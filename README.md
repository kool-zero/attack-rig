# attack-rig

Your attack rig as code. Kali gives you a world-class offensive base, and so does any
Kali-derived cloud VM or client jumpbox; this repo is the **personal layer** on top: the
tools, keys, cheats, and recipes that make a box *yours*, laid down with one command by
[chezmoi](https://chezmoi.io). Targets Kali/Linux.

```bash
chezmoi init --apply https://github.com/<you>/attack-rig.git
```

That's it. On the first run chezmoi asks for your **GitHub username** (used only to fetch
your *public* SSH keys) and then converges the box.

## What it sets up

- **An opinionated shell, ready to go**: a managed `~/.zshenv` + `~/.zshrc` so the box
  is usable the moment `apply` finishes. `~/.local/bin` (where the downloaded tools land)
  is put on `PATH` for every shell, [oh-my-zsh](https://ohmyz.sh) loads a tight plugin
  set (`git`, `zsh-autosuggestions`, `fast-syntax-highlighting`: all vendored as
  externals), and [Starship](https://starship.rs) draws the prompt. Every tool
  integration (atuin, zoxide, fzf, navi) is `command -v`-guarded, so the *same* rc works
  on a stripped Linux jumpbox and a fully set-up Kali box alike.
- **Catppuccin Mocha, everywhere it shows**: one theme across the whole surface: the
  [Starship](dot_config/starship.toml) prompt, `fast-syntax-highlighting`,
  [tmux](dot_tmux.conf.tmpl) (via TPM), and [bat](dot_config/bat/config). Themes are
  vendored as externals or fetched by a `run_once` script, so the look travels with the
  rig instead of being hand-installed on each box.
- **Auto-updating toolkit** (`.chezmoiexternal.toml`): tools declared by URL and kept
  current on their own:
  - `penelope` from raw GitHub (tracks `main`)
  - `chisel` / `ligolo-ng` via `gitHubLatestRelease` (track the newest upstream release)
  - `goshs` pinned to a tag (pin-vs-track contrast)
  - a **run-vs-serve split**: binaries you run land in `~/.local/bin`; payloads you serve
    to targets land in `~/.local/share/payloads` (with a `~/payloads` reminder symlink)
  - pin-vs-track shown side by side: penelope/chisel/ligolo track upstream, goshs is
    pinned to a tag: one repo, carried identically onto every Kali/Linux box
- **Reachable, but only when you say so**: Kali installs `openssh-server` and leaves the
  service disabled on purpose, which is the right default for a box that visits other
  people's networks. So this repo does not turn it on for you. `touch ~/.enable_sshd` and
  re-apply, and [`enable-sshd`](.chezmoiscripts/run_onchange_after_50-enable-sshd.sh.tmpl)
  enables it (`systemctl enable --now`, so it survives a reboot) and warns if
  `authorized_keys` is empty, because then you are exposing password auth on a box whose
  stock credentials everyone knows. Removing the marker reports the state but deliberately
  does **not** stop a running sshd: cutting your own access to a remote box is the worse
  failure. Turn it off explicitly with `sudo systemctl disable --now ssh`.
- **Your keys, trusted**: `~/.ssh/authorized_keys` is populated from your GitHub public
  keys, so the box trusts you out of the box.
- **Cheats, versioned**: [navi](https://github.com/denisidoro/navi) runnable cheats
  (`Ctrl-g`) with placeholder generators (`<lhost>` auto-detects your VPN interface,
  `<target>`, `<port>`, `<session_id>`), gated by what's actually installed; plus
  markdown reference cards (`tmux`, `windbg`) for a `glow`-style browser.
- **Recipes as a runbook**: a global [just](https://github.com/casey/just)file
  (`justg`) with a `security` group (reverse-shell / meterpreter multihandlers,
  badchars), an `offsec` group (`new-project <name>` scaffolds an engagement directory
  tree: recon/loot/exploits/notes/scans), and `just update` to refresh the whole rig.
- **Batteries included on Kali**: one `run_once` installer
  ([`.chezmoiscripts/run_once_after_10-install-linux-tools.sh`](.chezmoiscripts/run_once_after_10-install-linux-tools.sh.tmpl))
  brings a bare box up to fully functional. `apt` lays down what Kali already packages
  well (`zsh tmux git curl fzf ripgrep bat eza jq zoxide direnv unzip`). The helpers Kali's
  apt *doesn't* ship (`navi`, `atuin`, and `yazi`) are pulled from their official installers
  / GitHub releases into `~/.local/bin`, alongside `just`, `glow`, and `starship`. The AI CLIs
  (`claude-code`, `codex`) aren't in apt and aren't packaged for Linux *anywhere*, so
  they're installed from **npm** into `~/.local` (no sudo; the `claude`/`codex` binaries
  land on `PATH`). It's idempotent (skips anything already present), non-fatal per tool,
  and never `sudo`s blindly (root vs. sudo is detected). No Homebrew required; if you
  happen to run Linuxbrew, `brew install navi just glow atuin starship` is an equivalent
  path, but this rig doesn't use it.
- **Portable shell history**: [atuin](https://github.com/atuinsh/atuin) makes your
  shell history a fuzzy, full-text, per-directory search (Ctrl-r / up-arrow). Ships
  local-first here; turn on end-to-end-encrypted sync and your shell history follows you
  to every box (self-host the server or use atuin's).
- **`ls` you actually want**: [eza](https://github.com/eza-community/eza) takes over `ls`,
  with `ll`, `la`, and `lt` (a two-level tree). Dirs first, icons, and git status in the
  long views. The aliases are defined only when eza is present, and aliases are
  interactive-only, so scripts on the box still get the real `ls`.
- **Directory jump**: [zoxide](https://github.com/ajeetdsouza/zoxide) backs `cd`, so it
  learns your paths and `cd <partial>` teleports to the frecent match. `fz` opens an
  [fzf](https://github.com/junegunn/fzf) picker over *every* dir zoxide knows (frecency
  ordered) with a live `eza` preview of each: `fz` to browse them all, `fz <keyword>` to
  pre-filter. Both degrade gracefully: no fzf falls back to zoxide's plain best-match jump,
  no eza to plain `ls`. [yazi](https://github.com/sxyazi/yazi) covers the times you'd rather
  browse than type: `y` opens it and drops you in whatever directory you quit from.
- **Per-engagement environment**: [direnv](https://direnv.net) loads an `.envrc` on `cd` and
  unloads it on the way out, so a target IP lives with the engagement instead of in your
  scrollback. `just new-project acme 10.10.10.5` scaffolds the tree and writes the `.envrc`
  (committable) plus a gitignored `.env` (the values), so `$TARGET`, `$ENGAGEMENT`, and
  `$LOOT` are set the moment you `cd` in. direnv is deny-by-default: an `.envrc` stays
  blocked until you `direnv allow` it, which is what you want on a box where you `cd` into
  other people's directories.
- **Terminal capture & grab**: a trimmed [tmux config](dot_tmux.conf.tmpl) built for
  fieldwork: split with the keys that look like the split (`prefix |` side-by-side,
  `prefix -` stacked; the default `"`/`%` are unbound), `prefix C` toggles live pane
  logging to `~/.tmux-logs/`, `prefix H` dumps the full scrollback to a timestamped
  file, `prefix Tab` (extrakto) grabs IPs / hashes / URLs straight off the screen, and
  `prefix ?` opens the glow cheats browser.
- **Your AI is part of the rig**: a demo Claude Code skill (`recon-notes`) versioned
  right next to everything else, and the AI CLIs (`claude-code`, `codex`) installed by the
  Kali installer above. The rig is public; your real secrets are not.

## Where things are declared, and how to add one

A rig spans more than one installer, and pretending otherwise is how you end up
reinventing a package manager. The mechanisms stay native; what's unified is the
*declaration*. There is one place to look per kind of thing, and `just tools` prints
every declared tool, where it comes from, and whether it's actually on the box.

| What you need | macOS | Kali/Linux | Declared in |
|---|---|---|---|
| Common CLI tool | brew | apt | `.chezmoidata/packages.yaml` |
| Bleeding edge, or the distro lags | GitHub release | GitHub release | `.chezmoiexternal.toml` |
| Tool no package manager carries | GitHub release | GitHub release | `.chezmoiexternal.toml` |
| Language-ecosystem CLI | npm / pipx | npm / pipx | `.chezmoidata/packages.yaml` |
| System change (apt source, `.deb`, service) | n/a | ansible | `dot_bootstrap/*.yml` |
| Upstream only ships an install script | vendor script | vendor script | the `run_once` installer |
| Distro lacks it and there's no release | brew | Linuxbrew | installer, commented out |

The defaults differ per OS because the *cheapest correct source* differs per OS. On macOS
that's Homebrew, which carries almost everything (16 of the 18 tools here, `ligolo-ng` and
`penelope` being the exceptions). On a Kali box you rebuild constantly it's apt, because
it's already there, while Linuxbrew would cost you a full toolchain download on every
rebuild. Same declaration, different fetcher. That is what the templating is for.

Adding a tool is a one-line edit in whichever file the table points at. Nothing is
hardcoded in shell: the installer templates its package list straight out of
`.chezmoidata/packages.yaml`.

## Script order is alphabetical, so number it

chezmoi runs scripts in lexicographic order of their target name, which means the order is
whatever the alphabet happens to give you. That bit once: `install-ghostty` sorted before
`install-linux-tools`, so an optional extra ran before the base toolchain, and when it
failed chezmoi stopped and the whole base never installed. A two-digit prefix makes the
dependency explicit instead of accidental:

```
run_before_10-fix-dns.sh.tmpl                 # network first, everything else needs it
run_once_before_20-decrypt-age-key.sh.tmpl    # identity, before encrypted files land

run_once_after_10-install-linux-tools.sh.tmpl # the base: apt, just, starship, npm CLIs
run_onchange_after_20-install-ghostty.sh.tmpl # extras, which need apt working
run_once_after_30-theme-bat-catppuccin.sh     # needs bat from step 10
run_onchange_after_40-configure-xfce-panel.sh.tmpl  # reacts to what 20 installed
run_onchange_after_50-enable-sshd.sh.tmpl     # independent, so it goes last
```

Gaps of ten leave room to insert a step without renumbering. Note that
`.chezmoiignore` matches the **target** name, so it lists `.chezmoiscripts/20-install-ghostty.sh`,
not the source filename.

One thing numbering cannot fix: templates are rendered *before* any script runs, so a
`lookPath` in `40-configure-xfce-panel` sees the box as it was at the start of the apply.
Install Ghostty and the launcher appears on the **next** apply, not this one. That is why
the demo applies twice, and it is a property of template evaluation, not of ordering.

## Marker files: carry it, but do not run it

Some boxes should receive the *files* without the *side effects*. A client jumpbox you do
not own, a container, a machine where you want to read a playbook before it touches
anything. Three marker files in `$HOME` gate the parts of this repo that change the
system. They live outside the repo on purpose, so the same commit behaves differently per
machine, and nothing about the box is encoded in the source.

| Marker | Effect | Default |
|---|---|---|
| `~/.chezmoi_only_copy_files` | Provisioning scripts **copy** their playbooks and skip running them | absent (things run) |
| `~/.enable_sshd` | Enables the ssh service (Kali ships it installed but off) | absent (ssh stays off) |
| `~/.no_dns_fix` | Skips the malformed-resolver repair | absent (repair runs if needed) |

**`~/.chezmoi_only_copy_files`** is the important one. With it present,
[`install-ghostty`](.chezmoiscripts/run_onchange_after_20-install-ghostty.sh.tmpl) still
delivers `~/.bootstrap/ghostty.yml` but refuses to execute it, printing what it skipped.
Remove the marker, apply again, and the same commit provisions the box:

```bash
touch ~/.chezmoi_only_copy_files && chezmoi apply   # carries the playbook, installs nothing
rm ~/.chezmoi_only_copy_files    && chezmoi apply   # now it provisions
```

The gate is a `stat` in the script's **template**, so the marker's state is baked into the
rendered content. That is why these are `run_onchange_` and not `run_once_`: toggling the
marker changes the script's contents, which is what makes chezmoi re-run it. A `run_once_`
script would fire once and then ignore the marker forever.

## Keeping it fresh

```bash
chezmoi apply --refresh-externals   # refresh + pull the latest tool versions
just update                         # same thing, from the runbook
```

Externals carry a weekly `refreshPeriod`, so an ordinary `chezmoi apply` also picks up
new tool versions about once a week without you asking.

## age encryption demo

This repo doubles as a worked example of chezmoi's
[age](https://age-encryption.org) encryption: the mechanism you'd use to carry *real*
secrets in a dotfiles repo, shown here with a **throwaway key and a fake token** so the
whole thing is safe to publish. It's a two-layer flow:

1. **A passphrase unlocks your identity, once.** The age private key is itself encrypted
   with a passphrase and shipped as [`key.txt.age`](key.txt.age). On the first `apply`,
   [`run_once_before_20-decrypt-age-key.sh`](.chezmoiscripts/run_once_before_20-decrypt-age-key.sh.tmpl)
   notices there's no `~/.config/chezmoi/key.txt` yet, asks for the passphrase **once**,
   and writes the decrypted identity to `~/.config/chezmoi/key.txt` (mode 600). Being a
   `run_once_before` script, it runs *before* any encrypted file is applied.
2. **The identity decrypts everything else, silently.** With the key in place, chezmoi
   auto-decrypts every `encrypted_*.age` source file for the rest of that apply, and
   every apply after, with no further prompts. The demo file is
   [`dot_config/encrypted_private_lab-creds.env.age`](dot_config/encrypted_private_lab-creds.env.age),
   which decrypts to `~/.config/lab-creds.env` holding a single fake token.

**Passphrase for this demo: `attack-rig-demo`.** It's printed here on purpose: the key is
a throwaway and guards nothing real. For non-interactive runs (CI, an automated
`chezmoi init`), set `CHEZMOI_AGE_PASSPHRASE=attack-rig-demo` in the environment and the
`run_once_before` reads it instead of prompting.

Why it only asks **once**: the passphrase protects the *identity*, not each individual
secret. You unlock the identity a single time (the `run_once_before`); chezmoi then uses
that identity to decrypt every `encrypted_*.age` file for free. Ciphertext is stored
ASCII-armored (`age.armor = true` in `.chezmoi.toml.tmpl`) so it's text-diffable in git.

> In a *real* rig you'd generate your own key, keep the passphrase in your head (not the
> README), and encrypt real secrets. The `.gitignore` still blocks stray `*.age`,
> `key.txt`, `*.key`, and `.env` files; it only carves out chezmoi's own `key.txt.age`
> and `encrypted_*.age` source files, which are meant to be committed.

### Making it yours: swapping in your own key

The demo key is throwaway, so the first thing to do with a fork is rotate it. The same
steps cover *rotating* a key you already own (a leak, a lost laptop, routine hygiene):
generate a new identity, re-encrypt every secret to it, then re-wrap the identity itself.

**Start by asking chezmoi what is actually encrypted**, so you know the full blast radius:

```bash
chezmoi managed --include=encrypted                          # target paths
chezmoi managed --include=encrypted --path-style=source-relative   # source files
```

In this repo that is a single file (`dot_config/encrypted_private_lab-creds.env.age`), but
in a real rig it is the checklist of everything you must re-encrypt. Then:

```bash
# 1. While the OLD key still works, get every secret back to plaintext on disk.
chezmoi cat ~/.config/lab-creds.env          # inspect
chezmoi apply                                # or just apply, which writes them out

# 2. Generate a new identity. age-keygen refuses to overwrite, so move the old one aside.
mv ~/.config/chezmoi/key.txt ~/.config/chezmoi/key.txt.old
age-keygen -o ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
age-keygen -y ~/.config/chezmoi/key.txt      # prints the new PUBLIC key (the recipient)

# 3. Put that public key in .chezmoi.toml.tmpl under [age] recipient = "age1...",
#    then regenerate the real config. chezmoi.toml is GENERATED, so editing only the
#    template does nothing until you re-init.
chezmoi init

# 4. Re-encrypt each secret to the new recipient (plaintext must be on disk).
chezmoi add --encrypt ~/.config/lab-creds.env

# 5. Re-wrap the identity itself with your own passphrase, replacing the demo key.txt.age.
chezmoi age encrypt --passphrase --output "$(chezmoi source-path)/key.txt.age" \
    ~/.config/chezmoi/key.txt
```

Verify before you commit, because a mistake here is only visible on the *next* machine:

```bash
mv ~/.config/chezmoi/key.txt /tmp/key.verify          # pretend to be a fresh box
chezmoi age decrypt --passphrase --output ~/.config/chezmoi/key.txt \
    "$(chezmoi source-path)/key.txt.age"              # your new passphrase
chmod 600 ~/.config/chezmoi/key.txt
chezmoi cat ~/.config/lab-creds.env                   # should print the secret
```

Once that round-trips, delete `key.txt.old`, commit the changed `key.txt.age`,
`encrypted_*.age` files, and `.chezmoi.toml.tmpl`, and treat the old passphrase as burned.
Rotating the key does **not** rewrite git history: the old ciphertext is still in earlier
commits, so if a *real* secret leaked, rotate the secret at its source too.

To encrypt something new, `chezmoi add --encrypt <file>`; chezmoi stores it as
`encrypted_*.age` and decrypts it on every apply.

## Errata

During the live session `authorized_keys` came out empty and extrakto did not load.
Both are fixed in the current commit.

- **Empty `authorized_keys`**: the GitHub username was mistyped during setup, so
  `gitHubKeys` had no account to read and the template rendered nothing. It fails
  silently, which is the annoying part; `enable-sshd` now warns when the file is empty.
- **extrakto missing**: TPM arrives as an external, but it does not install the plugins
  `.tmux.conf` declares. That normally needs `prefix + I` typed inside tmux, which is not
  "one command and the rig is up". A `run_onchange` script now installs them on apply.

## Notes

- Everything here is **public-safe**. The age demo above uses a throwaway key and a fake
  token on purpose; your *real* secrets stay out of the repo; generate your own key and
  encrypt real configs the same way. This is the portable layer, not the vault.
- Set `GITHUB_TOKEN` in your environment if you hit GitHub's unauthenticated rate limit
  while fetching externals or your public keys.
