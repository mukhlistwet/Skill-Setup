# Official Sources & Verification Notes

Semua sumber diverifikasi pada **26 November 2026**. Selalu periksa kembali dokumentasi versi terbaru sebelum upgrade besar karena ekosistem CLI/plugin coding-agent berkembang cepat.

## Skills CLI & Agent Specifications
- Vercel Skills CLI: https://github.com/vercel-labs/skills
- Commands reference: https://github.com/vercel-labs/skills/blob/main/docs/commands.md
- Agent paths reference: https://github.com/vercel-labs/skills/blob/main/docs/agents.md

## Native Coding-Agent Skill Docs
- OpenCode: https://opencode.ai/docs/skills/
- Claude Code: https://code.claude.com/docs/en/skills
- Codex: https://developers.openai.com/codex/skills
- Antigravity: https://antigravity.google/docs/commands/learn
- Hermes Agent: https://hermes-agent.nousresearch.com/docs/user-guide/features/skills

## Ecosystem & Candidate Repositories
- Context Mode (Upstream): https://github.com/mksglu/context-mode
- Context Mode (Install Guide): https://contextmode.ai/docs/engine/install
- Context Mode (Personal Fork Reference): https://github.com/mukhlistwet/context-mode
- Taste Skill (`design-taste-frontend`): https://github.com/Leonxlnx/taste-skill
- OpenDesign MCP: https://github.com/nexu-io/open-design
- Google `DESIGN.md` CLI: https://github.com/google-labs-code/design.md
- Awesome DESIGN.md Catalog: https://github.com/VoltAgent/awesome-design-md
- Awesome Design Skills Catalog: https://github.com/mukhlistwet/awesome-design-skills

## Known Caveats
1. Format Google `DESIGN.md` saat ini berstatus `alpha`; pin dependency dan commit `package-lock.json`.
2. URL upstream dan commit SHA untuk 11 core skills harus dipulihkan dari metadata/lockfile/backup device lama dan diisi ke `manifest/skills-manifest.csv`; jangan menebak repository hanya dari nama skill.
3. Skills CLI membuat direktori skill per agent, namun discovery native tetap wajib diverifikasi di dalam setiap aplikasi/CLI yang terpasang.
4. Scope global berarti user-level pada satu device, bukan cloud sync otomatis. Portabilitas lintas device dicapai melalui repository ini.
