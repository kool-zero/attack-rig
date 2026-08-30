# Presentation

Slides and terminal recordings from the OffSec Live session "Your Attack Rig as Code".
This directory is documentation, not part of the rig: `.chezmoiignore` keeps `chezmoi
apply` from ever writing it into your home directory.

- `your-attack-rig-as-code.pdf`: the deck, one page per slide, including the vertical
  backup slide that sits under the penelope demo.
- `casts/`: the terminal recordings embedded in the deck, in
  [asciinema](https://asciinema.org) v2 format.

## Playing the recordings

They are real unedited sessions, so you can replay them at your own pace, scrub, and
copy text straight out of the terminal:

```bash
asciinema play casts/coldopen.cast          # bare Kali to a working rig, one command
asciinema play casts/ghostty-demo.cast      # carry it, trigger it, the config reacts
asciinema play casts/penelope-mcp.cast      # three shells, one MCP channel
```

`coldopen.cast` runs 5m27s in real time. The deck plays it at 8x, so speed it up to
match what you saw on stage:

```bash
asciinema play -s 8 casts/coldopen.cast
```
