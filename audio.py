#!/usr/bin/env python3
# audio.py - mette i suoni generati al posto giusto, col nome giusto (gemello di verde.py)
#
# Uso:
#   python3 audio.py --gioco heist ~/Downloads/audio_heist/
#   python3 audio.py --gioco case  ~/Downloads/audio_case/
#   python3 audio.py --lista heist          (stampa la lista dei file attesi)
#
# Come chiamare i file scaricati: basta che il NOME contenga la parola chiave
# (es. "menu.mp3", "jazz menu loop.mp3" -> music_menu.mp3; "reel stop.wav" ->
# sfx_reel_stop.wav; "pre_cassa.mp3" -> sfx_pre_cassa.mp3). Le parole chiave
# sono quelle nella lista qui sotto (colonna "chiavi"). Formati: mp3, ogg, wav
# (il gioco li legge tutti e tre, nessuna conversione).
#
# Destinazione: ~/slot-mvp/assets/audio (heist) o ~/midnight-case/assets/audio (case).
# I file gia' presenti con lo stesso nome vengono sovrascritti (--no-sovrascrivi per evitarlo).
import os, sys, shutil, re

GIOCHI = {
    "heist": os.path.expanduser("~/slot-mvp/assets/audio"),
    "case":  os.path.expanduser("~/midnight-case/assets/audio"),
}

# nome file (senza estensione) -> parole chiave accettate nel nome del file scaricato
# ordine: le chiavi piu' specifiche PRIMA (es. "reel_stop" prima di "reel")
COMUNI = [
    ("music_menu",        ["music_menu", "menu"]),
    ("music_tension",     ["music_tension", "tension", "tensione"]),
    ("music_bonus",       ["music_bonus", "bonus_music", "bonusmusic", "freespin", "musica_bonus"]),
    ("music_base",        ["music_base", "base", "gioco", "gameplay"]),
    ("sfx_pre_colpo",     ["pre_colpo", "precolpo", "pre_fs", "prefs"]),
    ("sfx_pre_cassa",     ["pre_cassa", "precassa", "pre_caso", "precaso"]),
    ("sfx_bonus_unlock",  ["bonus_unlock", "bonusunlock", "apertura_bonus"]),
    ("sfx_cassaforte_apri",["cassaforte_apri", "cassaforte", "disco"]),
    ("sfx_sack_land",     ["sack_land", "sack", "sacco", "fascicolo"]),
    ("sfx_jackpot",       ["jackpot", "grand"]),
    ("sfx_bonus_unlock",  ["bonus_unlock"]),
    ("sfx_unlock",        ["unlock", "sblocco", "flash"]),
    ("sfx_nome",          ["nome", "timbro", "stamp"]),
    ("sfx_player",        ["player", "giocatore", "riff"]),
    ("sfx_reel_stop",     ["reel_stop", "reelstop", "stop"]),
    ("sfx_reel",          ["reel", "rulli", "rullo"]),
    ("sfx_spin",          ["spin"]),
    ("sfx_count",         ["count", "conteggio", "contatore"]),
    ("sfx_win_big",       ["win_big", "winbig", "big_win", "bigwin", "grande_vincita"]),
    ("sfx_win_small",     ["win_small", "winsmall", "small_win", "piccola_vincita"]),
    ("sfx_on",            ["sfx_on", "click", "tasto", "button"]),
    ("sfx_whoosh",        ["whoosh", "swoosh"]),
    ("sfx_anticipation",  ["anticipation", "suspense", "attesa"]),
    ("sfx_wild_espanso",  ["wild_espanso", "wild", "espanso"]),
    ("sfx_premium",       ["premium"]),
    ("sfx_battito",       ["battito", "heartbeat", "cuore"]),
]
# solo Heist (mini-giochi e indizi)
SOLO_HEIST = [
    ("sfx_tool",          ["tool", "attrezzo"]),
    ("sfx_pre_rosso",     ["pre_rosso", "rosso"]),
    ("sfx_pre_verde",     ["pre_verde", "verde"]),
    ("sfx_pre_blu",       ["pre_blu", "blu"]),
    ("sfx_polizia",       ["polizia", "police", "sirena"]),
    ("sfx_vetro",         ["vetro", "glass"]),
    ("sfx_esplosione",    ["esplosione", "explosion", "dinamite"]),
]

def lista(gioco):
    L = list(COMUNI) + (list(SOLO_HEIST) if gioco == "heist" else [])
    visti = set(); out = []
    for n, k in L:
        if n not in visti: visti.add(n); out.append((n, k))
    return out

def normalizza(nome):
    b = os.path.splitext(os.path.basename(nome))[0].lower()
    return re.sub(r"[^a-z0-9]+", "_", b)

def abbina(nomefile, gioco):
    b = normalizza(nomefile)
    for n, chiavi in lista(gioco):
        if b == n: return n
    for n, chiavi in lista(gioco):
        for k in chiavi:
            if k in b: return n
    return None

if __name__ == "__main__":
    a = sys.argv[1:]
    if "--lista" in a:
        g = a[a.index("--lista") + 1]
        print("File attesi per %s (nome -> parole chiave accettate):" % g)
        for n, k in lista(g): print("  %-22s <- %s" % (n, ", ".join(k)))
        sys.exit(0)
    if "--gioco" not in a:
        print("Uso: python3 audio.py --gioco heist|case CARTELLA_O_FILE [--no-sovrascrivi]"); sys.exit(1)
    gioco = a[a.index("--gioco") + 1]
    if gioco not in GIOCHI: print("gioco sconosciuto:", gioco); sys.exit(1)
    sovr = "--no-sovrascrivi" not in a
    src = [x for x in a if x not in ("--gioco", gioco, "--no-sovrascrivi")]
    files = []
    for s in src:
        s = os.path.expanduser(s)
        if os.path.isdir(s):
            files += [os.path.join(s, f) for f in sorted(os.listdir(s)) if f.lower().endswith((".mp3", ".ogg", ".wav"))]
        elif os.path.isfile(s): files.append(s)
    dest = GIOCHI[gioco]; os.makedirs(dest, exist_ok=True)
    fatti = {}; ignorati = []
    for f in files:
        n = abbina(f, gioco)
        if n is None: ignorati.append(os.path.basename(f)); continue
        ext = os.path.splitext(f)[1].lower()
        out = os.path.join(dest, n + ext)
        # se esiste con un'altra estensione, la tolgo (il gioco prende la prima che trova)
        for e in (".mp3", ".ogg", ".wav"):
            if e != ext and os.path.exists(os.path.join(dest, n + e)): os.remove(os.path.join(dest, n + e))
        if os.path.exists(out) and not sovr: print("  gia' presente, salto:", n + ext); continue
        shutil.copy2(f, out); fatti[n] = os.path.basename(f); print("  ok  %-22s <- %s" % (n + ext, os.path.basename(f)))
    if ignorati:
        print("\nNON riconosciuti (rinominali con una parola chiave):"); [print("   ", i) for i in ignorati]
    mancanti = [n for n, _ in lista(gioco) if not any(os.path.exists(os.path.join(dest, n + e)) for e in (".mp3", ".ogg", ".wav"))]
    print("\nInstallati ora: %d. Mancano ancora in %s:" % (len(fatti), dest))
    for m in mancanti: print("   ", m)
    if not mancanti: print("    (nessuno: audio completo)")
