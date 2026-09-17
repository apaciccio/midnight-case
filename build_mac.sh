#!/bin/bash
# build_mac.sh - Midnight Case: build DEBUG per Mac con log, a prova di errore
# Uso:  bash ~/Downloads/build_mac.sh
set -u
P="$HOME/midnight-case"
G="$HOME/Desktop/Godot.app/Contents/MacOS/Godot"
OUT="$P/export/mac"
LOG="$HOME/mc_log.txt"

echo "== 1) controllo progetto"
[ -f "$P/project.godot" ] || { echo "ERRORE: non trovo $P/project.godot"; exit 1; }
grep -q 'config/name="Midnight Case"' "$P/project.godot" || echo "ATTENZIONE: il project.godot non si chiama Midnight Case"
[ -x "$G" ] || { echo "ERRORE: non trovo Godot in $G"; exit 1; }

echo "== 2) file di gioco"
for f in main.gd menu.gd slot_engine.gd lang.gd; do
  [ -f "$P/$f" ] || { echo "ERRORE: manca $P/$f"; exit 1; }
  echo "   $f -> $(sed -n '2p' "$P/$f")"
done
# se in Downloads ci sono versioni piu' nuove di main/lang, le installo
for f in main lang slot_engine menu; do
  NEW="$(ls -t "$HOME/Downloads/$f"*.gd 2>/dev/null | head -1)"
  if [ -n "$NEW" ] && [ "$NEW" -nt "$P/$f.gd" ]; then
    cp -f "$NEW" "$P/$f.gd" && echo "   aggiornato $f.gd da Downloads -> $(sed -n '2p' "$P/$f.gd")"
  fi
done

echo "== 3) preset di export"
CFG="$P/export_presets.cfg"
if ! grep -q 'name="macOS"' "$CFG" 2>/dev/null; then
  echo "   preset macOS mancante: lo aggiungo"
  N=0
  grep -q '\[preset.0\]' "$CFG" 2>/dev/null && N=1
  cat >> "$CFG" << EOF

[preset.$N]

name="macOS"
platform="macOS"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="export/mac/MidnightCase.zip"
patches=PackedStringArray()
encryption_include_filters=""
encryption_exclude_filters=""
seed=0
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.$N.options]

export/distribution_type=0
binary_format/architecture="universal"
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=0
application/icon=""
application/bundle_identifier="it.ciccioapache.midnightheist"
application/app_category="Games"
application/min_macos_version_x86_64="10.12"
application/min_macos_version_arm64="11.00"
display/high_res=true
codesign/codesign=1
codesign/entitlements/app_sandbox/enabled=false
notarization/notarization=0
EOF
fi
echo "   preset macOS: presente"

echo "== 4) export DEBUG (headless, nessuna finestra)"
mkdir -p "$OUT"
rm -rf "$OUT/Midnight Case.app" "$OUT/MH_debug.zip"
"$G" --headless --path "$P" --export-debug "macOS" "$OUT/MH_debug.zip" > "$HOME/mh_export_log.txt" 2>&1
if [ ! -f "$OUT/MH_debug.zip" ]; then
  echo "ERRORE: export fallito. Ultime righe:"; tail -15 "$HOME/mh_export_log.txt"; exit 1
fi
cd "$OUT" && unzip -o -q MH_debug.zip && xattr -cr "Midnight Case.app"
echo "   app pronta: $OUT/Midnight Case.app"

echo "== 5) lancio il gioco (log in $LOG). Gioca; quando chiudi, stampo gli errori."
"$OUT/Midnight Case.app/Contents/MacOS/Midnight Case" > "$LOG" 2>&1
echo "== 6) esito"
if grep -q "handle_crash\|SCRIPT ERROR\|main.gd:" "$LOG"; then
  echo "   TROVATI errori:"; grep -n "main.gd\|SCRIPT ERROR\|handle_crash\|ERROR" "$LOG" | tail -30
else
  echo "   LOG PULITO: nessun errore di script, nessun crash."
fi
