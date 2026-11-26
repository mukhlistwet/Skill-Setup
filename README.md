# Engineering Agent Setup

Panduan operasional, manifest, policy, template, dan skrip otomasi untuk menyiapkan lingkungan **AI coding-agent** pada **Windows 11 + PowerShell** secara konsisten saat pindah device atau memulai project baru.

- **Versi:** 2.0 (Repo-Ready Runbook Edition)
- **Verifikasi sumber terakhir:** 26 November 2026
- **Target OS:** Windows 11 + PowerShell
- **Coding-agent tercakup:** OpenCode / Oh My OpenCode (OMP), Claude Code CLI, Codex, Antigravity, Hermes Agent, ZCode

---

## Peta Navigasi Repository

| Folder / File | Kegunaan |
|---|---|
| `runbooks/01-NEW-DEVICE.md` | Langkah terurut setup laptop/PC baru dari nol hingga verifikasi |
| `runbooks/02-NEW-PROJECT.md` | Playbook setup project baru berdasarkan tipe (API, Dashboard/ERP, Landing Page) |
| `runbooks/03-MAINTENANCE.md` | Backup, update, pemulihan source manifest, audit skill baru, dan rollback |
| `manifest/skills-manifest.csv` | Sumber kebenaran daftar 11 core skills + 2 conditional skills |
| `manifest/harnesses.json` | Metadata path dan dukungan plugin per coding-agent |
| `manifest/winget-packages.json` | Daftar paket dasar Windows developer environment (`winget import`) |
| `policies/` | Kebijakan engineering, keamanan, quality gates, dan design system |
| `templates/` | Template `DESIGN.md`, `AGENTS.md`, `.env.example`, dan `.gitignore` agent |
| `scripts/` | Skrip PowerShell untuk backup, install global/project, verifikasi, dan rollback |
| `docs/REFERENCE-AGENTS-PATHS.md` | Referensi tunggal lokasi folder agent, Context Mode, dan OpenDesign MCP |
| `docs/DECISIONS.md` | Catatan keputusan konsolidasi skill dan pemisahan komponen |
| `docs/SOURCES.md` | Daftar dokumentasi resmi, repository kandidat, dan caveat |

---

## Arsitektur Komponen

Tidak semua ekosistem coding-agent dipasang sebagai Agent Skill. Pisahkan menjadi lima kategori:

| Jenis | Contoh | Fungsi | Cara Pemasangan |
|---|---|---|---|
| **Agent Skill** | `security-review`, `frontend-ui-engineering`, `design-taste-frontend` | Prosedur/instruksi yang dipanggil agent saat relevan | Vercel Skills CLI (`npx.cmd skills`) atau native harness |
| **Plugin / MCP** | Context Mode, OpenDesign MCP | Menambah tools, hooks, atau koneksi workspace | Install satu kali per harness yang didukung |
| **CLI Tool** | `@google/design.md` | Validasi dan diff dokumen design system | `npm` / `npx` per project |
| **Design Specification** | `DESIGN.md` | Sumber kebenaran visual & token satu project | Simpan di root project dan commit ke Git |
| **Catalog / Reference** | `awesome-design-md`, `awesome-design-skills` | Referensi inspirasi desain | Pilih maksimal satu referensi, adaptasikan; jangan bulk-install |

### Prinsip Scope: Global vs Project-Level

- **Global (user-level):** Tersedia lintas project di satu device/user. Digunakan untuk **11 core engineering skills** (debugging, review, security, database, API, architecture, CI/CD, observability, performance, frontend engineering, webapp testing).
- **Project-level:** Tersedia khusus satu repository dan ikut ter-commit lewat `--copy`. Digunakan untuk `design-taste-frontend`, `DESIGN.md`, dan skill spesifik framework/project.
- **Conditional:** `vercel-react-best-practices` dipasang global hanya jika mayoritas pekerjaan menggunakan React/Next.js; selain itu pasang project-level.

---

## Ringkasan Skill Final (11 Core + 2 Conditional)

### Core Skills (Global)

| No. | Skill | Fokus Utama |
|---:|---|---|
| 1 | `frontend-ui-engineering` | Implementasi UI, komponen, state, interaksi, responsive behavior |
| 2 | `webapp-testing` | Pengujian workflow UI nyata di browser |
| 3 | `systematic-debugging` | Root-cause debugging untuk bug dan regression |
| 4 | `code-review` | Review diff dan kualitas perubahan kode |
| 5 | `security-review` | Review auth, authorization, input, secrets, API, trust boundary |
| 6 | `database-designer` | Schema, index, query optimization, data model, migration |
| 7 | `api-and-interface-design` | Kontrak API/service, request/response, backward compatibility |
| 8 | `software-architecture` | System boundary, tradeoff arsitektur, ADR |
| 9 | `ci-cd-pipeline-builder` | Desain build, test, dan deployment pipeline |
| 10 | `observability-setup` | Logging, metrics, tracing, alerting, SLI/SLO |
| 11 | `performance-engineer` | Profiling, bottleneck analysis, capacity & benchmark |

### Conditional Skills

| Skill | Scope Rekomendasi | Kapan Digunakan |
|---|---|---|
| `design-taste-frontend` | Project-level (`--copy`) | Company website, SaaS marketing site, landing page, product launch, visual redesign eksplisit |
| `vercel-react-best-practices` | Conditional (Global/Project) | Optimasi React/Next.js: rendering, async waterfall, bundle, server/client boundary |

---

## Tindakan Wajib Sebelum Pemakaian Pertama

> **Lengkapi `manifest/skills-manifest.csv` terlebih dahulu.**  
> Beberapa entri core skill masih memakai placeholder `<VERIFIED_OWNER/REPO>` dan `<TAG_OR_COMMIT>` karena metadata URL upstream harus diambil langsung dari instalasi aktif atau `skills-lock.json` device lama. Skrip `install-global-skills.ps1` akan otomatis menolak berjalan jika masih ada placeholder agar tidak memasang source yang salah. Lihat panduan pemulihannya di `runbooks/03-MAINTENANCE.md`.

---

## Batas Git: Apa yang Masuk & Dilarang

| Item | Setup Repository Ini | Project Repository |
|---|---|---|
| `skills-manifest.csv` (source & commit SHA) | Ya | Opsional |
| Skrip backup/install/verify/rollback | Ya | Opsional |
| Kebijakan kanonikal (`policies/`) | Ya | Rujuk atau adaptasi di `AGENTS.md` |
| `DESIGN.md` | Template saja (`templates/`) | Ya, spesifik produk |
| Project-specific skills (`--copy`) | Tidak | Ya |
| `skills-lock.json` | Tidak selalu | Ya jika dikelola Skills CLI |
| `.env`, API key, agent auth files, session history | **Dilarang** | **Dilarang** |

---

## Quick Reference Command

| Tujuan | Command (PowerShell) |
|---|---|
| Backup global skills | `.\scripts\backup-global.ps1` |
| Dry-run install global skills | `.\scripts\install-global-skills.ps1 -DryRun` |
| Install global skills | `.\scripts\install-global-skills.ps1` |
| Install project skill (`--copy`) | `.\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MyApp" -Skills "design-taste-frontend"` |
| Verifikasi environment & skills | `.\scripts\verify-install.ps1` |
| Cek daftar global skills | `npx.cmd skills ls -g` |
| Cek daftar project skills | `npx.cmd skills ls` |
| Cek update tanpa install | `npx.cmd skills check` |
| Update global / project skills | `npx.cmd skills update -g` / `npx.cmd skills update -p` |
| Lint `DESIGN.md` | `npx -p @google/design.md designmd lint DESIGN.md` |
| Cek Context Mode | `/ctx-doctor` (di dalam session agent) |
| Preview OpenDesign MCP | `od mcp install <agent> --print` |
