# Master Engineering Policy

Kebijakan kanonikal lintas project untuk menjaga konsistensi eksekusi coding-agent, efisiensi konteks, dan kualitas arsitektur.

## 1. Prinsip Single Source of Truth
- Konvensi spesifikasi desain tingkat produk berada di `DESIGN.md` pada root project.
- Konvensi stack, perintah build/test, dan arsitektur spesifik repository berada di `AGENTS.md` pada root project.
- Jangan menduplikasi instruksi yang sama di banyak skill.

## 2. Disiplin Skill & Context Management
- Gunakan maksimal **11 core skills global** untuk kebutuhan engineering harian.
- Pasang conditional/specialist skills hanya pada project yang memang membutuhkannya.
- Gunakan Context Mode pada harness yang didukung untuk efisiensi token dan manajemen konteks; jangan memasang skill terpisah hanya untuk *token optimization*.
- Hindari duplicate skill IDs lintas direktori kompatibilitas (`.agents/skills`, `.claude/skills`, `.opencode/skills`).

## 3. Alur Eksekusi Perubahan
1. Pahami konteks dan baca `AGENTS.md` serta `DESIGN.md` (untuk task UI) sebelum mengubah kode.
2. Untuk perubahan arsitektur, database schema, atau kontrak API, rancang tradeoff dan dampaknya terlebih dahulu.
3. Implementasikan secara terfokus tanpa mengubah business logic atau kontrak di luar scope task.
4. Jalankan verifikasi otomatis dan review diff sebelum menyatakan selesai.
