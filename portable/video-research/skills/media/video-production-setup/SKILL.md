---
name: video-production-setup
description: Use when setting up portable local-first video workflows.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [video, blender, antigravity, mcp, portability, setup]
---

# Setup video portabel, local-first

## When to Use

Gunakan untuk riset, pemilihan renderer, konfigurasi dan pemulihan workflow video pada device lain. Ini koordinator SETUP, bukan izin membuat video. `creator-video-workflow` tetap pemilik brief, narasi, hak aset, produksi dan QA. Jangan memasang koordinator editorial kedua.

## Batas persetujuan

Permintaan riset/setup/migrasi mengizinkan perubahan dokumen dan konfigurasi yang secara eksplisit diminta; tidak mengizinkan generation, render produksi, voice synthesis, upload aset, login baru, rental GPU atau penggunaan kredit. Aktifkan tahap tersebut hanya setelah permintaan dan persetujuan terpisah. Template/deklarasi policy bukan enforcement sandbox atau hard spending cap.

## Target device dan bukti

Baca `references/targets.json`. Bedakan `reported_target` dari hasil probe langsung. Target yang dinyatakan pengguna adalah RAM 32 GB, Intel Core i5 generasi 8 dan GTX 1070 Ti; CPU SKU, OS, VRAM, driver, instalasi Blender dan performa belum diukur pada device itu. Jangan menyebut hardware target sebagai hasil pemeriksaan mesin aktif atau memindahkan kesimpulan benchmark device lama ke device baru.

Pada target, periksa OS, CPU/RAM, GPU/VRAM/driver, executable Blender, versi dan capability Cycles/EEVEE. GTX 1070 Ti tidak menjamin kecepatan render tertentu. Pilih versi Blender kompatibel berdasarkan sumber resmi dan smoke test yang diizinkan, bukan otomatis downgrade atau upgrade. Jangan menganggap instalasi portable tidak ada hanya karena PATH/registry kosong.

## Jalur local-first

1. Cek CLI agy yang benar-benar terpasang: help, MCP interface dan model yang tersedia. Jangan memakai model ID pensiun atau mengasumsikan kuota/tarif. Pilih model ringan untuk edit sederhana dan lebih mampu untuk logika geometri/animasi yang kompleks.
2. Agy membuat script scene reusable dan versioned; MCP Blender opsional untuk inspeksi/iterasi. Renderer sebenarnya Blender lokal; MCP tidak menambah tenaga GPU.
3. Untuk authoring/preview mulai scene sederhana, resolusi rendah, satu proses dan aset hemat memori. Produksi panjang sebaiknya memakai script/.blend tersimpan dan batch rendering, bukan satu RPC panjang. Benchmark representative frame/segment hanya bila mendapat izin menjalankan render.
4. Higgsfield merupakan penyedia layanan opsional: TTS, sandbox dan GPU rental; bukan sinonim Blender atau model video. Flow/Seedance merupakan lane generatif terpisah. Jangan memaksa setiap video melewati semua engine.
5. Jangan mengaktifkan paid asset APIs atau cloud fallback otomatis. Rental hanya setelah bottleneck lokal terukur, quote/budget disetujui dan cleanup/rental-status readback dirancang.

## MCP dan supply chain

Baca references/provider-pins.json sebagai snapshot riset, bukan bukti binary aman atau kompatibilitas teruji. Periksa ulang sumber/paket/lock dan publikasi resmi sebelum install. `ahujasid/blender-mcp` telah mengarah ke `ahujasid/mcp-for-blender`; jangan menebak nama paket dari tutorial lama.

Gunakan satu controller dan addon yang sesuai, loopback-only, telemetry dinonaktifkan eksplisit, dan safe mode bila kompatibel. Socket tanpa autentikasi/enkripsi dan arbitrary Python tetap berisiko; validator safe-mode bukan sandbox OS. Jangan expose port ke LAN/internet atau menjalankan bulk installer yang mengubah client/profil lain. MCP config dari repo berstatus TEMPLATE_DISABLED dan tidak dijalankan oleh restore.

## Aset dan kit engineering

Pertahankan canonical mesh/material/rig/camera/timing dan provenance, bukan hanya referensi gambar. Scene mekanik memerlukan domain checks; render selesai bukan bukti mekanisme benar. Kit engineering pengguna masih perlu adaptasi Claude/Linux, source resolver fork yang pinned, fail-closed shell stages, validasi output dan cleanup biaya. Jangan menyalin importer/script upstream ke runtime tanpa review; pertahankan lisensi/NOTICE.

## Migrasi melalui Git

Repo setup adalah sumber konfigurasi PORTABEL, bukan backup akun. Bawa hanya skill yang dibundel dan field setting allowlisted; jangan menyalin auth.json, .env, cookie/profile browser, vault, akun, memories pribadi, session DB, logs atau konfigurasi MCP berisi credential. Path device diselesaikan ulang pada target, bukan mengganti username secara global.

Restore harus memverifikasi manifest/hash, menampilkan diff dan dry-run secara default, menghormati HERMES_HOME/profil aktif dan menolak profil lain. Periksa link pada file manifest sendiri, bukan hanya folder/payload; tolak komponen parent tujuan sebelum akses filesystem dan bandingkan root yang sudah dinormalisasi. Preflight semua ancestor/direktori tujuan sebelum menambah file agar regular-file obstruction pada skill belakangan tidak menyebabkan partial apply yang sudah dapat diprediksi. Pertahankan representasi byte/hash lintas Git checkout; CRLF yang sengaja dipertahankan perlu atribut whitespace yang sesuai, bukan mematikan pemeriksaan error secara global. Perubahan config Hermes melalui `hermes config set`, bukan edit YAML manual. Merge field yang dikelola saja; pertahankan setting/skill yang tidak terkait. Perubahan existing skill memerlukan backup/approval dan tidak boleh menghapus skill lain. Instalasi aplikasi/addon dan login dilakukan sebagai tahap terpisah, bukan side effect restore.

## Definition of done

Laporkan secara terpisah: research snapshot, config/skills restored, dependency installed, MCP handshake, CPU/GPU smoke, render QA, dan cost reconciliation. Test restore fixture tidak membuktikan Blender bekerja pada target. Setelah push, baca ulang SHA dan blob exact di GitHub sebelum memberikan link. Jika hanya branch yang dipush, berikan link branch/commit itu dan jangan mengklaim sudah merge ke main.
