#!/bin/sh
# Baut das Arch-Paket und veröffentlicht es als pacman-Paketquelle im GitHub-Release „repo“.
# Voraussetzungen: makepkg, repo-add, gh (angemeldet: gh auth login)
set -eu

REPO_NAME=tv-play
TAG=repo
cd "$(dirname "$0")/.."

makepkg -f --cleanbuild --nodeps  # Laufzeit-Abhängigkeiten installiert pacman beim Nutzer
PKG="$(makepkg --packagelist | head -n1)"
[ -f "$PKG" ] || { echo "Paket $PKG nicht gefunden"; exit 1; }

rm -rf dist && mkdir dist
cp "$PKG" dist/
repo-add -q "dist/$REPO_NAME.db.tar.gz" "dist/$(basename "$PKG")"
# GitHub-Releases kennen keine Symlinks – echte Kopien hochladen
for f in db files; do
    rm "dist/$REPO_NAME.$f"
    cp "dist/$REPO_NAME.$f.tar.gz" "dist/$REPO_NAME.$f"
done

if ! gh release view "$TAG" >/dev/null 2>&1; then
    gh release create "$TAG" --title "pacman-Paketquelle" \
        --notes "Dateien für die pacman-Paketquelle von tv-play. Einrichtung siehe README."
fi

# Alte Paketversionen aus dem Release entfernen
for asset in $(gh release view "$TAG" --json assets --jq '.assets[].name'); do
    case "$asset" in
        *.pkg.tar.zst) [ "$asset" = "$(basename "$PKG")" ] || gh release delete-asset "$TAG" "$asset" --yes ;;
    esac
done

gh release upload "$TAG" --clobber dist/*
echo "Veröffentlicht: $(basename "$PKG")"
