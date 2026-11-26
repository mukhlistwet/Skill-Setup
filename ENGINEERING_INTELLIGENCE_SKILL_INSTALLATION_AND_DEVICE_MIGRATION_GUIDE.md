# Engineering Intelligence — Skill Inventory, Installation & Device Migration Guide

**Versi panduan:** 1.0  
**Tanggal verifikasi sumber:** 26 November 2026  
**Target OS utama:** Windows 11 + PowerShell  
**Coding-agent:** OpenCode / Oh My OpenCode, Claude Code CLI, Codex, Antigravity, Zcode, Hermes Agent  
**Tujuan:** daftar skill yang ringkas, pemisahan global/project install, panduan pemakaian, dan prosedur pindah device tanpa konfigurasi manual berulang.

---

# 1. Pahami dulu jenis komponennya

Enam repository kandidat yang Anda berikan tidak semuanya Agent Skill. Pisahkan menjadi lima kategori:

| Jenis | Contoh | Fungsi | Cara pemasangan |
|---|---|---|---|
| Agent Skill | `security-review`, `frontend-ui-engineering`, `design-taste-frontend` | Prosedur/instruksi yang dipanggil agent saat relevan | Skills CLI atau native harness |
| Plugin / MCP | Context Mode, OpenDesign MCP | Menambah tools, hooks, atau koneksi agent | Install per harness |
| CLI Tool | `@google/design.md` | Validasi/export design-system document | npm/npx, biasanya per project |
| Design Specification | `DESIGN.md` | Sumber kebenaran desain satu project | Simpan di root project dan commit ke Git |
| Catalog / Reference | awesome-design-md, awesome-design-skills | Referensi/inspirasi design | Pilih satu referensi; jangan bulk-install |

**Jangan install keenam repository sebagai enam Agent Skills.** Fungsinya berbeda.

## 1.1 Global vs project-level

**Global/user-level** berarti tersedia di semua project pada satu device dan user yang sama. Cocok untuk prosedur engineering umum seperti debugging, review, security, database, API, architecture, CI/CD, observability, dan performance.

**Project-level** berarti tersedia hanya untuk repository tertentu. Cocok untuk design style, workflow khusus project, framework-specific skill, atau instruksi yang akan ikut dibagikan melalui Git.

| Kebutuhan | Pilih |
|---|---|
| Dipakai berulang di banyak repository | Global |
| Khusus satu project | Project-level |
| Design system/brand satu produk | `DESIGN.md` di project |
| Plugin/MCP coding-agent | Install satu kali per harness di device |
| Referensi desain dari katalog | Pilih satu dan simpan hasil adaptasinya di project |

**Rekomendasi:** 11 core engineering skills dipasang global. `design-taste-frontend` dipasang per-project bila memang membuat website/landing page. `vercel-react-best-practices` global hanya jika Anda sering mengerjakan React/Next.js; selain itu project-level. `DESIGN.md` selalu project-level.

---

# 2. Daftar skill final yang direkomendasikan

Gunakan **11 core skills + 2 conditional skills**. Jangan kembali memasang 22 skill lama sekaligus.

## 2.1 Core skills — 11

| No. | Skill | Tanggung jawab | Kapan digunakan | Scope |
|---:|---|---|---|---|
| 1 | `frontend-ui-engineering` | Implementasi frontend, komponen, state, interaksi, responsive behavior | Membuat/refactor UI dan frontend workflow | Global |
| 2 | `webapp-testing` | Browser-based testing | Menguji workflow UI nyata di browser | Global |
| 3 | `systematic-debugging` | Root-cause debugging | Bug/regression yang penyebabnya belum jelas | Global |
| 4 | `code-review` | Review diff dan perubahan kode | Review perubahan yang bermakna | Global |
| 5 | `security-review` | Security dan trust-boundary review | Auth, authorization, input, secrets, API, integrasi eksternal | Global |
| 6 | `database-designer` | Database design dan migration analysis | Schema, index, query, data model, migration | Global |
| 7 | `api-and-interface-design` | API/service contract | Endpoint, request/response, compatibility | Global |
| 8 | `software-architecture` | Architecture dan tradeoff | System boundary, material design decisions, ADR | Global |
| 9 | `ci-cd-pipeline-builder` | CI/CD pipeline | Build/test/deployment pipeline design | Global |
| 10 | `observability-setup` | Logging, metrics, tracing, alerting | Instrumentation, SLI/SLO, monitoring | Global |
| 11 | `performance-engineer` | Profiling dan capacity | Bottleneck, resource use, performance benchmark | Global |

**Penting tentang source:** nama dan tanggung jawab 11 skill ini berasal dari inventory yang sudah diaudit sebelumnya. Laporan inventory yang ada di percakapan tidak menyertakan URL upstream/owner/repository secara lengkap untuk semua skill. Jangan menebak repository hanya dari nama. Pulihkan source URL dan commit dari install metadata, `skills-lock.json`, backup, atau registry lama sebelum clean reinstall. Jika tidak ditemukan, cari dengan `npx skills find`, lalu bandingkan konten dan restriction sebelum memilih.

## 2.2 Conditional skills — 2

| Skill | Source | Kapan diaktifkan | Scope |
|---|---|---|---|
| `design-taste-frontend` | `Leonxlnx/taste-skill` | Company website, SaaS marketing site, landing page, product launch, explicit visual redesign | Project-level untuk website yang relevan |
| `vercel-react-best-practices` | Source perlu dipulihkan dari metadata/audit lama atau dicari dan diverifikasi | Hanya untuk React/Next.js performance, rendering, async waterfall, bundle, server/client concerns | Global jika sering React/Next; selain itu project-level |

`design-taste-frontend` bukan default untuk backend-only, API/database, admin dashboard/data-heavy UI, HRIS/POS, atau project yang sudah memiliki visual system kuat kecuali memang diminta.

## 2.3 Skill lama yang tidak dipasang terpisah

| Skill lama | Keputusan | Kemampuan tetap berada di |
|---|---|---|
| `frontend-design` | Tidak dipasang terpisah secara global | `DESIGN.md` project + Taste untuk website tertentu |
| `web-design-guidelines` | Tidak dipasang terpisah | Central accessibility/UX quality policy |
| `vercel-composition-patterns` | Tidak dipasang terpisah | `frontend-ui-engineering` |
| `tailwind-design-system` | Tidak dipasang terpisah | `DESIGN.md` + konvensi Tailwind project |
| `shadcn` | Tidak dipasang default | Gunakan shadcn CLI/docs saat project memang memakainya |
| `extract-design-system` | Tidak dipasang default | Hanya untuk task reverse-engineering eksplisit |
| `impeccable` | Tidak dipasang default | `frontend-ui-engineering` + design review |
| `token-optimization` | Tidak dipasang sebagai skill | Context Management policy + Context Mode |
| `implement-spec` | Tidak dipasang sebagai skill | Workflow policy |
| `test-strategy` | Tidak dipasang sebagai skill | Quality Gates |

Tujuannya bukan membuang praktik baik, melainkan menghindari instruksi yang sama/bertentangan dari beberapa skill.

---

# 3. Enam repository kandidat

## 3.1 Context Mode — plugin/tool, bukan skill biasa

Repository yang Anda berikan: https://github.com/mukhlistwet/context-mode  
Upstream: https://github.com/mksglu/context-mode  
Official install guide: https://contextmode.ai/docs/engine/install

Repository user-linked adalah fork dari upstream. Dokumentasi install Context Mode Engine yang diperiksa saat ini menggunakan `mksglu/context-mode` pada perintah plugin. Untuk instalasi baru, gunakan upstream kecuali Anda sudah membandingkan fork dan memiliki alasan khusus untuk memakai fork.

**Scope:** install satu kali per coding-agent harness yang didukung dan benar-benar Anda gunakan, bukan per project. Data/tool state disimpan lokal; scope/index dapat terkait project.

**Prasyarat yang didokumentasikan:** Node.js 24.15.0+, dan Git for Windows di Windows karena shell tools menggunakan Git Bash. Restart agent setelah install dan jalankan `/ctx-doctor` pada agent yang mendukungnya.

### Claude Code

```powershell
claude plugin marketplace add mksglu/context-mode
claude plugin install context-mode@context-mode
```

Restart Claude Code, lalu di session:

```text
/ctx-doctor
```

### Codex

```powershell
codex plugin marketplace add mksglu/context-mode
codex plugin add context-mode@context-mode
npm install -g context-mode
context-mode setup --agents codex
```

Restart Codex, lalu `/ctx-doctor`.

### OpenCode

```powershell
opencode plugin add context-mode
```

Restart OpenCode, lalu `/ctx-doctor`.

### ZCode

```powershell
zcode plugins marketplace add mksglu/context-mode
zcode plugins install context-mode@context-mode
```

Verifikasi:

```powershell
zcode plugins list
```

### Oh My OpenCode (OMP)

```powershell
omp plugin install context-mode
omp plugin list
```

### Antigravity dan Hermes Agent

Install guide resmi yang diperiksa tidak memberikan langkah native yang dapat diverifikasi untuk Antigravity/Hermes. Jangan menyalin command OpenCode/Codex ke dua agent tersebut. Tunggu dukungan native atau gunakan integrasi lain yang benar-benar didokumentasikan.

**Safety:** Context Mode bukan pengganti OS sandbox/permission model. Periksa hooks/MCP scope sebelum mengaktifkan. Jangan menjalankan purge saat setup dan jangan memasukkan secrets ke index/context.

## 3.2 Taste Skill — specialist frontend visual

Repository: https://github.com/Leonxlnx/taste-skill  
Nama skill: `design-taste-frontend`

Khusus untuk company website, marketing website, landing page, SaaS marketing, product launch, dan explicit visual redesign. README menyebut Node.js 22+ serta Chrome/Edge/Chromium; ffmpeg opsional untuk fungsi tertentu.

### Global install

Gunakan hanya bila skill ini memang dipakai lintas project:

```powershell
npx.cmd skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend --global --agent opencode --agent claude-code --agent codex --agent antigravity --agent hermes-agent --agent zcode --yes
```

Hapus `--agent` untuk agent yang tidak digunakan.

### Project install (lebih direkomendasikan)

```powershell
Set-Location "D:\Projects\MarketingWebsite"
npx.cmd skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend --agent opencode --agent claude-code --agent codex --agent antigravity --agent hermes-agent --agent zcode --copy --yes
```

Tanpa `--global`, Skills CLI memasang ke project saat ini. `--copy` membuat files berada di project sehingga tidak bergantung pada symlink/cache device lama.

Contoh cara meminta agent:

```text
Gunakan design-taste-frontend untuk membuat landing page produk ini.
Baca DESIGN.md project terlebih dahulu.
Pertahankan brand token dan jangan ubah API/business logic.
Selesaikan responsive layout dan jalankan browser consistency check.
```

## 3.3 OpenDesign — design workspace + MCP

Repository: https://github.com/nexu-io/open-design

OpenDesign adalah aplikasi/workspace design dengan MCP integration, bukan satu Agent Skill. Berguna untuk design system workspace, visual prototype, live design handoff, dan berbagi design files dengan coding agent.

Sebelum mengubah konfigurasi agent, preview:

```powershell
od mcp install codex --print
od mcp install claude --print
od mcp install opencode --print
od mcp install antigravity --print
od mcp install hermes --print
```

Setelah review preview, pasang hanya pada agent yang dipakai:

```powershell
od mcp install codex
od mcp install opencode
```

Verifikasi:

```powershell
od project list --json
od plugin list --json
od skills list --json
```

Daftar kompatibilitas README mencantumkan Claude Code, Codex, OpenCode, Antigravity, dan Hermes. ZCode tidak tercantum. OpenDesign opsional; tidak wajib untuk menggunakan `DESIGN.md`.

## 3.4 Google `design.md` — format + CLI validator

Repository: https://github.com/google-labs-code/design.md

Ini format specification/CLI untuk design-system document, bukan skill. Simpan `DESIGN.md` di root setiap project frontend; jangan pasang global.

Install sebagai dev dependency:

```powershell
npm install -D "@google/design.md"
```

Atau one-off:

```powershell
npx -p @google/design.md designmd lint DESIGN.md
```

Perintah penting:

```powershell
npx -p @google/design.md designmd lint DESIGN.md
npx -p @google/design.md designmd diff DESIGN.md DESIGN-v2.md
```

**Catatan:** format saat ini masih `alpha`. Pin versi, commit `package-lock.json`, dan jangan membuat seluruh workflow bergantung pada field schema yang belum stabil.

## 3.5 Awesome DESIGN.md — katalog referensi

Repository: https://github.com/VoltAgent/awesome-design-md

Ini katalog DESIGN.md dari brand/site yang terlihat secara publik. Tidak perlu install sebagai skill. Cara pakai: pilih satu referensi, periksa token, license, aset, dan adaptasikan ke project `DESIGN.md`. Jangan menyalin semua brand styles ke product Anda.

## 3.6 Awesome Design Skills — katalog 67 skill

Repository: https://github.com/mukhlistwet/awesome-design-skills

Ini katalog 67 folder design dengan `SKILL.md` dan `DESIGN.md`, bukan satu skill universal. Jangan install semua 67. Pilih maksimal satu design pack yang punya kebutuhan spesifik, periksa source/license/script/overlap, dan instal project-level bila memang dibutuhkan.

---

# 4. Lokasi global dan project per coding-agent

`~` berarti home folder Windows, biasanya `C:\Users\<NamaUser>`.

| Agent | Skills CLI agent ID | Global / user-level | Project-level |
|---|---|---|---|
| OpenCode | `opencode` | `~/.config/opencode/skills/` | `.agents/skills/` melalui Skills CLI; native OpenCode juga membaca `.opencode/skills/` |
| Claude Code | `claude-code` | `~/.claude/skills/` | `.claude/skills/` |
| Codex | `codex` | `~/.agents/skills/` | `.agents/skills/` |
| Antigravity | `antigravity` | `~/.gemini/config/skills/` | `.agents/skills/` |
| Hermes Agent | `hermes-agent` | `~/.hermes/skills/` | `.hermes/skills/` atau `.agents/skills/` |
| ZCode | `zcode` | `~/.zcode/skills/` | `.zcode/skills/` |

Oh My OpenCode menggunakan ekosistem OpenCode untuk skill discovery; jangan pasang salinan kedua dengan ID yang sama.

Catatan khusus:
- OpenCode juga membaca compatibility directories `.claude/skills` dan `.agents/skills`; hindari duplicate IDs.
- Claude Code personal skills tersedia lintas project pada device; project skills ikut repository.
- Codex membaca user/project/admin/system skill scopes.
- Antigravity memakai `.agents/skills` untuk workspace/project dan `~/.gemini/config/skills` untuk global.
- Hermes Agent mendukung project-local skills, tetapi meminta `hermes skills trust` sebelum memuat skills dari repo.
- ZCode memiliki direktori user/project sendiri.

---

# 5. Vercel Skills CLI — install global atau project

CLI: https://github.com/vercel-labs/skills  
Dokumentasi command: https://github.com/vercel-labs/skills/blob/main/docs/commands.md

Node.js 22.20+ diperlukan oleh Skills CLI. Tidak perlu install CLI global; gunakan `npx`.

Pada Windows PowerShell, gunakan `npx.cmd` bila `npx.ps1` terkena Execution Policy.

## 5.1 Prasyarat

```powershell
node --version
npm --version
git --version
npx.cmd skills --help
```

Skills CLI menerima source GitHub shorthand, URL, local path, tag, atau full commit. Untuk install reproducible, gunakan tag/commit pin yang tercatat di manifest.

## 5.2 Cari skill dan periksa repository

```powershell
npx.cmd skills find database-designer
npx.cmd skills add OWNER/REPO --list
```

Sebelum install, baca `SKILL.md` dan periksa description, trigger, restrictions, scripts, hooks, dependencies, network access, license, source commit.

## 5.3 Install global ke beberapa agent

Template:

```powershell
npx.cmd skills add OWNER/REPO@TAG-ATAU-COMMIT `
  --skill NAMA-SKILL `
  --global `
  --agent opencode `
  --agent claude-code `
  --agent codex `
  --agent antigravity `
  --agent hermes-agent `
  --agent zcode `
  --yes
```

Ganti source, skill name, dan commit. Hapus agent yang tidak dipakai di device Anda. `--global` membuat skill tersedia di banyak project untuk user pada device itu.

## 5.4 Install project-level

Masuk ke root project dahulu:

```powershell
Set-Location "D:\Projects\FamilyMOO"
```

Lalu install tanpa `--global`:

```powershell
npx.cmd skills add OWNER/REPO@TAG-ATAU-COMMIT `
  --skill NAMA-SKILL `
  --agent opencode `
  --agent claude-code `
  --agent codex `
  --agent antigravity `
  --agent hermes-agent `
  --agent zcode `
  --copy `
  --yes
```

`--copy` direkomendasikan untuk project yang akan masuk Git. Skill files menjadi bagian dari project dan tidak bergantung pada symlink ke path cache device lama.

## 5.5 Source manifest untuk 11 core skills

Buat `skills-manifest.csv` dalam private setup repository:

```csv
skill,source,ref,scope,agents
frontend-ui-engineering,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
webapp-testing,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
systematic-debugging,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
code-review,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
security-review,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
database-designer,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
api-and-interface-design,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
software-architecture,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
ci-cd-pipeline-builder,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
observability-setup,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
performance-engineer,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,global,opencode;claude-code;codex;antigravity;hermes-agent;zcode
design-taste-frontend,https://github.com/Leonxlnx/taste-skill,<PINNED_COMMIT>,project,opencode;claude-code;codex;antigravity;hermes-agent;zcode
vercel-react-best-practices,<VERIFIED_OWNER/REPO>,<TAG_OR_COMMIT>,conditional,opencode;claude-code;codex;antigravity;hermes-agent;zcode
```

Lengkapi source dan commit sebelum clean reinstall. Placeholder tidak boleh tertinggal pada manifest final. Jika source tidak dapat dibuktikan, jangan hapus satu-satunya copy lama sampai source/backup aman.

## 5.6 Verifikasi, update, dan remove

Lihat global skills:

```powershell
npx.cmd skills ls -g
```

Lihat project skills dari root project:

```powershell
npx.cmd skills ls
```

Filter agent:

```powershell
npx.cmd skills ls -g -a codex
npx.cmd skills ls -g -a opencode
```

Check update tanpa install:

```powershell
npx.cmd skills check
```

Update global dan project secara terpisah:

```powershell
npx.cmd skills update -g
npx.cmd skills update -p
```

Remove skill tertentu:

```powershell
npx.cmd skills remove NAMA-SKILL --global
```

Dari root project, remove project skill:

```powershell
npx.cmd skills remove NAMA-SKILL
```

Jangan menjalankan bulk remove sebelum backup dan memahami lockfile. Skill manual/untracked dapat tidak ikut terhapus oleh bulk remove.

---

# 6. DESIGN.md per project

`DESIGN.md` bukan global skill. Buat satu per project frontend di root repository.

Contoh struktur yang dapat dikembangkan:

```markdown
---
version: alpha
name: Product Name Design System
---

# Overview
Purpose, users, product context and visual direction.

# Brand
Approved logo, assets, fonts and brand constraints.

# Colors
Semantic colors: primary, secondary, surface, text, border, success, warning, danger.

# Typography
Font families, sizes, line heights and hierarchy.

# Spacing and Layout
Spacing scale, grid, container widths and breakpoints.

# Components
Buttons, inputs, cards, tables, navigation, dialog and states.

# Accessibility
Semantic HTML, keyboard, focus, contrast, forms and reduced motion.

# Responsive Behavior
Mobile, tablet and desktop rules.

# Do Not
Patterns or visual changes that must not be introduced.
```

Install validator sebagai dev dependency:

```powershell
npm install -D "@google/design.md"
```

Atau one-off lint di Windows:

```powershell
npx -p @google/design.md designmd lint DESIGN.md
```

Diff dua versi:

```powershell
npx -p @google/design.md designmd diff DESIGN.md DESIGN-v2.md
```

Spesifikasi `DESIGN.md` saat ini alpha. Pin dependency, commit lockfile, dan review schema updates sebelum upgrade.

## Cara mengambil referensi dari katalog

1. `awesome-design-md`: pilih satu `DESIGN.md` yang relevan.
2. `awesome-design-skills`: pilih satu kandidat jika memang butuh prosedur design yang tidak disediakan skill aktif.
3. Periksa license, source, tokens, scripts, dan instruction conflicts.
4. Adaptasikan ke brand/product, jangan copy seluruh identitas brand lain.
5. Simpan hasil akhirnya sebagai `DESIGN.md` project.

Jangan install semua 67 design skills. Jangan load lebih dari satu design direction yang saling bertentangan.

---

# 7. OpenDesign opsional

OpenDesign MCP menambah koneksi ke design workspace; tidak wajib untuk setiap coding agent/project.

Preview konfigurasi:

```powershell
od mcp install codex --print
od mcp install claude --print
od mcp install opencode --print
od mcp install antigravity --print
od mcp install hermes --print
```

Review file/setting yang akan ditambahkan. Jika tepat, install ke harness yang dipakai:

```powershell
od mcp install codex
od mcp install opencode
```

Verifikasi:

```powershell
od project list --json
od plugin list --json
od skills list --json
```

OpenDesign README mencantumkan Claude, Codex, OpenCode, Antigravity, dan Hermes sebagai target MCP. ZCode tidak tercantum pada daftar yang diperiksa.

---

# 8. Perbedaan lokasi global/project

Tabel ringkas default path:

| Agent | Global | Project |
|---|---|---|
| OpenCode | `~/.config/opencode/skills/` | `.agents/skills/` via Skills CLI; native `.opencode/skills/` juga didukung |
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| Codex | `~/.agents/skills/` | `.agents/skills/` |
| Antigravity | `~/.gemini/config/skills/` | `.agents/skills/` |
| Hermes | `~/.hermes/skills/` | `.hermes/skills/` atau `.agents/skills/` |
| ZCode | `~/.zcode/skills/` | `.zcode/skills/` |

Hermes: project skills perlu trusted repo. Jalankan dari root project:

```powershell
hermes skills trust
```

Cabut trust:

```powershell
hermes skills untrust
```

Hermes juga mendukung external skill directories melalui `skills.external_dirs` di `~/.hermes/config.yaml`, tetapi external directories bukan read-only boundary bila proses Hermes memiliki hak tulis. Jangan mengarahkan Hermes ke shared directory yang tidak ingin diubahnya.

---

# 9. Setup global plugin Context Mode per harness

Context Mode bukan skill global file. Install plugin dengan perintah native per harness yang didukung.

| Agent | Install | Check |
|---|---|---|
| Claude Code | `claude plugin marketplace add mksglu/context-mode` lalu `claude plugin install context-mode@context-mode` | `/ctx-doctor` |
| Codex | `codex plugin marketplace add mksglu/context-mode`; `codex plugin add context-mode@context-mode`; `npm install -g context-mode`; `context-mode setup --agents codex` | `/ctx-doctor` |
| OpenCode | `opencode plugin add context-mode` | `/ctx-doctor` |
| OMP | `omp plugin install context-mode` | `omp plugin list` |
| ZCode | `zcode plugins marketplace add mksglu/context-mode`; `zcode plugins install context-mode@context-mode` | `zcode plugins list` |

Dokumentasi terbaru yang diperiksa tidak memberikan install flow yang terverifikasi untuk Antigravity/Hermes. Jangan menyalin perintah dari agent lain.

Untuk Windows, Context Mode memerlukan Node 24.15+ dan Git for Windows. Jalankan `node --version` dan `git --version` lebih dahulu.

---

# 10. Pindah device — prosedur yang paling gampang

Tujuan portability adalah membawa manifest dan script, bukan menyalin seluruh folder runtime/credential dari device lama.

## 10.1 Buat satu private setup repository

Buat repository private misalnya `engineering-agent-setup` dengan isi:

```text
engineering-agent-setup/
├── README.md
├── manifest/
│   ├── skills-manifest.csv
│   ├── harnesses.json
│   └── versions.json
├── policies/
│   ├── MASTER_ENGINEERING_POLICY.md
│   ├── SECURITY_AND_PERMISSION_POLICY.md
│   ├── QUALITY_GATES.md
│   └── DESIGN_SYSTEM_POLICY.md
├── design/
│   └── DESIGN.md.template
├── scripts/
│   ├── backup-global.ps1
│   ├── install-global-skills.ps1
│   ├── install-project-skills.ps1
│   ├── verify-install.ps1
│   └── rollback.ps1
└── docs/
    ├── INSTALL.md
    └── DEVICE-MIGRATION.md
```

Simpan di GitHub private atau Git server pribadi. Jangan commit API key, `.env`, credentials, auth file, session history, atau full global config mentah.

## 10.2 Apa yang harus disimpan dalam manifest?

Setiap skill entry wajib mencatat:
- exact skill name;
- source repository URL;
- tag/full commit SHA;
- license/provenance;
- target agent IDs;
- global atau project scope;
- Node/browser/CLI prerequisites;
- restriction version/hash.

Contoh:

```csv
skill,source,ref,scope,agents
design-taste-frontend,https://github.com/Leonxlnx/taste-skill,<PINNED_COMMIT>,project,opencode;claude-code;codex
security-review,<VERIFIED_SOURCE>,<PINNED_COMMIT>,global,opencode;claude-code;codex
```

Jangan biarkan placeholder tertinggal pada manifest final.

## 10.3 Setup pada device baru

### Langkah 1 — Install prerequisites

Install Node.js 24.15+, Git for Windows, dan coding-agent yang memang akan dipakai. Install Chrome/Edge/Chromium jika menggunakan Taste Skill.

Verifikasi:

```powershell
node --version
npm --version
git --version
npx.cmd skills --help
```

### Langkah 2 — Clone setup repository

```powershell
Set-Location $HOME
git clone https://github.com/<USERNAME>/engineering-agent-setup.git
Set-Location "$HOME\engineering-agent-setup"
```

Ganti `<USERNAME>` dengan akun GitHub Anda.

### Langkah 3 — Login ke agent

Login menggunakan mekanisme resmi tiap aplikasi. Jangan copy credential/token dari device lama.

### Langkah 4 — Install global skills

Setelah Anda memiliki script yang membaca manifest:

```powershell
.\scripts\install-global-skills.ps1
```

Script harus idempotent, menampilkan dry-run/preview, hanya menginstall source yang terdaftar, dan melaporkan error. Jangan menghapus skill lain di luar manifest.

### Langkah 5 — Install plugin global

Jalankan Context Mode per harness sesuai tabel Section 9 dan verifikasi dengan doctor/list.

### Langkah 6 — Clone project

```powershell
git clone <PROJECT_REPOSITORY>
Set-Location <PROJECT_FOLDER>
```

Project yang benar seharusnya sudah membawa `DESIGN.md`, project-specific skills, policy references, dan lockfile bila dipakai.

### Langkah 7 — Trust Hermes (bila dipakai)

```powershell
hermes skills trust
```

### Langkah 8 — Verify

```powershell
npx.cmd skills ls -g
npx.cmd skills check
```

Buka setiap agent dan periksa native skill list, bukan hanya keberadaan folder.

## 10.4 Apa yang masuk Git dan apa yang tidak?

| Item | Setup repository | Project repository |
|---|---|---|
| Skill manifest/source commit | Ya | Opsional |
| Install/update scripts | Ya | Opsional |
| Canonical policies | Ya | Bisa dirujuk/di-copy sesuai workflow |
| `DESIGN.md` | Template saja | Ya, project-specific |
| Project-specific skill | Tidak | Ya |
| `skills-lock.json` | Tidak selalu | Ya jika dikelola Skills CLI |
| `.env` / API key | Jangan | Jangan |
| Agent auth files | Jangan | Jangan |
| Session history | Jangan | Jangan |
| Full global config | Jangan copy mentah | Jangan |

---

# 11. Backup dan clean uninstall lama

Sebelum reset skill lama:
1. Jalankan `npx.cmd skills ls -g`.
2. Dari setiap project, jalankan `npx.cmd skills ls`.
3. Simpan `skills-lock.json`, source URL/commit, dan custom skill folders.
4. Backup manual skills yang tidak tercatat dalam lockfile.
5. Catat global/project configuration dan hash bila perlu.
6. Jangan hapus built-in skills bawaan aplikasi.
7. Jangan menghapus MCP/plugin yang tidak terkait skill.

Contoh backup global skill folders pada Windows:

```powershell
$Backup = Join-Path $HOME ("AI-Skill-Backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Force -Path $Backup | Out-Null

$Paths = @(
  "$HOME\.agents\skills",
  "$HOME\.claude\skills",
  "$HOME\.config\opencode\skills",
  "$HOME\.gemini\config\skills",
  "$HOME\.hermes\skills",
  "$HOME\.zcode\skills"
)

foreach ($Path in $Paths) {
  if (Test-Path $Path) {
    $Name = ($Path -replace '[\\/:~.]', '_')
    Copy-Item $Path (Join-Path $Backup $Name) -Recurse -Force
  }
}

Write-Host "Backup saved to: $Backup"
```

Verifikasi backup sebelum menghapus apa pun. Hindari bulk remove tanpa memahami lock scope. Folder manual/untracked bisa tidak termasuk dalam bulk removal.

---

# 12. Checklist harian dan maintenance

## Global per device
- [ ] Node.js 24.15+
- [ ] Git for Windows
- [ ] Skills CLI melalui `npx`
- [ ] 11 core skills terpasang dari source/commit terverifikasi
- [ ] Context Mode terpasang hanya pada harness yang didukung/dipakai
- [ ] Semua harness yang digunakan sudah login
- [ ] Global skill list diverifikasi

## Per project
- [ ] `DESIGN.md` tersedia untuk project frontend yang perlu design system
- [ ] Stack/framework conventions sesuai repository
- [ ] Project-specific skills hanya bila memang dibutuhkan
- [ ] `skills-lock.json` disimpan bila menggunakan Skills CLI
- [ ] Tidak ada duplicate skill IDs
- [ ] Tidak ada competing design systems
- [ ] Tidak ada secrets di Git
- [ ] Hermes project skills sudah trusted bila memakai Hermes

## Sebelum menambah skill baru
- [ ] Pastikan capability belum dicakup skill aktif.
- [ ] Baca `SKILL.md` dan supporting files.
- [ ] Periksa scripts/hooks/network/MCP permissions.
- [ ] Periksa license dan source provenance.
- [ ] Cek overlap dengan skill aktif.
- [ ] Pilih global atau project scope.
- [ ] Pin tag/commit dan catat di manifest.
- [ ] Jalankan routing/restriction test.

---

# 13. Quick reference command

| Tujuan | Command |
|---|---|
| Bantuan | `npx.cmd skills --help` |
| Cari skill | `npx.cmd skills find <keyword>` |
| List skill dari repo | `npx.cmd skills add OWNER/REPO --list` |
| Install global | `npx.cmd skills add OWNER/REPO --skill NAME --global --agent codex` |
| Install project | `npx.cmd skills add OWNER/REPO --skill NAME --agent codex --copy` |
| Lihat global | `npx.cmd skills ls -g` |
| Lihat project | `npx.cmd skills ls` |
| Cek update | `npx.cmd skills check` |
| Update global | `npx.cmd skills update -g` |
| Update project | `npx.cmd skills update -p` |
| Remove global | `npx.cmd skills remove NAME --global` |
| Remove project | `npx.cmd skills remove NAME` |
| DESIGN.md lint (PowerShell) | `npx -p @google/design.md designmd lint DESIGN.md` |
| Context Mode check | `/ctx-doctor` pada agent yang mendukung |
| OpenDesign MCP preview | `od mcp install <agent> --print` |

---

# 14. Sumber resmi

Sumber diperiksa pada 26 November 2026. Periksa kembali versi saat melakukan instalasi karena CLI/plugin dapat berubah.

## Skills CLI dan lokasi per agent
- https://github.com/vercel-labs/skills
- https://github.com/vercel-labs/skills/blob/main/docs/commands.md
- https://github.com/vercel-labs/skills/blob/main/docs/agents.md

## Native skill documentation
- OpenCode: https://opencode.ai/docs/skills/
- Claude Code: https://code.claude.com/docs/en/skills
- Codex: https://developers.openai.com/codex/skills
- Antigravity: https://antigravity.google/docs/commands/learn
- Hermes: https://hermes-agent.nousresearch.com/docs/user-guide/features/skills

## Candidate repositories
- Context Mode fork: https://github.com/mukhlistwet/context-mode
- Context Mode upstream: https://github.com/mksglu/context-mode
- Context Mode install guide: https://contextmode.ai/docs/engine/install
- Taste Skill: https://github.com/Leonxlnx/taste-skill
- OpenDesign: https://github.com/nexu-io/open-design
- Google DESIGN.md: https://github.com/google-labs-code/design.md
- Awesome DESIGN.md: https://github.com/VoltAgent/awesome-design-md
- Awesome Design Skills: https://github.com/mukhlistwet/awesome-design-skills

## Caveats
- Google `DESIGN.md` format is currently alpha.
- User-linked Context Mode repository is a fork; official install commands currently use `mksglu/context-mode`.
- Exact source URL/commit for 11 audited core skills is not present in the inventory summary. Recover from metadata/backup/lockfile; do not invent.
- Skills CLI can create agent-specific folders, but native discovery/invocation must still be verified in each installed harness.
- Global means user-level on one device, not automatic cloud sync. Use a private setup repository and bootstrap scripts for device portability.
'''
