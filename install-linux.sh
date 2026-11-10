#!/bin/bash
# Installs (or updates) Sacid303, SacidKit, SacidSampler, SacidOne and SacidHalo for the current user:
# plug-ins into ~/.vst3, the standalone apps into ~/.local/bin. No root needed.
#   curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-linux.sh | bash
set -u
REPO="${SACID_REPO:-https://github.com/aleksandrsvoboda/sacid-plugins/releases/download}"
VST3="${SACID_DEST:-$HOME/.vst3}"
BIN="${SACID_BIN:-$HOME/.local/bin}"
PLUGINS="Sacid303/sacid303-2.1 SacidKit/sacidkit-1.1 SacidSampler/sacidsampler-1.1 SacidOne/sacidone-1.2 SacidHalo/sacidhalo-1.0"
OLD_NAMES="Acid303 AcidKit AcidSampler AcidOne SacedOne"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$VST3" "$BIN" || exit 1

# The plug-ins were renamed; the old copies are the same plug-ins and would show up twice.
for old in $OLD_NAMES; do
    rm -rf "$VST3/$old.vst3" "$BIN/$old"
done

for entry in $PLUGINS; do
    name="${entry%%/*}"
    tag="${entry#*/}"
    if ! curl -fsSL -o "$TMP/$name.tar.gz" "$REPO/$tag/$name-linux-x64.tar.gz"; then
        echo "  $name: download failed, skipped (try again in a few minutes)"
        continue
    fi
    mkdir -p "$TMP/$name"
    tar -xzf "$TMP/$name.tar.gz" -C "$TMP/$name" || { echo "  $name: unpack failed, skipped"; continue; }
    rm -rf "$VST3/$name.vst3"
    cp -R "$TMP/$name/$name.vst3" "$VST3/"
    if [ -f "$TMP/$name/$name" ]; then
        cp "$TMP/$name/$name" "$BIN/$name" && chmod +x "$BIN/$name"
    fi
    echo "  $name: installed"
done

echo
echo "Done. Plug-ins are in $VST3 - rescan plug-ins in your DAW."
echo "The standalone apps are in $BIN (run e.g. SacidOne; add $BIN to PATH if it isn't)."
