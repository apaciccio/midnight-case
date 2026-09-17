# ==== INIZIO FILE: copia da questa riga in giu' ====
# slot_engine.gd - MOTORE v0.19-CASE (Midnight Case: SENZA INDIZI/ATTREZZI)
# Identico al motore v0.19 di Midnight Heist tranne: i tre attrezzi (TOOL_*)
# hanno peso 0 sui rulli, pioggia/sblocchi/supremo a probabilita' 0.
# CERTIFICAZIONE Midnight Case (motore_certificazione.py, stessi cambi, 30M giri):
# RTP 94.84% +/- 0.12 | linee 63.3 | Il Caso 16.4 | Inseguimento 14.9 | scatter 0.4
# Inseguimento ogni ~600 giri (8.3 giri medi), Il Caso ogni ~134, GRAND 1 ogni ~440k.
# Le costanti CARICA_PIENA/SCASSO/TAGLIO/RAPINA restano per compatibilita'
# del codice ma non vengono mai raggiunte.
# v0.19: il medaglione pieno garantisce lo sblocco (probabilita' che cresce
#   con la carica fino a 1). Nessun cambio all'EV di lungo periodo; da
#   ricertificare la sola distribuzione dell'attesa.
# v0.18.3: lavagna degli attrezzi separata PER LIVELLO DI PUNTATA e
#   salvata su disco (cambi puntata e torni: ritrovi la tua carica).
#   Nessun effetto sulla matematica (i trigger sono per pezzo).
# v0.18.2: la DEMO del Colpo mette le tre casseforti su rulli casuali
#   (solo estetica del tasto D; la matematica del gioco vero e' invariata).
# v0.18.1: SCASSO con premi grossi (20-50-100-200-300-500-750-1000) e
#   polizia piu' vicina (continua 28.0%): valore medio INVARIATO = 50
#   crediti (5x, forma chiusa), quindi RTP invariato. Max 292x.
# ================================================================
# RTP 94.800%  - certificato il 2026-09-04 con:
#   * enumerazione ESATTA delle linee base (WILD espanso, max una
#     cassaforte per rullo): 57.442% + scatter 0.335%
#   * Cassaforte 1/151 (EV 21.94x), Colpo 1/669 (EV 77.3x, 8.3 giri),
#     misurati con 300.000 / 150.000 eventi dedicati
#   * SCASSO 1/110 (EV 5.0x esatto, max 292x), TAGLIO 1/320 (EV 8.0x esatto),
#     RAPINA 1/1.279 (EV 21.79x, 300.000 eventi), SUPREMO 1/1.282
#   * verifica indipendente: simulazione completa del motore
#   Trigger: R 0.0318  G 0.0187  B 0.0122  (unica modifica dal v0.17.2)
#   Max vincita per giro: 5000x. Dev. std per spin ~7.4x (volatilita' alta).
#   DA QUI IN POI LA MATEMATICA NON SI TOCCA SENZA RICERTIFICARE.
# ================================================================
# Storico: v0.17.2 retrigger visibile | v0.17 Colpo Grande | v0.16 WILD
# espanso + fix WILD | v0.15 dinamite | v0.14 taglio | v0.12 scasso |
# v0.11 garanzia sacco | v0.10 max una cassaforte per rullo | v0.8-0.9
# Piano misterioso | v0.5 CASSA_LAND_P decrescente
class_name SlotEngine
extends RefCounted

static var lang := "it"   # non piu' usato (la lingua sta in Engine.get_meta("mh_lang"))

const INDIZI_ATTIVI := false   # Midnight Case: niente medaglioni/mini-giochi
const REELS := 5
const ROWS := 3
const NUM_LINES := 10
const LINE_BET := 1
const TOTAL_BET := NUM_LINES * LINE_BET

const SYMBOLS := {
	"GEM_RED":    [18.0,   10.8],
	"GEM_BLUE":   [18.0,   10.8],
	"GEM_GREEN":  [16.0,   9.6],
	"GEM_PURPLE": [12.0,   7.2],
	"CROWN":      [8.0,    4.0],
	"STAR":       [5.0,    2.5],
	"WILD":       [0.855,  0.15],    # espanso; nel Colpo APPICCICOSO
	"SCATTER":    [1.76,   1.10],   # CASE: era 1.731 in Heist (ribilancio senza indizi)
	"COIN":       [11.551, 3.0],     # nel Colpo: sacchi pagati subito x mult
	"TOOL_RED":   [0.0,    0.0],     # CASE: indizi spenti
	"TOOL_GREEN": [0.0,    0.0],
	"TOOL_BLUE":  [0.0,    0.0],
	"DINAMITE":   [0.0,    2.5],    # solo nei giri gratis: +1 al moltiplicatore
}

const PAYTABLE := {
	"GEM_RED":    {3: 6,  4: 21,  5: 70},
	"GEM_BLUE":   {3: 6,  4: 21,  5: 70},
	"GEM_GREEN":  {3: 7,  4: 34,  5: 110},
	"GEM_PURPLE": {3: 14, 4: 55,  5: 210},
	"CROWN":      {3: 28, 4: 115, 5: 450},
	"STAR":       {3: 58, 4: 230, 5: 1150},
	"WILD":       {3: 70, 4: 280, 5: 1400},
}

const SCATTER_PAY := {3: 2, 4: 10, 5: 50}
const FREESPINS_AWARD := {3: 8, 4: 12, 5: 20}
const FS_MULTIPLIER := 3
const FS_RETRIGGER := true

const WILD_MULT_VALUES := [1, 2, 3]
const WILD_MULT_WEIGHTS := [78.0, 17.0, 5.0]
const WILD_MULT_CAP := 27

# --- CASSAFORTE (Hold & Win) ---
const COIN_VALUES := [5, 10, 20, 30, 50, 100, 200, -1, -2, -3]
const COIN_WEIGHTS := [28.0, 27.0, 20.0, 12.0, 7.5, 2.3, 0.6, 1.9, 0.5, 0.08]
const JACKPOT_PAY := {-1: 50, -2: 200, -3: 1000}   # MINI / MINOR / MAJOR
const CASSA_TRIGGER := 6
const CASSA_RESPINS := 3
const CASSA_LAND_P0 := 0.0951      # probabilita' a bonus appena partito
const CASSA_EMPTY_REF := 9.0       # celle vuote al trigger minimo (15 - 6)
const CASSA_FULL_BONUS := 10000    # GRAND

# --- PIANO DEL COLPO ---
const PIANO_TRIGGER_P := {"TOOL_RED": 0.0, "TOOL_GREEN": 0.0, "TOOL_BLUE": 0.0}   # CASE: mai
# pezzi che riempiono il medaglione e garantiscono lo sblocco (pity timer)
const CARICA_PIENA := {"TOOL_RED": 40, "TOOL_GREEN": 70, "TOOL_BLUE": 110}
const SUPER_P := 0.0                # ogni sblocco: 6% di COLPO SUPREMO
const SHOWER_P := 0.0               # PIOGGIA DI ATTREZZI: 1 spin su 33
const SHOWER_MIX := {"TOOL_RED": 0.6, "TOOL_GREEN": 0.3, "TOOL_BLUE": 0.1}
const SCASSO_LADDER := [20, 50, 100, 200, 300, 500, 750, 1000]  # premi grossi, polizia vicina
const SCASSO_CONT_P := 0.28274    # prob. di continuare: EV = 50 (5x) ESATTO, max 292x
const FS_COIN_VALUES := [5, 10, 15, 20, 30, 50, 100]   # sacchi del Colpo (unita')
const FS_COIN_WEIGHTS := [30.0, 26.0, 18.0, 12.0, 8.0, 4.0, 2.0]
const MAX_WIN_X := 5000                                  # tetto vincita per giro
const TAGLIO_FRAMMENTI := 5
const TAGLIO_VALUES := [5, 8, 10, 15, 20, 30, 50]
const TAGLIO_WEIGHTS := [39.805, 26.0, 17.0, 10.0, 6.0, 2.5, 0.5]
const TAGLIO_MULT_VALUES := [1, 2, 3, 5]
const TAGLIO_MULT_WEIGHTS := [55.0, 28.0, 12.0, 5.0]
const RAPINA_START_SACKS := 6        # sblocco BLU: sacchi garantiti Rapina
const PIANO_SAVE_PATH := "user://piano_colpo.cfg"

const PAYLINES := [
	[1,1,1,1,1], [0,0,0,0,0], [2,2,2,2,2],
	[0,1,2,1,0], [2,1,0,1,2], [0,0,1,2,2],
	[2,2,1,0,0], [1,0,1,2,1], [1,2,1,0,1],
	[0,1,1,1,0],
]

var rng := RandomNumberGenerator.new()

# lavagna: attrezzi raccolti finora (caricata da disco all'avvio)
var lavagna := {"TOOL_RED": 0, "TOOL_GREEN": 0, "TOOL_BLUE": 0}
var forza_prossimo := ""   # DEMO: forza il prossimo esito (vuoto = gioco normale)

func _init() -> void:
	rng.randomize()
	_load_lavagna()

# ---------- PERSISTENZA LAVAGNA (una per livello di puntata) ----------
# Ogni livello di puntata ha i SUOI contatori: cambiando puntata si
# mette via la lavagna corrente e si riprende quella del nuovo livello.
# Tutto salvato su disco (user://), quindi sopravvive alla chiusura.
var lavagna_livello := 0    # indice del livello di puntata attivo

func _load_lavagna() -> void:
	var cf := ConfigFile.new()
	if cf.load(PIANO_SAVE_PATH) == OK:
		lavagna_livello = int(cf.get_value("piano", "livello", 0))
		for k in lavagna.keys():
			lavagna[k] = int(cf.get_value("piano_%d" % lavagna_livello, k, 0))

func _save_lavagna() -> void:
	var cf := ConfigFile.new()
	cf.load(PIANO_SAVE_PATH)   # tengo le lavagne degli altri livelli
	cf.set_value("piano", "livello", lavagna_livello)
	for k in lavagna.keys():
		cf.set_value("piano_%d" % lavagna_livello, k, lavagna[k])
	cf.save(PIANO_SAVE_PATH)

func _reset_lavagna() -> void:
	for k in lavagna.keys():
		lavagna[k] = 0

# chiamata dal main al cambio puntata: salva la lavagna del livello vecchio,
# carica quella del nuovo (zero se e' la prima volta)
func cambia_livello(nuovo: int) -> void:
	_save_lavagna()
	lavagna_livello = nuovo
	var cf := ConfigFile.new()
	_reset_lavagna()
	if cf.load(PIANO_SAVE_PATH) == OK:
		for k in lavagna.keys():
			lavagna[k] = int(cf.get_value("piano_%d" % lavagna_livello, k, 0))
	_save_lavagna()

# compatibilita': azzera solo il livello corrente
func azzera_lavagna() -> void:
	_reset_lavagna()
	_save_lavagna()

# ---------- ESTRAZIONE ----------

func _pick_symbol(fs_mode: bool) -> String:
	var idx := 1 if fs_mode else 0
	var total := 0.0
	for s in SYMBOLS:
		total += SYMBOLS[s][idx]
	var r := rng.randf() * total
	var acc := 0.0
	for s in SYMBOLS:
		acc += SYMBOLS[s][idx]
		if r <= acc:
			return s
	return "GEM_RED"

func _pick_weighted(values: Array, weights: Array) -> int:
	var total := 0.0
	for w in weights:
		total += w
	var r := rng.randf() * total
	var acc := 0.0
	for i in values.size():
		acc += weights[i]
		if r <= acc:
			return values[i]
	return values[values.size() - 1]

func _pick_wild_mult() -> int:
	var total := 0.0
	for w in WILD_MULT_WEIGHTS:
		total += w
	var r := rng.randf() * total
	var acc := 0.0
	for i in WILD_MULT_VALUES.size():
		acc += WILD_MULT_WEIGHTS[i]
		if r <= acc:
			return WILD_MULT_VALUES[i]
	return 1

func _pick_coin_value() -> int:
	var total := 0.0
	for w in COIN_WEIGHTS:
		total += w
	var r := rng.randf() * total
	var acc := 0.0
	for i in COIN_VALUES.size():
		acc += COIN_WEIGHTS[i]
		if r <= acc:
			return COIN_VALUES[i]
	return COIN_VALUES[0]

func spin_grid(fs_mode: bool = false) -> Dictionary:
	var grid: Array = []
	var mults: Array = []
	var coins: Array = []
	for reel in REELS:
		var column: Array = []
		var mcol: Array = []
		var ccol: Array = []
		var col_scatter := false
		for row in ROWS:
			var s := _pick_symbol(fs_mode)
			# massimo UNA maschera per rullo (regola da slot vera)
			while s == "SCATTER" and col_scatter:
				s = _pick_symbol(fs_mode)
			if s == "SCATTER":
				col_scatter = true
			column.append(s)
			mcol.append(_pick_wild_mult() if s == "WILD" else 1)
			ccol.append(_pick_coin_value() if s == "COIN" else 0)
		grid.append(column)
		mults.append(mcol)
		coins.append(ccol)
	# WILD ESPANSO: il primo WILD del rullo copre i simboli paganti col suo moltiplicatore
	var grid_pre: Array = []
	for reel in REELS:
		grid_pre.append(grid[reel].duplicate())
	var espansi: Array = []
	for reel in REELS:
		var wrow := -1
		for row in ROWS:
			if grid[reel][row] == "WILD":
				wrow = row
				break
		if wrow >= 0:
			var wm: int = mults[reel][wrow]
			var coperto := false
			for row in ROWS:
				var sym: String = grid[reel][row]
				if PAYTABLE.has(sym) and sym != "WILD":
					grid[reel][row] = "WILD"
					mults[reel][row] = wm
					coperto = true
				elif sym == "WILD":
					mults[reel][row] = wm
			if coperto:
				espansi.append(reel)
	return {"grid": grid, "mults": mults, "coins": coins, "grid_pre": grid_pre, "espansi": espansi}

# ---------- VALUTAZIONE LINEE ----------

func evaluate(grid: Array, mults: Array) -> Dictionary:
	var total_line_win := 0
	var line_hits: Array = []

	for li in PAYLINES.size():
		var line: Array = PAYLINES[li]
		var syms: Array = []
		for reel in REELS:
			syms.append(grid[reel][line[reel]])

		var base_sym := "WILD"
		for s in syms:
			if s != "WILD":
				base_sym = s
				break

		var wild_count := 0
		for s in syms:
			if s == "WILD":
				wild_count += 1
			else:
				break
		var wild_pay: int = PAYTABLE["WILD"].get(wild_count, 0)

		var count := 0
		var pay := 0
		if base_sym == "SCATTER" or base_sym == "COIN" or base_sym == "DINAMITE" or base_sym.begins_with("TOOL_"):
			# FIX: 3+ WILD prima di un simbolo speciale pagano come WILD
			if wild_pay <= 0:
				continue
		else:
			for s in syms:
				if s == base_sym or s == "WILD":
					count += 1
				else:
					break
			pay = PAYTABLE.get(base_sym, {}).get(count, 0)

		var best: int = max(pay, wild_pay)
		if best > 0:
			var used: int = count if pay >= wild_pay else wild_count
			var wmult := 1
			for reel in used:
				if grid[reel][line[reel]] == "WILD":
					wmult *= mults[reel][line[reel]]
			wmult = mini(wmult, WILD_MULT_CAP)
			var win: int = best * LINE_BET * wmult
			total_line_win += win
			line_hits.append({
				"line": li,
				"symbol": base_sym if pay >= wild_pay else "WILD",
				"count": used,
				"win": win,
				"wild_mult": wmult,
			})

	var n_scatter := 0
	for reel in grid:
		for s in reel:
			if s == "SCATTER":
				n_scatter += 1

	var scatter_win := 0
	if n_scatter >= 3:
		scatter_win = SCATTER_PAY[mini(n_scatter, 5)] * TOTAL_BET

	return {
		"line_win": total_line_win,
		"scatter_win": scatter_win,
		"n_scatter": n_scatter,
		"line_hits": line_hits,
	}

# ---------- CASSAFORTE (Hold & Win) ----------

# La probabilita' di atterraggio cala man mano che la griglia si riempie.
func _cassa_land_p(empty: int) -> float:
	return CASSA_LAND_P0 * (float(empty) / CASSA_EMPTY_REF)

func run_cassaforte(grid: Array, coins: Array) -> Dictionary:
	# board: valori dei sacchi bloccati (0 = cella vuota)
	var board: Array = []
	var n := 0
	for reel in REELS:
		var col: Array = []
		for row in ROWS:
			var v: int = coins[reel][row] if grid[reel][row] == "COIN" else 0
			if v != 0:
				n += 1
			col.append(v)
		board.append(col)
	return _run_holdwin(board, n, [])

# RAPINA PERFETTA: parte con RAPINA_START_SACKS sacchi in celle casuali.
# I sacchi garantiti arrivano come primo evento "landed", cosi' la UI
# li mostra atterrare uno a uno con la stessa animazione dei respin.
func run_rapina_perfetta() -> Dictionary:
	var board: Array = []
	for reel in REELS:
		var col: Array = []
		for row in ROWS:
			col.append(0)
		board.append(col)
	# celle casuali distinte
	var celle: Array = []
	for reel in REELS:
		for row in ROWS:
			celle.append([reel, row])
	celle.shuffle()
	var landed0: Array = []
	for i in RAPINA_START_SACKS:
		var c: Array = celle[i]
		var v := _pick_coin_value()
		board[c[0]][c[1]] = v
		landed0.append([c[0], c[1], v])
	var ev0 := {"landed": landed0, "respins_left": CASSA_RESPINS}
	return _run_holdwin(board, RAPINA_START_SACKS, [ev0])

# nucleo comune Cassaforte / Rapina
func _run_holdwin(board: Array, n_start: int, pre_events: Array) -> Dictionary:
	var events: Array = pre_events.duplicate()
	var n := n_start
	var respins := CASSA_RESPINS
	var safety := 0
	var landed_any := false
	while respins > 0 and n < 15 and safety < 200:
		safety += 1
		respins -= 1
		# la probabilita' si calcola UNA VOLTA a inizio respin
		var p_land := _cassa_land_p(15 - n)
		var landed: Array = []
		for reel in REELS:
			for row in ROWS:
				if board[reel][row] == 0 and rng.randf() < p_land:
					var v := _pick_coin_value()
					board[reel][row] = v
					n += 1
					landed.append([reel, row, v])
		# GARANZIA SACCO MINIMO: il bonus non muore mai a zero
		if landed.size() == 0 and respins == 0 and not landed_any and n < 15:
			var vuote: Array = []
			for reel in REELS:
				for row in ROWS:
					if board[reel][row] == 0:
						vuote.append([reel, row])
			var cg: Array = vuote[rng.randi_range(0, vuote.size() - 1)]
			var vg := _pick_coin_value()
			board[cg[0]][cg[1]] = vg
			n += 1
			landed.append([cg[0], cg[1], vg])
		if landed.size() > 0:
			respins = CASSA_RESPINS
			landed_any = true
		events.append({"landed": landed, "respins_left": respins})

	var total := 0
	for reel in REELS:
		for row in ROWS:
			var bv: int = board[reel][row]
			total += JACKPOT_PAY[bv] if bv < 0 else bv
	var full := (n == 15)
	if full:
		total += CASSA_FULL_BONUS

	return {"board": board, "events": events, "total": total, "full": full}

# ---------- SPIN COMPLETO ----------

func play_spin() -> Dictionary:
	var s := spin_grid(false)
	# DEMO: esiti forzati (solo dal tasto D del main)
	var forzati: Array = []   # [rullo, riga, simbolo] da mettere in griglia E in grid_pre
	if forza_prossimo == "colpo":
		# tre casseforti su rulli distinti a righe casuali (ordine diverso ogni volta)
		var rr := [0,1,2,3,4]; rr.shuffle()
		forzati = [[rr[0], rng.randi()%3, "SCATTER"], [rr[1], rng.randi()%3, "SCATTER"], [rr[2], rng.randi()%3, "SCATTER"]]
	elif forza_prossimo == "cassaforte":
		forzati = [[0,0,"COIN"],[1,2,"COIN"],[2,1,"COIN"],[3,0,"COIN"],[4,2,"COIN"],[1,0,"COIN"]]
	elif forza_prossimo == "scasso":
		forzati = [[2,1,"TOOL_RED"]]
	elif forza_prossimo == "accesso":
		forzati = [[2,1,"TOOL_GREEN"]]
	elif forza_prossimo == "rapina":
		forzati = [[2,1,"TOOL_BLUE"]]
	elif forza_prossimo == "supremo":
		forzati = [[1,1,"TOOL_RED"],[2,1,"TOOL_GREEN"],[3,1,"TOOL_BLUE"]]
	if forza_prossimo == "colpo":
		# via le casseforti cadute per caso: ne restano ESATTAMENTE tre, una per rullo
		for reel in REELS:
			for row in ROWS:
				if s["grid"][reel][row] == "SCATTER":
					s["grid"][reel][row] = "GEM_RED"
				if s["grid_pre"][reel][row] == "SCATTER":
					s["grid_pre"][reel][row] = "GEM_RED"
	for fz in forzati:
		s["grid"][fz[0]][fz[1]] = fz[2]
		s["grid_pre"][fz[0]][fz[1]] = fz[2]
		s["mults"][fz[0]][fz[1]] = 1
		if fz[2] == "COIN":
			s["coins"][fz[0]][fz[1]] = _pick_coin_value()
	if forzati.size() > 0:
		# le celle forzate non fanno parte di un rullo espanso
		var esp2: Array = []
		for r in s["espansi"]:
			var tocca := false
			for fz in forzati:
				if fz[0] == r: tocca = true
			if not tocca: esp2.append(r)
		s["espansi"] = esp2
	var res := evaluate(s["grid"], s["mults"])
	var result := {
		"grid": s["grid"],
		"mults": s["mults"],
		"coins": s["coins"],
		"grid_pre": s["grid_pre"],
		"espansi": s["espansi"],
		"base": res,
		"free_spins": [],
		"total_win": res["line_win"] + res["scatter_win"],
	}

	# CASSAFORTE
	var n_coins := 0
	for reel in REELS:
		for row in ROWS:
			if s["grid"][reel][row] == "COIN":
				n_coins += 1
	if n_coins >= CASSA_TRIGGER:
		var cassa := run_cassaforte(s["grid"], s["coins"])
		result["cassaforte"] = cassa
		result["total_win"] += cassa["total"]

	# FREE SPINS (Il Colpo)
	if res["n_scatter"] >= 3:
		var fs_left: int = FREESPINS_AWARD[mini(res["n_scatter"], 5)]
		var safety := 0
		var fs_mult := 1   # moltiplicatore progressivo del Colpo
		var sticky := {}   # rullo -> moltiplicatore della maschera appiccicata
		while fs_left > 0 and safety < 500:
			safety += 1
			fs_left -= 1
			var g := spin_grid(true)
			# MASCHERE APPICCICOSE: i rulli gia' espansi restano WILD (anche all'atterraggio)
			for reel in sticky.keys():
				for row in ROWS:
					var sym0: String = g["grid"][reel][row]
					if PAYTABLE.has(sym0):
						g["grid"][reel][row] = "WILD"
						g["grid_pre"][reel][row] = "WILD"
						g["mults"][reel][row] = sticky[reel]
			var esp_nuovi: Array = []
			for reel in g["espansi"]:
				if not sticky.has(reel):
					var wm := 1
					for row in ROWS:
						if g["grid"][reel][row] == "WILD":
							wm = g["mults"][reel][row]
							break
					sticky[reel] = wm
					esp_nuovi.append(reel)
			g["espansi"] = esp_nuovi
			var r := evaluate(g["grid"], g["mults"])
			# la DINAMITE fa saltare il moltiplicatore (vale gia' su questo giro)
			var n_din := 0
			for reel in REELS:
				for row in ROWS:
					if g["grid"][reel][row] == "DINAMITE":
						n_din += 1
			fs_mult += n_din
			# SACCHI NEL COLPO: valore dalla tabella dedicata, pagati subito x mult
			var coin_win := 0
			for reel in REELS:
				for row in ROWS:
					if g["grid"][reel][row] == "COIN":
						var cv: int = _pick_weighted(FS_COIN_VALUES, FS_COIN_WEIGHTS)
						g["coins"][reel][row] = cv
						coin_win += cv
			var fs_win: int = mini((r["line_win"] + r["scatter_win"] + coin_win) * fs_mult, MAX_WIN_X * TOTAL_BET)
			result["free_spins"].append({
				"grid": g["grid"], "mults": g["mults"], "coins": g["coins"],
				"result": r, "win": fs_win, "coin_win": coin_win * fs_mult,
				"mult": fs_mult, "dinamite": n_din,
				"grid_pre": g["grid_pre"], "espansi": g["espansi"],
				"sticky": sticky.keys(),
				"retrigger": (FREESPINS_AWARD[mini(r["n_scatter"], 5)] if (FS_RETRIGGER and r["n_scatter"] >= 3) else 0),
			})
			result["total_win"] += fs_win
			if FS_RETRIGGER and r["n_scatter"] >= 3:
				fs_left += FREESPINS_AWARD[mini(r["n_scatter"], 5)]

	# PIANO DEL COLPO "misterioso": pezzi da rulli, FREE SPIN e pioggia
	var tools_landed := {"TOOL_RED": 0, "TOOL_GREEN": 0, "TOOL_BLUE": 0}
	for reel in REELS:
		for row in ROWS:
			var sym: String = s["grid"][reel][row]
			if sym.begins_with("TOOL_"):
				tools_landed[sym] += 1
	# anche i giri gratis del Colpo raccolgono attrezzi
	for fs in result["free_spins"]:
		for reel in REELS:
			for row in ROWS:
				var symf: String = fs["grid"][reel][row]
				if symf.begins_with("TOOL_"):
					tools_landed[symf] += 1

	# PIOGGIA DI ATTREZZI: grappolo extra di un colore (non occupa celle)
	if rng.randf() < SHOWER_P or forza_prossimo == "pioggia":
		var colr := rng.randf()
		var ck := "TOOL_RED"
		if colr >= SHOWER_MIX["TOOL_RED"] + SHOWER_MIX["TOOL_GREEN"]:
			ck = "TOOL_BLUE"
		elif colr >= SHOWER_MIX["TOOL_RED"]:
			ck = "TOOL_GREEN"
		var extra := 3 + rng.randi_range(0, 4)
		tools_landed[ck] += extra
		result["pioggia"] = {"colore": ck, "pezzi": extra}

	var any_tool := false
	for k in tools_landed.keys():
		if tools_landed[k] > 0:
			any_tool = true
	result["lavagna_pre"] = lavagna.duplicate()
	result["tools_landed"] = tools_landed

	# accumulo + estrazione degli sblocchi (max uno per colore per spin)
	# PITY TIMER: piu' il medaglione e' carico, piu' sale la probabilita'.
	# A CARICA_PIENA[k] pezzi la probabilita' e' 1 (sblocco garantito): il
	# medaglione "pieno" NON resta mai bloccato. L'EV di lungo periodo non
	# cambia, cambia solo la distribuzione dell'attesa.
	var triggered: Array = []
	for k in tools_landed.keys():
		for i in tools_landed[k]:
			lavagna[k] += 1
			if not triggered.has(k):
				var base_p: float = PIANO_TRIGGER_P[k]
				var pieni: int = CARICA_PIENA[k]
				var frac: float = clampf(float(lavagna[k]) / float(pieni), 0.0, 1.0)
				# probabilita' che cresce: parte da base_p, arriva a 1 a carica piena
				var p: float = base_p + (1.0 - base_p) * pow(frac, 2.5)
				if lavagna[k] >= pieni or rng.randf() < p:
					triggered.append(k)

	# DEMO: esito ESATTO, senza sblocchi naturali ne' Supremo casuale
	if forza_prossimo == "scasso":
		triggered = ["TOOL_RED"]
	elif forza_prossimo == "accesso":
		triggered = ["TOOL_GREEN"]
	elif forza_prossimo == "rapina":
		triggered = ["TOOL_BLUE"]
	elif forza_prossimo == "supremo":
		triggered = ["TOOL_RED", "TOOL_GREEN", "TOOL_BLUE"]

	# COLPO SUPREMO: uno sblocco puo' trascinare tutti e tre
	if forza_prossimo == "" and triggered.size() > 0 and triggered.size() < 3 and rng.randf() < SUPER_P:
		triggered = ["TOOL_RED", "TOOL_GREEN", "TOOL_BLUE"]
		result["super"] = true
	if triggered.size() == 3:
		result["super"] = true

	if triggered.has("TOOL_GREEN"):
		lavagna["TOOL_GREEN"] = 0
		# IL TAGLIO DEL DIAMANTE: 5 frammenti x moltiplicatore
		var frammenti: Array = []
		var somma := 0
		for i in TAGLIO_FRAMMENTI:
			var v: int = _pick_weighted(TAGLIO_VALUES, TAGLIO_WEIGHTS)
			frammenti.append(v)
			somma += v
		var mult: int = _pick_weighted(TAGLIO_MULT_VALUES, TAGLIO_MULT_WEIGHTS)
		var tot_t := somma * mult
		result["taglio"] = {"frammenti": frammenti, "mult": mult, "total": tot_t}
		result["total_win"] += tot_t

	if triggered.has("TOOL_RED"):
		lavagna["TOOL_RED"] = 0
		# mini-gioco: apri casseforti finche' non arriva la polizia
		var picks: Array = []
		for i in SCASSO_LADDER.size():
			picks.append(SCASSO_LADDER[i])
			if i < SCASSO_LADDER.size() - 1 and rng.randf() >= SCASSO_CONT_P:
				break
		var scasso_tot := 0
		for pv in picks:
			scasso_tot += pv
		result["scasso"] = scasso_tot
		result["scasso_picks"] = picks
		result["total_win"] += scasso_tot


	if triggered.has("TOOL_BLUE"):
		lavagna["TOOL_BLUE"] = 0
		var rapina := run_rapina_perfetta()
		result["rapina"] = rapina
		result["total_win"] += rapina["total"]

	if any_tool:
		_save_lavagna()
	result["lavagna"] = lavagna.duplicate()
	forza_prossimo = ""

	return result
