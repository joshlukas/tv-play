#!/bin/sh
# Installiert tv-play für den aktuellen Benutzer (ohne root) – für Linux-Systeme ohne pacman.
#   ./install.sh             installieren / aktualisieren
#   ./install.sh --uninstall entfernen (Kopplung in ~/.pyatv.conf bleibt erhalten)
set -eu

PYATV_REF="git+https://github.com/robkochman/pyatv.git@8144c77c6cecbed4f9ba2adb5a350ad86a8f6604"
PREFIX="${PREFIX:-$HOME/.local}"
LIB="$PREFIX/lib/tv-play"
BIN="$PREFIX/bin"
MENU="${XDG_DATA_HOME:-$HOME/.local/share}/kio/servicemenus"
SRC="$(cd "$(dirname "$0")" && pwd)"

if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$LIB" "$BIN/tv-play" "$BIN/tv-play-konsole" "$MENU/tv-play.desktop"
    echo "tv-play entfernt."
    exit 0
fi

missing=""
for cmd in python3 git ffmpeg ffprobe avahi-browse; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
if [ -n "$missing" ]; then
    echo "Bitte zuerst installieren:$missing"
    echo "  (Debian/Ubuntu: sudo apt install python3-venv git ffmpeg avahi-utils"
    echo "   Fedora:        sudo dnf install python3 git ffmpeg avahi-tools)"
    exit 1
fi
python3 -c 'import sys; sys.exit(sys.version_info < (3, 11))' \
    || { echo "Python 3.11 oder neuer wird benötigt."; exit 1; }

echo "» Lege Python-Umgebung in $LIB/venv an …"
rm -rf "$LIB/venv"
python3 -m venv "$LIB/venv"
"$LIB/venv/bin/pip" install -q --upgrade pip
echo "» Installiere pyatv (mit tvOS-26/27-Korrektur) …"
"$LIB/venv/bin/pip" install -q "pyatv @ $PYATV_REF" "srptools==1.0.1"

install -d "$BIN" "$MENU"
sed "1s|.*|#!$LIB/venv/bin/python -I|" "$SRC/tv-play" > "$BIN/tv-play"
cp "$SRC/tv-play-konsole" "$BIN/tv-play-konsole"
chmod 755 "$BIN/tv-play" "$BIN/tv-play-konsole"
sed "s|tv-play-konsole|$BIN/tv-play-konsole|" "$SRC/tv-play.desktop" > "$MENU/tv-play.desktop"
chmod 755 "$MENU/tv-play.desktop"
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true

echo
echo "Fertig. Nächste Schritte:"
echo "  1. tv-play --pair   (einmalig, PIN wird am Fernseher angezeigt)"
echo "  2. Bei aktiver Firewall Port 8099 fürs Heimnetz öffnen"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  Hinweis: $BIN ist nicht im PATH." ;; esac
