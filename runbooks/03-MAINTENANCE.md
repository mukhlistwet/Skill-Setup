# Runbook 03 — Maintenance, Source Pinning, Backup & Rollback

Panduan menjaga kebersihan skill, memeriksa upstream, mengunci versi, memperbarui secara terkendali, dan melakukan rollback bila terjadi regresi.

---

## 1. Periksa Source Upstream dan Manifest

Daftar source aktif disimpan dalam `manifest/skills-manifest.csv`. Mapping dan caveat per skill dicatat di `docs/SOURCES.md`.

1. Periksa `source` dan `skill` ID pada manifest.
2. Buka upstream repository/folder dan baca `SKILL.md` serta semua file pendukung.
3. Review license, scripts, hooks, network/file operations, dan tool permissions.
4. Cocokkan exact skill name yang tersedia dengan nilai kolom `skill` pada manifest.
5. Jangan menebak owner/repo hanya berdasarkan nama skill.

### Tentang kolom `ref`

- `ref` kosong berarti Skills CLI menggunakan default branch repository upstream ketika install dijalankan.
- Ini memudahkan first install, tetapi tidak reproducible: source dapat berubah dari waktu ke waktu.
- Untuk setup lintas device/produksi, pilih tag atau full commit SHA setelah review dan test, kemudian isi `ref`.
- Jangan mengisi SHA yang belum diverifikasi atau menggunakan commit dari repository lain.

Contoh source spec yang dipakai installer:

```text
addyosmani/agent-skills
addyosmani/agent-skills@<FULL_COMMIT_SHA>
```

---

## 2. Backup Sebelum Reset atau Pembersihan Besar

Selalu jalankan backup otomatis sebelum menghapus atau mereset folder skill:

```powershell
.\scripts\backup-global.ps1
```

Simpan lokasi backup dan pastikan direktori hasil backup dapat dibaca sebelum melanjutkan. Jangan menganggap backup parsial sebagai backup valid.

---

## 3. Install / Update Secara Terkendali

Sebelum install, jalankan dry-run:

```powershell
.\scripts\install-global-skills.ps1 -DryRun
```

Atau jalankan `INSTALL-SKILLS.bat` dan periksa preview sebelum konfirmasi.

Skills CLI juga menyediakan pemeriksaan dan update:

```powershell
npx.cmd skills check
npx.cmd skills update -g
npx.cmd skills update -p
```

Setelah update:

1. Periksa diff/isi skill yang berubah.
2. Jalankan test/use case pada agent yang ditargetkan.
3. Perbarui `ref` di manifest ke tag/full commit SHA yang sudah diuji.
4. Commit perubahan manifest dan catatan audit.

Jangan menjalankan bulk update pada semua skill tanpa memeriksa changelog/diff upstream.

---

## 4. Menghapus Skill & Rollback

### Hapus satu skill spesifik

```powershell
# Global
npx.cmd skills remove <NAMA-SKILL> --global

# Project (jalankan dari root project)
npx.cmd skills remove <NAMA-SKILL>
```

Hindari bulk remove sebelum backup dan memahami cakupan `skills-lock.json`. Skill manual/untracked bisa tidak ikut terhapus oleh bulk remove.

### Rollback ke Backup Sebelumnya

Preview proses restore terlebih dahulu:

```powershell
.\scripts\rollback.ps1 -BackupPath "$HOME\AI-Skill-Backup-<TIMESTAMP>" -DryRun
```

Jalankan restore setelah memeriksa preview:

```powershell
.\scripts\rollback.ps1 -BackupPath "$HOME\AI-Skill-Backup-<TIMESTAMP>"
```

---

## 5. Gate Audit Sebelum Menambah Skill Baru

Jangan memasang skill baru secara impulsif. Pastikan poin berikut lolos:

- [ ] Capability belum dicakup oleh 11 core skills atau policy aktif.
- [ ] Sudah membaca `SKILL.md` dan seluruh file pendukung/skrip di repository sumber.
- [ ] Sudah memeriksa hooks, skrip eksekusi, akses jaringan, akses file, dan MCP permissions.
- [ ] Lisensi dan provenance repository jelas serta sesuai kebutuhan penggunaan.
- [ ] Tidak terjadi overlap/konflik instruksi dengan skill yang sudah terpasang.
- [ ] Scope (global vs project) sudah ditentukan dengan alasan jelas.
- [ ] Tag atau full commit SHA telah dipin dan dicatat di `manifest/skills-manifest.csv` untuk instalasi reproducible.
- [ ] Dry-run dan test routing/trigger sudah dilakukan pada agent yang dipakai.

---

## 6. Catatan Troubleshooting

- Jika `npx.cmd` tidak ditemukan, install/repair Node.js dan buka terminal baru agar PATH ter-refresh.
- Jika Skills CLI menolak `--agent`, periksa agent ID yang didukung oleh versi CLI saat ini.
- Jika source tidak ditemukan, verifikasi repo/skill ID dan akses jaringan; jangan mengganti source secara acak.
- Jika `ref` kosong, pesan warning tentang floating/default branch adalah expected behavior.
- Jika skill terpasang tetapi tidak terbaca agent, periksa native skill directory dan dokumentasi discovery harness tersebut.
