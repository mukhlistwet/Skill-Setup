CREATOR DESKTOP — PAKET RENCANA v0.2
Tanggal: 28 November 2026, UTC+07:00
Status: PROPOSED / BELUM DISETUJUI UNTUK IMPLEMENTASI
Nama kerja: Creator Desktop; bukan nama produk yang sudah diputuskan.
Pemilik produk/pemberi persetujuan: ayah keren.

1. RINGKASAN
Aplikasi desktop Windows-first dengan Rust sebagai domain core dan Tauri sebagai shell yang diusulkan. Aplikasi mengubah brief dan aset menjadi rencana video, menjalankan workflow terkontrol melalui adapter/API/MCP/Chrome yang tersedia, lalu mengomposisi, meninjau dan mengekspor hasil.
Fokus vertical slice pertama: affiliate Shopee Indonesia AI-assisted/hybrid berbasis produk/varian nyata dan aset berizin. Blender bukan default affiliate; structured 3D engineering menjadi lane terpisah dengan Blender atau Three.js sesuai kebutuhan.
Shopee menjelaskan program affiliate melalui media sosial, Shopee Video dan Shopee Live; paket ini memilih video dan export manual, bukan live commerce.[12]

2. KEPUTUSAN DESAIN INTI — MASIH USULAN
  Tujuan: AFFILIATE, EDUCATIONAL, STORYTELLING, GENERAL.
  Format: SHORT, LONG, CUSTOM — terpisah dari tujuan.
  Platform output: Shopee Video, TikTok, YouTube Shorts/Video, Instagram Reels, Custom.
  Gaya produksi: product footage, product explainer, narrative/B-roll, motion graphic; 3D engineering kemudian.
  Template: mengunci workflow version, skill revisions, kebutuhan aset, opsi konfigurasi dan QA.
Contoh valid: AFFILIATE + SHORT + Shopee Video + Product Explainer.
Contoh valid: EDUCATIONAL + LONG + YouTube + Engineering 3D.
Sidebar boleh menyediakan shortcut Affiliate / Short / Video Biasa, tetapi shortcut tidak menjadi enum kategori yang saling meniadakan di database.

3. APA YANG SUDAH DIKETAHUI
  User ingin desktop berbasis Rust, MCP/adapter/Chrome, template routing, setting video, menu provider/model dan pemilihan model pada generator.
  Konteks konten: Shopee Indonesia; distribusi juga TikTok, YouTube dan Instagram.
  Skill editorial affiliate dan skill setup 3D sudah ada dalam pekerjaan sebelumnya. Skill bukan renderer, koneksi provider, maupun bukti aplikasi siap berjalan.
  Aplikasi ini belum dibangun. Tidak ada login, upload aset, render produksi atau kredit dipakai dalam pekerjaan perencanaan ini.

4. ASUMSI UNTUK DISETUJUI
  Single operator, single local workspace aktif, offline-first untuk metadata dan editing rencana.
  Windows menjadi target pertama; target hardware lama adalah laporan pengguna, bukan hasil benchmark aplikasi ini.
  UI web dalam Tauri diperbolehkan; “Rust desktop” bukan berarti semua UI harus pure Rust.
  Tidak ada akun cloud milik aplikasi, subscription server, kolaborasi multiuser atau marketplace plugin pada MVP.
  API resmi diprioritaskan; Chrome assistant bersifat opt-in. Tidak mengasumsikan akses Shopee OpenAPI/affiliate API atau Google Flow API tersedia.

5. BACA DOKUMEN
  01-PRD.txt                  overview, masalah, tujuan, core features, scope/non-goals.
  02-FLOWS-AND-USE-CASES.txt   use case, user flow, screen flow, state/error/approval flow.
  03-ARCHITECTURE.txt         tech stack, modul, trust boundary, ADR, NFR.
  04-DATABASE.txt             schema overview, kamus data, invariants, backup/migrasi.
  05-INTEGRATION-CONTRACTS.txt  provider/model, adapter, MCP, Chrome, workflow contracts.
  06-DELIVERY-AND-QA.txt       roadmap vertical slice, acceptance, risiko, decision log.
  07-SOURCE-NOTES.txt          temuan primer dan batas bukti.
  08-PRODUCTION-LANES.txt      keputusan user: affiliate AI/hybrid; engineering Blender/Three.js.
  requirements.csv           functional/NFR IDs, prioritas, acceptance, traceability.
  schema/001-initial.sql       DDL usulan SQLite; belum migrasi aplikasi nyata.
  schema/verify_schema.py      pemeriksaan executable terhadap DDL pada DB disposable.
  diagrams.html               diagram visual offline: arsitektur, use case, flow, ERD kelompok.
  diagrams/*.mmd              sumber diagram flow/ERD.
  diagrams/use-cases.puml      sumber UML use case.
  verification/               hasil validasi artefak perencanaan, bukan tes app.
  research/                  ledger URL sumber resmi; raw page captures tidak dipublikasikan.

6. BATAS DONE
Selesai di tahap ini berarti dokumen dan diagram tersedia, source references tervalidasi, DDL dapat dieksekusi dan constraint diuji, serta requirement dapat ditelusuri. Itu tidak membuktikan UI, model AI, Shopee integration, MCP handshake atau Chrome/Flow automation bekerja.
Jangan menyalin database runtime ke folder OneDrive yang sedang disinkronisasi. Lokasi paket rencana ini bukan lokasi runtime yang diusulkan.
Publikasi Git paket ini hanya menerbitkan rencana dan pemeriksa artefak. Tidak mengimplementasikan aplikasi, memasang dependency, mengekspor secret atau memberi izin generation/publishing.

7. KEPUTUSAN TERBUKA TERPENTING
  A. Setujui Windows-first + Tauri/Rust core + UI TypeScript, atau wajib pure Rust UI?
  B. Arah editorial disepakati: AI/hybrid affiliate dengan canonical product assets. Exact video provider/model/route pertama masih perlu dipilih dan diuji; footage asli tetap opsi/evidence.
  C. Provider text pertama ditentukan dari akun/model yang benar-benar dimiliki, bukan nama model yang diasumsikan tersedia.
  D. Jalur Chrome: manual-assisted lebih dahulu; extension native messaging hanya setelah spike read-only disetujui.
  E. Penyimpanan produk: lokal/manual dahulu; API/import Shopee hanya jika izin dan akses resmi terverifikasi.
Pertanyaan ini tidak menghalangi penyusunan plan, tetapi memblokir keputusan implementasi terkait.

Sources:
[12] https://help.shopee.co.id/portal/4/article/72053 — Shopee ID: affiliate program
