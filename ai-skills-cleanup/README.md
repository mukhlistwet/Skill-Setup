# AI Agent Skills Cleanup for Windows

PowerShell utility untuk mengaudit dan membersihkan folder skills AI coding agents pada Windows 10/11.

## Yang didukung

Lokasi global yang diperiksa:

- Agent Skills / `skills.sh`: `%USERPROFILE%\.agents\skills`
- OpenCode: `%USERPROFILE%\.config\opencode\skills` dan folder singular `skill`
- Claude Code: `%USERPROFILE%\.claude\skills`
- Codex: `%USERPROFILE%\.codex\skills`
- Antigravity: `%USERPROFILE%\.gemini\antigravity\skills`
- Cursor: `%USERPROFILE%\.cursor\skills`
- Windsurf: `%USERPROFILE%\.windsurf\skills` dan `%USERPROFILE%\.codeium\windsurf\skills`
- Cline: `%USERPROFILE%\.cline\skills`
- Roo Code: `%USERPROFILE%\.roo\skills`
- Kilo Code: `%USERPROFILE%\.kilocode\skills`
- Continue: `%USERPROFILE%\.continue\skills`
- Zencoder: `%USERPROFILE%\.zencoder\skills`
- ZCode: `%USERPROFILE%\.zcode\skills` (candidate location; verify the path shown by the audit)
- Beberapa custom config root melalui environment variables: `OPENCODE_CONFIG_DIR`, `XDG_CONFIG_HOME`, `CODEX_HOME`, dan `CLAUDE_CONFIG_DIR`.

Lokasi project yang diperiksa: `.agents/skills`, `.claude/skills`, `.codex/skills`, `.opencode/skills`, `.cursor/skills`, `.windsurf/skills`, `.cline/skills`, `.roo/skills`, `.kilocode/skills`, `.continue/skills`, `.gemini/antigravity/skills`, `.github/skills`, `.zencoder/skills`, dan `.zcode/skills` (candidate location).

> Daftar ini mencakup lokasi umum, bukan semua kemungkinan custom path. Folder `skills` generik di root project sengaja tidak dihapus otomatis karena bisa menjadi source code aplikasi.

## Cara paling mudah (interaktif)

1. Extract ZIP ke folder biasa, misalnya `C:\Tools\AI-Skills-Cleanup`.
2. Tutup OpenCode, Codex, Antigravity, Claude Code, Cursor, VS Code, dan terminal agent lain.
3. Untuk audit saja, klik dua kali `Run-Audit.bat`. Untuk menu cleanup, klik dua kali `Start-Cleanup.bat`. Keduanya menjalankan PowerShell dengan ExecutionPolicy Bypass hanya untuk proses tersebut.
4. Alternatif manual: buka PowerShell sebagai user Windows biasa (tidak perlu Administrator), lalu pindah ke folder script:

   ```powershell
   cd C:\Tools\AI-Skills-Cleanup
   ```

5. Jalankan:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
   .\Reset-AISkills.ps1
   ```

6. Pilih menu:
   - `1` untuk audit saja, tanpa menghapus.
   - `2` untuk menghapus global skills.
   - `3` untuk menghapus skills pada satu project.
   - `4` untuk menghapus global + project skills.
   - `5` untuk keluar.
7. Periksa semua path yang ditampilkan. Script akan membuat backup dan baru menghapus setelah Anda mengetik `HAPUS`.

## Rekomendasi prosedur paling aman

Jalankan audit terlebih dahulu:

```powershell
.\Reset-AISkills.ps1 -Mode Audit
```

Setelah memeriksa hasil audit, hapus global skills:

```powershell
.\Reset-AISkills.ps1 -Mode CleanupGlobal
```

Untuk satu project tertentu:

```powershell
.\Reset-AISkills.ps1 -Mode CleanupProject -ProjectPath 'D:\Projects\nama-project'
```

Untuk global + satu project:

```powershell
.\Reset-AISkills.ps1 -Mode CleanupBoth -ProjectPath 'D:\Projects\nama-project'
```

## Custom path

Jika Anda menyimpan skills di lokasi lain, berikan path secara eksplisit. Contoh:

```powershell
.\Reset-AISkills.ps1 -Mode Audit -ExtraSkillPath 'D:\Shared\agent-skills'
```

Untuk beberapa path:

```powershell
.\Reset-AISkills.ps1 -Mode CleanupGlobal -ExtraSkillPath 'D:\Shared\agent-skills', 'E:\AI\skills'
```

Gunakan `-ExtraSkillPath` hanya untuk folder yang memang berisi kumpulan skills dan memang ingin dibersihkan.

## Backup dan pemulihan

Secara default backup dibuat di home directory dengan nama seperti:

`C:\Users\NamaUser\skills-cleanup-backup-20261126-183000`

Backup berisi:

- Salinan file dan folder biasa dari setiap target.
- `manifest.json` dan `manifest.csv` yang memetakan path asli ke backup.
- File `*_links.json` untuk metadata symlink/junction yang ditemukan.
- `deletion-errors.csv` jika ada target yang gagal dihapus.

Untuk memulihkan file/folder biasa, salin isi folder backup target kembali ke path asli sesuai `manifest.csv`. Metadata link disimpan untuk referensi; link yang dihapus mungkin perlu dibuat ulang secara manual dengan target yang tercatat.

## Perlindungan dan batasan

Script ini:

- Tidak menggunakan `Remove-Item -Recurse` untuk menghapus tree.
- Tidak mengikuti symlink/junction saat backup maupun penghapusan.
- Jika target utama adalah symlink/junction, hanya link tersebut yang dilepas; target aslinya tetap ada.
- Menghentikan proses jika backup gagal.
- Memerlukan konfirmasi dengan mengetik tepat `HAPUS`.
- Tidak menghapus `.config\opencode`, `.claude`, `.codex`, `.gemini` atau folder konfigurasi root lainnya.
- Tidak menghapus MCP, provider, API keys, agent definitions, rules, hooks, plugins, package manager cache, npm packages, `node_modules`, atau dependency project.

Script tidak dapat menemukan semua custom path dan skill yang dibundel di dalam plugin/extension. Periksa konfigurasi custom Anda dan gunakan `-ExtraSkillPath` untuk lokasi tambahan.

## Perbaikan versi cleanup (v1.0.2)

Versi ini memperbaiki dua kasus PowerShell saat backup:

- `RelativePrefix` dan `RelativePath` mengizinkan string kosong untuk mewakili root backup.
- Parameter `Links` pada fungsi backup mengizinkan `ArrayList` kosong melalui `[AllowEmptyCollection()]`. Tanpa atribut ini, Windows PowerShell dapat menolak backup folder yang tidak berisi symlink/junction meskipun kondisi tersebut normal.

Kegagalan backup tetap menghentikan penghapusan. Tidak ada penghapusan yang dilakukan sebelum seluruh target selesai di-backup.

## Troubleshooting

**PowerShell menolak menjalankan script**

Jalankan ini pada jendela PowerShell yang sama:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

**Access denied**

Pastikan aplikasi agent sudah ditutup dan jalankan PowerShell dengan akun Windows yang memiliki folder tersebut. Jangan langsung menjalankan seluruh script sebagai Administrator kecuali memang diperlukan.

**Ada skills yang masih tersisa**

Periksa path custom pada setting masing-masing tool dan jalankan audit dengan `-ExtraSkillPath`. Script hanya memeriksa lokasi yang didefinisikan, bukan memindai seluruh disk.
