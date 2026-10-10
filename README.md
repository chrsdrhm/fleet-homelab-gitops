[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/chrsdrhm/)

# fleet-homelab-gitops

[Fleet](https://fleetdm.com) configuration for my homelab Fleet Premium instance, managed as code with `fleetctl gitops`.

> **This is a personal learning project, not production guidance.** It configures a Fleet server in my own AWS account, which is torn down when I'm not using it. The infrastructure lives in a separate repo: [`fleet-homelab-infra`](https://github.com/chrsdrhm/fleet-homelab-infra). Take ideas from this, but don't treat it as a reference setup.

## What this is

Everything Fleet can manage from Git is described here in YAML. A GitHub Actions workflow applies it to the server, so a change goes through a pull request, a dry run, and a merge, and the history is the audit trail.

- **Org settings** (`default.yml`): organization name, single sign-on (Okta SAML with just-in-time provisioning), 
- **Fleets** (`fleets/`): one fleet, "Workstations", covering all my devices.
- **Labels, policies, reports, profiles, scripts and software** (`labels/`, `platforms/`): the scaffold's layout, filled in as I go.

## How it runs

| Trigger | What happens |
|---|---|
| Pull request | `fleetctl gitops --dry-run` only. Nothing changes in Fleet. |
| Push to `main` | Dry run, then apply. |
| Nightly, and manual | Same as a push, to correct any drift made in the UI. |
| After a rebuild | The infra repo's `up.sh` starts a run, so a change pushed while the stack was down is applied as soon as Fleet is back. |

The Fleet server is torn down between sessions. Every run first checks that Fleet answers. If it does not, a **nightly** run skips cleanly (there is nothing to reconcile) and a **pull request** passes with a notice (`main` requires the check, so changes can merge while the stack is down; the run after the next rebuild applies and checks them), while a **push or manual** run fails with a message to bring the stack up first.

Because `default.yml` contains `org_settings`, **anything not defined in this repo is removed from Fleet on apply**, including fleets created only in the UI. That is the point of GitOps, and it is also why edits belong here and not in the console.

## Security notes

- **No secret is stored in this repo.** Anything sensitive is a `$VARIABLE` in the YAML that the workflow fills in from GitHub Actions secrets: the Fleet API token and the identity provider's metadata URL. (Enroll secrets are not here at all: Fleet excludes them from GitOps by default and manages them itself.)
- The API token belongs to a dedicated API-only Fleet user with the `gitops` role, which can change configuration but cannot log in to the UI.
- The workflow runs with a read-only `GITHUB_TOKEN`, and every action is pinned to a commit SHA.
- The Fleet server sits behind a WAF that only allows US traffic, and GitHub's runners can be anywhere, so the workflow sends a secret header (a repository secret) that lets its requests past the country check. Fleet still requires the API token on every call.
- Pull requests from forks get no secrets, workflow runs from outside contributors need my approval, and only I can merge.
- If you spot something that looks like a security problem, please use this repo's **Security** tab to report it privately instead of opening a public issue.

## Built with AI assistance

I built this with [Claude Code](https://claude.com/claude-code). The design decisions, the Fleet instance it configures, and the review of what gets applied are mine; much of the setup and the fact-checking against Fleet's own source were done with the assistant.

## License

[MIT](LICENSE). Provided as-is, with no warranty. It's my own experiment, so expect it to change, break, or be torn down.
