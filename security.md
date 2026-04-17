# git_sanity_test tag verification: design notes

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
   primary cryptographic trust anchor.**
2. Enforcing release-workflow hygiene on, and authenticating, tags at
   HEAD:
   - at most one tag at HEAD
   - that tag must be an annotated tag (not lightweight)
   - that tag must be signed by a trusted developer
   **This is a secondary cryptographic trust anchor.**
3. Rejecting uncommitted changes.

Items 1 and 2 are real cryptographic verification of the repository.
Item 3 is **workflow hygiene**: it catches developer mistakes but is
not itself a trust check.

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

Release trust for the built artifact rests mostly on this commit
authentication. If the commit chain is OK per the policy file, the
commit being verified is trustworthy regardless of what tags look like.

## Why check tags at all then?

Tags are a **release-identification** anchor for the Kicksecure
/ Whonix workflow:

- `derivative-update --tag v1.2.3` names a release by tag
- humans recognize "v1.2.3" as "the v1.2.3 release"
- downstream tooling (apt repos, image names) uses the tag name

Users and developers will generally build release artifacts from a
specific tag. Tags are bound to version numbers, and version numbers
must be trustworthy enough to use to determine whether a vulnerability
in an earlier version of Kicksecure or Whonix is present or absent from
the artifact being built. If an attacker can create tags that end-users
trust, the attacker can make users build artifacts from any commit.
**This would allow attackers to perform rollback attacks on users who
build Kicksecure or Whonix from source.** Signing tags ensures that
only trusted developers can assign version numbers to commits,
preventing this attack scenario.

So the policy is:

- only VALID tag states for a derivative-maker checkout are
  (A) no tag at HEAD (under `--allow-untagged`), or
  (B) exactly one annotated tag at HEAD, signed by a trusted developer
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
# when used on example 2
...
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

## Current implementation

As of the time this file was written, `help-steps/git_sanity_test`
extracts signing keys that are trusted to sign tags from the
`openpgp-policy.toml` file, then uses those to verify tag signatures.
This ensures that tags can be trusted by end-users.

## Future directions

If sequoia-git grows a `sq-git verify-tag` command that uses the
policy file, the code will be able to be simplified.
