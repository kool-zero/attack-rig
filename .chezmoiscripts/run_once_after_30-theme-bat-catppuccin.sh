#!/bin/bash
# install the Catppuccin Mocha theme for bat and rebuild its cache
set -u

# bat is batcat on Debian/Kali
BAT="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null || true)"
[ -n "$BAT" ] || { echo "bat-theme: bat not installed, skipping"; exit 0; }

# let bat tell us its config dir
CONFIG_DIR="$("$BAT" --config-dir 2>/dev/null)"
[ -n "$CONFIG_DIR" ] || CONFIG_DIR="$HOME/.config/bat"
THEME_DIR="$CONFIG_DIR/themes"
THEME_FILE="$THEME_DIR/Catppuccin Mocha.tmTheme"

if [ -f "$THEME_FILE" ]; then
    echo "bat-theme: Catppuccin Mocha already present, skipping fetch"
else
    mkdir -p "$THEME_DIR"
    URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
    if curl -fsSL "$URL" -o "$THEME_FILE"; then
        echo "bat-theme: fetched Catppuccin Mocha -> $THEME_FILE"
    else
        echo "bat-theme: download failed (non-fatal); bat will use a built-in theme" >&2
        rm -f "$THEME_FILE"
        exit 0
    fi
fi

# register the new theme
"$BAT" cache --build >/dev/null 2>&1 \
    && echo "bat-theme: cache rebuilt" \
    || echo "bat-theme: 'bat cache --build' failed (non-fatal)" >&2
exit 0
