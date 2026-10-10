# checks

Every check for this repo lives here, so it's all in one place and can be removed in one go. CI (the `gitops-lint` job in `.github/workflows/lint.yml`) runs the same script you can run locally.

| Check | File | What it does |
|---|---|---|
| Private values | `private-values/check.py` (also the optional local hooks) | Fails if a change, file name, commit message, or PR title/body contains a private value. See below. |
| Checker self-test | `tests/test_private_values.py` | Tests the private-values checker with phony values. |
| shellcheck | `run.sh` | Lints our scripts and hooks. Fleet's scaffold in `.github/fleet-gitops/` is left as generated. |
| actionlint | `run.sh` | Lints the workflow files, including the shell in `run:` blocks. |
| zizmor | `run.sh`, `zizmor.yml` | Security audit of the workflows. Official image, pinned by digest. |

Fleet's own validation of the configuration is the `fleetctl gitops --dry-run` that the GitOps workflow runs on every pull request; it isn't part of this folder.

## Running them locally

```bash
checks/install-tools.sh                  # once: pinned actionlint into .check-tools/ (gitignored)
checks/run.sh                            # everything (zizmor needs Docker running; skipped otherwise)
git config core.hooksPath checks/hooks   # optional: check every commit for private values
```

## Removing them

Delete this folder. The lint workflow then has nothing to run and passes. You can also delete `.github/workflows/lint.yml`; if `gitops-lint` is a required check in your branch rules, remove it there too. If the hooks were on, run `git config --unset core.hooksPath`.

## Private values

The checker is the same as the infra repo's: patterns for AWS account IDs, Okta org names, URLs and app IDs, personal emails and signed tokens, plus SHA-256 hashes (with plain labels) of values no pattern can single out. It never stores or prints a value.

The hash list is maintained from the infra repo, which holds the files the values come from. Its [`checks/README.md`](https://github.com/chrsdrhm/fleet-homelab-infra/blob/main/checks/README.md#private-values) explains when and how to update it. Its `sync-hashes.sh` updates the `PRIVATE_HASHES` secret here too.

All values in the checker's tests are phony placeholders.
