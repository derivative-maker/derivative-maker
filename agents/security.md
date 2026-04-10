* The command line is considered trusted because it is input from the end-user.
* Files on the filesystem are considered trusted at the time derivative-maker or derivative-update runs;
  * the user is expected to have verified the Git repo integrity using manual digital software verification or similar before running either script.
* The only time where trust matters in the derivative-maker codebase is when running derivative-update - the files present on the filesystem when derivative-update runs are considered trusted, but the files that are being fetched from upstream are not trusted until they have been cryptographically verified.
  * This means that derivative-update must never run git checkout until after it has verified whatever ref it is about to check out.
* Verbose logging is generally considered a feature, not a bug, unless you can find a specific secrets leak in CI logs.

secrets:

* `./roles/common/vars/secrets.yml`
