---
name: fleet-gitops
description: Make changes to a Fleet GitOps repository (default.yml, fleets/*.yml or teams/*.yml, and the policies, reports, labels, scripts, software, configuration profiles, and DDM declarations they reference). Use this whenever a task touches Fleet-managed devices through YAML, even if the user never says "GitOps" - adding, scoping, or updating software (Fleet-maintained apps, custom packages, App Store or Google Play apps), writing a policy or report, remediating a CVE, creating or editing a .mobileconfig, DDM .json, Windows CSP .xml, or Android policy .json, changing labels, controls, OS update deadlines, or org settings, or reviewing a GitOps pull request. Covers the layout rules fleetctl enforces, validation against upstream schemas (osquery tables, Apple, Microsoft, Google), and fleetctl dry runs.
allowed-tools: Read, Grep, Glob, Edit, Write, WebFetch, WebSearch, Bash(python3 .agents/skills/fleet-gitops/scripts/validate.py*), Bash(plutil -lint *), Bash(xmllint --noout *), Bash(jq *), Bash(contour profile validate *), Bash(contour profile ddm validate *), Bash(git diff *), Bash(git status *), Bash(git log *), Bash(ls *), Bash(fleetctl gitops * --dry-run)
effort: high
---

# Fleet GitOps

Task: $ARGUMENTS

<!-- From Fleet's fleetctl new template (cmd/fleetctl/fleetctl/templates/new/.claude/skills/fleet-gitops). Changed in one place: `allowed-tools` pre-approves only the checks the skill runs (the validator, `plutil -lint`, `xmllint --noout`, `jq`, contour's validate commands, read-only git) and `fleetctl gitops` with `--dry-run` last, instead of any `python3`, `contour` or `find` command; anything else asks for permission first. -->

This is the Claude Code entry point for the `fleet-gitops` skill. The skill itself lives at `.agents/skills/fleet-gitops/` in the root of this repository, the cross-agent location that Codex, Cursor, GitHub Copilot, Gemini CLI, and Kilo Code also read, with its `references/` files and the `scripts/validate.py` checker beside it. Keeping one copy there means every agent follows the same instructions.

Read `.agents/skills/fleet-gitops/SKILL.md` now and follow it exactly as if it were this file. Its relative references (`references/...`, `scripts/validate.py`) resolve from that folder.
