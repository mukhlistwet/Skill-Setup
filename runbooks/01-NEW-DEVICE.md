# Runbook 01 — Setup Device Baru (Windows 11)

Panduan langkah demi langkah untuk memigrasikan lingkungan engineering dan coding-agent ke PC/laptop baru tanpa menyalin folder runtime, cache, atau file kredensial dari device lama.

---

## Langkah 1 — Siapkan Fondasi Dev Environment Windows

1. **Install paket dasar menggunakan `winget`** (atau install manual bila ingin versi spesifik):

   ```powershell
   winget import -i .\manifest\winget-packages.json --accept-package-agreements --accept-source-agreements
   ```

2. **Pastikan versi prasyarat terpenuhi:**
   - **Node.js `24.15.0+`** untuk Context Mode Engine; Skills CLI saat ini mendokumentasikan minimal Node.js `22.20.0+`. Jika memakai `fnm`, install dan aktifkan versi yang sesuai.
   - **Git for Windows** (dibutuhkan untuk clone repository dan shell tools Context Mode melalui Git Bash).
   - **Chrome / Edge / Chromium** (dibutuhkan jika menggunakan `design-taste-frontend` / browser testing).

   Verifikasi di PowerShell baru:

   ```powershell
   node --version
   npm --version
   git --version
   npx.cmd skills --help
   ```

   > Catatan PowerShell: gunakan `npx.cmd` jika `npx.ps1` terblokir Execution Policy Windows.

3. **Konfigurasi Git & SSH key baru** (jangan salin private key sembarangan jika bisa membuat key baru per device):

   ```powershell
   git config --global user.name "<NAMA_ANDA>"
   git config --global user.email "<EMAIL_ANDA>"
   ssh-keygen -t ed25519 -C "<EMAIL_ANDA>"
   ```

4. **Atur storage Docker Desktop sejak awal** (opsional, disarankan jika memakai Docker):
   - Buat folder di drive data internal (misalnya `D:\DockerData`).
   - Buka **Docker Desktop → Settings → Resources → Disk image location**, arahkan ke `D:\DockerData`, lalu **Apply & restart**.

---

## Langkah 2 — Clone Setup Repository

```powershell
Set-Location $HOME
git clone https://github.com/mukhlistwet/Skill-Setup.git
Set-Location "$HOME\Skill-Setup"
```

Periksa `manifest\skills-manifest.csv` dan `docs\SOURCES.md`. Kolom `source` telah diisi dengan upstream. Kolom `ref` masih kosong pada mapping awal, artinya installer memakai default branch upstream saat instalasi. Untuk hasil reproducible lintas device, isi `ref` dengan tag/full commit SHA yang sudah direview dan diuji.

---

## Langkah 3 — Install & Login Coding-Agent Harnesses

Install hanya coding-agent yang memang akan digunakan di device ini (misalnya OpenCode / OMP, Claude Code CLI, Codex, Antigravity, Hermes Agent, ZCode).

- Login menggunakan mekanisme autentikasi resmi masing-masing aplikasi.
- **Jangan** menyalin token, auth file, atau full global config mentah dari device lama.
- Pastikan agent yang dipilih saat install skills memang sudah tersedia dan didukung Skills CLI.

---

## Langkah 4 — Install 11 Global Core Skills

Cara yang direkomendasikan di Windows adalah menggunakan `INSTALL-SKILLS.bat`:

1. Jalankan `INSTALL-SKILLS.bat` dari File Explorer atau terminal.
2. Pilih target agent (default: OpenCode + Codex + Antigravity).
3. Pilih Core 11 saja, kecuali memang membutuhkan `vercel-react-best-practices`.
4. Periksa dry-run: source, exact skill ID, dan agent target.
5. Konfirmasi instalasi jika preview benar.
6. Periksa hasil:

   ```powershell
   npx.cmd skills ls -g
   .\scripts\verify-install.ps1
   ```

Alternatif PowerShell langsung:

```powershell
.\scripts\install-global-skills.ps1 -Agents opencode,claude-code,codex,antigravity -DryRun
.\scripts\install-global-skills.ps1 -Agents opencode,claude-code,codex,antigravity
```

Jika mayoritas pekerjaan menggunakan React/Next.js dan `vercel-react-best-practices` ingin dipasang global, tambahkan:

```powershell
-IncludeConditionalSkills "vercel-react-best-practices"
```

Jalankan command tanpa `-DryRun` hanya setelah preview diperiksa. Kolom `ref` kosong menghasilkan warning karena instalasi memakai default branch, bukan immutable pin.

---

## Langkah 5 — Install Project-Level Design Skill (Opsional)

`design-taste-frontend` tidak dipasang global. Gunakan `INSTALL-PROJECT-DESIGN-SKILL.bat`:

1. Jalankan BAT.
2. Masukkan full path root project.
3. Pilih agent target.
4. Periksa dry-run dan konfirmasi.
5. Installer menggunakan `--copy`; review hasil `git status`, baca seluruh file skill, lalu commit jika memang ingin menjadi bagian dari project.

PowerShell equivalent:

```powershell
.\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MyApp" -Skills design-taste-frontend -Agents opencode,codex -DryRun
```

---

## Langkah 6 — Install Global Plugin Context Mode (Per Harness)

Context Mode adalah plugin/engine, bukan Agent Skill biasa. Pasang satu kali hanya pada harness yang didukung dan benar-benar dipakai.

Gunakan upstream resmi `mksglu/context-mode` (kecuali Anda sengaja memakai fork terverifikasi). Lihat tabel perintah lengkap per harness di `docs/REFERENCE-AGENTS-PATHS.md`.

Ringkasan cepat:
- **Claude Code:** `claude plugin marketplace add mksglu/context-mode` → `claude plugin install context-mode@context-mode` → restart → `/ctx-doctor`
- **Codex:** `codex plugin marketplace add mksglu/context-mode` → `codex plugin add context-mode@context-mode` → `npm install -g context-mode` → `context-mode setup --agents codex` → restart → `/ctx-doctor`
- **OpenCode:** `opencode plugin add context-mode` → restart → `/ctx-doctor`
- **OMP:** `omp plugin install context-mode` → `omp plugin list` (verifikasi binary `omp` aktual di mesin Anda)
- **ZCode:** `zcode plugins marketplace add mksglu/context-mode` → `zcode plugins install context-mode@context-mode` → `zcode plugins list`
- **Antigravity & Hermes Agent:** jangan menganggap perintah harness lain kompatibel; gunakan hanya alur native yang resmi/terverifikasi.

---

## Langkah 7 — Setup OpenDesign MCP (Opsional)

Hanya perlu jika menggunakan OpenDesign sebagai workspace desain bersama agent. Selalu preview dulu dengan `--print`:

```powershell
od mcp install opencode --print
od mcp install codex --print
```

Jika konfigurasi sudah aman, pasang ke harness yang digunakan lalu verifikasi:

```powershell
od mcp install opencode
od mcp install codex
od project list --json
od plugin list --json
od skills list --json
```

OpenDesign MCP terpisah dari Agent Skills manifest dan tidak dipasang oleh BAT installer pada repository ini.

---

## Langkah 8 — Verifikasi Instalasi

Jalankan skrip verifikasi otomatis:

```powershell
.\scripts\verify-install.ps1
```

Lanjutkan dengan pemeriksaan native di dalam setiap coding-agent yang terpasang. Buka aplikasi/CLI masing-masing dan cek daftar skill yang terbaca secara native, bukan hanya mengecek folder di disk.

---

## Checklist Final — Global per Device

- [ ] Node.js versi sesuai kebutuhan (22.20.0+ untuk Skills CLI; 24.15.0+ untuk Context Mode Engine bila digunakan) dan Git for Windows terpasang.
- [ ] `npx.cmd skills --help` berjalan normal di PowerShell.
- [ ] Semua coding-agent yang dipakai sudah login secara resmi.
- [ ] Preview installer sudah diperiksa sebelum instalasi.
- [ ] 11 core skills terpasang; conditional hanya jika dibutuhkan.
- [ ] Source upstream telah ditinjau; `ref` di-pin jika memerlukan hasil reproducible.
- [ ] Context Mode terpasang dan lolos `/ctx-doctor` / plugin list pada harness yang didukung (jika digunakan).
- [ ] OpenDesign MCP di-preview dan diverifikasi (jika digunakan).
- [ ] `verify-install.ps1` dan pemeriksaan native per agent lulus tanpa duplicate skill IDs.
