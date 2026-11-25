<!--
This file only imports AGENTS.md, which holds the instructions for every AI assistant
and reviewer (Claude Code, GitHub Copilot and others). Edit AGENTS.md, not this file.

Why both: AGENTS.md is the shared, tool-neutral convention. Claude Code reads it on
its own, but when a repo also has a CLAUDE.md it reads only the CLAUDE.md, and older
Claude Code versions read only CLAUDE.md. This import makes Claude get AGENTS.md
either way. Instructions only Claude should see can go below the import.
-->
@AGENTS.md

## Claude Code notes

- The repository's agent instructions live in `AGENTS.md`, imported above, so Claude Code and the other agents follow the same rules.
- The `fleet-gitops` skill is registered under `.claude/skills/fleet-gitops/` and hands off to the full skill in `.agents/skills/fleet-gitops/`. Invoke it with `/fleet-gitops`, or let it trigger on its own for GitOps work.
