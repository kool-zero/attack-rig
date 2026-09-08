# tmux

`prefix` = **Ctrl-b**

## windows (tabs) & panes

| Keys | Action |
|------|--------|
| `prefix c` | **new window** (tab) |
| `prefix ,` | rename window |
| `prefix n` / `prefix p` | next / previous window |
| `prefix 0`…`9` | jump to window N |
| `prefix w` | window / session picker |
| `prefix &` | **close window** (tab): asks to confirm |
| `prefix -` / `prefix \|` | **split pane**: stacked (top/bottom) / side-by-side |
| `prefix ← ↑ ↓ →` | move between panes |
| `prefix Ctrl-h/j/k/l` | **resize pane**: vi dirs, repeatable |
| `prefix o` | cycle panes · `prefix z` zoom pane (toggle fullscreen) |
| `prefix x` | **close pane**: asks to confirm (or just `exit` / `Ctrl-d`) |
| `prefix d` | detach session (leaves it running) |

## capture & grab

| Keys | Action |
|------|--------|
| `prefix Tab` | **extrakto**: grab text on screen · `Enter` copy · `Tab` inject · `Ctrl-f` cycle filter (word/all/line/**ipv4**) |
| `prefix [` | copy-mode · `v` select · `Enter` copy (→ clipboard via OSC 52) |
| `prefix P` | paste-buffer |

## popups & tools

| Keys | Action |
|------|--------|
| `prefix g` | **lazygit** popup (current repo) |
| `prefix r` | reload tmux config |
| `prefix ?` | **cheats browser** (this): `/` filter · `Enter` open · `Esc` back · `q` quit |

## shell (zsh)

| Keys | Action |
|------|--------|
| `Ctrl-g` | **navi**: runnable-command launcher (fill placeholders → run) |
| `Ctrl-x Ctrl-e` | edit the current command line in `$EDITOR` |
| `Ctrl-r` | history search |

_Mouse is on: click/drag to select panes, resize borders, scroll. Full key list: `prefix :` then `list-keys`._
