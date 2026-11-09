#!/bin/bash
# Installs (or updates) AcidSampler, SacedOne, Acid303 and AcidKit into the Mac's VST3 folder and
# removes the "downloaded from the internet" block, so Live can load them.
#   curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/acid-plugins/main/install-mac.sh | bash
set -u
REPO="https://github.com/aleksandrsvoboda/acid-plugins/releases/download"
DEST="/Library/Audio/Plug-Ins/VST3"
PLUGINS="AcidSampler/acidsampler-1.0 SacedOne/sacedone-1.1 Acid303/acid303-2.0 AcidKit/acidkit-1.0"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "Installing into $DEST (macOS asks for your password once)."
sudo mkdir -p "$DEST" || exit 1

# AcidOne was renamed SacedOne: same plug-in, so the old copy would show up twice in Live.
sudo rm -rf "$DEST/AcidOne.vst3" "$HOME/Library/Audio/Plug-Ins/VST3/AcidOne.vst3"

for entry in $PLUGINS; do
    name="${entry%%/*}"
    tag="${entry#*/}"
    if ! curl -fsSL -o "$TMP/$name.zip" "$REPO/$tag/$name-macos.zip"; then
        echo "  $name: download failed, skipped"
        continue
    fi
    mkdir -p "$TMP/$name"
    ditto -x -k "$TMP/$name.zip" "$TMP/$name" || { echo "  $name: unzip failed, skipped"; continue; }
    sudo rm -rf "$DEST/$name.vst3" "$HOME/Library/Audio/Plug-Ins/VST3/$name.vst3"   # one copy only
    sudo cp -R "$TMP/$name/$name.vst3" "$DEST/" && sudo xattr -cr "$DEST/$name.vst3" && echo "  $name: installed"
done

echo
echo "Done. In Ableton Live: Settings > Plug-Ins, turn on 'Use VST3 Plug-In System Folders',"
echo "then hold Option and click Rescan. They're under Plug-Ins > VST3 > Acid303 and Saced."
