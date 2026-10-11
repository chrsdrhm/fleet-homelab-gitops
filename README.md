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

## Getting started

This repo configures the Fleet server built by [`fleet-homelab-infra`](https://github.com/chrsdrhm/fleet-homelab-infra). Set that up first, then follow its [setup guide's GitOps step](https://github.com/chrsdrhm/fleet-homelab-infra/blob/main/docs/setup.md#7-the-gitops-repo-fleets-configuration) to connect this repo.

## How it runs

| Trigger | What happens |
|---|---|
| Pull request | `fleetctl gitops --dry-run` only. Nothing changes in Fleet. The workflow and action come from `main`, so a pull request can't change the code that runs with the API token; its YAML is only read. |
| Push to `main` | Dry run, then apply. |
| Nightly, and manual | Same as a push, to correct any drift. |
| After a rebuild | The infra repo's `up.sh` starts a run, so a change pushed while the stack was down is applied as soon as Fleet is back. |
| Optional: Claude review | Claude reviews each pull request when it's opened, against Fleet's approach and endpoint baselines (CIS, NIST, STIG). Comment `@claude` on a pull request to review its latest commit again. It needs a Claude subscription; see the infra repo's [GitHub setup](https://github.com/chrsdrhm/fleet-homelab-infra/blob/main/docs/github-setup.md#6-optional-claude-reviews-pull-requests). |

### While the stack is down

The Fleet server is [torn down between sessions](https://github.com/chrsdrhm/fleet-homelab-infra#teardown-and-rebuild), and this repo is built for that:

- **No failed runs.** Every run first checks that Fleet answers. If it doesn't, the run is skipped with a **warning** instead of failing, so a pull request still passes its check and can be merged.
- **Nothing is lost.** Changes merged while Fleet is down are applied as soon as it's back: the infra repo's `up.sh` starts a run after every rebuild, and that run applies whatever is on `main`.
- Pull requests without secrets (Dependabot or forks) skip their dry run with a notice.

### GitOps mode: the UI is read-only

Because `default.yml` contains `org_settings`, **anything not defined in this repo is removed from Fleet on apply**, including things created only in the UI, on a merge or by the nightly run. The dry run doesn't compare with the server, so nothing would warn you. So **GitOps mode is on** (`org_settings.gitops` in `default.yml`): Fleet's UI shows everything this repo manages as read-only, with a link here, and changes go through a pull request. If you run this with CI, keep it on.

**Exceptions.** Fleet can leave three things editable in the UI (Settings → Integrations → Change management; they can't be set in YAML). Only enroll secrets are excepted here, which is Fleet's default. You'd add the others if their speed matters more than having every change reviewed and in Git:
- **Enroll secrets** (on by default, and kept on): they're secrets, so they can't live in this public repo; rotate them in the UI.
- **Labels:** to make a label on the spot, such as a manual label to group a few hosts during an investigation, without a pull request.
- **Software:** to upload an installer or add an App Store app from the UI, for example a one-off install or a package too large for Git.

Excepted items aren't in this repo, so it stops being the full record of them, and GitOps no longer manages them.

## Security notes

- **Nothing sensitive or identifying in the YAML.** The server URL and the identity provider's URLs are `$VARIABLES` filled in from GitHub Actions secrets, and the API token is passed in by the workflow. Enroll secrets aren't here at all; Fleet manages them itself.
- **A least-privilege token.** It belongs to an API-only Fleet user with the `gitops` role, which can change configuration but can't log in to the UI. A pull request's dry run uses the workflow and action from `main`, as Fleet's current template does, so a pull request can't edit them to read the token. `fleetctl` still reads the pull request's YAML and fills in its `$VARIABLES`, which could put a secret's value into what the dry run sends to Fleet, so dry runs are limited to this repo's own branches, which only people with write access can push.
- **Through the WAF by header, not by opening it up.** Fleet only accepts US traffic, and GitHub's runners can be anywhere, so the workflow sends a secret header that lets its requests past the country check. Fleet still requires the API token on every call.
- **Checked on every pull request.** A lint workflow runs `actionlint` and `zizmor` on the workflows and fails if a pull request adds a private value: AWS account IDs, Okta org and app IDs, personal emails and signed tokens by pattern, plus values a pattern can't describe (like the hostname), checked against a list of their SHA-256 hashes in a repository secret, so no plaintext is stored anywhere. Everything is in [`checks/`](checks/README.md), which also explains running the checks locally, the optional hooks, and removing them.
- **Found a problem?** Please [report it privately](https://github.com/chrsdrhm/fleet-homelab-gitops/security/advisories/new) through this repo's **Security** tab instead of opening a public issue.

## Built with AI assistance

I built this with [Claude Code](https://claude.com/claude-code). The design decisions, the Fleet instance it configures, and the review of what gets applied are mine; much of the setup and the fact-checking against Fleet's own source were done with the assistant. Rules for AI assistants working in or reviewing this repo are in [`AGENTS.md`](AGENTS.md), which Claude Code, GitHub Copilot and other tools read; `CLAUDE.md` only imports it, for Claude Code setups that read nothing else. Fleet's `/fleet-gitops` skill (in `.claude/skills/`, from its `fleetctl new` template) checks new policies, profiles and software against Fleet's and Apple's references; here it may run `fleetctl gitops` only as a dry run.

## License

[MIT](LICENSE). Provided as-is, with no warranty. It's my own experiment, so expect it to change, break, or be torn down.

