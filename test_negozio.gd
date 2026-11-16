extends SceneTree
# Collaudo negozio + raffica di click (60 s): spin sovrapposti, crash, monete.
# Uso: godot --headless --path . -s res://test_negozio.gd
var main
var avvii := 0
var sovrapposti := 0
var errori := 0

func _initialize() -> void:
	_run()

func _run() -> void:
	# file puliti per un test ripetibile
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://midnight_acquisti.cfg"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://midnight_stato.cfg"))
	await process_frame
	var shop = root.get_node_or_null("Shop")
	if shop == null:
		print("ERRORE: autoload Shop mancante"); quit(1); return
	print("Shop modo=", shop.modo, " (1=PROVA)")
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await create_timer(1.0).timeout

	# 1) acquisto di prova dal pannello
	var saldo0: int = main.balance
	main._apri_negozio()
	await process_frame
	assert(main.shop_aperto)
	var pannello = null
	for c in main.get_children():
		if c.get_script() == preload("res://shop_panel.gd"): pannello = c
	if pannello == null: print("ERRORE: pannello non aperto"); errori += 1
	pannello._compra("monete_50k")
	await create_timer(1.0).timeout
	var guadagno: int = main.balance - saldo0
	print("acquisto prova: +", guadagno, " (atteso 50000)")
	if guadagno != 50000: errori += 1
	if shop.in_attesa() != 0: print("ERRORE: monete non incassate"); errori += 1
	if pannello._esito == null: print("ERRORE: schermata esito mancante"); errori += 1
	pannello._chiudi_esito()
	# doppio click veloce sullo stesso acquisto: deve contare UNA volta
	saldo0 = main.balance
	pannello._compra("monete_10k"); pannello._compra("monete_10k")
	await create_timer(1.0).timeout
	print("doppio click: +", main.balance - saldo0, " (atteso 10000)")
	if main.balance - saldo0 != 10000: errori += 1
	pannello.chiudi()
	await process_frame
	if main.shop_aperto: print("ERRORE: shop_aperto resta true"); errori += 1

	# 2) negozio non si apre durante lo spin
	main._on_spin_pressed()
	await process_frame
	main._apri_negozio()
	await process_frame
	if main.shop_aperto: print("ERRORE: negozio aperto durante lo spin"); errori += 1
	while main.spinning: await create_timer(0.1).timeout

	# 3) raffica di click per 60 s (spin + tentativi di aprire il negozio)
	var t0 := Time.get_ticks_msec()
	var era := false
	var n := 0
	while Time.get_ticks_msec() - t0 < 60000:
		if main.spinning and not era: avvii += 1
		era = main.spinning
		if n % 3 == 0:
			main._on_spin_pressed()
		elif n % 7 == 0:
			main._apri_negozio()
			await process_frame
			if main.shop_aperto:
				for c in main.get_children():
					if c.get_script() == preload("res://shop_panel.gd"): c.chiudi()
				await process_frame
		var ev := InputEventKey.new(); ev.keycode = KEY_SPACE; ev.pressed = true
		main._unhandled_input(ev)
		n += 1
		if main.balance < 0: print("ERRORE: saldo negativo"); errori += 1
		await create_timer(0.03).timeout
	print("raffica: click=", n, " spin avviati=", avvii, " saldo=", main.balance)
	# 4) persistenza: il saldo salvato deve contenere le monete comprate
	var cf := ConfigFile.new(); cf.load("user://midnight_stato.cfg")
	print("saldo salvato=", cf.get_value("stato", "balance", -1))
	print("ERRORI=", errori)
	print("TEST_NEGOZIO_FINITO")
	quit(0 if errori == 0 else 1)
