# Skill Upstream Sources & Verification Notes

**Mapping reviewed:** 26 November 2026. This document records where each skill is sourced from and the caveats identified during repository/name verification. It is not a comprehensive security audit or a legal opinion. Upstream repositories may change after this review.

## Skills CLI and supported agent IDs

- Skills CLI repository: https://github.com/vercel-labs/skills
- Commands reference: https://github.com/vercel-labs/skills/blob/main/docs/commands.md
- Agent IDs reference: https://github.com/vercel-labs/skills/blob/main/docs/agents.md
- Skills CLI supports `npx skills add owner/repo --skill <skill-id>` and optional `owner/repo@<tag-or-commit>`; use `--global` for user-level installation and `--copy` for project-level copied files.
- Agent IDs used by this repository: `opencode`, `claude-code`, `codex`, `antigravity`, `hermes-agent`, `zcode`. Confirm support in the Skills CLI agent reference when upgrading the CLI.

## 11 core skills

| Skill ID | Upstream repository / exact source path | Verification and review notes |
|---|---|---|
| `frontend-ui-engineering` | [addyosmani/agent-skills — skill folder](https://github.com/addyosmani/agent-skills/tree/main/skills/frontend-ui-engineering) | Skill name is listed by the upstream agent-skills repository. Confirm current contents and license before adopting updates. |
| `webapp-testing` | [anthropics/skills — skill folder](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) | Exact skill ID found in the official Anthropic skills repository. Includes helper/script content (including `scripts/with_server.py` in the reviewed tree); read scripts and dependencies before allowing an agent to execute them. |
| `systematic-debugging` | [obra/superpowers — skill folder](https://github.com/obra/superpowers/tree/main/skills/systematic-debugging) | Exact skill ID found in the upstream Superpowers repository. The reviewed skill includes supporting scripts; inspect the complete folder before use. |
| `code-review` | [mattpocock/skills — engineering/code-review](https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review) | Exact skill ID found under `skills/engineering/code-review`. Upstream guidance may depend on issue-tracker context/setup; follow the source's setup instructions rather than assuming integrations exist. |
| `security-review` | [getsentry/skills — skill folder](https://github.com/getsentry/skills/tree/main/skills/security-review) | Exact skill ID found in the Sentry skills repository. Review its instructions against your own security policy and threat model. |
| `database-designer` | [borghei/Claude-Skills — engineering/database-designer](https://github.com/borghei/Claude-Skills/tree/main/engineering/database-designer) | Exact skill path found. The reviewed skill metadata identifies **MIT + Commons Clause**; the Commons Clause may restrict some commercial/redistribution use. Verify the current license text and obtain legal review where relevant. |
| `api-and-interface-design` | [addyosmani/agent-skills — skill folder](https://github.com/addyosmani/agent-skills/tree/main/skills/api-and-interface-design) | Exact skill name listed by upstream. Confirm current contents and license before adopting updates. |
| `software-architecture` | [sickn33/agentic-awesome-skills — skill folder](https://github.com/sickn33/agentic-awesome-skills/tree/main/skills/software-architecture) | Exact skill ID found. Reviewed metadata marks it `source: community` and `risk: critical`; treat that as a prompt to inspect all instructions and bundled files carefully, not as proof of malicious behavior. |
| `ci-cd-pipeline-builder` | [alirezarezvani/claude-skills — engineering/skills/ci-cd-pipeline-builder](https://github.com/alirezarezvani/claude-skills/tree/main/engineering/skills/ci-cd-pipeline-builder) | Exact skill file found at this path. Inspect pipeline examples and any scripts for commands, secrets handling, and external services before use. |
| `observability-setup` | [patricio0312rev/skills](https://github.com/patricio0312rev/skills) | Skills CLI listing provides the exact `observability-setup` install ID. At the reviewed snapshot, the skills.sh listing showed Pass for Gen Agent Trust Hub, Socket, and Snyk. These are point-in-time third-party checks, not a complete security audit or guarantee; re-check and inspect source before use. |
| `performance-engineer` | [sickn33/agentic-awesome-skills — skill folder](https://github.com/sickn33/agentic-awesome-skills/tree/main/skills/performance-engineer) | Exact skill ID found. Reviewed metadata marks it `source: community` and `risk: critical`; manually inspect the content and any executable assets before use. |

## 2 conditional skills

| Skill ID | Upstream repository / exact source path | Intended scope |
|---|---|---|
| `design-taste-frontend` | [Leonxlnx/taste-skill — `skills/taste-skill`](https://github.com/Leonxlnx/taste-skill/tree/main/skills/taste-skill) | Project-level. The current default is v2 and is described upstream as experimental/actively iterating. A skills.sh snapshot showed mixed scanner results (Gen Agent Trust Hub Fail, Socket Pass, Snyk Warn); inspect scripts/network behavior and repeat scans before use. |
| `vercel-react-best-practices` | [vercel-labs/agent-skills — skills/react-best-practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) | Conditional global or project-level. Relevant to React/Next.js rendering, async waterfalls, bundle, and server/client boundary decisions. |

## License and security policy

1. A source link is provenance, not an endorsement or completed security audit.
2. Inspect `SKILL.md`, references, scripts, hooks, templates, and other files in the full upstream skill directory before installation. Review shell commands, network access, file writes, credential access, and destructive operations.
3. Check the current license file for every upstream. The `license` column in the manifest is a reminder, not a substitute for license review. `SEE_UPSTREAM` and `CHECK_UPSTREAM` intentionally mean the license has not been normalized/legally cleared in this repository.
4. Some third-party metadata marks `software-architecture` and `performance-engineer` as `risk: critical`. This label does not prove the content is malicious, but it is a reason for a human review before use.
5. Never provide an agent with broader permissions merely because a skill requests them. Use the least-privilege tool and filesystem policy for the task.
6. Repeat trust scans before adopting new upstream commits. Security scanner output is time-sensitive and should be recorded with scan date/tool/version if used as a decision input.

## Version pinning

The current manifest deliberately leaves `ref` empty because a full commit SHA or release tag was not verified for every source during this mapping pass. Therefore:

- `source` is populated and installable by Skills CLI.
- empty `ref` means the source's default branch at install time (floating version).
- to lock an installation, review the skill, choose an immutable full commit SHA or release tag, and set `ref` in `manifest/skills-manifest.csv`.
- do not invent SHAs or use a ref from a different repository/skill.
- after changing `ref`, run the installer's dry-run and test the skill in each target agent before committing the manifest.

## Native coding-agent documentation

- OpenCode: https://opencode.ai/docs/skills/
- Claude Code: https://code.claude.com/docs/en/skills
- Codex: https://developers.openai.com/codex/skills
- Antigravity: https://antigravity.google/docs/commands/learn
- Hermes Agent: https://hermes-agent.nousresearch.com/docs/user-guide/features/skills

## Related components (not Agent Skills)

- Context Mode upstream: https://github.com/mksglu/context-mode
- Context Mode personal fork reference: https://github.com/mukhlistwet/context-mode
- OpenDesign MCP: https://github.com/nexu-io/open-design
- Google `DESIGN.md` CLI: https://github.com/google-labs-code/design.md
- Awesome DESIGN.md catalog: https://github.com/VoltAgent/awesome-design-md
- Awesome Design Skills catalog: https://github.com/mukhlistwet/awesome-design-skills

Context Mode, OpenDesign MCP, and `@google/design.md` are separate components. Do not install them using the Agent Skills manifest unless their own setup guides explicitly require that workflow.
