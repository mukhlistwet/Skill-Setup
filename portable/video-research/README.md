# Video workflow portabel — mulai di sini

Paket ini menyimpan workflow riset/setup video, bukan akun atau instalasi aplikasi lengkap. Target yang dinyatakan pengguna: RAM 32 GB, Intel Core i5 generasi 8 (SKU belum diketahui), NVIDIA GTX 1070 Ti. Spesifikasi tersebut belum diprobe di device tujuan; OS, VRAM, driver dan performa tetap perlu diperiksa di sana.

## Cakupan yang benar-benar dapat disamakan

- Dua skill authored: `creator-video-workflow` dan `video-production-setup`, termasuk reference/template yang dibundel.
- Snapshot 16 field non-secret Hermes, dalam `settings.json`.
- Policy local-first dan research/setup-only, dalam `workflow-policy.json`.
- Blueprint MCP Blender yang TIDAK terpasang/aktif, dalam `templates/`.
- Riset/kontrak dan daftar uji produksi yang masih berupa rencana.

Ini BUKAN snapshot seluruh skill/agent yang terpasang. Skill engineering dari katalog root, aplikasi, dependencies, model entitlement, akun, cookie, browser profile, voice/asset library dan MCP account connections tidak dibawa. Model provider/default yang tersimpan memerlukan login sendiri dan pengecekan ketersediaan di device tujuan. Menyalin setting tidak memindahkan subscription/kuota.

## Prompt untuk agent pada device baru

> Baca paket `portable/video-research/` pada revision repo yang saya berikan. Ikuti README ini, verifikasi manifest SHA-256, lalu dry-run terhadap profil Hermes default yang aktif. Samakan hanya dua skill bundled dan setting allowlisted setelah menampilkan diff serta meminta izin apply. Jangan menghapus skill/config lain, menyentuh profil lain, memasang/menjalankan MCP atau Blender, login, upload, merender, generate, TTS, merental GPU atau memakai kredit. Target rencana saya RAM 32 GB, i5 generasi 8, GTX 1070 Ti; probe target sebelum memilih backend/model/driver. Berhenti jika ada konflik atau fitur/model tidak tersedia.

Berikan link branch/commit yang benar, bukan sekadar root repo jika perubahan belum masuk main. Review konten sebelum menjalankan script. Manifest mendeteksi kerusakan/konten berubah; ia bukan tanda tangan tepercaya. Gunakan commit Git yang telah diverifikasi untuk provenance.

## Restore skill, dry-run dahulu

Butuh Python 3.12+ (untuk pemeriksaan junction Windows) dan clone repo biasa. Script tidak menginstal dependency.

    python -B portable/video-research/tools/sync_video_setup.py

Target mengikuti `HERMES_HOME`; jika variabel tidak ada, default Windows adalah `%LOCALAPPDATA%\hermes`, sedangkan Linux/macOS `~/.hermes`. Pastikan path tersebut benar-benar profil default aktif. Target named profile ditolak. Gunakan `--home` hanya jika resolver perlu diarahkan secara eksplisit; jangan menunjuk user home/root drive/project.

Sesudah memeriksa rencana dan memberi izin:

    python -B portable/video-research/tools/sync_video_setup.py --apply

Helper hanya menambah file skill yang belum ada. File identik dilaporkan UNCHANGED. Existing skill yang berbeda atau mempunyai file tambahan membuat helper berhenti SEBELUM apply; tidak ada force/overwrite/delete. Agent harus menampilkan diff dan membuat backup lokal sebelum rekonsiliasi manual yang terpisah. Profil/skill yang tidak terkait tetap dipertahankan.

Apply terdiri dari penambahan file eksklusif, bukan transaksi atomik seluruh bundle. Gangguan disk/proses bisa meninggalkan sebagian file baru; keluar gagal, periksa hasil, kemudian ulangi dry-run. Jangan menganggap error berarti tidak ada file yang sempat dibuat. Helper tidak menyentuh config.yaml, auth atau setting MCP.

## Restore konfigurasi secara eksplisit

1. Baca `settings.json` dan bandingkan tiap key memakai `hermes config get KEY`.
2. Konfirmasi login/model pada target dan tampilkan perubahan yang dibutuhkan.
3. Setelah izin, jalankan hanya baris yang disetujui di `settings-commands.txt` melalui CLI native `hermes config set KEY VALUE`. Jangan menulis YAML manual, memakai `--force` atau mengganti seluruh config.
4. Baca ulang setiap key dengan CLI dan pastikan nilainya sesuai. Jika key/model tidak dikenal, berhenti; jangan mengklaim restore config berhasil.
5. Reload skill/config sesuai versi Hermes, lalu cek skill melalui tool native pada sesi baru. Identitas model dan entitlement dapat berbeda walaupun setting berhasil disimpan.

Nilai ini snapshot aktual, bukan rekomendasi universal untuk batas turn/concurrency atau keamanan. Setting yang tidak terdaftar, local paths, API endpoints, credential headers dan account connections sengaja tidak diekspor.

## Blender/agy/MCP: template saja

`templates/agy-blender-mcp.blueprint.json` adalah data rancangan, BUKAN format konfigurasi siap-import agy. Restore TIDAK menjalankan `uvx`, menambah MCP, memasang addon, mengubah PATH/firewall atau memulai port. Pin source tidak mengunci seluruh dependency graph dan tidak membuktikan distribusi sama dengan source.

Pada tahap instalasi yang kelak diizinkan: periksa `agy --help`, `agy mcp add --help`, `agy models`, runtime Blender dan spesifikasi target. Pilih satu controller, loopback-only, telemetry off, paid APIs off, serta batas filesystem. Safe mode bukan sandbox. Jangan bulk-run installer upstream lintas app/profil.

## Uji paket, bukan uji Blender

    python -B -m unittest discover -s portable/video-research/tests -v

Fixtures memakai direktori scratch Hermes, bukan profil sungguhan. Uji mencakup dry-run, hash tamper, path traversal, preservation/idempotency dan pembatasan profil. Hasil restore fixture tidak membuktikan MCP handshake, GPU backend, kecepatan, konsistensi video atau biaya pada target.

## Isi lain

- `manifest.json`: SHA-256 dan exact managed roots.
- `research/`: hasil penelitian dan kontrak; NOT_RUN pada test produksi tetap NOT_RUN.
- `RESEARCH.md`: batas adopsi dan sumber prioritas.
- `verification/`: hasil pemeriksaan paket yang benar-benar dijalankan, bukan hasil render.

Jangan menjalankan installer root repository hanya untuk paket video ini. Mekanisme legacy/root mempunyai cakupan berbeda dan tidak dimodifikasi oleh paket ini.
