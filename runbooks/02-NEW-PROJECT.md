# Runbook 02 — Setup Project Baru

Playbook cepat saat memulai atau meng-clone repository project baru agar skill, design system, dan batasan keamanan langsung tertata tanpa bloat.

---

## Pilih Profil Sesuai Tipe Project

| Tipe Project | Global Core Skills | `DESIGN.md` | `design-taste-frontend` | `vercel-react-best-practices` |
|---|---|---|---|---|
| **A. Backend / API / Worker / CLI** | Ya (otomatis) | Tidak | **Tidak** | Tidak |
| **B. Admin Dashboard / POS / ERP / Internal App** | Ya (otomatis) | **Ya** | **Tidak** (kecuali redesign eksplisit) | Opsional (jika React/Next.js) |
| **C. Company Website / SaaS Marketing / Landing Page** | Ya (otomatis) | **Ya** | **Ya (project-level `--copy`)** | Opsional (jika React/Next.js) |

---

## Langkah 1 — Fondasi Wajib Semua Tipe Project

1. Masuk ke root project:

```powershell
Set-Location "D:\Projects\<PROJECT_NAME>"
```

2. Salin template instruksi project dan lengkapi konteks arsitektur/stack:

```powershell
Copy-Item "$HOME\engineering-agent-setup\templates\AGENTS.md.template" ".\AGENTS.md"
```

3. Gabungkan aturan `.gitignore` khusus artefak agent/secrets ke `.gitignore` project:

```powershell
Get-Content "$HOME\engineering-agent-setup\templates\gitignore-agent.txt" | Add-Content ".\.gitignore"
```

4. Pastikan file environment menggunakan template `.env.example` dan tidak pernah meng-commit `.env`.

---

## Langkah 2 — Setup `DESIGN.md` (Khusus Tipe B & C)

`DESIGN.md` adalah sumber kebenaran desain tingkat project, bukan global skill.

1. Salin template ke root repository:

```powershell
Copy-Item "$HOME\engineering-agent-setup\templates\DESIGN.md.template" ".\DESIGN.md"
```

2. (Opsional) Jika mengambil inspirasi dari katalog `awesome-design-md` atau `awesome-design-skills`:
   - Pilih **maksimal satu** referensi yang paling relevan.
   - Periksa lisensi, token, aset, skrip, dan potensi konflik instruksi.
   - Adaptasikan sepenuhnya ke identitas produk Anda; jangan menyalin mentah identitas brand lain dan jangan bulk-install katalog 67 skill.

3. Pasang validator `@google/design.md` sebagai dev dependency (pin versi di `package.json` & commit lockfile karena spesifikasi masih berstatus `alpha`):

```powershell
npm install -D "@google/design.md"
```

4. Validasi `DESIGN.md` (atau jalankan secara one-off):

```powershell
npx -p @google/design.md designmd lint DESIGN.md
```

Untuk membandingkan revisi:

```powershell
npx -p @google/design.md designmd diff DESIGN.md DESIGN-v2.md
```

---

## Langkah 3 — Install Project-Level Skills (Jika Diperlukan)

Gunakan skrip installer project yang otomatis memakai flag `--copy` agar file skill tersimpan fisik di repository dan tidak rusak oleh symlink device lain.

### Contoh Tipe C — Pasang `design-taste-frontend`

```powershell
& "$HOME\engineering-agent-setup\scripts\install-project-skills.ps1" `
  -ProjectPath "D:\Projects\<PROJECT_NAME>" `
  -Skills "design-taste-frontend" `
  -Agents opencode,claude-code,codex,antigravity
```

Contoh prompt saat memakai `design-taste-frontend`:

```text
Gunakan design-taste-frontend untuk membangun landing page produk ini.
Baca DESIGN.md project terlebih dahulu.
Pertahankan brand token dan jangan ubah API atau business logic.
Selesaikan responsive layout dan jalankan browser consistency check.
```

### Contoh Tambahan — Pasang `vercel-react-best-practices` (jika tidak dipasang global)

```powershell
& "$HOME\engineering-agent-setup\scripts\install-project-skills.ps1" `
  -ProjectPath "D:\Projects\<PROJECT_NAME>" `
  -Skills "vercel-react-best-practices" `
  -Agents opencode,claude-code,codex,antigravity
```

---

## Langkah 4 — Trust Project di Hermes Agent (Bila Dipakai)

Hermes mewajibkan trust eksplisit sebelum memuat skill lokal dari repository:

```powershell
Set-Location "D:\Projects\<PROJECT_NAME>"
hermes skills trust
```

Untuk mencabut trust:

```powershell
hermes skills untrust
```

---

## Langkah 5 — Verifikasi Project

```powershell
& "$HOME\engineering-agent-setup\scripts\verify-install.ps1" -ProjectPath "D:\Projects\<PROJECT_NAME>"
npx.cmd skills ls
```

---

## Checklist Final — Per Project

- [ ] `AGENTS.md` tersedia dan mencerminkan stack/konvensi repository
- [ ] `DESIGN.md` tersedia & lolos lint (khusus project frontend/UI)
- [ ] Project-specific skills dipasang dengan `--copy` hanya bila benar-benar dibutuhkan
- [ ] `skills-lock.json` ikut ter-commit jika memakai Skills CLI
- [ ] Tidak ada duplicate skill IDs lintas folder (`.agents/skills`, `.claude/skills`, `.opencode/skills`)
- [ ] Tidak ada competing design systems
- [ ] Pola `.gitignore` agent aktif dan tidak ada secrets di Git
- [ ] `hermes skills trust` sudah dijalankan (jika memakai Hermes)
