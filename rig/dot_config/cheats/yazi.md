# yazi

Terminal file manager (`yazi`, or the `y` wrapper that cd's to wherever you quit).
This rig's config: hidden files **shown**, dirs first, natural sort, size linemode.
Opening a file (`Enter` / `o`) hands it to `$EDITOR`.
Keys below are yazi **defaults**. Press `~` inside yazi for the full, live keymap.

## navigate

| Keys | Action |
|------|--------|
| `h` `j` `k` `l` | parent · down · up · **enter dir / open file** |
| `←` `↓` `↑` `→` | same, with arrows |
| `K` / `J` | scroll preview up / down |
| `g g` / `G` | jump to top / bottom |
| `z` / `Z` | jump via **zoxide** / **fzf** |

## select

| Keys | Action |
|------|--------|
| `Space` | toggle selection, move down |
| `v` / `V` | enter / exit **visual** select mode |
| `Ctrl-a` | select all |
| `Ctrl-r` | invert selection |
| `Esc` | clear selection / cancel |

## file operations

| Keys | Action |
|------|--------|
| `y` / `x` | **yank (copy)** / **cut** |
| `p` / `P` | paste / paste **overwriting** |
| `Y` / `X` | cancel the pending yank / cut |
| `d` / `D` | **trash** / **delete permanently** |
| `a` | create. ends with `/` makes a directory |
| `r` | rename |
| `c c` / `c d` / `c f` / `c n` | copy **full path** / **dir path** / **filename** / **name (no ext)** |
| `;` / `:` | run a shell command / (blocking) |

## view · search · open

| Keys | Action |
|------|--------|
| `.` | toggle hidden files |
| `s` / `S` | search by **name (fd)** / **content (rg)** |
| `f` | filter the current directory |
| `/` `?` · `n` `N` | find forward / back · next / prev match |
| `,` then key | sort menu (`m` mtime, `s` size, `n` natural, ...) |
| `o` / `O` | open with... / open interactively |
| `Tab` | toggle the spot / preview info panel |

## tabs · tasks · quit

| Keys | Action |
|------|--------|
| `t` · `1`-`9` · `[` `]` | new tab · switch to tab N · prev / next tab |
| `w` | task manager (copy/move progress) |
| `~` | **help**: the full, live keymap |
| `q` / `Q` | quit (**cd on exit** via the `y` wrapper) / quit **without** cd |
