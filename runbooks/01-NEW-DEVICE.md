# Runbook 01 — Setup Device Baru (Windows 11)

Panduan langkah demi langkah untuk memigrasikan lingkungan engineering dan coding-agent ke PC/laptop baru tanpa menyalin folder runtime, cache, atau file kredensial dari device lama.

---

## Langkah 1 — Siapkan Fondasi Dev Environment Windows

1. **Install paket dasar menggunakan `winget`** (atau install manual bila ingin versi spesifik):

```powershell
winget import -i .\manifest\winget-packages.json --accept-package-agreements --accept-source-agreements
```

2. **Pastikan versi prasyarat terpenuhi:**
   - **Node.js `24.15.0+`** (syarat Context Mode Engine; Vercel Skills CLI membutuhkan minimal `22.20+`). Jika memakai `fnm`, install dan aktifkan versi 24.15+.
   - **Git for Windows** (dibutuhkan oleh shell tools Context Mode di Windows melalui Git Bash).
   - **Chrome / Edge / Chromium** (dibutuhkan jika menggunakan `design-taste-frontend` / browser testing).

Verifikasi di PowerShell baru:

```powershell
node --version
npm --version
git --version
npx.cmd skills --help
```

> Catatan PowerShell: selalu gunakan `npx.cmd` jika `npx.ps1` terblokir Execution Policy Windows.

3. **Konfigurasi Git & SSH key baru** (jangan salin private key sembarangan jika bisa membuat key baru per device):

```powershell
git config --global user.name "<NAMA_ANDA>"
git config --global user.email "<EMAIL_ANDA>"
ssh-keygen -t ed25519 -C "<EMAIL_ANDA>"
```

4. **Atur storage Docker Desktop sejak awal (opsional, sangat disarankan jika memakai Docker):**
   - Buat folder di drive data internal (misalnya `D:\DockerData`).
   - Buka **Docker Desktop → Settings → Resources → Disk image location**, arahkan ke `D:\DockerData`, lalu **Apply & restart**.
   - Langkah ini mencegah `docker_data.vhdx` membengkak hingga ratusan GB di `C:\Users\<User>\AppData\Local`.

---

## Langkah 2 — Clone Setup Repository

```powershell
Set-Location $HOME
git clone https://github.com/<USERNAME>/engineering-agent-setup.git
Set-Location "$HOME\engineering-agent-setup"
```

Pastikan `manifest\skills-manifest.csv` sudah tidak memiliki placeholder `<VERIFIED_OWNER/REPO>` atau `<TAG_OR_COMMIT>`.

---

## Langkah 3 — Install & Login Coding-Agent Harnesses

Install hanya coding-agent yang memang akan digunakan di device ini (misalnya OpenCode / OMP, Claude Code CLI, Codex, Antigravity, Hermes Agent, ZCode).

- Login menggunakan mekanisme autentikasi resmi masing-masing aplikasi.
- **Jangan** menyalin token, auth file, atau full global config mentah dari device lama.

---

## Langkah 4 — Install 11 Global Core Skills

Lakukan preview terlebih dahulu dengan `-DryRun`:

```powershell
.\scripts\install-global-skills.ps1 -DryRun
```

Jika hanya memakai beberapa agent tertentu, batasi target dengan parameter `-Agents`:

```powershell
.\scripts\install-global-skills.ps1 -Agents opencode,claude-code,codex,antigravity -DryRun
```

Setelah preview sesuai, jalankan instalasi sebenarnya:

```powershell
.\scripts\install-global-skills.ps1 -Agents opencode,claude-code,codex,antigravity
```

> Jika mayoritas pekerjaan Anda menggunakan React/Next.js dan ingin memasang `vercel-react-best-practices` secara global, tambahkan flag `-IncludeConditionalSkills "vercel-react-best-practices"`.

---

## Langkah 5 — Install Global Plugin Context Mode (Per Harness)

Context Mode adalah plugin/engine, bukan Agent Skill biasa. Pasang satu kali hanya pada harness yang didukung dan benar-benar dipakai.

Gunakan upstream resmi `mksglu/context-mode` (kecuali Anda sengaja memakai fork terverifikasi). Lihat tabel perintah lengkap per harness di `docs/REFERENCE-AGENTS-PATHS.md`.

Ringkasan cepat:
- **Claude Code:** `claude plugin marketplace add mksglu/context-mode` → `claude plugin install context-mode@context-mode` → restart → `/ctx-doctor`
- **Codex:** `codex plugin marketplace add mksglu/context-mode` → `codex plugin add context-mode@context-mode` → `npm install -g context-mode` → `context-mode setup --agents codex` → restart → `/ctx-doctor`
- **OpenCode:** `opencode plugin add context-mode` → restart → `/ctx-doctor`
- **OMP:** `omp plugin install context-mode` → `omp plugin list` *(verifikasi binary `omp` aktual di mesin Anda)*
- **ZCode:** `zcode plugins marketplace add mksglu/context-mode` → `zcode plugins install context-mode@context-mode` → `zcode plugins list`
- **Antigravity & Hermes Agent:** Belum ada alur instalasi native terverifikasi; jangan menyalin perintah dari agent lain.

---

## Langkah 6 — Setup OpenDesign MCP (Opsional)

Hanya perlu jika Anda memakai OpenDesign sebagai workspace desain bersama agent. Selalu preview dulu dengan `--print`:

```powershell
od mcp install opencode --print
od mcp install codex --print
```

Jika konfigurasi sudah aman, pasang ke harness yang dipakai lalu verifikasi:

```powershell
od mcp install opencode
od mcp install codex
od project list --json
od plugin list --json
od skills list --json
```

---

## Langkah 7 — Verifikasi Instalasi

Jalankan skrip verifikasi otomatis:

```powershell
.\scripts\verify-install.ps1
```

Lanjutkan dengan pemeriksaan native di dalam setiap coding-agent yang terpasang (buka aplikasi/CLI masing-masing dan cek daftar skill yang terbaca secara native, bukan hanya mengecek folder di disk).

---

## Checklist Final — Global per Device

- [ ] Node.js `24.15.0+` dan Git for Windows terpasang
- [ ] `npx.cmd skills --help` berjalan normal di PowerShell
- [ ] Lokasi Docker `.vhdx` sudah diarahkan ke drive data (jika pakai Docker)
- [ ] Semua coding-agent yang dipakai sudah login secara resmi
- [ ] 11 core skills terpasang dari source & commit SHA terverifikasi
- [ ] Context Mode terpasang dan lolos `/ctx-doctor` / plugin list pada harness yang didukung
- [ ] `verify-install.ps1` dan pemeriksaan native per agent lulus tanpa duplicate skill IDs
