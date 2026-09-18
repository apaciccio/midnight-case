# ==== INIZIO FILE: copia da questa riga in giu' ====
# main.gd - MIDNIGHT CASE v1.9 (TEMA DETECTIVE NOIR, SENZA INDIZI)
# v1.9: l'ispettore ESULTA (detective_win_1..N) a ogni vincita del gioco base,
#   per tutta la durata del conteggio; prima i fotogrammi win partivano solo
#   dentro i bonus.
# v1.8: l'insegna dei bonus entra TUTTA nello spazio sopra i rulli (non piu'
#   tagliata in alto) e il testo si rimpicciolisce da solo se e' lungo; il
#   FLASH non compare piu' prima del lancio quando il suo rullo ha un
#   DISTINTIVO che si espande.
# v1.2: detective piu' basso e sotto il logo (non lo copre piu').
# v1.3: scritta SCATTER sotto la lente quando atterra.
# v1.4: targhetta SCATTER illustrata (assets/scatter_tag.png), testo solo di riserva.
# v1.5: demo (tasto D, con DEMO_ATTIVA=true) limitata a Il Caso + L'Inseguimento.
# v1.6: scatola dell'ispettore corretta (pose non piu' tagliate), insegna del
#   bonus piu' grande col testo dentro, VINCITA EPICA a sinistra dell'ispettore,
#   il flash parte dalla macchina fotografica.
# v1.7: monete della tempesta a taglia giusta (expand_mode prima della size),
#   SCATTER non buca piu' le transizioni, insegna sopra i rulli del bonus.
# v1.1: niente medaglioni degli indizi (SlotEngine.INDIZI_ATTIVI = false):
#   restano L'Inseguimento (3 lenti), Il Caso (6 fascicoli) e il distintivo
#   WILD espanso. Motore ribilanciato: vedi slot_engine.gd.
# Base: Midnight Heist main v3.74 (motore, matematica certificata, fix e tasti
# illustrati IDENTICI). Cambia solo il tema: personaggio detective_*.png,
# sfondi, testi (lang.gd). Simboli: vedi MAPPA_SIMBOLI in fondo al file.
# v3.74: i medaglioni del Piano si caricano DAVVERO a vista. Con la
#   matematica v0.19 lo sblocco arriva in media al 30-35% della carica
#   piena, e la carica era disegnata lineare: si illuminava solo il terzo
#   basso e poi esplodeva. Ora la carica mostrata segue una curva che sale
#   in fretta e rallenta (allo sblocco tipico ~60-65%, oltre l'80% pulsa,
#   il 100% solo all'esplosione), e prima di esplodere il medaglione si
#   riempie fino in cima. Solo presentazione: motore e RTP intatti.
# v3.73: durante l'autospin il tasto AUTO diventa l'immagine tasto_stop.png
#   (stesso stile degli altri) e i giri rimasti stanno in un bollino tondo
#   in alto a destra (bordo dorato, cifra dorata; "∞" per l'infinito).
#   La targhetta rossa da codice resta solo come riserva se manca l'immagine.
#   CHIUSURA V1: DBG_OVERLAY e DEMO_ATTIVA a false (via la scritta verde di
#   diagnostica e il tasto D della demo).
# v3.72: SPIN, TURBO, AUTO, MENU e il chip BET sono IMMAGINI in stile gioco
#   (assets/tasto_spin.png, tasto_turbo_off.png, tasto_turbo_on.png,
#   tasto_auto.png, tasto_menu.png, chip_bet.png). Gli automatismi restano:
#   TURBO alterna l'immagine spenta/accesa (fiamme arancioni), AUTO durante
#   l'autospin mostra una targhetta "STOP n" sopra l'immagine, il chip BET
#   porta il numero della puntata e apre la schermata dei tagli. Se
#   un'immagine manca, il tasto torna dorato dal codice (nessun crash).
#   Layout: una riga sotto la griglia, TURBO - SPIN (grande) - AUTO - MENU.
# v3.71: TURBO/AUTO/MENU disegnati dal codice come SPIN: gradiente dorato
#   pieno, bordo chiaro, testo scuro in rilievo. TURBO acceso = piu' caldo.
#   Non dipendono piu' dalle immagini btn_*.png (che erano sbiadite).
# v3.70: la carica del medaglione riflette il pity timer (si riempie sul
#   serio verso lo sblocco garantito); TURBO/AUTO/MENU disegnati dorati e
#   pieni come SPIN (non piu' semitrasparenti).
# v3.69: fix spin sovrapposti
# v3.69: IL bug dei click a raffica. Dalla v3.56 il guardiano, uscendo dal
#   suo ciclo perche' era iniziato un ALTRO spin, metteva spinning=false
#   (riga fuori dall'if): un secondo dopo l'inizio di ogni spin il gioco
#   si dichiarava fermo e il click successivo faceva partire un secondo
#   spin sopra il primo -> strisce doppie, anelli accumulati, crash.
#   Ora spinning=false solo quando il guardiano interviene davvero.
# v3.68: tappe DBG dentro ogni bonus (Cassaforte, Colpo, Scasso, Taglio,
#   Supremo, cerimonie, dialoghi) e tetto sui cicli che usano il delta.
# v3.67: la cache delle texture procedurali viene svuotata all'uscita
#   (niente "texture leaked" alla chiusura).
# v3.66: CANCELLO: mentre lo spin e' in corso, un livello invisibile sopra
#   tutta l'interfaccia intercetta OGNI tocco (chip della puntata, TURBO,
#   MENU, medaglioni, AUTO...). Un tocco durante lo spin vale solo come
#   "caduta rapida" (o STOP dell'autospin). I mini-giochi stanno sopra
#   il cancello e ricevono i tocchi normalmente. E' la soluzione
#   strutturale al "secondo tocco che arriva mentre il primo anima".
# v3.65: se il saldo non basta per uno spin, dopo 1.5 s il gioco ricarica
#   1.000 monete con un avviso (social casino; sull'app sara' il bonus
#   giornaliero). Vale all'avvio e durante il gioco.
# v3.64: nello Scasso e nel Taglio un tocco alla volta (i tap a raffica
#   facevano partire due sequenze insieme: la seconda animava casseforti
#   gia' eliminate -> crash main.gd:2183). Ogni uso di nodi dopo
#   un'attesa e' protetto. Le animazioni a ciclo continuo delle scene
#   (raggi della grande vincita) vengono fermate quando la scena muore.
# v3.63: una striscia che ha l'ordine di fermarsi ma non atterra entro
#   3 s atterra d'ufficio (scarica la coda e si posa). Niente rulli
#   che girano all'infinito.
# v3.62: il GUARDIANO scattava a meta' bonus (12 s senza "nutrimento",
#   p.es. mentre il giocatore decide quale cassaforte toccare) e
#   spazzava tutto -> caos, e al click dopo il vecchio spin toccava
#   strisce gia' eliminate -> CRASH (main.gd:1791 nel rapporto macOS).
#   Ora: il guardiano viene nutrito da OGNI attesa del gioco (_wait,
#   _fine, cicli di attesa dei tap) e scatta solo dopo 60 s di vero
#   silenzio; la striscia si elimina solo se esiste ancora.
# v3.61: all'avvio il gioco disegna per 2 frame, invisibile, un esemplare
#   di OGNI tipo di effetto (Polygon2D, Line2D, gradienti, label con
#   contorno, veli, TextureRect modulati...) cosi' il browser compila
#   tutti gli shader durante il caricamento e non piu' a meta' partita
#   (= gli stalli di decine di secondi sul web). Tetti anche sui cicli
#   is_running() della grande vincita e della manopola.
# v3.60: NESSUNA attesa aspetta piu' un segnale "finished": tutte le 24
#   attese di fine animazione passano per _fine(tween), che controlla
#   is_running() e ha un tempo massimo. Anche le attese "finche' non
#   succede X" (fasci degli attrezzi) hanno un tetto. Sul web il segnale
#   di fine tween ogni tanto non arriva: era la causa dei blocchi.
#   Anche 'await process_frame' -> timer di 16 ms (piu' affidabile sul web).
# v3.59: le texture procedurali (aloni, anelli, spade di luce) si creano
#   UNA volta per colore e si riusano: niente piu' texture nuove a ogni
#   atterraggio (nel browser ingolfavano la grafica e la bloccavano per
#   secondi). Salvataggio su disco ogni 5 spin invece che a ogni spin.
# v3.58: sul web il TITOLO della scheda del browser mostra frame e fase
#   ogni mezzo secondo (si aggiorna anche se la grafica si congela);
#   _wait usa un timer breve invece del segnale di frame.
# v3.57: DBG_OVERLAY: scritta in alto a sinistra con la fase esatta dello
#   spin (per trovare i blocchi). Mettere false prima della pubblicazione.
# v3.56: difese contro il blocco da pressioni rapide:
#   - le attese sui rulli hanno un TEMPO MASSIMO (4 s): oltre, il rullo
#     si forza a terra e si prosegue (niente attese infinite)
#   - il rimbalzo d'atterraggio non aspetta piu' un segnale che potrebbe
#     non arrivare (controlla se il tween e' ancora in corso)
#   - delta-time dei rulli limitato a 50 ms (niente scatti dopo uno stallo)
#   - i click a raffica su SPIN sono filtrati (uno ogni 120 ms)
#   - WATCHDOG da 150 s a 12 s: se qualcosa muore, si sblocca subito
# v3.55: salvataggio
# v3.55: al cambio puntata gli attrezzi NON si azzerano: ogni livello ha
#   i suoi contatori, che ritrovi tornando indietro. Monete e puntata
#   si salvano sul dispositivo e si ritrovano riaprendo il gioco.
# v3.54: sacchi in scala con la puntata
# v3.54: il numero sui sacchi mostra il valore REALE alla puntata attuale
#   (valore base x bet/10), coerente col bottino incassato.
# v3.53.1: fix tipo di bonus_scattato
# v3.53: pulsante AUTO sotto la griglia. Tap = scegli i giri (10/25/50/
#   infinito); parte in automatico e si ferma quando finiscono, quando
#   scatta un bonus, se il saldo non basta, o al tap su STOP. Durante
#   l'autospin il bottone SPIN diventa STOP.
# v3.52: la grande vincita raccontata
# v3.52: BIG/MEGA/EPIC WIN sono una SCENA MADRE: buio totale, il
#   Mastermind entra da destra, il titolo esplode, e il conteggio del
#   premio SALE cifra per cifra (2-4 s, piu' lungo per l'epica) con
#   tin-tin e monete a fontana; scossa crescente; chiusura a schermo
#   pieno. Sotto i 15x resta la vincita normale in linea.
# v3.51: mancati casuali, grand celebrato
# v3.51: i premi mancati dello Scasso sono MESCOLATI e includono targhe
#   MINI/MINOR/MAJOR; il GRAND della Cassaforte (griglia piena) ha una
#   scena dedicata: le 15 celle lampeggiano d'oro a onda, esplosione,
#   pioggia di monete lunga, banner GRAND che pulsa.
# v3.50: scasso, premi mancati
# v3.50: nello Scasso, dopo la polizia, le casseforti rimaste si aprono
#   una a una e mostrano in grigio i premi che non hai preso ("PREMI
#   MANCATI"). Scala nuova 20..1000 (motore v0.18.1, EV invariato).
# v3.49: mastermind a taglia costante
# v3.49: il nodo del Mastermind ha la proporzione esatta dei frame
#   (904x1004 -> 414x460): ogni posa viene scalata identica, niente
#   salti di taglia tra un frame e l'altro.
# v3.48: etichette dei frammenti
# v3.48: nel Taglio i "+N" dei frammenti volano nel display insieme ai
#   frammenti e spariscono (non restano piu' sullo schermo).
# v3.47: retrigger visibile
# v3.47: 3+ casseforti nei giri gratis = evento: le casseforti esplodono
#   d'oro, targa "+N GIRI!", il contatore GIRO salta al nuovo totale.
# v3.46: una volta per tutte
# v3.46: (1) momento della verita' SENZA personaggio: velo, zoom, battito
#   e la frase come SOTTOTITOLO in basso al centro - nessuna sovrapposizione
#   possibile; (2) placchetta+numero sono UN SOLO oggetto (il numero e'
#   figlio della placchetta, centrato per costruzione, mai piu' toccato);
#   (3) ogni scena si registra nel gruppo "scena_bonus": a inizio e fine
#   spin il gioco spazza via qualsiasi residuo, e un WATCHDOG (150 s)
#   sblocca lo spin se una scena muore per un errore.
# v3.45: volumi per suono
# v3.45: tabella SFX_GAIN_DB: volume in dB per singolo effetto (0 = com'e',
#   +6 = doppio, -6 = meta'). Il battito parte a +4.
# v3.44: manopola, display, provocazione
# v3.44: il moltiplicatore del Taglio esce dalla MANOPOLA della cassaforte
#   (asset disco_cassaforte.png con marcatore in alto; fallback disegnata)
#   che gira, scatta e punta uno degli otto moltiplicatori in cerchio;
#   conteggi su DISPLAY meccanico (bezel scuro, cifre dorate) in tutti
#   i bonus; nel Colpo i rulli PROVOCANO il Mastermind: le gemme sulle
#   celle destinate tremolano, lui si gira, stringe i pugni e lancia.
# v3.43: fix blocco ruota, dinamite finta
# v3.43: fix del blocco nel Taglio (attesa sicura sui tween della ruota
#   e del conteggio); nel Colpo la gemma "finta" al posto della dinamite
#   e' decisa PRIMA che la striscia atterri (niente candelotto che
#   appare e sparisce); il Mastermind grande si nasconde in OGNI momento
#   della verita' (anche quello dei sacchi).
# v3.42: ruota del diamante, rabbia, scossa
# v3.42: nel Colpo le celle della dinamite atterrano con un simbolo
#   normale (niente buchi), poi il Mastermind si ARRABBIA (posa furia,
#   tremore, ringhio) e lancia; nel Taglio i frammenti si SOMMANO in un
#   contatore e il moltiplicatore esce da una RUOTA che gira, poi il
#   contatore si moltiplica sotto gli occhi; nel Supremo, dopo lo
#   scontro, PAUSA con scossa lunga e lampi; nel momento della verita'
#   il Mastermind grande sparisce (niente doppioni in trasparenza);
#   placchette mai visibili sulle celle vuote; etichetta del numero
#   sempre ricalcolata.
# v3.41: pose di lancio e furia
# v3.41: usa mastermind_furia.png durante la furia e mastermind_lancio.png
#   nel lancio; il candelotto parte dalla mano alzata (in alto a destra
#   del personaggio, che guarda verso i rulli).
# v3.40: etichetta del sacco
# v3.40: la placchetta e' un'etichetta appesa al CORPO del sacco (piu'
#   piccola, 56x30, centrata al 62% dell'altezza della cella) e il
#   numero e' centrato sul rettangolo della placchetta, non sulla cella.
# v3.39: hud dei bonus
# v3.39: niente piu' scritta "LA CASSAFORTE - RESPIN - BOTTINO": HUD dei
#   bonus rifatto. Cassaforte: i tre pallini + scritta RESPIN sotto
#   (senza numeri). Colpo: contatore GIRO e BADGE del moltiplicatore
#   che cresce con un pop a ogni dinamite. Bottino su targa dorata in
#   basso a sinistra con numero che salta a ogni incasso.
# v3.38: il mastermind lancia la dinamite
# v3.38: nel Colpo la dinamite la LANCIA il Mastermind: la cella destinata
#   atterra vuota e scura, lui carica (posa mastermind_lancio.png se
#   esiste, altrimenti esultanza + slancio) e il candelotto vola ad arco
#   fino alla cella ed esplode. Con 2+ candelotti: FURIA (trema, "Adesso
#   basta!", raffica). Matematica invariata: la dinamite e' quella del
#   motore, cambia chi la porta.
# v3.37: il colpo grande
# v3.37: nel Colpo le MASCHERE APPICCICOSE restano illuminate per tutto
#   il bonus (respiro dorato sui rulli appiccicati); i SACCHI cadono con
#   il loro valore e vengono incassati subito x moltiplicatore (pop
#   dorato per cella + "+N" volante). Richiede motore v0.17.
# v3.36: verita' pulita, sacchi, spade di luce, respin
# v3.36: il momento della verita' nasconde l'HUD (niente sovrapposizioni)
#   e vale anche per il SESTO SACCO ("Manca un sacco..."); i simboli
#   importanti hanno la SPADA DI LUCE che li attraversa ogni pochi
#   secondi e stanno un filo piu' grandi; i RESPIN della Cassaforte sono
#   tre LUCI dorate che si spengono e si riaccendono (con pop e flash).
# v3.35: lingue dal dispositivo
# v3.35: i testi vivono in lang.gd (classe Lingue, 7 lingue); la
#   lingua si rileva dal dispositivo, il menu permette di cambiarla.
#   RICHIEDE lang.gd nella cartella del progetto.
# v3.34: aure e momento della verita'
# v3.34: AURA pulsante dietro i simboli importanti anche da fermi
#   (WILD/STAR forte, CROWN/casseforte/sacco/dinamite media), nel loro
#   colore; MOMENTO DELLA VERITA': con due casseforti a terra e la
#   terza destinata, il tempo rallenta (velo, zoom sulla griglia,
#   battito, il Mastermind sussurra "Ne manca una...") e la terza cade
#   in slow motion. Suono opzionale sfx_battito.
# v3.33: placchetta centrata e pulita
# v3.33: la placchetta di cuoio e' centrata esattamente sotto il
#   numero (78x44) e sparisce quando la cella si svuota (Cassaforte).
# v3.32: fix placchetta e targa gigante
# v3.32: la placchetta di cuoio compare SOLO sotto il numero dei sacchi
#   (centrata); il banner generico delle scene non esplode piu' a
#   dimensione piena (expand_mode impostato prima della size).
# v3.31: durata dei suoni dal codice
# v3.31: ogni effetto ha una DURATA MASSIMA nel codice (SFX_MAX_S):
#   se il file e' piu' lungo, il gioco lo spegne al momento giusto con
#   una dissolvenza di 80 ms. I file audio possono essere lunghi quanto
#   vogliono: rinomina e basta. Suoni non elencati: nessun limite.
# v3.30: mastermind che parla, grande
# v3.30: nella scena-dialogo il Mastermind e' a tutta altezza (nodo
#   560x620, in basso a sinistra), fumetto accanto.
# v3.29: mastermind che esulta
# v3.29: nodo del Mastermind piu' largo (396x460) per le braccia
#   spalancate; esultanza in ping-pong a 0.22s; posa speciale
#   mastermind_win_coins.png durante le celebrazioni BIG/MEGA/EPIC.
# v3.28: mastermind che respira
# v3.28: frame idle in ping-pong a 0.45s (respiro ~2.7s), win a 0.14s;
#   senza frame win, nel bonus resta l'idle animato (niente salti).
# v3.27: cornice medaglione
# v3.27: con med_frame.png presente, l'attrezzo si posiziona DENTRO
#   l'apertura della cornice (piu' piccolo, centrato sull'apertura) e
#   la cornice resta dorata con un velo del colore dell'attrezzo.
# v3.26: targhe generiche, testo dal codice
# v3.26: le targhe sono immagini VUOTE e il testo lo scrive il codice
#   nella lingua attiva: banner_scena.png (IL COLPO / LA CASSAFORTE),
#   targa_jackpot.png (MINI/MINOR/MAJOR sulle celle), banner_targa.png
#   (eventi). Una lingua nuova = una riga nel dizionario, zero immagini.
#   Restano validi come ripiego i vecchi banner con testo disegnato.
# v3.25: wild espanso
# v3.25: quando un WILD cade, i rulli si fermano sui simboli ORIGINALI,
#   poi la maschera si ALLARGA a coprire il rullo (stiramento, lampo,
#   onda, scossa) e le celle diventano WILD col moltiplicatore.
#   Suono opzionale sfx_wild_espanso. Richiede motore v0.16.
# v3.24: gerarchia dei simboli
# v3.24: ogni simbolo atterra con un effetto proporzionato al valore:
#   LEGGENDA (WILD, STAR): anello dorato + scintille + brillio + suono
#   ALTO (CROWN, casseforte, sacco, dinamite): anello nel loro colore
#   ATTREZZI: rimbalzo + anello nel colore dell'attrezzo
#   GEMME: rimbalzo semplice. Suono opzionale sfx_premium.
# v3.23: il colpo con la dinamite
# v3.23: IL COLPO e' una scena nuova: dentro il caveau aperto (asset
#   sfondo_colpo.png dietro i rulli, con fallback), il Mastermind lo
#   apre con una battuta, e la DINAMITE che cade ESPLODE (onda, flash,
#   scossa) facendo saltare il moltiplicatore, mostrato grande e
#   pulsante. HUD: MOLT x1 -> x2 -> x3... Asset: dinamite.png in
#   assets/symbols (fallback: cella rossa "TNT"), sfx_esplosione.
#   Richiede motore v0.15.
# v3.22: il mastermind parla
# v3.22: nel Colpo Supremo niente piu' targhe: tra una scena e l'altra
#   il MASTERMIND appare su nero con un FUMETTO a macchina da scrivere
#   e racconta il colpo (asset opzionale mastermind_talk.png per la
#   posa parlante). Transizioni: nero, lampo, luce.
# v3.21: banner in lingua, cerimonie senza stacco
# v3.21: i banner-immagine dei bonus cambiano con la lingua: cerca
#   banner_colpo_en.png / banner_colpo_es.png (idem cassaforte); se
#   mancano usa una targa disegnata col testo tradotto. La CERIMONIA
#   di sblocco e' su nero pieno e porta DIRETTAMENTE nella scena
#   (niente dissolvenza ne' targa in mezzo). Casseforti dello Scasso
#   disposte ad ARCO con alone dorato, rotazioni e taglie diverse.
# v3.20: colpo supremo in quattro atti
# v3.20: il COLPO SUPREMO non e' piu' tre bonus in fila ma UNA scena:
#   1) Convergenza: i tre attrezzi volano dai medaglioni e si
#      scontrano al centro (lampo, onda, targa); 2) il Diamante;
#   3) "I frammenti aprono le casseforti" -> parete; 4) "La polizia?!
#   Il complice apre il caveau" -> Rapina Perfetta; FINALE: un solo
#   conteggio BOTTINO SUPREMO di tutto. Matematica invariata.
# v3.19: il taglio del diamante
# v3.19: la tessera apre IL TAGLIO DEL DIAMANTE: buio, diamante
#   gigante che ruota, lo colpisci 3 volte (trema, crepe, scintille),
#   esplode in 5 frammenti a stella che rivelano premi uno a uno, poi
#   il MOLTIPLICATORE piomba dal centro. Asset opzionali: diamante.png,
#   diamante_crepato.png, frammento.png; suono sfx_vetro. Motore v0.14.
# v3.18: scasso al buio, mastermind vivo
# v3.18: FIX definitivo del popup puntata (il pannello vecchio restava
#   in hud_nodes e riappariva a fine bonus: eliminato del tutto);
#   SCASSO ridisegnato: schermo completamente nero, 9 casseforti
#   GRANDI e libere che fluttuano (niente riquadri); MASTERMIND vivo:
#   respiro + ondeggio invece del su-e-giu' piatto, e supporto ai
#   FRAME ANIMATI se generi mastermind_idle_1..N.png e
#   mastermind_win_1..N.png (si animano da soli a 6 fps)
# v3.17: rullo complice
# v3.17: l'ACCESSO e' il RULLO COMPLICE: targa dedicata, il rullo del
#   complice gira tinto di verde e allo stop la colonna esplode WILD
#   con onda verde. Richiede motore v0.13.
# v3.16: scasso mini-gioco
# v3.16: lo SCASSO e' un mini-gioco a schermo pieno: parete di 12
#   casseforti, le TOCCHI tu, ognuna si apre e paga in crescendo
#   finche' non esce LA POLIZIA (lampeggio rosso/blu, sirena) e scappi
#   col bottino. Se le apri tutte e 8: RIPULITO TUTTO. Asset opzionali:
#   scasso_cassaforte_chiusa.png / scasso_cassaforte_aperta.png /
#   scasso_polizia.png, suoni sfx_polizia e sfx_cassaforte_apri.
#   Richiede motore v0.12. RTP invariato (EV 5x esatto).
# v3.15: puntata a tutto schermo
# v3.15: chip BET rotondo, spostato a destra; cliccandolo si apre il
#   SELETTORE A TUTTO SCHERMO coi tagli grandi (niente piu' popup che
#   si incastra sui rulli); pulizia di sicurezza delle strisce a
#   inizio e fine spin; demo con esiti esatti (motore v0.11.1)
# v3.14.1: suspense sopra turbo/fastdrop
# v3.14.1: la SUSPENSE vince su turbo e caduta rapida - rallentamento
#   e attese di tensione attivi anche col turbo e col doppio click
# v3.14: la pioggia non ha piu' la targa: coriandoli colorati e
#   monetine cadono su tutto lo schermo mentre gli attrezzi volano ai
#   medaglioni; TASTO D = DEMO, attiva in sequenza TUTTI i bonus
#   (pioggia, Cassaforte, Colpo, SCASSO, ACCESSO, CHIAVE, SUPREMO)
#   senza dover spinnare - solo per i test, il flag DEMO_ATTIVA in
#   testa al file va messo false prima della pubblicazione.
#   Richiede motore v0.11 (che porta anche la GARANZIA SACCO MINIMO).
# v3.13: audio nel menu, suspense con rallentamento
# v3.13: interruttori MUSICA/EFFETTI spostati nel menu (targhetta
#   AUDIO); il gioco li legge da Engine meta mh_music/mh_sfx.
#   Suspense del 1o simbolo finalmente VISIBILE: tinta ambra forte e
#   RALLENTAMENTO dei rulli restanti (0.55x; 0.45x al 2o; 0.35x al 3o
#   e coi sacchi vicini al trigger). Richiede menu v2.2.
# v3.12: cerimonie di sblocco, numeri coniati
# v3.12: ogni sblocco ha la sua CERIMONIA epica a schermo pieno
#   (rosso: il grimaldello forza la serratura a 3 scatti; verde: la
#   tessera striscia col lettore e la scansione; blu: la chiave gira
#   nella toppa) - asset opzionale scasso_lucchetto.png dietro il
#   grimaldello; NUMERI CONIATI sui sacchi (oro, contorno, ombra;
#   placchetta opzionale sacco_plate.png dietro il numero)
# v3.11: presagi, targhe, tin-tin, puntata a chip
# v3.11: PRESAGI "la macchina lo sa" per OGNI funzione (cornice dello
#   schermo che pulsa: oro=Cassaforte, rosso=Colpo; suoni-firma
#   opzionali sfx_pre_cassa/colpo/rosso/verde/blu); TARGHE-BANNER
#   eleganti al posto delle scritte nude (pop elastico + flash, asset
#   opzionale banner_targa.png); TIN-TIN del conteggio (sfx_count);
#   scritte principali con contorno; PUNTATA A CHIP: un bottone
#   dorato che apre i tagli 10/20/50/100/200
# v3.10.1: fix crash sblocco
# v3.10: vignetta radiale nei bonus; impatto fisico dei sacchi
#   (shockwave + scintille + scossa griglia, targhe con flash colore);
#   sacchi bloccati che respirano; BIG/MEGA/EPIC WIN (15x/40x/100x)
#   con fontana di monete; contatore pulsante; popup +N nel Colpo
# v3.9: suspense viva, medaglioni liberi
# v3.9: medaglioni LIBERI senza sagoma (130px, fluttuano da fermi);
#   TELEGRAFO "la macchina lo sa": se uno sblocco arrivera', il suo
#   medaglione lo anticipa gia' durante lo spin (rosso VIBRA, verde
#   PULSA, blu SI ILLUMINA); suspense PROGRESSIVA sulle maschere
#   (1a leggera ambra, 2a forte rossa, 3a esplosiva oro/rosso) e sui
#   sacchi vicini alla Cassaforte (4 tenue, 5 forte). Motore v0.10.
# v3.8: Cassaforte a ONDA (partenze/stop scaglionati, velocita' varie,
#   ritmo piu' lento); POP dei simboli all'atterraggio (piu' forte per
#   WILD/scatter/sacchi/attrezzi); fascio ad ARCO con scia di fantasmi;
#   medaglioni ridisegnati a card (niente cerchio, bordo sottile
#   colorato, icona grande; usa assets/med_frame.png se esiste)
# v3.7: attrezzi nei free spin + reset puntata
# v3.7: gli attrezzi raccolti nei giri gratis lampeggiano sulle celle
#   e caricano i medaglioni a fine bonus; cambiare la puntata azzera
#   la carica (i medaglioni si svuotano animati). Richiede motore v0.9.
# v3.6: carica misteriosa, fasci paralleli, pioggia, Colpo Supremo
# v3.5: rulli a scorrimento vero + caveau notturno
# v3.4: lavagna stile Power Pig — tre MEDAGLIONI grandi a sinistra
#   (grimaldello/tessera/chiave) che si CARICANO di luce dal basso;
#   quando l'attrezzo cade sui rulli un FASCIO vola dalla cella al
#   medaglione (whoosh + jingle), il medaglione pulsa quando manca
#   un pezzo, e quando e' pieno ESPLODE in schegge e attiva il premio.
#   Suoni opzionali: sfx_whoosh (fascio), sfx_tool (arrivo) in
#   assets/audio — se mancano usa sfx_unlock. Richiede motore v0.7.1.
# v3.3: aggancio tre binari (Scasso/Accesso/Chiave Maestra)
# Novita' rispetto a v2.9:
#  - pannello IL PIANO a sinistra: contatori attrezzi (6/4/3), si
#    aggiorna a ogni spin, si nasconde durante i bonus
#  - RAPINA PERFETTA: quando il set si completa parte una Cassaforte
#    con 6 sacchi garantiti (stessa animazione, banner dedicato)
#  - richiede slot_engine.gd v0.6
# (v2.9: fix selettore puntata a larghezze fisse)
# ------------------------------------------------------------------
# Musica base -> suspense sugli scatter -> sting + musica bonus.
# Toggle MUSICA/EFFETTI. I file vanno in assets/audio/ (mp3, ogg o wav).
# Transizione a pioggia piena -> schermata bonus senza HUD
# con rulli ingranditi al centro. Logo e tipo piu' a destra.
# Pioggia di monete/banconote, Mastermind animato con tween,
# banner dorati che calano dall'alto, pannello bonus con targa.
extends Node2D

const VW := 1152.0
const VH := 648.0
const CELL := 96
const GAP := 8
const ROWS := 3
const REELS := 5

# griglia centrata orizzontalmente, con spazio a destra per il Mastermind
var GRID_W := REELS * CELL + (REELS - 1) * GAP
var GRID_X := int((VW - 340 - (REELS * CELL + (REELS - 1) * GAP)) / 2.0) + 20
const GRID_Y := 150

const SYMBOL_COLORS := {
	"GEM_RED": Color("#8d6e63"), "GEM_BLUE": Color("#5c8db8"),
	"GEM_GREEN": Color("#7cb342"), "GEM_PURPLE": Color("#ab47bc"),
	"CROWN": Color("#f5b73f"), "STAR": Color("#7fe3f0"),
	"WILD": Color("#e53950"), "SCATTER": Color("#ffd700"), "COIN": Color("#c9a24b"),
	"TOOL_RED": Color("#d1543f"), "TOOL_GREEN": Color("#6fbf5e"), "TOOL_BLUE": Color("#4f83d1"),
	"DINAMITE": Color("#e0341c"),
}
const SYMBOL_LETTERS := {
	"GEM_RED": "G", "GEM_BLUE": "R", "GEM_GREEN": "P", "GEM_PURPLE": "T",
	"CROWN": "L", "STAR": "D", "WILD": "M", "SCATTER": "$", "COIN": "S",
	"TOOL_RED": "1", "TOOL_GREEN": "2", "TOOL_BLUE": "3",
}

# ritmo
const TICK := 0.06
const FIRST_STOP := 0.8
const STOP_GAP := 0.35
const ANTICIPATION_GAP := 1.4
const TURBO_SCALE := 0.4
# bonus PIU' LENTO e goduto
const FS_SHUFFLE := 0.6
const FS_PAUSE := 0.9

const BET_LEVELS := [10, 20, 50, 100, 200]
const JACKPOT_BASE := {"mini": 50, "minor": 200, "major": 1000, "grand": 10000}
const JP_PAY := {-1: 50, -2: 200, -3: 1000}
const JP_NAME := {-1: "MINI", -2: "MINOR", -3: "MAJOR"}
const JP_CELL_BG := {-1: Color("#0e3540"), -2: Color("#1c3312"), -3: Color("#38103f")}
const JP_TXT := {-1: Color("#7fd8e8"), -2: Color("#9fe37c"), -3: Color("#e056fd")}
# (i testi sono in lang.gd - classe Lingue)
func _lang() -> String:
	return Lingue.attiva()

func T(k: String) -> String:
	return Lingue.t(k, _lang())

var engine := SlotEngine.new()
var balance := 1000
var bet_index := 0
var turbo := false
var cells: Array = []
var textures := {}
var jackpot_labels := {}
var spin_button_node: TextureRect = null
var spin_hitbox: BaseButton
var turbo_tex: TextureRect
var turbo_btn: BaseButton
var turbo_tex_off: Texture2D = null
var turbo_tex_on: Texture2D = null
var bet_num_label: Label = null       # numero della puntata sopra il chip illustrato
var auto_stop_plate: Control = null   # targhetta "STOP n" (riserva se manca tasto_stop.png)
var auto_tex: Texture2D = null        # immagine AUTO a riposo
var stop_tex: Texture2D = null        # immagine STOP durante l'autospin
var auto_badge: Control = null        # bollino coi giri rimasti
var auto_badge_label: Label = null
var balance_label: Label
var win_label: Label
var bet_chip: BaseButton
var fs_banner: Label
var fs_info: Label
var mastermind_node: TextureRect
var mm_idle_frames: Array = []
var mm_win_frames: Array = []
var mm_frames_attivi := "idle"
var mm_coins = null
var mm_normal = null
var mm_win = null
var spinning := false
var request_fastdrop := false
var last_spin_click := 0.0
var fx_layer: Node2D = null
var grid_root: Node2D = null
var hud_nodes: Array = []
var rain_on := false
var mm_sway_tween: Tween = null
var banner_node: TextureRect = null
var music_player: AudioStreamPlayer = null
var sfx_player: AudioStreamPlayer = null
var spin_sfx_player: AudioStreamPlayer = null
var current_music := ""
var piano_med := {}
const PIANO_COL := {"TOOL_RED": Color("#d1543f"), "TOOL_GREEN": Color("#6fbf5e"), "TOOL_BLUE": Color("#4f83d1")}
const PITCH := CELL + GAP
const SPIN_SPEED := 1500.0
const CASSA_SPIN_SPEED := 1050.0
const STOP_GAP_STRIP := 0.10
var col_strips: Array = []
var reel_suspense := 1.0
var sticky_illuminati: Array = []
var dinamite_lanciata := false
const DEMO_ATTIVA := false   # true solo per provare i bonus col tasto D
const DBG_OVERLAY := false   # true = scritta verde di diagnostica in alto a sinistra
var dbg_label: Label = null
var dbg_n := 0

var dbg_fase := ""
var dbg_frames := 0
var dbg_acc := 0.0

func _process(delta: float) -> void:
	if not DBG_OVERLAY: return
	dbg_frames += 1
	dbg_acc += delta
	if dbg_acc >= 0.5:
		dbg_acc = 0.0
		if OS.has_feature("web"):
			JavaScriptBridge.eval("document.title='MH f=%d | %s | spin=%s'" % [dbg_frames, dbg_fase.replace("'", ""), str(spinning)])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_tex_cache.clear()

func _dbg(fase: String) -> void:
	dbg_fase = fase
	if not DBG_OVERLAY: return
	if dbg_label == null or not is_instance_valid(dbg_label):
		dbg_label = Label.new()
		dbg_label.add_theme_font_size_override("font_size", 13)
		dbg_label.add_theme_color_override("font_color", Color("#7fff7f"))
		dbg_label.add_theme_color_override("font_outline_color", Color.BLACK)
		dbg_label.add_theme_constant_override("outline_size", 4)
		dbg_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dbg_label.z_index = 200
		add_child(dbg_label)
		dbg_label.position = Vector2(6, 26)
	dbg_n += 1
	dbg_label.text = "DBG %d | %s | spinning=%s fastdrop=%s auto=%d t=%.1f" % [dbg_n, fase, str(spinning), str(request_fastdrop), autospin_left, Time.get_ticks_msec() / 1000.0]
	print("DBG ", dbg_n, " ", fase)
var demo_in_corso := false
static var music_on := true
static var sfx_on := true

func _ready() -> void:
	_carica_stato()
	_load_textures()
	_build_ui()
	_riscalda_shader()
	_fill_random_grid()
	_audio_setup()

func _bet() -> int: return BET_LEVELS[bet_index]
func _t(s: float) -> float: return s * (TURBO_SCALE if turbo else 1.0)

func _load_textures() -> void:
	for key in SlotEngine.SYMBOLS.keys():
		var p := "res://assets/symbols/%s.png" % key.to_lower()
		if ResourceLoader.exists(p):
			textures[key] = load(p)
	if ResourceLoader.exists("res://assets/detective_full.png"):
		mm_normal = load("res://assets/detective_full.png")
	if ResourceLoader.exists("res://assets/detective_win.png"):
		mm_win = load("res://assets/detective_win.png")

func _tasto_dorato(testo: String, x: float, y: float, w: float, h: float, acceso: bool = false) -> Button:
	var b := Button.new()
	b.text = testo
	b.size = Vector2(w, h); b.position = Vector2(x, y)
	b.add_theme_font_size_override("font_size", 22)
	for st in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#e8b73a") if acceso else Color("#c9a24a")
		sb.border_color = Color("#fff0b8")
		sb.border_width_top = 2; sb.border_width_bottom = 3; sb.border_width_left = 2; sb.border_width_right = 2
		sb.corner_radius_top_left = 12; sb.corner_radius_top_right = 12
		sb.corner_radius_bottom_left = 12; sb.corner_radius_bottom_right = 12
		sb.shadow_color = Color(0, 0, 0, 0.45); sb.shadow_size = 5; sb.shadow_offset = Vector2(0, 3)
		if st == "hover": sb.bg_color = sb.bg_color.lightened(0.08)
		if st == "pressed": sb.bg_color = sb.bg_color.darkened(0.10)
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_color_override("font_color", Color("#2a1c05"))
	b.add_theme_color_override("font_hover_color", Color("#2a1c05"))
	b.add_theme_color_override("font_pressed_color", Color("#1a1204"))
	b.add_theme_color_override("font_focus_color", Color("#2a1c05"))
	add_child(b)
	return b

func _img(path: String, x: float, y: float, w: float, h: float) -> TextureRect:
	if not ResourceLoader.exists(path): return null
	var t := TextureRect.new()
	t.texture = load(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	t.size = Vector2(w, h); t.position = Vector2(x, y)
	add_child(t)
	return t

# TASTO ILLUSTRATO: immagine in stile gioco (assets/<nome>); se manca, tasto
# dorato dal codice con la scritta di riserva. Feedback alla pressione:
# leggero scurimento e piccolo "schiacciamento".
func _tasto_img(nome: String, riserva: String, x: float, y: float, w: float, h: float) -> BaseButton:
	var path := "res://assets/%s" % nome
	if not ResourceLoader.exists(path):
		return _tasto_dorato(riserva, x, y, w, h)
	var b := TextureButton.new()
	b.texture_normal = load(path)
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	b.size = Vector2(w, h); b.position = Vector2(x, y)
	b.pivot_offset = Vector2(w / 2.0, h / 2.0)
	b.focus_mode = Control.FOCUS_NONE
	b.button_down.connect(func():
		if is_instance_valid(b):
			b.modulate = Color(0.82, 0.82, 0.82); b.scale = Vector2(0.95, 0.95))
	b.button_up.connect(func():
		if is_instance_valid(b):
			b.modulate = Color.WHITE; b.scale = Vector2.ONE)
	add_child(b)
	return b

func _build_ui() -> void:
	# sfondo pieno
	if ResourceLoader.exists("res://assets/background.png"):
		var bg := TextureRect.new()
		bg.texture = load("res://assets/background.png")
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.size = Vector2(VW, VH)
		add_child(bg)
	else:
		var c := ColorRect.new(); c.color = Color("#0d1117"); c.size = Vector2(VW,VH); add_child(c)

	# logo in alto a DESTRA, dietro il personaggio (lui lo sovrappone)
	if ResourceLoader.exists("res://assets/title.png"):
		var tlogo := Sprite2D.new()
		tlogo.texture = load("res://assets/title.png")
		var lw := 300.0
		var lsc := lw / tlogo.texture.get_width()
		tlogo.scale = Vector2(lsc, lsc)
		tlogo.position = Vector2(955, 92)
		add_child(tlogo)
		hud_nodes.append(tlogo)

	# BARRA JACKPOT centrata sopra la griglia
	var jdata := [
		{"k": "mini", "nome": "MINI", "col": Color("#7fd8e8")},
		{"k": "minor", "nome": "MINOR", "col": Color("#7cb342")},
		{"k": "major", "nome": "MAJOR", "col": Color("#e056fd")},
		{"k": "grand", "nome": "GRAND", "col": Color("#f5b73f")},
	]
	var plate_w := (GRID_W - 3 * 10.0) / 4.0
	var jx := float(GRID_X)
	for jd in jdata:
		var plate := Panel.new()
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color(0.06, 0.07, 0.11, 0.95)
		psb.border_color = Color("#f5b73f")
		psb.border_width_top = 2; psb.border_width_bottom = 2
		psb.border_width_left = 2; psb.border_width_right = 2
		psb.corner_radius_top_left = 10; psb.corner_radius_top_right = 10
		psb.corner_radius_bottom_left = 10; psb.corner_radius_bottom_right = 10
		plate.add_theme_stylebox_override("panel", psb)
		plate.size = Vector2(plate_w, 54)
		plate.position = Vector2(jx, 76)
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(plate)
		hud_nodes.append(plate)
		var jn := Label.new()
		jn.text = jd["nome"]
		jn.position = Vector2(0, 4); jn.size = Vector2(plate_w, 20)
		jn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		jn.add_theme_font_size_override("font_size", 15)
		jn.modulate = jd["col"]
		plate.add_child(jn)
		var jv := Label.new()
		jv.text = str(JACKPOT_BASE[jd["k"]])
		jv.position = Vector2(0, 26); jv.size = Vector2(plate_w, 24)
		jv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		jv.add_theme_font_size_override("font_size", 18)
		jv.modulate = Color("#ffd700")
		plate.add_child(jv)
		jackpot_labels[jd["k"]] = jv
		jx += plate_w + 10

	# griglia (dentro un contenitore scalabile per la scena bonus)
	grid_root = Node2D.new()
	grid_root.position = Vector2(GRID_X, GRID_Y)
	add_child(grid_root)
	for reel in REELS:
		var col: Array = []
		for row in ROWS:
			var panel := ColorRect.new()
			panel.color = Color("#141821")
			panel.size = Vector2(CELL, CELL)
			panel.position = Vector2(reel*(CELL+GAP), row*(CELL+GAP))
			grid_root.add_child(panel)
			# AURA: alone pulsante dietro i simboli importanti
			var aura := TextureRect.new()
			aura.texture = _glow_texture(Color("#ffd700"))
			aura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
			aura.visible = false
			panel.add_child(aura)
			aura.size = Vector2(CELL * 1.6, CELL * 1.6)
			aura.position = Vector2(-CELL * 0.3, -CELL * 0.3)
			var tex := TextureRect.new()
			tex.pivot_offset = Vector2((CELL-8) / 2.0, (CELL-8) / 2.0)
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.size = Vector2(CELL-8, CELL-8); tex.position = Vector2(4,4)
			tex.visible = false
			panel.add_child(tex)
			# placchetta opzionale dietro il numero dei sacchi (assets/sacco_plate.png)
			var plate: TextureRect = null
			if ResourceLoader.exists("res://assets/sacco_plate.png"):
				plate = TextureRect.new()
				plate.texture = load("res://assets/sacco_plate.png")
				plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
				plate.visible = false
				panel.add_child(plate)
				plate.size = Vector2(56, 30)
				plate.position = Vector2((CELL - 56) / 2.0, CELL * 0.62 - 15.0)
				# il NUMERO e' figlio della placchetta: centrato per costruzione, per sempre
				var numlab := Label.new()
				numlab.add_theme_font_size_override("font_size", 21)
				numlab.add_theme_color_override("font_color", Color("#ffe9a8"))
				numlab.add_theme_color_override("font_outline_color", Color("#3a2405"))
				numlab.add_theme_constant_override("outline_size", 6)
				numlab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				numlab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				numlab.mouse_filter = Control.MOUSE_FILTER_IGNORE
				plate.add_child(numlab)
				numlab.position = Vector2.ZERO
				numlab.size = plate.size
				plate.set_meta("numlab", numlab)
			var lab := Label.new()
			# numero coniato: oro, contorno scuro, ombra
			lab.add_theme_font_size_override("font_size", 40)
			lab.add_theme_color_override("font_color", Color("#ffe9a8"))
			lab.add_theme_color_override("font_outline_color", Color("#3a2405"))
			lab.add_theme_constant_override("outline_size", 12)
			lab.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
			lab.add_theme_constant_override("shadow_offset_x", 2)
			lab.add_theme_constant_override("shadow_offset_y", 3)
			lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lab.size = panel.size
			panel.add_child(lab)
			# SPADA DI LUCE: lama chiara che attraversa i simboli importanti
			var clipper := Control.new()
			clipper.clip_contents = true
			clipper.mouse_filter = Control.MOUSE_FILTER_IGNORE
			panel.add_child(clipper)
			clipper.position = Vector2(4, 4)
			clipper.size = Vector2(CELL - 8, CELL - 8)
			var sweep := TextureRect.new()
			if not _tex_cache.has("sweep"):
				var sg := Gradient.new()
				sg.colors = PackedColorArray([Color(1,1,1,0.0), Color(1,1,1,0.75), Color(1,1,1,0.0)])
				sg.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
				var st := GradientTexture2D.new()
				st.gradient = sg; st.width = 64; st.height = 8
				st.fill_from = Vector2(0, 0.5); st.fill_to = Vector2(1, 0.5)
				_tex_cache["sweep"] = st
			sweep.texture = _tex_cache["sweep"]
			sweep.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			sweep.mouse_filter = Control.MOUSE_FILTER_IGNORE
			sweep.visible = false
			clipper.add_child(sweep)
			sweep.size = Vector2(36, CELL * 1.6)
			sweep.pivot_offset = Vector2(18, CELL * 0.8)
			sweep.rotation_degrees = 25.0
			sweep.position = Vector2(-60, -CELL * 0.3)
			col.append({"panel": panel, "label": lab, "tex": tex, "symbol": "", "plate": plate, "aura": aura, "aura_tw": null, "sweep": sweep, "sweep_tw": null})
		cells.append(col)

	# Mastermind a destra: VIVO (respiro + ondeggio; frame animati se esistono)
	if mm_normal != null:
		mastermind_node = TextureRect.new()
		# expand_mode PRIMA della texture: altrimenti la scatola prende
		# l'altezza dell'immagine (694 px) e le pose finiscono sotto lo schermo
		mastermind_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mastermind_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mastermind_node.texture = mm_normal
		# CASE: il detective e' alto e stretto, quindi parte SOTTO il logo
		# (logo in alto a destra fino a y~185) e finisce a filo del pavimento
		mastermind_node.size = Vector2(414, 460)
		mastermind_node.position = Vector2(734, 186)
		add_child(mastermind_node)
		# perno ai piedi: il respiro parte da terra, non fluttua a mezz'aria
		mastermind_node.pivot_offset = Vector2(207, 460)
		var resp := create_tween().set_loops()
		resp.tween_property(mastermind_node, "scale", Vector2(1.004, 1.018), 1.7).set_trans(Tween.TRANS_SINE)
		resp.tween_property(mastermind_node, "scale", Vector2.ONE, 1.7).set_trans(Tween.TRANS_SINE)
		var sway := create_tween().set_loops()
		sway.tween_property(mastermind_node, "rotation_degrees", 0.9, 2.3).set_trans(Tween.TRANS_SINE)
		sway.tween_property(mastermind_node, "rotation_degrees", -0.9, 2.3).set_trans(Tween.TRANS_SINE)
		# frame animati opzionali: mastermind_idle_1..N.png (6 fps)
		mm_idle_frames.clear()
		var fi := 1
		while ResourceLoader.exists("res://assets/detective_idle_%d.png" % fi):
			mm_idle_frames.append(load("res://assets/detective_idle_%d.png" % fi))
			fi += 1
		fi = 1
		mm_win_frames.clear()
		while ResourceLoader.exists("res://assets/detective_win_%d.png" % fi):
			mm_win_frames.append(load("res://assets/detective_win_%d.png" % fi))
			fi += 1
		if ResourceLoader.exists("res://assets/detective_win_coins.png"):
			mm_coins = load("res://assets/detective_win_coins.png")
		if mm_idle_frames.size() >= 2:
			_mm_anim_loop()

	# audio: gli interruttori vivono nel menu (targhetta AUDIO)
	music_on = Engine.get_meta("mh_music") if Engine.has_meta("mh_music") else true
	sfx_on = Engine.get_meta("mh_sfx") if Engine.has_meta("mh_sfx") else true

	# --- LAVAGNA DEL PIANO: tre medaglioni che si caricano ---
	_build_piano_medaglioni()

	var below := GRID_Y + ROWS*(CELL+GAP) + 16

	# riga 1: saldo a sinistra, bet a destra (stessa riga)
	balance_label = Label.new()
	balance_label.position = Vector2(GRID_X, below)
	balance_label.add_theme_font_size_override("font_size", 22)
	add_child(balance_label); _update_balance()
	hud_nodes.append(balance_label)

	# riga 2: vincita centrata sulla griglia
	win_label = Label.new()
	win_label.position = Vector2(GRID_X, below + 30)
	win_label.size = Vector2(GRID_W, 28)
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 26)
	win_label.add_theme_color_override("font_color", Color("#ffd700"))
	win_label.add_theme_color_override("font_outline_color", Color("#3a2705"))
	win_label.add_theme_constant_override("outline_size", 8)
	add_child(win_label)

	# banner + info bonus (centrati sulla griglia)
	fs_banner = Label.new()
	fs_banner.position = Vector2(GRID_X, GRID_Y - 6)
	fs_banner.size = Vector2(GRID_W, 40)
	fs_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fs_banner.add_theme_font_size_override("font_size", 30)
	fs_banner.add_theme_color_override("font_color", Color("#ff5252"))
	fs_banner.add_theme_color_override("font_outline_color", Color("#2a0808"))
	fs_banner.add_theme_constant_override("outline_size", 8)
	add_child(fs_banner)
	fs_info = Label.new()
	fs_info.position = Vector2(0, VH - 96)
	fs_info.size = Vector2(VW, 90)
	fs_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fs_info.add_theme_font_size_override("font_size", 22)
	fs_info.add_theme_color_override("font_color", Color("#ffd700"))
	fs_info.add_theme_color_override("font_outline_color", Color("#3a2705"))
	fs_info.add_theme_constant_override("outline_size", 6)
	add_child(fs_info)

	# --- controlli: bet, spin, turbo, auto, menu (ILLUSTRATI, v3.72) ---
	# --- PUNTATA A CHIP: chip illustrato (chip_bet.png) col numero sopra; apre i tagli ---
	var chip_lato := 96.0
	bet_chip = _tasto_img("chip_bet.png", "", GRID_X + GRID_W + 10, below - 34, chip_lato, chip_lato)
	if bet_chip is TextureButton:
		# numero della puntata nella parte bassa del chip (la parola BET e' nel disegno)
		bet_num_label = _etichetta("", 21, Color("#2a1c05"), Color("#ffe9a8"), 5)
		bet_num_label.position = Vector2(0, chip_lato * 0.60)
		bet_num_label.size = Vector2(chip_lato, chip_lato * 0.26)
		bet_chip.add_child(bet_num_label)
	else:
		# riserva dorata rotonda (come v3.71)
		bet_chip.add_theme_font_size_override("font_size", 17)
		bet_chip.add_theme_color_override("font_color", Color("#2a1c05"))
		var chsb := StyleBoxFlat.new()
		chsb.bg_color = Color("#e3a93c")
		chsb.corner_radius_top_left = 48; chsb.corner_radius_top_right = 48
		chsb.corner_radius_bottom_left = 48; chsb.corner_radius_bottom_right = 48
		chsb.border_width_top = 3; chsb.border_width_bottom = 3
		chsb.border_width_left = 3; chsb.border_width_right = 3
		chsb.border_color = Color("#ffe89a")
		chsb.shadow_color = Color(0, 0, 0, 0.55); chsb.shadow_size = 6; chsb.shadow_offset = Vector2(0, 4)
		bet_chip.add_theme_stylebox_override("normal", chsb)
		var chsh := chsb.duplicate(); chsh.bg_color = Color("#ffc85a")
		bet_chip.add_theme_stylebox_override("hover", chsh)
	bet_chip.pressed.connect(_apri_bet_schermo)
	hud_nodes.append(bet_chip)
	_update_bet_label()

	# RIGA DEI TASTI sotto la griglia, centrata: TURBO - SPIN (grande) - AUTO - MENU
	var lato_piccolo := 80.0
	var lato_spin := 100.0
	var gap_tasti := 26.0
	var riga_y := below + 66          # bordo alto della riga (SPIN)
	var tot_w := lato_piccolo * 3 + lato_spin + gap_tasti * 3
	var x0 := GRID_X + (GRID_W - tot_w) / 2.0
	var cy := riga_y + lato_spin / 2.0    # asse orizzontale della riga
	var turbo_x := x0
	var spin_x := x0 + lato_piccolo + gap_tasti
	var auto_x := spin_x + lato_spin + gap_tasti
	var menu_x := auto_x + lato_piccolo + gap_tasti

	# SPIN (illustrato) al centro
	spin_hitbox = _tasto_img("tasto_spin.png", "SPIN", spin_x, riga_y, lato_spin, lato_spin)
	spin_hitbox.pressed.connect(_on_spin_pressed)
	if spin_hitbox is Button: spin_hitbox.add_theme_font_size_override("font_size", 26)
	hud_nodes.append(spin_hitbox)

	# TURBO (illustrato, due stati). L'immagine ACCESA ha le fiamme che escono
	# dal corpo del tasto: verde.py --tasti salva on/off sulla STESSA tela,
	# quindi il rettangolo del tasto e' piu' largo del corpo. Quanto, lo
	# misuro dall'immagine spenta (corpo = pixel non trasparenti), cosi' il
	# corpo del TURBO risulta grande come gli altri tasti e l'accensione non
	# sposta nulla.
	var turbo_w := lato_piccolo
	if ResourceLoader.exists("res://assets/tasto_turbo_off.png"):
		turbo_tex_off = load("res://assets/tasto_turbo_off.png")
		turbo_tex_on = load("res://assets/tasto_turbo_on.png") if ResourceLoader.exists("res://assets/tasto_turbo_on.png") else turbo_tex_off
		var im: Image = turbo_tex_off.get_image()
		if im != null and not im.is_empty():
			var corpo := im.get_used_rect()
			if corpo.size.x > 0:
				turbo_w = lato_piccolo * clampf(float(im.get_width()) / float(corpo.size.x), 1.0, 1.8)
	turbo_btn = _tasto_img("tasto_turbo_off.png", "TURBO", turbo_x + (lato_piccolo - turbo_w) / 2.0, cy - turbo_w / 2.0, turbo_w, turbo_w)
	turbo_btn.pressed.connect(_on_turbo_pressed)
	hud_nodes.append(turbo_btn)
	_turbo_refresh()

	# AUTO (illustrato) a destra di SPIN; durante l'autospin porta la targhetta STOP n
	auto_button = _tasto_img("tasto_auto.png", "AUTO", auto_x, cy - lato_piccolo / 2.0, lato_piccolo, lato_piccolo)
	auto_button.pressed.connect(_on_auto_pressed)
	if auto_button is TextureButton:
		auto_stop_plate = Control.new()
		auto_stop_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		auto_stop_plate.size = Vector2(lato_piccolo, lato_piccolo)
		var pl := Panel.new()
		pl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color(0.20, 0.03, 0.03, 1.0)
		psb.border_color = Color("#ff9a3c"); psb.set_border_width_all(2)
		psb.set_corner_radius_all(int(lato_piccolo * 0.18))
		pl.add_theme_stylebox_override("panel", psb)
		pl.position = Vector2(lato_piccolo * 0.06, lato_piccolo * 0.08)
		pl.size = Vector2(lato_piccolo * 0.88, lato_piccolo * 0.84)
		auto_stop_plate.add_child(pl)
		auto_label = _etichetta("", 20, Color("#ff6b6b"), Color("#2a0505"), 5)
		auto_label.size = Vector2(lato_piccolo, lato_piccolo)
		auto_stop_plate.add_child(auto_label)
		auto_stop_plate.visible = false
		auto_button.add_child(auto_stop_plate)
		# STOP illustrato + bollino del conteggio (in alto a destra, sporge un po')
		auto_tex = load("res://assets/tasto_auto.png")
		if ResourceLoader.exists("res://assets/tasto_stop.png"):
			stop_tex = load("res://assets/tasto_stop.png")
			var d := 32.0
			auto_badge = Control.new()
			auto_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			auto_badge.position = Vector2(lato_piccolo - d + 8.0, -8.0)
			auto_badge.size = Vector2(d, d)
			var cerchio := Panel.new()
			cerchio.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var csb := StyleBoxFlat.new()
			csb.bg_color = Color("#1a0a05")
			csb.border_color = Color("#ffd77a"); csb.set_border_width_all(2)
			csb.set_corner_radius_all(int(d / 2.0))
			csb.shadow_color = Color(0, 0, 0, 0.5); csb.shadow_size = 3; csb.shadow_offset = Vector2(0, 2)
			cerchio.add_theme_stylebox_override("panel", csb)
			cerchio.size = Vector2(d, d)
			auto_badge.add_child(cerchio)
			auto_badge_label = _etichetta("", 15, Color("#ffe9a8"), Color("#2a1505"), 3)
			auto_badge_label.size = Vector2(d, d)
			auto_badge.add_child(auto_badge_label)
			auto_badge.visible = false
			auto_button.add_child(auto_badge)
	hud_nodes.append(auto_button)

	# MENU (illustrato)
	var menu_btn := _tasto_img("tasto_menu.png", "MENU", menu_x, cy - lato_piccolo / 2.0, lato_piccolo, lato_piccolo)
	menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://menu.tscn"))
	hud_nodes.append(menu_btn)

	# CANCELLO DEI TOCCHI: sopra tutta l'interfaccia, attivo solo durante lo spin
	input_gate = Control.new()
	input_gate.name = "input_gate"
	input_gate.mouse_filter = Control.MOUSE_FILTER_STOP
	input_gate.size = Vector2(VW, VH)
	input_gate.visible = false
	input_gate.gui_input.connect(func(ev: InputEvent):
		if (ev is InputEventMouseButton and ev.pressed) or (ev is InputEventScreenTouch and ev.pressed):
			if autospin_left != 0:
				_autospin_stop()
			else:
				_on_spin_pressed())
	add_child(input_gate)

# fast-drop: barra spaziatrice
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if spinning:
			request_fastdrop = true
		else:
			_on_spin_pressed()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_D and DEMO_ATTIVA:
		_demo_bonus()

func _update_balance() -> void: balance_label.text = "%s: %d" % [T("monete"), balance]
func _update_bet_label() -> void:
	if bet_num_label != null and is_instance_valid(bet_num_label):
		bet_num_label.text = str(_bet())
	elif bet_chip is Button:
		bet_chip.text = "%s\n%d" % [T("bet"), _bet()]
	# i jackpot scalano con la puntata
	for jf in JACKPOT_BASE.keys():
		if jackpot_labels.has(jf):
			var scaled := int(JACKPOT_BASE[jf] * _bet() / 10.0)
			jackpot_labels[jf].text = _fmt(scaled)

func _fmt(n: int) -> String:
	var s := str(n); var out := ""; var c := 0
	for i in range(s.length()-1, -1, -1):
		out = s[i] + out; c += 1
		if c % 3 == 0 and i > 0: out = "." + out
	return out

var bet_screen: Node2D = null

func _apri_bet_schermo() -> void:
	if spinning or (bet_screen != null and is_instance_valid(bet_screen)): return
	bet_screen = Node2D.new()
	add_child(bet_screen)
	bet_screen.z_index = 92
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.78)
	bet_screen.add_child(veil)
	veil.size = Vector2(VW, VH)
	veil.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed: _chiudi_bet_schermo())
	var tit := Label.new()
	tit.text = T("bet")
	tit.add_theme_font_size_override("font_size", 44)
	tit.add_theme_color_override("font_color", Color("#f5b73f"))
	tit.add_theme_color_override("font_outline_color", Color("#3a2405"))
	tit.add_theme_constant_override("outline_size", 12)
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bet_screen.add_child(tit)
	tit.position = Vector2(0, 120)
	tit.size = Vector2(VW, 60)
	var n := BET_LEVELS.size()
	var dim := 136.0
	var gap := 28.0
	var x0 := (VW - (n * dim + (n - 1) * gap)) / 2.0
	for i in n:
		var b := Button.new()
		b.text = str(BET_LEVELS[i])
		b.add_theme_font_size_override("font_size", 34)
		var attivo := i == bet_index
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#e3a93c") if attivo else Color(0.12, 0.14, 0.2, 0.96)
		sb.corner_radius_top_left = 68; sb.corner_radius_top_right = 68
		sb.corner_radius_bottom_left = 68; sb.corner_radius_bottom_right = 68
		sb.border_width_top = 4; sb.border_width_bottom = 4
		sb.border_width_left = 4; sb.border_width_right = 4
		sb.border_color = Color("#ffe89a") if attivo else Color("#8a93ad")
		sb.shadow_color = Color(0, 0, 0, 0.5); sb.shadow_size = 6; sb.shadow_offset = Vector2(0, 4)
		b.add_theme_stylebox_override("normal", sb)
		var sh := sb.duplicate(); sh.bg_color = Color("#ffc85a") if attivo else Color(0.2, 0.24, 0.34, 0.96)
		b.add_theme_stylebox_override("hover", sh)
		b.add_theme_color_override("font_color", Color("#2a1c05") if attivo else Color("#ffffff"))
		bet_screen.add_child(b)
		b.position = Vector2(x0 + i * (dim + gap), VH / 2.0 - dim / 2.0)
		b.size = Vector2(dim, dim)
		var idx := i
		b.pressed.connect(func(): _scegli_bet(idx))

func _chiudi_bet_schermo() -> void:
	if bet_screen != null and is_instance_valid(bet_screen):
		bet_screen.queue_free()
	bet_screen = null


func _scegli_bet(i: int) -> void:
	if bet_index != i:
		bet_index = i
		_update_bet_label()
		engine.cambia_livello(i)   # ogni puntata ha la sua lavagna
		_refresh_piano(true)
		_salva_stato()
	_chiudi_bet_schermo()

# ---------- SALVATAGGIO DI MONETE E PUNTATA ----------
const STATO_SAVE_PATH := "user://midnight_stato.cfg"
var spin_dal_salvataggio := 0

var ricarica_in_corso := false

func _ricarica_cortesia() -> void:
	# monete di cortesia quando il saldo non basta (sull'app: bonus giornaliero)
	if ricarica_in_corso: return
	ricarica_in_corso = true
	await get_tree().create_timer(1.5).timeout
	if balance < _bet():
		balance = 1000
		_update_balance()
		_salva_stato()
		_targa_banner(T("ricarica"), Color("#f5b73f"), 1.6)
		_burst_money(14)
	ricarica_in_corso = false

func _salva_stato() -> void:
	var cf := ConfigFile.new()
	cf.set_value("stato", "balance", balance)
	cf.set_value("stato", "bet_index", bet_index)
	cf.save(STATO_SAVE_PATH)

func _carica_stato() -> void:
	var cf := ConfigFile.new()
	if cf.load(STATO_SAVE_PATH) == OK:
		balance = int(cf.get_value("stato", "balance", balance))
		bet_index = clampi(int(cf.get_value("stato", "bet_index", 0)), 0, BET_LEVELS.size() - 1)
		if balance < BET_LEVELS[bet_index]:
			balance = 1000   # ripartenza: monete di cortesia se non puoi spinnare
	# la lavagna del motore deve essere quella di QUESTO livello
	if engine.lavagna_livello != bet_index:
		engine.cambia_livello(bet_index)

func _on_turbo_pressed() -> void:
	turbo = not turbo
	_turbo_refresh()

func _turbo_refresh() -> void:
	if turbo_btn == null or not is_instance_valid(turbo_btn): return
	if turbo_btn is TextureButton:
		var tx: Texture2D = turbo_tex_on if turbo else turbo_tex_off
		if tx != null:
			turbo_btn.texture_normal = tx
	elif turbo_btn is Button:
		var sb: StyleBoxFlat = turbo_btn.get_theme_stylebox("normal")
		if sb != null: sb.bg_color = Color("#ff9a3c") if turbo else Color("#c9a24a")

# TARGHETTA "SCATTER" illustrata (assets/scatter_tag.png): incollata in basso
# sulla cella quando atterra uno scatter. Creata una volta per cella, poi
# solo mostrata/nascosta. Se l'immagine manca, _set_cell scrive il testo.
func _scatter_tag(c: Dictionary, mostra: bool) -> void:
	if not mostra:
		if c.has("tag") and is_instance_valid(c["tag"]): c["tag"].visible = false
		return
	if not ResourceLoader.exists("res://assets/scatter_tag.png"): return
	if not c.has("tag") or not is_instance_valid(c["tag"]):
		var t := TextureRect.new()
		t.texture = load("res://assets/scatter_tag.png")
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pw: float = c["panel"].size.x
		# al CENTRO della cella, sopra l'oggetto (un filo sotto la mezzeria)
		t.size = Vector2(pw * 0.94, pw * 0.32)
		t.position = Vector2(pw * 0.03, c["panel"].size.y * 0.56 - t.size.y / 2.0)
		c["panel"].add_child(t)
		c["tag"] = t
	c["tag"].visible = true

func _set_cell(reel: int, row: int, sym: String, mult: int = 1, coin_val: int = 0) -> void:
	var c: Dictionary = cells[reel][row]
	c["symbol"] = sym
	_scatter_tag(c, sym == "SCATTER")
	if c.get("plate") != null:
		c["plate"].visible = (sym == "COIN" and coin_val > 0)
	_aura_cella(c, sym)
	c["panel"].color = Color("#141821") if textures.has(sym) else SYMBOL_COLORS[sym].darkened(0.6)
	if sym == "DINAMITE" and not textures.has(sym):
		c["tex"].visible = false
		c["label"].text = "TNT"
		c["label"].add_theme_font_size_override("font_size", 30)
		c["label"].add_theme_color_override("font_color", Color("#ffe9a8"))
		c["label"].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		return
	if textures.has(sym):
		c["tex"].texture = textures[sym]; c["tex"].visible = true
		if sym == "WILD" and mult > 1:
			c["label"].text = "x"+str(mult); c["label"].add_theme_font_size_override("font_size",26)
			c["label"].vertical_alignment = VERTICAL_ALIGNMENT_TOP
			c["label"].add_theme_color_override("font_color", Color("#ffd700"))
		elif sym == "COIN" and coin_val != 0:
			if coin_val < 0:
				# TARGA jackpot: asset se esiste, altrimenti disegnata a codice
				var tname := "res://assets/targa_%s.png" % JP_NAME[coin_val].to_lower()
				if ResourceLoader.exists(tname):
					c["tex"].texture = load(tname)
					c["label"].text = ""
				elif ResourceLoader.exists("res://assets/targa_jackpot.png"):
					# targa generica + nome scritto dal codice, nel colore del livello
					c["tex"].texture = load("res://assets/targa_jackpot.png")
					c["tex"].visible = true
					c["label"].position = Vector2.ZERO
					c["label"].size = c["panel"].size
					c["label"].text = JP_NAME[coin_val]
					c["label"].add_theme_font_size_override("font_size", 22)
					c["label"].add_theme_color_override("font_color", JP_TXT[coin_val])
				else:
					c["tex"].visible = false
					c["panel"].color = JP_CELL_BG[coin_val]
					c["label"].text = JP_NAME[coin_val]
					c["label"].add_theme_font_size_override("font_size", 22)
					c["label"].add_theme_color_override("font_color", JP_TXT[coin_val])
			else:
				# il valore mostrato e' quello REALE alla puntata attuale
				var mostra := int(round(coin_val * float(_bet()) / float(SlotEngine.TOTAL_BET)))
				if c.get("plate") != null:
					# il numero sta DENTRO la placchetta; la label della cella resta vuota
					var nl: Label = c["plate"].get_meta("numlab")
					nl.text = _fmt(mostra)
					nl.add_theme_font_size_override("font_size", 21 if nl.text.length() <= 3 else (18 if nl.text.length() <= 5 else 15))
					c["label"].text = ""
				else:
					c["label"].text = _fmt(mostra)
					c["label"].position = Vector2.ZERO
					c["label"].size = c["panel"].size
					c["label"].add_theme_font_size_override("font_size", 32)
					c["label"].add_theme_constant_override("outline_size", 10)
					c["label"].add_theme_color_override("font_color", Color("#ffffff"))
			c["label"].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			c["label"].add_theme_color_override("font_outline_color", Color("#5a3c08"))
		else:
			c["label"].text = ""
			c["label"].position = Vector2.ZERO
			c["label"].size = c["panel"].size
			if sym == "SCATTER" and not ResourceLoader.exists("res://assets/scatter_tag.png"):
				# riserva: scritta SCATTER in testo se manca la targhetta assets/scatter_tag.png
				c["label"].text = "SCATTER"
				c["label"].add_theme_font_size_override("font_size", 13)
				c["label"].vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
				c["label"].add_theme_color_override("font_color", Color("#ffe9a8"))
				c["label"].add_theme_color_override("font_outline_color", Color("#2a1505"))
				c["label"].add_theme_constant_override("outline_size", 6)
		return
	c["tex"].visible = false
	c["label"].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if sym == "WILD" and mult > 1:
		c["label"].text = "M"+str(mult)
	elif sym == "COIN" and coin_val != 0:
		c["label"].text = JP_NAME[coin_val] if coin_val < 0 else str(coin_val)
	else:
		c["label"].text = SYMBOL_LETTERS[sym]
	c["label"].add_theme_color_override("font_color", SYMBOL_COLORS[sym])

func _update_piano_ui() -> void:
	_refresh_piano(false)

func _build_piano_medaglioni() -> void:
	if not SlotEngine.INDIZI_ATTIVI: return   # Midnight Case: niente indizi
	var mx := 18.0
	var my := 96.0
	var title := Label.new()
	title.text = T("piano")
	title.add_theme_font_size_override("font_size", 15)
	title.modulate = Color("#f5b73f")
	add_child(title)
	title.position = Vector2(mx + 6, my - 24)
	title.size = Vector2(120, 20)
	hud_nodes.append(title)
	var step := 152.0
	var msize := 130.0
	var icon := 118.0
	var fase := 0.0
	for tk in ["TOOL_RED", "TOOL_GREEN", "TOOL_BLUE"]:
		# nessuna sagoma: solo l'attrezzo, libero e vivo
		var back := Control.new()
		back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(back)
		back.position = Vector2(mx, my)
		back.size = Vector2(msize, msize)
		back.pivot_offset = Vector2(msize / 2.0, msize / 2.0)
		hud_nodes.append(back)
		# cornice-asset opzionale (assets/med_frame.png): l'attrezzo va DENTRO l'apertura
		var icon_l := icon
		var icon_cx := msize / 2.0
		var icon_cy := msize / 2.0
		if ResourceLoader.exists("res://assets/med_frame.png"):
			var fr := TextureRect.new()
			fr.texture = load("res://assets/med_frame.png")
			fr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			fr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			fr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fr.modulate = Color.WHITE.lerp(PIANO_COL[tk], 0.3)
			back.add_child(fr)
			fr.position = Vector2.ZERO
			fr.size = Vector2(msize, msize)
			icon_l = msize * 0.56
			icon_cy = msize * 0.52
		var dim := TextureRect.new()
		if textures.has(tk): dim.texture = textures[tk]
		dim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dim.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		dim.modulate = Color(0.26, 0.28, 0.36)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		back.add_child(dim)
		var icon_top := icon_cy - icon_l / 2.0
		dim.position = Vector2(icon_cx - icon_l / 2.0, icon_top)
		dim.size = Vector2(icon_l, icon_l)
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		back.add_child(clip)
		clip.position = Vector2(icon_cx - icon_l / 2.0, icon_top + icon_l)
		clip.size = Vector2(icon_l, 0)
		var bright := TextureRect.new()
		if textures.has(tk): bright.texture = textures[tk]
		bright.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bright.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bright.modulate = Color(1.18, 1.15, 1.02)
		bright.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.add_child(bright)
		bright.position = Vector2(0, -icon_l)
		bright.size = Vector2(icon_l, icon_l)
		piano_med[tk] = {"back": back, "clip": clip, "bright": bright, "icon": icon_l, "size": msize, "icon_top": icon_top, "pulse": null, "telegraph": null, "base_y": my}
		# fluttuazione continua: vivo anche da fermo
		var bob := create_tween().set_loops()
		bob.tween_property(back, "position:y", my + 5.0, 1.35 + fase).set_trans(Tween.TRANS_SINE)
		bob.tween_property(back, "position:y", my, 1.35 + fase).set_trans(Tween.TRANS_SINE)
		fase += 0.22
		my += step
	_refresh_piano(false)

func _piano_set_fill(tk: String, count: int, animate: bool) -> void:
	_piano_apply_frac(tk, _piano_frac_visibile(tk, count), animate)

# carica misteriosa: sale sempre, non arriva mai al pieno da sola.
# Curva 0.96 * (1 - e^(-3x)) con x = pezzi / CARICA_PIENA:
#   x=0.10 -> 25%   x=0.35 (sblocco tipico) -> 62%   x=0.55 -> 78% (pulsa)   x=1 -> 91%
func _piano_frac_visibile(tk: String, count: int) -> float:
	if count <= 0: return 0.0
	var x := float(count) / float(SlotEngine.CARICA_PIENA[tk])
	return clampf(0.96 * (1.0 - exp(-3.0 * x)), 0.0, 0.96)

func _piano_apply_frac(tk: String, f: float, animate: bool) -> void:
	if not piano_med.has(tk): return
	var med: Dictionary = piano_med[tk]
	var icon: float = med["icon"]
	var top: float = med.get("icon_top", (med["size"] - icon) / 2.0)
	var h: float = icon * clampf(f, 0.0, 1.0)
	var clip: Control = med["clip"]
	var bright: TextureRect = med["bright"]
	if animate:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(clip, "position:y", top + icon - h, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(clip, "size:y", h, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(bright, "position:y", -(icon - h), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		clip.position.y = top + icon - h
		clip.size.y = h
		bright.position.y = -(icon - h)
	# pulsazione: carica alta, puo' scattare da un momento all'altro
	if med["pulse"] != null:
		med["pulse"].kill(); med["pulse"] = null
		med["back"].scale = Vector2.ONE
	if f >= 0.78 and f < 1.0:
		var pt := create_tween().set_loops()
		pt.tween_property(med["back"], "scale", Vector2(1.06, 1.06), 0.5).set_trans(Tween.TRANS_SINE)
		pt.tween_property(med["back"], "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
		med["pulse"] = pt

func _refresh_piano(animate: bool) -> void:
	for tk in piano_med.keys():
		_piano_set_fill(tk, engine.lavagna[tk], animate)

func _telegraph_start(tk: String) -> void:
	if not piano_med.has(tk): return
	# "la macchina lo sa": il medaglione anticipa lo sblocco in arrivo
	var med: Dictionary = piano_med[tk]
	if med["telegraph"] != null: return
	if sfx_on:
		var nome := "sfx_pre_rosso" if tk == "TOOL_RED" else ("sfx_pre_verde" if tk == "TOOL_GREEN" else "sfx_pre_blu")
		var stp = _find_audio(nome)
		if stp != null:
			sfx_player.stream = stp
			sfx_player.play()
	var back: Control = med["back"]
	var tw: Tween
	if tk == "TOOL_RED":
		tw = create_tween().set_loops()
		tw.tween_property(back, "rotation_degrees", 4.0, 0.06)
		tw.tween_property(back, "rotation_degrees", -4.0, 0.06)
	elif tk == "TOOL_GREEN":
		tw = create_tween().set_loops()
		tw.tween_property(back, "scale", Vector2(1.10, 1.10), 0.32).set_trans(Tween.TRANS_SINE)
		tw.tween_property(back, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_SINE)
	else:
		tw = create_tween().set_loops()
		tw.tween_property(back, "modulate", Color(1.55, 1.55, 1.95), 0.35)
		tw.tween_property(back, "modulate", Color.WHITE, 0.35)
	med["telegraph"] = tw

func _telegraph_stop(tk: String) -> void:
	if not piano_med.has(tk): return
	var med: Dictionary = piano_med[tk]
	if med["telegraph"] != null:
		med["telegraph"].kill(); med["telegraph"] = null
	med["back"].rotation_degrees = 0.0
	med["back"].scale = Vector2.ONE
	med["back"].modulate = Color.WHITE

func _piano_center(tk: String) -> Vector2:
	if not piano_med.has(tk): return Vector2(70, 300)
	var med: Dictionary = piano_med[tk]
	return med["back"].position + Vector2(med["size"] / 2.0, med["size"] / 2.0)

func _sfx_tool() -> void:
	if not sfx_on: return
	var stream = _find_audio("sfx_tool")
	if stream == null: stream = _find_audio("sfx_unlock")
	if stream == null: return
	sfx_player.stream = stream
	sfx_player.play()

func _fly_tool(reel: int, row: int, tk: String) -> void:
	var start: Vector2 = grid_root.position + grid_root.scale * (cells[reel][row]["panel"].position + Vector2(CELL / 2.0, CELL / 2.0))
	await _fly_from(start, tk)

func _fly_tracked(start: Vector2, tk: String, stato: Dictionary, delay: float) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	await _fly_from(start, tk)
	stato["fatti"] += 1

func _fly_from(start: Vector2, tk: String) -> void:
	var target := _piano_center(tk)
	if sfx_on:
		var wst = _find_audio("sfx_whoosh")
		if wst != null:
			_play_limited(spin_sfx_player, wst, "sfx_whoosh")
	var streak := TextureRect.new()
	if textures.has(tk): streak.texture = textures[tk]
	streak.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	streak.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	streak.mouse_filter = Control.MOUSE_FILTER_IGNORE
	streak.modulate = Color(1.7, 1.5, 0.95)
	add_child(streak)
	streak.size = Vector2(50, 50)
	streak.position = start - streak.size / 2.0
	streak.pivot_offset = streak.size / 2.0
	streak.z_index = 50
	# arco: punto di controllo alto tra partenza e arrivo
	var ctrl := Vector2((start.x + target.x) / 2.0, minf(start.y, target.y) - 100.0)
	var dur := 0.5
	var tme := 0.0
	var frame_i := 0
	while tme < dur:
		await get_tree().create_timer(0.016).timeout
		if not is_instance_valid(streak):
			return
		var dt := get_process_delta_time()
		tme += dt
		var u := clampf(tme / dur, 0.0, 1.0)
		var q1 := start.lerp(ctrl, u)
		var q2 := ctrl.lerp(target, u)
		var pos := q1.lerp(q2, u)
		streak.position = pos - streak.size / 2.0
		streak.rotation_degrees += 640.0 * dt
		var sc := lerpf(1.0, 0.62, u) + 0.30 * sin(PI * u)
		streak.scale = Vector2(sc, sc)
		# scia di fantasmi che sfumano
		frame_i += 1
		if frame_i % 2 == 0:
			var g := TextureRect.new()
			g.texture = streak.texture
			g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			g.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(g)
			g.size = streak.size
			g.position = streak.position
			g.rotation_degrees = streak.rotation_degrees
			g.pivot_offset = g.size / 2.0
			g.scale = streak.scale
			g.modulate = Color(1.5, 1.25, 0.7, 0.45)
			g.z_index = 49
			var gt := create_tween().set_parallel(true)
			gt.tween_property(g, "modulate:a", 0.0, 0.28)
			gt.tween_property(g, "scale", g.scale * 0.7, 0.28)
			gt.chain().tween_callback(g.queue_free)
	streak.queue_free()
	_sfx_tool()
	var med: Dictionary = piano_med[tk]
	var bump := create_tween()
	bump.tween_property(med["back"], "scale", Vector2(1.18, 1.18), 0.1)
	bump.tween_property(med["back"], "scale", Vector2.ONE, 0.12)

func _explode_medallion(tk: String) -> void:
	if not piano_med.has(tk): return
	_telegraph_stop(tk)
	var med: Dictionary = piano_med[tk]
	# si riempie fino in cima A VISTA, poi scoppia
	_piano_apply_frac(tk, 1.0, true)
	await get_tree().create_timer(0.45).timeout
	if not is_instance_valid(med["back"]): return
	_sfx("sfx_jackpot")
	var back: Control = med["back"]
	var tw := create_tween()
	tw.tween_property(back, "scale", Vector2(1.5, 1.5), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(back, "scale", Vector2.ONE, 0.2)
	# schegge colorate
	var c := _piano_center(tk)
	for i in 12:
		var s := ColorRect.new()
		s.color = PIANO_COL[tk].lightened(0.3)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		s.size = Vector2(10, 10)
		s.position = c - Vector2(5, 5)
		s.z_index = 60
		var ang := randf_range(0, TAU)
		var dist := randf_range(70, 170)
		var st := create_tween().set_parallel(true)
		st.tween_property(s, "position", s.position + Vector2(cos(ang), sin(ang)) * dist, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		st.tween_property(s, "modulate:a", 0.0, 0.5)
		st.chain().tween_callback(s.queue_free)
	await _fine(tw)
	_piano_set_fill(tk, engine.lavagna[tk], true)   # scende all'avanzo (carry-over)

func _tint_reel(reel: int, tint: Color) -> void:
	for row in ROWS: cells[reel][row]["panel"].modulate = tint
func _tint_all(tint: Color) -> void:
	for reel in REELS: _tint_reel(reel, tint)

func _fill_random_grid() -> void:
	var s := engine.spin_grid(false)
	for reel in REELS:
		for row in ROWS:
			_set_cell(reel, row, s["grid"][reel][row], s["mults"][reel][row], s["coins"][reel][row])

func _spazza_scene() -> void:
	# via ogni scena/overlay residuo (se un errore ha interrotto un bonus, qui si ripulisce)
	for nd in get_tree().get_nodes_in_group("scena_bonus"):
		if is_instance_valid(nd): nd.queue_free()
	_cerimonia_chiudi()
	_bonus_hud_distruggi()
	_respin_luci_distruggi()
	if verita_lay != null and is_instance_valid(verita_lay):
		verita_lay.queue_free(); verita_lay = null
	grid_root.z_index = 0
	if mastermind_node != null:
		mastermind_node.visible = true
		mastermind_node.rotation_degrees = 0.0
	for nd in hud_nodes:
		if is_instance_valid(nd): nd.visible = true
	win_label.visible = true
	dinamite_lanciata = false
	reel_suspense = 1.0

var spin_watchdog_id := 0
var input_gate: Control = null
var autospin_left := 0        # 0 = spento; -1 = infinito
var auto_button: BaseButton = null
var auto_label: Label = null

var watchdog_nutrito := 0.0

func _nutri_watchdog() -> void:
	watchdog_nutrito = Time.get_ticks_msec() / 1000.0

func _watchdog(id: int) -> void:
	# se per 60 s non c'e' NESSUNA attivita', qualcosa e' morto: sblocco e ripulisco
	_nutri_watchdog()
	while spinning and spin_watchdog_id == id:
		await get_tree().create_timer(1.0).timeout
		if Time.get_ticks_msec() / 1000.0 - watchdog_nutrito > 60.0:
			break
	if spinning and spin_watchdog_id == id:
		push_warning("WATCHDOG: spin bloccato, sblocco forzato")
		_spazza_scene()
		_tint_all(Color.WHITE)
		_bonus_exit_forzata()
		if input_gate != null: input_gate.visible = false
		spinning = false

func _bonus_exit_forzata() -> void:
	grid_root.position = Vector2(GRID_X, GRID_Y)
	grid_root.scale = Vector2.ONE
	if fx_layer != null and is_instance_valid(fx_layer):
		fx_layer.queue_free(); fx_layer = null

func _on_auto_pressed() -> void:
	if autospin_left != 0:
		_autospin_stop()   # tap su STOP
		return
	# menu di scelta dei giri
	_apri_auto_scelta()

func _apri_auto_scelta() -> void:
	var lay := Control.new()
	lay.name = "auto_scelta"
	lay.size = Vector2(VW, VH)
	add_child(lay)
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.55); veil.size = Vector2(VW, VH)
	veil.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed: lay.queue_free())
	lay.add_child(veil)
	var opzioni := [["10", 10], ["25", 25], ["50", 50], ["∞", -1]]
	var larg := 120.0; var gap := 20.0
	var tot := opzioni.size() * larg + (opzioni.size() - 1) * gap
	var x0 := (VW - tot) / 2.0
	var tit := _etichetta(T("auto_scegli"), 26, Color("#ffe9a8"), Color("#3a2405"), 8)
	lay.add_child(tit); tit.size = Vector2(VW, 40); tit.position = Vector2(0, VH / 2.0 - 90.0)
	for i in opzioni.size():
		var b := Button.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#c9a24a"); sb.corner_radius_top_left = 16; sb.corner_radius_top_right = 16
		sb.corner_radius_bottom_left = 16; sb.corner_radius_bottom_right = 16
		b.add_theme_stylebox_override("normal", sb); b.add_theme_stylebox_override("hover", sb); b.add_theme_stylebox_override("pressed", sb)
		b.add_theme_font_size_override("font_size", 34); b.add_theme_color_override("font_color", Color("#1a1206"))
		b.text = opzioni[i][0]
		b.size = Vector2(larg, 100); b.position = Vector2(x0 + i * (larg + gap), VH / 2.0 - 30.0)
		var n: int = opzioni[i][1]
		b.pressed.connect(func():
			lay.queue_free()
			_autospin_start(n))
		lay.add_child(b)

func _autospin_start(n: int) -> void:
	autospin_left = n
	_autospin_refresh()
	if not spinning:
		_on_spin_pressed()

func _autospin_stop() -> void:
	autospin_left = 0
	_autospin_refresh()

func _autospin_refresh() -> void:
	if auto_button == null or not is_instance_valid(auto_button): return
	var testo := ""
	if autospin_left < 0: testo = "STOP ∞"
	elif autospin_left > 0: testo = "STOP %d" % autospin_left
	if stop_tex != null and auto_button is TextureButton:
		# STOP illustrato: scambio l'immagine e mostro il bollino coi giri rimasti
		var tb := auto_button as TextureButton
		tb.texture_normal = stop_tex if autospin_left != 0 else auto_tex
		if auto_badge != null and is_instance_valid(auto_badge):
			auto_badge.visible = (autospin_left != 0)
			if auto_badge_label != null and is_instance_valid(auto_badge_label):
				auto_badge_label.text = "∞" if autospin_left < 0 else str(autospin_left)
				auto_badge_label.add_theme_font_size_override("font_size", 15 if autospin_left < 100 else 12)
		if auto_stop_plate != null and is_instance_valid(auto_stop_plate): auto_stop_plate.visible = false
		return
	if auto_stop_plate != null and is_instance_valid(auto_stop_plate):
		# riserva: targhetta STOP sopra l'immagine (a due righe)
		auto_stop_plate.visible = (autospin_left != 0)
		# il tasto sotto si scurisce (self_modulate: la targhetta figlia non ne risente)
		auto_button.self_modulate = Color(0.35, 0.35, 0.35) if autospin_left != 0 else Color.WHITE
		if auto_label != null and is_instance_valid(auto_label):
			auto_label.text = testo.replace(" ", "\n")
		return
	if auto_button is Button:
		if autospin_left == 0:
			auto_button.text = "AUTO"
			auto_button.add_theme_color_override("font_color", Color("#f5b73f"))
		else:
			auto_button.text = testo
			auto_button.add_theme_color_override("font_color", Color("#ff6b6b"))

func _on_spin_pressed() -> void:
	# doppio click = fast drop
	var now := Time.get_ticks_msec() / 1000.0
	if spinning:
		if now - last_spin_click < 0.12:
			return   # raffica: ignoro le pressioni troppo ravvicinate
		if now - last_spin_click < 0.5:
			request_fastdrop = true
		last_spin_click = now
		return
	last_spin_click = now
	if balance < _bet():
		win_label.text = T("finite")
		_ricarica_cortesia()
		return
	spinning = true; request_fastdrop = false
	if input_gate != null: input_gate.visible = true
	_dbg("A inizio spin")
	if sfx_on:
		var sp = _find_audio("sfx_spin")
		if sp != null:
			spin_sfx_player.stream = sp
			spin_sfx_player.play()
	if spin_hitbox: spin_hitbox.disabled = true
	win_label.text = ""; balance -= _bet(); _update_balance()
	_tint_all(Color.WHITE)

	var scale := float(_bet()) / float(SlotEngine.TOTAL_BET)
	var result: Dictionary = engine.play_spin()
	_dbg("B esito calcolato")
	var final_grid: Array = result["grid"]

	_chiudi_bet_schermo()
	_spazza_scene()
	spin_watchdog_id += 1
	_watchdog(spin_watchdog_id)
	# rete di sicurezza: nessuna striscia orfana deve sopravvivere
	for sv in col_strips:
		if sv is Dictionary:
			sv["finished"] = true
			sv["stopping"] = true
			if is_instance_valid(sv.get("win")):
				sv["win"].queue_free()
	col_strips.clear()
	reel_suspense = 1.0
	_reels_start_all()
	_dbg("C rulli partiti")
	# la macchina lo sa: se uno sblocco arrivera', il medaglione freme
	if result.has("scasso") or result.has("super"): _telegraph_start("TOOL_RED")
	if result.has("taglio") or result.has("super"): _telegraph_start("TOOL_GREEN")
	if result.has("rapina") or result.has("super"): _telegraph_start("TOOL_BLUE")
	if result.has("cassaforte"): _presagio_start(Color("#ffd700"), "sfx_pre_cassa")
	if result["free_spins"].size() > 0: _presagio_start(Color("#ff5252"), "sfx_pre_colpo")
	await _wait(FIRST_STOP)
	var scatters := 0
	var sacchi := 0
	for reel in REELS:
		_dbg("D stop rullo %d..." % reel)
		await _reel_stop(reel, final_grid, result["mults"], result["coins"], result.get("grid_pre"), result.get("espansi", []))
		_dbg("D rullo %d a terra" % reel)
		for row in ROWS:
			if final_grid[reel][row] == "SCATTER": scatters += 1
			elif final_grid[reel][row] == "COIN": sacchi += 1
		if reel < REELS-1:
			var gap := STOP_GAP_STRIP
			if true:
				# suspense PROGRESSIVA sulle casseforti del Colpo
				if scatters >= 3:
					if verita_lay != null:
						_momento_verita_fine()
					_play_music("music_tension")
					_sfx("sfx_anticipation")
					reel_suspense = 0.35
					# esplosiva: i rulli che girano lampeggiano oro/rosso
					for i in 6:
						for r in range(reel+1, REELS):
							_reel_tint(r, Color("#ffd700") if i % 2 == 0 else Color("#ff5252"))
						await get_tree().create_timer(0.22).timeout
					gap = 0.25
				elif scatters == 2:
					_play_music("music_tension")
					if result["free_spins"].size() > 0 and verita_lay == null:
						# la macchina lo sa: la terza arrivera'. Momento della verita'.
						await _momento_verita(reel)
						gap = 0.2
					else:
						_sfx("sfx_anticipation")
						for r in range(reel+1, REELS): _reel_tint(r, Color("#ff5252"))
						reel_suspense = 0.45
						gap = ANTICIPATION_GAP
				elif scatters == 1:
					# gia' dalla PRIMA cassaforte: ambra forte e rulli che rallentano
					for r in range(reel+1, REELS): _reel_tint(r, Color(1.5, 1.18, 0.5))
					reel_suspense = 0.55
					gap = 0.8
				# suspense sui sacchi vicini alla Cassaforte
				if sacchi >= 6 and verita_lay != null:
					_momento_verita_fine()
					_flash_schermo(Color("#ffd700"), 0.35, 0.5)
				if sacchi == 5 and scatters < 2 and result.has("cassaforte") and verita_lay == null:
					# la macchina lo sa: il sesto sacco arrivera'
					await _momento_verita(reel, "manca_sacco", Color("#ffd700"))
					gap = 0.2
				elif sacchi >= 5 and scatters < 2:
					_sfx("sfx_anticipation")
					for r in range(reel+1, REELS): _reel_tint(r, Color("#ffd700"))
					reel_suspense = minf(reel_suspense, 0.45)
					gap = maxf(gap, 1.1)
				elif sacchi == 4 and scatters == 0:
					for r in range(reel+1, REELS): _reel_tint(r, Color(1.4, 1.22, 0.5))
					reel_suspense = minf(reel_suspense, 0.6)
					gap = maxf(gap, 0.65)
			# le attese di suspense NON vengono accorciate
			_dbg("D%d attesa gap=%.2f" % [reel, gap])
			if gap > STOP_GAP_STRIP:
				await get_tree().create_timer(gap).timeout
			else:
				await _wait(gap)
			_dbg("D%d attesa finita" % reel)
	reel_suspense = 1.0
	if verita_lay != null:
		await _momento_verita_fine()
	_tint_all(Color.WHITE)
	spin_sfx_player.stop()
	_presagi_stop()

	# attrezzi del Piano: fasci PARALLELI (sfalsati) verso i medaglioni
	var tool_cells: Array = []
	for reel in REELS:
		for row in ROWS:
			var symt: String = final_grid[reel][row]
			if symt.begins_with("TOOL_"):
				tool_cells.append([reel, row, symt])
	var n_beams := tool_cells.size()
	if result.has("pioggia"):
		n_beams += result["pioggia"]["pezzi"]
	if n_beams > 0:
		var stato := {"fatti": 0}
		var bi := 0
		for tc in tool_cells:
			cells[tc[0]][tc[1]]["panel"].modulate = Color(1.3, 1.2, 0.85)
			var st: Vector2 = grid_root.position + grid_root.scale * (cells[tc[0]][tc[1]]["panel"].position + Vector2(CELL / 2.0, CELL / 2.0))
			_fly_tracked(st, tc[2], stato, bi * 0.08)
			bi += 1
		if result.has("pioggia"):
			_pioggia_fx()
			_sfx("sfx_unlock")
			for j in result["pioggia"]["pezzi"]:
				var sky := Vector2(randf_range(240.0, 720.0), -40.0)
				_fly_tracked(sky, result["pioggia"]["colore"], stato, bi * 0.08)
				bi += 1
		var t_fasci := 0.0
		while stato["fatti"] < n_beams and t_fasci < 6.0:
			t_fasci += 0.05
			await get_tree().create_timer(0.016).timeout
		for tc in tool_cells:
			cells[tc[0]][tc[1]]["panel"].modulate = Color.WHITE
		# le cariche salgono (pezzi visti ora: rulli base + pioggia;
		# quelli dei free spin arrivano a fine bonus)
		var conto := {}
		for k2 in engine.lavagna.keys():
			conto[k2] = result["lavagna_pre"][k2] if result.has("lavagna_pre") else 0
		for tc in tool_cells:
			conto[tc[2]] += 1
		if result.has("pioggia"):
			conto[result["pioggia"]["colore"]] += result["pioggia"]["pezzi"]
		for k2 in conto.keys():
			_piano_set_fill(k2, conto[k2], true)
		await get_tree().create_timer(0.25).timeout

	var base_win := int(round((result["base"]["line_win"] + result["base"]["scatter_win"]) * scale))
	_dbg("E vincita valutata")
	if base_win > 0:
		_flash(_winning_cells_of(final_grid, result["base"]))
		if base_win >= _bet() * 15:
			await _celebra_vincita(base_win)
			_dbg("F celebrazione finita")
		await _count_up(T("bottino"), base_win, _t(1.0))
		balance += base_win; _update_balance()
	elif result.has("cassaforte") == false and result["free_spins"].is_empty():
		win_label.text = T("fallito")

	_dbg("G prima dei bonus")
	if result.has("cassaforte"): await _play_cassaforte(result, scale)
	if result["free_spins"].size() > 0: await _play_heist(result, scale)
	if result.has("super") and result.has("scasso") and result.has("taglio") and result.has("rapina"):
		await _play_supremo(result, scale)
	else:
		if result.has("scasso"):
			await _explode_medallion("TOOL_RED")
			await _cerimonia_sblocco("TOOL_RED")
			await _play_scasso(result, scale)
		if result.has("taglio"):
			await _explode_medallion("TOOL_GREEN")
			await _cerimonia_sblocco("TOOL_GREEN")
			await _play_taglio(result, scale)
		if result.has("rapina"):
			await _explode_medallion("TOOL_BLUE")
			await _cerimonia_sblocco("TOOL_BLUE")
			await _play_cassaforte(result, scale, "rapina")
	for tkx in piano_med.keys():
		_telegraph_stop(tkx)
	_refresh_piano(true)

	if mastermind_node != null and mm_normal != null:
		mm_frames_attivi = "idle"
		if mm_idle_frames.size() < 2:
			mastermind_node.texture = mm_normal
	_play_music("music_base")
	if input_gate != null: input_gate.visible = false
	spinning = false
	spin_dal_salvataggio += 1
	if spin_dal_salvataggio >= 5:
		spin_dal_salvataggio = 0
		_salva_stato()
	if spin_hitbox: spin_hitbox.disabled = false
	# AUTOSPIN: continua se attivo, ma fermati sui bonus e a saldo finito
	if autospin_left != 0:
		var bonus_scattato: bool = result.has("cassaforte") or (not result["free_spins"].is_empty()) or result.has("scasso") or result.has("taglio") or result.has("rapina")
		if bonus_scattato or balance < _bet():
			_autospin_stop()
		else:
			if autospin_left > 0:
				autospin_left -= 1
			_autospin_refresh()
			if autospin_left != 0:
				await get_tree().create_timer(0.35).timeout
				if autospin_left != 0 and not spinning:
					_on_spin_pressed()

# attesa che si interrompe col fast-drop
# attesa ROBUSTA della fine di un tween: controlla, non aspetta un segnale; tetto di sicurezza
func _fine(tw: Tween, max_s: float = 6.0) -> void:
	var t := 0.0
	while is_instance_valid(tw) and tw.is_valid() and tw.is_running() and t < max_s:
		_nutri_watchdog()
		await get_tree().create_timer(0.016).timeout
		t += 0.016

# ================= RISCALDAMENTO SHADER (web) =================
# Disegna una volta, quasi invisibile, ogni tipo di elemento grafico usato
# dagli effetti: le compilazioni degli shader avvengono ORA e mai in gioco.
func _riscalda_shader() -> void:
	var lay := Node2D.new()
	add_child(lay)
	lay.z_index = 150
	lay.modulate = Color(1, 1, 1, 0.02)
	# poligono (raggi, puntatore, disco di ripiego)
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(0,0), Vector2(60,10), Vector2(30,60), Vector2(-20,40)])
	poly.color = Color("#ffd700")
	lay.add_child(poly); poly.position = Vector2(200, 200)
	# linea (bordi della manopola, tacche)
	var ln := Line2D.new()
	ln.points = PackedVector2Array([Vector2(0,0), Vector2(80,20), Vector2(120,0)])
	ln.width = 4.0; ln.default_color = Color("#f5b73f")
	lay.add_child(ln); ln.position = Vector2(300, 200)
	# gradienti radiali (aloni, anelli, vignetta) e lineare (spada di luce)
	for tx in [_glow_texture(Color("#ffd700")), _glow_texture(Color("#ff5252")), _glow_texture(Color("#3a6fd8")), _ring_texture(Color("#ffd700")), _ring_texture(Color("#ff7a1c"))]:
		var tr := TextureRect.new()
		tr.texture = tx; tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lay.add_child(tr); tr.size = Vector2(64, 64); tr.position = Vector2(400, 200)
		tr.modulate = Color(1.5, 1.2, 0.8, 0.5)   # modulate > 1: variante shader dei lampeggi
	# texture del gioco con modulate/rotazione/scala (celle, monete, frame)
	var keys := ["fx_coin", "diamante", "frammento", "disco_cassaforte", "sacco_plate", "banner_targa", "banner_scena", "targa_jackpot", "med_frame", "scasso_cassaforte_chiusa", "scasso_polizia", "sfondo_colpo", "detective_talk", "detective_lancio", "detective_furia", "detective_win_coins"]
	for k in keys:
		var p := "res://assets/%s.png" % k
		if ResourceLoader.exists(p):
			var t2 := TextureRect.new()
			t2.texture = load(p); t2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			lay.add_child(t2); t2.size = Vector2(48, 48); t2.position = Vector2(500, 200)
			t2.rotation_degrees = 15.0; t2.modulate = Color(0.6, 0.6, 0.7)
	for k in textures.keys():
		var t3 := TextureRect.new()
		t3.texture = textures[k]; t3.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lay.add_child(t3); t3.size = Vector2(32, 32); t3.position = Vector2(560, 200)
	# rettangoli colorati (veli, pannelli), pannelli con StyleBox (targhe, luci), label con contorno
	var cr := ColorRect.new(); cr.color = Color(0, 0, 0, 0.5); lay.add_child(cr); cr.size = Vector2(80, 40); cr.position = Vector2(640, 200)
	var pn := Panel.new(); var sb := StyleBoxFlat.new(); _stile_targa(sb, Color("#c8501c"), Color("#ffd27a"), 20)
	pn.add_theme_stylebox_override("panel", sb); lay.add_child(pn); pn.size = Vector2(80, 40); pn.position = Vector2(740, 200)
	var lb := _etichetta("x27 1.000", 40, Color("#ffd700"), Color("#5a1a05"), 16); lay.add_child(lb); lb.position = Vector2(200, 300); lb.size = Vector2(300, 60)
	var rt := RichTextLabel.new(); rt.bbcode_enabled = true; rt.text = "[color=#ffd700]w[/color]"; lay.add_child(rt); rt.size = Vector2(40, 30); rt.position = Vector2(520, 300)
	# due frame di disegno, poi via tutto
	await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.05).timeout
	lay.queue_free()

func _wait(seconds: float) -> void:
	_nutri_watchdog()
	if request_fastdrop:
		await get_tree().create_timer(0.02).timeout
		return
	await get_tree().create_timer(_t(seconds)).timeout

# ================= RULLI A SCORRIMENTO VERO =================
# Una "striscia" e' una finestra ritagliata sopra la colonna (o la
# singola cella) dentro cui i simboli scorrono in verticale. Alla
# richiesta di stop, i simboli finali entrano dall'alto e la striscia
# atterra con un rimbalzo. Le celle vere vengono rivelate sotto.

func _make_strip(x: float, y: float, visible_rows: int) -> Dictionary:
	var win := Control.new()
	win.clip_contents = true
	win.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid_root.add_child(win)
	win.position = Vector2(x, y)
	win.size = Vector2(CELL, visible_rows * PITCH - GAP)
	win.z_index = 5
	var bg := ColorRect.new()
	bg.color = Color("#0d1119")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win.add_child(bg)
	bg.size = win.size
	var strip := Control.new()
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win.add_child(strip)
	var texs: Array = []
	for i in visible_rows + 1:
		var tr := TextureRect.new()
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_child(tr)
		tr.position = Vector2(4, i * PITCH - PITCH + 4)
		tr.size = Vector2(CELL - 8, CELL - 8)
		texs.append(tr)
	return {"win": win, "strip": strip, "texs": texs, "offset": 0.0,
			"stopping": false, "queue": [], "finished": false}

func _rand_symbol_texture() -> Texture2D:
	var s := engine._pick_symbol(false)
	return textures[s] if textures.has(s) else null

func _strip_seed(s: Dictionary, coins_only: bool) -> void:
	for tr in s["texs"]:
		tr.texture = textures.get("COIN") if coins_only else _rand_symbol_texture()

func _strip_shift(s: Dictionary, coins_only: bool) -> void:
	var texs: Array = s["texs"]
	for i in range(texs.size() - 1, 0, -1):
		texs[i].texture = texs[i - 1].texture
	if s["queue"].size() > 0:
		texs[0].texture = s["queue"].pop_front()
	else:
		texs[0].texture = textures.get("COIN") if coins_only else _rand_symbol_texture()

func _strip_run(s: Dictionary, speed: float, coins_only: bool = false) -> void:
	while true:
		await get_tree().create_timer(0.016).timeout
		if not is_instance_valid(s["win"]):
			return
		# la suspense vince su turbo e caduta rapida
		var mult := 1.0
		if reel_suspense < 1.0:
			mult = reel_suspense
		elif request_fastdrop:
			mult = 2.4
		elif turbo:
			mult = 1.5
		var v := speed * mult
		s["offset"] += v * minf(get_process_delta_time(), 0.05)
		var landed := false
		# atterraggio d'ufficio: se lo stop e' stato chiesto da >3 s, scarico tutto e mi poso
		if s["stopping"]:
			s["t_stop"] = s.get("t_stop", 0.0) + 0.016
			if s["t_stop"] > 3.0:
				var guardia := 0
				while not s["queue"].is_empty() and guardia < 12:
					_strip_shift(s, coins_only)
					guardia += 1
				landed = true
		while not landed and s["offset"] >= PITCH:
			s["offset"] -= PITCH
			_strip_shift(s, coins_only)
			if s["stopping"] and s["queue"].is_empty():
				landed = true
				break
		if landed:
			s["offset"] = 0.0
			s["strip"].position.y = 0.0
			break
		s["strip"].position.y = s["offset"]
	# rimbalzo d'atterraggio (attesa robusta: controllo, non segnale)
	if is_instance_valid(s["strip"]):
		var tw := create_tween()
		tw.tween_property(s["strip"], "position:y", 13.0, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(s["strip"], "position:y", 0.0, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var guard := 0
		while tw.is_running() and guard < 60:
			await get_tree().create_timer(0.016).timeout
			guard += 1
	s["finished"] = true

func _strip_stop_with(s: Dictionary, entry_textures: Array) -> void:
	s["queue"] = entry_textures.duplicate()
	s["stopping"] = true

func _reels_start_all() -> void:
	col_strips.clear()
	for reel in REELS:
		var s := _make_strip(reel * PITCH, 0.0, ROWS)
		_strip_seed(s, false)
		col_strips.append(s)
		_strip_run(s, SPIN_SPEED)

func _reel_stop(reel: int, grid: Array, mults: Array, coins, grid_pre = null, espansi: Array = []) -> void:
	var s: Dictionary = col_strips[reel]
	# atterrano i simboli ORIGINALI (prima dell'espansione del WILD)
	var g_land: Array = grid_pre if grid_pre != null else grid
	# nel Colpo la dinamite la lancia il Mastermind: la cella atterra con una gemma finta
	var finti := {}
	if dinamite_lanciata:
		for row in ROWS:
			if String(g_land[reel][row]) == "DINAMITE":
				finti[row] = ["GEM_RED", "GEM_BLUE", "GEM_GREEN", "GEM_PURPLE"][randi() % 4]
	var entry: Array = []
	for row in range(ROWS - 1, -1, -1):
		var sym: String = finti[row] if finti.has(row) else g_land[reel][row]
		entry.append(textures[sym] if textures.has(sym) else null)
	entry.append(_rand_symbol_texture())
	_strip_stop_with(s, entry)
	_nutri_watchdog()
	_dbg("D%d attendo striscia" % reel)
	var t_att := 0.0
	while not s["finished"] and t_att < 4.0:
		await get_tree().create_timer(0.016).timeout
		t_att += get_process_delta_time()
	if not s["finished"]:
		push_warning("rullo %d forzato a terra" % reel)
		s["finished"] = true
	for row in ROWS:
		var cv: int = coins[reel][row] if coins != null else 0
		if finti.has(row):
			_set_cell(reel, row, finti[row], 1, 0)
			_landing_fx(reel, row, finti[row])
			continue
		_set_cell(reel, row, g_land[reel][row], mults[reel][row] if g_land[reel][row] == "WILD" else 1, cv)
		_landing_fx(reel, row, String(g_land[reel][row]))
	if is_instance_valid(s.get("win")):
		s["win"].queue_free()
	if espansi.has(reel):
		await _espandi_wild(reel, grid, mults, g_land)
	if sfx_on:
		var st = _find_audio("sfx_reel_stop")
		if st == null: st = _find_audio("sfx_reel")
		if st != null:
			_play_limited(spin_sfx_player, st, "sfx_reel_stop")

func _reel_tint(reel: int, c: Color) -> void:
	if reel < col_strips.size() and is_instance_valid(col_strips[reel]["win"]):
		col_strips[reel]["win"].modulate = c

func _play_cassaforte(result: Dictionary, scale: float, bonus_key: String = "cassaforte") -> void:
	_dbg("H cassaforte inizio")
	var cassa: Dictionary = result[bonus_key]
	var fresh := bonus_key == "rapina"   # la Rapina parte a griglia vuota
	if cerimonia_lay != null and is_instance_valid(cerimonia_lay):
		var cl := cerimonia_lay
		cerimonia_lay = null
		var fo := create_tween()
		fo.tween_property(cl, "modulate:a", 0.0, 0.45)
		fo.tween_callback(cl.queue_free)
	var hud_key := "rapina_hud" if fresh else "cassa_hud"
	for i in 4:
		_tint_all(Color("#ffd700") if i%2==0 else Color.WHITE); await get_tree().create_timer(0.2).timeout
	_sfx("sfx_unlock" if fresh else "sfx_bonus_unlock")
	_play_music("music_bonus")
	await _bonus_enter()
	_fx_start("banner_cassaforte", Color(0.05, 0.09, 0.20, 0.26))
	_tint_all(Color.WHITE)
	var loot := 0
	var locked := {}
	for reel in REELS:
		for row in ROWS:
			if not fresh and result["grid"][reel][row] == "COIN":
				var iv: int = result["coins"][reel][row]
				_set_cell(reel,row,"COIN",1,iv); loot += JP_PAY[iv] if iv < 0 else iv
				if iv >= 0:
					cells[reel][row]["panel"].color = Color("#191207")
				locked["%d_%d" % [reel,row]] = true
				_glow_lock(reel, row)
			else:
				cells[reel][row]["symbol"]=""; cells[reel][row]["panel"].color=Color("#0a0e14")
				cells[reel][row]["label"].text=""; cells[reel][row]["tex"].visible=false
				if cells[reel][row].get("plate") != null: cells[reel][row]["plate"].visible = false
				_aura_cella(cells[reel][row], "")
	if fresh:
		await _targa_banner(T("rapina"), Color("#3a6fd8"), 1.0)
	var respin := 3
	fs_info.text = ""
	_bonus_hud_crea("cassaforte")
	_bonus_hud_loot(int(round(loot*scale)))
	_respin_luci_crea()
	_respin_luci_set(respin, true)
	await get_tree().create_timer(0.8).timeout
	for ev in cassa["events"]:
		# celle vuote: mini-rulli di sacchi che SCORRONO davvero
		var cell_strips: Array = []
		for reel in REELS:
			for row in ROWS:
				var key := "%d_%d" % [reel,row]
				if not locked.has(key):
					var cs := _make_strip(reel * PITCH, row * PITCH, 1)
					_strip_seed(cs, true)
					cs["reel"] = reel
					cell_strips.append(cs)
		# partenza a onda da sinistra, velocita' leggermente diverse
		for cs in cell_strips:
			_strip_run(cs, CASSA_SPIN_SPEED * randf_range(0.85, 1.05), true)
			await get_tree().create_timer(0.035).timeout
		await get_tree().create_timer(0.55).timeout
		# stop a onda, colonna per colonna
		var last_reel := -1
		for cs in cell_strips:
			if cs["reel"] != last_reel and last_reel != -1:
				await get_tree().create_timer(0.12).timeout
			last_reel = cs["reel"]
			_strip_stop_with(cs, [textures.get("COIN"), textures.get("COIN")])
		for cs in cell_strips:
			var t_cs := 0.0
			while not cs["finished"] and t_cs < 4.0:
				await get_tree().create_timer(0.016).timeout
				t_cs += get_process_delta_time()
			if is_instance_valid(cs["win"]): cs["win"].queue_free()
		# ripulisci e rivela gli atterraggi di questo respin
		for reel in REELS:
			for row in ROWS:
				var key := "%d_%d" % [reel,row]
				if not locked.has(key):
					var c: Dictionary = cells[reel][row]
					c["tex"].visible = false; c["tex"].modulate = Color.WHITE
					c["label"].text = ""
					if c.get("plate") != null: c["plate"].visible = false
					_aura_cella(c, "")
					c["panel"].color = Color("#0a0e14")
		if ev["landed"].size() > 0:
			for l in ev["landed"]:
				var lv: int = l[2]
				_set_cell(l[0],l[1],"COIN",1,lv); loot += JP_PAY[lv] if lv < 0 else lv
				locked["%d_%d" % [l[0],l[1]]] = true
				if lv < 0:
					_sfx("sfx_jackpot")
					_targa_banner(T("vinto") % JP_NAME[lv], JP_TXT[lv], 0.55)
					_burst_money(12)
					await get_tree().create_timer(0.6).timeout
				else:
					_sfx("sfx_sack_land")
				var cpos := _cell_center(l[0], l[1])
				if lv >= 0:
					_shockwave(cpos, Color("#ffd700"), 170.0)
					_scintille(cpos, Color("#ffd700"), 10)
					_shake(3.0, 0.18)
					cells[l[0]][l[1]]["panel"].color = Color("#ffd700")
					await get_tree().create_timer(0.25).timeout
					cells[l[0]][l[1]]["panel"].color = Color("#191207")
				else:
					_flash_schermo(JP_TXT[lv], 0.32, 0.5)
					_shockwave(cpos, JP_TXT[lv], 320.0)
					_scintille(cpos, JP_TXT[lv], 16)
					_shake(6.0, 0.3)
					await get_tree().create_timer(0.25).timeout
				_glow_lock(l[0], l[1])
			respin = 3
			_respin_luci_set(3, true)
			_flash_schermo(Color("#ffd700"), 0.12, 0.3)
		else:
			respin -= 1
			_respin_luci_set(maxi(respin, 0))
		_bonus_hud_loot(int(round(loot*scale)))
		await get_tree().create_timer(0.5).timeout
	# conto alla rovescia finale se la griglia non e' piena (3 giri a vuoto)
	if not cassa["full"]:
		while respin > 0:
			_dbg("H cassaforte respin %d" % respin)
			for tick in 4:
				for reel in REELS:
					for row in ROWS:
						var key := "%d_%d" % [reel,row]
						if not locked.has(key):
							var c: Dictionary = cells[reel][row]
							c["panel"].color = Color("#141a24") if tick % 2 == 0 else Color("#0a0e14")
				await get_tree().create_timer(0.12).timeout
			respin -= 1
			_respin_luci_set(respin)
			_nutri_watchdog()
			await get_tree().create_timer(0.4).timeout
	fs_info.text=""; _glow_stop(); _respin_luci_distruggi(); _bonus_hud_distruggi()
	var total := int(round(cassa["total"]*scale))
	if cassa["full"]:
		_sfx("sfx_jackpot")
		# ONDA D'ORO: le 15 celle si accendono a diagonale
		for onda in 6:
			for reel in REELS:
				for row in ROWS:
					if (reel + row) == onda or (reel + row) == onda - 1:
						cells[reel][row]["panel"].modulate = Color(2.2, 1.8, 0.9)
						_scintille(_cell_center(reel, row), Color("#ffd700"), 4)
			await get_tree().create_timer(0.08).timeout
		for reel in REELS:
			for row in ROWS:
				cells[reel][row]["panel"].modulate = Color.WHITE
		_flash_schermo(Color("#ffd700"), 0.6, 0.7)
		_shockwave(Vector2(VW/2.0, VH/2.0), Color("#ffd700"), 600.0)
		_shake(10.0, 0.6)
		await _mastermind_dice(T("grand_dice"), 1.0)
		_targa_banner(T("grand"), Color("#f5b73f"), 2.0)
		if banner_node != null and ResourceLoader.exists("res://assets/banner_secolo.png"):
			banner_node.texture = load("res://assets/banner_secolo.png")
		for i in 8:
			_tint_all(Color("#ffd700") if i%2==0 else Color("#ff5252")); await get_tree().create_timer(0.18).timeout
		_burst_money(40); await get_tree().create_timer(0.4).timeout; _burst_money(40)
	_tint_all(Color.WHITE)
	_burst_money(18)
	await _celebra_vincita(total)
	await _count_up(T("malloppo"), total, 2.0)
	balance += total; _update_balance()
	await _fx_stop()
	await _bonus_exit()
	for reel in REELS:
		for row in ROWS:
			_set_cell(reel,row,result["grid"][reel][row],result["mults"][reel][row],result["coins"][reel][row])

func _play_scasso(result: Dictionary, scale: float, finale: bool = true) -> int:
	_dbg("H scasso inizio")
	var picks: Array = result.get("scasso_picks", [result["scasso"]])
	var lay := Node2D.new()
	add_child(lay)
	lay.add_to_group("scena_bonus")
	lay.z_index = 88
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 1.0)
	lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	_cerimonia_chiudi()
	var tit := Label.new()
	tit.text = T("scasso_scegli")
	tit.add_theme_font_size_override("font_size", 34)
	tit.add_theme_color_override("font_color", Color("#f5b73f"))
	tit.add_theme_color_override("font_outline_color", Color("#3a2405"))
	tit.add_theme_constant_override("outline_size", 12)
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lay.add_child(tit)
	tit.position = Vector2(0, 58)
	tit.size = Vector2(VW, 46)
	var pot := Label.new()
	pot.text = "0"
	pot.add_theme_font_size_override("font_size", 36)
	pot.add_theme_color_override("font_color", Color("#ffd700"))
	pot.add_theme_color_override("font_outline_color", Color("#5a3c08"))
	pot.add_theme_constant_override("outline_size", 12)
	pot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lay.add_child(pot)
	pot.position = Vector2(0, VH - 84.0)
	pot.size = Vector2(VW, 46)
	pot.pivot_offset = Vector2(VW / 2.0, 23.0)
	var chiusa = load("res://assets/scasso_cassaforte_chiusa.png") if ResourceLoader.exists("res://assets/scasso_cassaforte_chiusa.png") else textures.get("SCATTER")
	var aperta = load("res://assets/scasso_cassaforte_aperta.png") if ResourceLoader.exists("res://assets/scasso_cassaforte_aperta.png") else null
	var polizia = load("res://assets/scasso_polizia.png") if ResourceLoader.exists("res://assets/scasso_polizia.png") else null
	var stato := {"aperte": 0, "fine": false, "tot": 0, "bottoni": [], "lay": lay}
	# 9 casseforti libere nel buio, disposte ad ARCO su due file,
	# con alone dorato, taglie e inclinazioni leggermente diverse
	var posti: Array = []
	var cx := VW / 2.0
	for i in 5:   # fila alta: arco che scende ai lati
		var u := (i - 2.0) / 2.0
		posti.append([cx + u * 400.0, 210.0 + abs(u) * 34.0, 150.0 - abs(u) * 14.0])
	for i in 4:   # fila bassa: arco sfalsato
		var u := (i - 1.5) / 1.5
		posti.append([cx + u * 330.0, 420.0 + abs(u) * 26.0, 160.0 - abs(u) * 12.0])
	for i in 9:
		var pcx: float = posti[i][0]
		var pcy: float = posti[i][1]
		var dim: float = posti[i][2]
		var alone := TextureRect.new()
		alone.texture = _glow_texture(Color("#ffd27a"))
		alone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		alone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(alone)
		alone.size = Vector2(dim * 1.9, dim * 1.9)
		alone.position = Vector2(pcx, pcy) - alone.size / 2.0
		alone.modulate.a = 0.55
		var b := TextureButton.new()
		if chiusa != null:
			b.texture_normal = chiusa
			b.texture_disabled = chiusa
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		lay.add_child(b)
		var bx := pcx - dim / 2.0
		var by := pcy - dim / 2.0
		b.position = Vector2(bx, by)
		b.size = Vector2(dim, dim)
		b.pivot_offset = Vector2(dim / 2.0, dim / 2.0)
		b.rotation_degrees = randf_range(-7.0, 7.0)
		b.modulate = Color(1.12, 1.1, 1.0)
		var ic := TextureRect.new()
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(ic)
		ic.position = Vector2.ZERO
		ic.size = Vector2(dim, dim)
		ic.visible = false
		# fluttuazione, ognuna col suo ritmo
		var bob := create_tween().set_loops()
		bob.tween_property(b, "position:y", by + 7.0, 1.1 + 0.13 * i).set_trans(Tween.TRANS_SINE)
		bob.tween_property(b, "position:y", by, 1.1 + 0.13 * i).set_trans(Tween.TRANS_SINE)
		stato["bottoni"].append([b, ic])
		b.pressed.connect(func(): _scasso_tap(b, ic, stato, picks, aperta, polizia, pot, scale))
	while not stato["fine"]:
		_nutri_watchdog()
		await get_tree().create_timer(0.016).timeout
	await get_tree().create_timer(1.0).timeout
	var tot := int(round(result["scasso"] * scale))
	pot.text = _fmt(tot)
	if finale:
		_burst_money(14)
		await _celebra_vincita(tot)
		await _count_up(T("bottino"), tot, 1.5)
		balance += tot; _update_balance()
	else:
		await get_tree().create_timer(0.5).timeout
	var out := create_tween()
	out.tween_property(lay, "modulate:a", 0.0, 0.3)
	await _fine(out)
	lay.queue_free()
	return tot

func _scasso_tap(b: TextureButton, ic: TextureRect, stato: Dictionary, picks: Array, aperta, polizia, pot: Label, scale: float) -> void:
	_nutri_watchdog()
	_scasso_tap_(b, ic, stato, picks, aperta, polizia, pot, scale)

func _scasso_tap_(b: TextureButton, ic: TextureRect, stato: Dictionary, picks: Array, aperta, polizia, pot: Label, scale: float) -> void:
	if stato["fine"] or stato.get("busy", false) or b.has_meta("usata"): return
	stato["busy"] = true
	b.set_meta("usata", true)
	b.disabled = true
	var centro: Vector2 = b.position + b.size / 2.0
	var k: int = stato["aperte"]
	if k < picks.size():
		stato["aperte"] += 1
		var val := int(round(picks[k] * scale))
		stato["tot"] += val
		if aperta != null:
			ic.texture = aperta
			ic.visible = true
			b.texture_normal = null
			b.texture_disabled = null
		b.modulate = Color(1.5, 1.35, 0.8)
		var ap = _find_audio("sfx_cassaforte_apri")
		if sfx_on and ap != null:
			_play_limited(sfx_player, ap, "sfx_cassaforte_apri")
		else:
			_sfx_tool()
		_shockwave(centro, Color("#ffd700"), 150.0)
		_scintille(centro, Color("#ffd700"), 8)
		var pv := Label.new()
		pv.text = "+" + _fmt(val)
		pv.add_theme_font_size_override("font_size", 26)
		pv.add_theme_color_override("font_color", Color("#ffe9a8"))
		pv.add_theme_color_override("font_outline_color", Color("#3a2405"))
		pv.add_theme_constant_override("outline_size", 8)
		pv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_child(pv)
		pv.position = Vector2(0, b.size.y - 34.0)
		pv.size = Vector2(b.size.x, 30)
		pot.text = _fmt(stato["tot"])
		var pp := create_tween()
		pp.tween_property(pot, "scale", Vector2(1.15, 1.15), 0.1)
		pp.tween_property(pot, "scale", Vector2.ONE, 0.12)
		var bp := create_tween()
		bp.tween_property(b, "scale", Vector2(1.12, 1.12), 0.09)
		bp.tween_property(b, "scale", Vector2.ONE, 0.1)
		if stato["aperte"] == picks.size() and picks.size() >= SlotEngine.SCASSO_LADDER.size():
			# tutte e 8 aperte: repulisti totale
			stato["fine"] = true
			_flash_schermo(Color("#ffd700"), 0.4, 0.6)
			_targa_banner(T("ripulito"), Color("#f5b73f"), 1.4)
		stato["busy"] = false
	else:
		# LA POLIZIA! (blocco subito tutte le casseforti: niente altri tocchi)
		for coppia0 in stato["bottoni"]:
			if is_instance_valid(coppia0[0]): coppia0[0].disabled = true
		if polizia != null:
			ic.texture = polizia
			ic.visible = true
			b.texture_normal = null
			b.texture_disabled = null
			b.modulate = Color.WHITE
		else:
			b.modulate = Color(1.6, 0.4, 0.4)
		var sir = _find_audio("sfx_polizia")
		if sfx_on and sir != null:
			_play_limited(sfx_player, sir, "sfx_polizia")
		else:
			_sfx("sfx_anticipation")
		_shake(6.0, 0.4)
		for j in 6:
			_flash_schermo(Color("#d13a3a") if j % 2 == 0 else Color("#3a6fd8"), 0.3, 0.24)
			await get_tree().create_timer(0.13).timeout
		await _targa_banner(T("polizia"), Color("#3a6fd8"), 1.4)
		if not is_instance_valid(stato.get("lay")):
			stato["fine"] = true
			return
		# I PREMI MANCATI: le casseforti rimaste si aprono in grigio, una a una
		var mancati: Array = []
		for j in range(k, SlotEngine.SCASSO_LADDER.size()):
			mancati.append(SlotEngine.SCASSO_LADDER[j])
		# ogni tanto tra i mancati compare una targa jackpot (illusione del "quasi")
		if mancati.size() >= 2 and randf() < 0.6:
			mancati[mancati.size() - 1] = SlotEngine.JACKPOT_PAY[-2]   # MINOR 200
		if mancati.size() >= 4 and randf() < 0.3:
			mancati[1] = SlotEngine.JACKPOT_PAY[-1]                    # MINI 50
		mancati.shuffle()
		if mancati.size() > 0:
			var cap := _etichetta(T("mancati"), 24, Color("#c9c9c9"), Color("#1a1a1a"), 8)
			stato["lay"].add_child(cap)
			cap.size = Vector2(VW, 36)
			cap.position = Vector2(0, 14)
			var idx := 0
			for coppia in stato["bottoni"]:
				var b2: TextureButton = coppia[0]
				var ic2: TextureRect = coppia[1]
				if not is_instance_valid(b2) or b2.has_meta("usata") or idx >= mancati.size(): continue
				b2.set_meta("usata", true)
				b2.disabled = true
				var vm := int(round(mancati[idx] * scale))
				idx += 1
				if aperta != null:
					ic2.texture = aperta
					ic2.visible = true
					b2.texture_normal = null
					b2.texture_disabled = null
				b2.modulate = Color(0.55, 0.55, 0.6)
				_sfx_tool()
				var pm := _etichetta(_fmt(vm), 24, Color("#d8d8d8"), Color("#1a1a1a"), 7)
				b2.add_child(pm)
				pm.position = Vector2(0, b2.size.y - 34.0)
				pm.size = Vector2(b2.size.x, 30)
				var bq := create_tween()
				bq.tween_property(b2, "scale", Vector2(1.08, 1.08), 0.08)
				bq.tween_property(b2, "scale", Vector2.ONE, 0.1)
				await get_tree().create_timer(0.28).timeout
			await get_tree().create_timer(0.9).timeout
		stato["fine"] = true

func _play_heist(result: Dictionary, scale: float, fs_key: String = "free_spins") -> void:
	_dbg("H colpo inizio")
	var fs_list: Array = result[fs_key]
	for i in 4:
		_tint_all(Color("#ff5252") if i%2==0 else Color.WHITE); await get_tree().create_timer(0.2).timeout
	_sfx("sfx_bonus_unlock")
	if fs_key == "free_spins":
		await _mastermind_dice(T("colpo_intro"), 1.0)
	dinamite_lanciata = true
	_play_music("music_bonus")
	await _bonus_enter()
	# dentro il caveau aperto: sfondo dedicato dietro i rulli
	var sfondo_colpo: TextureRect = null
	if ResourceLoader.exists("res://assets/sfondo_colpo.png"):
		sfondo_colpo = TextureRect.new()
		sfondo_colpo.texture = load("res://assets/sfondo_colpo.png")
		sfondo_colpo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sfondo_colpo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		sfondo_colpo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(sfondo_colpo)
		move_child(sfondo_colpo, 1)
		sfondo_colpo.size = Vector2(VW, VH)
		sfondo_colpo.modulate.a = 0.0
		var sf := create_tween()
		sf.tween_property(sfondo_colpo, "modulate:a", 1.0, 0.6)
	_fx_start("banner_colpo", Color(0.10, 0.05, 0.16, 0.24))
	_tint_all(Color.WHITE)
	var loot := 0; var n := fs_list.size()
	var mult_att := 1
	sticky_illuminati.clear()
	for i in n:
		var fs: Dictionary = fs_list[i]
		var mult_prima := mult_att
		mult_att = fs.get("mult", 3)
		if i == 0:
			_bonus_hud_crea("colpo")
			_bonus_hud_mult(1)
		_bonus_hud_giro(i+1, n)
		_bonus_hud_loot(int(round(loot*scale)))
		_nutri_watchdog()
		_dbg("H colpo giro %d/%d" % [i+1, n])
		_reels_start_all()
		if fs.has("complice"):
			_reel_tint(fs["complice"], Color(0.75, 1.35, 0.75))
		await get_tree().create_timer(FS_SHUFFLE).timeout
		# i rulli si fermano in sequenza da sinistra, come nel gioco base
		for reel in REELS:
			_dbg("H colpo rullo %d" % reel)
			await _reel_stop(reel, fs["grid"], fs["mults"], fs.get("coins"), fs.get("grid_pre"), fs.get("espansi", []))
			if reel < REELS-1:
				await get_tree().create_timer(0.10).timeout
		if fs.has("complice"):
			# la colonna del complice esplode WILD
			var crx: int = fs["complice"]
			_sfx("sfx_unlock")
			_shockwave(_cell_center(crx, 1), Color("#6fbf5e"), 280.0)
			_scintille(_cell_center(crx, 1), Color("#6fbf5e"), 12)
			for rowx in ROWS:
				cells[crx][rowx]["panel"].modulate = Color(1.25, 1.55, 1.1)
				var tx: TextureRect = cells[crx][rowx]["tex"]
				if tx.visible:
					tx.pivot_offset = tx.size / 2.0
					var pwx := create_tween()
					pwx.tween_property(tx, "scale", Vector2(1.3, 1.3), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					pwx.tween_property(tx, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			await get_tree().create_timer(0.55).timeout
			for rowx in ROWS:
				cells[crx][rowx]["panel"].modulate = Color.WHITE
		# MASCHERE APPICCICOSE: i rulli appiccicati respirano d'oro (una volta sola per rullo)
		for rs in fs.get("sticky", []):
			if not sticky_illuminati.has(rs):
				sticky_illuminati.append(rs)
				for rowz in ROWS:
					_glow_lock(rs, rowz)
		# SACCHI NEL COLPO: incasso immediato x moltiplicatore
		if fs.get("coin_win", 0) > 0:
			for reel in REELS:
				for row in ROWS:
					if String(fs["grid"][reel][row]) == "COIN":
						var cc := _cell_center(reel, row)
						_shockwave(cc, Color("#ffd700"), 140.0)
						_scintille(cc, Color("#ffd700"), 8)
			_sfx("sfx_win_small")
			_popup_vincita(int(round(fs["coin_win"] * scale)))
			await get_tree().create_timer(0.45).timeout
		# RETRIGGER: altre casseforti nei giri gratis -> altri giri
		if fs.get("retrigger", 0) > 0:
			_sfx("sfx_bonus_unlock")
			for reel in REELS:
				for row in ROWS:
					if String(fs["grid"][reel][row]) == "SCATTER":
						_shockwave(_cell_center(reel, row), Color("#ffd700"), 200.0)
						_scintille(_cell_center(reel, row), Color("#ffd700"), 10)
			_flash_schermo(Color("#ffd700"), 0.35, 0.5)
			_shake(6.0, 0.35)
			await _targa_banner(T("retrigger") % fs["retrigger"], Color("#f5b73f"), 1.3)
			_bonus_hud_giro(i+1, n)
		# DINAMITE: esplode e fa saltare il moltiplicatore
		if fs.get("dinamite", 0) > 0:
			var bersagli: Array = []
			for reel in REELS:
				for row in ROWS:
					if String(fs["grid"][reel][row]) == "DINAMITE":
						bersagli.append([reel, row])
			await _mastermind_lancia(bersagli)
			# il moltiplicatore nuovo piomba grande sui rulli
			var ml := Label.new()
			ml.text = "x%d" % mult_att
			ml.add_theme_font_size_override("font_size", 120)
			ml.add_theme_color_override("font_color", Color("#ffb347"))
			ml.add_theme_color_override("font_outline_color", Color("#3a1005"))
			ml.add_theme_constant_override("outline_size", 22)
			ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ml.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			add_child(ml)
			ml.size = Vector2(320, 160)
			ml.position = Vector2(VW / 2.0 - 160.0, VH / 2.0 - 110.0)
			ml.pivot_offset = ml.size / 2.0
			ml.scale = Vector2(2.6, 2.6)
			ml.modulate.a = 0.0
			ml.z_index = 75
			var mt := create_tween().set_parallel(true)
			mt.tween_property(ml, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			mt.tween_property(ml, "modulate:a", 1.0, 0.18)
			await _fine(mt)
			_shake(4.0, 0.2)
			await get_tree().create_timer(0.55).timeout
			var mo := create_tween()
			mo.tween_property(ml, "modulate:a", 0.0, 0.25)
			mo.tween_callback(ml.queue_free)
			_bonus_hud_mult(mult_att, true)
		# attrezzi nei giri gratis: lampo (la carica sale a fine bonus)
		var fs_tools := false
		for reel in REELS:
			for row in ROWS:
				if String(fs["grid"][reel][row]).begins_with("TOOL_"):
					cells[reel][row]["panel"].modulate = Color(1.35, 1.25, 0.9)
					fs_tools = true
		if fs_tools:
			_sfx_tool()
			await get_tree().create_timer(0.18).timeout
			for reel in REELS:
				for row in ROWS:
					cells[reel][row]["panel"].modulate = Color.WHITE
		var w := int(round(fs["win"]*scale))
		if w>0:
			loot += w; _flash(_winning_cells_of(fs["grid"], fs["result"]))
			_popup_vincita(w)
			_bonus_hud_loot(int(round(loot*scale)))
		await get_tree().create_timer(FS_PAUSE).timeout
	fs_info.text=""; _tint_all(Color.WHITE); _bonus_hud_distruggi()
	if loot>0:
		_burst_money(24)
		await _celebra_vincita(loot)
		await _count_up(T("malloppo_colpo"), loot, 2.5)
	_glow_stop()
	sticky_illuminati.clear()
	dinamite_lanciata = false
	if sfondo_colpo != null:
		var sfo := create_tween()
		sfo.tween_property(sfondo_colpo, "modulate:a", 0.0, 0.5)
		sfo.tween_callback(sfondo_colpo.queue_free)
		balance += loot; _update_balance()
	await _fx_stop()
	await _bonus_exit()

func _count_up(prefix: String, amount: int, duration: float) -> void:
	_dbg("H count_up")
	# v1.9: esultanza dell'ispettore durante il conteggio (solo se era a riposo:
	# dentro i bonus e nella vincita grande comanda gia' la scena)
	var mm_esulta := mastermind_node != null and is_instance_valid(mastermind_node) and mm_frames_attivi == "idle" and mm_win_frames.size() >= 2 and amount > 0
	if mm_esulta:
		mm_frames_attivi = "win"
		mastermind_node.texture = mm_win_frames[0]
	_sfx("sfx_win_big" if amount >= _bet() * 10 else "sfx_win_small")
	win_label.pivot_offset = win_label.size / 2.0
	var pulse := create_tween().set_loops()
	pulse.tween_property(win_label, "scale", Vector2(1.06, 1.06), 0.13)
	pulse.tween_property(win_label, "scale", Vector2.ONE, 0.13)
	var tick_st := {"on": true}
	_ticker(tick_st)
	var t := create_tween()
	t.tween_method(func(v: float): win_label.text = prefix + _fmt(int(v)), 0.0, float(amount), duration)
	await _fine(t)
	tick_st["on"] = false
	pulse.kill()
	win_label.scale = Vector2.ONE
	sfx_player.stop()   # taglia le monete: niente code che si sovrappongono alla musica
	if mm_esulta and mm_frames_attivi == "win" and mastermind_node != null and is_instance_valid(mastermind_node):
		# resta in posa ancora un attimo, poi torna a fumare la pipa
		_mm_torna_idle()

func _winning_cells_of(grid: Array, res: Dictionary) -> Array:
	var out: Array = []
	for hit in res["line_hits"]:
		var line: Array = SlotEngine.PAYLINES[hit["line"]]
		for reel in hit["count"]: out.append([reel, line[reel]])
	if res["n_scatter"] >= 3:
		for reel in REELS:
			for row in ROWS:
				if grid[reel][row] == "SCATTER": out.append([reel,row])
	return out

func _flash(winning: Array) -> void:
	if winning.is_empty(): return
	for i in 6:
		var bright := (i%2==0)
		for wc in winning:
			var c: Dictionary = cells[wc[0]][wc[1]]
			if bright: c["panel"].color = SYMBOL_COLORS[c["symbol"]]
			else: c["panel"].color = Color("#141821") if textures.has(c["symbol"]) else SYMBOL_COLORS[c["symbol"]].darkened(0.6)
		await get_tree().create_timer(_t(0.15)).timeout


# ================= TARGHE, PRESAGI, TICKER =================
var presagi: Array = []

func _targa_banner(testo: String, col: Color = Color("#e3a93c"), durata: float = 1.0) -> void:
	_dbg("H targa")
	var w := maxf(380.0, testo.length() * 24.0 + 90.0)
	var h := 82.0
	var holder := Control.new()
	add_child(holder)
	holder.z_index = 85
	holder.size = Vector2(w, h)
	holder.position = Vector2((VW - w) / 2.0, 148.0)
	holder.pivot_offset = holder.size / 2.0
	if ResourceLoader.exists("res://assets/banner_targa.png"):
		var img := TextureRect.new()
		img.texture = load("res://assets/banner_targa.png")
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_SCALE
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(img)
		img.size = Vector2(w, h)
		img.modulate = col.lightened(0.15)
	else:
		var p := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = col
		sb.border_color = Color("#ffe89a")
		sb.border_width_top = 3; sb.border_width_bottom = 3
		sb.border_width_left = 3; sb.border_width_right = 3
		sb.corner_radius_top_left = 18; sb.corner_radius_top_right = 18
		sb.corner_radius_bottom_left = 18; sb.corner_radius_bottom_right = 18
		sb.shadow_color = Color(0, 0, 0, 0.6); sb.shadow_size = 9; sb.shadow_offset = Vector2(0, 5)
		p.add_theme_stylebox_override("panel", sb)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(p)
		p.size = Vector2(w, h)
	var lb := Label.new()
	lb.text = testo
	lb.add_theme_font_size_override("font_size", 34)
	lb.add_theme_color_override("font_color", Color("#2a1c05"))
	lb.add_theme_color_override("font_outline_color", Color("#fff0c0"))
	lb.add_theme_constant_override("outline_size", 4)
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(lb)
	lb.size = Vector2(w, h)
	# ingresso elastico con flash di luce
	holder.scale = Vector2(0.2, 0.2)
	holder.rotation_degrees = -5.0
	var fl := ColorRect.new()
	fl.color = Color(1, 1, 1, 0.4)
	fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(fl)
	fl.size = Vector2(w, h)
	var ft := create_tween()
	ft.tween_property(fl, "color:a", 0.0, 0.35)
	ft.tween_callback(fl.queue_free)
	var tin := create_tween().set_parallel(true)
	tin.tween_property(holder, "scale", Vector2(1.12, 1.12), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tin.tween_property(holder, "rotation_degrees", 0.0, 0.22)
	tin.chain().tween_property(holder, "scale", Vector2.ONE, 0.12)
	await _fine(tin)
	await get_tree().create_timer(durata).timeout
	var tout := create_tween().set_parallel(true)
	tout.tween_property(holder, "scale", Vector2(0.3, 0.3), 0.18)
	tout.tween_property(holder, "modulate:a", 0.0, 0.18)
	await _fine(tout)
	holder.queue_free()

func _presagio_start(col: Color, sfx_nome: String) -> void:
	# suono-firma della funzione in arrivo (se il file esiste)
	if sfx_on:
		var st = _find_audio(sfx_nome)
		if st != null:
			sfx_player.stream = st
			sfx_player.play()
	# cornice dello schermo che pulsa del colore della funzione
	var fr := Control.new()
	fr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fr)
	fr.z_index = 65
	for r in [Rect2(0, 0, VW, 10), Rect2(0, VH - 10, VW, 10), Rect2(0, 0, 10, VH), Rect2(VW - 10, 0, 10, VH)]:
		var c := ColorRect.new()
		c.color = col
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fr.add_child(c)
		c.position = r.position
		c.size = r.size
	fr.modulate.a = 0.0
	var tw := create_tween().set_loops()
	tw.tween_property(fr, "modulate:a", 0.85, 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_property(fr, "modulate:a", 0.12, 0.45).set_trans(Tween.TRANS_SINE)
	presagi.append({"node": fr, "tw": tw})

func _presagi_stop() -> void:
	for p in presagi:
		p["tw"].kill()
		p["node"].queue_free()
	presagi.clear()

func _ticker(st: Dictionary) -> void:
	# tin-tin del conteggio (richiede assets/audio/sfx_count)
	if not sfx_on: return
	var s = _find_audio("sfx_count")
	if s == null: return
	while st["on"]:
		spin_sfx_player.stream = s
		spin_sfx_player.play()
		await get_tree().create_timer(0.07).timeout

# ================= CERIMONIE DI SBLOCCO =================

var cerimonia_lay: Node2D = null

func _cerimonia_chiudi() -> void:
	# chiamata dalla scena successiva appena il suo nero e' a schermo
	if cerimonia_lay != null and is_instance_valid(cerimonia_lay):
		cerimonia_lay.queue_free()
	cerimonia_lay = null

func _cerimonia_sblocco(tk: String) -> void:
	_dbg("H cerimonia")
	var col: Color = PIANO_COL[tk]
	var lay := Node2D.new()
	add_child(lay)
	lay.add_to_group("scena_bonus")
	lay.z_index = 85
	cerimonia_lay = lay
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	var tv := create_tween()
	tv.tween_property(veil, "color:a", 1.0, 0.3)
	var centro := Vector2(VW / 2.0, VH / 2.0 - 20.0)
	if tk == "TOOL_RED" and ResourceLoader.exists("res://assets/scasso_lucchetto.png"):
		var lock := TextureRect.new()
		lock.texture = load("res://assets/scasso_lucchetto.png")
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(lock)
		lock.size = Vector2(230, 230)
		lock.position = centro - lock.size / 2.0 + Vector2(0, 30)
	var tool := TextureRect.new()
	if textures.has(tk): tool.texture = textures[tk]
	tool.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tool.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tool.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(tool)
	tool.size = Vector2(220, 220)
	tool.position = centro - tool.size / 2.0
	tool.pivot_offset = tool.size / 2.0
	tool.scale = Vector2(0.15, 0.15)
	var tin := create_tween()
	tin.tween_property(tool, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _fine(tin)

	if tk == "TOOL_RED":
		# il grimaldello forza la serratura: tre scatti e cede
		for i in 3:
			var tw := create_tween()
			tw.tween_property(tool, "rotation_degrees", -16.0, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(tool, "rotation_degrees", 10.0, 0.07)
			await _fine(tw)
			_sfx_tool()
			_scintille(centro + Vector2(30, 20), col, 6)
			_shake(3.5, 0.1)
			await get_tree().create_timer(0.18).timeout
		var snap := create_tween()
		snap.tween_property(tool, "rotation_degrees", 52.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await _fine(snap)
		_sfx("sfx_unlock")
		_flash_schermo(col, 0.35, 0.5)
		_shockwave(centro, col, 360.0)
		_scintille(centro, col, 18)
		_shake(6.0, 0.3)
	elif tk == "TOOL_GREEN":
		# la tessera striscia nel lettore e la scansione la accetta
		tool.position = Vector2(-260.0, centro.y - tool.size.y / 2.0)
		var sw := create_tween()
		sw.tween_property(tool, "position:x", centro.x - tool.size.x / 2.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await _fine(sw)
		_sfx_tool()
		var linea := ColorRect.new()
		linea.color = Color(col.r, col.g, col.b, 0.85)
		linea.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(linea)
		linea.size = Vector2(tool.size.x + 60.0, 5.0)
		linea.position = Vector2(centro.x - linea.size.x / 2.0, centro.y - tool.size.y / 2.0)
		var sl := create_tween()
		sl.tween_property(linea, "position:y", centro.y + tool.size.y / 2.0, 0.42)
		await _fine(sl)
		linea.queue_free()
		_sfx("sfx_unlock")
		_flash_schermo(col, 0.32, 0.5)
		_shockwave(centro, col, 340.0)
		_scintille(centro, col, 14)
		_shake(4.0, 0.22)
	else:
		# la chiave entra nella toppa e gira
		var kr := create_tween()
		kr.tween_property(tool, "rotation_degrees", 90.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		await _fine(kr)
		_sfx("sfx_unlock")
		_flash_schermo(col, 0.35, 0.55)
		_shockwave(centro, col, 400.0)
		_scintille(centro, col, 18)
		_shake(5.0, 0.3)
	await get_tree().create_timer(0.35).timeout
	# l'attrezzo svanisce, il nero resta: la scena nasce da qui
	var out := create_tween()
	out.tween_property(tool, "modulate:a", 0.0, 0.2)
	await _fine(out)

var mm_esulta_id := 0
func _mm_torna_idle() -> void:
	mm_esulta_id += 1
	var mio := mm_esulta_id
	await get_tree().create_timer(0.5).timeout
	if mio != mm_esulta_id or mm_frames_attivi != "win": return
	if mastermind_node == null or not is_instance_valid(mastermind_node): return
	mm_frames_attivi = "idle"
	if mm_idle_frames.size() >= 1:
		mastermind_node.texture = mm_idle_frames[0]
	elif mm_normal != null:
		mastermind_node.texture = mm_normal

func _mm_anim_loop() -> void:
	var fr := 0
	while is_instance_valid(mastermind_node):
		_nutri_watchdog()
		if mm_frames_attivi == "coins" and mm_coins != null:
			mastermind_node.texture = mm_coins
			await get_tree().create_timer(0.2).timeout
			continue
		if mm_frames_attivi == "lancio":
			await get_tree().create_timer(0.1).timeout
			continue
		var win_ok := mm_frames_attivi == "win" and mm_win_frames.size() >= 2
		var lista: Array = mm_win_frames if win_ok else mm_idle_frames
		var attesa := 0.22 if win_ok else 0.45
		if lista.size() >= 2:
			# avanti e indietro (1-2-3-2), respiro lento o esultanza vivace
			var n := lista.size()
			var ciclo := 2 * n - 2
			var i := fr % ciclo
			if i >= n:
				i = ciclo - i
			mastermind_node.texture = lista[i]
			fr += 1
		await get_tree().create_timer(attesa).timeout

# ================= PIOGGIA DI FESTA + DEMO =================

func _pioggia_fx() -> void:
	# coriandoli colorati e monetine su tutto lo schermo
	_sfx("sfx_unlock")
	var coin_tex = load("res://assets/fx_coin.png") if ResourceLoader.exists("res://assets/fx_coin.png") else null
	var colori := [Color("#f5b73f"), Color("#d1543f"), Color("#6fbf5e"), Color("#4f83d1"), Color("#ffe9a8")]
	for i in 34:
		var moneta := i % 3 == 0 and coin_tex != null
		var nodo: Control
		if moneta:
			var tr := TextureRect.new()
			tr.texture = coin_tex
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			tr.size = Vector2(34, 34)
			nodo = tr
		else:
			var cr := ColorRect.new()
			cr.color = colori[i % colori.size()]
			cr.size = Vector2(10, 16)
			nodo = cr
		nodo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(nodo)
		nodo.position = Vector2(randf_range(160.0, VW - 160.0), randf_range(-160.0, -30.0))
		nodo.pivot_offset = nodo.size / 2.0
		nodo.z_index = 65
		var dur := randf_range(0.9, 1.6)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(nodo, "position:y", VH + 40.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(nodo, "position:x", nodo.position.x + randf_range(-90.0, 90.0), dur)
		tw.tween_property(nodo, "rotation_degrees", randf_range(-420.0, 420.0), dur)
		tw.tween_property(nodo, "modulate:a", 0.0, 0.3).set_delay(dur - 0.3)
		tw.chain().tween_callback(nodo.queue_free)

func _demo_bonus() -> void:
	# tasto D: tutti i bonus in sequenza, per vederli senza spinnare
	if demo_in_corso or spinning: return
	demo_in_corso = true
	var targa := Label.new()
	targa.text = "DEMO"
	targa.add_theme_font_size_override("font_size", 18)
	targa.add_theme_color_override("font_color", Color("#ff5252"))
	targa.add_theme_color_override("font_outline_color", Color("#2a0808"))
	targa.add_theme_constant_override("outline_size", 8)
	add_child(targa)
	targa.position = Vector2(16, 12)
	targa.z_index = 95
	for f in (["cassaforte", "colpo"] if not SlotEngine.INDIZI_ATTIVI else ["pioggia", "cassaforte", "colpo", "scasso", "accesso", "rapina", "supremo"]):
		if balance < _bet() * 4:
			balance += 5000   # credito demo
			_update_balance()
		engine.forza_prossimo = f
		await _on_spin_pressed()
		await get_tree().create_timer(0.7).timeout
	targa.queue_free()
	demo_in_corso = false

func _mastermind_dice(testo: String, attesa: float = 1.2) -> void:
	_nutri_watchdog()
	await _mastermind_dice_(testo, attesa)

func _mastermind_dice_(testo: String, attesa: float = 1.2) -> void:
	_dbg("H dialogo")
	# scena-dialogo su nero: personaggio a sinistra, fumetto a macchina da scrivere
	var lay := Node2D.new()
	add_child(lay)
	lay.add_to_group("scena_bonus")
	lay.z_index = 89
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 1.0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	_cerimonia_chiudi()
	var tex = null
	if ResourceLoader.exists("res://assets/detective_talk.png"):
		tex = load("res://assets/detective_talk.png")
	elif mm_win != null:
		tex = mm_win
	else:
		tex = mm_normal
	if tex != null:
		var pj := TextureRect.new()
		pj.texture = tex
		pj.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pj.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pj.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(pj)
		pj.size = Vector2(560, 620)
		pj.position = Vector2(20, VH - 620.0 + 16.0)
		pj.pivot_offset = Vector2(280, 620)
		pj.modulate.a = 0.0
		var ein := create_tween().set_parallel(true)
		ein.tween_property(pj, "modulate:a", 1.0, 0.25)
		ein.tween_property(pj, "position:x", 20.0, 0.35).from(-40.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# fumetto
	var fum := Panel.new()
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color("#f7f1e3")
	fsb.border_color = Color("#3a2405")
	fsb.border_width_top = 4; fsb.border_width_bottom = 4
	fsb.border_width_left = 4; fsb.border_width_right = 4
	fsb.corner_radius_top_left = 26; fsb.corner_radius_top_right = 26
	fsb.corner_radius_bottom_left = 26; fsb.corner_radius_bottom_right = 6
	fsb.shadow_color = Color(0, 0, 0, 0.6); fsb.shadow_size = 10; fsb.shadow_offset = Vector2(0, 6)
	fum.add_theme_stylebox_override("panel", fsb)
	fum.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(fum)
	fum.size = Vector2(560, 150)
	fum.position = Vector2(540, 120)
	fum.pivot_offset = Vector2(0, 150)
	fum.scale = Vector2(0.2, 0.2)
	var pop := create_tween()
	pop.tween_property(fum, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var lb := Label.new()
	lb.text = ""
	lb.add_theme_font_size_override("font_size", 26)
	lb.add_theme_color_override("font_color", Color("#2a1c05"))
	lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fum.add_child(lb)
	lb.position = Vector2(24, 12)
	lb.size = Vector2(512, 126)
	await _fine(pop)
	# macchina da scrivere
	var tick = _find_audio("sfx_count")
	for i in testo.length():
		lb.text = testo.substr(0, i + 1)
		if sfx_on and tick != null and i % 3 == 0:
			_play_limited(sfx_player, tick, "sfx_count")
		await get_tree().create_timer(0.028).timeout
	await get_tree().create_timer(attesa).timeout
	# uscita: lampo e nero
	_flash_schermo(Color("#ffffff"), 0.5, 0.35)
	var out := create_tween()
	out.tween_property(lay, "modulate:a", 0.0, 0.3)
	await _fine(out)
	lay.queue_free()

# ================= COLPO SUPREMO: UN FILM IN QUATTRO ATTI =================

func _play_supremo(result: Dictionary, scale: float) -> void:
	_dbg("H supremo inizio")
	# ATTO 1 - LA CONVERGENZA: i tre attrezzi si scontrano al centro
	for tkx in piano_med.keys():
		_telegraph_stop(tkx)
	var lay := Node2D.new()
	add_child(lay)
	lay.add_to_group("scena_bonus")
	lay.z_index = 86
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	var tv := create_tween()
	tv.tween_property(veil, "color:a", 0.88, 0.35)
	var centro := Vector2(VW / 2.0, VH / 2.0 - 20.0)
	_play_music("music_tension")
	var attrezzi := ["TOOL_RED", "TOOL_GREEN", "TOOL_BLUE"]
	var volanti: Array = []
	for tk in attrezzi:
		var t := TextureRect.new()
		if textures.has(tk): t.texture = textures[tk]
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(t)
		t.size = Vector2(150, 150)
		t.position = _piano_center(tk) - t.size / 2.0
		t.pivot_offset = t.size / 2.0
		t.modulate = Color(1.4, 1.35, 1.1)
		volanti.append(t)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(t, "position", centro - t.size / 2.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(t, "rotation_degrees", 540.0, 0.85)
		tw.tween_property(t, "scale", Vector2(1.6, 1.6), 0.85)
	for i in 3:
		_sfx_tool()
		await get_tree().create_timer(0.28).timeout
	# lo scontro
	for t in volanti:
		t.queue_free()
	_sfx("sfx_jackpot")
	_flash_schermo(Color("#ffffff"), 0.85, 0.6)
	_shockwave(centro, Color("#ffd700"), 520.0)
	_shockwave(centro, Color("#ffffff"), 380.0)
	_scintille(centro, Color("#ffd700"), 34)
	_shake(9.0, 0.5)
	for tk in attrezzi:
		_explode_medallion(tk)
	# PAUSA: e' successo qualcosa di grosso. Scossa lunga e lampi lenti.
	await get_tree().create_timer(0.5).timeout
	_shake(12.0, 1.2)
	for i in 4:
		_flash_schermo(Color("#ffd700") if i % 2 == 0 else Color("#ffffff"), 0.35, 0.45)
		await get_tree().create_timer(0.35).timeout
	await get_tree().create_timer(0.4).timeout
	var out := create_tween()
	out.tween_property(lay, "modulate:a", 0.0, 0.3)
	await _fine(out)
	lay.queue_free()
	await _mastermind_dice(T("sup_1"), 1.3)

	# ATTO 2 - IL DIAMANTE
	var t_tot: int = await _play_taglio(result, scale, false)

	# ATTO 3 - I FRAMMENTI APRONO LE CASSEFORTI
	await _mastermind_dice(T("sup_2"), 1.1)
	var s_tot: int = await _play_scasso(result, scale, false)

	# ATTO 4 - LA POLIZIA?! IL COMPLICE APRE IL CAVEAU
	await _mastermind_dice(T("sup_3"), 1.2)
	await _play_cassaforte(result, scale, "rapina")

	# FINALE - BOTTINO SUPREMO (la rapina si e' gia' incassata da sola)
	var r_tot := int(round(result["rapina"]["total"] * scale))
	var grand := t_tot + s_tot + r_tot
	balance += t_tot + s_tot; _update_balance()
	_burst_money(30)
	_flash_schermo(Color("#ffd700"), 0.4, 0.8)
	await _celebra_vincita(grand)
	await _count_up(T("sup_fine"), grand, 2.6)

# ================= LA RUOTA DEL MOLTIPLICATORE =================
const RUOTA_SETTORI := [1, 2, 1, 3, 1, 2, 1, 5]

func _ruota_moltiplicatore(lay: Node2D, centro: Vector2, m: int, colm: Color) -> void:
	# LA MANOPOLA: otto moltiplicatori in cerchio, il disco della cassaforte gira e punta uno di loro
	var n := RUOTA_SETTORI.size()
	var r_badge := 205.0
	var colori := {1: Color("#2b3450"), 2: Color("#8a6a1a"), 3: Color("#a5521c"), 5: Color("#a3202a")}
	var badges: Array = []
	for i in n:
		var a := -PI / 2.0 + i * TAU / n
		var b := Panel.new()
		var sb := StyleBoxFlat.new()
		_stile_targa(sb, colori[RUOTA_SETTORI[i]], Color("#ffe89a"), 30)
		b.add_theme_stylebox_override("panel", sb)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(b)
		b.size = Vector2(60, 60)
		b.position = centro + Vector2(cos(a), sin(a)) * r_badge - b.size / 2.0
		b.pivot_offset = b.size / 2.0
		b.scale = Vector2(0.2, 0.2)
		var lb := _etichetta("x%d" % RUOTA_SETTORI[i], 24, Color("#ffffff"), Color("#1a0a2a"), 7)
		b.add_child(lb)
		lb.size = b.size
		badges.append(b)
		var tb := create_tween()
		tb.tween_property(b, "scale", Vector2.ONE, 0.25).set_delay(i * 0.04).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# il disco al centro
	var disco := Control.new()
	disco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(disco)
	var dsz := 270.0
	disco.size = Vector2(dsz, dsz)
	disco.position = centro - disco.size / 2.0
	disco.pivot_offset = disco.size / 2.0
	if ResourceLoader.exists("res://assets/disco_cassaforte.png"):
		var img := TextureRect.new()
		img.texture = load("res://assets/disco_cassaforte.png")
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		disco.add_child(img)
		img.size = disco.size
	else:
		# ripiego disegnato: disco scuro con bordo d'ottone, tacche e marcatore rosso in alto
		var cir := Polygon2D.new()
		var pts := PackedVector2Array()
		for k in 48: pts.append(Vector2(dsz / 2.0, dsz / 2.0) + Vector2(cos(k * TAU / 48.0), sin(k * TAU / 48.0)) * (dsz / 2.0 - 4.0))
		cir.polygon = pts; cir.color = Color("#1a1f2c")
		disco.add_child(cir)
		var anello := Line2D.new()
		var ap := PackedVector2Array()
		for k in 49: ap.append(Vector2(dsz / 2.0, dsz / 2.0) + Vector2(cos(k * TAU / 48.0), sin(k * TAU / 48.0)) * (dsz / 2.0 - 4.0))
		anello.points = ap; anello.width = 8.0; anello.default_color = Color("#c9a24a")
		disco.add_child(anello)
		for k in 40:
			var tk := Line2D.new()
			var ang := k * TAU / 40.0
			var lung := 18.0 if k % 5 == 0 else 9.0
			tk.points = PackedVector2Array([Vector2(dsz / 2.0, dsz / 2.0) + Vector2(cos(ang), sin(ang)) * (dsz / 2.0 - 14.0), Vector2(dsz / 2.0, dsz / 2.0) + Vector2(cos(ang), sin(ang)) * (dsz / 2.0 - 14.0 - lung)])
			tk.width = 3.0; tk.default_color = Color("#e8d9a0")
			disco.add_child(tk)
		var marc := Polygon2D.new()
		marc.polygon = PackedVector2Array([Vector2(dsz / 2.0 - 12, 6), Vector2(dsz / 2.0 + 12, 6), Vector2(dsz / 2.0, 40)])
		marc.color = Color("#ff4d4d")
		disco.add_child(marc)
	disco.scale = Vector2(0.2, 0.2)
	var tin := create_tween()
	tin.tween_property(disco, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _fine(tin)
	# il marcatore parte in alto (badge 0): per puntare il badge idx ruota di idx settori + giri interi
	var candidati: Array = []
	for i in n:
		if RUOTA_SETTORI[i] == m: candidati.append(i)
	if candidati.is_empty(): candidati = [0]
	var idx: int = candidati[randi() % candidati.size()]
	var finale := TAU * 4.0 + idx * TAU / n
	_sfx("sfx_whoosh")
	var giro := create_tween()
	giro.tween_property(disco, "rotation", finale, 3.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var tick = _find_audio("sfx_count")
	var ultimo := -1
	var t_giro := 0.0
	while giro.is_running() and t_giro < 6.0:
		t_giro += 0.016
		await get_tree().create_timer(0.016).timeout
		var sett_att := int(floor(fmod(disco.rotation + TAU * 100.0, TAU) / (TAU / n) + 0.5)) % n
		if sett_att != ultimo:
			ultimo = sett_att
			if sfx_on and tick != null: _play_limited(spin_sfx_player, tick, "sfx_count")
			var bb: Panel = badges[sett_att]
			var pb := create_tween()
			pb.tween_property(bb, "scale", Vector2(1.18, 1.18), 0.05)
			pb.tween_property(bb, "scale", Vector2.ONE, 0.08)
	# scatto finale: il badge scelto si accende, gli altri si spengono
	_sfx("sfx_reel_stop")
	_shockwave(centro, colm, 300.0)
	_shake(3.0, 0.15)
	for i in n:
		var bb: Panel = badges[i]
		if i == idx:
			var pw := create_tween()
			pw.tween_property(bb, "scale", Vector2(1.6, 1.6), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			pw.tween_property(bb, "scale", Vector2(1.35, 1.35), 0.12)
		else:
			var pf := create_tween()
			pf.tween_property(bb, "modulate:a", 0.25, 0.3)
	await get_tree().create_timer(0.8).timeout
	var out := create_tween().set_parallel(true)
	out.tween_property(disco, "modulate:a", 0.0, 0.3)
	for bb in badges: out.tween_property(bb, "modulate:a", 0.0, 0.3)
	await _fine(out)
	disco.queue_free()
	for bb in badges: bb.queue_free()

# ================= IL TAGLIO DEL DIAMANTE =================

func _play_taglio(result: Dictionary, scale: float, finale: bool = true) -> int:
	_dbg("H taglio inizio")
	var tg: Dictionary = result["taglio"]
	var lay := Node2D.new()
	add_child(lay)
	lay.add_to_group("scena_bonus")
	lay.z_index = 88
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 1.0)
	lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	_cerimonia_chiudi()
	var tit := Label.new()
	tit.text = T("tocca_dia")
	tit.add_theme_font_size_override("font_size", 34)
	tit.add_theme_color_override("font_color", Color("#9fdcff"))
	tit.add_theme_color_override("font_outline_color", Color("#0a2438"))
	tit.add_theme_constant_override("outline_size", 12)
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lay.add_child(tit)
	tit.position = Vector2(0, 54)
	tit.size = Vector2(VW, 46)
	var dia_tex = load("res://assets/diamante.png") if ResourceLoader.exists("res://assets/diamante.png") else textures.get("STAR")
	var centro := Vector2(VW / 2.0, VH / 2.0 - 10.0)
	var dia := TextureButton.new()
	if dia_tex != null:
		dia.texture_normal = dia_tex
		dia.texture_disabled = dia_tex
	dia.ignore_texture_size = true
	dia.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	lay.add_child(dia)
	dia.size = Vector2(300, 300)
	dia.position = centro - dia.size / 2.0
	dia.pivot_offset = dia.size / 2.0
	var rot := create_tween().set_loops()
	rot.tween_property(dia, "rotation_degrees", 360.0, 7.0).from(0.0)
	var glow := create_tween().set_loops()
	glow.tween_property(dia, "modulate", Color(1.25, 1.35, 1.6), 1.2).set_trans(Tween.TRANS_SINE)
	glow.tween_property(dia, "modulate", Color.WHITE, 1.2).set_trans(Tween.TRANS_SINE)
	var stato := {"colpi": 0, "rotto": false}
	dia.pressed.connect(func(): _taglio_tap(dia, stato, centro))
	while not stato["rotto"]:
		_nutri_watchdog()
		await get_tree().create_timer(0.016).timeout
	rot.kill(); glow.kill()
	tit.text = ""
	# frammenti a stella
	var vals: Array = tg["frammenti"]
	var n := vals.size()
	var frag_tex = load("res://assets/frammento.png") if ResourceLoader.exists("res://assets/frammento.png") else dia_tex
	var pezzi: Array = []
	for i in n:
		var ang := -PI / 2.0 + i * TAU / n
		var dest := centro + Vector2(cos(ang), sin(ang)) * 215.0
		var f := TextureRect.new()
		if frag_tex != null: f.texture = frag_tex
		f.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		f.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(f)
		f.size = Vector2(96, 96)
		f.position = centro - f.size / 2.0
		f.pivot_offset = f.size / 2.0
		f.rotation_degrees = randf_range(-40.0, 40.0)
		f.modulate = Color(1.2, 1.3, 1.5)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(f, "position", dest - f.size / 2.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(f, "rotation_degrees", f.rotation_degrees + randf_range(-200.0, 200.0), 0.55)
		pezzi.append([f, dest, vals[i]])
	await get_tree().create_timer(0.7).timeout
	# rivelazione uno a uno
	var somma := 0
	for item in pezzi:
		var val := int(round(item[2] * scale))
		somma += val
		var dest: Vector2 = item[1]
		var lb := Label.new()
		lb.text = "+" + _fmt(val)
		lb.add_theme_font_size_override("font_size", 30)
		lb.add_theme_color_override("font_color", Color("#ffe9a8"))
		lb.add_theme_color_override("font_outline_color", Color("#3a2405"))
		lb.add_theme_constant_override("outline_size", 10)
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lay.add_child(lb)
		lb.size = Vector2(140, 36)
		lb.position = dest + Vector2(-70.0, 52.0)
		lb.pivot_offset = Vector2(70, 18)
		lb.scale = Vector2(0.3, 0.3)
		var pt := create_tween()
		pt.tween_property(lb, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		item.append(lb)   # l'etichetta viaggia col frammento
		_scintille(dest, Color("#9fdcff"), 6)
		_sfx_tool()
		await get_tree().create_timer(0.38).timeout
	await get_tree().create_timer(0.3).timeout
	# CONTATORE della somma dei frammenti, in basso
	var bez := Panel.new()
	var bsb := StyleBoxFlat.new()
	_stile_targa(bsb, Color(0.02, 0.02, 0.03, 0.96), Color("#b8923a"), 8)
	bez.add_theme_stylebox_override("panel", bsb)
	bez.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(bez)
	bez.size = Vector2(320, 84)
	bez.position = Vector2(VW / 2.0 - 160.0, VH - 104.0)
	var cont := _etichetta(_fmt(somma), 48, Color("#ffd15c"), Color("#2a1a05"), 8)
	bez.add_child(cont)
	cont.size = Vector2(320, 84)
	cont.position = Vector2.ZERO
	cont.pivot_offset = Vector2(160, 42)
	cont.scale = Vector2(0.3, 0.3)
	var ctw := create_tween()
	ctw.tween_property(cont, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# i frammenti volano dentro il contatore
	for item in pezzi:
		var f0: TextureRect = item[0]
		var tf := create_tween().set_parallel(true)
		tf.tween_property(f0, "position", bez.position + Vector2(160, 42) - f0.size / 2.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tf.tween_property(f0, "scale", Vector2(0.3, 0.3), 0.4)
		tf.tween_property(f0, "modulate:a", 0.0, 0.4).set_delay(0.2)
		if item.size() > 3:
			var lb0: Label = item[3]
			var tl := create_tween().set_parallel(true)
			tl.tween_property(lb0, "position", bez.position + Vector2(160, 42) - lb0.size / 2.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tl.tween_property(lb0, "scale", Vector2(0.3, 0.3), 0.4)
			tl.tween_property(lb0, "modulate:a", 0.0, 0.35).set_delay(0.15)
			tl.chain().tween_callback(lb0.queue_free)
	await get_tree().create_timer(0.6).timeout
	# la RUOTA dei moltiplicatori gira e si ferma sul valore deciso dal motore
	var m: int = tg["mult"]
	var colm := Color("#ffffff")
	if m == 2: colm = Color("#ffd700")
	elif m == 3: colm = Color("#ff9a3c")
	elif m >= 5: colm = Color("#ff4d4d")
	await _ruota_moltiplicatore(lay, centro, m, colm)
	# la moltiplicazione sotto gli occhi: il contatore sale da somma a somma x m
	_sfx("sfx_unlock")
	_flash_schermo(colm, 0.35, 0.5)
	_shockwave(bez.position + Vector2(160, 42), colm, 300.0)
	_shake(4.0 + m, 0.3)
	var tc2 := create_tween()
	tc2.tween_method(func(v: float): cont.text = _fmt(int(v)), float(somma), float(somma * m), 0.9 if m > 1 else 0.2)
	var tick2 = _find_audio("sfx_count")
	if sfx_on and tick2 != null and m > 1:
		for i in 6:
			_play_limited(sfx_player, tick2, "sfx_count")
			await get_tree().create_timer(0.15).timeout
	var t_c2 := 0.0
	while tc2.is_running() and t_c2 < 4.0:
		t_c2 += 0.016
		await get_tree().create_timer(0.016).timeout
	var cp := create_tween()
	cp.tween_property(cont, "scale", Vector2(1.3, 1.3), 0.12)
	cp.tween_property(cont, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.9).timeout
	var tot := int(round(tg["total"] * scale))
	if finale:
		_burst_money(14)
		await _celebra_vincita(tot)
		await _count_up(T("bottino"), tot, 1.5)
		balance += tot; _update_balance()
	else:
		await get_tree().create_timer(0.5).timeout
	var out := create_tween()
	out.tween_property(lay, "modulate:a", 0.0, 0.3)
	await _fine(out)
	lay.queue_free()
	return tot

func _taglio_tap(dia: TextureButton, stato: Dictionary, centro: Vector2) -> void:
	_nutri_watchdog()
	_taglio_tap_(dia, stato, centro)

func _taglio_tap_(dia: TextureButton, stato: Dictionary, centro: Vector2) -> void:
	if stato.get("busy", false) or stato["rotto"]: return
	stato["busy"] = true
	await _taglio_tap_impl(dia, stato, centro)
	stato["busy"] = false

func _taglio_tap_impl(dia: TextureButton, stato: Dictionary, centro: Vector2) -> void:
	if stato["rotto"]: return
	stato["colpi"] += 1
	var c: int = stato["colpi"]
	var vt = _find_audio("sfx_vetro")
	if sfx_on and vt != null:
		_play_limited(sfx_player, vt, "sfx_vetro")
	else:
		_sfx_tool()
	_shake(2.0 * c, 0.15)
	_scintille(centro, Color("#9fdcff"), 5 * c)
	var punch := create_tween()
	punch.tween_property(dia, "scale", Vector2(1.14, 0.9), 0.07)
	punch.tween_property(dia, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if c == 2 and ResourceLoader.exists("res://assets/diamante_crepato.png"):
		dia.texture_normal = load("res://assets/diamante_crepato.png")
	if c >= 3:
		stato["rotto"] = true
		dia.disabled = true
		dia.visible = false
		_flash_schermo(Color("#9fdcff"), 0.45, 0.5)
		_shockwave(centro, Color("#9fdcff"), 430.0)
		_scintille(centro, Color("#9fdcff"), 28)
		_shake(7.0, 0.4)
		_sfx("sfx_unlock")

# ================= WILD ESPANSO =================

func _espandi_wild(reel: int, grid: Array, mults: Array, g_land: Array) -> void:
	_dbg("H espandi wild")
	# la maschera si allarga dalla cella d'origine a tutto il rullo
	var origine := 1
	for row in ROWS:
		if g_land[reel][row] == "WILD":
			origine = row
			break
	var sfx = _find_audio("sfx_wild_espanso")
	if sfx_on and sfx != null:
		_play_limited(sfx_player, sfx, "sfx_wild_espanso")
	else:
		_sfx("sfx_unlock")
	var ov := TextureRect.new()
	if textures.has("WILD"): ov.texture = textures["WILD"]
	ov.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ov.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid_root.add_child(ov)
	ov.z_index = 6
	var x := reel * PITCH + 4.0
	var y0 := origine * PITCH + 4.0
	ov.position = Vector2(x, y0)
	ov.size = Vector2(CELL - 8.0, CELL - 8.0)
	ov.modulate = Color(1.6, 1.3, 1.3)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(ov, "position:y", 4.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(ov, "size:y", ROWS * PITCH - GAP - 8.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await _fine(tw)
	var centro := _cell_center(reel, 1)
	_flash_schermo(Color("#ff5a6e"), 0.25, 0.35)
	_shockwave(centro, Color("#ff5a6e"), 260.0)
	_scintille(centro, Color("#ff9aa8"), 14)
	_shake(4.0, 0.22)
	for row in ROWS:
		# v1.8: nei giri gratis il FLASH lo lancia l'ispettore: qui resta la
		# gemma finta atterrata, altrimenti comparirebbe prima del lancio
		if dinamite_lanciata and String(grid[reel][row]) == "DINAMITE":
			continue
		_set_cell(reel, row, grid[reel][row], mults[reel][row], 0)
		var ct: TextureRect = cells[reel][row]["tex"]
		if ct.visible:
			ct.pivot_offset = ct.size / 2.0
			var pw := create_tween()
			pw.tween_property(ct, "scale", Vector2(1.25, 1.25), 0.1)
			pw.tween_property(ct, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	ov.queue_free()
	await get_tree().create_timer(0.15).timeout

# ================= AURE DEI SIMBOLI IMPORTANTI =================

func _aura_cella(c: Dictionary, sym: String) -> void:
	if not c.has("aura") or c["aura"] == null: return
	var aura: TextureRect = c["aura"]
	if c["aura_tw"] != null:
		c["aura_tw"].kill(); c["aura_tw"] = null
	var lv: String = LIVELLO_SIMBOLO.get(sym, "gemma")
	# spada di luce e taglia a riposo
	if c.get("sweep_tw") != null:
		c["sweep_tw"].kill(); c["sweep_tw"] = null
	if c.get("sweep") != null: c["sweep"].visible = false
	c["tex"].scale = Vector2.ONE
	if lv == "gemma" or lv == "attrezzo":
		aura.visible = false
		return
	if c.get("sweep") != null:
		var sw: TextureRect = c["sweep"]
		sw.visible = true
		var stw := create_tween().set_loops()
		stw.tween_interval(randf_range(1.5, 3.5))
		stw.tween_property(sw, "position:x", CELL + 40.0, 0.5).from(-70.0).set_trans(Tween.TRANS_SINE)
		c["sweep_tw"] = stw
	c["tex"].scale = Vector2(1.08, 1.08) if lv == "leggenda" else Vector2(1.04, 1.04)
	var col: Color = COLORE_ATTERRAGGIO.get(sym, Color("#ffd700"))
	var gt := _glow_texture(col)
	if aura.texture != gt: aura.texture = gt
	aura.visible = true
	var forte := lv == "leggenda"
	aura.modulate = Color(1, 1, 1, 0.55 if forte else 0.32)
	aura.pivot_offset = aura.size / 2.0
	aura.scale = Vector2.ONE
	var tw := create_tween().set_loops()
	tw.tween_property(aura, "modulate:a", 0.9 if forte else 0.5, 0.7 + randf() * 0.4).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(aura, "scale", Vector2(1.12, 1.12), 0.7 + randf() * 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(aura, "modulate:a", 0.55 if forte else 0.32, 0.7 + randf() * 0.4).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(aura, "scale", Vector2.ONE, 0.7 + randf() * 0.4).set_trans(Tween.TRANS_SINE)
	c["aura_tw"] = tw

# ================= IL MOMENTO DELLA VERITA' =================
var verita_lay: Node2D = null
var verita_pos := Vector2.ZERO
var verita_scale := Vector2.ONE

func _momento_verita(reel_fermo: int, chiave: String = "una_manca", col_tint: Color = Color("#ff5252")) -> void:
	# il simbolo decisivo arrivera': il tempo rallenta (HUD nascosto, niente sovrapposizioni)
	reel_suspense = 0.22
	for nd in hud_nodes:
		if is_instance_valid(nd): nd.visible = false
	win_label.visible = false
	if mastermind_node != null: mastermind_node.visible = false
	verita_lay = Node2D.new()
	add_child(verita_lay)
	verita_lay.z_index = 40
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	verita_lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	var tv := create_tween()
	tv.tween_property(veil, "color:a", 0.72, 0.35)
	# la griglia sale sopra il velo e si avvicina
	verita_pos = grid_root.position
	verita_scale = grid_root.scale
	grid_root.z_index = 41
	var gsz := Vector2(REELS * PITCH - GAP, ROWS * PITCH - GAP)
	var zoom := 1.14
	var tz := create_tween().set_parallel(true)
	tz.tween_property(grid_root, "scale", verita_scale * zoom, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tz.tween_property(grid_root, "position", verita_pos - gsz * (zoom - 1.0) * 0.5 * verita_scale, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# battito
	var bat = _find_audio("sfx_battito")
	if sfx_on and bat != null:
		_play_limited(spin_sfx_player, bat, "sfx_battito")
	else:
		_sfx("sfx_anticipation")
	for r in range(reel_fermo + 1, REELS): _reel_tint(r, col_tint)
	# la frase come SOTTOTITOLO da film, in basso al centro
	var sub := _etichetta(T(chiave), 30, Color("#ffe9a8"), Color("#2a1a05"), 10)
	verita_lay.add_child(sub)
	sub.size = Vector2(VW, 44)
	sub.position = Vector2(0, VH - 92.0)
	sub.modulate.a = 0.0
	var ts := create_tween()
	ts.tween_property(sub, "modulate:a", 1.0, 0.35)
	await get_tree().create_timer(1.7).timeout

func _momento_verita_fine() -> void:
	if verita_lay == null: return
	var tz := create_tween().set_parallel(true)
	tz.tween_property(grid_root, "scale", verita_scale, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tz.tween_property(grid_root, "position", verita_pos, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var out := create_tween()
	out.tween_property(verita_lay, "modulate:a", 0.0, 0.4)
	await _fine(out)
	grid_root.z_index = 0
	verita_lay.queue_free()
	verita_lay = null
	for nd in hud_nodes:
		if is_instance_valid(nd): nd.visible = true
	win_label.visible = true
	if mastermind_node != null: mastermind_node.visible = true

# ================= GERARCHIA DEI SIMBOLI ALL'ATTERRAGGIO =================
const LIVELLO_SIMBOLO := {
	"WILD": "leggenda", "STAR": "leggenda",
	"CROWN": "alto", "SCATTER": "alto", "COIN": "alto", "DINAMITE": "alto",
	"TOOL_RED": "attrezzo", "TOOL_GREEN": "attrezzo", "TOOL_BLUE": "attrezzo",
}
const COLORE_ATTERRAGGIO := {
	"WILD": Color("#ff5a6e"), "STAR": Color("#9fdcff"), "CROWN": Color("#ffd700"),
	"SCATTER": Color("#ffd700"), "COIN": Color("#ffcf5a"), "DINAMITE": Color("#ff7a1c"),
	"TOOL_RED": Color("#d1543f"), "TOOL_GREEN": Color("#6fbf5e"), "TOOL_BLUE": Color("#4f83d1"),
}

func _landing_fx(reel: int, row: int, sym: String) -> void:
	var ct: TextureRect = cells[reel][row]["tex"]
	var lv: String = LIVELLO_SIMBOLO.get(sym, "gemma")
	var col: Color = COLORE_ATTERRAGGIO.get(sym, Color.WHITE)
	var centro := _cell_center(reel, row)
	var pop := 1.12
	if lv == "leggenda": pop = 1.32
	elif lv == "alto": pop = 1.24
	elif lv == "attrezzo": pop = 1.2
	var riposo := 1.08 if lv == "leggenda" else (1.04 if lv == "alto" else 1.0)
	if ct.visible:
		ct.pivot_offset = ct.size / 2.0
		ct.scale = Vector2.ONE
		var pw := create_tween()
		pw.tween_property(ct, "scale", Vector2(pop, pop), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		pw.tween_property(ct, "scale", Vector2(riposo, riposo), 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if lv == "gemma":
		return
	# anello nel colore del simbolo (dimensione per livello)
	var raggio := 110.0
	if lv == "leggenda": raggio = 170.0
	elif lv == "alto": raggio = 135.0
	_shockwave(centro, col, raggio)
	if lv == "leggenda":
		_scintille(centro, col, 10)
		# brillio: il simbolo si accende e torna normale
		if ct.visible:
			var br := create_tween()
			br.tween_property(ct, "modulate", Color(1.7, 1.6, 1.45), 0.12)
			br.tween_property(ct, "modulate", Color.WHITE, 0.45)
		if sfx_on:
			var pr = _find_audio("sfx_premium")
			if pr != null:
				_play_limited(sfx_player, pr, "sfx_premium")
	elif lv == "alto":
		_scintille(centro, col, 5)
		if ct.visible:
			var br2 := create_tween()
			br2.tween_property(ct, "modulate", Color(1.35, 1.3, 1.2), 0.1)
			br2.tween_property(ct, "modulate", Color.WHITE, 0.3)

# ================= HUD DEI BONUS =================
var bhud: Node2D = null
var bhud_loot: Label = null
var bhud_mult: Label = null
var bhud_mult_back: Panel = null
var bhud_giro: Label = null

func _stile_targa(sb: StyleBoxFlat, bg: Color, bordo: Color, raggio: int) -> void:
	sb.bg_color = bg; sb.border_color = bordo
	sb.border_width_top = 3; sb.border_width_bottom = 3; sb.border_width_left = 3; sb.border_width_right = 3
	sb.corner_radius_top_left = raggio; sb.corner_radius_top_right = raggio
	sb.corner_radius_bottom_left = raggio; sb.corner_radius_bottom_right = raggio
	sb.shadow_color = Color(0, 0, 0, 0.55); sb.shadow_size = 6; sb.shadow_offset = Vector2(0, 3)

func _etichetta(testo: String, dim: int, col: Color, contorno: Color, spess: int) -> Label:
	var lb := Label.new()
	lb.text = testo
	lb.add_theme_font_size_override("font_size", dim)
	lb.add_theme_color_override("font_color", col)
	lb.add_theme_color_override("font_outline_color", contorno)
	lb.add_theme_constant_override("outline_size", spess)
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lb

func _bonus_hud_crea(tipo: String) -> void:
	# tipo: "cassaforte" (pallini + RESPIN) oppure "colpo" (GIRO + badge moltiplicatore)
	_bonus_hud_distruggi()
	bhud = Node2D.new()
	add_child(bhud)
	bhud.z_index = 30
	# targa del bottino, in basso a sinistra
	var tp := Panel.new()
	var tsb := StyleBoxFlat.new()
	# DISPLAY meccanico: bezel quasi nero, bordo d'ottone sottile, cifre dorate
	_stile_targa(tsb, Color(0.02, 0.02, 0.03, 0.96), Color("#b8923a"), 8)
	tsb.border_width_top = 2; tsb.border_width_bottom = 2; tsb.border_width_left = 2; tsb.border_width_right = 2
	tp.add_theme_stylebox_override("panel", tsb)
	tp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bhud.add_child(tp)
	tp.size = Vector2(250, 78)
	tp.position = Vector2(26, VH - 100.0)
	var cap := _etichetta(T("bottino_lbl"), 14, Color("#f5b73f"), Color("#3a2405"), 4)
	tp.add_child(cap)
	cap.position = Vector2(0, 6); cap.size = Vector2(250, 18)
	bhud_loot = _etichetta("0", 34, Color("#ffe9a8"), Color("#3a2405"), 8)
	tp.add_child(bhud_loot)
	bhud_loot.position = Vector2(0, 26); bhud_loot.size = Vector2(250, 44)
	bhud_loot.pivot_offset = Vector2(125, 22)
	if tipo == "cassaforte":
		# RESPIN sotto i tre pallini (i pallini tengono il conto)
		var rl := _etichetta(T("respin_lbl"), 20, Color("#f5b73f"), Color("#3a2405"), 6)
		bhud.add_child(rl)
		rl.position = Vector2(VW / 2.0 - 120.0, VH - 78.0); rl.size = Vector2(240, 28)
	else:
		# GIRO n/N in alto a sinistra della griglia, badge del moltiplicatore in alto a destra
		bhud_giro = _etichetta("", 20, Color("#ffe9a8"), Color("#3a2405"), 6)
		bhud.add_child(bhud_giro)
		bhud_giro.position = Vector2(26, VH - 140.0); bhud_giro.size = Vector2(250, 30)
		bhud_mult_back = Panel.new()
		var msb := StyleBoxFlat.new()
		_stile_targa(msb, Color("#c8501c"), Color("#ffd27a"), 46)
		bhud_mult_back.add_theme_stylebox_override("panel", msb)
		bhud_mult_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bhud.add_child(bhud_mult_back)
		bhud_mult_back.size = Vector2(92, 92)
		bhud_mult_back.position = Vector2(VW / 2.0 - 46.0, VH - 126.0)
		bhud_mult_back.pivot_offset = Vector2(46, 46)
		bhud_mult = _etichetta("x1", 34, Color("#ffffff"), Color("#5a1a05"), 8)
		bhud_mult_back.add_child(bhud_mult)
		bhud_mult.size = Vector2(92, 92)

func _bonus_hud_loot(v: int) -> void:
	if bhud_loot == null or not is_instance_valid(bhud_loot): return
	if bhud_loot.text != _fmt(v):
		bhud_loot.text = _fmt(v)
		var tw := create_tween()
		tw.tween_property(bhud_loot, "scale", Vector2(1.25, 1.25), 0.1)
		tw.tween_property(bhud_loot, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _bonus_hud_giro(i: int, n: int) -> void:
	if bhud_giro != null and is_instance_valid(bhud_giro):
		bhud_giro.text = T("giro") % [i, n]

func _bonus_hud_mult(m: int, salto: bool = false) -> void:
	if bhud_mult == null or not is_instance_valid(bhud_mult): return
	bhud_mult.text = "x%d" % m
	if salto:
		var tw := create_tween()
		tw.tween_property(bhud_mult_back, "scale", Vector2(1.5, 1.5), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(bhud_mult_back, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_shockwave(bhud_mult_back.position + Vector2(46, 46), Color("#ff7a1c"), 160.0)

func _bonus_hud_distruggi() -> void:
	if bhud != null and is_instance_valid(bhud):
		bhud.queue_free()
	bhud = null; bhud_loot = null; bhud_mult = null; bhud_mult_back = null; bhud_giro = null

# ================= LUCI DEI RESPIN =================
var respin_luci: Array = []
var respin_lay: Node2D = null

func _respin_luci_crea() -> void:
	_respin_luci_distruggi()
	respin_lay = Node2D.new()
	add_child(respin_lay)
	respin_lay.z_index = 30
	respin_luci.clear()
	for i in 3:
		var p := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#ffd700")
		sb.border_color = Color("#fff3b0")
		sb.border_width_top = 3; sb.border_width_bottom = 3; sb.border_width_left = 3; sb.border_width_right = 3
		sb.corner_radius_top_left = 16; sb.corner_radius_top_right = 16; sb.corner_radius_bottom_left = 16; sb.corner_radius_bottom_right = 16
		sb.shadow_color = Color(1.0, 0.85, 0.3, 0.7); sb.shadow_size = 10
		p.add_theme_stylebox_override("panel", sb)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		respin_lay.add_child(p)
		p.size = Vector2(32, 32)
		p.position = Vector2(VW / 2.0 - 60.0 + i * 44.0, VH - 118.0)
		p.pivot_offset = Vector2(16, 16)
		respin_luci.append(p)

func _respin_luci_set(n: int, reset: bool = false) -> void:
	if respin_lay == null: return
	for i in respin_luci.size():
		var p: Panel = respin_luci[i]
		var acceso := i < n
		var sb: StyleBoxFlat = p.get_theme_stylebox("panel")
		sb.bg_color = Color("#ffd700") if acceso else Color("#2a2418")
		sb.border_color = Color("#fff3b0") if acceso else Color("#4a4030")
		sb.shadow_size = 10 if acceso else 0
		if reset and acceso:
			var tw := create_tween()
			tw.tween_property(p, "scale", Vector2(1.5, 1.5), 0.1)
			tw.tween_property(p, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		elif not acceso and i == n:
			var tw2 := create_tween()
			tw2.tween_property(p, "scale", Vector2(0.6, 0.6), 0.08)
			tw2.tween_property(p, "scale", Vector2.ONE, 0.12)

func _respin_luci_distruggi() -> void:
	if respin_lay != null and is_instance_valid(respin_lay):
		respin_lay.queue_free()
	respin_lay = null
	respin_luci.clear()

# ================= IL MASTERMIND LANCIA LA DINAMITE =================

func _mastermind_lancia(bersagli: Array) -> void:
	_dbg("H lancio dinamite")
	var furia := bersagli.size() >= 2
	var mm_prima := mm_frames_attivi
	var tex_lancio = null
	if ResourceLoader.exists("res://assets/detective_lancio.png"):
		tex_lancio = load("res://assets/detective_lancio.png")
	# mano da cui parte il candelotto (a sinistra del personaggio, altezza spalla)
	var mano := Vector2(VW - 300.0, GRID_Y + 70.0)
	if mastermind_node != null:
		# la mano alzata con la dinamite: in alto a destra del personaggio
		# CASE: la macchina fotografica sta davanti al petto, a sinistra del corpo
		mano = mastermind_node.position + Vector2(mastermind_node.size.x * 0.32, mastermind_node.size.y * 0.30)
	var tex_furia = null
	if ResourceLoader.exists("res://assets/detective_furia.png"):
		tex_furia = load("res://assets/detective_furia.png")
	# PROVOCAZIONE: le gemme sulle celle destinate tremolano e sfrigolano...
	var tw_prov: Array = []
	for b0 in bersagli:
		var ct: TextureRect = cells[b0[0]][b0[1]]["tex"]
		ct.pivot_offset = ct.size / 2.0
		var tp := create_tween().set_loops()
		tp.tween_property(ct, "rotation_degrees", 7.0, 0.07)
		tp.tween_property(ct, "rotation_degrees", -7.0, 0.07)
		tw_prov.append(tp)
		cells[b0[0]][b0[1]]["panel"].modulate = Color(1.4, 0.9, 0.9)
		_scintille(_cell_center(b0[0], b0[1]), Color("#ff7a1c"), 4)
	_sfx("sfx_anticipation")
	# ...lui si gira a guardarle...
	if mastermind_node != null:
		mm_frames_attivi = "lancio"
		if ResourceLoader.exists("res://assets/detective_talk.png"):
			mastermind_node.texture = load("res://assets/detective_talk.png")
	await get_tree().create_timer(0.8).timeout
	# ...e stringe i pugni.
	if mastermind_node != null:
		if tex_furia != null:
			mastermind_node.texture = tex_furia
		elif mm_win_frames.size() >= 3:
			mastermind_node.texture = mm_win_frames[2]
		var tr0 := create_tween()
		for i in 6:
			tr0.tween_property(mastermind_node, "rotation_degrees", 4.0 if i % 2 == 0 else -4.0, 0.06)
		tr0.tween_property(mastermind_node, "rotation_degrees", 0.0, 0.08)
	_flash_schermo(Color("#c0261c"), 0.2, 0.45)
	_sfx("sfx_anticipation")
	await get_tree().create_timer(0.7).timeout
	for tp in tw_prov: tp.kill()
	for b0 in bersagli:
		cells[b0[0]][b0[1]]["tex"].rotation_degrees = 0.0
		cells[b0[0]][b0[1]]["panel"].modulate = Color.WHITE
	if furia:
		# FURIA: posa furiosa, trema, rosso ai bordi, "Adesso basta!"
		_sfx("sfx_anticipation")
		_flash_schermo(Color("#c0261c"), 0.3, 0.5)
		if mastermind_node != null:
			mm_frames_attivi = "lancio"
			if tex_furia != null:
				mastermind_node.texture = tex_furia
			var tr := create_tween()
			for i in 6:
				tr.tween_property(mastermind_node, "rotation_degrees", 6.0 if i % 2 == 0 else -6.0, 0.06)
			tr.tween_property(mastermind_node, "rotation_degrees", 0.0, 0.08)
		_bolla_mastermind(T("furia"), 1.1)
		await get_tree().create_timer(0.75).timeout
	for b in bersagli:
		var reel: int = b[0]
		var row: int = b[1]
		# posa di lancio + slancio
		if mastermind_node != null:
			mm_frames_attivi = "lancio"
			if tex_lancio != null:
				mastermind_node.texture = tex_lancio
			elif mm_win_frames.size() >= 2:
				mastermind_node.texture = mm_win_frames[1]
			var sl := create_tween()
			sl.tween_property(mastermind_node, "rotation_degrees", -9.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			sl.tween_property(mastermind_node, "rotation_degrees", 0.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_sfx("sfx_whoosh")
		# il candelotto vola ad arco
		var d := TextureRect.new()
		if textures.has("DINAMITE"): d.texture = textures["DINAMITE"]
		d.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		d.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(d)
		d.size = Vector2(70, 70)
		d.position = mano - d.size / 2.0
		d.pivot_offset = d.size / 2.0
		d.z_index = 60
		var dest := _cell_center(reel, row)
		var ctrl := Vector2((mano.x + dest.x) / 2.0, minf(mano.y, dest.y) - 150.0)
		var dur := 0.36 if furia else 0.5
		var tme := 0.0
		while tme < dur:
			await get_tree().create_timer(0.016).timeout
			var dt := maxf(get_process_delta_time(), 0.008)
			tme += dt
			var u := clampf(tme / dur, 0.0, 1.0)
			var pos := mano.lerp(ctrl, u).lerp(ctrl.lerp(dest, u), u)
			d.position = pos - d.size / 2.0
			d.rotation_degrees += 900.0 * dt
			if int(tme * 60.0) % 3 == 0:
				_scintille(pos, Color("#ffb347"), 1)
		d.queue_free()
		# esplosione sulla cella e la dinamite appare
		var esp = _find_audio("sfx_esplosione")
		if sfx_on and esp != null:
			_play_limited(sfx_player, esp, "sfx_esplosione")
		else:
			_sfx("sfx_unlock")
		_flash_schermo(Color("#ff7a1c"), 0.35, 0.4)
		_shockwave(dest, Color("#ff7a1c"), 300.0)
		_scintille(dest, Color("#ffb347"), 16)
		_shake(6.0, 0.3)
		_set_cell(reel, row, "DINAMITE", 1, 0)
		_landing_fx(reel, row, "DINAMITE")
		cells[reel][row]["panel"].modulate = Color(1.8, 1.2, 0.8)
		await get_tree().create_timer(0.2 if furia else 0.32).timeout
		cells[reel][row]["panel"].modulate = Color.WHITE
	if mastermind_node != null:
		mastermind_node.rotation_degrees = 0.0
		mm_frames_attivi = mm_prima

func _bolla_mastermind(testo: String, durata: float) -> void:
	# fumetto breve accanto alla testa del Mastermind, dentro il gioco
	var fum := Panel.new()
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color("#f7f1e3"); fsb.border_color = Color("#3a2405")
	fsb.border_width_top = 3; fsb.border_width_bottom = 3; fsb.border_width_left = 3; fsb.border_width_right = 3
	fsb.corner_radius_top_left = 14; fsb.corner_radius_top_right = 14; fsb.corner_radius_bottom_left = 14; fsb.corner_radius_bottom_right = 3
	fum.add_theme_stylebox_override("panel", fsb)
	fum.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fum)
	fum.size = Vector2(220, 52)
	var px := VW - 330.0
	var py := GRID_Y - 60.0
	if mastermind_node != null:
		px = mastermind_node.position.x - 150.0
		py = mastermind_node.position.y + 30.0
	fum.position = Vector2(px, py)
	fum.pivot_offset = Vector2(220, 52)
	fum.scale = Vector2(0.2, 0.2)
	fum.z_index = 70
	var lb := Label.new()
	lb.text = testo
	lb.add_theme_font_size_override("font_size", 20)
	lb.add_theme_color_override("font_color", Color("#2a1c05"))
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fum.add_child(lb)
	lb.size = fum.size
	var tw := create_tween()
	tw.tween_property(fum, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(durata)
	tw.tween_property(fum, "modulate:a", 0.0, 0.2)
	tw.tween_callback(fum.queue_free)

# ================= IMPATTI E CELEBRAZIONI =================
var cassa_glows: Array = []
const BIGWIN_SOGLIE := [[100.0, "epicwin"], [40.0, "megawin"], [15.0, "bigwin"]]

func _shake(forza: float, durata: float) -> void:
	var orig: Vector2 = grid_root.position
	var t := 0.0
	while t < durata:
		await get_tree().create_timer(0.016).timeout
		t += get_process_delta_time()
		grid_root.position = orig + Vector2(randf_range(-forza, forza), randf_range(-forza, forza))
	grid_root.position = orig

var _tex_cache := {}

func _ring_texture(col: Color) -> GradientTexture2D:
	var key := "ring_" + col.to_html(false)
	if _tex_cache.has(key): return _tex_cache[key]
	var t0 := _ring_texture_nuova(col)
	_tex_cache[key] = t0
	return t0

func _ring_texture_nuova(col: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(col.r, col.g, col.b, 0.0), Color(col.r, col.g, col.b, 0.0), col, Color(col.r, col.g, col.b, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 0.72, 0.85, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	t.width = 256; t.height = 256
	return t

func _glow_texture(col: Color) -> GradientTexture2D:
	var key := "glow_" + col.to_html(false)
	if _tex_cache.has(key): return _tex_cache[key]
	var t0 := _glow_texture_nuova(col)
	_tex_cache[key] = t0
	return t0

func _glow_texture_nuova(col: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(col.r, col.g, col.b, 0.75), Color(col.r, col.g, col.b, 0.22), Color(col.r, col.g, col.b, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	t.width = 256; t.height = 256
	return t

func _shockwave(centro: Vector2, col: Color, raggio: float = 180.0) -> void:
	var w := TextureRect.new()
	w.texture = _ring_texture(col)
	w.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(w)
	w.size = Vector2(60, 60)
	w.position = centro - w.size / 2.0
	w.pivot_offset = w.size / 2.0
	w.z_index = 70
	var sc := raggio / 30.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(w, "scale", Vector2(sc, sc), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(w, "modulate:a", 0.0, 0.45)
	tw.chain().tween_callback(w.queue_free)

func _scintille(centro: Vector2, col: Color, n: int = 10) -> void:
	for i in n:
		var s := ColorRect.new()
		s.color = col.lightened(0.25)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		s.size = Vector2(8, 8)
		s.position = centro - Vector2(4, 4)
		s.z_index = 70
		var ang := randf_range(0, TAU)
		var dist := randf_range(40, 120)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(s, "position", s.position + Vector2(cos(ang), sin(ang)) * dist, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "modulate:a", 0.0, 0.45)
		tw.chain().tween_callback(s.queue_free)

func _cell_center(reel: int, row: int) -> Vector2:
	return grid_root.position + grid_root.scale * (Vector2(reel * PITCH, row * PITCH) + Vector2(CELL / 2.0, CELL / 2.0))

func _flash_schermo(col: Color, alfa: float = 0.32, durata: float = 0.45) -> void:
	var f := ColorRect.new()
	f.color = Color(col.r, col.g, col.b, alfa)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(f)
	f.size = Vector2(VW, VH)
	f.z_index = 80
	var tw := create_tween()
	tw.tween_property(f, "color:a", 0.0, durata)
	tw.tween_callback(f.queue_free)

func _glow_lock(reel: int, row: int) -> void:
	# il sacco bloccato respira
	var p: ColorRect = cells[reel][row]["panel"]
	var tw := create_tween().set_loops()
	tw.tween_property(p, "modulate", Color(1.16, 1.12, 0.95), 0.75).set_trans(Tween.TRANS_SINE)
	tw.tween_property(p, "modulate", Color.WHITE, 0.75).set_trans(Tween.TRANS_SINE)
	cassa_glows.append(tw)

func _glow_stop() -> void:
	for g in cassa_glows:
		if g != null: g.kill()
	cassa_glows.clear()
	_tint_all(Color.WHITE)

func _popup_vincita(v: int) -> void:
	var lb := Label.new()
	lb.text = "+" + _fmt(v)
	lb.add_theme_font_size_override("font_size", 40)
	lb.add_theme_color_override("font_color", Color("#ffd700"))
	lb.add_theme_color_override("font_outline_color", Color("#5a3c08"))
	lb.add_theme_constant_override("outline_size", 10)
	add_child(lb)
	lb.position = Vector2(VW / 2.0 - 80.0, 300.0)
	lb.z_index = 75
	var tw := create_tween().set_parallel(true)
	tw.tween_property(lb, "position:y", 228.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lb, "modulate:a", 0.0, 0.8).set_delay(0.25)
	tw.chain().tween_callback(lb.queue_free)

func _celebra_vincita(amount: int) -> void:
	_dbg("H celebra")
	var x := float(amount) / float(_bet())
	var chiave := ""
	var livello := 0
	for idx in BIGWIN_SOGLIE.size():
		if x >= BIGWIN_SOGLIE[idx][0]:
			chiave = BIGWIN_SOGLIE[idx][1]
			livello = BIGWIN_SOGLIE.size() - idx   # 1=big, 2=mega, 3=epic
			break
	if chiave == "":
		return
	var mm_prima := mm_frames_attivi
	var lay := Node2D.new()
	add_child(lay)
	lay.add_to_group("scena_bonus")
	lay.z_index = 95
	# BUIO che cala
	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(veil)
	veil.size = Vector2(VW, VH)
	var tvin := create_tween()
	tvin.tween_property(veil, "color:a", 0.9 if livello >= 2 else 0.78, 0.4)
	_sfx("sfx_pre_colpo")
	await get_tree().create_timer(0.35).timeout
	# raggi rotanti dietro (piu' intensi salendo di livello)
	var raggi := Polygon2D.new()
	var rp := PackedVector2Array()
	var nr := 20
	for k in nr * 2:
		var ang := k * PI / nr
		var rad := 900.0 if k % 2 == 0 else 300.0
		rp.append(Vector2(cos(ang), sin(ang)) * rad)
	raggi.polygon = rp
	raggi.color = Color(1.0, 0.84, 0.2, 0.10 + 0.05 * livello)
	lay.add_child(raggi)
	raggi.position = Vector2(VW / 2.0, VH / 2.0 - 20.0)
	var trot := create_tween().set_loops()
	trot.tween_property(raggi, "rotation", TAU, 8.0 - livello)
	lay.tree_exiting.connect(func(): if trot.is_valid(): trot.kill())
	# il MASTERMIND entra da destra in posa d'esultanza
	if mm_win_frames.size() >= 2 or mm_normal != null:
		var mm := TextureRect.new()
		mm.texture = mm_win_frames[1] if mm_win_frames.size() >= 2 else mm_normal
		mm.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mm.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(mm)
		mm.size = Vector2(360, 400)
		mm.position = Vector2(VW - 300.0, VH - 400.0)
		var tmm := create_tween()
		tmm.tween_property(mm, "position:x", VW - 360.0, 0.4).from(VW + 40.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# il TITOLO esplode al centro
	var lb := Label.new()
	lb.text = T(chiave)
	lb.add_theme_font_size_override("font_size", 74 + 16 * livello)
	lb.add_theme_color_override("font_color", Color("#ffd700"))
	lb.add_theme_color_override("font_outline_color", Color("#5a1a05") if livello >= 3 else Color("#5a3c08"))
	lb.add_theme_constant_override("outline_size", 18 + 4 * livello)
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lay.add_child(lb)
	lb.size = Vector2(VW - 330.0, 150)   # CASE: a sinistra dell'ispettore
	lb.position = Vector2(0, VH / 2.0 - 150.0)
	lb.pivot_offset = lb.size / 2.0
	lb.scale = Vector2(2.6, 2.6)
	lb.modulate.a = 0.0
	var tt := create_tween().set_parallel(true)
	tt.tween_property(lb, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tt.tween_property(lb, "modulate:a", 1.0, 0.25)
	_sfx("sfx_jackpot")
	_flash_schermo(Color("#ffd700"), 0.4, 0.5)
	_shake(6.0 + 2 * livello, 0.4)
	await get_tree().create_timer(0.4).timeout
	# il PREMIO sale cifra per cifra
	var num := Label.new()
	num.add_theme_font_size_override("font_size", 96)
	num.add_theme_color_override("font_color", Color("#ffffff"))
	num.add_theme_color_override("font_outline_color", Color("#5a3c08"))
	num.add_theme_constant_override("outline_size", 16)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lay.add_child(num)
	num.size = Vector2(VW - 330.0, 130)
	num.position = Vector2(0, VH / 2.0 + 10.0)
	num.pivot_offset = num.size / 2.0
	var durata := 1.8 + 0.9 * livello   # epica = piu' lunga
	var tick = _find_audio("sfx_count")
	var tnum := create_tween()
	tnum.tween_method(func(v: float):
		num.text = _fmt(int(v))
		num.scale = Vector2(1.06, 1.06)
		, 0.0, float(amount), durata).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# monete a fontana + tin-tin durante la salita
	var coin_tex = load("res://assets/fx_coin.png") if ResourceLoader.exists("res://assets/fx_coin.png") else null
	var t0 := 0.0
	while tnum.is_running() and t0 < 8.0:
		await get_tree().create_timer(0.12).timeout
		t0 += 0.12
		if sfx_on and tick != null: _play_limited(spin_sfx_player, tick, "sfx_count")
		for i in (1 + livello):
			var c := TextureRect.new()
			if coin_tex != null: c.texture = coin_tex
			c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			lay.add_child(c)
			c.size = Vector2(46, 46)
			c.position = Vector2(randf_range(VW*0.15, VW*0.85), VH + 40.0)
			var su := randf_range(VH*0.2, VH*0.5)
			var tc := create_tween()
			tc.tween_property(c, "position:y", su, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tc.tween_property(c, "position:y", VH + 60.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tc.chain().tween_callback(c.queue_free)
	num.text = _fmt(amount)
	var np := create_tween()
	np.tween_property(num, "scale", Vector2(1.35, 1.35), 0.15)
	np.tween_property(num, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_flash_schermo(Color("#ffd700"), 0.4, 0.5)
	_shake(8.0 + 2 * livello, 0.5)
	await get_tree().create_timer(1.2 + 0.4 * livello).timeout
	var fade := create_tween()
	fade.tween_property(lay, "modulate:a", 0.0, 0.4)
	await _fine(fade)
	lay.queue_free()
	if mm_frames_attivi == "coins":
		mm_frames_attivi = mm_prima


# ================= SCENA BONUS (FX) =================

func _fx_start(banner_file: String, tint: Color) -> void:
	_dbg("H fx_start")
	# layer sopra tutto
	fx_layer = Node2D.new()
	add_child(fx_layer)
	# velo colorato d'atmosfera (non blocca i click)
	var veil := ColorRect.new()
	veil.color = tint
	veil.size = Vector2(VW, VH)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.add_child(veil)
	# vignetta radiale: luce al centro, buio ai bordi
	var vtex: GradientTexture2D
	if _tex_cache.has("vignetta"):
		vtex = _tex_cache["vignetta"]
	else:
		var vgrad := Gradient.new()
		vgrad.colors = PackedColorArray([Color(0,0,0,0.0), Color(0,0,0,0.0), Color(0,0,0,0.55)])
		vgrad.offsets = PackedFloat32Array([0.0, 0.62, 1.0])
		vtex = GradientTexture2D.new()
		vtex.gradient = vgrad
		vtex.fill = GradientTexture2D.FILL_RADIAL
		vtex.fill_from = Vector2(0.5, 0.5)
		vtex.fill_to = Vector2(0.5, 0.0)
		vtex.width = 512; vtex.height = 512
		_tex_cache["vignetta"] = vtex
	var vg := TextureRect.new()
	vg.texture = vtex
	vg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.add_child(vg)
	vg.size = Vector2(VW, VH)
	# banner che cala dall'alto. Priorita': 1) targa GENERICA + testo nella
	# lingua attiva; 2) banner con testo disegnato (in lingua o italiano);
	# 3) targa disegnata dal codice
	var L := _lang()
	var tkey0 := "colpo_titolo" if banner_file == "banner_colpo" else "cassa_titolo"
	if ResourceLoader.exists("res://assets/banner_scena.png"):
		var gb := TextureRect.new()
		gb.texture = load("res://assets/banner_scena.png")
		gb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		gb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		gb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fx_layer.add_child(gb)
		# v1.8: l'insegna sta TUTTA nei 120 px sopra i rulli del bonus
		gb.size = Vector2(600, 116)
		gb.position = Vector2((VW - 600) / 2.0, -150)
		var gl := Label.new()
		gl.text = T(tkey0)
		# larghezza vera del disegno (l'immagine e' centrata mantenendo le proporzioni)
		var art_w := gb.size.x
		if gb.texture != null and gb.texture.get_height() > 0:
			art_w = minf(gb.size.x, gb.size.y * float(gb.texture.get_width()) / float(gb.texture.get_height()))
		# il testo si rimpicciolisce finche' entra nel pannello centrale
		var fsz := 30
		var fnt: Font = gl.get_theme_font("font")
		while fsz > 16 and fnt != null and fnt.get_string_size(gl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x > art_w * 0.70:
			fsz -= 1
		gl.add_theme_font_size_override("font_size", fsz)
		gl.add_theme_color_override("font_color", Color("#ffe9a8"))
		gl.add_theme_color_override("font_outline_color", Color("#3a1005"))
		gl.add_theme_constant_override("outline_size", 6)
		gl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		gb.add_child(gl)
		# il testo sta nel pannello centrale dell'insegna (sotto il fregio in alto)
		gl.position = Vector2(0, gb.size.y * 0.16)
		gl.size = Vector2(gb.size.x, gb.size.y * 0.72)
		banner_node = gb
		var tg := create_tween()
		# v1.8: si ferma a y=2, tutta visibile, sopra i rulli del bonus (y=120)
		tg.tween_property(gb, "position:y", 2.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		return
	var bp := "res://assets/%s_%s.png" % [banner_file, L]
	if not ResourceLoader.exists(bp) and L == "it":
		bp = "res://assets/%s.png" % banner_file
	if ResourceLoader.exists(bp):
		banner_node = TextureRect.new()
		banner_node.texture = load(bp)
		banner_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		banner_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		banner_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fx_layer.add_child(banner_node)
		banner_node.size = Vector2(560, 105)
		banner_node.position = Vector2((VW - 560) / 2.0, -130)
		var tw := create_tween()
		tw.tween_property(banner_node, "position:y", 8.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		# targa disegnata col testo tradotto (finche' non generi il banner in lingua)
		var tkey := "colpo_titolo" if banner_file == "banner_colpo" else "cassa_titolo"
		var pn := Panel.new()
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color("#e3a93c")
		psb.border_color = Color("#ffe89a")
		psb.border_width_top = 4; psb.border_width_bottom = 4
		psb.border_width_left = 4; psb.border_width_right = 4
		psb.corner_radius_top_left = 18; psb.corner_radius_top_right = 18
		psb.corner_radius_bottom_left = 18; psb.corner_radius_bottom_right = 18
		psb.shadow_color = Color(0, 0, 0, 0.6); psb.shadow_size = 8; psb.shadow_offset = Vector2(0, 5)
		pn.add_theme_stylebox_override("panel", psb)
		pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fx_layer.add_child(pn)
		pn.size = Vector2(520, 84)
		pn.position = Vector2((VW - 520) / 2.0, -130)
		var lb := Label.new()
		lb.text = T(tkey)
		lb.add_theme_font_size_override("font_size", 40)
		lb.add_theme_color_override("font_color", Color("#6b1e12"))
		lb.add_theme_color_override("font_outline_color", Color("#ffe9a8"))
		lb.add_theme_constant_override("outline_size", 6)
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pn.add_child(lb)
		lb.size = pn.size
		banner_node = null
		var tw2 := create_tween()
		tw2.tween_property(pn, "position:y", 18.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# pioggia di soldi
	rain_on = true
	_rain_loop()
	# Mastermind: posa vittoria + ondeggio continuo
	if mastermind_node != null:
		mm_frames_attivi = "win"
		# senza frame win: se ci sono gli idle animati restano loro, altrimenti la posa fissa
		if mm_win != null and mm_win_frames.size() < 2 and mm_idle_frames.size() < 2:
			mastermind_node.texture = mm_win
		mastermind_node.pivot_offset = Vector2(mastermind_node.size.x / 2.0, mastermind_node.size.y)
		var jump := create_tween()
		jump.tween_property(mastermind_node, "scale", Vector2(1.12, 1.12), 0.18)
		jump.tween_property(mastermind_node, "scale", Vector2(1.0, 1.0), 0.22)
		mm_sway_tween = create_tween().set_loops()
		mm_sway_tween.tween_property(mastermind_node, "rotation_degrees", 3.0, 0.8).set_trans(Tween.TRANS_SINE)
		mm_sway_tween.tween_property(mastermind_node, "rotation_degrees", -3.0, 0.8).set_trans(Tween.TRANS_SINE)

func _fx_stop() -> void:
	rain_on = false
	if mm_sway_tween != null:
		mm_sway_tween.kill(); mm_sway_tween = null
	if mastermind_node != null:
		mastermind_node.rotation_degrees = 0.0
		mastermind_node.scale = Vector2.ONE
		if mm_normal != null:
			mastermind_node.texture = mm_normal
	if banner_node != null:
		var tw := create_tween()
		tw.tween_property(banner_node, "position:y", -140.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if fx_layer != null:
		var f := fx_layer
		fx_layer = null
		await get_tree().create_timer(0.4).timeout
		f.queue_free()

func _rain_loop() -> void:
	var coin_tex = load("res://assets/fx_coin.png") if ResourceLoader.exists("res://assets/fx_coin.png") else null
	var bill_tex = load("res://assets/fx_bill.png") if ResourceLoader.exists("res://assets/fx_bill.png") else null
	while rain_on and fx_layer != null:
		for i in 2:
			_spawn_money(coin_tex if randi() % 2 == 0 else bill_tex)
		await get_tree().create_timer(0.22).timeout

func _spawn_money(tex) -> void:
	if fx_layer == null: return
	var s := TextureRect.new()
	if tex != null:
		s.texture = tex
	else:
		var cr := ColorRect.new(); cr.color = Color("#ffd700"); cr.size = Vector2(20,20)
		s.add_child(cr)
	var sz := randf_range(0.5, 1.1)
	s.size = Vector2(64, 64) * sz
	s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.position = Vector2(randf_range(0, VW - 60), -70)
	s.pivot_offset = s.size / 2.0
	s.rotation_degrees = randf_range(-40, 40)
	fx_layer.add_child(s)
	var dur := randf_range(1.6, 2.8)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(s, "position:y", VH + 80.0, dur)
	tw.tween_property(s, "position:x", s.position.x + randf_range(-120, 120), dur)
	tw.tween_property(s, "rotation_degrees", s.rotation_degrees + randf_range(-260, 260), dur)
	tw.chain().tween_callback(s.queue_free)

func _burst_money(n: int) -> void:
	# esplosione di monete dal centro (per le grandi vincite)
	var coin_tex = load("res://assets/fx_coin.png") if ResourceLoader.exists("res://assets/fx_coin.png") else null
	if fx_layer == null: return
	for i in n:
		var s := TextureRect.new()
		if coin_tex != null: s.texture = coin_tex
		s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		s.size = Vector2(48, 48)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.position = Vector2(VW/2.0 - 24, VH/2.0 - 24)
		s.pivot_offset = s.size / 2.0
		fx_layer.add_child(s)
		var ang := randf_range(0, TAU)
		var dist := randf_range(150, 420)
		var target := s.position + Vector2(cos(ang), sin(ang)) * dist
		var tw := create_tween().set_parallel(true)
		tw.tween_property(s, "position", target, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "rotation_degrees", randf_range(-360, 360), 0.9)
		tw.tween_property(s, "modulate:a", 0.0, 0.9).set_delay(0.35)
		tw.chain().tween_callback(s.queue_free)


# ============ TRANSIZIONE SCENA BONUS ============

func _bonus_enter() -> void:
	_dbg("H bonus_enter")
	# 1) raffica di pioggia che copre lo schermo
	var coin_tex = load("res://assets/fx_coin.png") if ResourceLoader.exists("res://assets/fx_coin.png") else null
	var bill_tex = load("res://assets/fx_bill.png") if ResourceLoader.exists("res://assets/fx_bill.png") else null
	var storm := Node2D.new()
	add_child(storm)
	for i in 90:
		var s := TextureRect.new()
		var tex = coin_tex if i % 2 == 0 else bill_tex
		if tex != null: s.texture = tex
		var sz := randf_range(0.7, 1.5)
		s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		s.size = Vector2(64, 64) * sz   # DOPO expand_mode: altrimenti prende la taglia dell'immagine
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.position = Vector2(randf_range(-40, VW), randf_range(-720, -60))
		s.rotation_degrees = randf_range(-60, 60)
		storm.add_child(s)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(s, "position:y", VH + 100.0, randf_range(0.7, 1.2))
		tw.tween_property(s, "rotation_degrees", s.rotation_degrees + randf_range(-300, 300), 1.2)
	# 2) dietro la pioggia, riconfiguro la scena
	await get_tree().create_timer(0.55).timeout
	for nd in hud_nodes:
		if is_instance_valid(nd): nd.visible = false
	win_label.text = ""
	# rulli grandi al centro
	var gs := 1.32
	var tw2 := create_tween().set_parallel(true)
	tw2.tween_property(grid_root, "scale", Vector2(gs, gs), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw2.tween_property(grid_root, "position", Vector2((VW - 340 - GRID_W * gs) / 2.0 + 10, 120.0), 0.4)
	await get_tree().create_timer(0.7).timeout
	storm.queue_free()

func _bonus_exit() -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(grid_root, "scale", Vector2.ONE, 0.35)
	tw.tween_property(grid_root, "position", Vector2(GRID_X, GRID_Y), 0.35)
	await _fine(tw)
	for nd in hud_nodes:
		if is_instance_valid(nd): nd.visible = true


# ================= AUDIO =================

func _audio_setup() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -6.0
	add_child(music_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -3.0
	add_child(sfx_player)
	spin_sfx_player = AudioStreamPlayer.new()
	spin_sfx_player.volume_db = -6.0
	add_child(spin_sfx_player)
	_play_music("music_base")

func _find_audio(name: String):
	for ext in ["mp3", "ogg", "wav"]:
		var p := "res://assets/audio/%s.%s" % [name, ext]
		if ResourceLoader.exists(p):
			return load(p)
	return null

func _play_music(name: String) -> void:
	if name == current_music and music_player.playing:
		return
	var stream = _find_audio(name)
	if stream == null:
		return
	current_music = name
	if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
		stream.loop = true
	music_player.stream = stream
	if music_on:
		music_player.play()

func _stop_music() -> void:
	music_player.stop()
	current_music = ""

# durata massima di ogni effetto (secondi): oltre, il gioco lo spegne con dissolvenza
const SFX_MAX_S := {
	"sfx_reel_stop": 0.25, "sfx_whoosh": 0.45, "sfx_count": 0.10, "sfx_premium": 0.6,
	"sfx_vetro": 0.5, "sfx_esplosione": 0.9, "sfx_tool": 0.3, "sfx_unlock": 0.7,
	"sfx_cassaforte_apri": 1.0, "sfx_wild_espanso": 0.5,
	"sfx_pre_cassa": 2.4, "sfx_pre_colpo": 2.4, "sfx_pre_rosso": 2.0, "sfx_pre_verde": 2.0,
	"sfx_pre_blu": 2.0, "sfx_polizia": 2.0, "sfx_battito": 2.4,
}

# volume per singolo effetto, in dB (0 = com'e' nel file; +6 = doppio; -6 = meta')
const SFX_GAIN_DB := {
	"sfx_battito": 6.0, "sfx_pre_cassa": 0.0, "sfx_pre_colpo": 0.0, "sfx_pre_rosso": 0.0,
	"sfx_pre_verde": 0.0, "sfx_pre_blu": 2.0, "sfx_polizia": 0.0, "sfx_esplosione": 0.0,
	"sfx_reel_stop": 0.0, "sfx_count": 0.0, "sfx_whoosh": 0.0, "sfx_premium": 0.0,
}

func _play_limited(player: AudioStreamPlayer, stream, name: String) -> void:
	# suona (col suo volume) e, se il file e' piu' lungo del dovuto, lo spegne al momento giusto
	if not sfx_on or stream == null: return
	player.stream = stream
	player.volume_db = float(SFX_GAIN_DB.get(name, 0.0))
	player.play()
	if not SFX_MAX_S.has(name): return
	var limite: float = SFX_MAX_S[name]
	await get_tree().create_timer(limite - 0.08).timeout
	if player.stream == stream and player.playing:
		var tw := create_tween()
		tw.tween_property(player, "volume_db", -40.0, 0.08)
		await _fine(tw)
		if player.stream == stream:
			player.stop()
		player.volume_db = 0.0

func _sfx(name: String) -> void:
	if not sfx_on: return
	var stream = _find_audio(name)
	if stream == null: return
	_play_limited(sfx_player, stream, name)



# MAPPA_SIMBOLI (Midnight Case): il motore usa i nomi di Midnight Heist,
# i file in assets/symbols/ sono i disegni del detective:
#   gem_red=card_j  gem_blue=card_q  gem_green=card_k  gem_purple=card_a
#   crown=orologio  star=revolver  wild=distintivo  scatter=lente
#   coin=fascicolo  tool_red=impronta  tool_green=cappello  tool_blue=bossolo
#   dinamite=flash (solo nei giri gratis)
