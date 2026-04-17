# git_sanity_test tag verification: design notes and limitations

This file documents the design decisions, threat model, and known
limitations of the tag-state check in `help-steps/git_sanity_test`.
It is separate from the script so the analysis can be thorough without
bloating the script's inline comments.

Audience: developers / reviewers of `help-steps/git_sanity_test` and
related `derivative-update` / build-step code.

## Summary

`git_sanity_test` gates derivative-maker builds by:

1. Authenticating the target commit via `sq-git log` against the
   authorized signers in `openpgp-policy.toml`. **This is the
   cryptographic trust anchor.**
2. Enforcing release-workflow hygiene on tags at HEAD:
   - at most one tag at HEAD
   - that tag must be an annotated tag (not lightweight)
   - that tag must have a signature block (per the current check)
3. Rejecting uncommitted changes.

Item 1 is real cryptographic verification of the commit. Items 2 and
3 are **workflow hygiene**: they catch developer mistakes and repo
misconfiguration but are not themselves cryptographic trust checks.

This file is about item 2, the tag check. Specifically, about the
"tag must be signed" sub-requirement and what it can and cannot
actually enforce.

## Trust model recap

`sq-git log --trust-root ROOT -- TARGET` walks the commit chain from
ROOT to TARGET, validating each commit signature against the
authorized signers declared in `openpgp-policy.toml`. It is
**commit-centric**: tags don't enter into the authentication.

In derivative-maker, `sq_git_trust_root` is usually `HEAD` in CI and
non-redistributable builds (TOFU: the caller declares HEAD trusted)
and a fixed historical commit hash in redistributable non-CI builds
(strictly stronger than TOFU - `sq-git log` then walks every commit
between that anchor and HEAD).

Release trust for the built artifact rests entirely on this commit
authentication. If the commit chain is OK per the policy file, the
release is trustworthy regardless of what tags look like.

## Why check tags at all then?

Tags are not a cryptographic trust anchor, but they are a
**release-identification** anchor for the Kicksecure / Whonix
workflow:

- `derivative-update --tag v1.2.3` names a release by tag
- humans recognize "v1.2.3" as "the v1.2.3 release"
- downstream tooling (apt repos, image names) uses the tag name

A release cut from a commit that "looks right" but is not associated
with a proper release tag, or is associated with a lightweight
bookmark tag, or has two competing tags, is a **workflow bug** even
if the commit authentication succeeds. The tag check exists to catch
that category of mistake before a broken "release" is published.

So the policy is:

- only VALID tag states for a derivative-maker checkout are
  (A) no tag at HEAD (under `--allow-untagged`), or
  (B) exactly one annotated signed tag at HEAD
- any other state is a policy violation and a hard error

## sq-git does not help with tag state

Proven by experiment on Debian trixie `sequoia-git 0.4.0-4+b5` (Apr
2026):

```
$ git tag del                             # example 1: lightweight, no -a
$ git tag del -m .                        # example 2: annotated, no -s
$ git tag -v del                          # git's own verifier
# when used on example 1
error: del: cannot verify a non-tag object of type commit.
...
# when used on example 2
error: no signature found.

$ sq-git log --trust-root HEAD del        # our verifier, on either example
Verified that there is an authenticated path from the trust root
bf034a8f78dff7247bc528b7a322e7b2f666de0d to bf034a8f78dff7247bc528b7a322e7b2f666de0d.
```

`sq-git log` resolves any tag name to the commit it points at and
authenticates the commit chain. It does not look at the tag object,
does not care whether the tag is annotated or lightweight, and does
not care whether it has a signature. A lightweight tag silently
"passes" because its target commit is signed. This is why the tag
check in `git_sanity_test` has to exist on top of sq-git.

## The "is this tag signed?" problem

Deciding whether an annotated tag is signed is harder than it looks.

An annotated git tag object is a plain text blob. A signed tag has
its OpenPGP signature appended to the body:

```
object <sha>
type commit
tag v1.0
tagger Alice <alice@example.com> 1234567890 +0000

Release v1.0
Some release notes

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiE...    <actual base64-encoded signature packet>
-----END PGP SIGNATURE-----
```

An unsigned annotated tag is the same minus the signature block. So
far so good - a substring search for `-----BEGIN PGP SIGNATURE-----`
would work... except that the tag message is free-form text and can
contain anything, including that marker.

### Spoof attempt 1: marker text in the message body

```
$ git tag -a spoof -m "release notes

not a real sig:
-----BEGIN PGP SIGNATURE-----
fake fake fake
-----END PGP SIGNATURE-----

more notes after"
```

The resulting tag object contains the BEGIN marker anywhere a
substring search would find it. **A naive substring check
misclassifies this as signed.**

### Spoof attempt 2: use git's own `%(contents:signature)` atom

```
$ git for-each-ref --format='%(contents:signature)' refs/tags/spoof
-----BEGIN PGP SIGNATURE-----
fake fake fake
-----END PGP SIGNATURE-----

more notes after
```

Git's own ref-filter atom for extracting a tag signature finds the
first BEGIN marker and returns everything from there to end-of-body
as "the signature". Git's parser is a simple scan, not a
cryptographic check. **Also misclassifies the spoof as signed.**

### Spoof attempt 3: OpenPGP packet structure verification

Idea: extract whatever `%(contents:signature)` returns, pipe it
through `sq packet dump`. A structurally valid OpenPGP signature
packet parses; `fake fake fake` does not.

This closes the "I put ASCII garbage between armor headers" spoof.

**But it does not close the replay spoof:** an attacker can paste a
real, structurally valid signature block copied from a previously
created real signed tag in this repo. `sq packet dump` accepts it as
a valid OpenPGP packet and the tag classifies as signed. The
signature doesn't cryptographically cover THIS tag's payload - but we
never checked that.

### Spoof attempt 4: full cryptographic verification

The only way to truly distinguish "signed" from "unsigned" for a
given tag is to recompute the canonical hash of the tag object's
payload (`object <sha>\ntype commit\ntag <name>\ntagger ...\n\n<message>`)
and verify the signature was made over THAT hash.

Tools that do this:

- `git tag -v <tag>` - uses `gpg.openpgp.program` (usually gpg, or
  `sq-git-wrapper` if we re-wire it). Real verification, requires a
  key the verifier trusts. Exits 0 only on signature + trusted key.
- `sq verify --signer-cert <cert> --signature-file <sig> -` fed with
  the tag payload on stdin. Same story, requires the cert.

Both pull the signing cert management back into scope. We previously
decided against that because:

1. `openpgp-policy.toml` is sq-git's policy format. Neither
   `git tag -v` (wants gpg keyring) nor plain `sq verify` (wants a
   cert file) consumes it directly. Bridging would mean duplicating
   key management.
2. The cryptographic security gate is already `sq-git log` on the
   COMMIT. A forged tag cannot make the commit valid. An attacker
   without the signing key cannot create a release artifact that
   passes `sq-git log`; they can at most confuse a developer who
   rebuilds locally from a bogus tag.

## Current implementation

As of the time this file was written, `help-steps/git_sanity_test`
uses a substring check on the tag body for signature presence. This
is **spoofable by spoof attempts 1 through 4** above. The script
documents it as hygiene, not cryptographic verification.

The script is spoofable in the sense that a developer (or an
attacker with commit/tag push access) can craft a tag that passes
the "is it signed?" check without having signed anything. They
**cannot** thereby create a release artifact that passes
`sq-git log`: the commit chain is still authenticated independently.

What spoofability does enable:

- Developer forgets `-s`, pastes a PGP-looking block into the tag
  message, doesn't notice the mistake. Their local build succeeds.
  They push a "release" that the upstream verifier will reject. A
  workflow bug, not a security breach.

What spoofability does NOT enable:

- Forging a release that downstream verifiers will accept. Downstream
  verification authenticates the COMMIT via `sq-git log`; tags are
  metadata on top.

## Options considered

The real options for the "is this tag signed?" check, in order of
strictness:

### A) Substring check (current)

```bash
case "$tag_body" in
   *'-----BEGIN PGP SIGNATURE-----'*|...) : ;;
   *) return 2 ;;
esac
```

- **Spoofable:** yes, trivially (markers anywhere in message)
- **Dependencies:** none
- **Complexity:** minimal
- **Catches:** developer forgot `-s` with a normal release message
- **Misses:** developer copy-pasted sig-looking text; attacker with
  tag push access

### B) `git for-each-ref --format='%(contents:signature)'`

- **Spoofable:** yes, same way (git's parser is also a simple marker
  scan, confirmed by experiment)
- **Dependencies:** none beyond git
- **Complexity:** minimal
- **Advantage over A:** none in practice. Semantically cleaner (uses
  git's own atom) but the underlying parser is functionally the same.

### C) Drop the signature-presence check

- Policy becomes: "no tag, or exactly one annotated tag". Annotated
  tags are accepted regardless of signing.
- **Honest:** the script stops claiming to check something it
  cannot reliably check.
- **Weaker:** developers who forget `-s` are not caught.
- **Cryptographic security unchanged:** still rests on `sq-git log`
  commit authentication.

### D) `%(contents:signature)` + `sq packet dump` structural check

- **Closes spoofs 1-2** (random text inside fake armor fails
  OpenPGP packet parsing)
- **Does NOT close spoof 3** (replay of a real signature block from
  a previous tag - the packet parses successfully, it just wasn't
  made over THIS tag's payload)
- **Dependencies:** `sq` binary (present in trixie)
- **Complexity:** ~10 lines of shell
- **Still not cryptographic verification**

### E) Full cryptographic verification via `git tag -v` or `sq verify --signer-cert`

- **Closes all spoofs**
- **Dependencies:** gpg keyring with signer key, OR sq cert store
  with signer cert, OR extract cert from `openpgp-policy.toml` and
  pass it to `sq verify` as a file
- **Complexity:** signer cert management - the exact complexity we
  closed during the Sequoia migration
- **Architecturally inconsistent:** reintroduces a second trust
  store alongside `openpgp-policy.toml`

## Decision (to be made)

Not yet decided. The trade-off is:

- **Security reality:** `sq-git log` commit authentication is the
  real gate. Any tag-state check is hygiene.
- **Strictest honest check without new complexity:** D (still
  spoofable by replay)
- **Simplest honest check:** C (drop the signature claim, just
  require annotated)
- **Strictest check that actually closes replay:** E (but brings
  back all the cert management we eliminated)

A reasonable path is C for now (honest, simple) with a note that
switching to E later is possible if release-workflow enforcement
becomes important enough to justify the complexity.

## Threat model (summary)

| Actor | Capability | Caught by | Not caught by |
|---|---|---|---|
| Honest developer forgets `-s` | creates unsigned tag | substring check (if no markers in message) | substring check (if markers in message) |
| Honest developer with PGP-looking release notes | creates unsigned tag with spoof-triggering text | cryptographic verification of tag signature | substring check, `%(contents:signature)`, `sq packet dump` |
| Attacker with tag push access, no signing key | creates spoofed tag | cryptographic verification of tag signature | all options except E |
| Attacker with tag push access, no signing key | creates commit | `sq-git log` (commit is not signed by authorized signer) | N/A - caught |
| Attacker with signing key | anything | nothing | all options |

Key takeaway: anything worse than a honest-developer mistake is
caught by `sq-git log` on the commit, not by the tag check. The tag
check exists for the honest-developer case.

## Future directions

- If the Kicksecure release workflow adds tooling for cross-signing
  tags with commit keys, option E becomes tractable: we would trust
  the same certs for both commit and tag verification.
- If sequoia-git grows a `sq-git verify-tag` command that uses the
  policy file, the architectural objection to E disappears.
