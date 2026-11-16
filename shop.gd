# shop.gd - NEGOZIO MONETE (autoload "Shop") - v1.1
# Uguale per tutta la serie Midnight (Heist, Case, Elixir).
#
# COME FUNZIONA
# - Su Android con il plugin GodotGooglePlayBilling: acquisti VERI tramite
#   Google Play (pacchetti consumabili, si possono ricomprare).
# - Su iPhone/iPad con il plugin IOSInAppPurchase (hrk4649, StoreKit 2,
#   v0.3.0 per Godot 4.6): acquisti VERI tramite App Store (consumabili).
# - Su Mac/PC (editor o build desktop): modalita' PROVA, le monete arrivano
#   subito senza pagare, per collaudare il negozio.
# - Altrove: negozio "non disponibile".
# v1.1: aggiunto App Store (Modo.APPLE).
#
# LE MONETE NON SI PERDONO MAI
# Un acquisto riuscito viene prima SCRITTO su disco (monete "da incassare"),
# poi consumato su Google Play. Se l'app si chiude a meta', al riavvio
# Google lo ripropone e il token gia' registrato non viene contato due volte.
# Il gioco incassa con Shop.in_attesa() + Shop.segna_incassate() (all'avvio
# e quando arriva il segnale monete_arrivate).
#
# Le monete sono virtuali: non hanno valore reale e non si riscuotono.
extends Node

signal monete_arrivate(quante: int)      # c'e' qualcosa da incassare
signal prodotti_aggiornati                # prezzi caricati dallo store
signal messaggio(chiave: String)          # testo da mostrare (chiave di lang.gd)

# ID uguali su Google Play e App Store. Prezzo = solo etichetta di riserva:
# quello vero (in valuta locale) arriva dallo store.
const PACCHETTI := [
	{"id": "monete_10k", "monete": 10000, "prezzo": "0,99 €"},
	{"id": "monete_50k", "monete": 50000, "prezzo": "4,99 €"},
	{"id": "monete_150k", "monete": 150000, "prezzo": "9,99 €"},
	{"id": "monete_500k", "monete": 500000, "prezzo": "24,99 €"},
	{"id": "monete_2m", "monete": 2000000, "prezzo": "49,99 €"},
]

const SAVE_FILE := "user://midnight_acquisti.cfg"
const PLUGIN := "GodotGooglePlayBilling"
const PLUGIN_IOS := "IOSInAppPurchase"
const MAX_TOKEN := 200   # quanti token ricordare (bastano e avanzano)

enum Modo { NESSUNO, PROVA, PLAY, APPLE }
var modo: int = Modo.NESSUNO
var pronto := false                    # si puo' comprare adesso?
var prezzi := {}                       # id -> prezzo formattato dallo store
var acquisto_in_corso := false

var _client = null                     # BillingClient (solo su Android)
var _ios = null                        # singleton IOSInAppPurchase (iPhone)
var _da_incassare := 0
var _token_registrati: Array = []
var _tentativi_connessione := 0


func _ready() -> void:
	_carica()
	if Engine.has_singleton(PLUGIN):
		modo = Modo.PLAY
		_avvia_play()
	elif Engine.has_singleton(PLUGIN_IOS):
		modo = Modo.APPLE
		_avvia_apple()
	elif OS.has_feature("editor") or OS.has_feature("pc"):
		modo = Modo.PROVA
		pronto = true
	else:
		modo = Modo.NESSUNO
		pronto = false


# ---------------------------------------------------------------- API
func pacchetti() -> Array:
	return PACCHETTI

func prezzo(id: String) -> String:
	if prezzi.has(id):
		return prezzi[id]
	for p in PACCHETTI:
		if p["id"] == id:
			return p["prezzo"]
	return ""

func e_prova() -> bool:
	return modo == Modo.PROVA

func disponibile() -> bool:
	return modo != Modo.NESSUNO

# Monete in attesa di essere aggiunte al saldo (non le azzera).
func in_attesa() -> int:
	return _da_incassare

# Da chiamare DOPO aver aggiunto le monete al saldo e averlo salvato:
#   var n := Shop.in_attesa(); saldo += n; salva(); Shop.segna_incassate(n)
# (se l'app si chiude in mezzo, al massimo le monete arrivano due volte,
#  mai zero volte).
func segna_incassate(n: int) -> void:
	if n <= 0:
		return
	_da_incassare = maxi(0, _da_incassare - n)
	_salva()

func compra(id: String) -> void:
	if acquisto_in_corso:
		return
	var pk := _pacchetto(id)
	if pk.is_empty():
		return
	match modo:
		Modo.PROVA:
			acquisto_in_corso = true
			await get_tree().create_timer(0.4).timeout
			_registra("prova_%d_%d" % [Time.get_ticks_usec(), randi()], pk["monete"])
			acquisto_in_corso = false
			messaggio.emit("shop_ok")
		Modo.PLAY:
			if not pronto or _client == null:
				messaggio.emit("shop_non_pronto")
				_riconnetti()
				return
			var r: Dictionary = _client.purchase(id)
			if int(r.get("response_code", -99)) == 0:
				acquisto_in_corso = true   # l'esito arriva da on_purchase_updated
			else:
				messaggio.emit("shop_errore")
		Modo.APPLE:
			if _ios == null:
				messaggio.emit("shop_non_pronto")
				return
			if int(_ios.request("purchase", {"productID": id})) == 0:
				acquisto_in_corso = true   # l'esito arriva dal segnale response
			else:
				messaggio.emit("shop_errore")
		_:
			messaggio.emit("shop_non_disp")

# Ripristino (solo App Store): ripropone gli acquisti non ancora conclusi.
# I consumabili gia' incassati non tornano (e' normale: sono monete spese).
func ripristina() -> void:
	if modo == Modo.APPLE and _ios != null:
		_ios.request("proceedUnfinishedTransactions", {})


# ---------------------------------------------------------- App Store
# Il plugin risponde sempre col segnale response(nome, dati). Puo' arrivare
# da un thread di StoreKit: lo gestiamo con call_deferred sul thread giusto.
func _avvia_apple() -> void:
	_ios = Engine.get_singleton(PLUGIN_IOS)
	_ios.response.connect(func(nome, dati): _on_apple.call_deferred(str(nome), dati))
	_ios.request("startUpdateTask", {})               # acquisti fatti fuori dall'app
	_ios.request("products", {"productIDs": _ids_pacchetti()})
	_ios.request("proceedUnfinishedTransactions", {}) # acquisti rimasti a meta'

func _on_apple(nome: String, dati) -> void:
	if not (dati is Dictionary):
		return
	var esito := str(dati.get("result", ""))
	match nome:
		"products":
			if esito != "success":
				await get_tree().create_timer(5.0).timeout
				_ios.request("products", {"productIDs": _ids_pacchetti()})
				return
			for pr in dati.get("products", []):
				if pr is Dictionary:
					var pid := str(pr.get("id", ""))
					var fp := str(pr.get("displayPrice", ""))
					if pid != "" and fp != "":
						prezzi[pid] = fp
			pronto = true
			prodotti_aggiornati.emit()
		"purchase":
			acquisto_in_corso = false
			match esito:
				"success":
					_gestisci_apple(dati)
				"pending":
					messaggio.emit("shop_attesa")
				"userCancelled":
					messaggio.emit("shop_annullato")
				"revoked":
					pass   # rimborsato da Apple: niente monete
				_:
					messaggio.emit("shop_errore")

func _gestisci_apple(d: Dictionary) -> void:
	var pk := _pacchetto(str(d.get("productID", "")))
	if pk.is_empty():
		return
	# id della transazione dal JSON di StoreKit: serve a non contarla due volte
	var token := ""
	var j = JSON.parse_string(str(d.get("json", "")))
	if j is Dictionary:
		token = str(j.get("transactionId", j.get("transactionID", "")))
	if token == "" or token == "<null>":
		token = "ios_%s_%s" % [str(d.get("productID", "")), str(d.get("json", "")).hash()]
	token = "ios_" + token if not token.begins_with("ios_") else token
	if _token_registrati.has(token):
		return
	var q := maxi(1, int(str(d.get("purchasedQuantity", "1"))))
	_registra(token, int(pk["monete"]) * q)
	messaggio.emit("shop_ok")


# ---------------------------------------------------------- Google Play
func _avvia_play() -> void:
	# BillingClient e' lo script del plugin (addons/GodotGooglePlayBilling)
	var script_path := "res://addons/GodotGooglePlayBilling/BillingClient.gd"
	if not ResourceLoader.exists(script_path):
		modo = Modo.NESSUNO
		return
	_client = load(script_path).new()
	add_child(_client)
	_client.connected.connect(_on_connesso)
	_client.disconnected.connect(_on_disconnesso)
	_client.connect_error.connect(_on_errore_connessione)
	_client.query_product_details_response.connect(_on_dettagli)
	_client.query_purchases_response.connect(_on_acquisti_esistenti)
	_client.on_purchase_updated.connect(_on_acquisto)
	_client.consume_purchase_response.connect(_on_consumato)
	_client.start_connection()

func _riconnetti() -> void:
	if _client == null:
		return
	if _tentativi_connessione > 5:
		return
	_tentativi_connessione += 1
	_client.start_connection()

func _on_connesso() -> void:
	_tentativi_connessione = 0
	var ids := PackedStringArray()
	for p in _ids_pacchetti():
		ids.append(p)
	_client.query_product_details(ids, 0)   # 0 = INAPP
	_client.query_purchases(0)              # recupera acquisti non consumati

func _on_disconnesso() -> void:
	pronto = false

func _on_errore_connessione(_codice: int, _msg: String) -> void:
	pronto = false

func _on_dettagli(r: Dictionary) -> void:
	if int(r.get("response_code", -1)) != 0:
		return
	for d in r.get("product_details", []):
		var id: String = str(d.get("product_id", ""))
		var offerte = d.get("one_time_purchase_offer_details_list", null)
		if offerte is Array and not offerte.is_empty():
			var fp := str(offerte[0].get("formatted_price", ""))
			if fp != "":
				prezzi[id] = fp
	pronto = true
	prodotti_aggiornati.emit()

func _on_acquisti_esistenti(r: Dictionary) -> void:
	if int(r.get("response_code", -1)) != 0:
		return
	for p in r.get("purchases", []):
		_gestisci(p)

func _on_acquisto(r: Dictionary) -> void:
	acquisto_in_corso = false
	var codice := int(r.get("response_code", -1))
	if codice == 0:
		for p in r.get("purchases", []):
			_gestisci(p)
	elif codice == 1:
		messaggio.emit("shop_annullato")
	elif codice == 7:
		# gia' posseduto: c'e' un acquisto non consumato, lo recuperiamo
		_client.query_purchases(0)
	else:
		messaggio.emit("shop_errore")

func _gestisci(p: Dictionary) -> void:
	var stato := int(p.get("purchase_state", 0))
	var token := str(p.get("purchase_token", ""))
	if token == "":
		return
	if stato == 2:            # PENDING: pagamento non ancora concluso
		messaggio.emit("shop_attesa")
		return
	if stato != 1:            # non PURCHASED
		return
	var monete := 0
	for id in p.get("product_ids", []):
		var pk := _pacchetto(str(id))
		if not pk.is_empty():
			monete += int(pk["monete"]) * maxi(1, int(p.get("quantity", 1)))
	if monete <= 0:
		return
	if not _token_registrati.has(token):
		_registra(token, monete)      # PRIMA salvo le monete...
		messaggio.emit("shop_ok")
	_client.consume_purchase(token)  # ...POI consumo (ripetibile senza danni)

func _on_consumato(_r: Dictionary) -> void:
	pass   # se fallisce, l'acquisto ricompare al prossimo avvio e si riconsuma


# ---------------------------------------------------------- interni
func _ids_pacchetti() -> Array:
	var a: Array = []
	for p in PACCHETTI:
		a.append(p["id"])
	return a

func _pacchetto(id: String) -> Dictionary:
	for p in PACCHETTI:
		if p["id"] == id:
			return p
	return {}

func _registra(token: String, monete: int) -> void:
	_token_registrati.append(token)
	while _token_registrati.size() > MAX_TOKEN:
		_token_registrati.pop_front()
	_da_incassare += monete
	_salva()
	monete_arrivate.emit(monete)

func _salva() -> void:
	var cf := ConfigFile.new()
	cf.set_value("acquisti", "da_incassare", _da_incassare)
	cf.set_value("acquisti", "token", _token_registrati)
	cf.save(SAVE_FILE)

func _carica() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_FILE) == OK:
		_da_incassare = maxi(0, int(cf.get_value("acquisti", "da_incassare", 0)))
		var t = cf.get_value("acquisti", "token", [])
		_token_registrati = t if t is Array else []
