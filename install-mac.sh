#!/bin/bash
# Installs (or updates) Sacid303, SacidKit, SacidSampler, SacidOne and SacidHalo into the Mac's VST3
# folder and removes the "downloaded from the internet" block, so Live can load them.
#   curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-mac.sh | bash
set -u
REPO="${SACID_REPO:-https://github.com/aleksandrsvoboda/sacid-plugins/releases/download}"
DEST="${SACID_DEST:-/Library/Audio/Plug-Ins/VST3}"
PLUGINS="Sacid303/sacid303-2.1 SacidKit/sacidkit-1.1 SacidSampler/sacidsampler-1.1 SacidOne/sacidone-1.2 SacidHalo/sacidhalo-1.0"
OLD_NAMES="Acid303 AcidKit AcidSampler AcidOne SacedOne"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "Installing into $DEST (macOS asks for your password once)."
sudo mkdir -p "$DEST" || exit 1

# The plug-ins were renamed; the old copies are the same plug-ins and would show up twice.
for old in $OLD_NAMES; do
    sudo rm -rf "$DEST/$old.vst3" "$HOME/Library/Audio/Plug-Ins/VST3/$old.vst3"
done

for entry in $PLUGINS; do
    name="${entry%%/*}"
    tag="${entry#*/}"
    if ! curl -fsSL -o "$TMP/$name.zip" "$REPO/$tag/$name-macos.zip"; then
        echo "  $name: download failed, skipped (try again in a few minutes)"
        continue
    fi
    mkdir -p "$TMP/$name"
    ditto -x -k "$TMP/$name.zip" "$TMP/$name" || { echo "  $name: unzip failed, skipped"; continue; }
    sudo rm -rf "$DEST/$name.vst3" "$HOME/Library/Audio/Plug-Ins/VST3/$name.vst3"   # one copy only
    sudo cp -R "$TMP/$name/$name.vst3" "$DEST/" && sudo xattr -cr "$DEST/$name.vst3" && echo "  $name: installed"
done

echo
echo "Done. In Ableton Live: Settings > Plug-Ins, turn on 'Use VST3 Plug-In System Folders',"
echo "then hold Option and click Rescan. They're under Plug-Ins > VST3 > Sacid."
