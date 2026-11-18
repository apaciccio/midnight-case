extends SceneTree
# Collaudo cambio lingua con TOCCHI VERI (eventi di input, come sul telefono)
# per 60 s: tocca il tasto lingua, sceglie una lingua, poi verifica che i tasti
# rispondano ancora (riapre l'elenco e lo richiude toccando fuori).
# Uso: godot --headless --path . -s res://test_lingua.gd
var menu
var cambi := 0
var errori := 0
var muti := 0          # volte in cui un tasto non ha risposto

func _initialize() -> void:
	_run()

func _tocca(c: Control) -> void:
	var p: Vector2 = root.get_final_transform() * (c.get_global_rect().get_center())
	for premuto in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = premuto
		e.position = p
		e.global_position = p
		root.push_input(e)
		await process_frame

func _tocca_punto(v: Vector2) -> void:
	var p: Vector2 = root.get_final_transform() * v
	for premuto in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = premuto
		e.position = p
		e.global_position = p
		root.push_input(e)
		await process_frame

func _tasto() -> Button:
	var t = menu.get_node_or_null("TastoLingua")
	if t != null and not t.is_queued_for_deletion(): return t
	return null

func _elenco() -> Control:
	var e = menu.get_node_or_null("SceltaLingua")
	if e != null and not e.is_queued_for_deletion(): return e
	return null

func _run() -> void:
	await process_frame
	menu = load("res://menu.tscn").instantiate()
	root.add_child(menu)
	await create_timer(0.5).timeout
	var t0 := Time.get_ticks_msec()
	var lingue: Array = Lingue.LINGUE
	while Time.get_ticks_msec() - t0 < 60000:
		var t := _tasto()
		if t == null:
			await process_frame; continue
		await _tocca(t)
		var el := _elenco()
		if el == null:
			muti += 1; await process_frame; continue
		var code: String = lingue[randi() % lingue.size()]
		var scelto: Button = null
		for b in el.get_child(0).get_children():
			if b is Button and b.text == Lingue.NOMI[code]: scelto = b
		await _tocca(scelto)
		if randf() < 0.3 and is_instance_valid(scelto): await _tocca(scelto)   # doppio tocco
		for k in 3: await process_frame
		cambi += 1
		var t2 := _tasto()
		if t2 == null or t2.text != Lingue.NOMI[code]:
			errori += 1; print("lingua non cambiata: ", code); continue
		# i tasti rispondono ancora? apro l'elenco e lo chiudo toccando fuori
		await _tocca(t2)
		if _elenco() == null:
			muti += 1; continue
		await _tocca_punto(Vector2(900, 300))
		await process_frame
		if _elenco() != null:
			muti += 1
	print("CAMBI=", cambi, " TASTI_MUTI=", muti, " LINGUA=", Lingue.attiva())
	errori += muti
	print("ERRORI=", errori)
	quit(0 if errori == 0 else 1)
