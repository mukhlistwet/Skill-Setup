# Runbook 03 — Maintenance, Pemulihan Source, Backup & Rollback

Panduan menjaga kebersihan skill, memulihkan URL upstream dari device lama, memperbarui versi secara terkendali, dan melakukan rollback bila terjadi regresi.

---

## 1. Memulihkan Source URL & Commit SHA dari Device Aktif

Sebelum melakukan clean reinstall atau migrasi ke device baru, lengkapi semua placeholder di `manifest/skills-manifest.csv`:

1. Jalankan inventarisasi di device lama:

```powershell
npx.cmd skills ls -g
```

2. Cek metadata instalasi dan `skills-lock.json` di folder global atau project untuk mendapatkan:
   - Exact repository URL (`OWNER/REPO` atau full URL)
   - Tag atau full commit SHA
   - Lisensi & provenance
3. Jika sebuah skill tidak memiliki metadata source:
   - **Jangan hapus salinan lamanya** sebelum backup selesai.
   - Cari kandidatnya dengan `npx.cmd skills find <nama-skill>` dan periksa `npx.cmd skills add OWNER/REPO --list`.
   - Bandingkan isi `SKILL.md` dan restriction-nya sebelum menetapkan URL resmi di manifest.

---

## 2. Backup Sebelum Reset atau Pembersihan Besar

Selalu jalankan backup otomatis sebelum menghapus atau mereset folder skill:

```powershell
.\scripts\backup-global.ps1
```

Skrip ini akan:
- Menyalin seluruh direktori skill global dari 6 agent yang ada ke `$HOME\AI-Skill-Backup-yyyyMMdd-HHmmss`.
- Menyimpan snapshot output `npx.cmd skills ls -g` ke file teks di dalam folder backup.
- Tidak menghapus atau memodifikasi file built-in bawaan aplikasi maupun MCP/plugin yang tidak terkait skill.

---

## 3. Update Rutin (Terkendali)

Periksa update terlebih dahulu tanpa langsung menimpa:

```powershell
npx.cmd skills check
```

Update global dan project secara terpisah:

```powershell
npx.cmd skills update -g
npx.cmd skills update -p
```

Setelah update diverifikasi aman, perbarui kolom `ref` (tag/commit SHA) di `manifest/skills-manifest.csv` dan commit ke setup repository.

---

## 4. Menghapus Skill & Rollback

### Hapus satu skill spesifik

```powershell
# Global
npx.cmd skills remove <NAMA-SKILL> --global

# Project (jalankan dari root project)
npx.cmd skills remove <NAMA-SKILL>
```

> Hindari bulk remove sebelum backup dan memahami cakupan `skills-lock.json`. Skill manual/untracked bisa tidak ikut terhapus oleh bulk remove.

### Rollback ke Backup Sebelumnya

Preview proses restore terlebih dahulu:

```powershell
.\scripts\rollback.ps1 -BackupPath "$HOME\AI-Skill-Backup-20261126-180000" -DryRun
```

Jalankan restore (skrip otomatis membuat safety snapshot terlebih dahulu sebelum menimpa):

```powershell
.\scripts\rollback.ps1 -BackupPath "$HOME\AI-Skill-Backup-20261126-180000"
```

---

## 5. Gate Audit Sebelum Menambah Skill Baru

Jangan memasang skill baru secara impulsif. Pastikan semua poin berikut lolos:

- [ ] Capability belum dicakup oleh 11 core skills atau policy aktif.
- [ ] Sudah membaca `SKILL.md` dan seluruh file pendukung/skrip di dalam repository sumber.
- [ ] Sudah memeriksa izin hooks, skrip eksekusi, akses jaringan, dan MCP permissions.
- [ ] Lisensi dan provenance repository jelas serta dapat diaudit.
- [ ] Tidak terjadi overlap/konflik instruksi dengan skill yang sudah terpasang.
- [ ] Scope (global vs project) sudah ditentukan dengan alasan jelas.
- [ ] Tag atau full commit SHA sudah di-pin dan dicatat di `manifest/skills-manifest.csv`.
- [ ] Sudah diuji routing/trigger-nya pada agent yang dipakai.
