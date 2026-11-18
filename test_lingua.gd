extends SceneTree
# Collaudo cambio lingua nel menu + raffica di click (60 s).
# Simula il tocco sulla tendina: apre il popup e preme una voce (come su iPhone),
# anche piu' volte di fila mentre il menu si sta ricostruendo.
# Uso: godot --headless --path . -s res://test_lingua.gd
var menu
var cambi := 0
var errori := 0

func _initialize() -> void:
	_run()

func _tendina() -> OptionButton:
	for c in menu.get_children():
		if c is OptionButton and not c.is_queued_for_deletion():
			return c
	return null

func _attract_loops() -> int:
	return 1 if menu._attract_attivo else 0

func _run() -> void:
	await process_frame
	menu = load("res://menu.tscn").instantiate()
	root.add_child(menu)
	await create_timer(0.5).timeout
	var t0 := Time.get_ticks_msec()
	var lingue: Array = Lingue.LINGUE
	while Time.get_ticks_msec() - t0 < 60000:
		var ob := _tendina()
		if ob == null:
			await process_frame
			continue
		var i := randi() % lingue.size()
		var pop := ob.get_popup()
		pop.popup()
		# il tocco su una voce: PopupMenu emette id_pressed -> OptionButton -> item_selected
		pop.id_pressed.emit(ob.get_item_id(i))
		# a volte un secondo tocco immediato (doppio tap)
		if randf() < 0.3:
			pop.id_pressed.emit(ob.get_item_id((i + 1) % lingue.size()))
		cambi += 1
		for k in randi() % 4:
			await process_frame
		if not is_instance_valid(menu):
			errori += 1; break
	await create_timer(0.5).timeout
	var ob2 := _tendina()
	var att: String = Lingue.attiva()
	var sel_ok: bool = ob2 != null and Lingue.LINGUE[ob2.selected] == att
	var n_tendine := 0
	for c in menu.get_children():
		if c is OptionButton and not c.is_queued_for_deletion(): n_tendine += 1
	print("CAMBI=", cambi, " TENDINE=", n_tendine, " LINGUA=", att, " SEL_OK=", sel_ok, " FIGLI=", menu.get_child_count())
	if n_tendine != 1 or not sel_ok: errori += 1
	print("ERRORI=", errori)
	quit(0 if errori == 0 else 1)
