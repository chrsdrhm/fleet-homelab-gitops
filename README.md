[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/chrsdrhm/)

# fleet-homelab-gitops

[Fleet](https://fleetdm.com) configuration for my homelab Fleet Premium instance, managed as code with `fleetctl gitops`.

> **This is a personal learning project, not production guidance.** It configures a Fleet server in my own AWS account, which is torn down when I'm not using it. The infrastructure lives in a separate repo: [`fleet-homelab-infra`](https://github.com/chrsdrhm/fleet-homelab-infra). Take ideas from this, but don't treat it as a reference setup.

## What this is

Everything Fleet can manage from Git is described here in YAML. A GitHub Actions workflow applies it to the server, so a change goes through a pull request, a dry run, and a merge, and the history is the audit trail.

The layout is the one `fleetctl new` generates:

- **`default.yml`**: organization-wide settings, such as single sign-on and MDM.
- **`fleets/`**: one file per fleet, each with its own settings, policies and software.
- **`labels/`** and **`platforms/`**: labels, and per-platform profiles, scripts, software, policies and reports that the YAML files refer to.

Fleet's [GitOps reference](https://fleetdm.com/docs/configuration/yaml-files) lists everything each file can hold.

**Single sign-on is optional.** Fleet works without it: people sign in with a password instead. I use Okta because it makes the lab more like a real deployment, where people sign in through the company's identity provider and get their Fleet role from it. To run this without Okta, set `enable_sso: false` under `sso_settings` in `default.yml` (or remove the `sso_settings` block) and leave out the `FLEET_OKTA_METADATA_URL` and `FLEET_IDP_IMAGE_URL` secrets; the pull request's dry run shows whether Fleet accepts the change. Fleet's SSO is standard SAML, so another identity provider can take Okta's place by pointing `metadata_url` at its metadata. The Okta side of this setup is Terraform in the infra repo's [`okta/`](https://github.com/chrsdrhm/fleet-homelab-infra/tree/main/okta), which is optional there too.

## Getting started

This repo configures the Fleet server built by [`fleet-homelab-infra`](https://github.com/chrsdrhm/fleet-homelab-infra). Set that up first, then follow its [setup guide's GitOps step](https://github.com/chrsdrhm/fleet-homelab-infra/blob/main/docs/setup.md#7-the-gitops-repo-fleets-configuration) to connect this repo.

## How it runs

| Trigger | What happens |
|---|---|
| Pull request | `fleetctl gitops --dry-run` only. Nothing changes in Fleet. |
| Push to `main` | Dry run, then apply. |
| Nightly, and manual | Same as a push, to correct any drift made in the UI. |
| After a rebuild | The infra repo's `up.sh` starts a run, so a change pushed while the stack was down is applied as soon as Fleet is back. |

### While the stack is down

The Fleet server is [torn down between sessions](https://github.com/chrsdrhm/fleet-homelab-infra#teardown-and-rebuild), and this repo is built for that:

- **No failed runs.** Every run first checks that Fleet answers. If it doesn't, the run is skipped with a **warning** instead of failing, so a pull request still passes its check and can be merged.
- **Nothing is lost.** Changes merged while Fleet is down are applied as soon as it's back: the infra repo's `up.sh` starts a run after every rebuild, and that run applies whatever is on `main`.
- Pull requests without secrets (Dependabot or forks) skip their dry run with a notice.

Because `default.yml` contains `org_settings`, **anything not defined in this repo is removed from Fleet on apply**, including fleets created only in the UI. That is the point of GitOps, and it is also why edits belong here and not in the console.

## Security notes

- **Nothing sensitive or identifying in the YAML.** The server URL and the identity provider's URLs are `$VARIABLES` filled in from GitHub Actions secrets, and the API token is passed in by the workflow. Enroll secrets aren't here at all; Fleet manages them itself.
- **A least-privilege token.** It belongs to an API-only Fleet user with the `gitops` role, which can change configuration but can't log in to the UI.
- **Through the WAF by header, not by opening it up.** Fleet only accepts US traffic, and GitHub's runners can be anywhere, so the workflow sends a secret header that lets its requests past the country check. Fleet still requires the API token on every call.
- **Checked on every pull request.** A lint workflow runs `actionlint` and `zizmor` on the workflows and fails if a pull request adds a private value: AWS account IDs, Okta org and app IDs, personal emails and signed tokens by pattern, plus values a pattern can't describe (like the hostname), checked against a list of their SHA-256 hashes in a repository secret, so no plaintext is stored anywhere. Everything is in [`checks/`](checks/README.md), which also explains running the checks locally, the optional hooks, and removing them.
- **Found a problem?** Please [report it privately](https://github.com/chrsdrhm/fleet-homelab-gitops/security/advisories/new) through this repo's **Security** tab instead of opening a public issue.

## Built with AI assistance

I built this with [Claude Code](https://claude.com/claude-code). The design decisions, the Fleet instance it configures, and the review of what gets applied are mine; much of the setup and the fact-checking against Fleet's own source were done with the assistant.

## License

[MIT](LICENSE). Provided as-is, with no warranty. It's my own experiment, so expect it to change, break, or be torn down.
