# ==== INIZIO FILE: copia da questa riga in giu' ====
# menu.gd - MENU MIDNIGHT CASE v1.1 (attract solo monete; base: menu Midnight Heist v2.5) + targhe illustrate
# v2.5: sul web i browser bloccano l'audio finche' l'utente non tocca la
#   pagina: al primo click/tocco il menu fa (ri)partire la musica.
# v2.4.1: fix - lo Sprite2D e' gia' centrato, niente pivot_offset;
#   il Mastermind ondeggia attorno ai piedi via offset.
# v2.4: il logo respira e brilla; il Mastermind ondeggia; una VINCITA
#   FINTA gira in sottofondo ogni pochi secondi (monete + "MEGA WIN"
#   sfumato) per catturare chi apre il gioco. Tutto puramente estetico.
# v2.3: testi in lang.gd (7 lingue); lingua rilevata dal dispositivo;
#   menu a tendina compatto in alto a sinistra per cambiarla.
#   RICHIEDE lang.gd nella cartella del progetto.
# v2.2.1: targhetta AUDIO diventa barra orizzontale in basso a
#   sinistra (non copre piu' il bottone GIOCA)
# v2.2: targhetta AUDIO nel menu (MUSICA/EFFETTI on-off, letti dal
#   gioco via Engine meta mh_music/mh_sfx); leggenda corretta coi nomi
#   veri dei simboli: le CASSEFORTI attivano il Colpo, la MASCHERA e'
#   il WILD. Richiede main v3.13.
# Leggenda ricostruita con RichTextLabel (righe robuste, icone inline):
#  - TABELLA VINCITE completa, coi valori presi VIVI da SlotEngine.PAYTABLE
#    (se ritariamo il motore, la leggenda si aggiorna da sola)
#  - pagamenti scatter, Colpo, Cassaforte + targhe, WILD
#  - IL PIANO DEL COLPO per intero: attrezzi, Pioggia, Supremo,
#    free spin, reset puntata
# Tutto scorrevole, in IT/EN/ES.
extends Node2D

const VW := 1152.0
const VH := 648.0

# (i testi sono in lang.gd - classe Lingue)

const SYM_ORDER := ["WILD", "STAR", "CROWN", "GEM_PURPLE", "GEM_GREEN", "GEM_BLUE", "GEM_RED"]

func _lang() -> String:
	return Lingue.attiva()

func T(k: String) -> String:
	return Lingue.t(k, _lang())

func _ready() -> void:
	_build()
	_play_menu_music()

var menu_music: AudioStreamPlayer = null

func _mus_on() -> bool:
	return Engine.get_meta("mh_music") if Engine.has_meta("mh_music") else true

func _fx_on() -> bool:
	return Engine.get_meta("mh_sfx") if Engine.has_meta("mh_sfx") else true

func _play_menu_music() -> void:
	var stream = null
	for ext in ["mp3", "ogg", "wav"]:
		var p := "res://assets/audio/music_menu.%s" % ext
		if ResourceLoader.exists(p):
			stream = load(p); break
	if stream == null: return
	if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
		stream.loop = true
	menu_music = AudioStreamPlayer.new()
	menu_music.stream = stream; menu_music.volume_db = -6.0
	add_child(menu_music)
	if _mus_on(): menu_music.play()

func _input(event: InputEvent) -> void:
	# WEB: l'audio e' bloccato dal browser fino al primo gesto dell'utente.
	# Al primo click/tocco/tasto riavvio la musica se e' ferma o "muta".
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
		if event.is_pressed() and menu_music != null and _mus_on():
			if not menu_music.playing:
				menu_music.play()
			elif OS.has_feature("web") and menu_music.get_playback_position() < 0.05:
				menu_music.stop(); menu_music.play()

func _gold_button(text: String, x: float, y: float, w: float, h: float, fsize: int, gold: bool = true) -> BaseButton:
	# tasto ILLUSTRATO se c'e' assets/tasto_menu.png (targa vuota: il testo lo scrive il codice, multilingua)
	if ResourceLoader.exists("res://assets/targa_menu.png"):
		var tb := TextureButton.new()
		tb.texture_normal = load("res://assets/targa_menu.png")
		tb.ignore_texture_size = true
		tb.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		tb.focus_mode = Control.FOCUS_NONE
		tb.modulate = Color(1, 1, 1) if gold else Color(0.82, 0.84, 0.95)
		add_child(tb)
		tb.position = Vector2(x, y)
		tb.size = Vector2(w, h)
		tb.pivot_offset = Vector2(w / 2.0, h / 2.0)
		var lb := Label.new()
		lb.text = text
		lb.size = Vector2(w, h)
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lb.add_theme_font_size_override("font_size", fsize)
		lb.add_theme_color_override("font_color", Color("#ffd76a") if gold else Color("#fff3d0"))
		lb.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		lb.add_theme_constant_override("outline_size", 5)
		lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tb.add_child(lb)
		tb.button_down.connect(func() -> void: tb.scale = Vector2(0.96, 0.96))
		tb.button_up.connect(func() -> void: tb.scale = Vector2.ONE)
		return tb
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", fsize)
	var sb := StyleBoxFlat.new()
	if gold:
		sb.bg_color = Color("#e3a93c")
		b.add_theme_color_override("font_color", Color("#2a1c05"))
	else:
		sb.bg_color = Color("#3a4258")
		b.add_theme_color_override("font_color", Color("#ffffff"))
	sb.set_corner_radius_all(14)
	sb.set_border_width_all(3)
	sb.border_color = Color("#ffe89a") if gold else Color("#8a93ad")
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 4)
	b.add_theme_stylebox_override("normal", sb)
	var sh := sb.duplicate()
	sh.bg_color = Color("#ffc85a") if gold else Color("#4a5470")
	b.add_theme_stylebox_override("hover", sh)
	b.add_theme_stylebox_override("pressed", sh)
	add_child(b)
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	return b

func _build() -> void:
	for c in get_children():
		if c is Control or c is Sprite2D: c.queue_free()

	if ResourceLoader.exists("res://assets/background.png"):
		var bg := TextureRect.new()
		bg.texture = load("res://assets/background.png")
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(bg)
		bg.size = Vector2(VW, VH)
	else:
		var c := ColorRect.new(); add_child(c)
		c.color = Color("#0d1117"); c.size = Vector2(VW,VH)

	var veil := ColorRect.new()
	add_child(veil)
	veil.color = Color(0,0,0,0.5); veil.size = Vector2(VW,VH)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists("res://assets/detective.png"):
		var mm := Sprite2D.new()
		mm.texture = load("res://assets/detective.png")
		var msc := 420.0 / mm.texture.get_height()
		mm.scale = Vector2(msc, msc)
		mm.position = Vector2(895, 410)
		add_child(mm)
		# ondeggio dolce (Sprite2D ruota attorno al proprio centro: va benissimo)
		var mmt := create_tween().set_loops()
		mmt.tween_property(mm, "rotation_degrees", 1.2, 2.2).set_trans(Tween.TRANS_SINE)
		mmt.tween_property(mm, "rotation_degrees", -1.2, 2.2).set_trans(Tween.TRANS_SINE)

	if not ResourceLoader.exists("res://assets/title.png"):
		# logo non ancora generato: titolo di riserva in oro
		var tl := Label.new()
		tl.text = "MIDNIGHT\nCASE"
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tl.add_theme_font_size_override("font_size", 72)
		tl.add_theme_color_override("font_color", Color("#f5c542"))
		tl.add_theme_color_override("font_outline_color", Color("#2a1505"))
		tl.add_theme_constant_override("outline_size", 10)
		tl.position = Vector2(45, 110); tl.size = Vector2(660, 200)
		add_child(tl)
	if ResourceLoader.exists("res://assets/title.png"):
		var t := Sprite2D.new()
		t.texture = load("res://assets/title.png")
		var sc := 660.0 / t.texture.get_width()
		t.scale = Vector2(sc, sc)
		t.position = Vector2(375, 205)
		add_child(t)
		# il logo respira
		var tb := create_tween().set_loops()
		tb.tween_property(t, "scale", Vector2(sc*1.04, sc*1.04), 1.6).set_trans(Tween.TRANS_SINE)
		tb.tween_property(t, "scale", Vector2(sc, sc), 1.6).set_trans(Tween.TRANS_SINE)
		# un brillio che attraversa il titolo ogni tanto
		_titolo_brillio(t, sc)

	_gold_button(T("gioca"), 150, 430, 280, 90, 36, true).pressed.connect(_on_play)
	_gold_button(T("come"), 450, 446, 190, 56, 18, false).pressed.connect(_on_legend)

	# lingua: rilevata dal dispositivo; un menu a tendina compatto per cambiarla
	var ob := OptionButton.new()
	ob.add_theme_font_size_override("font_size", 15)
	var idx := 0
	for i in Lingue.LINGUE.size():
		var code: String = Lingue.LINGUE[i]
		ob.add_item(Lingue.NOMI[code], i)
		if code == _lang(): idx = i
	ob.select(idx)
	ob.item_selected.connect(func(i2: int):
		Engine.set_meta("mh_lang", Lingue.LINGUE[i2]); _build())
	add_child(ob)
	ob.position = Vector2(20, 20)
	ob.size = Vector2(150, 38)

	_build_audio_targhetta()
	_attract_mode()

func _titolo_brillio(t: Sprite2D, _sc: float) -> void:
	while is_instance_valid(t):
		await get_tree().create_timer(3.5).timeout
		if not is_instance_valid(t): return
		var fl := create_tween()
		fl.tween_property(t, "modulate", Color(1.6, 1.5, 1.1), 0.18)
		fl.tween_property(t, "modulate", Color.WHITE, 0.35)

func _attract_mode() -> void:
	# vincita finta ricorrente: monete che salgono (solo estetica; CASE senza scritte)
	while is_instance_valid(self):
		await get_tree().create_timer(6.0).timeout
		if not is_instance_valid(self): return
		var lay := Node2D.new()
		add_child(lay)
		lay.z_index = 5
		var coin_tex = load("res://assets/fx_coin.png") if ResourceLoader.exists("res://assets/fx_coin.png") else null
		for i in 14:
			var c := TextureRect.new()
			if coin_tex != null: c.texture = coin_tex
			c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			c.modulate.a = 0.7
			lay.add_child(c)
			c.size = Vector2(40, 40)
			c.position = Vector2(randf_range(VW*0.1, VW*0.9), VH + 30.0)
			var tc := create_tween()
			tc.tween_property(c, "position:y", randf_range(VH*0.25, VH*0.6), randf_range(0.8, 1.3)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(randf_range(0.0, 0.6))
			tc.tween_property(c, "position:y", VH + 50.0, randf_range(0.7, 1.1)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			var trc := create_tween()
			trc.tween_property(c, "rotation_degrees", randf_range(-360, 360), 2.0)
		# CASE: niente scritte BIG WIN/JACKPOT nell'attract, solo le monete
		await get_tree().create_timer(2.6).timeout
		if is_instance_valid(lay): lay.queue_free()

func _build_audio_targhetta() -> void:
	# targhetta AUDIO: interruttori validi per menu e gioco
	var pan := Panel.new()
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.05, 0.06, 0.1, 0.92)
	psb.border_color = Color("#f5b73f")
	psb.border_width_top = 2; psb.border_width_bottom = 2
	psb.border_width_left = 2; psb.border_width_right = 2
	psb.corner_radius_top_left = 12; psb.corner_radius_top_right = 12
	psb.corner_radius_bottom_left = 12; psb.corner_radius_bottom_right = 12
	psb.shadow_color = Color(0, 0, 0, 0.5); psb.shadow_size = 5; psb.shadow_offset = Vector2(0, 3)
	pan.add_theme_stylebox_override("panel", psb)
	add_child(pan)
	# barra orizzontale in basso a sinistra: non copre GIOCA
	pan.position = Vector2(20, 580)
	pan.size = Vector2(330, 50)
	var tit := Label.new()
	tit.text = T("audio_t")
	tit.add_theme_font_size_override("font_size", 15)
	tit.modulate = Color("#f5b73f")
	tit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pan.add_child(tit)
	tit.position = Vector2(14, 0)
	tit.size = Vector2(58, 50)
	var mb := _mini_toggle(pan, T("musica"), _mus_on(), 0)
	mb.pressed.connect(func():
		Engine.set_meta("mh_music", not _mus_on())
		mb.text = T("musica") + (": ON" if _mus_on() else ": OFF")
		if menu_music != null:
			if _mus_on(): menu_music.play()
			else: menu_music.stop())
	var sb2 := _mini_toggle(pan, T("effetti"), _fx_on(), 1)
	sb2.pressed.connect(func():
		Engine.set_meta("mh_sfx", not _fx_on())
		sb2.text = T("effetti") + (": ON" if _fx_on() else ": OFF"))

func _mini_toggle(pan: Panel, nome: String, acceso: bool, y: float) -> Button:
	var b := Button.new()
	b.text = nome + (": ON" if acceso else ": OFF")
	b.add_theme_font_size_override("font_size", 15)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#2c3550")
	sb.corner_radius_top_left = 9; sb.corner_radius_top_right = 9
	sb.corner_radius_bottom_left = 9; sb.corner_radius_bottom_right = 9
	sb.border_width_top = 2; sb.border_width_bottom = 2
	sb.border_width_left = 2; sb.border_width_right = 2
	sb.border_color = Color("#8a93ad")
	b.add_theme_stylebox_override("normal", sb)
	var sh := sb.duplicate(); sh.bg_color = Color("#3b4668")
	b.add_theme_stylebox_override("hover", sh)
	b.add_theme_color_override("font_color", Color("#ffffff"))
	pan.add_child(b)
	# y: 0 = primo slot, 1 = secondo slot della barra orizzontale
	b.position = Vector2(76.0 + y * 126.0, 7)
	b.size = Vector2(120, 36)
	b.add_theme_font_size_override("font_size", 13)
	return b

func _on_play() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

# ---------- LEGGENDA COMPLETA ----------

const RIGA_W := 830.0

func _icona_bb(file: String, dim: int = 42) -> String:
	var p := "res://assets/symbols/%s.png" % file
	if ResourceLoader.exists(p):
		return "[img=%d]%s[/img]  " % [dim, p]
	return ""

func _rtl(vb: VBoxContainer, bb: String, fsize: int = 16) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_size_override("normal_font_size", fsize)
	r.custom_minimum_size = Vector2(RIGA_W, 0)
	vb.add_child(r)
	r.text = bb
	return r

func _sezione(vb: VBoxContainer, testo: String) -> void:
	_rtl(vb, "\n[color=#f5b73f]%s[/color]" % testo, 22)

func _on_legend() -> void:
	if has_node("LegendPanel"): return

	var root := ColorRect.new()
	root.name = "LegendPanel"
	add_child(root)
	root.color = Color(0, 0, 0, 0.8)
	root.size = Vector2(VW, VH)
	root.position = Vector2.ZERO

	var PW := 920.0
	var PH := 616.0
	var panel := Panel.new()
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.05, 0.06, 0.09, 1.0)
	psb.border_color = Color("#f5b73f")
	psb.border_width_top = 3; psb.border_width_bottom = 3
	psb.border_width_left = 3; psb.border_width_right = 3
	psb.corner_radius_top_left = 16; psb.corner_radius_top_right = 16
	psb.corner_radius_bottom_left = 16; psb.corner_radius_bottom_right = 16
	panel.add_theme_stylebox_override("panel", psb)
	root.add_child(panel)
	panel.position = Vector2((VW - PW) / 2.0, (VH - PH) / 2.0)
	panel.size = Vector2(PW, PH)

	var title := Label.new()
	title.text = T("titolo_regole")
	title.add_theme_font_size_override("font_size", 28)
	title.modulate = Color("#f5b73f")
	panel.add_child(title)
	title.position = Vector2(34, 14)
	title.size = Vector2(PW - 68, 34)

	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(sc)
	sc.position = Vector2(34, 56)
	sc.size = Vector2(PW - 68, PH - 132)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.custom_minimum_size = Vector2(RIGA_W, 0)
	sc.add_child(vb)

	# scopo
	_rtl(vb, T("scopo"))

	# ----- TABELLA VINCITE (valori vivi dal motore) -----
	_sezione(vb, T("sez_paytable"))
	_rtl(vb, "[color=#c8c8c8]%s[/color]" % T("pt_nota"), 14)
	for sym in SYM_ORDER:
		var pt: Dictionary = SlotEngine.PAYTABLE[sym]
		var riga := _icona_bb(sym.to_lower(), 46)
		riga += "[color=#ffd991]3 %s = %d      4 %s = %d      5 %s = %d[/color]" % [
			T("x_di"), pt[3], T("x_di"), pt[4], T("x_di"), pt[5]]
		_rtl(vb, riga, 17)
	_rtl(vb, _icona_bb("scatter", 46) + "[color=#ffd991]" + T("scpay") + "[/color]", 17)

	# ----- I BONUS -----
	_sezione(vb, T("sez_bonus"))
	_rtl(vb, _icona_bb("scatter") + T("colpo"))
	_rtl(vb, _icona_bb("coin") + T("cassa"))
	_rtl(vb, "[color=#ffd991]" + T("targhe") + "[/color]")
	_rtl(vb, _icona_bb("wild") + T("wild"))

	# ----- GLI INDIZI (solo se il motore li usa: Midnight Case no) -----
	if SlotEngine.INDIZI_ATTIVI:
		_sezione(vb, T("sez_piano"))
		_rtl(vb, T("p_intro"))
		_rtl(vb, _icona_bb("tool_red") + "[color=#f0a396]" + T("p_rosso") + "[/color]")
		_rtl(vb, _icona_bb("tool_green") + "[color=#b7e3a8]" + T("p_verde") + "[/color]")
		_rtl(vb, _icona_bb("tool_blue") + "[color=#a8c4ec]" + T("p_blu") + "[/color]")
		_rtl(vb, "[color=#ffd991]" + T("p_pioggia") + "[/color]")
		_rtl(vb, "[color=#ffd700]" + T("p_supremo") + "[/color]")
		_rtl(vb, "[color=#c8c8c8]" + T("p_fs") + "[/color]", 15)
		_rtl(vb, "[color=#c8c8c8]" + T("p_bet") + "[/color]", 15)

	# ----- COMANDI -----
	_sezione(vb, T("sez_comandi"))
	_rtl(vb, T("comandi"), 15)

	var close := Button.new()
	close.text = T("chiudi")
	close.add_theme_font_size_override("font_size", 20)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color("#e3a93c")
	csb.corner_radius_top_left = 12; csb.corner_radius_top_right = 12
	csb.corner_radius_bottom_left = 12; csb.corner_radius_bottom_right = 12
	csb.border_width_top = 2; csb.border_width_bottom = 2
	csb.border_width_left = 2; csb.border_width_right = 2
	csb.border_color = Color("#ffe89a")
	close.add_theme_stylebox_override("normal", csb)
	var csh := csb.duplicate(); csh.bg_color = Color("#ffc85a")
	close.add_theme_stylebox_override("hover", csh)
	close.add_theme_color_override("font_color", Color("#2a1c05"))
	panel.add_child(close)
	close.position = Vector2((PW - 180) / 2.0, PH - 62)
	close.size = Vector2(180, 46)
	close.pressed.connect(func(): root.queue_free())
