# Security & Permission Policy

## 1. Kebersihan Secrets & Git
- **Dilarang keras** meng-commit `.env`, API key, private key, kredensial login agent, token sesi, session history, atau full global config mentah ke setup repo maupun project repo.
- Jangan memasukkan file yang berisi secrets ke dalam index atau konteks Context Mode.
- Saat pindah device, selalu login ulang melalui alur autentikasi resmi masing-masing harness.

## 2. Boundary Eksekusi & Sandbox
- Context Mode **bukan** pengganti OS sandbox atau model izin sistem operasi. Tinjau scope hooks dan MCP sebelum mengaktifkan plugin.
- Jangan menjalankan perintah purge saat setup awal.
- Untuk Hermes Agent, `skills.external_dirs` di `~/.hermes/config.yaml` bukan boundary read-only bila proses Hermes memiliki hak tulis; jangan arahkan ke direktori bersama yang tidak boleh dimodifikasi.
- Selalu gunakan `hermes skills trust` secara selektif hanya untuk repository yang dipercaya.

## 3. Supply Chain Skill
- Jangan memasang skill hanya berdasarkan nama tanpa memeriksa source URL, lisensi, `SKILL.md`, skrip, hooks, dan akses jaringan.
- Wajib pin tag atau full commit SHA di `manifest/skills-manifest.csv` agar instalasi bersifat reproducible.
- Gunakan `--copy` untuk instalasi project-level agar dependensi eksplisit dan dapat di-review lewat Git diff.
