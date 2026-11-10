#!/bin/bash
# Installs (or updates) the Sacid plug-ins you pick for the current user: plug-ins into
# ~/.vst3, the standalone apps into ~/.local/bin. No root needed.
#   curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-linux.sh | bash
# Unattended: SACID_ONLY="SacidOne SacidHalo" (or SACID_ANSWER="1 5") skips the question.
set -u
REPO="${SACID_REPO:-https://github.com/aleksandrsvoboda/sacid-plugins/releases/download}"
VST3="${SACID_DEST:-$HOME/.vst3}"
BIN="${SACID_BIN:-$HOME/.local/bin}"
PLUGIN_DIR="$VST3"
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
mkdir -p "$VST3" "$BIN" || exit 1

while IFS='|' read -r name tag olds desc; do
    case " $SELECTED " in *" $name "*) ;; *) continue ;; esac
    # Copies under earlier names are the same plug-in and would show up twice.
    for old in $olds; do rm -rf "$VST3/$old.vst3" "$BIN/$old"; done
    if ! curl -fsSL -o "$TMP/$name.tar.gz" "$REPO/$tag/$name-linux-x64.tar.gz"; then
        say "  $name: download failed, skipped (try again in a few minutes)"
        continue
    fi
    mkdir -p "$TMP/$name"
    tar -xzf "$TMP/$name.tar.gz" -C "$TMP/$name" || { say "  $name: unpack failed, skipped"; continue; }
    rm -rf "$VST3/$name.vst3"
    cp -R "$TMP/$name/$name.vst3" "$VST3/"
    if [ -f "$TMP/$name/$name" ]; then cp "$TMP/$name/$name" "$BIN/$name" && chmod +x "$BIN/$name"; fi
    say "  $name: installed"
done <<< "$(entries)"

say ""
say "Done. Plug-ins are in $VST3 - rescan plug-ins in your DAW."
say "The standalone apps are in $BIN (run e.g. SacidOne; add $BIN to PATH if it isn't)."
