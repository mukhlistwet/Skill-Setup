# Architecture Decision Records (ADRs)

Catatan keputusan desain di balik struktur setup repository ini agar mudah diaudit di masa depan.

---

## ADR-001: Konsolidasi dari 22 Skill Lama Menjadi 11 Core + 2 Conditional

**Keputusan:** Tidak memasang ulang 22 skill lama secara bersamaan. Fokus pada 11 core skills global + 2 conditional skills (`design-taste-frontend`, `vercel-react-best-practices`).

**Alasan:** Memasang banyak skill dengan domain tumpang tindih memicu konflik instruksi, membebani context window, dan membuat routing agent tidak deterministik.

### Pemetaan 10 Skill Lama yang Tidak Dipasang Terpisah

| Skill Lama | Keputusan | Kemampuan Tetap Berada Di |
|---|---|---|
| `frontend-design` | Tidak dipasang global terpisah | `DESIGN.md` project + `design-taste-frontend` (khusus marketing/website) |
| `web-design-guidelines` | Tidak dipasang terpisah | `policies/DESIGN_SYSTEM_POLICY.md` (aksesibilitas & UX baseline) |
| `vercel-composition-patterns` | Tidak dipasang terpisah | `frontend-ui-engineering` |
| `tailwind-design-system` | Tidak dipasang terpisah | `DESIGN.md` + konvensi Tailwind masing-masing project |
| `shadcn` | Tidak dipasang default | Gunakan CLI & dokumentasi shadcn hanya pada project terkait |
| `extract-design-system` | Tidak dipasang default | Aktifkan on-demand hanya untuk task reverse-engineering eksplisit |
| `impeccable` | Tidak dipasang default | `frontend-ui-engineering` + design review |
| `token-optimization` | Tidak dipasang sebagai skill | `policies/MASTER_ENGINEERING_POLICY.md` + Context Mode |
| `implement-spec` | Tidak dipasang sebagai skill | Workflow policy di `MASTER_ENGINEERING_POLICY.md` |
| `test-strategy` | Tidak dipasang sebagai skill | `policies/QUALITY_GATES.md` |

---

## ADR-002: Pemisahan 6 Repository Kandidat ke 5 Kategori

**Keputusan:** Menolak pemasangan 6 repository kandidat sebagai 6 Agent Skills.

- `context-mode` → Plugin/Engine per harness.
- `taste-skill` (`design-taste-frontend`) → Project-level Agent Skill khusus marketing/landing page.
- `open-design` → Opsional design workspace + MCP.
- `@google/design.md` → Format spesifikasi & CLI validator per project.
- `awesome-design-md` & `awesome-design-skills` → Katalog referensi (pilih maksimal 1, dilarang bulk-install 67 skill).

---

## ADR-003: Preferensi Upstream Context Mode

**Keputusan:** Gunakan upstream `mksglu/context-mode` untuk instalasi baru.

**Alasan:** Dokumentasi resmi Context Mode Engine menggunakan `mksglu/context-mode`. Fork pribadi hanya dipakai bila sudah diaudit diff-nya dan ada kebutuhan kustom eksplisit.

---

## ADR-004: Flag `--copy` untuk Project-Level Skills

**Keputusan:** Semua instalasi project-level melalui `install-project-skills.ps1` mewajibkan `--copy`.

**Alasan:** Menghindari symlink rusak saat repository di-clone di device lain dan memastikan setiap file skill masuk ke Git history secara transparan.
