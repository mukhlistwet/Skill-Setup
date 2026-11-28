> **Hotfix v2.1.1:** Perbaikan resolusi path manifest untuk Windows PowerShell; gunakan BAT terbaru di paket ini.

# Migrasi workflow video ke device baru

Paket riset/setup video portabel tersedia di [portable/video-research/README.md](portable/video-research/README.md): dua skill authored, snapshot setting non-secret, target device yang dilaporkan pengguna, blueprint MCP yang tidak aktif, dan helper restore dry-run. Baca paket tersebut jika hendak menyamakan workflow video; jangan menjalankan installer global di bawah hanya untuk paket video. Akun, token, cookie dan state browser tidak disalin.

# Rencana aplikasi Creator Desktop

Paket PRD/desain aplikasi desktop Rust untuk affiliate Shopee, short/general video dan ekspansi 3D tersedia di [docs/creator-desktop-plan/README.md](docs/creator-desktop-plan/README.md). Berisi flow/use case, arsitektur, requirements, schema SQLite, roadmap dan pemeriksa artefak. Ini plan-only, bukan aplikasi yang sudah dibangun atau izin menjalankan generation.

# Engineering Agent Setup

Panduan operasional, manifest, policy, template, dan skrip otomasi untuk menyiapkan lingkungan **AI coding-agent** pada **Windows 11 + PowerShell** secara konsisten saat pindah device atau memulai project baru.

- **Versi:** 2.1 (Manifest + Windows Installer)
- **Verifikasi mapping upstream:** 26 November 2026
- **Target OS:** Windows 11 + PowerShell 5.1 atau PowerShell 7+
- **Coding-agent tercakup:** OpenCode, Claude Code CLI, Codex, Antigravity, Hermes Agent, ZCode
- **Installer:** Vercel Skills CLI (`npx.cmd skills`)

> **Penting — source vs pin:** seluruh `source` pada manifest sudah diisi dengan upstream yang memiliki skill bernama sama. Kolom `ref` sengaja dikosongkan karena full commit SHA/tag belum diverifikasi. Installer akan memakai default branch upstream yang aktif saat instalasi. Ini praktis, tetapi belum reproducible. Untuk setup yang reproducible, isi `ref` dengan tag atau full commit SHA yang sudah diuji.

---

## Mulai Cepat (Windows)

### A. Install global core skills

1. Clone repository:

   ```powershell
   git clone https://github.com/mukhlistwet/Skill-Setup.git
   cd Skill-Setup
   ```

2. Pastikan Node.js, npm, dan Git tersedia:

   ```powershell
   node --version
   npm --version
   git --version
   ```

   Skills CLI membutuhkan Node.js minimal `22.20.0` menurut requirement yang didokumentasikan. Jika menggunakan Context Mode Engine, ikuti requirement Context Mode yang berlaku secara terpisah.

3. Jalankan **`INSTALL-SKILLS.bat`** dari File Explorer atau terminal. Installer akan:
   - Meminta target coding-agent.
   - Secara default memilih 11 core skills saja.
   - Menawarkan `vercel-react-best-practices` sebagai conditional skill.
   - Menjalankan dry-run terlebih dahulu.
   - Meminta konfirmasi sebelum instalasi sebenarnya.
   - Menjalankan verifikasi setelah instalasi.

Pilihan agent di BAT: OpenCode + Codex + Antigravity (default), masing-masing agent secara terpisah, semua 6 agent, atau daftar custom. Pastikan agent yang dipilih memang sudah terpasang dan didukung Skills CLI.

### B. Install design skill untuk satu project

`design-taste-frontend` sengaja tidak dipasang global. Jalankan **`INSTALL-PROJECT-DESIGN-SKILL.bat`**, masukkan full path root project, pilih agent target, cek dry-run, lalu konfirmasi. Skill dipasang dengan `--copy` agar file skill menjadi bagian dari repository project dan dapat ditinjau/di-commit.

### C. Install melalui PowerShell langsung

```powershell
# Preview 11 core skills ke empat agent
.\scripts\install-global-skills.ps1 -Agents opencode,codex,antigravity,hermes-agent -DryRun

# Install setelah preview diperiksa
.\scripts\install-global-skills.ps1 -Agents opencode,codex,antigravity,hermes-agent

# Tambahkan Vercel React Best Practices secara global
.\scripts\install-global-skills.ps1 -Agents opencode,codex,antigravity -IncludeConditionalSkills vercel-react-best-practices -DryRun

# Project-level design skill, copy ke project
.\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MyApp" -Skills design-taste-frontend -Agents opencode,codex -DryRun
```

Jalankan `-DryRun` terlebih dahulu dan periksa source, skill ID, serta agent tujuan sebelum instalasi.

---

## Peta Navigasi Repository

| Folder / File | Kegunaan |
|---|---|
| `INSTALL-SKILLS.bat` | Wizard Windows untuk dry-run dan install global core/conditional skills |
| `INSTALL-PROJECT-DESIGN-SKILL.bat` | Wizard untuk memasang `design-taste-frontend` ke satu project dengan `--copy` |
| `runbooks/01-NEW-DEVICE.md` | Setup device baru dari nol hingga verifikasi |
| `runbooks/02-NEW-PROJECT.md` | Playbook setup project baru berdasarkan tipe |
| `runbooks/03-MAINTENANCE.md` | Backup, update, pemulihan, audit skill, pin source, dan rollback |
| `manifest/skills-manifest.csv` | Single source of truth untuk 11 core + 2 conditional skills |
| `manifest/harnesses.json` | Metadata path dan dukungan plugin per coding-agent |
| `manifest/winget-packages.json` | Paket dasar Windows developer environment |
| `policies/` | Kebijakan engineering, keamanan, quality gates, dan design system |
| `templates/` | Template `DESIGN.md`, `AGENTS.md`, `.env.example`, dan `.gitignore` agent |
| `scripts/` | Skrip PowerShell untuk backup, install global/project, verifikasi, dan rollback |
| `docs/REFERENCE-AGENTS-PATHS.md` | Referensi lokasi folder agent, Context Mode, dan OpenDesign MCP |
| `docs/DECISIONS.md` | Catatan keputusan konsolidasi skill dan pemisahan komponen |
| `docs/SOURCES.md` | Daftar upstream skill, link source, bukti nama skill, dan caveat |

---

## Arsitektur Komponen

Tidak semua ekosistem coding-agent dipasang sebagai Agent Skill. Pisahkan menjadi lima kategori:

| Jenis | Contoh | Fungsi | Cara Pemasangan |
|---|---|---|---|
| **Agent Skill** | `security-review`, `frontend-ui-engineering`, `design-taste-frontend` | Prosedur/instruksi yang dipanggil agent saat relevan | Vercel Skills CLI atau native harness |
| **Plugin / MCP** | Context Mode, OpenDesign MCP | Menambah tools, hooks, atau koneksi workspace | Install per harness yang didukung |
| **CLI Tool** | `@google/design.md` | Validasi dan diff dokumen design system | `npm` / `npx` per project |
| **Design Specification** | `DESIGN.md` | Sumber kebenaran visual dan token satu project | Simpan di root project dan commit ke Git |
| **Catalog / Reference** | `awesome-design-md`, `awesome-design-skills` | Referensi inspirasi desain | Pilih dan adaptasikan; jangan bulk-install |

### Prinsip Scope: Global vs Project-Level

- **Global (user-level):** tersedia lintas project pada satu device/user. Digunakan untuk 11 core engineering skills.
- **Project-level:** hanya tersedia di satu repository dan dipasang dengan `--copy`. Digunakan untuk `design-taste-frontend`, `DESIGN.md`, dan skill spesifik framework/project.
- **Conditional:** `vercel-react-best-practices` dipasang global hanya jika pekerjaan dominan menggunakan React/Next.js; jika tidak, pertimbangkan project-level.

---

## Ringkasan Skill Final (11 Core + 2 Conditional)

### Core Skills (Global)

| No. | Skill | Fokus Utama | Source |
|---:|---|---|---|
| 1 | `frontend-ui-engineering` | Implementasi UI, komponen, state, interaksi, responsive behavior | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/tree/main/skills/frontend-ui-engineering) |
| 2 | `webapp-testing` | Pengujian workflow UI nyata di browser | [anthropics/skills](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) |
| 3 | `systematic-debugging` | Root-cause debugging untuk bug dan regression | [obra/superpowers](https://github.com/obra/superpowers/tree/main/skills/systematic-debugging) |
| 4 | `code-review` | Review diff dan kualitas perubahan kode | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review) |
| 5 | `security-review` | Review auth, authorization, input, secrets, API, trust boundary | [getsentry/skills](https://github.com/getsentry/skills/tree/main/skills/security-review) |
| 6 | `database-designer` | Schema, index, query optimization, data model, migration | [borghei/Claude-Skills](https://github.com/borghei/Claude-Skills/tree/main/engineering/database-designer) |
| 7 | `api-and-interface-design` | Kontrak API/service, request/response, backward compatibility | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/tree/main/skills/api-and-interface-design) |
| 8 | `software-architecture` | System boundary, tradeoff arsitektur, ADR | [sickn33/agentic-awesome-skills](https://github.com/sickn33/agentic-awesome-skills/tree/main/skills/software-architecture) |
| 9 | `ci-cd-pipeline-builder` | Desain build, test, dan deployment pipeline | [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills/tree/main/engineering/skills/ci-cd-pipeline-builder) |
| 10 | `observability-setup` | Logging, metrics, tracing, alerting, SLI/SLO | [patricio0312rev/skills](https://github.com/patricio0312rev/skills) |
| 11 | `performance-engineer` | Profiling, bottleneck analysis, capacity & benchmark | [sickn33/agentic-awesome-skills](https://github.com/sickn33/agentic-awesome-skills/tree/main/skills/performance-engineer) |

### Conditional Skills

| Skill | Scope Rekomendasi | Kapan Digunakan | Source |
|---|---|---|---|
| `design-taste-frontend` | Project-level (`--copy`) | Company website, SaaS marketing site, landing page, product launch, visual redesign eksplisit | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill/tree/main/skills/taste-skill) |
| `vercel-react-best-practices` | Conditional (Global/Project) | Optimasi React/Next.js: rendering, async waterfall, bundle, server/client boundary | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) |

**Catatan penting pada source:** link di atas mengarah ke repository/folder upstream, bukan berarti seluruh source sudah melalui security audit menyeluruh. Beberapa skill punya caveat license, script pendukung, atau penanda risk di upstream. Baca `docs/SOURCES.md` sebelum mengaktifkan skill pada repo/company environment.

---

## Manifest, Version Pinning, dan Reproducibility

`manifest/skills-manifest.csv` adalah sumber kebenaran installer. Kolom:

- `skill`: exact skill ID yang diteruskan ke `skills add --skill`.
- `source`: repository upstream `owner/repo` atau URL repository yang didukung Skills CLI.
- `ref`: tag atau full commit SHA opsional. **Kosong berarti gunakan default branch**.
- `scope`: `global`, `project`, atau `conditional`.
- `agents`: daftar agent IDs dipisahkan titik koma.
- `license`, `prerequisites`, `notes`: metadata dan caveat operasional.

### Kebijakan pinning

- Manifest saat ini mengisi source untuk 13 skill, tetapi `ref` dikosongkan. Jadi instalasi dapat mengambil perubahan upstream terbaru dan hasilnya bisa berubah dari waktu ke waktu.
- Untuk lingkungan produksi/perusahaan atau setup lintas device yang harus identik, audit skill, tentukan tag/full commit SHA, isi `ref`, lalu commit manifest.
- Installer membentuk source spec menjadi `owner/repo@ref` saat `ref` diisi; saat `ref` kosong, installer menggunakan `owner/repo` saja.
- Jangan memasukkan SHA yang belum diverifikasi atau menyalin ref milik skill lain.

---

## Tindakan Wajib Sebelum Pemakaian Pertama

1. Periksa `docs/SOURCES.md` dan source upstream tiap skill.
2. Pastikan target agent sudah terpasang dan benar-benar didukung oleh Skills CLI.
3. Jalankan `INSTALL-SKILLS.bat`, periksa dry-run, dan pilih hanya agent yang digunakan.
4. Setelah instalasi, jalankan `npx.cmd skills ls -g` dan periksa skill dari UI/CLI native masing-masing agent.
5. Untuk penggunaan jangka panjang, pin tag/full commit SHA pada manifest setelah audit.

Skills umumnya berupa instruksi yang dibaca agent; beberapa repository menyertakan script/helper tambahan. Jangan mengasumsikan instalasi skill menjalankan semua script otomatis, tetapi tetap review file pendukung sebelum agent diberi akses untuk menggunakannya.

---

## Batas Git: Apa yang Masuk & Dilarang

| Item | Setup Repository Ini | Project Repository |
|---|---|---|
| `skills-manifest.csv` (source & optional commit SHA) | Ya | Opsional |
| Skrip backup/install/verify/rollback | Ya | Opsional |
| Kebijakan kanonikal (`policies/`) | Ya | Rujuk atau adaptasi di `AGENTS.md` |
| `DESIGN.md` | Template saja (`templates/`) | Ya, spesifik produk |
| Project-specific skills (`--copy`) | Tidak | Ya |
| `skills-lock.json` | Tidak selalu | Ya jika dikelola Skills CLI |
| `.env`, API key, agent auth files, session history | **Dilarang** | **Dilarang** |

---

## Quick Reference Command

| Tujuan | Command |
|---|---|
| Wizard install global | `INSTALL-SKILLS.bat` |
| Wizard install project design skill | `INSTALL-PROJECT-DESIGN-SKILL.bat` |
| Dry-run global core | `powershell -File .\scripts\install-global-skills.ps1 -DryRun` |
| Install global core | `powershell -File .\scripts\install-global-skills.ps1` |
| Install project skill (`--copy`) | `powershell -File .\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MyApp" -Skills design-taste-frontend -DryRun` |
| Verifikasi environment & skills | `powershell -File .\scripts\verify-install.ps1` |
| Cek daftar global skills | `npx.cmd skills ls -g` |
| Cek daftar project skills | `npx.cmd skills ls` |
| Cek update tanpa install | `npx.cmd skills check` |
| Update global / project skills | `npx.cmd skills update -g` / `npx.cmd skills update -p` |
| Lint `DESIGN.md` | `npx -p @google/design.md designmd lint DESIGN.md` |
| Cek Context Mode | `/ctx-doctor` (di dalam session agent) |
| Preview OpenDesign MCP | `od mcp install <agent> --print` |

---

## Memasang Patch Update ke Repository yang Sudah Ada

Jika menerima ZIP patch dari repository ini:

1. Backup/commit perubahan lokal terlebih dahulu.
2. Extract ZIP ke **root** folder `Skill-Setup` dengan mempertahankan struktur folder.
3. Izinkan overwrite pada file yang namanya sama.
4. Jalankan `INSTALL-SKILLS.bat` untuk melihat preview. Jangan langsung memilih install sebelum memeriksa agent dan skill yang akan dipasang.

Patch ZIP hanya berisi file yang berubah/ditambahkan, bukan snapshot penuh repository.
