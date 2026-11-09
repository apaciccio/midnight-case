#!/bin/bash
# build_android.sh - Midnight Case: build Android (.aab per Google Play) da Terminale
# Uso:  bash ~/midnight-case/build_android.sh            (release, firmato -> da caricare su Play)
#       bash ~/midnight-case/build_android.sh --debug    (apk di prova da installare sul telefono)
#
# PRIMA VOLTA (una tantum, poi lo script fa tutto da solo):
#   1. Android Studio installato (https://developer.android.com/studio) e aperto almeno una volta:
#      installa SDK in ~/Library/Android/sdk. In SDK Manager -> SDK Tools spunta
#      "Android SDK Command-line Tools" e "Android SDK Build-Tools".
#   2. Java 17:  brew install openjdk@17
#   3. Template di export di Godot: Godot -> Editor -> Manage Export Templates -> Download and Install
#   4. Keystore di firma (UNA SOLA VOLTA, poi CONSERVALO: senza, non potrai mai piu' aggiornare l'app):
#      lo crea questo script al primo avvio e ti chiede una password. SCRIVILA DA QUALCHE PARTE.
set -u
P="$HOME/midnight-case"
G="$HOME/Desktop/Godot.app/Contents/MacOS/Godot"
SDK="$HOME/Library/Android/sdk"
KS="$HOME/midnight-keys/midnight_upload.keystore"      # un solo keystore per tutta la serie
ALIAS="midnight"
OUT="$P/export/android"
MODE="${1:-}"

echo "== 1) controlli"
[ -x "$G" ] || { echo "ERRORE: non trovo Godot in $G"; exit 1; }
[ -d "$SDK" ] || { echo "ERRORE: non trovo l'Android SDK in $SDK (installa Android Studio e aprilo una volta)"; exit 1; }
JAVA_HOME_17="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
if [ -z "$JAVA_HOME_17" ]; then
  for c in /opt/homebrew/opt/openjdk@17 /usr/local/opt/openjdk@17; do [ -d "$c" ] && JAVA_HOME_17="$c"; done
fi
[ -n "$JAVA_HOME_17" ] || { echo "ERRORE: Java 17 non trovato. Esegui: brew install openjdk@17"; exit 1; }
export JAVA_HOME="$JAVA_HOME_17"
echo "   Godot ok, SDK ok, Java: $JAVA_HOME"
TPL="$HOME/Library/Application Support/Godot/export_templates/4.6.3.stable"
[ -f "$TPL/android_source.zip" ] || { echo "ERRORE: template di export mancanti. In Godot: Editor -> Manage Export Templates -> Download and Install"; exit 1; }
echo "   template 4.6.3 ok"

echo "== 2) impostazioni editor (percorso SDK e Java)"
ES="$HOME/Library/Application Support/Godot/editor_settings-4.6.tres"
mkdir -p "$(dirname "$ES")"
if [ ! -f "$ES" ]; then
  printf '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' > "$ES"
fi
# le chiavi vanno nella sezione [resource], che e' l'ultima del file: le aggiungo/aggiorno in coda
python3 - "$ES" "$SDK" "$JAVA_HOME" <<'PY'
import sys,re
p,sdk,java=sys.argv[1:]
s=open(p,encoding="utf-8").read()
for k,v in (("export/android/android_sdk_path",sdk),("export/android/java_sdk_path",java)):
    riga='%s = "%s"' % (k,v)
    if re.search(r'^%s\s*=' % re.escape(k), s, re.M):
        s=re.sub(r'^%s\s*=.*$' % re.escape(k), riga, s, flags=re.M)
    else:
        s=s.rstrip("\n")+"\n"+riga+"\n"
open(p,"w",encoding="utf-8").write(s)
PY
grep -q 'export/android/java_sdk_path = "' "$ES" && echo "   ok (SDK: $SDK, Java: $JAVA_HOME)" || { echo "ERRORE: impostazioni editor non scritte"; exit 1; }

echo "== 3) keystore di firma"
mkdir -p "$(dirname "$KS")"
if [ ! -f "$KS" ]; then
  echo "   Non esiste: lo creo adesso. Ti chiede una PASSWORD (scrivila da qualche parte!) e qualche dato (puoi lasciare vuoto)."
  "$JAVA_HOME/bin/keytool" -genkeypair -v -keystore "$KS" -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 || { echo "ERRORE: keystore non creato"; exit 1; }
  echo "   CREATO: $KS  -> fai subito una COPIA in un posto sicuro (iCloud/USB)."
fi
read -r -s -p "   password del keystore: " KSPASS; echo
echo "   keystore ok"

echo "== 4) progetto Android (gradle)"
TPL_FLAG=""
if [ ! -d "$P/android/build" ]; then
  echo "   manca: lo installo durante l'export"
  TPL_FLAG="--install-android-build-template"
fi

echo "== 5) export"
mkdir -p "$OUT"
"$G" --headless --import --path "$P" >/dev/null 2>&1
PRESET="$P/export_presets.cfg"
set_format() { python3 - "$PRESET" "$1" <<'PY'
import sys,re
p,v=sys.argv[1:]; s=open(p).read()
s=re.sub(r'^gradle_build/export_format=\d$', 'gradle_build/export_format=%s' % v, s, flags=re.M)
open(p,'w').write(s)
PY
}
if [ "$MODE" = "--debug" ]; then
  set_format 0            # 0 = APK (da installare sul telefono); il preset torna a 1 (AAB) alla fine
  trap 'set_format 1' EXIT
  "$G" --headless --path "$P" $TPL_FLAG --export-debug "Android" "$OUT/MidnightCase_debug.apk" > "$HOME/case_android_log.txt" 2>&1
  F="$OUT/MidnightCase_debug.apk"
else
  set_format 1
  export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$KS"
  export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$ALIAS"
  export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$KSPASS"
  "$G" --headless --path "$P" $TPL_FLAG --export-release "Android" "$OUT/MidnightCase.aab" > "$HOME/case_android_log.txt" 2>&1
  F="$OUT/MidnightCase.aab"
fi
if [ -f "$F" ]; then
  echo "   PRONTO: $F  ($(du -h "$F" | cut -f1))"
  [ "$MODE" = "--debug" ] && echo "   per provarlo sul telefono: collega il telefono (debug USB) e: $SDK/platform-tools/adb install -r \"$F\""
  [ "$MODE" != "--debug" ] && echo "   questo .aab lo carichi su Google Play Console -> Produzione (o Test interno) -> Crea release."
else
  echo "ERRORE: export fallito. Ultime righe del log ($HOME/case_android_log.txt):"; tail -25 "$HOME/case_android_log.txt"; exit 1
fi
