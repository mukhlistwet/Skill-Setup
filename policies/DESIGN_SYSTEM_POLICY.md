# Design System Policy

## 1. Otoritas `DESIGN.md`
- Setiap project frontend yang membutuhkan konsistensi visual wajib memiliki satu `DESIGN.md` di root repository.
- Tidak boleh ada dua arah desain atau design system yang saling bersaing di dalam satu project.
- Karena format `@google/design.md` masih berstatus `alpha`, pin versinya di `package.json` dan commit lockfile.

## 2. Baseline Aksesibilitas & UX
- Wajib menggunakan semantic HTML, navigasi keyboard yang benar, focus state yang jelas, kontras warna memadai, label form yang tepat, dan menghormati `prefers-reduced-motion`.
- Praktik ini menjadi standar permanen lintas project tanpa perlu memasang skill terpisah yang tumpang tindih.

## 3. Penggunaan Katalog & Visual Specialist
- `design-taste-frontend` hanya diaktifkan pada company website, marketing website, landing page, product launch, atau visual redesign eksplisit.
- Untuk admin dashboard, POS, ERP, HRIS, atau data-heavy internal app, prioritaskan kejelasan informasi, struktur komponen, dan token `DESIGN.md` daripada gaya marketing landing page.
- Saat merujuk `awesome-design-md` atau `awesome-design-skills`: pilih maksimal satu referensi, audit lisensi/token/skrip, lalu adaptasikan ke identitas produk sendiri. Jangan pernah bulk-install katalog.
