# shop_panel.gd - FINESTRA DEL NEGOZIO MONETE - v2.0 (uguale per Heist/Case/Elixir)
# v2.0: grafica nuova (pile di monete disegnate, etichetta "MIGLIOR VALORE",
#   tasti prezzo luminosi) + SCHERMATA DI ESITO dopo ogni acquisto:
#   riuscito (verde, monete che piovono), non riuscito (rosso, tasto RIPROVA),
#   annullato (grigio), in attesa (ambra). Si chiude con OK / X / tocco fuori.
# I testi sono in lang.gd (chiavi shop_*). Segnale "chiuso" quando sparisce.
extends Control

signal chiuso

const VW := 1152.0
const VH := 648.0
const ORO := Color("#e3b04b")
const ORO_CHIARO := Color("#ffe9a8")
const ORO_SCURO := Color("#8a6420")
const SCURO := Color("#140d05")
const VERDE := Color("#3ccf6e")
const ROSSO := Color("#e0503f")
const AMBRA := Color("#f2a93b")
const GRIGIO := Color("#9a8f80")

var _msg: Label
var _bottoni := {}       # id -> Button
var _pannello: Panel
var _esito: Control = null
var _ultimo_id := ""     # pacchetto dell'ultimo acquisto tentato
var shop: Node = null    # autoload /root/Shop (preso a runtime)


# moneta disegnata (niente immagini: va bene per tutte e tre le slot)
class Moneta extends Control:
	var r := 14.0
	func _draw() -> void:
		var c := size / 2.0
		draw_circle(c + Vector2(0, 2), r, Color(0, 0, 0, 0.45))
		draw_circle(c, r, Color("#b8862a"))
		draw_circle(c, r - 2.0, Color("#f3c75a"))
		draw_circle(c, r - 5.0, Color("#e3a93c"))
		draw_arc(c, r - 5.0, PI * 1.1, PI * 1.7, 12, Color("#fff1b8"), 2.0)
		draw_circle(c + Vector2(-r * 0.35, -r * 0.35), r * 0.16, Color(1, 1, 1, 0.55))


# simbolo dell'esito: spunta, croce, orologio, linea
class Icona extends Control:
	var tipo := "ok"
	var col := Color.WHITE
	func _draw() -> void:
		var c := size / 2.0
		var r: float = min(size.x, size.y) / 2.0
		draw_circle(c, r, col.darkened(0.55))
		draw_circle(c, r - 5.0, col)
		var w := 9.0
		var k := Color("#1a1208")
		match tipo:
			"ok":
				draw_polyline(PackedVector2Array([c + Vector2(-r * 0.42, 0), c + Vector2(-r * 0.1, r * 0.32), c + Vector2(r * 0.45, -r * 0.33)]), k, w, true)
			"ko":
				draw_line(c + Vector2(-r * 0.35, -r * 0.35), c + Vector2(r * 0.35, r * 0.35), k, w, true)
				draw_line(c + Vector2(r * 0.35, -r * 0.35), c + Vector2(-r * 0.35, r * 0.35), k, w, true)
			"attesa":
				draw_arc(c, r * 0.5, 0, TAU, 32, k, 6.0, true)
				draw_line(c, c + Vector2(0, -r * 0.34), k, 6.0, true)
				draw_line(c, c + Vector2(r * 0.25, 0), k, 6.0, true)
			_:
				draw_line(c + Vector2(-r * 0.4, 0), c + Vector2(r * 0.4, 0), k, w, true)


func _T(k: String) -> String:
	return Lingue.t(k, Lingue.attiva())


func _ready() -> void:
	shop = get_node_or_null("/root/Shop")
	z_index = 200
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(VW, VH)
	position = Vector2.ZERO

	var velo := ColorRect.new()
	velo.color = Color(0, 0, 0, 0.74)
	velo.size = Vector2(VW, VH)
	velo.mouse_filter = Control.MOUSE_FILTER_STOP
	velo.gui_input.connect(func(ev: InputEvent):
		if (ev is InputEventMouseButton and ev.pressed) or (ev is InputEventScreenTouch and ev.pressed):
			chiudi())
	add_child(velo)

	var w := 620.0
	var h := 590.0
	_pannello = Panel.new()
	_pannello.size = Vector2(w, h)
	_pannello.position = Vector2((VW - w) / 2.0, (VH - h) / 2.0)
	_pannello.pivot_offset = _pannello.size / 2.0
	_pannello.mouse_filter = Control.MOUSE_FILTER_STOP
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#1a1107")
	sb.border_color = ORO
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(24)
	sb.shadow_color = Color(0.89, 0.69, 0.29, 0.28)
	sb.shadow_size = 22
	_pannello.add_theme_stylebox_override("panel", sb)
	add_child(_pannello)

	# fascia del titolo
	var fascia := Panel.new()
	fascia.size = Vector2(w - 24, 64)
	fascia.position = Vector2(12, 12)
	fascia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sf := StyleBoxFlat.new()
	sf.bg_color = Color("#2e1f0b")
	sf.border_color = ORO_SCURO
	sf.border_width_bottom = 2
	sf.set_corner_radius_all(18)
	fascia.add_theme_stylebox_override("panel", sf)
	_pannello.add_child(fascia)

	var titolo := _etichetta(_T("shop_titolo"), 34, ORO_CHIARO)
	titolo.size = Vector2(w, 64)
	titolo.position = Vector2(0, 12)
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titolo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pannello.add_child(titolo)
	for lato in [-1.0, 1.0]:
		var m := Moneta.new()
		m.r = 15.0
		m.size = Vector2(36, 36)
		m.position = Vector2(w / 2.0 + lato * 205.0 - 18.0, 26)
		m.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pannello.add_child(m)

	var x := Button.new()
	x.text = "✕"
	x.size = Vector2(48, 48)
	x.position = Vector2(w - 62, 20)
	x.add_theme_font_size_override("font_size", 24)
	x.flat = true
	x.focus_mode = Control.FOCUS_NONE
	x.add_theme_color_override("font_color", ORO_CHIARO)
	x.add_theme_color_override("font_hover_color", Color.WHITE)
	x.pressed.connect(chiudi)
	_pannello.add_child(x)

	var paks: Array = shop.pacchetti() if shop != null else []
	var y := 90.0
	for i in paks.size():
		var pk: Dictionary = paks[i]
		var migliore: bool = i == paks.size() - 1
		var riga := Panel.new()
		riga.size = Vector2(w - 48, 68)
		riga.position = Vector2(24, y)
		riga.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sr := StyleBoxFlat.new()
		sr.bg_color = Color("#3a2810") if migliore else Color("#271a0a")
		sr.border_color = ORO if migliore else Color("#5e4219")
		sr.set_border_width_all(3 if migliore else 2)
		sr.set_corner_radius_all(16)
		riga.add_theme_stylebox_override("panel", sr)
		_pannello.add_child(riga)

		# pila di monete: piu' alta per i pacchetti piu' grandi
		var pila := Control.new()
		pila.position = Vector2(14, 6)
		pila.size = Vector2(70, 56)
		pila.mouse_filter = Control.MOUSE_FILTER_IGNORE
		riga.add_child(pila)
		for k in i + 1:
			var mo := Moneta.new()
			mo.r = 13.0
			mo.size = Vector2(30, 30)
			var col := k % 3
			var liv := k / 3
			mo.position = Vector2(4 + col * 16, 22 - liv * 9 - (col % 2) * 4)
			mo.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pila.add_child(mo)

		var lab := _etichetta(migliaia(int(pk["monete"])), 28, ORO_CHIARO)
		lab.position = Vector2(92, 4)
		lab.size = Vector2(240, 40)
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		riga.add_child(lab)
		var sub := _etichetta(_T("monete").to_upper(), 14, Color("#c9a86a"))
		sub.position = Vector2(94, 40)
		sub.size = Vector2(200, 20)
		riga.add_child(sub)

		if migliore:
			var tag := Panel.new()
			tag.position = Vector2(232, 20)
			tag.size = Vector2(130, 28)
			tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var st := StyleBoxFlat.new()
			st.bg_color = Color("#c0392b")
			st.set_corner_radius_all(14)
			tag.add_theme_stylebox_override("panel", st)
			riga.add_child(tag)
			var tl := _etichetta(_T("shop_miglior"), 13, Color.WHITE)
			tl.size = tag.size
			tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			tag.add_child(tl)

		var b := Button.new()
		b.size = Vector2(176, 50)
		b.position = Vector2(riga.size.x - 188, 9)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 23)
		var sn := StyleBoxFlat.new()
		sn.bg_color = ORO
		sn.border_color = ORO_CHIARO
		sn.border_width_top = 2
		sn.border_width_bottom = 4
		sn.border_color = Color("#a8782a")
		sn.set_corner_radius_all(14)
		var sh := sn.duplicate(); sh.bg_color = ORO_CHIARO
		var sp := sn.duplicate(); sp.bg_color = Color("#d39a35"); sp.border_width_bottom = 1
		var sd := sn.duplicate(); sd.bg_color = Color("#5b4c33"); sd.border_color = Color("#3d3222")
		b.add_theme_stylebox_override("normal", sn)
		b.add_theme_stylebox_override("hover", sh)
		b.add_theme_stylebox_override("pressed", sp)
		b.add_theme_stylebox_override("disabled", sd)
		b.add_theme_color_override("font_color", SCURO)
		b.add_theme_color_override("font_hover_color", SCURO)
		b.add_theme_color_override("font_pressed_color", SCURO)
		b.add_theme_color_override("font_disabled_color", Color("#a99a80"))
		var id: String = pk["id"]
		b.pressed.connect(func(): _compra(id))
		riga.add_child(b)
		_bottoni[id] = b
		y += 76.0

	_msg = _etichetta("", 19, Color("#ffd27a"))
	_msg.size = Vector2(w - 40, 28)
	_msg.position = Vector2(20, y + 2)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pannello.add_child(_msg)

	var nota := _etichetta(_T("shop_nota"), 14, Color("#a8957a"))
	nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nota.custom_minimum_size = Vector2(w - 60, 0)
	nota.size = Vector2(w - 60, 40)
	nota.position = Vector2(30, h - 50)
	_pannello.add_child(nota)

	if shop != null:
		shop.prodotti_aggiornati.connect(_aggiorna)
		shop.messaggio.connect(_on_messaggio)
	_aggiorna()
	if shop != null and shop.e_prova():
		_msg.text = _T("shop_prova")
	elif shop == null or not shop.disponibile():
		_msg.text = _T("shop_non_disp")

	# entrata: dissolvenza + piccolo rimbalzo del pannello
	modulate.a = 0.0
	_pannello.scale = Vector2(0.92, 0.92)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.16)
	tw.tween_property(_pannello, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _aggiorna() -> void:
	var attivi: bool = shop != null and shop.disponibile() and not shop.acquisto_in_corso
	for id in _bottoni.keys():
		var b: Button = _bottoni[id]
		b.text = shop.prezzo(id) if shop != null else ""
		b.disabled = not attivi


func _compra(id: String) -> void:
	if shop == null or shop.acquisto_in_corso or _esito != null:
		return
	_ultimo_id = id
	_msg.text = _T("shop_attendi")
	shop.compra(id)
	_aggiorna()


func _on_messaggio(chiave: String) -> void:
	if not is_instance_valid(_msg):
		return
	_aggiorna()
	match chiave:
		"shop_ok":
			_mostra_esito("ok")
		"shop_errore", "shop_non_pronto":
			_mostra_esito("ko")
		"shop_annullato":
			_mostra_esito("annullato")
		"shop_attesa":
			_mostra_esito("attesa")
		_:
			_msg.text = _T(chiave)


# ------------------------------------------------ schermata di esito
func _mostra_esito(tipo: String) -> void:
	_msg.text = ""
	if _esito != null and is_instance_valid(_esito):
		_esito.queue_free()
	var w := _pannello.size.x
	var h := _pannello.size.y
	_esito = Panel.new()
	_esito.size = _pannello.size
	_esito.mouse_filter = Control.MOUSE_FILTER_STOP
	_esito.clip_contents = true
	var se := StyleBoxFlat.new()
	se.bg_color = Color("#140d05")
	se.set_corner_radius_all(24)
	_esito.add_theme_stylebox_override("panel", se)
	_pannello.add_child(_esito)

	var col := VERDE
	var titolo := _T("shop_ok_t")
	var testo := _T("shop_ok")
	match tipo:
		"ok":
			var pk: Dictionary = _pacchetto(_ultimo_id)
			if not pk.is_empty():
				testo = _T("shop_aggiunte") % migliaia(int(pk["monete"]))
		"ko":
			col = ROSSO
			titolo = _T("shop_ko_t")
			testo = _T("shop_ko_sub")
		"annullato":
			col = GRIGIO
			titolo = _T("shop_annullato")
			testo = _T("shop_annullato_sub")
		"attesa":
			col = AMBRA
			titolo = _T("shop_attesa_t")
			testo = _T("shop_attesa")

	var ic := Icona.new()
	ic.tipo = tipo
	ic.col = col
	ic.size = Vector2(120, 120)
	ic.position = Vector2((w - 120) / 2.0, 92)
	ic.pivot_offset = ic.size / 2.0
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_esito.add_child(ic)

	var t := _etichetta(titolo, 34, col.lightened(0.25))
	t.size = Vector2(w - 40, 50)
	t.position = Vector2(20, 236)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_esito.add_child(t)

	var d := _etichetta(testo, 21, ORO_CHIARO)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d.custom_minimum_size = Vector2(w - 100, 0)
	d.size = Vector2(w - 100, 80)
	d.position = Vector2(50, 294)
	_esito.add_child(d)

	# tasti: OK (e RIPROVA se e' fallito)
	var tasti: Array = [["shop_ok_btn", true]]
	if tipo == "ko" and _ultimo_id != "":
		tasti = [["shop_riprova", false], ["shop_ok_btn", true]]
	var bw := 190.0
	var gap := 24.0
	var tot := bw * tasti.size() + gap * (tasti.size() - 1)
	var bx := (w - tot) / 2.0
	for tt in tasti:
		var b := Button.new()
		b.text = _T(tt[0])
		b.size = Vector2(bw, 56)
		b.position = Vector2(bx, h - 150)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 24)
		var s := StyleBoxFlat.new()
		s.bg_color = ORO if tt[1] else Color("#3a2810")
		s.border_color = ORO_CHIARO if tt[1] else ORO
		s.set_border_width_all(2)
		s.set_corner_radius_all(16)
		var s2 := s.duplicate(); s2.bg_color = ORO_CHIARO if tt[1] else Color("#523a17")
		b.add_theme_stylebox_override("normal", s)
		b.add_theme_stylebox_override("hover", s2)
		b.add_theme_stylebox_override("pressed", s2)
		var fc := SCURO if tt[1] else ORO_CHIARO
		b.add_theme_color_override("font_color", fc)
		b.add_theme_color_override("font_hover_color", fc)
		b.add_theme_color_override("font_pressed_color", fc)
		if tt[1]:
			b.pressed.connect(_chiudi_esito if tipo != "ok" else chiudi)
		else:
			var rid := _ultimo_id
			b.pressed.connect(func():
				_chiudi_esito()
				_compra(rid))
		_esito.add_child(b)
		bx += bw + gap

	# animazioni: comparsa e "pop" dell'icona
	_esito.modulate.a = 0.0
	ic.scale = Vector2(0.3, 0.3)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_esito, "modulate:a", 1.0, 0.14)
	tw.tween_property(ic, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if tipo == "ok":
		_pioggia_monete(_esito)
	elif tipo == "ko":
		var tw2 := create_tween()
		for dx in [12.0, -10.0, 7.0, -4.0, 0.0]:
			tw2.tween_property(ic, "position:x", (w - 120) / 2.0 + dx, 0.05)

func _chiudi_esito() -> void:
	if _esito != null and is_instance_valid(_esito):
		_esito.queue_free()
	_esito = null
	_aggiorna()
	if shop != null and shop.e_prova():
		_msg.text = _T("shop_prova")

func _pioggia_monete(dove: Control) -> void:
	var w := dove.size.x
	for i in 18:
		var m := Moneta.new()
		m.r = randf_range(8.0, 13.0)
		m.size = Vector2(30, 30)
		m.mouse_filter = Control.MOUSE_FILTER_IGNORE
		m.position = Vector2(randf_range(30, w - 60), randf_range(-60, -10))
		m.modulate.a = 0.0
		dove.add_child(m)
		var tw := m.create_tween()
		tw.tween_interval(randf_range(0.0, 0.5))
		tw.tween_property(m, "modulate:a", 1.0, 0.08)
		tw.parallel().tween_property(m, "position:y", randf_range(160, 420), randf_range(0.7, 1.2)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(m, "modulate:a", 0.0, 0.25)
		tw.tween_callback(m.queue_free)

func _pacchetto(id: String) -> Dictionary:
	if shop == null:
		return {}
	for p in shop.pacchetti():
		if p["id"] == id:
			return p
	return {}


func chiudi() -> void:
	if shop != null:
		if shop.prodotti_aggiornati.is_connected(_aggiorna):
			shop.prodotti_aggiornati.disconnect(_aggiorna)
		if shop.messaggio.is_connected(_on_messaggio):
			shop.messaggio.disconnect(_on_messaggio)
	chiuso.emit()
	queue_free()


func _etichetta(testo: String, dim: int, col: Color) -> Label:
	var l := Label.new()
	l.text = testo
	l.add_theme_font_size_override("font_size", dim)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func migliaia(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "." + out
	return out
