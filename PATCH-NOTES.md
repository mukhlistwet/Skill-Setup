# Skill-Setup patch notes — 2.1

Extract this ZIP into the root of the existing `Skill-Setup` repository. Keep the directory structure and allow overwrite for files with the same path.

## Added

- `INSTALL-SKILLS.bat` — interactive global installer with agent selection, optional Vercel React conditional skill, dry-run, and explicit confirmation.
- `INSTALL-PROJECT-DESIGN-SKILL.bat` — project-specific installer for `design-taste-frontend` using `--copy`.

## Updated

- `README.md` — source column added to the 11 Core + 2 Conditional skill tables; install guidance and version-pinning behavior documented.
- `manifest/skills-manifest.csv` — all 13 `source` values populated with the verified upstream repository shorthand.
- `scripts/install-global-skills.ps1` — supports optional blank `ref`, CSV agent selection from BAT, explicit conditional selection, and npx `--yes`.
- `scripts/install-project-skills.ps1` — supports optional blank `ref`, CSV agent/skill selection, project `--copy`, and npx `--yes`.
- `scripts/verify-install.ps1` — no longer treats blank `ref` as a placeholder; reports unpinned sources and checks the documented Antigravity global path / shared `.agents/skills` project path.
- `docs/SOURCES.md` — records upstream links, verification notes, license/security caveats, and pinning policy.
- `runbooks/01-NEW-DEVICE.md` and `runbooks/03-MAINTENANCE.md` — updated install, migration, verification, and source-pinning steps.

## Deliberate limitation

The `ref` field remains blank because immutable commit SHAs/tags were not verified for every source. Installations therefore use the upstream default branch and are not fully reproducible until `ref` is pinned. Do not treat source mapping as a complete security or legal audit.

## Validation performed

- CSV parses and contains exactly 13 rows: 11 `global` and 2 conditional/project rows.
- All 13 `source` entries are non-empty; no source placeholders remain.
- README contains source links for all 13 skill entries.
- Static checks confirm the installers support blank `ref`, dry-run, agent selection, and explicit conditional/project selection.
- ZIP integrity test passed.

PowerShell and BAT scripts were not executed on a native Windows machine in this build environment. Run the BAT dry-run on Windows and review its output before confirming installation.


## Hotfix v2.1.1 — Manifest path resolution

- Fixed `Join-Path` failure caused by evaluating `$PSScriptRoot` inside a `param()` default expression.
- All three PowerShell scripts now resolve the default manifest path after parameter binding using the script file path.
- Both BAT launchers now pass the manifest path explicitly and stop early when the manifest is missing.
- Existing installation behavior, skill selection, and confirmation flow are unchanged.
