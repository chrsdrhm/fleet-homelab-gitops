# Instructions for AI assistants

Rules for any AI assistant working in or reviewing this repo (Claude Code, GitHub Copilot and others). People should start with the [README](README.md).

## What this repo is

Fleet's configuration (organization settings, single sign-on, fleets, policies), applied to a homelab Fleet server with `fleetctl gitops`.
- **The server:** built by the separate `fleet-homelab-infra` repo and torn down between sessions.
- **Layout:** the one `fleetctl new` generates. Fleet's [GitOps reference](https://fleetdm.com/docs/configuration/yaml-files) is the authority on what each YAML file can hold.
- **Checks:** in [`checks/`](checks/README.md).

## Fleet's own approach (prefer it)

Follow Fleet's documented approach, and call out deviations.

- [Fleet's GitOps reference](https://fleetdm.com/docs/configuration/yaml-files): what each YAML file and key can hold.
- [`fleetdm/fleet/it-and-security`](https://github.com/fleetdm/fleet/tree/main/it-and-security): Fleet's own GitOps setup for its company devices, the best real-world example of structure, policies, reports, profiles and software.
- [The `fleetctl new` templates](https://github.com/fleetdm/fleet/tree/main/cmd/fleetctl/fleetctl/templates/new): where this repo's layout and `.github/fleet-gitops/` come from.
- [Fleet docs](https://fleetdm.com/docs) and [guides](https://fleetdm.com/guides).

## Hard rules

- **No private or identifying values, anywhere.** That covers YAML, commit messages, branch names, and PR titles, bodies and comments.
  - Private values include the Fleet URL and hostname, the identity provider's metadata or logo URLs, Okta org names, IDs and URLs, email addresses, and any token or enroll secret.
  - In the YAML they stay as `$VARIABLES` filled from GitHub secrets.
- **Never create a plaintext copy of a private value** (no extra files, secrets or logs).
- **Never change identity-provider group membership.**
- **Every change goes through a pull request.** `main` has no bypass. Branch from an up-to-date `origin/main`, and before adding commits to an existing branch, check that its pull request is still open. Merges are the owner's call.
- **Remember that `default.yml` defines everything.** Anything not in this repo is removed from Fleet on apply, including fleets created only in the UI.
- **Leave Fleet's scaffold alone:** `.github/fleet-gitops/` and the generated layout are Fleet's. Change them only on purpose, and say so.

## How to work here

- **Run the checks before pushing:** `checks/run.sh` (after `checks/install-tools.sh` once). Every pull request also gets a `fleetctl gitops --dry-run`.
- **Expect skipped runs while Fleet is down:** while the stack is torn down, runs skip with a warning instead of failing. The run that the infra repo's `up.sh` starts after the next rebuild applies `main`.

## When reviewing a pull request

Focus on, in order:
1. Private or identifying values.
2. Changes that remove or weaken something in Fleet: deleted fleets, policies, labels or software; SSO turned off; `enable_sso_idp_login` turned on.
3. Departures from Fleet's GitOps reference or from how Fleet's own `it-and-security` setup does the same thing.
4. Workflow security: permissions, untrusted input in `run:` steps, unpinned actions.

Skip style nits.
