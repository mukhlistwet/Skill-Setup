# Reference — Agent Paths, Context Mode & OpenDesign MCP

Dokumen referensi tunggal (tanpa duplikasi) untuk lokasi skill, instalasi plugin Context Mode, dan integrasi OpenDesign MCP.

---

## 1. Lokasi Global & Project Skill per Coding-Agent

`~` merujuk pada home folder Windows (`C:\Users\<NamaUser>`).

| Agent | Skills CLI ID | Global / User-Level | Project-Level | Catatan Khusus |
|---|---|---|---|---|
| **OpenCode** | `opencode` | `~/.config/opencode/skills/` | `.agents/skills/` (Skills CLI) atau `.opencode/skills/` (native) | Juga membaca `.claude/skills` & `.agents/skills`; hindari duplicate IDs. OMP berbagi ekosistem discovery OpenCode. |
| **Claude Code** | `claude-code` | `~/.claude/skills/` | `.claude/skills/` | Personal skills berlaku lintas project di device; project skills ikut repo. |
| **Codex** | `codex` | `~/.agents/skills/` | `.agents/skills/` | Membaca scope user, project, admin, dan system. |
| **Antigravity** | `antigravity` | `~/.gemini/config/skills/` | `.agents/skills/` | Workspace/project memakai `.agents/skills/`. |
| **Hermes Agent** | `hermes-agent` | `~/.hermes/skills/` | `.hermes/skills/` atau `.agents/skills/` | Wajib `hermes skills trust` per repo. `skills.external_dirs` bukan boundary read-only. |
| **ZCode** | `zcode` | `~/.zcode/skills/` | `.zcode/skills/` | Memakai direktori user dan project sendiri. |

---

## 2. Setup Global Plugin — Context Mode (Per Harness)

- **Upstream resmi:** `https://github.com/mksglu/context-mode`
- **Prasyarat Windows:** Node.js `24.15.0+` dan Git for Windows (Git Bash).
- **Kebijakan fork:** Gunakan upstream `mksglu/context-mode` kecuali ada alasan terverifikasi memakai fork pribadi.
- **Tindakan pasca-install:** Restart agent lalu jalankan perintah verifikasi.

| Agent | Perintah Install (PowerShell) | Verifikasi |
|---|---|---|
| **Claude Code** | `claude plugin marketplace add mksglu/context-mode`<br>`claude plugin install context-mode@context-mode` | `/ctx-doctor` |
| **Codex** | `codex plugin marketplace add mksglu/context-mode`<br>`codex plugin add context-mode@context-mode`<br>`npm install -g context-mode`<br>`context-mode setup --agents codex` | `/ctx-doctor` |
| **OpenCode** | `opencode plugin add context-mode` | `/ctx-doctor` |
| **Oh My OpenCode (OMP)** | `omp plugin install context-mode` *(verifikasi binary `omp` di mesin Anda)* | `omp plugin list` |
| **ZCode** | `zcode plugins marketplace add mksglu/context-mode`<br>`zcode plugins install context-mode@context-mode` | `zcode plugins list` |
| **Antigravity & Hermes** | *Belum ada install flow native yang terverifikasi.* | Jangan salin command harness lain |

---

## 3. Integrasi Opsional — OpenDesign MCP

Repository: `https://github.com/nexu-io/open-design`

OpenDesign adalah workspace desain dengan MCP server, bersifat opsional dan tidak wajib untuk menggunakan `DESIGN.md`.

### Langkah Preview (Wajib Sebelum Install)

```powershell
od mcp install codex --print
od mcp install claude --print
od mcp install opencode --print
od mcp install antigravity --print
od mcp install hermes --print
```

### Install & Verifikasi (Hanya pada Harness yang Dipakai)

```powershell
od mcp install codex
od mcp install opencode

od project list --json
od plugin list --json
od skills list --json
```

> Kompatibilitas README resmi mencakup Claude Code, Codex, OpenCode, Antigravity, dan Hermes. ZCode belum tercantum pada verifikasi terakhir.

---

## 4. Perintah Dasar Vercel Skills CLI

```powershell
# Cari & periksa skill sebelum install
npx.cmd skills find <keyword>
npx.cmd skills add OWNER/REPO --list

# Install global manual (template)
npx.cmd skills add OWNER/REPO@TAG-ATAU-COMMIT --skill NAMA-SKILL --global --agent opencode --agent codex --yes

# Install project manual (template, selalu pakai --copy untuk Git)
npx.cmd skills add OWNER/REPO@TAG-ATAU-COMMIT --skill NAMA-SKILL --agent opencode --agent codex --copy --yes

# Inspeksi & filter per agent
npx.cmd skills ls -g
npx.cmd skills ls -g -a opencode
npx.cmd skills ls -g -a codex
npx.cmd skills ls
```
