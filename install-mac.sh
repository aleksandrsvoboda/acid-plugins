#!/bin/bash
# Installs (or updates) the Sacid plug-ins you pick into the Mac's VST3 folder and removes
# the "downloaded from the internet" block, so Live can load them.
#   curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-mac.sh | bash
# Unattended: SACID_ONLY="SacidOne SacidHalo" (or SACID_ANSWER="1 5") skips the question.
set -u
REPO="${SACID_REPO:-https://github.com/aleksandrsvoboda/sacid-plugins/releases/download}"
DEST="${SACID_DEST:-/Library/Audio/Plug-Ins/VST3}"
PLUGIN_DIR="$DEST"
SUDO="sudo"; [ -n "${SACID_DEST:-}" ] && SUDO=""
# --- Pick which plug-ins to install --------------------------------------------------
# Name, release tag, earlier names (removed when that plug-in is installed), description.
CATALOGUE="
SacidOne|sacidone-1.2|AcidOne SacedOne|mono synth: analog / FM / granular + step sequencer
SacidSampler|sacidsampler-1.1|AcidSampler|pitch-tracking sampler
SacidKit|sacidkit-1.1|AcidKit|808 / 909 drum machine
Sacid303|sacid303-2.1|Acid303|303 bass synth + sequencer
SacidHalo|sacidhalo-1.0||harmonic exciter + reverb (effect)"

entries() { echo "$CATALOGUE" | sed '/^$/d'; }
count="$(entries | wc -l | tr -d ' ')"

# The script arrives through a pipe (curl ... | bash), so questions read from the terminal.
ask() {
    if [ -n "${SACID_ANSWER+set}" ]; then printf '%s\n' "$SACID_ANSWER"; return 0; fi   # for scripted installs
    if ( exec < /dev/tty ) 2>/dev/null; then
        local reply
        IFS= read -r reply < /dev/tty || reply=""
        printf '%s\n' "$reply"
        return 0
    fi
    return 1   # no keyboard: install everything
}

# To the terminal when there is one (stdout is the pipe from curl), else plain stdout.
say() { { printf '%s\n' "$*" > /dev/tty; } 2>/dev/null || printf '%s\n' "$*"; }

SELECTED=""
if [ -n "${SACID_ONLY:-}" ]; then
    SELECTED="$(echo "$SACID_ONLY" | tr ',' ' ')"
else
    say ""
    say "Sacid plug-ins:"
    i=0
    while IFS='|' read -r name tag olds desc; do
        i=$((i + 1))
        mark=""
        if [ -e "$PLUGIN_DIR/$name.vst3" ]; then mark="  [installed]"; fi
        say "$(printf '  %d) %-13s %s%s' "$i" "$name" "$desc" "$mark")"
    done <<< "$(entries)"
    say ""
    while :; do
        { printf 'Which ones? Numbers like "1 3 5", Enter = all, q = quit: ' > /dev/tty; } 2>/dev/null || true
        if ! answer="$(ask)"; then answer=""; fi
        answer="$(echo "$answer" | tr ',' ' ' | tr -s ' ' | sed 's/^ //; s/ $//')"
        case "$answer" in
            q|Q|quit) say "Nothing installed."; exit 0 ;;
            ""|a|A|all) SELECTED="$(entries | cut -d'|' -f1 | tr '\n' ' ')"; break ;;
        esac
        ok=1; SELECTED=""
        for n in $answer; do
            case "$n" in
                *[!0-9]*|"") ok=0 ;;
                *) if [ "$n" -ge 1 ] && [ "$n" -le "$count" ]; then
                       SELECTED="$SELECTED $(entries | sed -n "${n}p" | cut -d'|' -f1)"
                   else ok=0; fi ;;
            esac
        done
        if [ "$ok" = 1 ] && [ -n "$SELECTED" ]; then break; fi
        say "  Please type numbers from 1 to $count, separated by spaces (or press Enter for all)."
        if [ -n "${SACID_ANSWER+set}" ]; then exit 1; fi   # a scripted wrong answer would loop forever
    done
fi
SELECTED="$(echo $SELECTED)"
say "Installing: $SELECTED"
# ---------------------------------------------------------------------------------------
[ -z "$SELECTED" ] && { say "Nothing selected."; exit 0; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
say "Installing into $DEST (macOS asks for your password once)."
$SUDO mkdir -p "$DEST" || exit 1

while IFS='|' read -r name tag olds desc; do
    case " $SELECTED " in *" $name "*) ;; *) continue ;; esac
    # Copies under earlier names are the same plug-in and would show up twice in Live.
    for old in $olds; do
        $SUDO rm -rf "$DEST/$old.vst3" "$HOME/Library/Audio/Plug-Ins/VST3/$old.vst3"
    done
    if ! curl -fsSL -o "$TMP/$name.zip" "$REPO/$tag/$name-macos.zip"; then
        say "  $name: download failed, skipped (try again in a few minutes)"
        continue
    fi
    mkdir -p "$TMP/$name"
    if command -v ditto >/dev/null; then ditto -x -k "$TMP/$name.zip" "$TMP/$name"; else unzip -q "$TMP/$name.zip" -d "$TMP/$name"; fi \
        || { say "  $name: unzip failed, skipped"; continue; }
    $SUDO rm -rf "$DEST/$name.vst3" "$HOME/Library/Audio/Plug-Ins/VST3/$name.vst3"   # one copy only
    $SUDO cp -R "$TMP/$name/$name.vst3" "$DEST/" && { $SUDO xattr -cr "$DEST/$name.vst3" 2>/dev/null || true; } && say "  $name: installed"
done <<< "$(entries)"

say ""
say "Done. In Ableton Live: Settings > Plug-Ins, turn on 'Use VST3 Plug-In System Folders',"
say "then hold Option and click Rescan. They're under Plug-Ins > VST3 > Sacid."
