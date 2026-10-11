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
  - Placeholder email addresses use `example.com`, `example.org` or `example.net`, the only domains the private-values check accepts.
- **Never create a plaintext copy of a private value** (no extra files, secrets or logs).
- **Never change identity-provider group membership.**
- **Every change goes through a pull request.** `main` has no bypass. Branch from an up-to-date `origin/main`, and before adding commits to an existing branch, check that its pull request is still open. Merges are the owner's call.
- **Remember that `default.yml` defines everything.** Anything not in this repo is removed from Fleet on apply, including fleets created only in the UI.
- **Leave Fleet's scaffold alone:** `.github/fleet-gitops/` and the generated layout are Fleet's. Change them only on purpose, and say so.

## How to work here

- **Run the checks before pushing:** `checks/run.sh` (after `checks/install-tools.sh` once). Every pull request also gets a `fleetctl gitops --dry-run`.
- **Expect skipped runs while Fleet is down:** while the stack is torn down, runs skip with a warning instead of failing. The run that the infra repo's `up.sh` starts after the next rebuild applies `main`.

## When reviewing a pull request

This repo deploys real endpoint configuration: policies, configuration profiles, scripts that run as root on every device in a fleet, and software. Review it as security configuration, not just YAML.

Comment only on what matters, with file and line, why it matters, and a suggested fix. Never quote a private value; point to where it is. Skip style nits.

**Standards to review against:**
- **CIS Benchmarks.** Fleet publishes CIS-based policies for macOS and Windows in [`fleetdm/fleet/ee/cis`](https://github.com/fleetdm/fleet/tree/main/ee/cis); see [Fleet's CIS docs](https://fleetdm.com/docs/using-fleet/cis-benchmarks). CIS's own PDFs need a free registration at cisecurity.org.
- **NIST's [macOS Security Compliance Project](https://pages.nist.gov/macos_security/)** ([source](https://github.com/usnistgov/macos_security)). It maps macOS settings to NIST SP 800-53, CIS and DISA STIG.
- **[DISA STIGs](https://public.cyber.mil/stigs/)**, and NIST's [National Checklist Program](https://csrc.nist.gov/projects/national-checklist-program).
- **[Microsoft's Windows security baselines](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines).**
- **Fleet's own approach** (above).

Cite a specific control ID only when you are sure of it; never invent one. This is a homelab, so a deliberate deviation is fine. Flag it, and ask for the reason to be written down in the change.

**Check, in this order:**
1. **Private or identifying values** anywhere in the change, including PR text and file names. Treat an email address on any domain other than `example.com`, `example.org` or `example.net` as a finding, even one that looks made up: the private-values check fails on it too, and the text reaches devices as written.
2. **Anything that weakens an endpoint control** compared with the baselines above. For example:
   - turning off disk encryption, the firewall, Gatekeeper or SIP, SmartScreen or Defender
   - a weaker screen lock or password policy
   - delayed or disabled OS updates
   - broader admin rights, or remote access left open
   - less logging
   - an existing policy removed or loosened
3. **What runs on devices:**
   - **Scripts** run as root on every device in the fleet they target, so check what they change and that they're idempotent.
   - **Software** should come from trusted sources, pinned to versions or hashes where Fleet supports it.
   - **Labels and fleet targeting** should reach only the intended devices.
4. **Fleet behaviour:** anything removed (fleets, policies, reports, labels, profiles, software), because what isn't in this repo is deleted from Fleet. Also single sign-on turned off, or `enable_sso_idp_login` turned on.
5. **Departures from Fleet's GitOps reference,** or from how Fleet's own `it-and-security` setup does the same thing.
6. **Workflow security:** permissions, untrusted input in `run:` steps, unpinned actions.
