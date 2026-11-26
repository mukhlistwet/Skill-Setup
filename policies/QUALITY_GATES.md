# Quality Gates

Standar pemeriksaan sebelum perubahan dianggap siap merge atau rilis.

## 1. Code & Architecture Gate
- Perubahan bermakna wajib melalui review diff (`code-review`) dan pengecekan kompatibilitas kontrak (`api-and-interface-design` / `database-designer`).
- Bug dan regression non-trivial wajib ditelusuri sampai akar masalah (`systematic-debugging`), bukan sekadar tambalan gejala.

## 2. Security Gate
- Setiap perubahan pada auth, authorization, validasi input, integrasi eksternal, atau pengelolaan secrets wajib melewati `security-review`.

## 3. Testing & UI Verification Gate
- Jalankan unit/integration test project sebelum selesai.
- Untuk perubahan UI yang bermakna, lakukan pengujian workflow nyata di browser (`webapp-testing`) dan cek konsistensi responsive (mobile, tablet, desktop).
- Jika `DESIGN.md` dimodifikasi, jalankan `npx -p @google/design.md designmd lint DESIGN.md`.

## 4. Operational Readiness Gate
- Perubahan layanan produksi memperhatikan logging terstruktur, metrik, alerting (`observability-setup`), pipeline CI/CD (`ci-cd-pipeline-builder`), dan bottleneck performa (`performance-engineer`).
