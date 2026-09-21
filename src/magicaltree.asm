; ==========================================================================
; MAGICAL TREE - Konami - MSX1 - cartucho RC-713 de 16 KB en la pagina 1
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: "AB" y la direccion de INIT (0x4077);
;   STATEMENT, DEVICE y TEXT a cero
;   0x4000..0x4010  (16 bytes)
DATA_cabecera_del_cartucho:
	defw 04241h,04077h,00000h,00000h,00000h,00000h,00000h,00000h	; 4000

; ======================================================================
; CODIGO 0x4010..0x40c3  (179 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ESCRIBIR Y LEER LA VRAM. Las dos rutinas que usa todo el cartucho en vez de la BIOS: preparan el puerto una vez y luego mueven los bytes con el registro C ya cargado en el juego alternativo, de modo que sacar un byte es un solo `out (c),a`.
; ----------------------------------------------------------------------
escribe_en_vram:
	call prepara_escritura_vram		;4010   ; pone el puntero de escritura y deja 0x98 en C'
	exx			;4013   ; al juego alternativo, donde C es el puerto de datos del VDP
	out (c),a		;4014   ; y ahi va el byte
	exx			;4016   ; de vuelta al juego normal
	ei			;4017   ; la rutina de abajo entro con `di`
	ret			;4018
lee_de_vram:
	call prepara_lectura_vram		;4019   ; lo mismo para leer
	exx			;401c   ; al juego alternativo, igual que al escribir
	in a,(c)		;401d   ; el byte leido vuelve en A
	exx			;401f
	ei			;4020   ; la lectura tambien entro con `di`
	ret			;4021

; ----------------------------------------------------------------------
; SUMAR UN INDICE DE OCHO BITS A UN PUNTERO, con el acarreo propagado a mano. Dos gemelas, una para HL y otra para DE; las llama medio cartucho para indexar tablas.
; ----------------------------------------------------------------------
suma_a_a_hl:
	add a,l			;4022   ; HL += A
	ld l,a			;4023
	ret nc			;4024   ; sin acarreo, ya esta
	inc h			;4025   ; y con acarreo, el byte alto
	ret			;4026
suma_a_a_de:
	add a,e			;4027   ; DE += A, la gemela
	ld e,a			;4028
	ret nc			;4029
	inc d			;402a   ; y con acarreo, el byte alto
	ret			;402b

; ----------------------------------------------------------------------
; EL GANCHO DE LA INTERRUPCION, donde vive el juego entero: INIT lo engancha en H.KEYI y se queda en el `jr $` de 0x40A5, asi que todo lo que pasa, pasa una vez por cuadro desde aqui. El cerrojo de (0xE005) es de UN BIT -`bit 0,(hl)`-, al contrario que en Circus Charlie, que lleva un contador.
; ----------------------------------------------------------------------
gancho_de_interrupcion:
	di			;402c   ; la interrupcion entra con todo cerrado
	call 0013eh		;402d   ; BIOS RDVDP - Reads VDP status register | lee el estado del VDP para que baje su bandera
	call suena_un_cuadro		;4030   ; el sonido, lo primero
	ld hl,0e005h		;4033   ; el cerrojo de reentrada
	bit 0,(hl)		;4036   ; si ya hay una dentro, no se entra otra vez
	jr nz,L_4047		;4038   ; con el cerrojo tomado se sale sin hacer nada
	inc (hl)			;403a   ; y si no, se toma
	ei			;403b   ; se abren las interrupciones ESTANDO dentro
	call lee_los_mandos		;403c   ; lee los mandos y el teclado
	call reparte_la_escena		;403f   ; y aqui se despacha la escena
	di			;4042   ; al salir se vuelve a cerrar
	xor a			;4043
	ld (0e005h),a		;4044   ; el cerrojo es de UN BIT: basta con dejarlo a cero
L_4047:
	ei			;4047
	reti		;4048   ; y se sale con las interrupciones ya abiertas

; ----------------------------------------------------------------------
; EL DESPACHADOR DE ESCENAS: la tabla va PEGADA detras del `call`, y el `pop hl` recupera su propia direccion de retorno, que es justo donde empieza. Quien llama solo pasa el numero de escena en A.
; ----------------------------------------------------------------------
despacha_por_tabla:
	add a,a			;404a   ; el numero de escena, por dos: son palabras
	pop hl			;404b   ; la direccion de retorno ES la tabla
	call suma_a_a_hl		;404c   ; la entrada que toca
	ld e,(hl)			;404f   ; y de ahi el destino
	inc hl			;4050
	ld d,(hl)			;4051   ; la palabra del destino
	ex de,hl			;4052   ; a HL, que es el unico par con el que se puede saltar
	jp (hl)			;4053   ; se salta sin dejar retorno

; ----------------------------------------------------------------------
; INTERCAMBIAR DOS BLOQUES DE B BYTES sin memoria auxiliar, byte a byte.
; ----------------------------------------------------------------------
intercambia_bloques:
	ld c,(hl)			;4054   ; el de (HL)
	ld a,(de)			;4055   ; y el de (DE)
	ld (hl),a			;4056   ; cada uno al sitio del otro
	ld a,c			;4057   ; el que estaba guardado va al otro lado
	ld (de),a			;4058
	inc hl			;4059
	inc de			;405a   ; y el siguiente par de bytes
	djnz intercambia_bloques		;405b
	ret			;405d

; ----------------------------------------------------------------------
; EL INTERPRETE DE ROTULOS, con dos puertas que solo cambian la mascara. El guion trae [destino en VRAM, palabra] y luego los indices, con 0xFE para saltar a otro destino y 0xFF para terminar. Con la mascara a 0x00 se escriben ceros: el MISMO guion borra el rotulo.
; ----------------------------------------------------------------------
borra_rotulo:
	ld c,000h		;405e   ; mascara 0x00: BORRA
	jr L_4064		;4060
pinta_rotulo:
	ld c,0ffh		;4062   ; mascara 0xFF: pinta
L_4064:
	ld e,(hl)			;4064   ; de la cabecera sale el destino en la VRAM
	inc hl			;4065
	ld d,(hl)			;4066   ; la palabra del destino, byte bajo primero
	inc hl			;4067
L_4068:
	ld a,(hl)			;4068   ; el siguiente byte del guion
	inc hl			;4069
	ld b,a			;406a   ; B es la copia con la que se miran los dos codigos de control sin perder A
	inc b			;406b   ; 0xFF es el fin del rotulo
	ret z			;406c
	inc b			;406d   ; 0xFE es "sigue en otro sitio"
	jr z,L_4064		;406e
	and c			;4070   ; aqui muerde la mascara
	call escribe_en_vram		;4071   ; y a la VRAM
	inc de			;4074   ; la siguiente celda
	jr L_4068		;4075

; ----------------------------------------------------------------------
; INIT, la direccion que trae la cabecera. Cuatro cosas y a dormir: modo 1 de interrupcion, gancho en H.KEYI, pila en 0xE400 y un kilobyte de RAM a cero. Desde el `ei` final, el juego entero corre dentro de la interrupcion.
; ----------------------------------------------------------------------
init:
	di			;4077
	im 1		;4078   ; modo 1: la interrupcion entra por 0x0038 y la BIOS la encamina a H.KEYI
	ld a,0c3h		;407a   ; un `jp` en 0xFD9A y la direccion detras: asi se engancha H.KEYI
	ld (0fd9ah),a		;407c
	ld hl,gancho_de_interrupcion		;407f   ; el gancho es el de 0x402C
	ld (0fd9bh),hl		;4082   ; y detras del `jp`, la direccion del gancho
	ld sp,0e400h		;4085   ; la pila, por encima de las variables
	ld hl,0e000h		;4088   ; y las variables, a cero de 0xE000 a 0xE3FF
	ld de,0e001h		;408b
	ld bc,003ffh		;408e
	ld (hl),000h		;4091   ; el clasico ldir sobre si mismo: se pone UN cero y el resto lo arrastra
	ldir		;4093
	ld a,001h		;4095   ; el cerrojo, tomado durante el arranque
	ld (0e005h),a		;4097   ; nadie va a atender un cuadro mientras se monta el hardware
	call arranca_el_hardware		;409a   ; prepara el VDP y la pantalla
	xor a			;409d   ; el hardware ya esta, se puede soltar
	ld (0e005h),a		;409e   ; y ahora si, se suelta
	call 0013eh		;40a1   ; BIOS RDVDP - Reads VDP status register
	ei			;40a4
espera_para_siempre:
	jr espera_para_siempre		;40a5   ; aqui se queda el hilo principal: lo demas pasa en la interrupcion

; ----------------------------------------------------------------------
; EL REPARTO DE ESCENAS. El numero esta en (0xE000) y, ademas, se APILA a mano la direccion por la que seguira cuando la escena haga `ret`: una de dos, segun el bit 6 de (0xE002). La escena 8 es la excepcion y por eso se salta el `push`.
; ----------------------------------------------------------------------
reparte_la_escena:
	ld hl,0e003h		;40a7   ; el contador de cuadros
	inc (hl)			;40aa   ; un cuadro mas; no se pone nunca a cero, da la vuelta sola
	ld a,(0e002h)		;40ab   ; el bit 6 decide cual de los dos remates se apila
	and 040h		;40ae   ; aisla el bit 6
	ld hl,043aah		;40b0   ; uno
	jr nz,L_40B8		;40b3
	ld hl,04557h		;40b5   ; y el otro
L_40B8:
	ld a,(0e000h)		;40b8   ; el numero de escena
	cp 008h		;40bb   ; la escena 8 no lleva remate
	jr z,L_40C0		;40bd
	push hl			;40bf   ; aqui se fabrica el retorno
L_40C0:
	call despacha_por_tabla		;40c0   ; y la tabla de dieciseis va pegada detras

; ----------------------------------------------------------------------
; DATOS tabla_de_escenas: 16 entradas; la primera apunta a 0x40E3, justo
;   detras de la tabla
;   0x40c3..0x40e3  (32 bytes)
DATA_tabla_de_escenas:
	defw 040e3h,040f0h,04102h,04114h,04116h,0411dh,04126h,0412fh	; 40c3
	defw 0420eh,0413bh,0415eh,04184h,04195h,041cfh,041e3h,04203h	; 40d3

; ======================================================================
; CODIGO 0x40e3..0x4247  (356 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ESCENA 0: el arranque frio, que monta la pantalla del titulo.
; ----------------------------------------------------------------------
L_40E3:
	call baja_los_contadores_y_barre		;40e3
	ret p			;40e6   ; `ret p`: con el bit 7 puesto todavia queda cuenta atras
	call monta_la_pantalla_del_titulo		;40e7
	call vuelca_los_registros_del_vdp		;40ea
	jp pasa_a_la_escena_siguiente		;40ed

; ----------------------------------------------------------------------
; ESCENA 1: el letrero de "VIDEO CARTRIDGE" parpadeando, uno de cada dos cuadros.
; ----------------------------------------------------------------------
L_40F0:
	ld a,(0e003h)		;40f0   ; el contador de cuadros
	rra			;40f3   ; su bit 0 al acarreo
	ret nc			;40f4
	call baja_el_logotipo_un_paso		;40f5   ; y el resto del parpadeo lo lleva el logotipo
	ret nz			;40f8
	ld hl,047bch		;40f9   ; el rotulo
	call pinta_rotulo		;40fc   ; con la mascara a 0xFF: pintandolo
	xor a			;40ff   ; plazo cero
	jr L_417C		;4100

; ----------------------------------------------------------------------
; ESCENA 2: la cuenta atras que limpia la franja y apaga la bandera de 0xE00A.
; ----------------------------------------------------------------------
L_4102:
	ld hl,0e004h		;4102   ; el plazo
	dec (hl)			;4105   ; un cuadro menos del plazo
	ret nz			;4106
	ld de,03880h		;4107   ; la franja de abajo
	ld bc,00100h		;410a   ; 256 celdas
	xor a			;410d   ; a cero: la franja se borra
	ld (0e00ah),a		;410e   ; y la bandera de 0xE00A tambien
	call rellena_vram		;4111
L_4114:
	jr pasa_a_la_escena_siguiente		;4114

; ----------------------------------------------------------------------
; ESCENA 3: espera a que el jugador se decida.
; ----------------------------------------------------------------------
L_4116:
	call barre_una_franja		;4116
	ret c			;4119   ; mientras devuelva acarreo, queda pantalla por barrer
	xor a			;411a   ; escena 0, la primera de la partida
	jr L_417C		;411b

; ----------------------------------------------------------------------
; ESCENA 4: otro plazo, el de la pantalla de seleccion.
; ----------------------------------------------------------------------
L_411D:
	ld hl,0e004h		;411d
	dec (hl)			;4120   ; el plazo de la pantalla de seleccion
	jp nz,parpadea_el_cursor		;4121   ; mientras corre, solo parpadea el cursor
	jr plazo_de_32_y_siguiente_escena		;4124

; ----------------------------------------------------------------------
; ESCENA 5: empieza partida.
; ----------------------------------------------------------------------
L_4126:
	call baja_los_contadores_y_barre		;4126
	ret p			;4129   ; hasta que las dos cuentas no llegan a cero, no se arranca
	call arranca_la_vida		;412a
	jr plazo_de_32_y_siguiente_escena		;412d

; ----------------------------------------------------------------------
; ESCENA 6: arranca la vida.
; ----------------------------------------------------------------------
L_412F:
	call avanza_el_guion_y_sigue		;412f
	ld a,(0e00ch)		;4132   ; si (0xE00C) esta a cero, todavia no toca
	or a			;4135   ; cero quiere decir que todavia no
	ret z			;4136
L_4137:
	xor a			;4137
	jp L_41FA		;4138

; ----------------------------------------------------------------------
; ESCENA 7.
; ----------------------------------------------------------------------
L_413B:
	ld a,(0e00dh)		;413b   ; la senal de fin de partida
	or a			;413e   ; cero es "la partida sigue"
	jr nz,L_415C		;413f
	call baja_los_contadores_y_barre		;4141
	ret p			;4144
	ld hl,0e050h		;4145   ; el contador de vidas
	dec (hl)			;4148   ; una menos: esta se va a jugar
	call pinta_el_marcador		;4149   ; repinta el marcador
	ld a,(0e002h)		;414c   ; el bit 5 dice si hay dos jugadores
	and 020h		;414f   ; el bit 5
	jr z,L_4159		;4151
	ld hl,047b1h		;4153   ; el rotulo "PLAYER 1"
	call pinta_rotulo_con_marca		;4156
L_4159:
	call pinta_la_altura_y_el_marcador		;4159   ; y detras, la altura y el marcador enteros
L_415C:
	jr pasa_a_la_escena_siguiente		;415c

; ----------------------------------------------------------------------
; EL CIERRE DE LA VIDA. Espera a que no quede nada sonando y entonces elige el sonido segun el bit 0 de (0xE05E): el 9 o el 0x8C. Deja el plazo en 32 cuadros y pasa a la escena siguiente.
; ----------------------------------------------------------------------
espera_a_que_pare_el_sonido:
	ld a,(0e012h)		;415e   ; lo que este sonando
	or a			;4161   ; mientras suene algo, no se cierra la vida
	ret nz			;4162
	ld a,(0e05eh)		;4163   ; la bandera que elige el sonido
	rra			;4166   ; el bit 0 elige entre los dos sonidos
	ld a,009h		;4167   ; un sonido
	jr c,L_416D		;4169
	ld a,08ch		;416b   ; o el otro
L_416D:
	call pide_un_sonido		;416d
	xor a			;4170   ; la bandera de "ya se hizo", a cero
	ld (0e001h),a		;4171
	ld hl,00000h		;4174
	ld (0e00ch),hl		;4177   ; y las dos senales de fin, de una tacada
plazo_de_32_y_siguiente_escena:
	ld a,020h		;417a   ; 32 cuadros de plazo
L_417C:
	ld (0e004h),a		;417c   ; el plazo, donde lo mira la escena siguiente
pasa_a_la_escena_siguiente:
	ld hl,0e000h		;417f   ; el numero de escena
	inc (hl)			;4182   ; la siguiente
	ret			;4183

; ----------------------------------------------------------------------
; ESCENA 8: el compas de la partida. Mientras (0xE00C) o el byte de al lado no sean cero, se sigue; cuando los dos lo son, se pasa a la escena 15.
; ----------------------------------------------------------------------
L_4184:
	call el_cuadro_del_juego		;4184
	ld hl,0e00ch		;4187   ; la senal de fin
	ld a,(hl)			;418a
	or a			;418b   ; cero es que la partida sigue
	jr nz,plazo_de_32_y_siguiente_escena		;418c
	inc hl			;418e   ; y el byte de al lado, la otra senal
	or (hl)			;418f   ; y su pareja
	ret z			;4190   ; con las dos a cero no hay nada que cerrar
	ld a,00fh		;4191   ; escena 15
	jr L_41FA		;4193

; ----------------------------------------------------------------------
; ESCENA 9: quedan vidas? Si no, suena el 0x93, se pintan los rotulos del final y se pasa a la escena 13.
; ----------------------------------------------------------------------
L_4195:
	ld a,(0e050h)		;4195   ; las vidas
	or a			;4198   ; si quedan, no es el final
	jr nz,L_41C5		;4199   ; quedando vidas, se sigue jugando
	ld a,(0e012h)		;419b   ; espera a que pare el sonido
	or a			;419e   ; mientras suene algo, no se cierra la partida
	ret nz			;419f   ; mientras suene algo, no se sigue
	ld a,093h		;41a0   ; el sonido del final
	call pide_un_sonido		;41a2   ; pedido
	ld hl,047a4h		;41a5   ; los rotulos
	call pinta_rotulo_con_marca		;41a8   ; pintados
	ld hl,04247h		;41ab   ; el otro rotulo
	call pinta_rotulo		;41ae   ; pintado
	ld hl,0e1bdh		;41b1   ; la altura
	ld de,039f1h		;41b4   ; y su celda
	call imprime_dos_bytes_bcd		;41b7   ; y la altura alcanzada
	call pinta_el_marcador		;41ba   ; el marcador
	ld a,00dh		;41bd   ; escena 13
	ld (0e000h),a		;41bf   ; y se pasa a ella
	xor a			;41c2   ; plazo cero: el cartel se queda puesto
	jr L_417C		;41c3
L_41C5:
	ld a,(0e080h)		;41c5   ; si el otro jugador tiene partida, se le cede el turno
	or a			;41c8   ; cero es "el otro no tiene partida"
	jr nz,pasa_a_la_escena_siguiente		;41c9
L_41CB:
	ld a,009h		;41cb   ; escena 9, la que mira si quedan vidas
	jr L_41FA		;41cd

; ----------------------------------------------------------------------
; EL CAMBIO DE JUGADOR, y es una sola instruccion la que lo hace todo: los treinta y dos bytes del que juega viven en 0xE050 y los del otro en 0xE080, y se PERMUTAN. No hay indices ni dos copias de la logica: el jugador en turno esta siempre en 0xE050.
; ----------------------------------------------------------------------
cambia_de_jugador:
	ld hl,0e050h		;41cf   ; el estado del que juega
	ld de,0e080h		;41d2   ; y el del que espera
	ld b,020h		;41d5   ; treinta y dos bytes cada uno
	call intercambia_bloques		;41d7   ; y se cambian de sitio
	ld hl,0e002h		;41da
	ld a,(hl)			;41dd   ; el byte de banderas
	xor 080h		;41de   ; el bit 7 dice de quien es el turno
	ld (hl),a			;41e0
	jr L_41CB		;41e1   ; y a la escena 9, ya con los bloques permutados

; ----------------------------------------------------------------------
; ESCENA 10: el relevo, cuando se agota el plazo.
; ----------------------------------------------------------------------
L_41E3:
	ld hl,0e004h		;41e3   ; el plazo
	dec (hl)			;41e6   ; un cuadro menos del cartel de relevo
	ret nz			;41e7
	ld a,(0e080h)		;41e8   ; el estado del otro jugador
	or a			;41eb   ; cero es "el otro no tiene partida"
	jr nz,escena_13_con_plazo_de_32		;41ec
	ld hl,0e002h		;41ee
	ld a,(hl)			;41f1
	and 0bfh		;41f2   ; apaga el bit 6 de (0xE002)
	ld (hl),a			;41f4
	jp L_4137		;41f5   ; sigue el mismo jugador
escena_13_con_plazo_de_32:
	ld a,00dh		;41f8   ; escena 13
L_41FA:
	ld (0e000h),a		;41fa   ; la escena elegida, que es lo que mira el reparto del cuadro siguiente
	ld a,020h		;41fd   ; y 32 cuadros de plazo
	ld (0e004h),a		;41ff
	ret			;4202

; ----------------------------------------------------------------------
; ESCENA 11: el plazo del relevo; al agotarse, escena 9.
; ----------------------------------------------------------------------
L_4203:
	ld hl,0e004h		;4203
	dec (hl)			;4206   ; el plazo del relevo
	ret nz			;4207
	ld a,009h		;4208   ; escena 9
	ld (0e000h),a		;420a
	ret			;420d

; ----------------------------------------------------------------------
; ESCENA 15: el fin de partida. Suena el 0x96, se pinta el cartel y quedan 80 cuadros; mientras corren, el bit 3 del propio plazo hace parpadear lo que hay en pantalla.
; ----------------------------------------------------------------------
fin_de_partida:
	ld a,(0e001h)		;420e   ; solo la primera vez
	or a			;4211   ; cero es la primera vez que se entra
	jr nz,L_422C		;4212
	ld a,096h		;4214   ; el sonido del fin de partida
	call pide_un_sonido		;4216
	ld a,050h		;4219   ; 80 cuadros
	ld (0e004h),a		;421b   ; 80 cuadros para el cartel
L_421E:
	call limpia_la_pantalla		;421e   ; limpia
	call carga_los_graficos_del_titulo		;4221   ; y se monta el decorado del cartel
	call barre_la_pantalla_entera		;4224   ; barrida entera de una vez
	ld hl,0e001h		;4227
	inc (hl)			;422a   ; se marca que ya se hizo
	ret			;422b
L_422C:
	ld hl,0e004h		;422c
	dec (hl)			;422f   ; el plazo del cartel de fin de partida
	jr z,L_4241		;4230
	bit 3,(hl)		;4232   ; el bit 3 del plazo: parpadeo de ocho en ocho cuadros
	jp nz,barre_la_pantalla_entera		;4234
	call donde_va_el_cursor		;4237   ; la celda donde esta el cursor
	ld bc,0001bh		;423a   ; 27 celdas que borrar
	xor a			;423d   ; cero: lo que se escribe es la celda vacia
	jp rellena_vram		;423e
L_4241:
	call borra_el_tanteo		;4241   ; y al agotarse, se borra el tanteo
	jp plazo_de_32_y_siguiente_escena		;4244

; ----------------------------------------------------------------------
; DATOS guion_0x4247: 16 bytes, 2 tramos, 10 bytes a la VRAM; lo pinta 0x41AB
;   0x4247..0x4257  (16 bytes)
DATA_guion_0x4247:
	defb 0e9h,039h,03bh,048h,045h,049h,047h,048h,054h,040h,0feh,0f5h,039h,018h,03bh,0ffh	; 4247  .9;HEIGHT@..9.;.

; ======================================================================
; CODIGO 0x4257..0x44ff  (680 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL MONTAJE DE LA PANTALLA DEL TITULO, y acaba con un bucle que repite DIECISEIS veces el mismo bloquecito de dieciseis bytes por la VRAM: es como se pinta la cenefa sin guardarla dieciseis veces.
; ----------------------------------------------------------------------
monta_la_pantalla_del_titulo:
	call monta_el_logotipo_de_konami		;4257
	call rellena_y_vuelca		;425a
carga_los_graficos_del_titulo:
	ld a,070h		;425d   ; el relleno de color
	ld de,01600h		;425f   ; la tabla de color
	call rellena_una_franja		;4262
	ld hl,047d2h		;4265   ; los patrones del titulo
	call descomprime		;4268
	ld de,00600h		;426b   ; desde la celda 0x600
	ld b,010h		;426e   ; dieciseis veces
L_4270:
	push bc			;4270
	push de			;4271
	ld hl,04894h		;4272   ; el mismo bloquecito
	call descomprime_en_de		;4275
	pop hl			;4278
	ld bc,00010h		;4279   ; y cada vuelta dieciseis celdas mas alla
	add hl,bc			;427c   ; dieciseis celdas mas alla en cada vuelta
	ex de,hl			;427d
	pop bc			;427e
	djnz L_4270		;427f
	ret			;4281
parpadea_el_cursor:
	ld bc,03e3fh		;4282   ; el par de patrones del cursor
	bit 3,(hl)		;4285   ; el bit 3 del plazo
	jr nz,L_428C		;4287
pinta_el_cursor:
	ld bc,00000h		;4289   ; y en la otra mitad, celdas vacias
L_428C:
	call donde_va_el_cursor		;428c   ; donde va el cursor
	ld a,b			;428f   ; el primero de los dos patrones
	call escribe_en_vram		;4290
	ld a,c			;4293
	inc de			;4294   ; y el de al lado
	call escribe_en_vram		;4295
	ret			;4298

; ----------------------------------------------------------------------
; DONDE CAE EL CURSOR DEL MENU. La opcion vive en (0xE042); sumando 0x14 y girando dos veces sale el byte bajo de la celda, con la fila 0x7A fija en D.
; ----------------------------------------------------------------------
donde_va_el_cursor:
	ld a,(0e042h)		;4299   ; la opcion elegida
	add a,014h		;429c   ; el desplazamiento a la primera fila del menu
	rrca			;429e   ; dos giros, y son ROTACIONES: el bit que se sale por abajo sube al 7, y es el que separa una opcion de la siguiente. Salen las filas 16, 18, 20 y 22, o sea DOS filas por opcion, que son las que pinta el guion de 0x472B
	rrca			;429f
	ld e,a			;42a0   ; el byte bajo ya es la celda: no hay nada mas que sumar
	ld d,07ah		;42a1   ; la pagina, fija
	ret			;42a3
pinta_rotulo_con_marca:
	call pinta_rotulo		;42a4   ; el rotulo
	ld a,(0e002h)		;42a7   ; el turno
	or a			;42aa   ; el bit 7 al signo
	ret p			;42ab   ; sin marca, aqui se acaba
	ld a,032h		;42ac   ; el patron de la marca
	dec de			;42ae   ; la celda de delante del rotulo
	call escribe_en_vram		;42af
	ret			;42b2

; ----------------------------------------------------------------------
; BAJAR LOS DOS CONTADORES Y, AL LLEGAR A CERO, BARRER LA PANTALLA. El `srl a / jr c / xor 01fh` hace que el indice vaya al reves en media vuelta: de ahi sale el vaiven del barrido.
; ----------------------------------------------------------------------
baja_los_contadores_y_barre:
	ld hl,0e003h		;42b3   ; el contador de cuadros
	dec (hl)			;42b6
	inc hl			;42b7   ; y el de al lado
	ld b,018h		;42b8   ; veinticuatro filas
	dec (hl)			;42ba   ; las dos cuentas bajan en el mismo sitio
	ret m			;42bb   ; si se paso de cero, se sale con el signo puesto
	ld a,(hl)			;42bc   ; el indice del barrido
	srl a		;42bd   ; el bit de abajo al acarreo
	jr c,L_42C3		;42bf
	xor 01fh		;42c1   ; y en media vuelta, al reves
L_42C3:
	ld e,a			;42c3   ; convertido en columna
	ld d,038h		;42c4   ; la fila 0x38 de la VRAM
L_42C6:
	xor a			;42c6   ; un cero por fila
	call escribe_en_vram		;42c7   ; un cero en cada fila
	ld a,020h		;42ca   ; la de abajo, 32 celdas mas alla
	call suma_a_a_de		;42cc
	djnz L_42C6		;42cf
saca_los_sprites_de_pantalla:
	ld de,03b00h		;42d1   ; los atributos de sprites
	ld a,0d0h		;42d4   ; 0xD0 en la fila: los saca de la pantalla
	call escribe_en_vram		;42d6
	xor a			;42d9   ; sale con A a cero y sin acarreo, que es lo que espera quien llama
	ret			;42da

; ----------------------------------------------------------------------
; SUMAR PUNTOS, en BCD y a seis digitos. DE trae lo que se suma; el tanteo es el de 0xE049 o el de 0xE046 segun el turno -bit 7 de (0xE002)-, y con el bit 6 puesto no se suma nada, que es como se congela el marcador en los cortes.
; ----------------------------------------------------------------------
suma_puntos:
	ld a,(0e002h)		;42db   ; el turno y las banderas
	add a,a			;42de   ; el bit 7 al acarreo, el 6 al signo
	ret p			;42df   ; con el bit 6 puesto no se suman puntos
	ld hl,0e049h		;42e0   ; el tanteo de un jugador
	jr nc,L_42E7		;42e3   ; el acarreo -el bit 7- elige cual de los dos tanteos
	ld l,046h		;42e5   ; o el del otro
L_42E7:
	ld a,(hl)			;42e7   ; el par de abajo del tanteo
	add a,e			;42e8   ; los dos digitos de abajo
	daa			;42e9   ; en BCD
	ld (hl),a			;42ea   ; guardado
	ld e,a			;42eb   ; en E
	inc l			;42ec   ; el byte siguiente
	ld a,(hl)			;42ed   ; el par del medio
	adc a,d			;42ee   ; los del medio, con acarreo
	daa			;42ef   ; el ajuste a BCD, otra vez
	ld (hl),a			;42f0   ; guardado
	ld d,a			;42f1   ; en D
	inc hl			;42f2   ; el siguiente
	jr nc,mira_si_es_record		;42f3   ; sin acarreo, no hay que tocar el tercero
	ld a,(hl)			;42f5   ; el par de arriba
	add a,001h		;42f6   ; y el tercer par
	daa			;42f8
	ld (hl),a			;42f9   ; guardado
	jr nc,mira_la_vida_extra		;42fa   ; y si no desborda, se sigue
	ld bc,09999h		;42fc   ; si desborda los seis digitos, el record se clava en 999999
	ld (0e043h),bc		;42ff   ; los dos pares de arriba
	ld (0e044h),bc		;4303   ; las dos escrituras van SOLAPADAS: entre ellas dejan 99 99 99 en 0xE043..0xE045
	jr L_4367		;4307

; ----------------------------------------------------------------------
; LA VIDA EXTRA. El umbral vive en (0xE052) y se compara con las centenas de millar del tanteo. Cada vez que se cruza, el umbral sube DOS -no uno- y, cuando desbordaria, se clava en 0xFF: a partir de ahi ya no hay mas vidas de regalo. Igual que en Circus Charlie.
; ----------------------------------------------------------------------
mira_la_vida_extra:
	ld a,(0e052h)		;4309   ; el umbral
	cp (hl)			;430c   ; contra los digitos altos del tanteo
	jr nc,mira_si_es_record		;430d   ; por debajo del umbral no hay vida que regalar
	push de			;430f   ; el tanteo se guarda, que la vida extra usa los mismos pares
	push hl			;4310
	add a,002h		;4311   ; el siguiente umbral, dos mas
	daa			;4313
	jr nc,L_4318		;4314
	ld a,0ffh		;4316   ; si se paso, 0xFF: no habra mas
L_4318:
	ld (0e052h),a		;4318
	ld hl,0e050h		;431b
	inc (hl)			;431e   ; una vida mas
	call pinta_las_vidas		;431f   ; repinta el contador
	ld a,008h		;4322   ; y suena el aviso
	call pide_un_sonido		;4324
	pop hl			;4327
	pop de			;4328

; ----------------------------------------------------------------------
; EL RECORD: primero el par alto y, solo si empata, los cuatro digitos de abajo con `sbc hl,de`.
; ----------------------------------------------------------------------
mira_si_es_record:
	ld a,(0e045h)		;4329   ; el par alto del record
	ld b,(hl)			;432c   ; los digitos altos del tanteo
	sub b			;432d   ; contra el del tanteo
	jr c,L_4339		;432e
	jr nz,L_4370		;4330   ; si el record es mayor, nada que hacer
	ld hl,(0e043h)		;4332   ; empatan arriba: se miran los de abajo
	sbc hl,de		;4335   ; el acarreo llega limpio del `sub` de arriba, asi que la resta es exacta
	jr nc,L_4370		;4337
L_4339:
	ld (0e043h),de		;4339   ; el tanteo nuevo manda
	ld a,b			;433d   ; y el par alto, que ya estaba en B
	ld (0e045h),a		;433e
	jr L_4367		;4341

; ----------------------------------------------------------------------
; EL MARCADOR ENTERO: los rotulos fijos -"HI", "STAGE" y "1P", mas "2P" si hay dos jugadores-, la altura, las vidas y los numeros. Con dos jugadores le da la vuelta al bit 7 antes de pintar el segundo tanteo, de modo que la misma rutina sirve para los dos.
; ----------------------------------------------------------------------
pinta_el_marcador:
	ld hl,04710h		;4343   ; los rotulos del marcador
	call pinta_rotulo		;4346
	ld a,(0e002h)		;4349   ; las banderas
	bit 5,a		;434c   ; el bit 5: hay dos jugadores?
	jr z,L_435E		;434e
	ld hl,04725h		;4350   ; entonces tambien el "2P"
	call pinta_rotulo		;4353
	ld a,(0e002h)		;4356
	xor 080h		;4359   ; se finge el otro turno
	call pinta_el_tanteo		;435b   ; y se pinta su tanteo con la misma rutina
L_435E:
	call pinta_las_vidas		;435e   ; el contador de vidas
	call pinta_la_altura		;4361   ; la altura
	call pinta_el_numero_de_fase		;4364   ; y el numero de fase
L_4367:
	ld hl,0e045h		;4367   ; el record
	ld de,0380fh		;436a   ; en la fila de arriba, columna 15
	call imprime_tres_bytes_bcd		;436d
L_4370:
	ld a,(0e002h)		;4370   ; el turno, para elegir cual de los dos tanteos
pinta_el_tanteo:
	ld de,03805h		;4373   ; la celda del primer tanteo
	ld hl,0e04bh		;4376   ; y su variable
	add a,a			;4379   ; el bit 7 al acarreo
	jr nc,imprime_tres_bytes_bcd		;437a
	ld e,025h		;437c   ; la columna del segundo
	ld hl,0e048h		;437e   ; y la variable del segundo
imprime_tres_bytes_bcd:
	ld b,003h		;4381   ; tres bytes de BCD
	jr imprime_bcd		;4383

; ----------------------------------------------------------------------
; EL NUMERO DE FASE DEL MARCADOR, el "STAGE". Imprime (0xE051) -un byte, dos digitos BCD-, que es el mismo contador que leen las seis rutinas del juego para saber por que fase va. No tiene nada que ver con las vidas: esas las pinta 0x43C4, con marcas y no con numeros.
; ----------------------------------------------------------------------
pinta_el_numero_de_fase:
	ld de,0381ch		;4385   ; la celda del contador
	ld hl,0e051h		;4388   ; (0xE051), el numero de fase en BCD
	ld b,001h		;438b   ; un solo byte

; ----------------------------------------------------------------------
; EL IMPRESOR DE BCD, de donde salen todos los numeros. Parte cada byte en sus dos digitos y les suma 0x30 -que aqui es donde empieza el "0", porque la fuente va ordenada como el ASCII-; el digito alto va primero y el puntero de la variable retrocede mientras el de la VRAM avanza, porque el BCD esta guardado del reves.
; ----------------------------------------------------------------------
imprime_bcd:
	ld a,(hl)			;438d   ; el byte
	push af			;438e   ; el byte entero se guarda: hacen falta sus dos mitades
	and 00fh		;438f   ; el digito de abajo
	or 030h		;4391   ; +0x30: el "0" de la fuente
	ld c,a			;4393   ; el digito de abajo, apartado en C hasta que le toque
	pop af			;4394   ; y se recupera el byte entero
	and 0f0h		;4395   ; y el de arriba
	rra			;4397   ; cuatro veces a la derecha
	rra			;4398
	rra			;4399
	rra			;439a
	or 030h		;439b   ; el mismo desplazamiento para el de arriba
	call escribe_en_vram		;439d   ; primero el alto
	inc de			;43a0
	ld a,c			;43a1   ; y ahora el que estaba esperando en C
	call escribe_en_vram		;43a2   ; y detras el bajo
	dec hl			;43a5   ; la variable va hacia atras
	inc de			;43a6   ; y la pantalla hacia delante
	djnz imprime_bcd		;43a7
	ret			;43a9

; ----------------------------------------------------------------------
; EL PARPADEO DEL "1P" / "2P", y todo el sale del contador de cuadros. El `ld hl,(0e002h)` trae de un tiron las banderas en L y el contador en H. Solo se hace algo cuando los cinco bits de abajo del contador estan a cero -un cuadro de cada 32-, y la mascara con la que se pinta es el BIT 5 DE ESE MISMO CONTADOR: a cero deja C=0x00, que en el interprete de rotulos es BORRAR, y a uno lo baja a 0xFF, que es pintar. De ahi salen los 32 cuadros encendido y 32 apagado. El turno solo elige CUAL de los dos rotulos. Igual que en Circus Charlie, byte a byte.
; ----------------------------------------------------------------------
parpadea_el_turno:
	ld hl,(0e002h)		;43aa   ; de un tiron: (0xE002) y el contador de cuadros
	ld a,01fh		;43ad   ; los cinco bits de abajo
	and h			;43af   ; H trae el contador de cuadros
	ret nz			;43b0   ; uno de cada 32 cuadros
	ld c,a			;43b1   ; y aqui A vale cero: la mascara 0x00, la de BORRAR
	bit 5,h		;43b2   ; el bit 5 del CONTADOR, no de las banderas: es lo que alterna cada 32 cuadros
	jr z,L_43B7		;43b4
	dec c			;43b6   ; C pasa de 0x00 a 0xFF, o sea de borrar a pintar
L_43B7:
	bit 7,l		;43b7   ; el bit 7 dice de quien es el turno
	ld hl,0471fh		;43b9
	jr z,L_43C1		;43bc   ; el turno solo elige cual de los dos rotulos
	ld hl,04725h		;43be
L_43C1:
	jp L_4064		;43c1

; ----------------------------------------------------------------------
; EL CONTADOR DE VIDAS, cinco marcas de derecha a izquierda: mientras queden se escribe la marca 0x2E y, en cuanto se acaban, un cero. Por eso el hueco se ve siempre.
; ----------------------------------------------------------------------
pinta_las_vidas:
	ld de,0383dh		;43c4   ; la celda mas a la derecha
	ld a,(0e050h)		;43c7   ; las vidas que quedan
	ld c,a			;43ca   ; las vidas, al contador del bucle
	ld b,005h		;43cb   ; cinco marcas como maximo
	ld a,02eh		;43cd   ; la marca
L_43CF:
	dec c			;43cf   ; una menos
	jp p,L_43D5		;43d0   ; mientras la resta no se pase de cero, marca
	ld a,000h		;43d3   ; agotadas: celda vacia
L_43D5:
	call escribe_en_vram		;43d5
	dec de			;43d8   ; y hacia la izquierda
	djnz L_43CF		;43d9
	ret			;43db
barre_la_pantalla_entera:
	ld a,000h		;43dc
	ld (0e00ah),a		;43de   ; la cortina se baja desde la fila 0
L_43E1:
	call barre_una_franja		;43e1
	jr c,L_43E1		;43e4   ; mientras devuelva acarreo, queda franja
	ret			;43e6

; ----------------------------------------------------------------------
; EL BARRIDO DE LA PANTALLA, dos filas por llamada. (0xE00A) dice por donde va; devuelve acarreo mientras quede trabajo, y al pasar de 15 saca la pantalla de seleccion. Ademas, cuando la franja cae en un sitio concreto (0xCC) pinta un patron aparte: es el remate del borde.
; ----------------------------------------------------------------------
barre_una_franja:
	ld hl,0e00ah		;43e7   ; por donde iba
	ld a,(hl)			;43ea   ; por donde iba
	inc (hl)			;43eb   ; y se deja avanzada
	cp 00fh		;43ec   ; quince pasadas
	jr nc,L_4417		;43ee   ; de la quince en adelante, el barrido se acabo
	ld de,03889h		;43f0   ; la esquina de arriba
	ld c,a			;43f3   ; el paso, apartado: hace falta dos veces
	add a,e			;43f4   ; mas el paso, que es la columna
	ld e,a			;43f5
	ld a,c			;43f6
	add a,a			;43f7   ; el paso por dos
	add a,0c0h		;43f8   ; +0xC0: de ahi sale el patron de la cortina
	ld c,a			;43fa   ; el patron con el que se pinta esta franja
	ld b,002h		;43fb   ; dos filas de golpe
L_43FD:
	ld a,c			;43fd
	call escribe_en_vram		;43fe
	ld a,020h		;4401   ; la de abajo
	call suma_a_a_de		;4403
	inc c			;4406   ; y el patron siguiente para la fila de abajo
	djnz L_43FD		;4407
	ld a,e			;4409   ; la columna a la que se ha llegado
	sub 0cch		;440a   ; el remate del borde
	cp 002h		;440c   ; solo en dos de las quince pasadas
	jr nc,L_4415		;440e
	add a,0deh		;4410   ; y entonces, un patron aparte: el remate del borde
	call escribe_en_vram		;4412
L_4415:
	scf			;4415   ; acarreo: todavia queda
	ret			;4416   ; el que llama sigue llamando mientras haya acarreo
L_4417:
	push af			;4417   ; la cuenta se guarda para el `cp` de abajo
	ld hl,0472bh		;4418   ; "PLAY SELECT" con sus cuatro opciones
	call z,pinta_rotulo		;441b   ; el menu se pinta justo en la pasada 15, cuando el barrido acaba
	pop af			;441e
	cp 034h		;441f   ; y se avisa si se llego al paso 52
	ret			;4421
limpia_la_pantalla:
	call saca_los_sprites_de_pantalla		;4422
	ld de,07800h		;4425   ; la tabla de nombres
	ld bc,00300h		;4428   ; sus 768 celdas
	xor a			;442b   ; a cero: la tabla de nombres entera en blanco

; ----------------------------------------------------------------------
; RELLENAR LA VRAM con el mismo byte, BC veces. Los dos `ex af,af'` seguidos de 0x442F no son un despiste: valen como espera y dejan el byte en el juego correcto para el bucle.
; ----------------------------------------------------------------------
rellena_vram:
	call prepara_escritura_vram		;442c   ; prepara el puntero de escritura
L_442F:
	ex af,af'			;442f
L_4430:
	ex af,af'			;4430   ; aqui entra tambien la de repetir del descompresor
	exx			;4431
	out (c),a		;4432   ; el byte, tal cual
	exx			;4434
	ex af,af'			;4435
	dec bc			;4436   ; una celda menos
	ld a,b			;4437   ; BC a cero se mira en dos pasos, que el `dec bc` no toca banderas
	or c			;4438
	jr nz,L_4430		;4439   ; hasta que BC llega a cero
	ei			;443b   ; el relleno entro con `di`; aqui se abre
	ret			;443c
repite_byte:
	ld a,(hl)			;443d   ; el byte que se repite
	inc hl			;443e   ; y el puntero queda detras del byte repetido
	jr L_442F		;443f

; ----------------------------------------------------------------------
; VOLCAR BC BYTES DE MEMORIA A LA VRAM, tal cual. Es lo que usan los bloques que NO van comprimidos.
; ----------------------------------------------------------------------
vuelca_bloque:
	di			;4441
	call prepara_escritura_vram		;4442
vuelca_bc_bytes:
	ld a,(hl)			;4445   ; un byte
	exx			;4446
	out (c),a		;4447   ; y al puerto de datos
	exx			;4449
	inc hl			;444a
	dec bc			;444b   ; una menos
	ld a,b			;444c   ; igual aqui: el `dec bc` no levanta el cero
	or c			;444d
	jr nz,vuelca_bc_bytes		;444e
	ei			;4450
	ret			;4451

; ----------------------------------------------------------------------
; COPIAR DE VRAM A VRAM byte a byte, pasando por el Z80: el VDP no sabe hacerlo solo.
; ----------------------------------------------------------------------
copia_vram_a_vram:
	call lee_de_vram		;4452   ; lee de (HL) en la VRAM
	ex de,hl			;4455   ; los dos punteros se turnan: HL lee y DE escribe
	call escribe_en_vram		;4456   ; y escribe en (DE), tambien en la VRAM
	ex de,hl			;4459
	inc hl			;445a
	inc de			;445b
	dec bc			;445c
	ld a,c			;445d   ; y otra vez la cuenta en dos pasos
	or b			;445e
	jr nz,copia_vram_a_vram		;445f
	ret			;4461

; ----------------------------------------------------------------------
; EL REPARTO DE LA VRAM, QUE HAY QUE LEER EN LOS REGISTROS Y NO EN LAS DIRECCIONES. Los ocho valores de 0x44FF son `02 E2 0E 7F 07 76 03 E1`, y en SCREEN 2 el R3 y el R4 no son direcciones sino base y mascara: del R3=0x7F solo cuenta el bit 7, que esta a CERO, o sea que la tabla de COLOR va en 0x0000; del R4=0x07 solo cuenta el bit 2, que esta puesto, o sea que la de PATRONES va en 0x2000. Por eso estas dos rutinas son al reves de lo que parecen a simple vista: la de aqui duplica los PATRONES y la de 0x4476 el COLOR. Se comprueba solo con la fuente: 0x447E rellena 384 bytes de 0x0180 con 0xF0 -tinta 15 sobre fondo transparente, o sea un byte de color- y suelta los dibujos de la fuente 0x2000 mas alla, en 0x2180.
; ----------------------------------------------------------------------
duplica_los_tercios_de_patrones:
	ld de,02000h		;4462   ; el primer tercio de la tabla de PATRONES: R4=0x07 la pone en 0x2000
	ld hl,02800h		;4465   ; al segundo
L_4468:
	ld bc,00800h		;4468   ; dos kilobytes
	call copia_vram_a_vram		;446b
	ld bc,00800h		;446e   ; y los otros dos
	jr copia_vram_a_vram		;4471
duplica_las_dos_tablas:
	call duplica_los_tercios_de_patrones		;4473   ; primero los patrones
duplica_los_tercios_de_color:
	ld de,00000h		;4476   ; y luego el color, que R3=0x7F deja en 0x0000
	ld hl,00800h		;4479   ; y el color, en el primer tercio de su tabla
	jr L_4468		;447c
rellena_y_vuelca:
	ld a,0f0h		;447e   ; el COLOR de relleno: tinta 15 sobre fondo transparente
	ld de,00180h		;4480   ; 384 celdas: las 48 de la fuente por ocho filas
	call rellena_una_franja		;4483   ; la franja de color, rellena
	jr duplica_las_dos_tablas		;4486   ; y de ahi, a repartirla por los tres tercios
rellena_una_franja:
	ld bc,00180h		;4488   ; 384 celdas
	call rellena_vram		;448b   ; 384 celdas del mismo byte
	ld hl,045b8h		;448e   ; la fuente
	ld a,020h		;4491   ; 0x2000 mas alla: de la tabla de color a la de patrones. 0x0180 es la celda 48, o sea que el primer dibujo cae en el patron 0x30
	add a,d			;4493   ; se le suma 0x20 al byte ALTO, que son los 0x2000 de la separacion
	ld d,a			;4494
	ld bc,00180h		;4495   ; y los mismos 384 bytes
	jp vuelca_bloque		;4498

; ----------------------------------------------------------------------
; EL DESCOMPRESOR, con tres puertas: por 0x449B el bloque trae delante su destino de VRAM, por 0x449F el destino ya viene en DE y por 0x44A3 esta puesto ademas el puntero. Es EL MISMO CODIGO que el 0x45C9 de Circus Charlie -la firma de catorce bytes de este bucle esta igual en los dos cartuchos-, y el lenguaje es al reves de lo que parece: bit 7 a CERO repite un byte, bit 7 PUESTO copia n bytes tal cual.
; ----------------------------------------------------------------------
descomprime:
	ld e,(hl)			;449b   ; el destino de VRAM, que va delante del bloque
	inc hl			;449c   ; y la palabra entera del destino
	ld d,(hl)			;449d
	inc hl			;449e
descomprime_en_de:
	di			;449f   ; aqui entran los que ya lo traen en DE
	call prepara_escritura_vram		;44a0
L_44A3:
	ld a,(hl)			;44a3   ; el byte de control
	and 07fh		;44a4   ; los siete bits de abajo son la cuenta
	ld c,a			;44a6   ; la cuenta, apartada en C
	ld a,(hl)			;44a7   ; y el byte entero se guarda para mirarle el bit 7
	inc hl			;44a8   ; el puntero, detras del byte de control
	jr nz,L_44B0		;44a9   ; cuenta distinta de cero: hay tramo
	cp c			;44ab   ; cuenta cero y byte 0x00: se acabo el bloque
	jr nz,descomprime		;44ac   ; cuenta cero y byte 0x80: detras viene otro destino
	ei			;44ae
	ret			;44af
L_44B0:
	ld b,000h		;44b0   ; la parte alta de la cuenta, siempre cero
	cp c			;44b2   ; compara el byte con su cuenta: solo difieren si el bit 7 esta puesto
	push af			;44b3   ; el resultado del `cp` hace falta dos veces, una por rama
	call nz,vuelca_bc_bytes		;44b4   ; bit 7 puesto -> copiar n bytes tal cual
	pop af			;44b7
	call z,repite_byte		;44b8   ; bit 7 a cero -> repetir el siguiente byte n veces
	di			;44bb   ; las dos ramas salen con las interrupciones abiertas; el bucle las quiere cerradas
	jr L_44A3		;44bc

; ----------------------------------------------------------------------
; PREPARAR EL PUERTO DE LA VRAM con SETWRT de la BIOS, y guardarse el puerto de datos en C' para que los bucles solo tengan que hacer `out (c),a`. SETWRT se queda con los catorce bits de abajo, que es por lo que los bloques llevan destinos como 0x5800 -que es 0x1800.
; ----------------------------------------------------------------------
prepara_escritura_vram:
	ex af,af'			;44be   ; A se aparta, que SETWRT lo usa
	ex de,hl			;44bf   ; SETWRT quiere la direccion en HL
	call 00053h		;44c0   ; BIOS SETWRT - Enables VDP to write | SETWRT: el puntero de escritura
	di			;44c3   ; SETWRT vuelve con las interrupciones abiertas, y aqui no interesan
	ex de,hl			;44c4   ; y HL y DE, como estaban
	exx			;44c5
	ld a,(00006h)		;44c6   ; el puerto de datos, de la tabla de la BIOS
	ld c,a			;44c9   ; a C', donde lo esperan los bucles
	exx			;44ca
	ex af,af'			;44cb
	ret			;44cc
prepara_lectura_vram:
	ex de,hl			;44cd
	call 00050h		;44ce   ; BIOS SETRD - Enables VDP to read | SETRD: el puntero de lectura
	di			;44d1
	ex de,hl			;44d2
	exx			;44d3
	ld a,(00007h)		;44d4   ; el puerto de LECTURA, que es otro que el de escritura
	ld c,a			;44d7
	exx			;44d8
	ret			;44d9

; ----------------------------------------------------------------------
; EL ARRANQUE DEL HARDWARE: apaga el sonido, borra los dieciseis kilobytes de VRAM y vuelca los ocho registros del VDP desde 0x44FF.
; ----------------------------------------------------------------------
arranca_el_hardware:
	ld a,0b8h		;44da   ; 0xB8 en el mezclador: los tres tonos abiertos, los tres ruidos cerrados y el puerto A como entrada, que es por donde se leen los mandos
	call escribe_el_mezclador_del_psg		;44dc
	ld a,09fh		;44df   ; el sonido de arranque
	call pide_un_sonido		;44e1
	ld de,00000h		;44e4   ; la VRAM entera
	ld bc,04000h		;44e7   ; los dieciseis kilobytes
	xor a			;44ea   ; a cero, byte a byte
	call rellena_vram		;44eb
vuelca_los_registros_del_vdp:
	ld hl,044ffh		;44ee   ; los ocho registros del VDP
	ld d,008h		;44f1   ; ocho escrituras
	ld c,000h		;44f3   ; se empieza por el registro 0
L_44F5:
	ld b,(hl)			;44f5   ; el valor
	call 00047h		;44f6   ; BIOS WRTVDP - Writes data in the VDP-register | WRTVDP: C lleva el numero de registro
	inc hl			;44f9
	inc c			;44fa   ; el siguiente: van los ocho seguidos, de R0 a R7
	dec d			;44fb
	jr nz,L_44F5		;44fc
	ret			;44fe

; ----------------------------------------------------------------------
; DATOS registros_del_vdp: los ocho valores que 0x44EE baja al VDP con `ld
;   hl,044ffh / ld d,008h / WRTVDP` subiendo C de 0 a 7: 0x02 0xE2 0x0E 0x7F
;   0x07 0x76 0x03 0xE1
;   0x44ff..0x4507  (8 bytes)
DATA_registros_del_vdp:
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e1h	; 44ff  .....v..

; ======================================================================
; CODIGO 0x4507..0x45b4  (173 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LEER EL MANDO. El bit 6 del registro 15 del PSG elige el puerto, y lo decide el bit 7 de (0xE002): cada jugador tiene el suyo. Los bits se invierten con `cpl` porque en el MSX un boton pulsado se lee como cero.
; ----------------------------------------------------------------------
lee_el_mando:
	ld e,08fh		;4507   ; la seleccion de puerto
	ld hl,0e002h		;4509
	bit 7,(hl)		;450c   ; el turno
	jr z,lee_un_puerto_del_psg		;450e   ; con el bit 7 a cero, el primer puerto
	set 6,e		;4510   ; el segundo jugador usa el otro puerto
lee_un_puerto_del_psg:
	ld a,00fh		;4512   ; registro 15 del PSG: el que elige el puerto
	call 00093h		;4514   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00eh		;4517   ; y el 14, que es donde se lee
	di			;4519   ; la lectura del PSG no puede partirse por una interrupcion
	call 00096h		;451a   ; BIOS RDPSG - Reads value from PSG-register
	ei			;451d   ; y aqui se vuelve a abrir
	cpl			;451e   ; pulsado es cero, asi que se invierte
	and 03fh		;451f   ; seis bits: cuatro direcciones y dos botones
	ret			;4521

; ----------------------------------------------------------------------
; LA LECTURA DE CADA CUADRO. Guarda lo de ahora en (0xE009) y lo de antes en (0xE008), que es lo que permite distinguir "esta pulsado" de "se acaba de pulsar". Con el bit 4 de (0xE002) se lee el TECLADO en vez del mando.
; ----------------------------------------------------------------------
lee_los_mandos:
	call lee_el_mando		;4522   ; el mando
	bit 4,(hl)		;4525   ; el bit 4: se juega con teclado
	call nz,lee_el_teclado		;4527
	ld hl,0e009h		;452a   ; la lectura de este cuadro
	ld c,(hl)			;452d   ; la de antes se guarda al lado
	ld (hl),a			;452e   ; la de ahora ocupa su sitio
	dec hl			;452f
	ld (hl),c			;4530   ; y la vieja queda en (0xE008), que es contra lo que se miran los flancos
	ret			;4531

; ----------------------------------------------------------------------
; LEER EL TECLADO por filas del PPI, armando los mismos seis bits que devuelve el mando: asi todo lo de arriba funciona igual con palanca o con teclas.
; ----------------------------------------------------------------------
lee_el_teclado:
	ld a,007h		;4532   ; una fila del teclado
	call 00141h		;4534   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4537   ; pulsado es cero, se invierte
	rrca			;4538   ; una rotacion
	and 020h		;4539   ; y se queda con su bit
	ld e,a			;453b   ; guardado en E
	ld a,008h		;453c   ; y otra fila
	call 00141h		;453e   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4541   ; pulsado es cero aqui tambien
	rrca			;4542   ; dos rotaciones
	rrca			;4543
	ld b,a			;4544   ; el resto, en B
	and 004h		;4545   ; las dos teclas de esta fila
	or e			;4547   ; juntadas con las de antes
	ld c,a			;4548   ; en C
	ld a,b			;4549   ; lo que quedaba
	rrca			;454a   ; dos rotaciones mas
	rrca			;454b
	ld b,a			;454c   ; otra vez en B
	and 018h		;454d   ; y las dos que quedan
	or c			;454f   ; juntadas
	ld c,a			;4550   ; en C
	ld a,b			;4551   ; y lo ultimo
	rrca			;4552   ; una rotacion
	and 003h		;4553   ; las dos que faltan
	or c			;4555   ; juntadas: las seis teclas caben en un byte
	ret			;4556

; ----------------------------------------------------------------------
; EL MENU DE SELECCION, que es el remate que 0x40A7 apila cuando el bit 6 de (0xE002) esta a cero. Junta las TRES entradas -los dos puertos de mando y el teclado- con un `or`, de modo que en el menu vale cualquiera, y se queda con el FLANCO (`xor c / and b`): cuenta el momento de pulsar, no que siga pulsado.
; ----------------------------------------------------------------------
atiende_el_menu:
	ld e,08fh		;4557   ; el primer puerto de mando
	call lee_un_puerto_del_psg		;4559
	ld d,a			;455c   ; guardado
	ld e,0cfh		;455d   ; y el segundo
	call lee_un_puerto_del_psg		;455f
	or d			;4562   ; se juntan
	ld d,a			;4563   ; los dos juntos
	call lee_el_teclado		;4564   ; mas el teclado
	or d			;4567   ; y el teclado encima: se juega con cualquiera de los tres
	ld hl,0e040h		;4568   ; lo de ahora en (0xE040)
	ld c,(hl)			;456b   ; lo de antes
	ld (hl),a			;456c   ; y lo de antes justo detras
	inc hl			;456d   ; el byte siguiente
	ld (hl),c			;456e   ; y la anterior, en (0xE041)
	ld b,a			;456f   ; en B
	xor c			;4570   ; los bits que han cambiado
	and b			;4571   ; y de esos, los que ahora estan pulsados: el flanco
	ret z			;4572   ; nada nuevo, nada que hacer
	ld b,a			;4573   ; los nuevos, en B
	ld a,000h		;4574   ; a cero
	ld (0e004h),a		;4576   ; se reinicia el plazo de la pantalla
	ld a,005h		;4579   ; solo la escena 5 responde al menu
	ld hl,0e000h		;457b   ; la escena de ahora
	cp (hl)			;457e   ; comparadas
	jr nz,L_459A		;457f   ; en las demas, solo se apunta la lectura
	ld a,b			;4581   ; los bits recien pulsados
	cp 010h		;4582   ; de 0x10 para arriba son botones; por debajo, direcciones
	jr c,mueve_el_cursor		;4584
	ld hl,045b4h		;4586   ; los cuatro modos de juego
	ld a,(0e042h)		;4589   ; indexados por la opcion elegida
	call suma_a_a_hl		;458c   ; indexa la tabla de modos
	ld a,(hl)			;458f   ; el modo que le toca a esa opcion
	ld (0e002h),a		;4590   ; y el modo queda en (0xE002)
	ld hl,00008h		;4593   ; a la escena 8, la que arranca sin remate apilado
	ld (0e000h),hl		;4596   ; las DOS a la vez: escena 8 en (0xE000) y cero en (0xE001), que es la bandera de la escena de fin
	ret			;4599
L_459A:
	ld (hl),a			;459a   ; en las demas escenas solo se apunta la lectura
	jp L_421E		;459b

; ----------------------------------------------------------------------
; MOVER EL CURSOR DEL MENU: arriba resta y abajo suma, y el `and 003h` del final hace que las cuatro opciones den la vuelta sin un solo `cp`.
; ----------------------------------------------------------------------
mueve_el_cursor:
	push bc			;459e
	call pinta_el_cursor		;459f   ; borra el cursor de donde estaba
	pop af			;45a2   ; los bits recien pulsados vuelven en A
	ld hl,0e042h		;45a3   ; la opcion elegida
	ld b,(hl)			;45a6   ; la opcion de ahora
	rra			;45a7   ; el bit 0: arriba
	jr nc,L_45AB		;45a8
	dec b			;45aa   ; una menos
L_45AB:
	rra			;45ab   ; el bit 1: abajo
	jr nc,L_45AF		;45ac
	inc b			;45ae   ; una mas
L_45AF:
	ld a,b			;45af   ; la opcion nueva
	and 003h		;45b0   ; cuatro opciones, y da la vuelta sola
	ld (hl),a			;45b2
	ret			;45b3

; ----------------------------------------------------------------------
; DATOS modos_de_juego: cuatro bytes, uno por opcion del menu; 0x4586 los
;   indexa con la opcion de (0xE042) y deja el elegido en (0xE002). Son 0x40
;   0x60 0x50 0x70: el bit 6 va siempre puesto y los que distinguen las cuatro
;   opciones son el 5 y el 4
;   0x45b4..0x45b8  (4 bytes)

; ----------------------------------------------------------------------
; LOS CUATRO MODOS DE JUEGO que el menu deja en (0xE002). El bit 6 va puesto siempre -es lo que le dice a 0x40A7 que ya no estamos en el menu-, el bit 5 significa DOS JUGADORES y el bit 4, TECLADO en vez de mando.
; ----------------------------------------------------------------------
DATA_modos_de_juego:
	defb 040h,060h,050h,070h	; 45b4

; ----------------------------------------------------------------------
; DATOS fuente: 43 dibujos de 8x8 que 0x448E vuelca a la tabla de patrones, y
;   el reparto no hay que suponerlo: 0x447E los suelta en 0x2180, que es la
;   celda 48, o sea el patron 0x30. De ahi sale todo lo demas y cuadra
;   DIBUJANDOLO: 0x30..0x39 los diez digitos, 0x3A la (c), 0x3B dos rayitas,
;   0x3C y 0x3D la palabra "with" partida en dos celdas, 0x3E y 0x3F el cursor
;   del menu -0x4282 los nombra con `ld bc,03e3fh`-, 0x40 una raya larga y
;   0x41..0x5A las veintiseis letras. O sea que cada letra cae en SU codigo
;   ASCII, y por eso los rotulos guardan el texto en claro: en 0x75B0 pone
;   "CASTLE" tal cual. La palabra "with" es la de los cuatro renglones del
;   menu, "1PLAYER with JOYSTICK" y sus tres hermanos, que 0x472B escribe con
;   esta misma fuente recolocada en el tile 0xC0 del tercer tercio por el
;   `rellena_una_franja` de 0x425D
;   0x45b8..0x4710  (344 bytes)
DATA_fuente:
	defb 000h,01ch,022h,063h,063h,063h,022h,01ch,000h,018h,038h,018h,018h,018h,018h,07eh	; 45b8  .."ccc"...8....~
	defb 000h,03eh,063h,003h,00eh,03ch,070h,07fh,000h,03eh,063h,003h,00eh,003h,063h,03eh	; 45c8  .>c..<p..>c...c>
	defb 000h,00eh,01eh,036h,066h,066h,07fh,006h,000h,07fh,060h,07eh,063h,003h,063h,03eh	; 45d8  ...6ff....`~c.c>
	defb 000h,03eh,063h,060h,07eh,063h,063h,03eh,000h,07fh,063h,006h,00ch,018h,018h,018h	; 45e8  .>c`~cc>..c.....
	defb 000h,03eh,063h,063h,03eh,063h,063h,03eh,000h,03eh,063h,063h,03fh,003h,063h,03eh	; 45f8  .>cc>cc>.>cc?.c>
	defb 03ch,042h,099h,0a1h,0a1h,099h,042h,03ch,000h,024h,024h,024h,000h,000h,000h,000h	; 4608  <B....B<.$$$....
	defb 000h,000h,002h,000h,08ah,0aah,0aah,0dah,000h,000h,008h,048h,0eeh,04ah,04ah,06ah	; 4618  ...........H.JJj
	defb 000h,00fh,01fh,0ffh,0ffh,0ffh,0ffh,00fh,000h,000h,0feh,0e0h,0e0h,0c0h,0c0h,080h	; 4628  ................
	defb 000h,000h,000h,000h,07eh,000h,000h,000h,000h,01ch,036h,063h,063h,07fh,063h,063h	; 4638  ....~.....6cc.cc
	defb 000h,07eh,063h,063h,07eh,063h,063h,07eh,000h,03eh,063h,060h,060h,060h,063h,03eh	; 4648  .~cc~cc~.>c```c>
	defb 000h,07ch,066h,063h,063h,063h,066h,07ch,000h,07fh,060h,060h,07eh,060h,060h,07fh	; 4658  .|fcccf|..``~``.
	defb 000h,07fh,060h,060h,07eh,060h,060h,060h,000h,03eh,063h,060h,067h,063h,063h,03fh	; 4668  ..``~```.>c`gcc?
	defb 000h,063h,063h,063h,07fh,063h,063h,063h,000h,03ch,018h,018h,018h,018h,018h,03ch	; 4678  .ccc.ccc.<.....<
	defb 000h,01fh,006h,006h,006h,006h,066h,03ch,000h,063h,066h,06ch,078h,07ch,06eh,067h	; 4688  ......f<.cflx|ng
	defb 000h,060h,060h,060h,060h,060h,060h,07fh,000h,063h,077h,07fh,07fh,06bh,063h,063h	; 4698  .``````..cw..kcc
	defb 000h,063h,073h,07bh,07fh,06fh,067h,063h,000h,03eh,063h,063h,063h,063h,063h,03eh	; 46a8  .cs{.ogc.>ccccc>
	defb 000h,07eh,063h,063h,063h,07eh,060h,060h,000h,03eh,063h,063h,063h,06fh,066h,03dh	; 46b8  .~ccc~``.>cccof=
	defb 000h,07eh,063h,063h,062h,07ch,066h,063h,000h,03eh,063h,060h,03eh,003h,063h,03eh	; 46c8  .~ccb|fc.>c`>.c>
	defb 000h,07eh,018h,018h,018h,018h,018h,018h,000h,063h,063h,063h,063h,063h,063h,03eh	; 46d8  .~.......cccccc>
	defb 000h,063h,063h,063h,063h,036h,01ch,008h,000h,063h,063h,06bh,06bh,07fh,077h,022h	; 46e8  .cccc6...cckk.w"
	defb 000h,063h,076h,03ch,01ch,01eh,037h,063h,000h,066h,066h,07eh,03ch,018h,018h,018h	; 46f8  .cv<..7c.ff~<...
	defb 000h,07fh,007h,00eh,01ch,038h,070h,07fh	; 4708  .....8p.

; ----------------------------------------------------------------------
; DATOS guion_0x4710: 21 bytes, 3 tramos, 12 bytes a la VRAM; lo pinta 0x4343
;   0x4710..0x4725  (21 bytes)
DATA_guion_0x4710:
	defb 00ch,038h,048h,049h,040h,0feh,016h,038h,053h,054h,041h,047h,045h,040h,0feh,002h	; 4710  .8HI@..8STAGE@..
	defb 038h,031h,050h,040h,0ffh	; 4720

; ----------------------------------------------------------------------
; DATOS guion_0x4725: 6 bytes, 1 tramos, 3 bytes a la VRAM; lo pinta 0x4350
;   0x4725..0x472b  (6 bytes)
DATA_guion_0x4725:
	defb 022h,038h,032h,050h,040h,0ffh	; 4725

; ----------------------------------------------------------------------
; DATOS guion_0x472B: 121 bytes, 6 tramos, 103 bytes a la VRAM; lo pinta
;   0x4418
;   0x472b..0x47a4  (121 bytes)
DATA_guion_0x472B:
	defb 0abh,039h,050h,04ch,041h,059h,000h,053h,045h,04ch,045h,043h,054h,0feh,007h,03ah	; 472b  .9PLAY.SELECT..:
	defb 0c1h,0e0h,0dch,0d1h,0e9h,0d5h,0e2h,000h,000h,0cch,0cdh,000h,0dah,0dfh,0e9h,0e3h	; 473b  ................
	defb 0e4h,0d9h,0d3h,0dbh,0feh,047h,03ah,0c2h,0e0h,0dch,0d1h,0e9h,0d5h,0e2h,0e3h,000h	; 474b  .....G:.........
	defb 0cch,0cdh,000h,0dah,0dfh,0e9h,0e3h,0e4h,0d9h,0d3h,0dbh,0feh,087h,03ah,0c1h,0e0h	; 475b  .............:..
	defb 0dch,0d1h,0e9h,0d5h,0e2h,000h,000h,0cch,0cdh,000h,0dbh,0d5h,0e9h,0d2h,0dfh,0d1h	; 476b  ................
	defb 0e2h,0d4h,0feh,0c7h,03ah,0c2h,0e0h,0dch,0d1h,0e9h,0d5h,0e2h,0e3h,000h,0cch,0cdh	; 477b  ....:...........
	defb 000h,0dbh,0d5h,0e9h,0d2h,0dfh,0d1h,0e2h,0d4h,0feh,00bh,039h,03ah,04bh,04fh,04eh	; 478b  ...........9:KON
	defb 041h,04dh,049h,000h,031h,039h,038h,034h,0ffh	; 479b  AMI.1984.

; ----------------------------------------------------------------------
; DATOS guion_0x47A4: 24 bytes, 2 tramos, 18 bytes a la VRAM (0x396B y
;   0x392C); lo pinta 0x41A5. El interprete de rotulos lo consume entero y se
;   para en el borde
;   0x47a4..0x47bc  (24 bytes)
DATA_guion_0x47A4:
	defb 06bh,039h,047h,041h,04dh,045h,000h,000h,04fh,056h,045h,052h,0feh,02ch,039h,050h	; 47a4  k9GAME..OVER.,9P
	defb 04ch,041h,059h,045h,052h,000h,031h,0ffh	; 47b4  LAYER.1.

; ----------------------------------------------------------------------
; DATOS guion_0x47BC: 22 bytes, 1 tramos, 19 bytes a la VRAM; lo pinta 0x40F9
;   0x47bc..0x47d2  (22 bytes)
DATA_guion_0x47BC:
	defb 066h,039h,040h,000h,056h,049h,044h,045h,04fh,000h,043h,041h,052h,054h,052h,049h	; 47bc  f9@.VIDEO.CARTRI
	defb 044h,047h,045h,000h,040h,0ffh	; 47cc

; ----------------------------------------------------------------------
; DATOS bloque_0x47D2: 194 bytes comprimidos -> 256 en VRAM (1 tramos:
;   0x2600); lo carga 0x4265
;   0x47d2..0x4894  (194 bytes)
DATA_bloque_0x47D2:
	defb 000h,026h,083h,078h,07ch,07eh,003h,07fh,082h,07bh,079h,008h,078h,089h,00fh,01fh	; 47d2  .&.x|~...{y.x...
	defb 03fh,07fh,0ffh,0ffh,0efh,0cfh,08fh,007h,00fh,005h,000h,08bh,03fh,03fh,007h,001h	; 47e2  ?...........??..
	defb 03fh,07fh,071h,071h,07fh,07fh,03dh,005h,000h,0a3h,081h,0c3h,0c7h,0c7h,0c7h,0c3h	; 47f2  ?.qq..=.........
	defb 0c1h,0c3h,0c1h,0c7h,0efh,000h,000h,000h,00eh,01eh,0feh,0f8h,0bch,01ch,0bch,0f8h	; 4802  ................
	defb 0f0h,080h,0f0h,0fch,01eh,040h,0e0h,0e0h,040h,000h,0e3h,0e7h,0e7h,004h,0eeh,084h	; 4812  .....@..@.......
	defb 0e7h,0e7h,0e3h,0e0h,004h,000h,08ch,0f0h,0f3h,0f3h,010h,000h,003h,007h,007h,017h	; 4822  ................
	defb 0f7h,0f7h,0f3h,005h,000h,08bh,0f8h,0fch,07ch,01ch,0fch,0fch,01ch,01ch,0fch,0fch	; 4832  ........|.......
	defb 0eeh,010h,0e0h,003h,01fh,00dh,001h,003h,0feh,00dh,0e0h,005h,000h,084h,0eeh,0feh	; 4842  ................
	defb 0feh,0f0h,007h,0e0h,005h,000h,083h,01eh,07fh,073h,088h,0e1h,0ffh,0ffh,0e0h,0f0h	; 4852  .........s......
	defb 07fh,07fh,01fh,005h,000h,083h,003h,08fh,08eh,088h,0dch,0dfh,0dfh,01ch,05eh,0cfh	; 4862  ..............^.
	defb 0cfh,083h,005h,000h,083h,0c0h,0f0h,070h,088h,038h,0f8h,0f8h,000h,008h,0f8h,0f8h	; 4872  .......p.8......
	defb 0f0h,085h,00eh,00eh,00fh,007h,001h,003h,000h,085h,00eh,00eh,01eh,0fch,0f0h,003h	; 4882  ................
	defb 000h,000h	; 4892

; ----------------------------------------------------------------------
; DATOS bloque_0x4894: 11 bytes comprimidos -> 16 en VRAM (1 tramos: ?); lo
;   carga 0x4272
;   0x4894..0x489f  (11 bytes)
DATA_bloque_0x4894:
	defb 002h,0c1h,002h,021h,006h,031h,003h,0e1h,003h,0f1h,000h	; 4894  ...!.1.....

; ======================================================================
; CODIGO 0x489f..0x48f9  (90 bytes)
; ======================================================================


monta_el_logotipo_de_konami:
	ld a,011h		;489f   ; diecisiete pasos
	ld (0e00ah),a		;48a1
	ld hl,00000h		;48a4   ; el logotipo empieza por arriba del todo
	ld (0e00eh),hl		;48a7
	ld hl,048f9h		;48aa   ; los veintiseis dibujos del logotipo
	ld de,02300h		;48ad
	call descomprime_en_de		;48b0
	ld de,00300h		;48b3   ; la tabla de color, desde la celda 0x300
	ld bc,000d0h		;48b6   ; 208 celdas
	ld a,0f0h		;48b9   ; y el color de la cortina
	jp rellena_vram		;48bb

; ----------------------------------------------------------------------
; UN PASO DEL LOGOTIPO. Avanza 32 celdas -una fila-, y la posicion donde escribe no es esa sino su REFLEJO respecto de 0x3AAA (`sbc hl,de`), asi que segun el contador sube, el logotipo baja por la pantalla. Cada paso pinta las veintiseis celdas del logotipo repartidas en tres filas seguidas: tres, once y doce, con los patrones CORRELATIVOS desde el 0x60 -de eso se encarga el `inc a` de 0x48EF-. Diecisiete pasos, que es lo que 0x489F deja en (0xE00A).
; ----------------------------------------------------------------------
baja_el_logotipo_un_paso:
	ld hl,(0e00eh)		;48be   ; por donde va
	ld de,00020h		;48c1   ; una fila, 32 celdas
	add hl,de			;48c4   ; una fila mas abajo en cada paso
	ld (0e00eh),hl		;48c5   ; y la cuenta queda guardada
	ex de,hl			;48c8
	or a			;48c9   ; limpia el acarreo para el `sbc` del reflejo
	ld hl,03aaah		;48ca   ; el punto de reflejo: la posicion de verdad sale de restarle la cuenta
	sbc hl,de		;48cd   ; y por eso el logotipo baja mientras la cuenta sube
	ex de,hl			;48cf   ; la posicion de verdad, al puntero de escritura
	ld a,060h		;48d0   ; el primer patron del logotipo
	ld b,003h		;48d2   ; tres celdas: la fila de arriba
	call pinta_franja_y_baja		;48d4   ; la fila de arriba, y sale apuntando a la de abajo
	ld bc,00b0ch		;48d7   ; once en la siguiente, y en C quedan las doce de la ultima
	call pinta_franja_y_baja		;48da
	ld b,c			;48dd   ; y la tercera, de doce: la cuenta venia guardada en C
	call pinta_franja_y_baja		;48de
	xor a			;48e1   ; lo que queda de la fila, en blanco
	call rellena_vram		;48e2
	ld hl,0e00ah		;48e5
	dec (hl)			;48e8   ; un paso menos de los diecisiete
	ret			;48e9
pinta_franja_y_baja:
	push de			;48ea   ; esta puerta se guarda el destino; la de abajo, no
pinta_franja_correlativa:
	call escribe_en_vram		;48eb   ; el patron
	inc de			;48ee   ; la celda de al lado
	inc a			;48ef   ; el siguiente, uno mas
	djnz pinta_franja_correlativa		;48f0
	pop de			;48f2
	ld hl,00020h		;48f3   ; y sale apuntando una fila mas abajo, que es lo que encadena las tres llamadas
	add hl,de			;48f6
	ex de,hl			;48f7
	ret			;48f8

; ----------------------------------------------------------------------
; DATOS logotipo_de_konami: 147 bytes comprimidos que 0x48AA suelta en 0x2300,
;   o sea en el patron 0x60, y que son 208 bytes: VEINTISEIS dibujos.
;   Dibujados desde la ROM y puestos como los pone 0x48D0 -tres celdas, once y
;   doce, cada tanda una fila mas abajo- se lee KONAMI con su (R), en la letra
;   de la casa. Es el logotipo que sale antes del titulo
;   0x48f9..0x498c  (147 bytes)
DATA_logotipo_de_konami:
	defb 00eh,000h,082h,007h,00fh,006h,000h,082h,0f8h,0f0h,004h,03eh,004h,03fh,090h,01fh	; 48f9  ...........>.?..
	defb 03fh,07fh,0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,000h,000h,000h,03eh,03eh,005h	; 4909  ?............>>.
	defb 000h,083h,01fh,07fh,0fbh,005h,000h,083h,00fh,0cfh,0efh,005h,000h,083h,078h,0fch	; 4919  ..............x.
	defb 0bch,005h,000h,083h,03fh,07fh,0f3h,005h,000h,083h,087h,0c7h,0c7h,005h,000h,083h	; 4929  ....?...........
	defb 0bch,0feh,0dfh,005h,000h,08dh,078h,0fch,0bch,060h,0f0h,0f0h,060h,000h,0f0h,0f0h	; 4939  ......x..`..`...
	defb 0f0h,03fh,03fh,006h,03eh,090h,0f8h,0fch,0feh,07fh,03fh,01fh,00fh,007h,03eh,03eh	; 4949  .??.>.....?...>>
	defb 03eh,07eh,0fch,0fch,0f8h,0e0h,005h,0f1h,083h,0fbh,07fh,01fh,006h,0efh,082h,0cfh	; 4959  >~..............
	defb 00fh,008h,01eh,088h,0e1h,003h,03fh,0f1h,0e1h,0f3h,07fh,01eh,008h,0e7h,008h,08fh	; 4969  ......?.........
	defb 008h,01eh,082h,0f1h,0f2h,004h,0f5h,08ah,0f2h,0f1h,0e0h,010h,0c8h,068h,0c8h,028h	; 4979  .............h.(
	defb 010h,0e0h,000h	; 4989

; ======================================================================
; CODIGO 0x498c..0x4a50  (196 bytes)
; ======================================================================


lee_la_celda_de_ahi:
	call posicion_a_celda		;498c   ; la celda en la que esta
	jp lee_de_vram		;498f   ; y se trae su indice de la VRAM

; ----------------------------------------------------------------------
; DE POSICION A CELDA DE PANTALLA. Divide las dos coordenadas entre ocho de una vez, encadenando los `rra` de una con los `rr e` de la otra, y le pega el 0x38 de la tabla de nombres. Tres bits de cada una, que es justo el tamano de un patron.
; ----------------------------------------------------------------------
posicion_a_celda:
	ld a,l			;4992   ; las dos coordenadas, cada una en su registro
	ld e,h			;4993
	rra			;4994   ; cuatro giros
	rra			;4995   ; las dos se dividen entre ocho A LA VEZ
	rra			;4996
	rra			;4997
	rr e		;4998   ; el acarreo que sale de una entra en la otra: asi la columna se arma sola
	rra			;499a
	rr e		;499b
	rra			;499d
	rr e		;499e
	and 003h		;49a0   ; lo que queda de la fila
	add a,038h		;49a2   ; mas la pagina de la tabla de nombres
	ld d,a			;49a4   ; y la fila, al byte alto
	ret			;49a5
vuelca_b_filas:
	push bc			;49a6
	ld b,000h		;49a7   ; la cuenta alta, siempre cero: una fila no llega a 256
	call vuelca_bloque		;49a9   ; una fila
	pop bc			;49ac
	ld a,020h		;49ad   ; la fila de abajo
	call suma_a_a_de		;49af
	djnz vuelca_b_filas		;49b2
	ret			;49b4
pinta_bloque_de_la_ficha:
	call elige_la_tabla_de_piezas		;49b5   ; la pieza y su tamano

; ----------------------------------------------------------------------
; PINTAR UN BLOQUE EN SU SITIO, fila a fila, SALTANDOSE las que caen fuera de la banda util (0x18..0xC0). Si C es menor de 7 la fila va tal cual; si no, se descomprime. Y cuando la fila esta fuera, 0x49ED avanza por los datos SIN pintar, interpretando el mismo lenguaje: un byte con el bit 7 puesto es un salto de n bytes. Asi se recorta por arriba y por abajo sin dibujar de mas.
; ----------------------------------------------------------------------
pinta_bloque_en_su_sitio:
	ld a,(hl)			;49b8   ; el puntero que hay ahi
	inc hl			;49b9
	ld h,(hl)			;49ba   ; leido al reves: primero el bajo y luego el alto sobre el mismo par
	ld l,a			;49bb
pinta_bloque_recortado:
	ld a,l			;49bc   ; la coordenada de la fila
	sub 018h		;49bd   ; la banda util empieza en 0x18
	cp 0a8h		;49bf   ; y mide 0xA8
	jr nc,salta_la_fila_que_no_se_ve		;49c1   ; fuera de la banda util no se dibuja: se salta
	push hl			;49c3   ; la posicion se guarda, que posicion_a_celda la gasta
	push de			;49c4
	call posicion_a_celda		;49c5   ; de posicion a celda
	pop hl			;49c8
	push bc			;49c9
	ld a,c			;49ca   ; el ancho de la fila
	cp 007h		;49cb   ; por debajo de siete va tal cual
	jr nc,L_49D6		;49cd
	ld b,000h		;49cf   ; la cuenta alta, cero
	call vuelca_bloque		;49d1
	jr L_49D9		;49d4
L_49D6:
	call descomprime_en_de		;49d6   ; y si no, se descomprime
L_49D9:
	ex de,hl			;49d9   ; el puntero por donde va el bloque
	pop bc			;49da
	pop hl			;49db
L_49DC:
	ld a,l			;49dc
	add a,008h		;49dd   ; ocho pixeles: la fila de abajo
	ld l,a			;49df
	djnz pinta_bloque_recortado		;49e0   ; hasta las B filas del bloque
	ret			;49e2
salta_la_fila_que_no_se_ve:
	ld a,c			;49e3   ; el mismo ancho que arriba
	cp 007h		;49e4   ; por debajo de siete, un ancho fijo
	jr nc,L_49ED		;49e6   ; con siete o mas hay que ir leyendo el lenguaje
	call suma_a_a_de		;49e8   ; que se salta
	jr L_49DC		;49eb   ; y a la fila siguiente, sin haber pintado nada
L_49ED:
	ld a,(de)			;49ed   ; el byte de control
	inc de			;49ee   ; detras del byte de control
	or a			;49ef   ; un cero cierra la fila
	jr z,L_49DC		;49f0   ; un cero cierra
	jp p,L_49FC		;49f2   ; bit 7 a cero: una sola celda
	and 07fh		;49f5   ; y con el bit 7, siete bits de salto
L_49F7:
	call suma_a_a_de		;49f7   ; se avanza sin escribir
	jr L_49ED		;49fa
L_49FC:
	ld a,001h		;49fc   ; con el bit 7 a cero, el salto es de una sola celda
	jr L_49F7		;49fe
borra_la_celda_de_ahi:
	ld a,l			;4a00   ; la banda util
	sub 018h		;4a01   ; la banda util empieza en 0x18
	cp 0a8h		;4a03   ; y mide 0xA8
	ret nc			;4a05
	call posicion_a_celda		;4a06   ; de posicion a celda
	ld a,003h		;4a09   ; y se borra con el indice 3
	jp rellena_vram		;4a0b

; ----------------------------------------------------------------------
; ELEGIR LA TABLA DE PIEZAS por los bits 7, 5 y 6 del tercer byte del objeto: cuatro tablas -0x5130, 0x5188, 0x5146 y 0x5170-, y el indice son los cinco bits de abajo.
; ----------------------------------------------------------------------
elige_la_tabla_de_piezas:
	push hl			;4a0e
	inc hl			;4a0f   ; el tercer byte del objeto
	inc hl			;4a10
	ld a,(hl)			;4a11   ; que es el que trae los tres bits
	bit 7,a		;4a12   ; el bit 7
	ld hl,05130h		;4a14   ; la primera tabla
	jr z,saca_la_pieza_y_su_tamano		;4a17
	ld hl,05188h		;4a19   ; la segunda
	bit 5,a		;4a1c   ; el bit 5
	jr nz,L_4A2A		;4a1e
	ld hl,05146h		;4a20   ; la tercera
	bit 6,a		;4a23   ; el bit 6
	jr z,L_4A2A		;4a25
	ld hl,05170h		;4a27   ; y la cuarta
L_4A2A:
	and 01fh		;4a2a   ; cinco bits de indice
saca_la_pieza_y_su_tamano:
	add a,a			;4a2c   ; por dos: son punteros
	call suma_a_a_hl		;4a2d   ; indexa la tabla elegida
	ld e,(hl)			;4a30   ; el puntero a la pieza
	inc hl			;4a31   ; y la palabra entera
	ld d,(hl)			;4a32
	pop hl			;4a33   ; el objeto, de vuelta
	ex de,hl			;4a34
	ld b,(hl)			;4a35   ; el primer byte de la pieza es cuantas filas tiene
	inc hl			;4a36
	ld c,(hl)			;4a37   ; y el segundo, lo ancha que es
	inc hl			;4a38   ; los datos empiezan detras de los dos
	ex de,hl			;4a39
	ret			;4a3a
hueco_de_sprite:
	ld a,c			;4a3b
	add a,a			;4a3c   ; por cuatro: cuatro bytes por sprite en la tabla de atributos
	add a,a			;4a3d
	jp suma_a_a_hl		;4a3e
hueco_de_sprite_en_de:
	ld a,c			;4a41
	add a,a			;4a42   ; los mismos cuatro, pero sobre DE
	add a,a			;4a43
	jp suma_a_a_de		;4a44
hueco_de_sprite_por_indice:
	ld a,c			;4a47
	add a,a			;4a48
	add a,c			;4a49   ; por tres: tres bytes por ficha en el bloque de 0xE132
	ld hl,0e132h		;4a4a
	jp suma_a_a_hl		;4a4d

; ----------------------------------------------------------------------
; DATOS trozos_del_decorado: los 25 trozos que la tabla de 0x4D30 apunta. Cada
;   trozo son N tiras de TRES celdas, y una tira no siempre ocupa lo mismo: si
;   el primer byte no es 0xFF, son dos bytes de los que 0x52FB saca tres
;   celdas (los tres bits de abajo, el byte siguiente entero, y los cinco de
;   arriba); si es 0xFF, son cuatro bytes y las tres celdas van en crudo.
;   Donde acaba cada trozo no se estima: se saca ejecutando ese mismo
;   interprete sobre las 25 entradas, y las 25 recorridas cubren
;   0x4A50..0x4D30 sin dejar un hueco ni pisarse
;   0x4a50..0x4d30  (736 bytes)
DATA_trozos_del_decorado:
	defb 006h,000h,070h,093h,0d8h,005h,04ch,005h,090h,000h,004h,001h,088h,081h,0d8h,005h	; 4a50  ..p...L.........
	defb 0bah,0e0h,0a1h,0c0h,091h,000h,052h,0e0h,08ah,081h,0d8h,005h,05bh,0c3h,098h,0c0h	; 4a60  ......R.....[...
	defb 0a8h,0c0h,0c0h,0c3h,019h,008h,090h,002h,006h,000h,0d8h,005h,073h,093h,022h,086h	; 4a70  ............s.".
	defb 033h,0e0h,090h,000h,0b3h,086h,0c0h,0e0h,049h,005h,088h,094h,0d8h,005h,0eah,0c9h	; 4a80  3.......I.......
	defb 072h,080h,023h,0c3h,038h,0c3h,050h,0c0h,060h,0c0h,0b0h,0c3h,0c8h,0c3h,019h,008h	; 4a90  r.#.8.P.`.......
	defb 0a8h,008h,005h,000h,0d8h,005h,04ch,005h,090h,001h,022h,0e0h,08ah,081h,0d8h,005h	; 4aa0  ......L...".....
	defb 09bh,0c0h,049h,005h,090h,000h,02bh,0c3h,001h,001h,070h,080h,089h,094h,052h,0c0h	; 4ab0  ..I...+...p...R.
	defb 060h,0c0h,039h,006h,090h,003h,0cdh,006h,089h,094h,04bh,005h,090h,000h,004h,001h	; 4ac0  `.9.......K.....
	defb 070h,093h,0d8h,005h,0bah,0e0h,0e8h,0c9h,059h,0c0h,049h,005h,090h,000h,004h,001h	; 4ad0  p.......Y.I.....
	defb 088h,081h,09bh,0c0h,0a8h,0c0h,0c0h,0c3h,039h,006h,090h,003h,0b3h,085h,005h,001h	; 4ae0  ........9.......
	defb 0b3h,0c2h,091h,00ah,03dh,006h,0c1h,0e0h,073h,080h,001h,000h,08ch,094h,05bh,0c0h	; 4af0  ....=...s.....[.
	defb 029h,0e0h,048h,005h,052h,0c8h,035h,0c3h,0c8h,0c3h,001h,003h,090h,003h,004h,001h	; 4b00  ).H.R.5.........
	defb 0d8h,005h,04ch,005h,090h,001h,004h,000h,070h,093h,0d8h,005h,089h,094h,062h,0c0h	; 4b10  ..L.....p.....b.
	defb 039h,006h,090h,001h,004h,001h,088h,081h,0d8h,005h,012h,0c8h,0a1h,0c0h,049h,005h	; 4b20  9.............I.
	defb 090h,001h,03dh,006h,0d8h,005h,003h,000h,092h,000h,08ch,081h,0dah,005h,031h,0e0h	; 4b30  ..=...........1.
	defb 0e1h,0c9h,021h,086h,098h,0c0h,0a8h,0c0h,071h,093h,090h,000h,08dh,094h,0c5h,0e0h	; 4b40  ..!.....q.......
	defb 025h,0c3h,038h,0c3h,0c8h,0c3h,019h,008h,090h,002h,0cdh,086h,019h,001h,07bh,086h	; 4b50  %.8...........{.
	defb 0c8h,0c3h,011h,081h,0b0h,006h,02bh,0c0h,038h,0c0h,078h,0c3h,019h,004h,022h,0c9h	; 4b60  ......+.8.x...".
	defb 09ah,0e0h,011h,094h,0c8h,086h,0a6h,0c3h,0c8h,0c3h,019h,002h,090h,008h,064h,086h	; 4b70  ..............d.
	defb 0a0h,007h,0bch,086h,062h,08fh,01ah,001h,078h,0e0h,0bbh,0c3h,011h,094h,0a0h,007h	; 4b80  ....b...x.......
	defb 033h,0c0h,060h,0c3h,019h,003h,0e8h,080h,083h,0c3h,0a8h,0c0h,0c0h,0c0h,071h,009h	; 4b90  3.`...........q.
	defb 014h,094h,0cch,0e0h,059h,086h,029h,0e0h,0a0h,086h,07eh,0e0h,0d3h,0c3h,031h,0c3h	; 4ba0  ....Y.)...~...1.
	defb 058h,0c3h,0c0h,005h,019h,003h,0a1h,08fh,0eah,080h,083h,0c3h,0a0h,0c3h,0c8h,0c0h	; 4bb0  X...............
	defb 071h,009h,0a6h,007h,01ch,001h,0e8h,093h,0b1h,086h,081h,0e0h,061h,086h,011h,081h	; 4bc0  q...........a...
	defb 033h,0c0h,040h,0c0h,060h,0c3h,019h,003h,032h,0c8h,014h,094h,089h,0c3h,0b0h,0c3h	; 4bd0  3.@.`...2.......
	defb 071h,009h,01eh,002h,0b0h,086h,0b3h,0c3h,011h,081h,0a0h,007h,02ah,0c0h,0b0h,0cah	; 4be0  q...........*...
	defb 019h,000h,061h,0e0h,080h,086h,0c9h,086h,03ah,086h,0cch,0c3h,0b1h,006h,03bh,0c3h	; 4bf0  ..a.....:.....;.
	defb 068h,0c3h,080h,0c3h,019h,004h,03dh,086h,0c9h,086h,0cah,0c3h,0c1h,005h,03bh,0c3h	; 4c00  h.....=.......;.
	defb 060h,086h,019h,001h,0e8h,093h,0b9h,086h,082h,086h,011h,094h,0b8h,0c3h,0d0h,0c0h	; 4c10  `...............
	defb 0b1h,006h,0ech,093h,062h,0c3h,080h,0c3h,019h,004h,0d5h,086h,019h,001h,0aah,0e0h	; 4c20  ....b...........
	defb 0d1h,0c3h,011h,081h,070h,0e0h,0c0h,005h,051h,086h,032h,0c0h,050h,0c3h,019h,002h	; 4c30  ....p...Q.2.P...
	defb 022h,0c8h,0b2h,0c3h,059h,086h,0a0h,007h,0ech,093h,05ah,0c3h,078h,0c3h,019h,004h	; 4c40  "...Y.....Z.x...
	defb 014h,094h,0c0h,086h,079h,086h,098h,086h,01bh,001h,0c2h,0c3h,0b1h,006h,011h,081h	; 4c50  ....y...........
	defb 032h,0c0h,019h,003h,0e8h,093h,07ah,08fh,09ah,0c3h,0d0h,0c0h,091h,008h,07ch,0c3h	; 4c60  2.....z.......|.
	defb 0e8h,093h,019h,004h,095h,000h,004h,000h,088h,094h,0c8h,006h,03ch,006h,090h,000h	; 4c70  ............<...
	defb 0cch,006h,004h,003h,090h,000h,074h,093h,0d8h,005h,095h,001h,0b3h,085h,001h,001h	; 4c80  ......t.........
	defb 04ch,005h,0b3h,0c2h,091h,00ah,04ch,005h,088h,094h,004h,001h,070h,080h,090h,000h	; 4c90  L.....L.....p...
	defb 05bh,0c0h,049h,005h,0c8h,006h,09bh,086h,0b1h,006h,05dh,086h,09ah,0c3h,071h,009h	; 4ca0  [.I.......]...q.
	defb 039h,086h,0c9h,0cah,0ebh,093h,03eh,0c3h,058h,0c3h,019h,003h,05bh,086h,011h,094h	; 4cb0  9.....>.X...[...
	defb 03ah,086h,0a3h,086h,03eh,0c3h,058h,0c3h,019h,004h,014h,094h,0a3h,0c3h,071h,009h	; 4cc0  :...>.X.......q.
	defb 043h,085h,0a8h,085h,0ffh,008h,087h,000h,001h,088h,01dh,000h,090h,008h,043h,085h	; 4cd0  C.............C.
	defb 0a8h,085h,0ffh,008h,08ah,000h,001h,089h,04dh,005h,090h,000h,005h,001h,0c8h,006h	; 4ce0  ........M.......
	defb 04dh,005h,090h,000h,004h,000h,0d8h,005h,0ffh,020h,084h,000h,004h,083h,005h,082h	; 4cf0  M........ ......
	defb 0b3h,0c2h,091h,00ah,03ch,006h,0b3h,0c0h,091h,002h,053h,0c0h,029h,007h,043h,085h	; 4d00  ....<.....S.).C.
	defb 0a8h,085h,0ffh,008h,08ah,000h,001h,091h,004h,092h,001h,091h,004h,092h,001h,091h	; 4d10  ................
	defb 05bh,0c4h,098h,0c4h,001h,092h,001h,091h,004h,092h,001h,091h,0ffh,020h,0ffh,000h	; 4d20  [............ ..

; ----------------------------------------------------------------------
; DATOS tabla_de_trozos: 25 entradas de tres bytes -puntero y numero de TIRAS-
;   que 0x52E9 indexa con `add a,a / add a,l` (por tres). Son 25 y no mas
;   porque la entrada 26 daria el puntero 0x0617, que no es ROM. Y esta tabla
;   se lee a si misma sin querer: el trozo 22 (0x4D0E) declara dieciseis
;   tiras, pero con quince ya ha llegado a 0x4D30, asi que la decimosexta coge
;   0x50 0x4A, que son los dos primeros bytes de la propia tabla. No es un
;   caso raro: 22 es 0x16, el numero que cierra TODOS los guiones de fase, o
;   sea que pasa en las diez
;   0x4d30..0x4d7b  (75 bytes)
DATA_tabla_de_trozos:
	defb 050h,04ah,014h,078h,04ah,000h,078h,04ah,015h,0a2h,04ah,012h,0c6h,04ah,013h,0ech	; 4d30  PJ.xJ.xJ..J..J..
	defb 04ah,011h,00eh,04bh,012h,032h,04bh,014h,05ah,04bh,012h,07eh,04bh,011h,0a0h,04bh	; 4d40  J..K.2K.ZK.~K..K
	defb 011h,0c2h,04bh,010h,0e2h,04bh,012h,006h,04ch,012h,02ah,04ch,013h,050h,04ch,012h	; 4d50  ..K..K..L.*L.PL.
	defb 0d0h,04ch,006h,0deh,04ch,00ch,074h,04ch,00ch,08ch,04ch,00dh,0a6h,04ch,00bh,0bch	; 4d60  .L..L.tL..L..L..
	defb 04ch,00ah,00eh,04dh,010h,0f8h,04ch,00ah,0e2h,04ch,00ah	; 4d70  L..M..L..L.

; ----------------------------------------------------------------------
; DATOS guiones_de_decorado: nueve tiras de numeros de trozo, una por fase.
;   Cada una acaba con el valor 0x16, que es el corte que mira 0x52E1; las
;   nueve seguidas suman los 160 bytes justos que hay hasta la tabla de abajo
;   0x4d7b..0x4e1b  (160 bytes)
DATA_guiones_de_decorado:
	defb 017h,006h,003h,004h,010h,00fh,014h,00ch,011h,003h,013h,004h,010h,00dh,015h,014h	; 4d7b  ................
	defb 016h,018h,012h,007h,000h,010h,00ch,009h,014h,011h,007h,012h,007h,010h,015h,00eh	; 4d8b  ................
	defb 00dh,016h,018h,000h,013h,002h,010h,00fh,00bh,015h,011h,002h,012h,005h,007h,010h	; 4d9b  ................
	defb 008h,00fh,00ch,016h,018h,003h,007h,004h,010h,00dh,00bh,008h,011h,012h,003h,002h	; 4dab  ................
	defb 010h,008h,00ah,015h,008h,016h,018h,002h,007h,004h,010h,009h,00fh,00bh,009h,014h	; 4dbb  ................
	defb 009h,00eh,014h,00ah,00fh,00bh,00ch,016h,018h,007h,006h,005h,010h,00dh,009h,00ch	; 4dcb  ................
	defb 015h,011h,012h,006h,007h,010h,015h,008h,00ah,016h,018h,007h,013h,000h,010h,009h	; 4ddb  ................
	defb 00ch,00dh,008h,011h,007h,005h,002h,007h,010h,008h,009h,00eh,016h,018h,012h,000h	; 4deb  ................
	defb 002h,005h,010h,015h,00ch,009h,00eh,00ah,014h,00dh,009h,00eh,015h,016h,018h,003h	; 4dfb  ................
	defb 002h,000h,006h,007h,005h,007h,013h,000h,010h,014h,00ah,00dh,009h,00eh,00dh,016h	; 4e0b  ................

; ----------------------------------------------------------------------
; DATOS tabla_de_decorados: diez punteros a los guiones de arriba, indexados
;   por el numero de fase de (0xE05C) en 0x52CF. El decimo repite el primero
;   (0x4D7B), o sea que a partir de la fase 10 se vuelve al decorado de la
;   primera
;   0x4e1b..0x4e2f  (20 bytes)
DATA_tabla_de_decorados:
	defb 07bh,04dh,08ch,04dh,09dh,04dh,0afh,04dh,0c1h,04dh,0d3h,04dh,0e5h,04dh,0f8h,04dh	; 4e1b  {M.M.M.M.M.M.M.M
	defb 009h,04eh,07bh,04dh	; 4e2b

; ----------------------------------------------------------------------
; DATOS piezas_4E2F: 46 estructuras, cada una con dos bytes de cabecera; las
;   apuntan las cuatro tablas de abajo
;   0x4e2f..0x5130  (769 bytes)
DATA_piezas_4E2F:
	defb 001h,005h,0cdh,0cfh,0cfh,0cfh,0d0h,001h,007h,001h,0cdh,005h,0cfh,001h,0d0h,000h	; 4e2f  ................
	defb 001h,009h,001h,0cdh,007h,0cfh,001h,0d0h,000h,001h,00bh,001h,0cdh,009h,0cfh,001h	; 4e3f  ................
	defb 0d0h,000h,001h,00fh,001h,0cdh,00dh,0cfh,001h,0d0h,000h,001h,005h,0d0h,0cfh,0cfh	; 4e4f  ................
	defb 0cfh,0ceh,001h,007h,001h,0d0h,005h,0cfh,001h,0ceh,000h,001h,009h,001h,0d0h,007h	; 4e5f  ................
	defb 0cfh,001h,0ceh,000h,001h,00bh,001h,0d0h,009h,0cfh,001h,0ceh,000h,001h,00fh,001h	; 4e6f  ................
	defb 0d0h,00dh,0cfh,001h,0ceh,000h,005h,001h,086h,086h,08bh,08ch,086h,005h,001h,08ah	; 4e7f  ................
	defb 08ah,08dh,08eh,08ah,004h,001h,086h,01ch,01dh,086h,004h,001h,08ah,01eh,01fh,08ah	; 4e8f  ................
	defb 005h,020h,00eh,003h,084h,086h,088h,089h,08ah,004h,003h,083h,078h,079h,07ah,007h	; 4e9f  . ..........xyz.
	defb 003h,000h,085h,003h,003h,07dh,07eh,07fh,009h,003h,084h,086h,088h,089h,08ah,004h	; 4eaf  .....}~.........
	defb 003h,083h,078h,079h,07ah,007h,003h,000h,08ah,07bh,07ch,005h,005h,005h,080h,081h	; 4ebf  ..xyz....{|.....
	defb 07dh,07eh,07fh,004h,003h,084h,086h,088h,089h,08ah,004h,003h,083h,078h,079h,07ah	; 4ecf  }~...........xyz
	defb 005h,003h,082h,07dh,07eh,000h,00ah,075h,088h,074h,076h,077h,077h,086h,088h,089h	; 4edf  ...}~..u.tvww...
	defb 08ah,004h,003h,08ah,078h,079h,07ah,003h,07dh,07eh,07dh,07ch,005h,005h,000h,00eh	; 4eef  ....xyz.}~}|....
	defb 004h,084h,086h,088h,089h,08ah,004h,004h,083h,071h,072h,073h,007h,004h,000h,004h	; 4eff  .........qrs....
	defb 020h,00eh,004h,084h,086h,088h,089h,08ah,004h,004h,083h,06dh,06eh,06fh,007h,004h	; 4f0f   ..........mno..
	defb 000h,00eh,068h,084h,086h,088h,089h,08ah,004h,068h,083h,069h,06ah,06bh,007h,068h	; 4f1f  ..h......h.ijk.h
	defb 000h,00eh,064h,084h,086h,088h,089h,08ah,004h,064h,083h,066h,067h,065h,007h,064h	; 4f2f  ..d......d.fge.d
	defb 000h,00dh,062h,086h,085h,086h,088h,089h,08ah,087h,003h,062h,083h,082h,083h,084h	; 4f3f  ..b........b....
	defb 007h,062h,000h,001h,020h,00eh,061h,084h,060h,061h,061h,063h,00eh,061h,000h,003h	; 4f4f  .b.. .a.`aac.a..
	defb 001h,0d4h,0d5h,003h,004h,003h,003h,09bh,003h,0c3h,022h,0c4h,003h,023h,003h,003h	; 4f5f  .........."..#..
	defb 003h,003h,005h,003h,003h,09bh,003h,0beh,024h,0bfh,0c0h,025h,0c1h,003h,0c2h,003h	; 4f6f  ........$..%....
	defb 003h,003h,003h,004h,003h,003h,09bh,003h,0bch,020h,0bdh,003h,021h,003h,003h,003h	; 4f7f  ......... ..!...
	defb 003h,001h,020h,083h,0a9h,089h,08ah,00dh,003h,00dh,003h,083h,006h,088h,0b1h,000h	; 4f8f  .. .............
	defb 004h,020h,083h,0a9h,089h,0aah,005h,0abh,083h,091h,094h,097h,004h,0abh,082h,0adh	; 4f9f  . ..............
	defb 0aeh,004h,0abh,083h,091h,094h,097h,005h,0abh,083h,0afh,0b0h,0b1h,000h,082h,0a9h	; 4faf  ................
	defb 0a3h,006h,0a4h,083h,092h,095h,098h,004h,0a4h,082h,0a5h,0a6h,004h,0a4h,083h,092h	; 4fbf  ................
	defb 095h,098h,006h,0a4h,082h,0a7h,0a8h,000h,081h,09dh,007h,09ch,090h,093h,096h,099h	; 4fcf  ................
	defb 09ch,09ch,09eh,0a0h,088h,089h,0a1h,0a2h,09ch,09ch,093h,096h,099h,007h,09ch,081h	; 4fdf  ................
	defb 09fh,000h,008h,003h,083h,078h,079h,07ah,003h,003h,084h,006h,088h,089h,08ah,003h	; 4fef  .....xyz........
	defb 003h,083h,078h,079h,07ah,008h,003h,000h,001h,020h,00eh,003h,084h,006h,088h,089h	; 4fff  ..xyz.... ......
	defb 08ah,00eh,003h,000h,004h,020h,082h,0b2h,0ach,006h,0abh,083h,091h,094h,097h,003h	; 500f  ..... ..........
	defb 0abh,084h,0afh,0b0h,089h,0aah,003h,0abh,083h,091h,094h,097h,007h,0abh,081h,0b3h	; 501f  ................
	defb 000h,082h,0a9h,0a6h,006h,0a4h,083h,092h,095h,098h,004h,0a4h,082h,0a7h,0a3h,004h	; 502f  ................
	defb 0a4h,083h,092h,095h,098h,006h,0a4h,082h,0a5h,0b1h,000h,084h,0a9h,089h,08ah,0a2h	; 503f  ................
	defb 004h,09ch,083h,093h,096h,099h,00ah,09ch,083h,093h,096h,099h,004h,09ch,084h,09eh	; 504f  ................
	defb 0a0h,088h,0b1h,000h,083h,0a9h,089h,08ah,005h,003h,083h,078h,079h,07ah,00ah,003h	; 505f  ...........xyz..
	defb 083h,078h,079h,07ah,005h,003h,083h,006h,088h,0b1h,000h,001h,001h,09bh,002h,001h	; 506f  .xyz............
	defb 09bh,003h,003h,001h,09bh,09ah,09bh,001h,009h,001h,0cdh,003h,0cfh,085h,0d3h,0d2h	; 507f  ................
	defb 0d1h,0d0h,0d0h,000h,002h,003h,078h,079h,07ah,003h,003h,003h,001h,003h,078h,079h	; 508f  ......xyz.....xy
	defb 07ah,002h,001h,086h,0d6h,002h,001h,08ah,0d7h,005h,002h,003h,003h,0c9h,0cah,028h	; 509f  z..............(
	defb 029h,0cbh,0cch,003h,003h,004h,003h,003h,003h,003h,0c5h,026h,0c6h,0c7h,027h,0c8h	; 50af  )..........&..'.
	defb 003h,003h,003h,004h,002h,003h,003h,02ah,02bh,02ch,02dh,003h,003h,001h,020h,010h	; 50bf  .......*+,-... .
	defb 00ah,001h,00ch,00fh,00ah,000h,001h,020h,0a0h,00ah,00ah,00bh,00ah,00ah,00bh,00ah	; 50cf  ....... ........
	defb 00ah,00bh,00ah,00ah,00bh,00ah,00ah,00bh,00ah,00ch,00ah,00bh,00ah,00ah,00bh,00ah	; 50df  ................
	defb 00ah,00bh,00ah,00ah,00bh,00ah,00ah,00bh,00ah,000h,003h,002h,00ah,00ah,02fh,008h	; 50ef  ............../.
	defb 007h,009h,003h,002h,003h,003h,003h,003h,019h,01ah,003h,002h,003h,003h,003h,003h	; 50ff  ................
	defb 01bh,01bh,003h,002h,003h,003h,019h,01ah,01bh,01bh,002h,002h,003h,003h,0b6h,0b7h	; 510f  ................
	defb 002h,003h,003h,003h,003h,0e2h,0e3h,0e4h,002h,002h,003h,003h,0bah,0bbh,001h,001h	; 511f  ................
	defb 003h	; 512f

; ----------------------------------------------------------------------
; DATOS tabla_de_piezas_1: 11 punteros; la elige 0x4A14
;   0x5130..0x5146  (22 bytes)
DATA_tabla_de_piezas_1:
	defw 04e2fh,04e36h,04e3fh,04e48h,04e51h,04e5ah,04e61h,04e6ah	; 5130
	defw 04e73h,04e7ch,05086h	; 5140

; ----------------------------------------------------------------------
; DATOS tabla_de_piezas_2: 21 punteros; la elige 0x4A20
;   0x5146..0x5170  (42 bytes)
DATA_tabla_de_piezas_2:
	defw 04e85h,04e8ch,04e9fh,04f0eh,04f52h,05093h,0507dh,04f9fh	; 5146
	defw 04f90h,05007h,05013h,050a0h,050a8h,050b4h,050a4h,05081h	; 5156
	defw 050c2h,050cch,050d5h,04e93h,04e99h	; 5166

; ----------------------------------------------------------------------
; DATOS tabla_de_piezas_3: 12 punteros; la elige 0x4A27
;   0x5170..0x5188  (24 bytes)
DATA_tabla_de_piezas_3:
	defw 04f5eh,04f63h,0509bh,0507ah,050f9h,05101h,05109h,05111h	; 5170
	defw 05119h,0511fh,05127h,0512dh	; 5180

; ----------------------------------------------------------------------
; DATOS tabla_de_piezas_4: 3 punteros; la elige 0x4A19
;   0x5188..0x518e  (6 bytes)
DATA_tabla_de_piezas_4:
	defw 04f63h,04f71h,04f82h	; 5188

; ======================================================================
; CODIGO 0x518e..0x51c1  (51 bytes)
; ======================================================================


borra_el_tanteo:
	ld hl,0e049h		;518e   ; el tanteo de un jugador
	ld bc,000e7h		;5191   ; 231 bytes por delante
	ld a,(0e002h)		;5194
	and 020h		;5197   ; el bit 5: hay dos jugadores
	push af			;5199
	jr z,reinicia_el_estado_del_jugador		;519a
	ld l,046h		;519c   ; entonces el otro tanteo
	inc bc			;519e
	inc bc			;519f
	inc bc			;51a0

; ----------------------------------------------------------------------
; REINICIAR AL JUGADOR: propaga un cero con `ldir` desde la propia celda, copia los diecisiete valores iniciales y, si hay dos jugadores, duplica el bloque entero en el hueco del segundo.
; ----------------------------------------------------------------------
reinicia_el_estado_del_jugador:
	ld d,h			;51a1
	ld e,l			;51a2
	inc e			;51a3
	ld (hl),000h		;51a4   ; un cero
	ldir		;51a6   ; y el ldir lo arrastra
	ld hl,051c1h		;51a8   ; los diecisiete valores iniciales
	ld de,0e050h		;51ab
	ld bc,00011h		;51ae
	ldir		;51b1
	pop af			;51b3
	ret z			;51b4   ; con un jugador, aqui se acaba
	ld hl,0e050h		;51b5   ; y con dos, el estado se duplica
	ld de,0e080h		;51b8
	ld bc,00020h		;51bb   ; los treinta y dos bytes
	ldir		;51be
	ret			;51c0

; ----------------------------------------------------------------------
; DATOS valores_iniciales: 17 bytes a 0xE050; 0x7545 copia trece desde 0x51C5
;   0x51c1..0x51d2  (17 bytes)
DATA_valores_iniciales:
	defb 003h,001h,000h,000h,000h,000h,084h,0f0h,003h,000h,083h,03bh,000h,077h,000h,004h,000h	; 51c1  ...........;.w...

; ======================================================================
; CODIGO 0x51d2..0x5394  (450 bytes)
; ======================================================================


pinta_la_altura_y_el_marcador:
	call monta_los_graficos		;51d2
	call limpia_los_objetos		;51d5
	call pone_en_pie_la_partida		;51d8
	jp vuelca_los_sprites		;51db

; ----------------------------------------------------------------------
; EL CUADRO ENTERO: vuelca los sprites, mira si el jugador ha llegado a algo, luego los premios y por ultimo todo lo que se mueve. El orden importa, porque lo ultimo que se escribe es lo que se ve.
; ----------------------------------------------------------------------
el_cuadro_del_juego:
	ld a,(0e001h)		;51de   ; la bandera de partida en marcha
	or a			;51e1
	jp nz,L_5227		;51e2
	call vuelca_los_sprites		;51e5   ; los sprites, a la VRAM
	call mira_lo_que_pisa		;51e8   ; mira el contacto
	jr c,el_jugador_pierde		;51eb
	call mira_los_bichos_caidos		;51ed
	jr nc,el_cuadro_de_la_partida		;51f0
	call suelta_el_premio		;51f2

; ----------------------------------------------------------------------
; EL CUADRO DE LA PARTIDA, y es lo mas parecido a un indice del cartucho: once llamadas seguidas, una por cada cosa que se mueve -los perseguidores, los tres de la lista, los cinco moviles, los bichos nuevos, los sueltos-.
; ----------------------------------------------------------------------
el_cuadro_de_la_partida:
	call mira_el_contacto_del_jugador		;51f5   ; lo primero, si al jugador le ha tocado algo
	call mueve_los_tres_perseguidores		;51f8   ; los tres perseguidores
	call mira_el_digito_y_suelta		;51fb   ; el digito que se gana y lo que suelta
	call mueve_los_tres_de_la_lista		;51fe
	call mueve_los_cinco_moviles		;5201   ; y los cinco moviles
	call suelta_el_bicho_del_cuadro_cero		;5204   ; el bicho del cuadro cero
	call suelta_un_bicho_nuevo		;5207
	call suelta_el_premio_de_la_fase_6		;520a   ; el premio que solo sale en la fase 6
	call mueve_los_premios		;520d
	call mueve_los_dos_bichos_sueltos		;5210
	call mueve_los_tres_proyectiles		;5213
	call mueve_los_tres_caidos		;5216   ; los que van cayendo
	call mueve_el_perseguidor		;5219
	call limpia_los_huecos_sobrantes		;521c   ; y al final, los huecos de sprite que hayan quedado sueltos
L_521F:
	call pinta_la_altura_en_bcd		;521f   ; la altura, que es el marcador de este juego
	xor a			;5222
	ld (0e1aah),a		;5223   ; y la direccion del movimiento se borra: cada cuadro la vuelve a poner quien toque
	ret			;5226
L_5227:
	call vuelca_los_sprites		;5227   ; esta puerta vuelca los sprites ANTES de mirar el contacto
	call mira_el_contacto_del_jugador		;522a
	jr L_521F		;522d
el_jugador_pierde:
	ld a,09ch		;522f   ; el sonido de perder
	call pide_un_sonido		;5231
	ld a,008h		;5234   ; estado 8: perdiendo
	ld (0e1b2h),a		;5236   ; estado 8
	xor a			;5239
	ld (0e003h),a		;523a   ; el contador de cuadros se pone a cero para medir desde aqui
	inc a			;523d   ; y (0xE001) a uno
	ld (0e001h),a		;523e   ; y se marca que ya paso
	ret			;5241
mira_lo_que_pisa:
	call lee_las_dos_celdas_de_debajo		;5242   ; las dos celdas de debajo
	ld a,(0e1b2h)		;5245   ; el estado del jugador
	cp 004h		;5248   ; en el estado 4 no se mira lo que pisa
	ret z			;524a
	cp 003h		;524b   ; el estado 3 mira ademas el sentido
	jr nz,L_5254		;524d   ; el estado 3 mira ademas el sentido
	ld a,(0e1c8h)		;524f
	and a			;5252   ; con el bit 7 puesto, tampoco
	ret m			;5253
L_5254:
	ld hl,0e1bfh		;5254   ; los dos patrones que se leyeron de debajo
	ld b,002h		;5257
busca_un_patron_del_arbol:
	ld a,(hl)			;5259   ; el patron
	ld c,a			;525a   ; el patron, apartado en C: es lo que devuelve la rutina
	sub 020h		;525b   ; los indices desde 0x20
	cp 00eh		;525d   ; catorce seguidos
	ret c			;525f   ; dentro de los catorce, hay arbol: se sale con acarreo
	inc hl			;5260
	djnz busca_un_patron_del_arbol		;5261   ; y si no, el otro
	ld hl,0e0e4h		;5263   ; los huecos de sprite
	ld de,01010h		;5266   ; dieciseis por dieciseis
	ld b,008h		;5269   ; ocho

; ----------------------------------------------------------------------
; LA CAJA CONTRA LOS OCHO HUECOS de sprite de 0xE0E4, de 0x10 por 0x10. Los patrones 0x90 y 0x94 se saltan: son los que no hacen dano.
; ----------------------------------------------------------------------
mira_los_ocho_huecos:
	push bc			;526b
	call caja_alrededor_del_jugador		;526c   ; contra este hueco
	pop bc			;526f
	inc hl			;5270   ; al byte del patron
	jr nc,L_527E		;5271   ; sin contacto, el siguiente
	ld a,(hl)			;5273
	cp 090h		;5274   ; estos dos patrones no cuentan
	jr z,L_527E		;5276
	cp 094h		;5278
	jr z,L_527E		;527a
	scf			;527c   ; acarreo: hay contacto
	ret			;527d
L_527E:
	inc hl			;527e
	inc hl			;527f   ; tres bytes por hueco, y uno ya se avanzo arriba
	djnz mira_los_ocho_huecos		;5280
	xor a			;5282   ; sin acarreo: no hay contacto con ninguno
	ret			;5283

; ----------------------------------------------------------------------
; LA CAJA ALREDEDOR DEL JUGADOR, y no es simetrica: de 8 a 0x18 en una coordenada y de 6 a 0x0A en la otra. Es la manera de que rozar por arriba no cuente igual que chocar de frente.
; ----------------------------------------------------------------------
caja_alrededor_del_jugador:
	ld bc,(0e1b3h)		;5284   ; la posicion del jugador
	ld a,008h		;5288   ; ocho por delante
	add a,c			;528a
	sub (hl)			;528b   ; la distancia a este lado
	cp e			;528c   ; contra el ancho
	jr c,L_5294		;528d   ; dentro del primer margen, ya hay contacto
	ld a,018h		;528f   ; y si no, se prueba con el ancho entero
	add a,c			;5291
	sub (hl)			;5292
	cp e			;5293
L_5294:
	inc hl			;5294   ; al byte de la otra coordenada
	ret nc			;5295   ; fuera en esta, no hace falta mirar la otra
	ld a,006h		;5296   ; seis por arriba
	add a,b			;5298
	sub (hl)			;5299   ; la distancia por arriba
	cp d			;529a
	ret c			;529b
	ld a,00ah		;529c   ; y diez
	add a,b			;529e
	sub (hl)			;529f   ; y por abajo
	cp d			;52a0
	ret			;52a1
vuelca_los_sprites:
	ld hl,0e0b0h		;52a2   ; el bufer de sprites en RAM
	ld de,03b00h		;52a5   ; la tabla de atributos de la VRAM
	ld bc,00080h		;52a8   ; 128 bytes, los 32 sprites
	jp vuelca_bloque		;52ab

; ----------------------------------------------------------------------
; LIMPIAR LAS DOS LISTAS con la propagacion del `ldir`: 292 bytes a cero desde 0xE131 y luego 119 bytes a 0xD0 desde 0xE132, que es el valor de "retirado". Dos instrucciones por lista.
; ----------------------------------------------------------------------
limpia_los_objetos:
	ld hl,0e131h		;52ae   ; la primera lista arranca en 0xE131
	ld de,0e132h		;52b1
	ld (hl),000h		;52b4   ; se pone UN cero
	ld bc,00124h		;52b6   ; 292 bytes
	ldir		;52b9   ; y el `ldir` lo arrastra por los 292

; ----------------------------------------------------------------------
; EL MONTAJE DEL DECORADO. La fase indexa la tabla de 0x4E1B, de ahi sale un guion de trozos, y cada trozo se busca en la tabla de 0x4D30 -tres bytes por entrada- que da su tira de patrones. El guion acaba en el valor 0x16.
; ----------------------------------------------------------------------
monta_el_decorado_de_la_fase:
	ld hl,0e132h		;52bb   ; la segunda lista, y la limpia la rutina de MONTAR el decorado: las dos van pegadas a proposito
	ld de,0e133h		;52be
	ld (hl),0d0h		;52c1   ; y 0xD0: retirado
	ld bc,00077h		;52c3   ; 119 bytes
	ldir		;52c6   ; mismo arrastre, con el otro valor
	ld de,03b80h		;52c8   ; el destino en la VRAM
	ld a,(0e05ch)		;52cb   ; el numero de fase
	add a,a			;52ce   ; por dos: son punteros
	ld hl,04e1bh		;52cf   ; la tabla de decorados
	call suma_a_a_hl		;52d2   ; indexa la tabla de decorados
	ld a,(hl)			;52d5   ; el puntero al guion de trozos
	inc hl			;52d6
	ld h,(hl)			;52d7   ; leido al reves sobre el mismo par
	ld l,a			;52d8
L_52D9:
	push hl			;52d9   ; el guion se guarda: pintar el trozo lo gasta
	ld a,(hl)			;52da   ; el trozo que toca
	call pinta_un_trozo_del_decorado		;52db
	pop hl			;52de
	ld a,(hl)			;52df   ; y se vuelve a leer para mirar si era el ultimo
	inc hl			;52e0
	cp 016h		;52e1   ; el valor 0x16 cierra el guion
	jr nz,L_52D9		;52e3
	ret			;52e5
pinta_un_trozo_del_decorado:
	ld l,a			;52e6
	add a,a			;52e7   ; por tres, que es lo que ocupa cada entrada
	add a,l			;52e8
	ld hl,04d30h		;52e9   ; la tabla de trozos
	call suma_a_a_hl		;52ec
	ld a,(hl)			;52ef   ; el byte bajo de la tira
	inc hl			;52f0
	ld c,(hl)			;52f1   ; cuantas tiras tiene
	inc hl			;52f2
	ld b,(hl)			;52f3   ; y el byte alto
	ld l,a			;52f4
	ld h,c			;52f5

; ----------------------------------------------------------------------
; PINTAR UNA TIRA DE TRES CELDAS. El byte trae DOS cosas: los cinco bits de arriba son el tercer patron y los tres de abajo el primero, de modo que dos celdas caben en un byte. Un 0xFF cierra la tira.
; ----------------------------------------------------------------------
pinta_la_tira_de_tres:
	ld a,(hl)			;52f6   ; el byte, con DOS patrones dentro
	cp 0ffh		;52f7   ; 0xFF: fin de la tira
	jr z,L_5312		;52f9
	and 0f8h		;52fb   ; los cinco bits de arriba
	ld c,a			;52fd   ; el tercero, apartado hasta el final
	ld a,(hl)			;52fe   ; y el mismo byte otra vez
	and 007h		;52ff   ; y los tres de abajo, el primer patron
	call escribe_en_vram		;5301
	inc de			;5304
	inc hl			;5305   ; el byte siguiente
	ld a,(hl)			;5306   ; el segundo va entero
	inc hl			;5307
	call escribe_en_vram		;5308
	inc de			;530b
	ld a,c			;530c   ; y ahora si, el tercero
	call escribe_en_vram		;530d
	jr L_531D		;5310
L_5312:
	inc hl			;5312   ; detras del 0xFF
	push bc			;5313
	ld bc,00003h		;5314   ; tres celdas seguidas, sin empaquetar
	call vuelca_bloque		;5317
	pop bc			;531a
	inc de			;531b   ; dos celdas mas, que las tiras van de tres en tres
	inc de			;531c
L_531D:
	inc de			;531d   ; la tercera
	djnz pinta_la_tira_de_tres		;531e
	ret			;5320

; ----------------------------------------------------------------------
; PONER EN PIE LA PARTIDA: monta el decorado, prepara los sprites, reparte los cinco bytes de 0x539D uno de cada cuatro -o sea, solo los colores- y copia los cinco valores iniciales del jugador.
; ----------------------------------------------------------------------
pone_en_pie_la_partida:
	call recorre_el_decorado_entero		;5321
	call prepara_los_sprites		;5324
	ld hl,0e0d3h		;5327   ; el bufer de sprites
	ld de,0539dh		;532a   ; los cinco valores
	ld b,005h		;532d   ; cinco
L_532F:
	ld a,(de)			;532f   ; el color de este sprite
	ld (hl),a			;5330
	inc de			;5331
	inc hl			;5332   ; cuatro bytes por sprite, y de los cuatro solo se toca el del color
	inc hl			;5333
	inc hl			;5334
	inc hl			;5335
	djnz L_532F		;5336
	ld hl,05398h		;5338   ; los cinco valores del jugador
	ld de,0e1b3h		;533b
	ld bc,00005h		;533e   ; cinco bytes
	ldir		;5341   ; los cinco a su sitio
	jp mete_al_jugador_en_los_sprites		;5343

; ----------------------------------------------------------------------
; PREPARAR EL BUFER DE SPRITES: cuatro copias del mismo grupo de cuatro bytes y, detras, 111 bytes de 0xC3 propagados con un `ldir` desde la propia celda. Todo lo que no se use queda fuera de la pantalla.
; ----------------------------------------------------------------------
prepara_los_sprites:
	ld de,0e0b0h		;5346
	ld hl,05394h		;5349
	ld bc,00404h		;534c   ; cuatro copias de cuatro bytes: el mismo grupo repetido
L_534F:
	push hl			;534f
	push bc			;5350
	ld b,000h		;5351   ; la cuenta alta, cero
	ldir		;5353
	pop bc			;5355
	pop hl			;5356
	djnz L_534F		;5357
	ld h,d			;5359   ; DE quedo detras de la ultima copia, y de ahi arranca el arrastre
	ld l,e			;535a
	ld (hl),0c3h		;535b   ; 0xC3: fuera de la pantalla
	inc de			;535d   ; y el `ldir` copia sobre si mismo
	ld c,06fh		;535e   ; y el ldir lo arrastra por el resto
	ldir		;5360
	ret			;5362

; ----------------------------------------------------------------------
; RECORRER EL DECORADO ENTERO DE UNA VEZ: guarda por donde iba, retrocede tres celdas y da VEINTISEIS pasadas seguidas de la rutina de movimiento, para dejar el arbol montado desde el principio. Al acabar, restaura el puntero.
; ----------------------------------------------------------------------
recorre_el_decorado_entero:
	ld a,(0e059h)		;5363   ; por donde iba
	ld hl,(0e05ah)		;5366
	push af			;5369   ; las dos cosas se guardan: las veintiseis pasadas las machacan
	push hl			;536a
	dec hl			;536b   ; tres celdas atras, que es desde donde se monta
	dec hl			;536c
	dec hl			;536d
	ld (0e1c5h),hl		;536e
	call 0004ah		;5371   ; BIOS RDVRM - Reads the content of VRAM
	dec a			;5374   ; uno menos que el indice leido
	ld (0e1c4h),a		;5375
	ld a,001h		;5378   ; hacia un lado
	ld (0e1aah),a		;537a   ; la direccion del movimiento
	ld b,01ah		;537d   ; veintiseis pasadas
L_537F:
	push bc			;537f
	call mueve_el_decorado_un_paso		;5380   ; y una pasada entera del decorado
	pop bc			;5383
	djnz L_537F		;5384
	pop hl			;5386
	pop af			;5387
	ld (0e059h),a		;5388   ; por donde iba, restaurado
	ld (0e05ah),hl		;538b
	ld hl,0e1abh		;538e
	set 1,(hl)		;5391   ; y el tope de arriba, marcado
	ret			;5393

; ----------------------------------------------------------------------
; DATOS plantilla_de_sprite: los cuatro bytes que 0x5346 copia CUATRO veces a
;   0xE0B0: el `pop hl` de 0x5356 devuelve HL a 0x5394 en cada vuelta, asi que
;   las cuatro copias salen de aqui
;   0x5394..0x5398  (4 bytes)
DATA_plantilla_de_sprite:
	defb 008h,000h,000h,000h	; 5394

; ----------------------------------------------------------------------
; DATOS valores_del_jugador: los cinco bytes que 0x5338 lleva de un `ldir` a
;   0xE1B3
;   0x5398..0x539d  (5 bytes)
DATA_valores_del_jugador:
	defb 098h,020h,000h,000h,008h	; 5398

; ----------------------------------------------------------------------
; DATOS patrones_de_los_cinco_sprites: un byte por sprite; 0x532A los reparte
;   por el bufer de 0xE0D3 saltando de cuatro en cuatro, que es lo que ocupa
;   cada sprite
;   0x539d..0x53a2  (5 bytes)
DATA_patrones_de_los_cinco_sprites:
	defb 009h,001h,009h,006h,009h	; 539d

; ======================================================================
; CODIGO 0x53a2..0x53e4  (66 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL GUION DE LA FASE, con su propio plazo en (0xE24D): cuando se agota, lee dos bytes mas adelante y, si es 0xFF, levanta la senal de fin de vida.
; ----------------------------------------------------------------------
avanza_el_guion_de_la_fase:
	ld hl,0e24dh		;53a2   ; el plazo del paso en curso
	ld de,(0e24eh)		;53a5   ; por donde va el guion
	dec (hl)			;53a9   ; el plazo
	jr nz,L_53BC		;53aa
	inc de			;53ac   ; dos bytes mas alla esta el paso siguiente
	inc de			;53ad
	ld a,(de)			;53ae
	cp 0ffh		;53af   ; 0xFF cierra el guion
	jr nz,L_53B7		;53b1   ; con 0xFF no hay mas guion
	ld (0e00ch),a		;53b3   ; y es la senal de fin
	ret			;53b6
L_53B7:
	ld (hl),a			;53b7   ; el plazo nuevo
	ld (0e24eh),de		;53b8   ; el guion queda apuntado
L_53BC:
	inc de			;53bc   ; y el byte de detras del plazo
	ld a,(de)			;53bd   ; y el paso siguiente pasa por (0xE009)
	ld (0e009h),a		;53be   ; es lo que el resto del cartucho lee como si fuera el mando
	ret			;53c1

; ----------------------------------------------------------------------
; ARRANCAR UNA VIDA: reinicia al jugador, pinta el marcador, baja las dos senales de fin y le da al guion de la fase un plazo de 150 cuadros con su puntero en 0x53E4.
; ----------------------------------------------------------------------
arranca_la_vida:
	call borra_el_tanteo		;53c2
	call pinta_el_marcador		;53c5
	call pinta_la_altura_y_el_marcador		;53c8
	xor a			;53cb   ; cero para las dos senales
	ld (0e00ch),a		;53cc   ; la senal de fin de vida
	ld (0e001h),a		;53cf   ; y la de partida en marcha
	ld a,096h		;53d2   ; ciento cincuenta cuadros
	ld (0e24dh),a		;53d4   ; el plazo del primer paso
	ld hl,053e4h		;53d7   ; el guion de la fase
	ld (0e24eh),hl		;53da   ; y el guion queda apuntado
	ret			;53dd
avanza_el_guion_y_sigue:
	call avanza_el_guion_de_la_fase		;53de
	jp el_cuadro_del_juego		;53e1

; ----------------------------------------------------------------------
; DATOS bloque_53E4: 97 bytes; la primera mitad de lo que 0x53D7 deja apuntado
;   0x53e4..0x5445  (97 bytes)
DATA_bloque_53E4:
	defb 000h,008h,0e0h,001h,020h,004h,022h,014h,015h,004h,022h,010h,015h,008h,022h,018h	; 53e4  .... ."..."...".
	defb 001h,002h,030h,008h,001h,001h,020h,004h,022h,014h,008h,004h,024h,014h,001h,008h	; 53f4  ..0... ."...$...
	defb 022h,018h,008h,008h,024h,018h,020h,008h,022h,018h,008h,008h,024h,014h,014h,004h	; 5404  "...$. ."...$...
	defb 022h,010h,008h,004h,038h,014h,008h,008h,022h,018h,020h,008h,020h,004h,022h,014h	; 5414  "...8...". . .".
	defb 001h,004h,030h,014h,008h,008h,022h,018h,004h,004h,022h,010h,040h,000h,038h,014h	; 5424  ..0..."...".@.8.
	defb 001h,000h,022h,010h,001h,000h,001h,018h,040h,001h,040h,018h,001h,004h,0a0h,014h	; 5434  ..".....@.@.....
	defb 0ffh	; 5444

; ----------------------------------------------------------------------
; DATOS bloque_0x5445: 1266 bytes comprimidos -> 1600 en VRAM (2 tramos:
;   0x2038 0x2300); lo carga 0x60C9
;   0x5445..0x5937  (1266 bytes)
DATA_bloque_0x5445:
	defb 038h,020h,098h,0b0h,0b0h,0b0h,0b8h,09ch,08fh,087h,07bh,06eh,051h,0e1h,041h,0e1h	; 5445  8 ........{nQ.A.
	defb 071h,039h,01dh,00dh,00dh,00dh,01dh,039h,0f1h,0e1h,0deh,004h,000h,003h,0ffh,005h	; 5455  q9.....9........
	defb 000h,084h,0ffh,010h,038h,010h,008h,080h,082h,0ffh,0ffh,00ch,000h,004h,0ffh,012h	; 5465  ....8...........
	defb 003h,084h,007h,03fh,0ffh,0ffh,004h,0c0h,082h,0e0h,0fch,004h,0ffh,00eh,0c0h,088h	; 5475  ...?............
	defb 018h,03ch,07eh,0ffh,07eh,066h,066h,07eh,087h,000h,000h,008h,01ch,03eh,07fh,07fh	; 5485  .<~.~ff~.....>..
	defb 008h,01ch,004h,000h,001h,068h,004h,054h,098h,000h,00fh,01fh,01fh,00fh,007h,003h	; 5495  .....h.T........
	defb 001h,000h,0f0h,0f8h,0f8h,0f0h,0e0h,0c0h,080h,000h,07eh,07eh,0f0h,0f0h,07eh,03ch	; 54a5  ..........~~..~<
	defb 018h,082h,0d3h,091h,008h,080h,083h,084h,0cch,0deh,003h,0ffh,082h,0d7h,093h,008h	; 54b5  ................
	defb 003h,083h,043h,067h,0f7h,003h,007h,0f0h,024h,0ffh,099h,024h,024h,099h,099h,000h	; 54c5  ..Cg....$..$$...
	defb 000h,0ffh,000h,0ffh,081h,081h,081h,000h,024h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh	; 54d5  ........$.......
	defb 000h,0ffh,000h,0ffh,000h,07eh,07eh,07eh,010h,030h,070h,050h,024h,0ffh,099h,000h	; 54e5  .....~~~.0pP$...
	defb 000h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,0c3h,0ffh,099h,000h,099h,099h,066h,07eh	; 54f5  ..............f~
	defb 03ch,018h,03ch,03ch,03ch,07eh,0e7h,000h,009h,009h,006h,00fh,01bh,01bh,019h,01fh	; 5505  <.<<<~..........
	defb 090h,090h,060h,0f0h,0d8h,0d8h,098h,0f8h,00ch,00fh,006h,00fh,009h,009h,006h,01fh	; 5515  ..`.............
	defb 030h,0f0h,060h,0f0h,090h,090h,060h,0f8h,039h,079h,0f5h,093h,0fch,006h,00eh,000h	; 5525  0.`...`.9y......
	defb 09ch,09eh,0afh,0c9h,03fh,060h,070h,000h,090h,018h,081h,024h,05ah,0dbh,0ffh,066h	; 5535  ....?`p....$Z..f
	defb 03ch,076h,08ah,087h,082h,087h,08eh,09ch,0b8h,080h,000h,023h,090h,081h,0e7h,0ffh	; 5545  <v.........#....
	defb 0cfh,09dh,01bh,032h,000h,0ffh,0ffh,0ffh,0cfh,09dh,01bh,032h,000h,008h,0ffh,091h	; 5555  ...2.......2....
	defb 0c1h,0f0h,0f8h,0cfh,09dh,01bh,032h,000h,0ffh,0ffh,0ffh,0cfh,09dh,01bh,032h,000h	; 5565  ......2.......2.
	defb 007h,006h,0e7h,082h,007h,0e0h,006h,0e7h,0a9h,0e0h,0ffh,0ffh,0ffh,0efh,0ddh,099h	; 5575  ................
	defb 000h,0ffh,0aah,099h,0ffh,0aah,0ffh,0ffh,099h,0ffh,0e0h,0e7h,0e7h,0e7h,0e7h,0ffh	; 5585  ................
	defb 0e7h,0e0h,0ffh,0aah,0ffh,099h,0ffh,0ffh,0ffh,0ffh,0f8h,018h,018h,018h,018h,0ffh	; 5595  ................
	defb 018h,0f8h,008h,0ffh,001h,0e0h,006h,0e7h,082h,0e0h,000h,006h,0ffh,082h,000h,007h	; 55a5  ................
	defb 006h,0e7h,001h,007h,008h,0ffh,001h,0e0h,006h,0e7h,082h,0e0h,000h,006h,0ffh,082h	; 55b5  ................
	defb 000h,007h,006h,0e7h,089h,007h,080h,0e0h,0fch,0ffh,0ffh,0ffh,0ffh,055h,007h,0ffh	; 55c5  .............U..
	defb 001h,055h,004h,000h,003h,0ffh,001h,055h,005h,000h,002h,0ffh,082h,055h,01fh,006h	; 55d5  .U.....U.....U..
	defb 018h,082h,01fh,0ffh,006h,000h,082h,0ffh,0f8h,006h,018h,08ch,0f8h,0ffh,0ffh,0ffh	; 55e5  ................
	defb 0ffh,0f8h,0e0h,0c0h,000h,0feh,0f8h,0c0h,005h,000h,09bh,0ffh,0ffh,0ffh,0fch,0f0h	; 55f5  ................
	defb 0e0h,080h,000h,0ffh,0ffh,0ffh,03fh,00fh,007h,001h,000h,0ffh,0ffh,0ffh,0ffh,0ffh	; 5605  ......?.........
	defb 07fh,03fh,000h,07fh,01fh,003h,005h,000h,089h,0ffh,0ffh,0ffh,0ffh,01fh,007h,003h	; 5615  .?..............
	defb 000h,0e0h,005h,0e7h,083h,0c3h,081h,000h,007h,0ffh,001h,007h,005h,0e7h,08ah,0c3h	; 5625  ................
	defb 081h,0feh,0fch,0f8h,0f0h,0e0h,0c0h,002h,009h,008h,0ffh,088h,07fh,03fh,01fh,00fh	; 5635  .............?..
	defb 007h,003h,040h,080h,008h,0d6h,008h,088h,008h,0f8h,082h,01ch,03eh,00dh,07fh,001h	; 5645  ..@.........>...
	defb 0ffh,082h,038h,07ch,00dh,0feh,011h,0ffh,002h,01fh,005h,018h,002h,01fh,006h,018h	; 5655  ..8|............
	defb 002h,01fh,006h,018h,083h,01fh,0ffh,0ffh,005h,000h,08ah,0ffh,000h,0ffh,0ffh,000h	; 5665  ................
	defb 0ffh,0ffh,0ffh,0ffh,000h,006h,0ffh,083h,000h,0f8h,0f8h,005h,018h,002h,0f8h,006h	; 5675  ................
	defb 018h,002h,0f8h,006h,018h,091h,0f8h,010h,01eh,033h,072h,052h,0f7h,0f7h,0f7h,010h	; 5685  .........3rR....
	defb 018h,01ch,014h,010h,030h,070h,050h,004h,0ffh,004h,000h,084h,01fh,00fh,007h,001h	; 5695  ....0pP.........
	defb 004h,000h,005h,0ffh,0d3h,03fh,007h,001h,0f8h,0f0h,0e0h,080h,000h,000h,000h,000h	; 56a5  .....?..........
	defb 0ffh,0ffh,00fh,001h,001h,000h,000h,000h,0ffh,0e0h,0c0h,080h,0fch,0f8h,0f8h,0f8h	; 56b5  ................
	defb 0ffh,0ffh,0c0h,0ffh,0ffh,0fch,0e0h,080h,08ch,086h,083h,083h,0c0h,060h,038h,00fh	; 56c5  .............`8.
	defb 000h,000h,000h,0ffh,000h,000h,000h,0ffh,007h,003h,001h,0f8h,01ch,00ch,004h,004h	; 56d5  ................
	defb 0e0h,0c0h,080h,01fh,030h,060h,040h,04fh,016h,036h,066h,0c6h,006h,00eh,01eh,0fch	; 56e5  ....0`@O.6f.....
	defb 070h,070h,070h,070h,060h,040h,000h,000h,008h,001h,088h,007h,01fh,03fh,00fh,003h	; 56f5  pppp`@.......?..
	defb 080h,080h,0e0h,005h,000h,003h,0ffh,005h,000h,0a3h,03fh,07fh,0ffh,003h,001h,000h	; 5705  ..........?.....
	defb 000h,000h,0f8h,0fch,0feh,0c0h,080h,000h,000h,000h,01fh,03fh,07fh,000h,000h,000h	; 5715  ...........?....
	defb 001h,007h,0feh,0feh,0fch,029h,029h,029h,029h,069h,069h,0e9h,0e9h,008h,070h,084h	; 5725  .....))))ii...p.
	defb 0ffh,0feh,0f8h,0c0h,004h,000h,088h,00fh,007h,003h,001h,000h,0c0h,0e0h,0f0h,010h	; 5735  ................
	defb 000h,090h,005h,013h,04ah,02bh,03fh,016h,016h,01fh,0a0h,0c8h,052h,0d4h,0fch,068h	; 5745  ....J+?.....R..h
	defb 068h,0f8h,010h,000h,0a0h,000h,000h,07fh,080h,07fh,000h,000h,000h,080h,0c7h,0c7h	; 5755  h...............
	defb 0fdh,0c7h,0c7h,080h,0c0h,000h,000h,001h,003h,003h,003h,003h,001h,000h,000h,080h	; 5765  ................
	defb 0c0h,0c0h,0c0h,0c0h,080h,006h,000h,082h,001h,003h,006h,000h,086h,080h,0c0h,003h	; 5775  ................
	defb 003h,003h,001h,004h,000h,003h,0c0h,001h,080h,004h,000h,003h,07eh,007h,000h,08eh	; 5785  ............~...
	defb 001h,003h,003h,003h,003h,001h,000h,000h,080h,0c0h,0c0h,0c0h,0c0h,080h,007h,000h	; 5795  ................
	defb 001h,01fh,007h,000h,085h,0f8h,00fh,00fh,007h,003h,004h,000h,084h,0f0h,0f0h,0e0h	; 57a5  ................
	defb 0c0h,008h,000h,084h,00ch,00fh,006h,00fh,004h,000h,087h,030h,0f0h,060h,0f0h,003h	; 57b5  ...........0.`..
	defb 007h,00eh,005h,000h,083h,0c0h,0e0h,070h,005h,000h,09bh,03eh,078h,060h,0e3h,0c3h	; 57c5  .......p...>x`..
	defb 001h,00fh,03fh,07ch,01eh,006h,0c7h,0c3h,080h,0f0h,0fch,03eh,07fh,070h,0f0h,013h	; 57d5  ..?|.......>.p..
	defb 030h,070h,050h,03eh,078h,0e0h,005h,000h,007h,018h,089h,0f8h,03eh,078h,070h,0f0h	; 57e5  0pP>x.......>xp.
	defb 013h,030h,070h,000h,007h,018h,08bh,01fh,018h,018h,07eh,0e3h,0d1h,091h,091h,0d1h	; 57f5  .0p.......~.....
	defb 07eh,03ch,006h,000h,090h,0dbh,092h,06ch,0feh,029h,045h,093h,0ffh,0dbh,049h,036h	; 5805  ~<.....l.)E...I6
	defb 07fh,094h,0a2h,0c9h,0ffh,002h,0ffh,006h,0c0h,002h,0ffh,006h,003h,088h,000h,038h	; 5815  ...............8
	defb 07ch,0ffh,09fh,06fh,0e6h,0fdh,001h,000h,003h,0dfh,001h,000h,003h,0feh,001h,0ffh	; 5825  |..o............
	defb 003h,020h,001h,0ffh,003h,001h,00ah,066h,087h,03ch,081h,081h,03ch,066h,066h,0ffh	; 5835  . .....f.<..<ff.
	defb 003h,020h,001h,0ffh,003h,001h,001h,0ffh,003h,001h,001h,0ffh,003h,020h,001h,0ffh	; 5845  . ........... ..
	defb 003h,001h,001h,0ffh,003h,020h,087h,000h,000h,00ch,03eh,0ffh,03eh,00ch,005h,000h	; 5855  ..... ....>.>...
	defb 081h,0ffh,005h,000h,086h,07ch,0f8h,0f0h,0f8h,07ch,000h,0e8h,006h,003h,01dh,00eh	; 5865  .....|...|......
	defb 007h,03ah,01dh,00ah,0abh,055h,0aah,055h,07eh,0c3h,081h,081h,060h,0c0h,0b8h,070h	; 5875  .:...U.U~...`..p
	defb 0e0h,05ch,0b8h,050h,000h,0feh,0feh,0feh,000h,0feh,0fch,0fch,000h,000h,000h,008h	; 5885  .\.P............
	defb 000h,000h,0ffh,000h,020h,030h,030h,030h,050h,090h,060h,03fh,03ah,01dh,002h,03dh	; 5895  .... 000P.`?:..=
	defb 00eh,033h,01dh,00ah,03ch,07eh,0dbh,0dbh,0ffh,0dbh,0e7h,07eh,05ch,0b8h,040h,0bch	; 58a5  .3..<~.....~\.@.
	defb 070h,0cch,0b8h,050h,0fch,0fch,0fch,0bdh,0adh,0c9h,0e1h,0f3h,03ch,07eh,0dbh,0dbh	; 58b5  p..P........<~..
	defb 0ffh,0dbh,0e7h,07eh,03fh,03fh,03fh,0bdh,0b5h,093h,087h,0cfh,003h,007h,00fh,00fh	; 58c5  ...~???.........
	defb 00eh,00eh,007h,003h,0bbh,07eh,03ch,018h,018h,018h,099h,099h,0ffh,0c0h,0e0h,0f0h	; 58d5  .....~<.........
	defb 0f0h,070h,070h,0e0h,0c0h,003h,007h,00fh,00fh,00eh,00eh,007h,003h,081h,0c3h,0e7h	; 58e5  .pp.............
	defb 0ffh,0ffh,07eh,07eh,03ch,0c0h,0e0h,0f0h,0f0h,070h,070h,0e0h,0c0h,022h,01dh,017h	; 58f5  ..~~<....pp.."..
	defb 01ch,007h,002h,07eh,03fh,044h,0b8h,0e8h,038h,0e0h,040h,07eh,0fch,00fh,007h,003h	; 5905  ...~?D..8.@~....
	defb 005h,000h,082h,07eh,03ch,005h,018h,084h,0ffh,0f0h,0e0h,0c0h,005h,000h,084h,073h	; 5915  ...~<..........s
	defb 07fh,03fh,01eh,004h,000h,083h,081h,0c3h,0e7h,005h,0ffh,083h,0ceh,0feh,078h,005h	; 5925  .?............x.
	defb 000h,000h	; 5935

; ----------------------------------------------------------------------
; DATOS bloque_5937: 1174 bytes comprimidos
;   0x5937..0x5bcd  (662 bytes)
DATA_bloque_5937:
	defb 008h,000h,008h,011h,008h,022h,008h,033h,008h,044h,008h,0cch,008h,066h,018h,016h	; 5937  .....".3.D...f..
	defb 006h,086h,002h,098h,005h,086h,083h,018h,019h,018h,004h,036h,084h,038h,038h,039h	; 5947  ...........6.889
	defb 038h,040h,063h,004h,0a1h,004h,091h,018h,0f1h,002h,043h,001h,0e3h,005h,043h,002h	; 5957  8@c.......C...C.
	defb 053h,001h,0e3h,005h,053h,002h,043h,001h,0e3h,002h,045h,003h,043h,01dh,064h,003h	; 5967  S...S.C...E.C.d.
	defb 068h,002h,013h,004h,01eh,002h,016h,004h,06eh,084h,0ceh,0c6h,0ceh,0ceh,002h,013h	; 5977  h.......n.......
	defb 006h,0e6h,005h,0e6h,083h,0e3h,063h,0e3h,001h,073h,003h,063h,084h,013h,013h,01eh	; 5987  ......c..s.c....
	defb 006h,008h,06eh,002h,063h,002h,06fh,084h,0f3h,0f3h,0f6h,0a6h,002h,0a6h,002h,096h	; 5997  ..n.c.o.........
	defb 002h,063h,002h,0f3h,003h,0f3h,085h,093h,063h,093h,063h,093h,003h,0f3h,085h,093h	; 59a7  .c......c.c.....
	defb 063h,093h,063h,093h,002h,063h,005h,0f3h,081h,093h,002h,063h,005h,0f3h,081h,093h	; 59b7  c.c..c.....c....
	defb 090h,063h,093h,063h,093h,096h,063h,0f3h,0f3h,063h,093h,063h,093h,096h,063h,0f3h	; 59c7  .c.c..c..c.c..c.
	defb 0f3h,082h,0a3h,031h,006h,091h,008h,016h,080h,000h,003h,003h,0a6h,00dh,0ach,008h	; 59d7  ...1............
	defb 0a0h,003h,0a6h,005h,0ach,008h,0e2h,007h,0efh,081h,02fh,008h,0efh,001h,0f0h,006h	; 59e7  ........../.....
	defb 0e2h,0a1h,0f0h,02eh,02eh,0e0h,02eh,0e0h,0f0h,02eh,0e0h,0efh,02fh,0efh,02fh,0efh	; 59f7  ...........././.
	defb 0f0h,02fh,0efh,0f0h,02eh,0e0h,02eh,0e0h,0f0h,020h,0f0h,0feh,0f2h,0feh,0f2h,0feh	; 5a07  ./....... ......
	defb 0f0h,0f2h,0feh,040h,04fh,007h,0c3h,001h,0ceh,007h,0c0h,001h,0ceh,007h,0c3h,001h	; 5a17  ...@O...........
	defb 0ceh,007h,0c3h,001h,0ceh,018h,0f3h,038h,03ch,018h,0afh,008h,0a6h,008h,060h,008h	; 5a27  .......8<.....`.
	defb 0a6h,010h,089h,008h,086h,00eh,016h,002h,0e6h,00eh,016h,002h,0e6h,010h,000h,005h	; 5a37  ................
	defb 0f6h,003h,0f8h,003h,0f9h,001h,0f8h,003h,0f9h,001h,0f8h,084h,0f9h,0f6h,0f6h,0f6h	; 5a47  ................
	defb 004h,0f3h,005h,0f6h,003h,0f8h,003h,09fh,004h,098h,001h,0f0h,004h,06fh,004h,03fh	; 5a57  .............o.?
	defb 005h,0f6h,003h,0f8h,003h,0f9h,085h,0f8h,0f9h,0f9h,0f9h,0f8h,004h,0f6h,004h,0f3h	; 5a67  ................
	defb 002h,083h,003h,063h,084h,058h,078h,078h,073h,003h,083h,085h,073h,083h,083h,083h	; 5a77  ...c.Xxxs...s...
	defb 090h,007h,063h,008h,063h,001h,090h,00fh,063h,008h,096h,004h,098h,004h,086h,083h	; 5a87  ..c.c...c.......
	defb 090h,086h,086h,005h,063h,028h,089h,010h,096h,005h,068h,003h,098h,010h,086h,002h	; 5a97  ....c(....h.....
	defb 036h,006h,086h,002h,036h,006h,086h,006h,086h,002h,089h,008h,098h,008h,096h,00ch	; 5aa7  6...6...........
	defb 036h,004h,086h,010h,063h,010h,0f3h,001h,053h,002h,0e3h,006h,0f3h,083h,0e3h,073h	; 5ab7  6...c...S......s
	defb 053h,004h,043h,003h,0f3h,001h,0feh,004h,0f3h,085h,0a3h,0a3h,0a6h,0b1h,0a6h,003h	; 5ac7  S.C.............
	defb 0a3h,017h,013h,001h,063h,007h,013h,084h,063h,0e3h,063h,0e3h,005h,063h,083h,0e3h	; 5ad7  ....c...c.c..c..
	defb 063h,0e3h,005h,063h,082h,0e3h,063h,006h,0e3h,003h,063h,085h,0e3h,063h,0e3h,063h	; 5ae7  c..c..c...c..c.c
	defb 0e3h,003h,063h,085h,0e3h,063h,0e3h,063h,0e3h,010h,083h,083h,0e3h,093h,0e3h,005h	; 5af7  ..c..c.c........
	defb 093h,083h,0e3h,093h,0e3h,005h,093h,006h,063h,002h,0f3h,006h,063h,002h,0f3h,002h	; 5b07  ........c...c...
	defb 063h,006h,0f3h,002h,063h,006h,0f3h,002h,0c9h,001h,0c8h,002h,0c6h,003h,036h,002h	; 5b17  c...c.........6.
	defb 0c9h,001h,0c8h,002h,0c6h,003h,036h,002h,0c9h,083h,0c8h,0c6h,0c3h,003h,063h,083h	; 5b27  ......6.......c.
	defb 0c9h,0c6h,0c6h,005h,003h,003h,0f9h,082h,0f8h,0f6h,003h,0f3h,002h,0c9h,08ah,0c8h	; 5b37  ................
	defb 0c6h,0c3h,063h,063h,00fh,0f9h,0f9h,0f8h,0f6h,004h,0f3h,003h,063h,005h,086h,008h	; 5b47  ..cc........c...
	defb 063h,002h,064h,002h,0e4h,004h,04fh,002h,064h,002h,0e4h,004h,04fh,010h,047h,018h	; 5b57  c.d...O.d...O.G.
	defb 0feh,00ah,086h,004h,081h,002h,086h,008h,047h,008h,089h,008h,068h,004h,043h,081h	; 5b67  ........G...h.C.
	defb 0f0h,003h,043h,008h,063h,004h,0f3h,081h,063h,003h,0f3h,00dh,0f8h,003h,0f1h,008h	; 5b77  ..C.c...c.......
	defb 0f8h,005h,086h,003h,081h,003h,098h,085h,081h,091h,091h,096h,091h,007h,0f8h,001h	; 5b87  ................
	defb 081h,008h,0f8h,007h,091h,001h,096h,008h,0f8h,008h,081h,007h,091h,001h,096h,008h	; 5b97  ................
	defb 081h,008h,098h,007h,096h,001h,090h,010h,098h,008h,0d9h,008h,098h,081h,0f8h,005h	; 5ba7  ................
	defb 0f9h,002h,098h,001h,0f8h,005h,0f9h,002h,098h,008h,098h,007h,096h,001h,090h,010h	; 5bb7  ................
	defb 098h,008h,0d9h,008h,098h,000h	; 5bc7

; ----------------------------------------------------------------------
; DATOS volcado_directo_5BCD: 320 bytes a la VRAM sin comprimir; 0x60E4 y
;   0x60E7 entran por 0x5BCD y 0x5BDD
;   0x5bcd..0x5d0d  (320 bytes)
DATA_volcado_directo_5BCD:
	defb 000h,000h,040h,023h,027h,014h,009h,007h,02ch,009h,019h,030h,031h,018h,00ch,000h	; 5bcd  ..@#'...,..01...
	defb 000h,000h,000h,0e0h,0f0h,008h,0f4h,0f8h,00ch,024h,024h,000h,020h,0c0h,000h,000h	; 5bdd  .........$$. ...
	defb 000h,0e0h,0b0h,0d0h,058h,02bh,036h,018h,013h,036h,026h,00fh,00eh,007h,003h,003h	; 5bed  ....X+6..6&.....
	defb 000h,000h,000h,000h,000h,0f0h,008h,004h,0f0h,0d8h,0d8h,0f8h,0d8h,038h,0f0h,0e0h	; 5bfd  .............8..
	defb 004h,006h,006h,007h,007h,000h,007h,007h,003h,000h,000h,000h,000h,000h,000h,000h	; 5c0d  ................
	defb 020h,020h,020h,060h,060h,000h,0e0h,0e0h,0c0h,000h,000h,000h,000h,000h,000h,000h	; 5c1d     ``...........
	defb 003h,019h,039h,078h,0f0h,0e7h,000h,000h,00ch,03eh,03ch,038h,01eh,000h,000h,000h	; 5c2d  ..9x.....><8....
	defb 0c0h,0d8h,0dch,09fh,087h,0e0h,000h,010h,030h,03ah,03eh,01eh,018h,000h,000h,000h	; 5c3d  ........0:>.....
	defb 00bh,019h,01ch,01ch,00fh,000h,000h,000h,00fh,00fh,00bh,003h,000h,000h,000h,000h	; 5c4d  ................
	defb 0e0h,0c0h,0c0h,0d0h,0f8h,018h,000h,000h,0c0h,080h,0c0h,0e0h,000h,000h,000h,000h	; 5c5d  ................
	defb 000h,00eh,00eh,00ch,00ch,00fh,007h,006h,000h,003h,003h,003h,003h,000h,000h,000h	; 5c6d  ................
	defb 0c0h,060h,060h,060h,060h,0f8h,008h,000h,000h,0c0h,0c0h,0e0h,0f0h,000h,000h,000h	; 5c7d  .````...........
	defb 007h,001h,001h,003h,003h,000h,000h,001h,003h,000h,000h,000h,000h,000h,000h,000h	; 5c8d  ................
	defb 020h,090h,090h,090h,090h,000h,0f0h,0f0h,0e0h,000h,000h,000h,000h,000h,000h,000h	; 5c9d   ...............
	defb 003h,019h,039h,071h,061h,007h,018h,0f8h,0fch,0c0h,080h,000h,000h,000h,000h,000h	; 5cad  ..9qa...........
	defb 0c3h,0dbh,09fh,09eh,08ch,0e0h,011h,01bh,03fh,01fh,006h,000h,000h,000h,000h,000h	; 5cbd  ........?.......
	defb 003h,000h,006h,000h,00ch,000h,00ch,000h,00ch,001h,00dh,001h,00ch,000h,019h,034h	; 5ccd  ...............4
	defb 080h,000h,0c0h,000h,060h,000h,060h,000h,0f8h,024h,054h,024h,0f8h,000h,004h,0f8h	; 5cdd  ....`.`..$T$....
	defb 000h,000h,000h,000h,000h,001h,006h,000h,018h,000h,030h,000h,060h,000h,040h,0a0h	; 5ced  ..........0.`.@.
	defb 000h,000h,000h,000h,000h,000h,0c0h,000h,030h,000h,038h,03eh,049h,055h,049h,03eh	; 5cfd  ........0.8>IUI>

; ----------------------------------------------------------------------
; DATOS bloque_0x5D0D: 956 bytes comprimidos -> 1248 en VRAM (1 tramos:
;   0x1B00); lo carga 0x6125
;   0x5d0d..0x60c9  (956 bytes)
DATA_bloque_0x5D0D:
	defb 000h,01bh,009h,000h,001h,066h,005h,029h,001h,026h,009h,000h,001h,030h,005h,048h	; 5d0d  .....f.).&...0.H
	defb 001h,030h,009h,000h,087h,071h,08ah,08ah,012h,022h,042h,0f9h,009h,000h,001h,08ch	; 5d1d  .0...q..."B.....
	defb 005h,052h,081h,08ch,008h,000h,088h,040h,079h,042h,042h,07ah,00ah,04ah,079h,009h	; 5d2d  .R.....@yBBz.Jy.
	defb 000h,001h,08ch,005h,052h,081h,08ch,009h,000h,087h,031h,072h,0d2h,092h,0fah,012h	; 5d3d  ....R.....1r....
	defb 011h,009h,000h,001h,08ch,005h,052h,081h,08ch,009h,000h,087h,001h,005h,00fh,00dh	; 5d4d  ......R.........
	defb 00fh,00dh,00eh,00ah,000h,086h,0a0h,0f0h,0b0h,0f0h,0b0h,070h,003h,000h,089h,001h	; 5d5d  ...........p....
	defb 003h,003h,000h,000h,006h,007h,007h,003h,004h,000h,08ch,007h,039h,071h,0f1h,0e1h	; 5d6d  ............9q..
	defb 081h,00fh,00fh,078h,0f8h,0fch,0f8h,004h,000h,08ch,0e0h,09ch,08eh,08fh,087h,081h	; 5d7d  ...x............
	defb 0f0h,0f0h,01eh,01fh,03fh,01fh,007h,000h,089h,080h,0c0h,0c0h,000h,000h,060h,0e0h	; 5d8d  ....?.........`.
	defb 0e0h,0c0h,004h,000h,010h,000h,090h,03fh,079h,0f1h,0e1h,0e1h,071h,03fh,01fh,008h	; 5d9d  .......?y...q?..
	defb 018h,03ch,03eh,01ch,01ch,03ch,07dh,009h,000h,087h,071h,08ah,082h,0f2h,08ah,08ah	; 5dad  .<>..<}...q.....
	defb 071h,009h,000h,081h,08ch,005h,052h,081h,08ch,009h,000h,087h,062h,095h,015h,025h	; 5dbd  q.....R.....b..%
	defb 015h,095h,062h,009h,000h,001h,022h,005h,055h,081h,022h,009h,000h,087h,062h,095h	; 5dcd  ..b...".U."...b.
	defb 095h,015h,065h,085h,0f2h,009h,000h,001h,022h,005h,055h,081h,022h,009h,000h,001h	; 5ddd  ..e.....".U."...
	defb 064h,005h,02ah,081h,024h,009h,000h,001h,044h,005h,0aah,081h,044h,004h,000h,088h	; 5ded  d.*.$...D...D...
	defb 001h,006h,00fh,007h,00fh,00bh,007h,002h,008h,000h,0b9h,0c0h,0c0h,0e0h,0e0h,0f0h	; 5dfd  ................
	defb 0f0h,0d0h,0e0h,0c0h,000h,000h,000h,006h,00dh,01eh,02fh,037h,07fh,07fh,07fh,03fh	; 5e0d  ........../7...?
	defb 06fh,07fh,0ffh,0ffh,0b5h,07bh,034h,030h,078h,0bch,0fch,0fah,0ffh,0ffh,0feh,0f4h	; 5e1d  o....{40x.......
	defb 0feh,0ffh,0ffh,0ffh,0fah,0bch,078h,000h,000h,01bh,037h,07fh,03fh,0ffh,0ffh,05fh	; 5e2d  ......x...7.?.._
	defb 03fh,01fh,00fh,007h,005h,000h,0aeh,01ch,0beh,0ffh,0ffh,0f3h,0e9h,0edh,0f3h,0feh	; 5e3d  ?...............
	defb 0f5h,07bh,07fh,03eh,01ch,000h,000h,070h,0f8h,0fdh,0ffh,0cfh,097h,0b7h,0cfh,07fh	; 5e4d  .{.>...p........
	defb 0afh,0dfh,07eh,038h,000h,000h,000h,018h,0bch,0feh,0feh,0ffh,0ffh,0ffh,0feh,0f4h	; 5e5d  ..~8............
	defb 0b8h,050h,000h,000h,000h,084h,000h,000h,001h,003h,00ch,007h,084h,000h,000h,0c0h	; 5e6d  .P..............
	defb 0e0h,00ch,0f0h,090h,0fch,09eh,08fh,087h,087h,08eh,0fch,0f8h,010h,018h,03ch,07ch	; 5e7d  ..............<|
	defb 038h,038h,03ch,03eh,010h,000h,082h,000h,006h,004h,00eh,002h,000h,083h,007h,007h	; 5e8d  88<>............
	defb 003h,006h,000h,081h,060h,004h,070h,002h,000h,083h,0e0h,0e0h,0c0h,005h,000h,007h	; 5e9d  ....`.p.........
	defb 000h,089h,003h,007h,01fh,01eh,01dh,01fh,00ch,00fh,007h,007h,000h,089h,0c0h,0e0h	; 5ead  ................
	defb 0f8h,038h,0f8h,0b8h,070h,0f0h,0e0h,0a0h,000h,000h,060h,0f0h,0f9h,0fbh,073h,077h	; 5ebd  .8..p.....`...sw
	defb 079h,07eh,03ch,03dh,01fh,019h,001h,001h,002h,00ah,00ah,002h,08ch,0fch,0feh,0feh	; 5ecd  y~<=............
	defb 09eh,07eh,03eh,0bch,0fch,098h,080h,080h,004h,000h,09ch,019h,03fh,07fh,07fh,07dh	; 5edd  .~>.........?..}
	defb 07bh,07eh,03dh,03fh,019h,001h,001h,002h,002h,006h,00fh,09fh,0dfh,0ceh,0eeh,0beh	; 5eed  {~=?............
	defb 0deh,07ch,0bch,0f8h,098h,080h,080h,005h,000h,082h,007h,00fh,007h,01fh,08bh,00fh	; 5efd  .|..............
	defb 007h,000h,000h,000h,004h,004h,0e4h,0f4h,0f8h,0fch,005h,0f8h,082h,0f0h,0e0h,088h	; 5f0d  ................
	defb 007h,00fh,00fh,00fh,000h,007h,007h,003h,008h,000h,088h,0e0h,0f0h,0f0h,0f0h,000h	; 5f1d  ................
	defb 0e0h,0e0h,0c0h,008h,000h,005h,000h,09bh,010h,01fh,0afh,0e0h,060h,0e0h,0f0h,0f8h	; 5f2d  ............`...
	defb 078h,030h,000h,002h,00ah,00ah,002h,004h,00ch,0f8h,0f0h,000h,000h,000h,00ch,01eh	; 5f3d  x0..............
	defb 01eh,00eh,00ch,088h,000h,07fh,0f8h,0f8h,07ch,01ch,078h,0f8h,009h,000h,08bh,0f0h	; 5f4d  ........|.x.....
	defb 010h,018h,038h,078h,07ch,03ch,01ch,01ch,01eh,01fh,004h,000h,005h,000h,09bh,010h	; 5f5d  ..8x|<..........
	defb 01fh,00fh,000h,000h,000h,018h,078h,078h,070h,030h,002h,00ah,00ah,002h,004h,008h	; 5f6d  ......xxp0......
	defb 0f8h,0f5h,007h,006h,007h,00fh,01fh,01eh,00ch,000h,08ch,000h,00fh,008h,018h,01ch	; 5f7d  ................
	defb 01eh,03eh,03ch,038h,038h,078h,0f8h,005h,000h,087h,0feh,01fh,01fh,03eh,038h,01eh	; 5f8d  .><88x.......>8.
	defb 01fh,008h,000h,08ch,000h,000h,001h,001h,010h,001h,003h,000h,002h,000h,003h,002h	; 5f9d  ................
	defb 004h,000h,08ch,004h,004h,084h,084h,008h,084h,0c0h,000h,040h,000h,0c0h,040h,004h	; 5fad  ...........@..@.
	defb 000h,090h,000h,01fh,01eh,00eh,00fh,01eh,01ch,03fh,03dh,03fh,03ch,03dh,01fh,019h	; 5fbd  .........?=?<=..
	defb 011h,001h,090h,002h,0fah,07ah,072h,0f4h,078h,038h,0f8h,0bch,0fch,03ch,0bch,0f8h	; 5fcd  .....zr.x8...<..
	defb 098h,088h,080h,005h,000h,09bh,010h,01fh,00fh,020h,060h,0e0h,0f0h,0f8h,078h,030h	; 5fdd  ......... `...x0
	defb 0c0h,002h,00ah,00ah,00ah,004h,008h,0f8h,0f0h,004h,006h,007h,00fh,01fh,01eh,00ch	; 5fed  ................
	defb 003h,089h,0f0h,07fh,078h,038h,01ch,00eh,006h,006h,002h,007h,000h,089h,00fh,0feh	; 5ffd  ....x8..........
	defb 01eh,01ch,038h,070h,060h,060h,040h,007h,000h,08ch,000h,000h,007h,00fh,000h,01fh	; 600d  ..8p``@.........
	defb 01ch,008h,00ah,000h,002h,001h,006h,000h,08ah,0e0h,0f0h,000h,0f8h,038h,010h,050h	; 601d  .............8.P
	defb 000h,040h,080h,004h,000h,0a0h,000h,078h,070h,070h,0ffh,0e0h,0e3h,0f7h,0f5h,07fh	; 602d  .@.....xpp......
	defb 07dh,03eh,03fh,019h,011h,001h,000h,01eh,00eh,00eh,0ffh,007h,0c7h,0efh,0afh,0feh	; 603d  }>?.............
	defb 0beh,07ch,0fch,098h,088h,080h,020h,000h,082h,001h,003h,003h,000h,09bh,010h,03fh	; 604d  .|.... ........?
	defb 02fh,060h,060h,060h,070h,038h,018h,010h,000h,082h,0cah,00ah,002h,004h,008h,0fch	; 605d  /```p8..........
	defb 0f4h,006h,006h,006h,00eh,01ch,01ch,008h,000h,08ch,000h,00fh,018h,038h,03ch,01eh	; 606d  .............8<.
	defb 01ch,00eh,00eh,007h,003h,003h,005h,000h,08bh,0f0h,018h,01ch,03ch,078h,038h,070h	; 607d  ............<x8p
	defb 070h,0e0h,0c0h,0c0h,004h,000h,09eh,003h,006h,00ch,01fh,003h,007h,00fh,01eh,03fh	; 608d  p..............?
	defb 07fh,0ffh,00fh,01fh,03fh,07fh,0feh,000h,000h,000h,0e0h,0c0h,080h,000h,000h,0fch	; 609d  ....?...........
	defb 0f8h,0f0h,0e0h,0c0h,080h,002h,000h,083h,008h,008h,00ch,006h,00fh,001h,003h,006h	; 60ad  ................
	defb 000h,083h,010h,010h,030h,006h,0f0h,001h,0c0h,006h,000h,000h	; 60bd  ....0.......

; ======================================================================
; CODIGO 0x60c9..0x617a  (177 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL MONTAJE GRAFICO DE LA FASE: cuatro bloques comprimidos y, en medio, el bucle de 0x60F0, que coge los 320 bytes de patrones de sprite de 0x5BCD y los DA LA VUELTA como en un espejo, dejando el resultado en 0x1940. Son diez tandas de 0x20 bytes -diez sprites de 16x16-, y el cartucho se ahorra asi guardar cada figura mirando a los dos lados.
; ----------------------------------------------------------------------
monta_los_graficos:
	ld hl,05445h		;60c9   ; el primer bloque comprimido
	call descomprime		;60cc
	ld hl,05937h		;60cf   ; el segundo
	call descomprime_con_mascara_de_color		;60d2
	call duplica_las_dos_tablas		;60d5   ; repartido a los tres tercios
	ld de,01800h		;60d8
	ld hl,05bcdh		;60db
	ld bc,00140h		;60de   ; 320 bytes sin comprimir
	call vuelca_bloque		;60e1
	ld de,05bcdh		;60e4   ; los patrones que hay que girar
	ld hl,05bddh		;60e7
	ld b,00ah		;60ea   ; diez tandas
	ld ix,0e0b0h		;60ec   ; el bufer de salida
L_60F0:
	push bc			;60f0
	ld b,010h		;60f1   ; dieciseis filas por sprite
saca_una_fila_a_dar_la_vuelta:
	ld a,(de)			;60f3   ; el byte de origen
	exx			;60f4
	ld h,a			;60f5
	exx			;60f6
	ld a,(hl)			;60f7   ; y el del bufer
	exx			;60f8
	ld l,a			;60f9
	ld b,010h		;60fa
da_la_vuelta_a_una_fila:
	add hl,hl			;60fc   ; el bit de mas peso de la fila, al acarreo
	rr (ix+000h)		;60fd   ; y entra por la izquierda de los dos bytes de salida
	rr (ix+010h)		;6101   ; que juntos son un registro de dieciseis bits
	djnz da_la_vuelta_a_una_fila		;6105   ; dieciseis vueltas: la fila entera
	exx			;6107   ; al juego alternativo
	inc hl			;6108   ; la fila siguiente
	inc de			;6109
	inc ix		;610a   ; y el byte de salida
	djnz saca_una_fila_a_dar_la_vuelta		;610c
	ld c,010h		;610e   ; y dieciseis mas, que con los que ya avanzo el bucle son 0x20 por tanda
	add hl,bc			;6110   ; y de tanda en tanda
	ex de,hl			;6111   ; se cambian
	add hl,bc			;6112
	ex de,hl			;6113   ; y de vuelta
	add ix,bc		;6114
	pop bc			;6116   ; se recupera
	djnz L_60F0		;6117
	ld de,01940h		;6119   ; el destino: 0x1940, cuarenta patrones despues de 0x1800
	ld hl,0e0b0h		;611c   ; el bufer donde se dio la vuelta
	ld bc,00140h		;611f   ; 320 bytes
	call vuelca_bloque		;6122   ; el resultado, a la VRAM
	ld hl,05d0dh		;6125   ; y el ultimo bloque
	call descomprime		;6128
	ret			;612b
descomprime_con_mascara_de_color:
	ld e,(hl)			;612c   ; el destino de VRAM, delante del bloque
	inc hl			;612d
	ld d,(hl)			;612e
	inc hl			;612f
	ld a,(0e05dh)		;6130   ; la mascara de color de esta fase
	ld c,a			;6133
	di			;6134
	call prepara_escritura_vram		;6135
	ld a,c			;6138
	and 0f0h		;6139
	ld d,a			;613b
	ld a,c			;613c
	and 00fh		;613d
	ld e,a			;613f
descomprime_con_mascara:
	ld a,(hl)			;6140
	and 07fh		;6141   ; los siete bits de abajo: la cuenta
	ld b,a			;6143
	ld a,(hl)			;6144   ; y el byte entero, para el bit 7
	inc hl			;6145
	jr nz,L_614D		;6146
	cp b			;6148   ; cuenta cero: fin o cambio de destino
	jr nz,descomprime_con_mascara_de_color		;6149
	ei			;614b
	ret			;614c
L_614D:
	cp b			;614d
L_614E:
	ex af,af'			;614e
	ld a,0f0h		;614f   ; el nibble alto
	and (hl)			;6151
	cp 030h		;6152   ; el valor 0x30
	jr nz,L_6157		;6154
	ld a,d			;6156
L_6157:
	ld c,a			;6157
	ld a,00fh		;6158   ; el nibble bajo
	and (hl)			;615a
	cp 003h		;615b   ; el valor 3
	jr nz,L_6160		;615d
	ld a,e			;615f
L_6160:
	or c			;6160   ; el par de bits, junto
	exx			;6161
	out (c),a		;6162   ; y al puerto de datos
	exx			;6164
	ex af,af'			;6165
	jr z,L_6169		;6166
	inc hl			;6168
L_6169:
	djnz L_614E		;6169
	jr nz,L_616E		;616b
	inc hl			;616d
L_616E:
	jr descomprime_con_mascara		;616e
mira_el_contacto_del_jugador:
	ld a,(0e1b2h)		;6170
	ld hl,061a0h		;6173
	push hl			;6176
	call despacha_por_tabla		;6177

; ----------------------------------------------------------------------
; DATOS tabla_617A: 19 entradas; cierra en 0x61A0, y el `ld hl,061a0h / push
;   hl` de 0x6173 lo confirma por otro camino
;   0x617a..0x61a0  (38 bytes)
DATA_tabla_617A:
	defw 061bfh,0630bh,061e4h,0630bh,063c3h,063e1h,06957h,06a4fh	; 617a
	defw 0732ah,0734bh,0737ah,0737ah,07395h,07427h,07446h,07466h	; 618a
	defw 074f8h,07534h,07541h	; 619a  -> estado_15_espera_larga estado_16_plazo_de_32 estado_17_reinicia

; ======================================================================
; CODIGO 0x61a0..0x61de  (62 bytes)
; ======================================================================


L_61A0:
	jp mete_al_jugador_en_los_sprites		;61a0

; ----------------------------------------------------------------------
; LEER DE LA VRAM LAS DOS CELDAS QUE HAY BAJO EL JUGADOR, para saber sobre que esta. En vez de llevar un mapa en RAM, el cartucho PREGUNTA A LA PANTALLA: convierte la posicion en celda y se trae los dos indices de patron a 0xE1BF.
; ----------------------------------------------------------------------
lee_las_dos_celdas_de_debajo:
	ld hl,(0e1b3h)		;61a3   ; la posicion del jugador
	ld bc,00408h		;61a6   ; desplazada a los pies
	add hl,bc			;61a9
	call posicion_a_celda		;61aa   ; convertida en celda de pantalla
	ld hl,0e1bfh		;61ad   ; donde se guarda lo leido
	ld b,002h		;61b0   ; dos celdas
L_61B2:
	call lee_de_vram		;61b2   ; y se leen de la propia VRAM
	ld (hl),a			;61b5
	inc hl			;61b6
	ld a,020h		;61b7   ; la de abajo, 32 celdas mas alla
	call suma_a_a_de		;61b9
	djnz L_61B2		;61bc
	ret			;61be
mira_si_agarra:
	call elige_el_paso_del_dibujo		;61bf
	call se_acaba_de_pulsar_direccion		;61c2
	jp nz,estado_3		;61c5
	ld a,(0e009h)		;61c8   ; lo que se esta pulsando
	rra			;61cb   ; el bit 0
	ret nc			;61cc
	call mira_los_objetos_de_cerca		;61cd
	ret nc			;61d0
	call busca_en_la_lista_de_agarres		;61d1
	ret nc			;61d4
	ld a,(0e1d1h)		;61d5
	cp 00ah		;61d8   ; el valor 10 es el que cuenta
	ret nz			;61da
	jp pasa_al_estado_6		;61db

; ----------------------------------------------------------------------
; DATOS sonidos_por_tipo: seis bytes, uno por tipo de objeto; 0x627B resta
;   0xC5 al tipo y 0x627D indexa aqui
;   0x61de..0x61e4  (6 bytes)
DATA_sonidos_por_tipo:
	defb 001h,002h,003h,005h,006h,007h	; 61de

; ======================================================================
; CODIGO 0x61e4..0x6571  (909 bytes)
; ======================================================================


mira_si_sube:
	call mira_si_llego_a_la_marca		;61e4
	jp nc,estado_4_con_sonido		;61e7
	ld a,(0e009h)		;61ea   ; lo que se esta pulsando
	and 00ch		;61ed   ; los dos bits de direccion
	jp z,sigue_el_cuadro_del_jugador		;61ef
	ld hl,0e134h		;61f2
	ld b,028h		;61f5   ; cuarenta objetos

; ----------------------------------------------------------------------
; EL BARRIDO DE LOS CUARENTA OBJETOS, tres bytes cada uno desde 0xE134. Para que uno cuente tiene que cumplir TRES cosas: que su tipo este entre 0xC5 y 0xCA, que no este marcado como retirado (0xD0), y que caiga dentro de la caja -0x18 en una coordenada y 0x10 en la otra-. El primero que cumple corta el bucle.
; ----------------------------------------------------------------------
busca_a_que_se_agarra:
	push bc			;61f7   ; se guardan los dos
	push hl			;61f8
	ld a,(hl)			;61f9   ; el tipo
	sub 0c5h		;61fa   ; el tipo, desde 0xC5
	cp 006h		;61fc   ; seis tipos validos
	jr nc,L_6219		;61fe   ; fuera de rango: ese no se agarra
	dec hl			;6200
	dec hl			;6201   ; dos bytes atras
	ld a,(hl)			;6202   ; la columna
	cp 0d0h		;6203   ; 0xD0: retirado, no cuenta
	jr z,L_6219		;6205   ; retirado: tampoco
	ld bc,(0e1b3h)		;6207   ; la posicion del jugador
	sub c			;620b   ; menos la columna del objeto
	cp 018h		;620c   ; veinticuatro pixeles
	jr nc,L_6219		;620e   ; fuera de alcance
	inc hl			;6210   ; el byte siguiente
	ld a,(hl)			;6211   ; la fila del objeto
	add a,008h		;6212   ; ocho de desplazamiento
	sub b			;6214   ; menos la del jugador
	cp 010h		;6215   ; y dieciseis en la otra
	jr c,agarra_el_objeto		;6217   ; y si cabe, se agarra
L_6219:
	pop hl			;6219   ; se recuperan
	pop bc			;621a
	inc hl			;621b   ; tres bytes por objeto
	inc hl			;621c
	inc hl			;621d
	djnz busca_a_que_se_agarra		;621e
	jp sigue_el_cuadro_del_jugador		;6220

; ----------------------------------------------------------------------
; AGARRARSE A UN OBJETO. Lo marca como retirado poniendole 0xD0 y, si su tipo es de los tres primeros, descuenta uno de (0xE05F); si no, calcula su celda en pantalla para repintarlo.
; ----------------------------------------------------------------------
agarra_el_objeto:
	pop hl			;6223   ; se recuperan los dos
	pop bc			;6224
	dec hl			;6225   ; dos bytes atras
	dec hl			;6226
	push hl			;6227   ; y se guarda
	call repinta_el_objeto		;6228   ; lo apunta como agarrado
	pop hl			;622b   ; se recupera
	ld c,(hl)			;622c   ; su columna
	ld (hl),0d0h		;622d   ; 0xD0: retirado
	inc hl			;622f   ; el byte siguiente
	ld b,(hl)			;6230   ; la fila
	inc hl			;6231
	ld a,(hl)			;6232   ; y el tipo
	ld d,a			;6233   ; guardado en D
	sub 0c5h		;6234   ; los tres primeros tipos
	cp 003h		;6236   ; tienen que caber en tres
	ld a,d			;6238   ; el tipo otra vez
	jr nc,L_6241		;6239   ; los demas, por el otro camino
	ld hl,0e05fh		;623b   ; el contador de objetos
	dec (hl)			;623e   ; uno menos en el contador
	jr L_627B		;623f   ; y se sigue
L_6241:
	push af			;6241   ; se guardan
	push bc			;6242
	ld b,a			;6243   ; el tipo, en B
	ld de,(0e05ah)		;6244   ; la referencia del decorado
	ld a,0b8h		;6248   ; el patron
	sub c			;624a   ; la distancia
	and 0f8h		;624b   ; redondeada a ocho
	rrca			;624d   ; tres giros: la celda
	rrca			;624e
	rrca			;624f
	ld c,a			;6250

; ----------------------------------------------------------------------
; BUSCAR EL OBJETO EN LA PANTALLA PARA BORRARLO. Recorre la VRAM de tres en tres celdas leyendo indices hasta dar con el que coincide, y entonces escribe el 0xCB encima. Otra vez la pantalla haciendo de mapa: el cartucho no lleva una copia en RAM.
; ----------------------------------------------------------------------
	ld a,(0e059h)		;6251   ; la referencia
	add a,c			;6254
L_6255:
	ex af,af'			;6255
	call lee_de_vram		;6256   ; lee la celda de la VRAM
	ld c,a			;6259
	ex af,af'			;625a
	sub c			;625b   ; la compara con lo que busca
	jr z,L_6263		;625c
	inc de			;625e   ; tres celdas mas alla
	inc de			;625f
	inc de			;6260
	jr L_6255		;6261
L_6263:
	inc de			;6263
	call lee_de_vram		;6264
	cp b			;6267
	jr nz,L_6271		;6268
	ld a,0cbh		;626a   ; el patron que deja el hueco vacio
	call escribe_en_vram		;626c
	jr L_6279		;626f
L_6271:
	inc de			;6271
	inc de			;6272
	call lee_de_vram		;6273   ; y si es cero, se sigue buscando
	or a			;6276
	jr z,L_6263		;6277
L_6279:
	pop bc			;6279
	pop af			;627a
L_627B:
	sub 0c5h		;627b   ; el tipo, desde 0xC5
	ld hl,061deh		;627d   ; la lista de sonidos por tipo
	call suma_a_a_hl		;6280
	ld a,(hl)			;6283
	call suma_los_puntos_del_tipo		;6284   ; y suena el que toque
sigue_el_cuadro_del_jugador:
	call elige_el_paso_del_dibujo		;6287   ; el paso del dibujo
	call se_acaba_de_pulsar_direccion		;628a   ; mira si se cae
	jr nz,estado_3		;628d   ; con direccion, se cae
	call se_acaba_de_pulsar_boton		;628f   ; y si hay suelo debajo
	ret z			;6292   ; sin boton no se agarra
	push af			;6293   ; se guarda lo pulsado
	call mira_los_objetos_de_cerca		;6294   ; mira si agarra
	jr nc,estado_5_cayendo		;6297   ; si no hay nada cerca, cae
	call busca_en_la_lista_de_agarres		;6299   ; y se busca en la lista
	jr nc,estado_5_cayendo		;629c   ; tampoco: cae
	pop af			;629e   ; se recupera
	rra			;629f   ; el bit 0 de lo que se pulsa
	jr c,mira_la_celda_de_al_lado		;62a0   ; con acarreo, mira la celda de al lado
	ld a,(0e1d9h)		;62a2   ; la altura a la que se llego
	ld hl,0e1b3h		;62a5   ; la del jugador
	sub (hl)			;62a8   ; la diferencia
	cp 024h		;62a9   ; treinta y seis de margen
	jr nc,L_62D3		;62ab   ; fuera de margen: no rehace nada
	call rehace_la_pantalla		;62ad   ; se rehace la pantalla
pasa_al_estado_6:
	ld a,006h		;62b0   ; el paso, a seis
	ld (0e1b5h),a		;62b2
	ld a,006h		;62b5   ; y estado 6
	jp pasa_al_estado		;62b7
mira_la_celda_de_al_lado:
	ld hl,(0e1b3h)		;62ba   ; la posicion del jugador
	ld a,l			;62bd
	sub 008h		;62be   ; ocho a un lado
	ld l,a			;62c0
	ld a,h			;62c1
	add a,004h		;62c2   ; y cuatro al otro
	ld h,a			;62c4
	call lee_la_celda_de_ahi		;62c5   ; que hay ahi
	sub 078h		;62c8   ; el patron 0x78
	cp 003h		;62ca   ; y los dos siguientes
	jr c,pasa_al_estado_6		;62cc
	ret			;62ce
estado_5_cayendo:
	pop af			;62cf
	bit 1,a		;62d0   ; el bit 1
	ret z			;62d2
L_62D3:
	call rehace_la_pantalla		;62d3
	ld a,005h		;62d6   ; estado 5
	jp pasa_al_estado		;62d8
estado_3:
	ld hl,06572h		;62db   ; el guion del jugador
L_62DE:
	call arranca_gesto_con_sonido		;62de
	ld a,003h		;62e1   ; estado 3
	jp pasa_al_estado		;62e3
estado_4_con_sonido:
	ld hl,06572h		;62e6
	call arranca_gesto		;62e9
	ld a,005h		;62ec   ; el sonido de este estado
	call pide_un_sonido		;62ee
	ld a,004h		;62f1   ; estado 4
	jp pasa_al_estado		;62f3
rehace_la_pantalla:
	ld b,004h		;62f6
L_62F8:
	push bc			;62f8
	ld a,008h		;62f9   ; el patron de partida
	call mueve_al_jugador		;62fb
	call mete_al_jugador_en_los_sprites		;62fe   ; monta el decorado
	call vuelca_los_sprites		;6301
	call mira_si_puede_subir		;6304
	pop bc			;6307
	djnz L_62F8		;6308
	ret			;630a
estado_1:
	call avanza_el_gesto_dos		;630b   ; mira el suelo
	call hay_suelo_debajo		;630e
	jr z,se_engancha		;6311
	ld a,(0e1c7h)		;6313   ; la bandera de 0xE1C7
	or a			;6316
	jr z,mira_si_puede_bajar		;6317
	call mira_si_puede_subir		;6319
	ld hl,(0e1b3h)		;631c   ; la posicion del jugador
	ld bc,00018h		;631f   ; veinticuatro por debajo
	add hl,bc			;6322
	call mira_los_cuarenta_objetos		;6323
	jr nc,mira_si_llego_al_suelo		;6326
	ld a,002h		;6328   ; el sonido de agarrarse
	call pide_un_sonido		;632a
	ld a,(0e1c8h)		;632d   ; el bit 7 de 0xE1C8
	or a			;6330
	jp m,compara_con_la_altura		;6331
L_6334:
	ld a,(0e1cbh)		;6334
	sub 020h		;6337   ; treinta y dos hacia arriba
	call sube_al_jugador		;6339
	call sube_hasta_la_fila_48		;633c
	ld a,002h		;633f   ; estado 2
	jp pasa_al_estado		;6341

; ----------------------------------------------------------------------
; COMPARAR CON LA ALTURA ALCANZADA, con dos restas encadenadas de 16 bits: la marca menos la altura del jugador menos 0x80. Si sale acarreo, todavia no ha llegado.
; ----------------------------------------------------------------------
compara_con_la_altura:
	ld bc,(0e054h)		;6344   ; la marca
	ld hl,(0e1bah)		;6348   ; la altura del jugador
	sbc hl,bc		;634b
	ld bc,00080h		;634d   ; y ochenta mas de margen
	sbc hl,bc		;6350
	jr c,L_6334		;6352
	ld a,004h		;6354   ; estado 4
	jp pasa_al_estado		;6356
mira_si_llego_al_suelo:
	ld hl,0e1b3h		;6359
	ld a,098h		;635c   ; el suelo esta en 0x98
	sub (hl)			;635e
	ret nc			;635f   ; si aun no ha llegado, nada
	call mueve_al_jugador		;6360
	ld a,000h		;6363   ; estado 0
	jp pasa_al_estado		;6365

; ----------------------------------------------------------------------
; SUBIR HASTA LA FILA 0x48, de ocho en ocho: es el tope por arriba de la pantalla de juego.
; ----------------------------------------------------------------------
sube_hasta_la_fila_48:
	ld a,(0e1b3h)		;6368
	cp 048h		;636b   ; el tope
	ret nc			;636d
	call baja_un_tramo		;636e   ; un tramo mas
	jr sube_hasta_la_fila_48		;6371
se_engancha:
	call sube_hasta_la_fila_48		;6373
	ld a,002h		;6376   ; el sonido de engancharse
	call pide_un_sonido		;6378
	ld hl,0e1b4h		;637b
	ld a,(hl)			;637e
	add a,004h		;637f   ; la posicion, redondeada a ocho
	and 0f8h		;6381   ; alineada
	sub 004h		;6383   ; y descontando cuatro
	ld (hl),a			;6385
	inc hl			;6386
	ld (hl),00ah		;6387   ; el paso, a diez
	ld a,007h		;6389   ; estado 7
	jp pasa_al_estado		;638b

; ----------------------------------------------------------------------
; MIRAR SI PUEDE BAJAR. Tres condiciones: que el desfase de (0xE1BE) sea de al menos cinco, que la posicion este entre 0x48 y 0x50, y que el bit 0 de (0xE1AB) no este puesto.
; ----------------------------------------------------------------------
mira_si_puede_bajar:
	ld a,(0e1beh)		;638e
	neg		;6391   ; el desfase, en positivo
	cp 005h		;6393   ; al menos cinco
	ret c			;6395
baja_si_puede:
	ld hl,0e1b3h		;6396
	ld a,048h		;6399   ; el tope de arriba
	sub (hl)			;639b
	ret c			;639c
	cp 008h		;639d   ; ocho de margen
	ret c			;639f
	ld a,(0e1abh)		;63a0
	rra			;63a3   ; el bit 0 lo impide
	ret c			;63a4
	ld a,(hl)			;63a5
	add a,008h		;63a6   ; y baja ocho
	ld (hl),a			;63a8
	jp marca_movimiento_abajo		;63a9

; ----------------------------------------------------------------------
; LO MISMO PARA SUBIR: entre 0x88 y 0x90, y con el bit 1 de (0xE1AB) a cero. Sube de ocho en ocho, que es la altura de una celda.
; ----------------------------------------------------------------------
mira_si_puede_subir:
	ld hl,0e1b3h		;63ac
	ld a,(hl)			;63af
	sub 088h		;63b0   ; el tope de abajo
	ret c			;63b2
	cp 008h		;63b3   ; ocho de margen
	ret c			;63b5
	ld a,(0e1abh)		;63b6
	bit 1,a		;63b9   ; el bit 1 lo impide
	ret nz			;63bb
	ld a,(hl)			;63bc
	sub 008h		;63bd   ; y sube ocho
	ld (hl),a			;63bf
	jp marca_movimiento_arriba		;63c0
estado_2_subiendo:
	call avanza_el_gesto		;63c3
	call mira_si_puede_subir		;63c6
	ld hl,(0e1b3h)		;63c9   ; la posicion del jugador
	call mira_los_cuarenta_objetos		;63cc   ; mira si hay algo ahi
	jr nc,mira_si_llego_al_suelo		;63cf
	ld a,(0e1cbh)		;63d1
	call sube_al_jugador		;63d4   ; se coloca
	ld a,006h		;63d7   ; el sonido
	call pide_un_sonido		;63d9
	ld a,005h		;63dc   ; estado 5
	jp pasa_al_estado		;63de

; ----------------------------------------------------------------------
; ESTADO 0: en el suelo. La lectura del mando se congela en (0xE1B7), el paso de la animacion sale del bit 2 de (0xE1B8) -8 o 9- y, si se pulsa algo, suena el 2. Cuando se pulsa un boton se dispara la subida en CUATRO tandas de 0xF8, o sea ocho pixeles hacia arriba cada una.
; ----------------------------------------------------------------------
estado_0_en_el_suelo:
	ld a,(0e009h)		;63e1   ; lo que se pulsa
	ld (0e1b7h),a		;63e4   ; congelado para el resto del cuadro
	call mira_si_llego_a_la_marca		;63e7
	jp nc,estado_4_con_sonido		;63ea
	ld a,(0e003h)		;63ed   ; el contador de cuadros
	rra			;63f0   ; uno de cada dos
	call c,elige_el_paso_del_dibujo		;63f1
	ld a,(0e009h)		;63f4
	and 00ch		;63f7   ; los dos bits de direccion
	jr z,L_6400		;63f9
	ld a,002h		;63fb   ; el sonido de andar
	call pide_un_sonido		;63fd
L_6400:
	ld a,(0e1b8h)		;6400
	bit 2,a		;6403   ; el bit 2 elige el paso
	ld b,008h		;6405
	jr nz,L_6410		;6407
	ld a,(0e009h)		;6409
	or a			;640c
	jr z,L_6410		;640d
	inc b			;640f   ; uno mas si se esta pulsando algo
L_6410:
	ld a,b			;6410
	ld (0e1b5h),a		;6411   ; y ese es el paso del dibujo
	call se_acaba_de_pulsar_boton		;6414   ; se acaba de pulsar boton?
	ret z			;6417
	rra			;6418
	jr nc,L_6434		;6419
	ld b,004h		;641b   ; cuatro tandas
L_641D:
	push bc			;641d
	ld a,0f8h		;641e   ; ocho pixeles hacia arriba cada una
	call mueve_al_jugador		;6420
	call mete_al_jugador_en_los_sprites		;6423
	call vuelca_los_sprites		;6426
	call baja_si_puede		;6429
	pop bc			;642c
	djnz L_641D		;642d
	ld a,002h		;642f   ; estado 2
	jp pasa_al_estado		;6431
L_6434:
	call mira_los_objetos_de_cerca		;6434   ; mira si agarra
	jr nc,L_644A		;6437
	call busca_en_la_lista_de_agarres		;6439
	jr nc,L_644A		;643c
	ld a,(0e1d9h)		;643e
	ld hl,0e1b3h		;6441
	cp (hl)			;6444
	jr nz,L_644A		;6445
	jp pasa_al_estado_6		;6447   ; estado 6
L_644A:
	call hay_suelo_debajo		;644a
	jp z,se_engancha		;644d   ; se engancha
	ld hl,06572h		;6450
	call arranca_gesto		;6453
	ld a,003h		;6456   ; estado 3
	jp pasa_al_estado		;6458

; ----------------------------------------------------------------------
; EL FLANCO DEL BOTON: invierte la lectura ANTERIOR y la cruza con la de ahora, de modo que solo queda a uno el boton que estaba suelto y ahora esta pulsado. Mantener apretado no cuenta dos veces.
; ----------------------------------------------------------------------
se_acaba_de_pulsar_boton:
	ld hl,0e008h		;645b
	ld a,(hl)			;645e   ; lo de antes
	cpl			;645f   ; invertido
	and 003h		;6460   ; los dos botones
	inc hl			;6462
	and (hl)			;6463   ; cruzado con lo de ahora: el flanco
	ret			;6464

; ----------------------------------------------------------------------
; SI HAY SUELO DEBAJO, preguntandoselo a la PANTALLA: se leen de la VRAM las dos celdas de los pies y se comparan con el patron 0x9B.
; ----------------------------------------------------------------------
hay_suelo_debajo:
	call lee_las_dos_celdas_de_debajo		;6465   ; las dos celdas de debajo
	ld a,09bh		;6468   ; el patron del suelo
	dec hl			;646a
	cp (hl)			;646b   ; una
	ret z			;646c
	dec hl			;646d
	cp (hl)			;646e   ; y la otra
	ret			;646f
baja_un_tramo:
	ld hl,0e1b3h		;6470
	ld a,(hl)			;6473
	add a,008h		;6474   ; ocho pixeles hacia abajo
	ld (hl),a			;6476
	call mete_al_jugador_en_los_sprites		;6477   ; y se repinta
	call vuelca_los_sprites		;647a
	call marca_movimiento_abajo		;647d
	ld hl,0e1b3h		;6480
	ld a,(hl)			;6483
	ret			;6484
L_6485:
	xor a			;6485
pasa_al_estado:
	ld hl,0e1b2h		;6486   ; el estado del jugador
	ld (hl),a			;6489
	ret			;648a
pasa_al_estado_siguiente:
	ld hl,0e1b2h		;648b
	inc (hl)			;648e   ; el estado del jugador, uno mas
	ret			;648f

; ----------------------------------------------------------------------
; EL PASO DEL DIBUJO SEGUN LO QUE SE PULSE. Si no hay direccion pulsada el paso se queda en 3 -el quieto-; si la hay, avanza el contador y de sus bits 2 y 3 sale el paso, o sea que la animacion va sola con el movimiento.
; ----------------------------------------------------------------------
elige_el_paso_del_dibujo:
	ld a,(0e009h)		;6490   ; lo que se esta pulsando
	and 00ch		;6493   ; los dos bits de direccion
	ld (0e1b6h),a		;6495   ; guardado para el cuadro
	ld hl,0e1b4h		;6498
	ld de,0e1b8h		;649b
	jr z,L_64B3		;649e
	ex de,hl			;64a0
	inc (hl)			;64a1   ; el contador de la animacion
	ex de,hl			;64a2
	ld (0e1b7h),a		;64a3   ; y la lectura, congelada
	ld c,001h		;64a6
	call mueve_sin_pasar_de_los_topes		;64a8
	ld a,(de)			;64ab
	and 00ch		;64ac   ; los bits 2 y 3
	rrca			;64ae   ; bajados a su sitio: el paso
	rrca			;64af
L_64B0:
	inc hl			;64b0
	ld (hl),a			;64b1
	ret			;64b2
L_64B3:
	ld a,003h		;64b3   ; el paso quieto
	jr L_64B0		;64b5
se_acaba_de_pulsar_direccion:
	ld hl,0e008h		;64b7
	ld a,(hl)			;64ba   ; lo de antes
	cpl			;64bb   ; invertido y cruzado con lo de ahora: el flanco
	and 030h		;64bc
	inc hl			;64be
	and (hl)			;64bf
	ret			;64c0
avanza_el_gesto_dos:
	ld c,002h		;64c1
	jr L_64C7		;64c3

; ----------------------------------------------------------------------
; AVANZAR UN GESTO. El bit 0 de (0xE1C7) decide el sentido -el paso sube o baja-, y a partir del octavo cambia el dibujo de 3 a 5. El desplazamiento se saca de la rampa que apunta (0xE1C9), con el signo cambiado si el gesto va marcha atras.
; ----------------------------------------------------------------------
avanza_el_gesto:
	ld c,001h		;64c5
L_64C7:
	ld a,(0e1c7h)		;64c7   ; el sentido del gesto
	ld b,a			;64ca
	ld hl,0e1c8h		;64cb
	bit 0,b		;64ce   ; el bit 0
	jr nz,L_64D5		;64d0
	inc (hl)			;64d2   ; hacia delante
	jr L_64D6		;64d3
L_64D5:
	dec (hl)			;64d5   ; o hacia atras
L_64D6:
	ld a,(hl)			;64d6
	cp 008h		;64d7   ; a partir del paso 8
	ld a,003h		;64d9
	jr c,L_64DF		;64db
	ld a,005h		;64dd   ; el otro dibujo
L_64DF:
	ld (0e1b5h),a		;64df
	ld hl,0e1b3h		;64e2
	ld de,(0e1c9h)		;64e5   ; por donde va la rampa
	ld a,(de)			;64e9   ; el desplazamiento de este paso
	bit 0,b		;64ea
	jr nz,L_64F0		;64ec
	neg		;64ee   ; al reves si va marcha atras
L_64F0:
	push bc			;64f0
	ld c,a			;64f1
	add a,(hl)			;64f2
	cp 018h		;64f3   ; veinticuatro de tope
	jr nc,L_64FA		;64f5
	ld a,(hl)			;64f7
	ld c,000h		;64f8   ; y si se pasa, no se mueve
L_64FA:
	ld (hl),a			;64fa
	inc hl			;64fb
	ld a,c			;64fc
	ld (0e1beh),a		;64fd   ; lo que se movio de verdad, apuntado
	pop bc			;6500
	bit 0,b		;6501
	jr z,L_6507		;6503
	ld c,001h		;6505
L_6507:
	neg		;6507
	push hl			;6509
	push de			;650a
	call ajusta_la_altura_alcanzada		;650b   ; se repinta
	pop de			;650e
	pop hl			;650f
	call mueve_sin_pasar_de_los_topes		;6510
	bit 0,b		;6513
	jr nz,L_651A		;6515
	inc de			;6517   ; la rampa avanza
	jr L_651B		;6518
L_651A:
	dec de			;651a   ; o retrocede
L_651B:
	ld a,(de)			;651b
	inc a			;651c   ; un 0xFF en la rampa es el final
	jr nz,L_652A		;651d
	dec de			;651f
	dec de			;6520
	inc a			;6521
	ld (0e1c7h),a		;6522   ; se baja la senal: se acabo el gesto
L_6525:
	ld (0e1c9h),de		;6525
	ret			;6529
L_652A:
	inc a			;652a
	jr nz,L_6525		;652b
	inc de			;652d
	jr L_6525		;652e

; ----------------------------------------------------------------------
; MOVER SIN PASARSE DE LOS TOPES. Los dos limites viven juntos en 0xE057 y 0xE058, y el bit 3 de lo que se pulsa decide contra cual se compara: si el paso se saliera, se deshace (`sub c` / `add a,c`) y el jugador se queda donde estaba.
; ----------------------------------------------------------------------
mueve_sin_pasar_de_los_topes:
	ld a,(0e1b6h)		;6530   ; lo que se esta pulsando
	or a			;6533
	ret z			;6534
	bit 3,a		;6535   ; el bit 3: hacia un lado o hacia el otro
	ld a,(hl)			;6537
	push hl			;6538
	ld hl,0e057h		;6539   ; los dos topes, juntos
	jr z,L_6545		;653c
	add a,c			;653e   ; un paso hacia delante
	cp (hl)			;653f
	jr c,L_6543		;6540   ; si se pasa del tope, se deshace
	sub c			;6542
L_6543:
	jr L_654B		;6543
L_6545:
	sub c			;6545   ; o un paso hacia atras
	inc hl			;6546
	cp (hl)			;6547
	jr nc,L_654B		;6548   ; contra el otro tope
	add a,c			;654a
L_654B:
	pop hl			;654b
	ld (hl),a			;654c
	ret			;654d
arranca_gesto_con_sonido:
	push hl			;654e
	ld a,003h		;654f   ; el sonido del gesto
	call pide_un_sonido		;6551
	pop hl			;6554
	xor a			;6555
	jr L_655A		;6556

; ----------------------------------------------------------------------
; ARRANCAR UN GESTO: la rampa queda apuntada en (0xE1C9), el sentido en (0xE1C7) y el paso a cero. Ademas se apunta la posicion de partida y la marca de altura de ese momento.
; ----------------------------------------------------------------------
arranca_gesto:
	ld a,001h		;6558
L_655A:
	ld (0e1c9h),hl		;655a   ; la rampa que hay que recorrer
	ld (0e1c7h),a		;655d   ; el sentido
	xor a			;6560
	ld (0e1c8h),a		;6561   ; el paso, a cero
	ld a,(0e1b3h)		;6564   ; la posicion de partida
	ld (0e1b9h),a		;6567
	ld hl,(0e054h)		;656a   ; y la marca de altura
	ld (0e1bah),hl		;656d
	ret			;6570

; ----------------------------------------------------------------------
; DATOS guion_0x6571: 19 bytes, 1 tramo, 16 bytes a la VRAM (0x08FE); lo
;   consume el interprete de rotulos y cierra en el borde
;   0x6571..0x6584  (19 bytes)
DATA_guion_0x6571:
	defb 0feh,008h,008h,008h,004h,004h,002h,002h,002h,002h,002h,001h,001h,001h,000h,000h	; 6571  ................
	defb 000h,000h,0ffh	; 6581

; ======================================================================
; CODIGO 0x6584..0x65ff  (123 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; METER AL JUGADOR EN EL BUFER DE SPRITES. Segun el estado -el 5, por debajo del 15 o por encima- se corrige la posicion y se elige una de dos tablas de patrones, la de 0x65FF (cuatro bytes por pose) o la de 0x6638 (CINCO, `a*4+a`). En los estados altos se le restan tres pixeles a dos de los sprites, que es lo que le inclina la figura.
; ----------------------------------------------------------------------
mete_al_jugador_en_los_sprites:
	ld hl,0e1b3h		;6584
	ld b,(hl)			;6587
	ld a,(0e1b2h)		;6588   ; el estado del jugador
	cp 005h		;658b   ; el estado 5 va aparte
	jr z,L_659D		;658d
	cp 00fh		;658f   ; de 15 en adelante, la otra tabla
	jr nc,mete_al_jugador_inclinado		;6591
	inc b			;6593   ; cuatro pixeles de correccion
	inc b			;6594
	inc b			;6595
	inc b			;6596
	sub 006h		;6597
	cp 006h		;6599
	jr nc,L_65A2		;659b
L_659D:
	ld a,008h		;659d   ; el paso quieto
	ld (0e1b7h),a		;659f
L_65A2:
	inc hl			;65a2
	ld c,(hl)			;65a3
	inc hl			;65a4
	ld a,(hl)			;65a5
	bit 0,a		;65a6   ; el bit 0 del paso corrige un pixel
	jr z,L_65AB		;65a8
	inc b			;65aa
L_65AB:
	ld de,065ffh		;65ab   ; la tabla de poses
	add a,a			;65ae   ; dos veces por dos
	add a,a			;65af
	call suma_a_a_de		;65b0   ; indexada
	ld hl,0e0d0h		;65b3   ; el bufer de sprites
	call mete_dos_sprites		;65b6   ; el primero
	ld a,010h		;65b9   ; dieciseis mas abajo: el segundo sprite
	add a,b			;65bb   ; mas la fila
	ld b,a			;65bc   ; guardada
	call mete_dos_sprites		;65bd   ; y el segundo
	ld (hl),0c3h		;65c0   ; y el tercero, fuera de pantalla
	ld a,(0e1b5h)		;65c2   ; el estado del jugador
	cp 006h		;65c5   ; en los estados altos
	ret c			;65c7   ; por debajo no se ajusta nada
	ld hl,0e0d4h		;65c8   ; la fila del primer sprite
	ld a,(hl)			;65cb   ; leida
	sub 003h		;65cc   ; tres pixeles menos
	ld (hl),a			;65ce   ; guardada
	ld hl,0e0dch		;65cf   ; y la del segundo
	ld a,(hl)			;65d2   ; leida
	sub 003h		;65d3   ; a los dos sprites
	ld (hl),a			;65d5   ; guardada
	ret			;65d6
mete_al_jugador_inclinado:
	inc b			;65d7   ; dos filas mas abajo
	inc b			;65d8
	inc hl			;65d9   ; el byte siguiente
	ld c,(hl)			;65da   ; la columna
	inc hl			;65db   ; el siguiente
	ld a,(hl)			;65dc   ; y la pose
	add a,a			;65dd   ; por cinco: esta tabla gasta uno mas
	add a,a			;65de
	add a,(hl)			;65df
	ld de,06638h		;65e0   ; la otra tabla de poses
	call suma_a_a_de		;65e3   ; indexada
	ld hl,0e0d0h		;65e6   ; el bufer de atributos
	call mete_dos_sprites		;65e9   ; el primer sprite
	ld a,010h		;65ec   ; dieciseis mas abajo
	add a,b			;65ee   ; mas la fila
	ld b,a			;65ef   ; guardada
	call mete_dos_sprites		;65f0   ; y el segundo
	ld a,c			;65f3   ; la columna
	sub 008h		;65f4   ; ocho a un lado
	ld (0e0d9h),a		;65f6   ; al atributo del tercero
	ld a,c			;65f9   ; la columna otra vez
	add a,008h		;65fa   ; y ocho al otro
	ld c,a			;65fc   ; guardada
	jr $+82		;65fd

; ----------------------------------------------------------------------
; DATOS tabla_de_poses: catorce poses de cuatro bytes; 0x65AB entra aqui con
;   el paso multiplicado por cuatro (`add a,a / add a,a`)
;   0x65ff..0x6637  (56 bytes)
DATA_tabla_de_poses:
	defb 004h,000h,00ch,008h,004h,000h,010h,008h,004h,000h,014h,018h,004h,000h,014h,018h	; 65ff  ................
	defb 000h,000h,000h,000h,004h,000h,01ch,008h,0c0h,0b8h,0c4h,0bch,0c8h,0b8h,0cch,0bch	; 660f  ................
	defb 0d4h,0b8h,0c4h,0bch,0e4h,0b8h,0cch,0bch,0ech,0b8h,0f0h,0bch,0d8h,0b8h,0dch,0bch	; 661f  ................
	defb 0b0h,0b8h,0c4h,0bch,0b4h,0b8h,0cch,0bch	; 662f  ........

; ----------------------------------------------------------------------
; DATOS byte_suelto_entre_las_dos_tablas: un byte (0xE8) que sobra entre la
;   pose 13, que acaba aqui, y la tabla de 0x6638, que 0x65E0 nombra por su
;   direccion
;   0x6637..0x6638  (1 bytes)
DATA_byte_suelto_entre_las_dos_tablas:
	defb 0e8h	; 6637

; ----------------------------------------------------------------------
; DATOS otra_tabla_de_poses: cuatro poses de CINCO bytes; 0x65DD multiplica el
;   paso por cinco (`add a,a / add a,a / add a,(hl)`) y 0x65E0 la carga. Las
;   cuatro empiezan por 0x04 0x00 y los veinte bytes cierran justo donde
;   empieza mete_dos_sprites
;   0x6638..0x664c  (20 bytes)
DATA_otra_tabla_de_poses:
	defb 004h,000h,07ch,0a8h,0a4h,004h,000h,074h,0a8h,0a4h,004h,000h,07ch,0a8h,078h,004h	; 6638  ..|....t....|.x.
	defb 000h,074h,0a8h,078h	; 6648

; ======================================================================
; CODIGO 0x664c..0x66e7  (155 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; METER UN SPRITE EN EL BUFER: fila, columna y patron. El bit 3 de la lectura congelada decide si el patron va tal cual o SUMANDO 0x28, que es como se dibuja la figura mirando al otro lado sin una segunda hoja de patrones.
; ----------------------------------------------------------------------
mete_dos_sprites:
	call mete_un_sprite		;664c
mete_un_sprite:
	ld (hl),b			;664f   ; la fila
	inc hl			;6650
	ld (hl),c			;6651   ; la columna
	inc hl			;6652
	ld a,(0e1b7h)		;6653   ; la lectura congelada
	bit 3,a		;6656   ; su bit 3: hacia donde mira
	ld a,(de)			;6658
	jr nz,L_6660		;6659
	ld a,028h		;665b   ; y entonces el patron va 0x28 mas alla
	ex de,hl			;665d
	add a,(hl)			;665e
	ex de,hl			;665f
L_6660:
	ld (hl),a			;6660
	inc de			;6661   ; cuatro bytes por sprite
	inc hl			;6662
	inc hl			;6663
	ret			;6664

; ----------------------------------------------------------------------
; LA CAJA CONTRA LOS CUARENTA OBJETOS. Se saltan los retirados (0xD0) y los que tengan algo en el nibble alto; la ventana es de NUEVE en una coordenada, y en la otra la anchura la trae C, que viene del tipo del objeto por ocho. Al acertar, copia sus tres bytes a 0xE1CB y devuelve acarreo.
; ----------------------------------------------------------------------
mira_los_cuarenta_objetos:
	ex de,hl			;6665
	ld hl,0e132h		;6666
	ld b,028h		;6669   ; cuarenta objetos
L_666B:
	push bc			;666b
	push hl			;666c
	ld a,(hl)			;666d
	cp 0d0h		;666e   ; retirado
	jr z,L_6679		;6670
	inc hl			;6672
	inc hl			;6673
	ld a,(hl)			;6674
	and 0f0h		;6675   ; el nibble alto tiene que estar limpio
	jr z,L_6682		;6677
L_6679:
	pop hl			;6679
	pop bc			;667a
	inc hl			;667b   ; tres bytes por objeto
	inc hl			;667c
	inc hl			;667d
	djnz L_666B		;667e
	and a			;6680
	ret			;6681
L_6682:
	dec hl			;6682   ; dos bytes atras
	dec hl			;6683
	push de			;6684   ; se guarda DE
	call ancho_del_objeto		;6685   ; el ancho, que lo dice el tipo
	pop de			;6688   ; se recupera
	ld a,e			;6689   ; nueve pixeles de margen
	sub (hl)			;668a   ; menos la columna del objeto
	cp 009h		;668b
	jr nc,L_6679		;668d   ; fuera de margen: no hay contacto
	inc hl			;668f   ; el byte siguiente
	ld a,d			;6690   ; la fila del jugador
	sub (hl)			;6691   ; menos la del objeto
	add a,008h		;6692   ; ocho de desplazamiento
	cp c			;6694   ; y el ancho, que lo trae el tipo
	jr nc,L_6679		;6695   ; y si no cabe, tampoco
	ld a,c			;6697   ; el ancho
	pop hl			;6698   ; se recuperan
	pop bc			;6699
	ld de,0e1cbh		;669a   ; los tres bytes del objeto, copiados
	ld bc,00003h		;669d
	ldir		;66a0   ; copiados
	ld (de),a			;66a2   ; y el ancho detras
	scf			;66a3   ; acarreo: hay contacto
	ret			;66a4
ancho_del_objeto:
	call elige_la_tabla_de_piezas		;66a5
	ld a,c			;66a8   ; el tipo, por ocho
	add a,a			;66a9   ; dos veces por dos
	add a,a			;66aa
	add a,a			;66ab
	inc a			;66ac   ; mas uno
	ld c,a			;66ad
	ret			;66ae
mira_si_llego_a_la_marca:
	ld a,(0e1b4h)		;66af   ; la posicion del jugador
	ld hl,0e1cch		;66b2   ; contra la marca
	sub (hl)			;66b5
	add a,008h		;66b6   ; ocho de margen
	inc hl			;66b8
	inc hl			;66b9
	cp (hl)			;66ba
	ret			;66bb
pinta_la_altura:
	ld hl,066e7h		;66bc   ; el rotulo "HEIGHT"
	call pinta_rotulo		;66bf
pinta_la_altura_en_bcd:
	ld hl,(0e054h)		;66c2   ; y la altura alcanzada

; ----------------------------------------------------------------------
; LA ALTURA, DIVIDIDA ENTRE DIECISEIS. Cuatro parejas de `srl h / rr l`, o sea cuatro divisiones entre dos encadenadas de 16 bits, y luego se pasa a BCD para poder pintarla.
; ----------------------------------------------------------------------
	srl h		;66c5   ; dividir entre dos, arrastrando el bit
	rr l		;66c7
	srl h		;66c9
	rr l		;66cb
	srl h		;66cd
	rr l		;66cf
	srl h		;66d1
	rr l		;66d3
	call binario_a_bcd		;66d5   ; y de binario a BCD
	ld (0e1bch),de		;66d8
	ld hl,0e1bdh		;66dc   ; el resultado
	ld de,0385ah		;66df   ; la celda del marcador
imprime_dos_bytes_bcd:
	ld b,002h		;66e2   ; dos bytes, cuatro digitos
	jp imprime_bcd		;66e4

; ----------------------------------------------------------------------
; DATOS guion_0x66E7: 14 bytes, 2 tramos, 8 bytes a la VRAM; lo pinta 0x66BC
;   0x66e7..0x66f5  (14 bytes)
DATA_guion_0x66E7:
	defb 053h,038h,048h,045h,049h,047h,048h,054h,040h,0feh,05eh,038h,018h,0ffh	; 66e7  S8HEIGHT@.^8..

; ======================================================================
; CODIGO 0x66f5..0x6a42  (845 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; DE BINARIO A BCD, sin dividir ni una vez. Recorre los dieciseis bits del numero de arriba abajo (`add hl,hl` saca el de mas peso al acarreo) y va DOBLANDO el resultado en BCD con `adc a,a / daa`: doblar en decimal es lo mismo que doblar en binario si se corrige con `daa` en cada paso.
; ----------------------------------------------------------------------
binario_a_bcd:
	ld b,010h		;66f5   ; dieciseis bits
	ld de,00000h		;66f7   ; el resultado, a cero
L_66FA:
	add hl,hl			;66fa   ; el bit de mas peso, al acarreo
	ld a,e			;66fb   ; el BCD se dobla y recoge ese bit
	adc a,a			;66fc
	daa			;66fd   ; corregido a decimal
	ld e,a			;66fe
	ld a,d			;66ff
	adc a,a			;6700   ; y el byte alto, igual
	daa			;6701
	ld d,a			;6702
	djnz L_66FA		;6703
	ret			;6705
sube_al_jugador:
	ld hl,0e1b3h		;6706   ; la posicion del jugador
	sub (hl)			;6709

; ----------------------------------------------------------------------
; MOVER AL JUGADOR Y AJUSTAR LA ALTURA ALCANZADA, que va en sentido contrario: lo que baja la posicion sube la marca. Y la marca tiene suelo: si la resta se pasa de cero, se queda en cero.
; ----------------------------------------------------------------------
mueve_al_jugador:
	push af			;670a
	ld hl,0e1b3h		;670b
	add a,(hl)			;670e   ; se aplica a la posicion
	ld (hl),a			;670f
	pop af			;6710
	neg		;6711   ; y al reves para la altura
ajusta_la_altura_alcanzada:
	ld hl,(0e054h)		;6713   ; la altura acumulada
	ld d,000h		;6716
	ld e,a			;6718
	or a			;6719
	jp p,L_6729		;671a   ; positivo: se suma
	neg		;671d
	ld e,a			;671f
	and a			;6720
	sbc hl,de		;6721   ; negativo: se resta
	jr nc,L_672A		;6723
	ld h,d			;6725   ; y si se pasa, cero
	ld l,d			;6726
	jr L_672A		;6727
L_6729:
	add hl,de			;6729
L_672A:
	ld (0e054h),hl		;672a
	ret			;672d
marca_movimiento_abajo:
	ld a,001h		;672e
	jr L_6734		;6730
marca_movimiento_arriba:
	ld a,002h		;6732
L_6734:
	ld hl,0e1aah		;6734   ; la direccion del ultimo movimiento
	ld (hl),a			;6737
	inc hl			;6738
	or a			;6739
	ret z			;673a
	and (hl)			;673b   ; cruzada con lo que se puede
	ld (hl),a			;673c
	or a			;673d
	jr z,mueve_el_decorado		;673e
	dec hl			;6740
	ld (hl),000h		;6741
	ret			;6743

; ----------------------------------------------------------------------
; EL MOVIMIENTO DEL DECORADO, otra vez leyendo de la VRAM: compara el indice que hay en pantalla con el que espera y, cuando coincide, escribe un cero y avanza el puntero. Dos listas a la vez, la de 0xE1C4 y la de 0xE059.
; ----------------------------------------------------------------------
mueve_el_decorado:
	dec hl			;6744
	ld a,(hl)			;6745
	rra			;6746   ; el bit 0
	jr nc,retrocede_el_decorado		;6747
mueve_el_decorado_un_paso:
	ld hl,0e1c4h		;6749
	ld de,(0e1c5h)		;674c   ; por donde va la primera lista
	inc (hl)			;6750
	call lee_de_vram		;6751   ; lee la celda de la pantalla
	cp (hl)			;6754   ; contra lo que se espera
	jr nz,L_6768		;6755
	inc de			;6757
	call lee_de_vram		;6758
	cp 0ffh		;675b   ; un 0xFF cierra la lista
	jr z,marca_el_tope_de_abajo		;675d
	ld (hl),000h		;675f   ; se borra
	call busca_un_hueco_de_objeto		;6761
	ld (0e1c5h),de		;6764
L_6768:
	call mueve_los_objetos		;6768
	ld hl,0e059h		;676b
	ld de,(0e05ah)		;676e   ; y la segunda lista
	inc (hl)			;6772
	call lee_de_vram		;6773
	cp (hl)			;6776
	ret nz			;6777
	ld (hl),000h		;6778
L_677A:
	inc de			;677a
	inc de			;677b
	inc de			;677c
	call lee_de_vram		;677d
	or a			;6780
	jr z,L_677A		;6781
	ld (0e05ah),de		;6783   ; el puntero de la lista, apuntado
	ret			;6787
marca_el_tope_de_abajo:
	ld hl,0e1abh		;6788
	set 0,(hl)		;678b   ; el bit 0 de (0xE1AB): tope por abajo
	jr L_6768		;678d

; ----------------------------------------------------------------------
; EL DECORADO HACIA ATRAS, con las dos listas recorridas al reves: se retrocede de tres en tres celdas hasta encontrar una que no sea cero. Y si el numero de fase coincide con lo que trae la celda, se levanta el tope de arriba.
; ----------------------------------------------------------------------
retrocede_el_decorado:
	ld hl,0e059h		;678f
	ld de,(0e05ah)		;6792   ; por donde va la lista
	dec (hl)			;6796
L_6797:
	dec de			;6797   ; tres celdas atras
	dec de			;6798
	dec de			;6799
	call lee_de_vram		;679a   ; lee de la pantalla
	or a			;679d
	jr z,L_6797		;679e   ; cero: se sigue retrocediendo
	ld a,(hl)			;67a0
	or a			;67a1
	jr nz,L_67D3		;67a2
L_67A4:
	inc de			;67a4
	call lee_de_vram		;67a5
	ld b,a			;67a8
	ld a,(0e056h)		;67a9   ; el numero de fase
	cp b			;67ac   ; contra lo que trae la celda
	jr nz,L_67B4		;67ad
	ld hl,0e1abh		;67af
	set 1,(hl)		;67b2   ; el bit 1: tope por arriba
L_67B4:
	call busca_un_hueco_de_objeto		;67b4
L_67B7:
	call mueve_los_objetos		;67b7
	ld hl,0e1c4h		;67ba
	ld de,(0e1c5h)		;67bd
	dec (hl)			;67c1   ; si se paso de cero, se deja
	ret p			;67c2
retrocede_la_lista_de_arriba:
	dec de			;67c3   ; tres celdas atras
	dec de			;67c4
	dec de			;67c5
	call lee_de_vram		;67c6   ; lee de la pantalla
	or a			;67c9
	jr z,retrocede_la_lista_de_arriba		;67ca   ; cero: se sigue retrocediendo
	dec a			;67cc
	ld (hl),a			;67cd   ; uno menos
	ld (0e1c5h),de		;67ce
	ret			;67d2
L_67D3:
	jp p,L_67B7		;67d3
	call lee_de_vram		;67d6   ; lee de la pantalla
	dec a			;67d9
	ld (hl),a			;67da   ; uno menos
	ld (0e05ah),de		;67db
	jr nz,L_67B7		;67df
L_67E1:
	dec de			;67e1   ; tres celdas atras
	dec de			;67e2
	dec de			;67e3
	call lee_de_vram		;67e4   ; lee de la pantalla
	or a			;67e7
	jr z,L_67E1		;67e8
	jr L_67A4		;67ea

; ----------------------------------------------------------------------
; BUSCAR UN HUECO LIBRE ENTRE LOS CUARENTA OBJETOS -el que tenga el 0xD0 de retirado- y rellenarlo leyendo DE LA PANTALLA los dos indices que lo definen. El primer byte es 0xE8 o 0xC0 segun el bit 0 de (0xE1AA), o sea segun por donde se venga.
; ----------------------------------------------------------------------
busca_un_hueco_de_objeto:
	ld hl,0e132h		;67ec   ; los cuarenta objetos
	ld b,028h		;67ef
L_67F1:
	ld a,0d0h		;67f1   ; 0xD0: hueco libre
	cp (hl)			;67f3
	jr z,L_67FC		;67f4
	inc hl			;67f6   ; tres bytes por objeto
	inc hl			;67f7
	inc hl			;67f8
	djnz L_67F1		;67f9
	ret			;67fb
L_67FC:
	push bc			;67fc
	ld a,(0e1aah)		;67fd   ; la direccion del movimiento
	rra			;6800
	ld (hl),0e8h		;6801   ; un tipo
	jr c,L_6807		;6803
	ld (hl),0c0h		;6805   ; o el otro
L_6807:
	ld (0e1dch),hl		;6807   ; el hueco elegido, apuntado
	inc hl			;680a   ; el byte siguiente
	call lee_de_vram		;680b   ; el indice que hay en la pantalla
	ld b,a			;680e   ; guardado en B
	inc de			;680f   ; la celda de al lado
	call lee_de_vram		;6810   ; y el de al lado
	ld (hl),a			;6813   ; el segundo, a la ficha
	inc hl			;6814
	ld (hl),b			;6815   ; y el primero detras
	ld a,b			;6816   ; el primero otra vez
	and 0e0h		;6817   ; los tres bits de arriba
	cp 0e0h		;6819   ; y si no lo son, es terreno normal
	jr nz,L_6875		;681b
	push de			;681d   ; se guardan los dos punteros
	push hl			;681e
	call busca_la_ficha_de_esa_posicion		;681f
	jr z,descarta_el_objeto		;6822   ; si ya hay una ficha ahi, se descarta
	push de			;6824
	ld de,00000h		;6825   ; a cero: se busca un hueco libre
	call busca_la_ficha_de_esa_posicion		;6828
	pop de			;682b
	jr nz,L_6873		;682c   ; si no lo hay, no cabe otro objeto
	ld (hl),d			;682e   ; la posicion, a la ficha
	dec hl			;682f
	ld (hl),e			;6830   ; los dos bytes
	inc hl			;6831
	inc hl			;6832   ; el siguiente

; ----------------------------------------------------------------------
; EL AZAR SALE DEL REGISTRO R. `ld a,r` lee el contador de refresco de memoria del Z80, que avanza solo con cada instruccion ejecutada: es el generador aleatorio del cartucho, gratis y sin tabla. La mascara depende de la fase -tres variantes en la 1, cuatro en las demas- y, en la fase 2, el valor 3 se rebaja a 2.
; ----------------------------------------------------------------------
	ld a,(0e051h)		;6833   ; el numero de fase
	ld c,a			;6836   ; guardado en C
	cp 001h		;6837   ; en la fase 1 solo hay dos variantes
	ld b,003h		;6839   ; en las demas, cuatro variantes
	jr nz,L_683E		;683b
	ld b,a			;683d   ; y en la primera, dos
L_683E:
	ld a,r		;683e   ; el contador de refresco del Z80: el azar
	and b			;6840   ; recortado a lo que haya en B
	ld (hl),a			;6841   ; a la ficha
	cp 003h		;6842   ; la variante mas alta
	jr nz,L_684C		;6844
	ld a,c			;6846   ; la fase
	cp 002h		;6847
	jr nz,L_684C		;6849   ; en las demas se queda como esta
	dec (hl)			;684b   ; se rebaja en la fase 2
L_684C:
	ld a,(0e1aah)		;684c   ; la direccion del movimiento
	rra			;684f   ; el bit 0 al acarreo
	jr c,L_6854		;6850   ; con acarreo se deja como esta
	set 7,(hl)		;6852   ; y el bit 7 marca el sentido del objeto
L_6854:
	inc hl			;6854   ; el byte siguiente
	ld de,(0e1dch)		;6855   ; y el hueco elegido
	push de			;6859
	push hl			;685a
	ld a,(de)			;685b   ; el tipo que se leyo de la pantalla
	ld (hl),000h		;685c
	cp 0e8h		;685e   ; 0xE8: el que lleva la marca 0xFF
	jr nz,L_6864		;6860
	ld (hl),0ffh		;6862
L_6864:
	inc hl			;6864
	ex de,hl			;6865
	ld bc,00003h		;6866   ; tres bytes de definicion
	ldir		;6869
	pop hl			;686b
	ld c,002h		;686c   ; y dos mas
	ldir		;686e
	pop hl			;6870
	ld (hl),0d0h		;6871   ; el hueco de origen queda retirado
L_6873:
	pop hl			;6873
	pop de			;6874
L_6875:
	pop bc			;6875
	inc hl			;6876
	inc de			;6877
	call lee_de_vram		;6878   ; la celda siguiente en la pantalla
	or a			;687b
	ret nz			;687c   ; si no esta vacia, se acabo
	inc de			;687d
	jp busca_un_hueco_de_objeto		;687e
descarta_el_objeto:
	pop hl			;6881
	pop de			;6882
	dec hl			;6883
	dec hl			;6884
	ld (hl),0d0h		;6885   ; 0xD0: retirado
	jr L_6875		;6887

; ----------------------------------------------------------------------
; EL BUCLE DE LOS CUARENTA OBJETOS. Los retirados se saltan; los demas se mueven ocho pixeles arriba o abajo segun el bit 0 de (0xE1AA), y en cuanto salen de la banda 0xC0..0xF0 se retiran solos. Es lo que mantiene la lista limpia sin barrerla aparte.
; ----------------------------------------------------------------------
mueve_los_objetos:
	ld hl,0e132h		;6889
	ld b,028h		;688c   ; cuarenta
L_688E:
	push hl			;688e
	push bc			;688f
	ld a,(hl)			;6890
	cp 0d0h		;6891   ; retirado: al siguiente
	jr z,L_68EC		;6893
	call elige_la_tabla_de_piezas		;6895
	push bc			;6898
	push de			;6899
	push hl			;689a
	ld a,(0e1aah)		;689b   ; la direccion del movimiento
	or a			;689e
	jr z,L_68D5		;689f
	ld d,(hl)			;68a1
	rra			;68a2
	ld a,0f8h		;68a3   ; ocho hacia un lado
	jr nc,L_68A9		;68a5
	ld a,008h		;68a7   ; u ocho hacia el otro
L_68A9:
	add a,(hl)			;68a9
	ld (hl),a			;68aa
	sub 0c0h		;68ab   ; la banda util empieza en 0xC0
	cp 030h		;68ad   ; y mide 0x30
	jr nc,L_68B3		;68af
	ld (hl),0d0h		;68b1   ; fuera: se retira
L_68B3:
	ld a,(0e1abh)		;68b3   ; los topes
	add a,a			;68b6   ; por dos: el bit 7 al acarreo
	jr c,L_68D5		;68b7   ; con acarreo, se sale
	inc hl			;68b9   ; el byte siguiente
	ld a,(hl)			;68ba   ; el byte alto
	inc hl			;68bb
	ld e,(hl)			;68bc   ; y la variante
	ld h,a			;68bd   ; el alto, en H
	ld l,d			;68be   ; y la fila, en L
	ld a,(0e1aah)		;68bf   ; la direccion del movimiento
	rra			;68c2   ; su bit 0 al acarreo
	jr c,L_68CC		;68c3   ; con acarreo, sin desplazar
	dec b			;68c5   ; uno menos
	ld a,b			;68c6
	add a,a			;68c7   ; por ocho: el desplazamiento dentro del bloque
	add a,a			;68c8
	add a,a			;68c9
	add a,l			;68ca   ; sumado a la fila
	ld l,a			;68cb   ; guardada
L_68CC:
	bit 7,e		;68cc   ; el bit 7 de la variante
	jr nz,L_68D5		;68ce   ; con el puesto, se sale
	ld b,000h		;68d0   ; a cero
	call borra_la_celda_de_ahi		;68d2
L_68D5:
	pop hl			;68d5   ; se recuperan los tres
	pop de			;68d6
	pop bc			;68d7
	push hl			;68d8   ; y se guarda el primero
	inc hl			;68d9
	inc hl			;68da   ; dos bytes mas alla
	ld a,(hl)			;68db   ; el tipo
	and 0c0h		;68dc   ; los dos bits de arriba
	cp 0c0h		;68de   ; si son los dos, es especial
	pop hl			;68e0   ; se recupera
	jr z,L_68EC		;68e1
	ld a,(0e1abh)		;68e3
	add a,a			;68e6   ; los topes
	jr c,L_68EC		;68e7   ; con acarreo no se pinta
	call pinta_bloque_en_su_sitio		;68e9   ; y si no, se pinta en su sitio
L_68EC:
	pop bc			;68ec
	pop hl			;68ed
	inc hl			;68ee
	inc hl			;68ef   ; tres mas alla
	inc hl			;68f0
	djnz L_688E		;68f1   ; tres bytes por objeto

; ----------------------------------------------------------------------
; REPINTAR LOS OBJETOS que lo pidan -bit 6 de su tercer byte- y que no esten retirados. C lleva el numero de objeto, que hace de indice para saber donde va cada uno.
; ----------------------------------------------------------------------
repinta_los_objetos:
	ld a,(0e1abh)		;68f3
	add a,a			;68f6
	ret c			;68f7
	ld hl,0e134h		;68f8   ; los cuarenta
	ld b,028h		;68fb
L_68FD:
	push hl			;68fd
	push bc			;68fe
	bit 6,(hl)		;68ff   ; el bit 6: hay que repintarlo
	jr z,L_690D		;6901
	dec hl			;6903
	dec hl			;6904
	ld a,(hl)			;6905
	cp 0d0h		;6906   ; retirado: no
	jr z,L_690D		;6908
	call pinta_bloque_de_la_ficha		;690a
L_690D:
	pop bc			;690d
	pop hl			;690e
	inc hl			;690f
	inc hl			;6910
	inc hl			;6911
	inc c			;6912   ; el numero de objeto
	djnz L_68FD		;6913
	call corre_los_tres_con_el_decorado		;6915

; ----------------------------------------------------------------------
; CORRER TODOS LOS SPRITES CON EL DECORADO, ocho pixeles en el sentido que diga (0xE1AA): diecisiete de la banda de 0xE0E4 y cuatro de la de 0xE0C0. El que se sale de la pantalla se marca con la fila 0xC3.
; ----------------------------------------------------------------------
corre_los_sprites:
	ld a,(0e1aah)		;6918
	and 003h		;691b   ; los dos bits de direccion
	ret z			;691d
	ld c,a			;691e
	ld hl,0e0e4h		;691f   ; la banda grande
	ld b,011h		;6922   ; diecisiete sprites
	call corre_un_sprite		;6924
	ld hl,0e0c0h		;6927   ; y la pequena
	ld b,004h		;692a   ; cuatro
	call corre_un_sprite		;692c
	ld hl,0e104h		;692f
	ld de,03b54h		;6932   ; la tabla de atributos de la VRAM
	ld bc,00008h		;6935   ; ocho bytes
	jp vuelca_bloque		;6938
corre_un_sprite:
	ld a,(hl)			;693b   ; la fila del sprite
	sub 008h		;693c   ; ocho arriba
	cp 0b9h		;693e   ; si se sale de la banda util
	jr c,L_6946		;6940
	ld (hl),0c3h		;6942   ; 0xC3: fuera de la pantalla
	jr L_6950		;6944
L_6946:
	ld a,008h		;6946   ; ocho hacia abajo
	bit 1,c		;6948   ; el bit 1 cambia el sentido
	jr z,L_694E		;694a
	ld a,0f8h		;694c   ; u ocho hacia arriba
L_694E:
	add a,(hl)			;694e
	ld (hl),a			;694f
L_6950:
	inc hl			;6950   ; cuatro bytes por sprite
	inc hl			;6951
	inc hl			;6952
	inc hl			;6953
	djnz corre_un_sprite		;6954
	ret			;6956

; ----------------------------------------------------------------------
; ESTADO 7: trepando. Con el bit 0 pulsado solo se avanza uno de cada dos cuadros -es lo que hace que subir cueste-, y se mira si por encima hay un objeto con el que seguir. El valor 0x0A tiene su propio camino.
; ----------------------------------------------------------------------
estado_7_trepando:
	ld a,(0e009h)		;6957   ; lo que se pulsa
	rra			;695a
	jr nc,L_6962		;695b
	ld a,(0e003h)		;695d   ; el contador de cuadros
	rra			;6960   ; uno de cada dos
	ret nc			;6961
L_6962:
	ld a,(0e009h)		;6962   ; la lectura del mando
	and 003h		;6965   ; los dos bits de direccion
	ret z			;6967   ; sin direccion, nada que hacer
	rra			;6968   ; el bit 0 al acarreo
	jr nc,estado_alterno_trepando		;6969   ; con acarreo, el otro camino
	call paso_de_trepar_6		;696b   ; el paso 6
	call baja_si_puede		;696e   ; baja si puede
	call mira_los_objetos_de_cerca		;6971   ; y mira lo que tenga cerca
	ld a,(0e1b3h)		;6974   ; la posicion del jugador
	add a,008h		;6977   ; ocho por encima
	ld b,a			;6979   ; en B
	ld hl,0e1cfh		;697a   ; la ficha del objeto
	ld a,(hl)			;697d   ; su fila
	cp 0c0h		;697e   ; por encima de 0xC0 no hay nada
	ret nc			;6980   ; y entonces no hay objeto
	cp b			;6981   ; comparada con la del jugador
	ret c			;6982   ; por debajo, no llega
	call ancho_del_objeto		;6983   ; el ancho del objeto
	ld de,0e1cbh		;6986   ; el bufer del objeto de cerca
	push de			;6989   ; se guarda
	ld bc,00003h		;698a   ; sus tres bytes, copiados
	ldir		;698d   ; copiados
	ld (de),a			;698f   ; y el ancho detras
	pop hl			;6990   ; se recupera
	inc hl			;6991
	inc hl			;6992   ; dos bytes mas alla
	ld a,(hl)			;6993   ; lo que haya ahi
	cp 00ah		;6994   ; el valor 10, aparte
	jp z,L_6334		;6996   ; tiene su propio camino
	ld (0e056h),a		;6999   ; y si no, ese es el numero de fase
	jp llega_arriba_del_todo		;699c
estado_alterno_trepando:
	call paso_de_trepar_6		;699f   ; el paso 6
	call mira_los_objetos_de_cerca		;69a2   ; los objetos de cerca
	call mira_si_puede_subir		;69a5   ; y si puede subir
	ld hl,(0e1b3h)		;69a8   ; la posicion del jugador
	ld a,l			;69ab   ; la fila
	add a,024h		;69ac   ; treinta y seis por debajo
	ld l,a			;69ae   ; guardada
	call mira_los_cuarenta_objetos		;69af   ; mira si hay objeto ahi
	jp nc,mira_si_llego_al_suelo		;69b2   ; sin acarreo, mira si ha llegado al suelo
	jp L_6334		;69b5
paso_de_trepar_10:
	ld a,00ah		;69b8   ; el paso 10
	jr L_69BE		;69ba

; ----------------------------------------------------------------------
; EL PASO DEL DIBUJO AL TREPAR: 6 o 10 segun por donde se entre, y uno mas si el bit 2 de la posicion esta puesto. O sea que el dibujo alterna cada cuatro pixeles de subida, sin contador aparte.
; ----------------------------------------------------------------------
paso_de_trepar_6:
	ld a,006h		;69bc   ; o el 6
L_69BE:
	push af			;69be   ; se guarda
	call avanza_trepando		;69bf   ; y se trepa
	pop af			;69c2
	ld hl,0e1b3h		;69c3
	bit 2,(hl)		;69c6   ; el bit 2 de la posicion
	jr nz,L_69CB		;69c8
	inc a			;69ca   ; el otro dibujo
L_69CB:
	inc hl			;69cb
	inc hl			;69cc
	ld (hl),a			;69cd   ; y ese es el paso
	ret			;69ce
avanza_trepando:
	ld a,(0e009h)		;69cf   ; lo que se pulsa
	and 003h		;69d2   ; los dos bits de direccion
	ld (0e1b6h),a		;69d4
	ret z			;69d7
	ld hl,0e1b3h		;69d8
	rra			;69db   ; el bit 0: hacia arriba
	jr nc,L_69DF		;69dc
	dec a			;69de   ; o hacia abajo
L_69DF:
	call mueve_al_jugador		;69df
	ld a,002h		;69e2   ; y el sonido de trepar
	jp pide_un_sonido		;69e4

; ----------------------------------------------------------------------
; BUSCAR UN AGARRE en la lista de 0xE1D2, con ocho pixeles de margen. Si lo encuentra, guarda su valor con `ldd` -hacia atras- y devuelve acarreo.
; ----------------------------------------------------------------------
busca_en_la_lista_de_agarres:
	ld hl,0e1d2h		;69e7
	ld b,(hl)			;69ea   ; cuantos hay
L_69EB:
	inc hl			;69eb
	ld a,(0e1b4h)		;69ec
	sub (hl)			;69ef
	cp 008h		;69f0   ; ocho pixeles de margen
	jr c,L_69F8		;69f2
	djnz L_69EB		;69f4
	and a			;69f6
	ret			;69f7
L_69F8:
	ld de,0e1dah		;69f8
	ldd		;69fb   ; hacia atras
	ld a,(0e1cfh)		;69fd
	ld (de),a			;6a00
	scf			;6a01   ; acarreo: encontrado
	ret			;6a02
mira_los_objetos_de_cerca:
	ld hl,0e132h		;6a03
	ld b,028h		;6a06   ; los cuarenta objetos
L_6A08:
	ld a,(hl)			;6a08
	inc hl			;6a09
	inc hl			;6a0a
	cp 0d0h		;6a0b   ; retirado: al siguiente
	jr z,L_6A1C		;6a0d
	ld a,(hl)			;6a0f
	cp 087h		;6a10   ; los tres tipos que sirven para trepar
	jr z,L_6A21		;6a12
	cp 00ah		;6a14
	jr z,L_6A21		;6a16
	cp 08ah		;6a18
	jr z,L_6A21		;6a1a
L_6A1C:
	inc hl			;6a1c   ; tres bytes por objeto
	djnz L_6A08		;6a1d
	and a			;6a1f
	ret			;6a20
L_6A21:
	dec hl			;6a21
	dec hl			;6a22
	ld de,0e1cfh		;6a23   ; los tres bytes del objeto, copiados
	ld bc,00003h		;6a26
	ldir		;6a29
	ld hl,06a42h		;6a2b   ; la tabla de trece equivalencias
L_6A2E:
	cp (hl)			;6a2e
	jr z,L_6A3A		;6a2f
	ld c,(hl)			;6a31
	inc c			;6a32   ; un 0xFF la cierra
	ret z			;6a33
	inc hl			;6a34   ; cuatro bytes por entrada
	inc hl			;6a35
	inc hl			;6a36
	inc hl			;6a37
	jr L_6A2E		;6a38
L_6A3A:
	inc hl			;6a3a
	ld bc,00003h		;6a3b   ; y de ahi salen los tres que faltan
	ldir		;6a3e
	scf			;6a40   ; acarreo: encontrado
	ret			;6a41

; ----------------------------------------------------------------------
; DATOS guion_0x6A42: 13 bytes, 1 tramo, 10 bytes a la VRAM (0x010A); lo pinta
;   0x6A2C
;   0x6a42..0x6a4f  (13 bytes)
DATA_guion_0x6A42:
	defb 00ah,001h,0b0h,000h,087h,002h,040h,0a8h,08ah,002h,040h,0a8h,0ffh	; 6a42  ......@...@..

; ======================================================================
; CODIGO 0x6a4f..0x6bbb  (364 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ESTADO 6: agarrado a una rama. Con direccion horizontal se suelta -0x6A93-, y con vertical trepa o baja. Subir vuelve a costar uno de cada dos cuadros. Ademas mira el indice que hay bajo los pies: si es el 3, baja ocho y pasa al estado 4.
; ----------------------------------------------------------------------
estado_6_en_la_rama:
	ld a,(0e009h)		;6a4f
	ld b,a			;6a52
	and 00ch		;6a53   ; los bits de direccion horizontal
	jr z,L_6A5C		;6a55
	call se_acaba_de_pulsar_direccion		;6a57   ; y que se acabe de pulsar
	jr nz,se_suelta_de_la_rama		;6a5a
L_6A5C:
	ld a,b			;6a5c
	and 003h		;6a5d   ; los de direccion vertical
	ret z			;6a5f
	rra			;6a60   ; el bit 0
	jr nc,L_6A7C		;6a61
	ld a,(0e003h)		;6a63   ; el contador de cuadros
	rra			;6a66   ; uno de cada dos
	ret c			;6a67
	call paso_de_trepar_10		;6a68
	call baja_si_puede		;6a6b
	ld hl,(0e1b3h)		;6a6e
	ld bc,0000ch		;6a71   ; doce por debajo
	add hl,bc			;6a74
	call mira_los_cuarenta_objetos		;6a75   ; hay objeto ahi?
	ret nc			;6a78
	jp L_6334		;6a79
L_6A7C:
	call paso_de_trepar_10		;6a7c
	call mira_si_puede_subir		;6a7f
	call lee_las_dos_celdas_de_debajo		;6a82   ; lo que hay bajo los pies
	ld a,(0e1bfh)		;6a85
	cp 003h		;6a88   ; el indice 3
	ret nz			;6a8a
	ld a,008h		;6a8b   ; ocho hacia abajo
	call mueve_al_jugador		;6a8d
	jp estado_4_con_sonido		;6a90

; ----------------------------------------------------------------------
; SOLTARSE DE LA RAMA. El bit 3 de lo que se pulsa decide a que lado se cae: +0x0D o -5 en el byte alto de la posicion. La lectura del mando se congela DOS veces, en (0xE1B6) y en (0xE1B7), para que la caida siga la direccion con la que se solto.
; ----------------------------------------------------------------------
se_suelta_de_la_rama:
	ld hl,(0e1b3h)		;6a93
	ld a,(0e009h)		;6a96
	ld b,a			;6a99
	bit 3,a		;6a9a   ; el bit 3: hacia donde
	ld a,00dh		;6a9c   ; trece a un lado
	jr nz,L_6AA2		;6a9e
	ld a,0fbh		;6aa0   ; o cinco al otro
L_6AA2:
	add a,h			;6aa2
	ld h,a			;6aa3
	ld (0e1b3h),hl		;6aa4
	ld hl,0e1b5h		;6aa7
	ld (hl),005h		;6aaa   ; el paso, a cinco
	ld a,b			;6aac
	and 00ch		;6aad   ; la direccion, congelada
	inc hl			;6aaf
	ld (hl),a			;6ab0
	inc hl			;6ab1
	ld (hl),a			;6ab2
	ld hl,06576h		;6ab3   ; y el guion de la caida
	jp L_62DE		;6ab6
mira_el_digito_y_suelta:
	call mira_el_digito_de_la_altura		;6ab9
	ret nc			;6abc
	ld a,(0e05fh)		;6abd
	or a			;6ac0
	ret z			;6ac1
	ld a,(0e23ah)		;6ac2
	or a			;6ac5
	ret nz			;6ac6

; ----------------------------------------------------------------------
; EL BARRIDO DE LOS OBJETOS 0x80 Y 0x81, con la rutina a la que hay que llamar metida en DE y saltada con `ex de,hl / jp (hl)`: un salto indirecto hecho a mano. Solo se atienden los que caigan en la banda 0x18..0x90.
; ----------------------------------------------------------------------
	ld a,080h		;6ac7   ; el primer tipo que cuenta
	ld de,apunta_el_objeto_en_la_lista_de_tres		;6ac9   ; la rutina que se les aplica
L_6ACC:
	ld hl,0e137h		;6acc
	ld bc,02701h		;6acf   ; treinta y nueve, y C lleva el numero
L_6AD2:
	push af			;6ad2
	push de			;6ad3
	push hl			;6ad4
	push bc			;6ad5
	cp (hl)			;6ad6   ; este tipo
	jr z,L_6ADD		;6ad7
	inc a			;6ad9   ; o el siguiente
	cp (hl)			;6ada
	jr nz,L_6AED		;6adb
L_6ADD:
	dec hl			;6add
	dec hl			;6ade
	ld a,(hl)			;6adf
	cp 0d0h		;6ae0   ; retirado: no
	jr z,L_6AED		;6ae2
	sub 018h		;6ae4   ; la banda util empieza en 0x18
	cp 078h		;6ae6   ; y mide 0x78
	jr nc,L_6AED		;6ae8
	call salta_a_la_rutina_de_de		;6aea
L_6AED:
	pop bc			;6aed
	pop hl			;6aee
	pop de			;6aef
	pop af			;6af0
	inc hl			;6af1   ; tres bytes por objeto
	inc hl			;6af2
	inc hl			;6af3
	inc c			;6af4
	djnz L_6AD2		;6af5
	ret			;6af7
salta_a_la_rutina_de_de:
	ex de,hl			;6af8
	jp (hl)			;6af9   ; el salto indirecto: a donde diga DE

; ----------------------------------------------------------------------
; LA RUTINA QUE 0x6AC9 PASA EN DE, para los objetos de tipo 0x80 y 0x81. El recorrido de objetos no llama a una rutina fija: recibe su direccion en DE y la salta con `ex de,hl / jp (hl)` en 0x6AF8. Esta apunta el objeto en la lista de tres de 0xE21D si no estaba ya: primero lo busca, y si no aparece busca un hueco libre -un cero- y lo ocupa.
; ----------------------------------------------------------------------
apunta_el_objeto_en_la_lista_de_tres:
	ld a,c			;6afa   ; el numero de objeto, que es lo que se apunta
	call busca_en_la_lista_de_tres		;6afb   ; ya estaba apuntado?
	ret z			;6afe   ; si estaba, no hay nada que hacer
	xor a			;6aff   ; y si no, se busca un hueco libre: un cero
	call busca_en_la_lista_de_tres		;6b00
	ret nz			;6b03   ; sin hueco, se deja como esta
	dec hl			;6b04
	ld (hl),001h		;6b05   ; el hueco queda marcado
	inc hl			;6b07
	ld (hl),c			;6b08   ; con el numero de objeto
	inc hl			;6b09
	ld (hl),040h		;6b0a   ; y el plazo de 0x40
	ret			;6b0c

; ----------------------------------------------------------------------
; LA BUSQUEDA EN LA LISTA DE TRES: recorre las tres entradas de 0xE21D saltando de tres en tres y vuelve con Z si alguna vale lo que trae A. Sirve para las dos preguntas, porque buscar un hueco libre es buscar un cero.
; ----------------------------------------------------------------------
busca_en_la_lista_de_tres:
	ld hl,0e21dh		;6b0d   ; la lista de tres
	ld b,003h		;6b10   ; tres entradas
recorre_la_lista_de_tres:
	cp (hl)			;6b12   ; esta?
	ret z			;6b13
	inc hl			;6b14   ; tres bytes por entrada
	inc hl			;6b15
	inc hl			;6b16
	djnz recorre_la_lista_de_tres		;6b17
	ret			;6b19
mira_el_digito_de_la_altura:
	ld a,(0e1bch)		;6b1a   ; la altura en BCD
	and 0f0h		;6b1d   ; el nibble alto
	cp 050h		;6b1f   ; contra el 5
	ret			;6b21

; ----------------------------------------------------------------------
; LOS TRES PERSEGUIDORES, atendidos UNA VEZ DE CADA 32 CUADROS (`and 01fh`). Cada uno guarda en 0xE21C el numero del objeto al que sigue; si ese objeto se salio de la banda o ya no es de los tipos 0x80/0x81, se borra la ficha y su sprite se saca de la pantalla.
; ----------------------------------------------------------------------
mueve_los_tres_perseguidores:
	ld a,(0e003h)		;6b22   ; el contador de cuadros
	and 01fh		;6b25   ; uno de cada treinta y dos
	ret nz			;6b27
	ld hl,0e21ch		;6b28
	ld bc,00300h		;6b2b   ; tres perseguidores
L_6B2E:
	push hl			;6b2e   ; se guardan los dos
	push bc			;6b2f
	ld a,(hl)			;6b30   ; la ficha
	or a			;6b31   ; ficha vacia
	jr z,L_6B65		;6b32   ; vacia: al siguiente
	inc hl			;6b34   ; el byte siguiente
	ld a,(hl)			;6b35   ; el objeto al que sigue
	ld e,a			;6b36   ; en E
	add a,a			;6b37   ; por tres, que es lo que ocupa
	add a,e			;6b38   ; y uno mas
	ld de,0e132h		;6b39   ; la lista de objetos
	call suma_a_a_de		;6b3c   ; indexada
	ld a,(de)			;6b3f   ; su columna
	sub 018h		;6b40   ; la banda util
	cp 078h		;6b42   ; tiene que caber en 0x78
	jr nc,L_6B56		;6b44   ; y si no, el perseguidor se retira
	inc de			;6b46
	inc de			;6b47   ; dos bytes mas alla
	ld a,(de)			;6b48   ; el tipo del objeto
	cp 080h		;6b49
	jr z,L_6B51		;6b4b   ; el 0x80 vale
	cp 081h		;6b4d   ; y el 0x81 tambien
	jr nz,L_6B56		;6b4f   ; los demas, no
L_6B51:
	call pinta_un_perseguidor		;6b51   ; se pinta
	jr L_6B65		;6b54
L_6B56:
	xor a			;6b56   ; a cero
	ld (hl),a			;6b57   ; la ficha, borrada
	dec hl			;6b58   ; el byte de antes
	ld (hl),a			;6b59
	inc hl			;6b5a
	inc hl			;6b5b
	ld (hl),a			;6b5c
	ld hl,0e104h		;6b5d
	call hueco_de_sprite		;6b60
	ld (hl),0c3h		;6b63   ; y el sprite, fuera de la pantalla
L_6B65:
	pop bc			;6b65
	pop hl			;6b66
	inc hl			;6b67   ; tres bytes por perseguidor
	inc hl			;6b68
	inc hl			;6b69
	inc c			;6b6a
	djnz L_6B2E		;6b6b
	ret			;6b6d

; ----------------------------------------------------------------------
; PINTAR UN PERSEGUIDOR. Su contador avanza cada vez y, con el bit 6 puesto, dos bits del contador eligen uno de cuatro patrones de la tabla de 0x6BBB. El desplazamiento de la columna es 4 o 5 segun el tipo del objeto al que sigue, que es lo que le deja pegado a el.
; ----------------------------------------------------------------------
pinta_un_perseguidor:
	dec hl			;6b6e   ; el byte de antes
	bit 7,(hl)		;6b6f   ; el bit 7: no se pinta
	ret nz			;6b71   ; con el bit puesto, este no sale
	inc hl			;6b72
	inc hl			;6b73   ; dos mas alla
	inc (hl)			;6b74   ; su contador, uno mas
	ld a,(0e23ah)		;6b75
	or a			;6b78   ; si vale cero, no se pinta
	jr nz,saca_el_sprite_de_pantalla		;6b79
	ld a,(hl)			;6b7b   ; el contador
	bit 6,a		;6b7c   ; el bit 6
	jr z,saca_el_sprite_de_pantalla		;6b7e   ; sin el, tampoco
	and 006h		;6b80   ; dos bits del contador
	rra			;6b82   ; entre dos: queda el indice
	push de			;6b83   ; se guarda DE
	ld de,06bbbh		;6b84   ; los cuatro patrones
	call suma_a_a_de		;6b87   ; indexados
	ld a,(de)			;6b8a   ; el patron que toca
	ex af,af'			;6b8b   ; guardado en el acumulador alternativo
	pop de			;6b8c   ; y se recupera DE
	dec de			;6b8d
	dec de			;6b8e   ; dos bytes atras
	ex de,hl			;6b8f
	ld de,0e104h		;6b90   ; el bufer de atributos
	call hueco_de_sprite_en_de		;6b93   ; su hueco
	ld a,(hl)			;6b96   ; la fila
	add a,00dh		;6b97   ; trece pixeles de desplazamiento
	ld (de),a			;6b99   ; al atributo
	inc hl			;6b9a   ; el byte siguiente
	inc de			;6b9b
	ld c,(hl)			;6b9c   ; la columna, en C
	inc hl			;6b9d
	ld a,(hl)			;6b9e   ; y el tipo
	cp 080h		;6b9f   ; el tipo del objeto
	ld b,005h		;6ba1   ; cinco
	jr nz,L_6BA7		;6ba3   ; en los demas, cinco
	ld b,004h		;6ba5   ; o cuatro
L_6BA7:
	ld a,c			;6ba7   ; la columna
	sub b			;6ba8   ; menos el ajuste
	ld (de),a			;6ba9   ; al atributo
	inc de			;6baa
	ex de,hl			;6bab   ; se cambian
	ld (hl),0a0h		;6bac   ; el color del sprite
	ex af,af'			;6bae   ; el patron guardado
	inc hl			;6baf
	ld (hl),a			;6bb0   ; y al atributo
	ret			;6bb1
saca_el_sprite_de_pantalla:
	ld hl,0e104h		;6bb2
	call hueco_de_sprite		;6bb5   ; su hueco de sprite
	ld (hl),0c3h		;6bb8   ; 0xC3: fuera de la pantalla
	ret			;6bba

; ----------------------------------------------------------------------
; DATOS patrones_del_parpadeo: los cuatro patrones que 0x6B84 elige con dos
;   bits del contador: 0x00 0x04 0x0F 0x0C
;   0x6bbb..0x6bbf  (4 bytes)
DATA_patrones_del_parpadeo:
	defb 000h,004h,00fh,00ch	; 6bbb

; ======================================================================
; CODIGO 0x6bbf..0x6fab  (1004 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LOS TRES DE 0xE1DE, que solo se mueven cuando el decorado esta quieto. El ritmo lo dan los bits del contador de cuadros: uno de cada ocho en general, uno de cada cuatro si el bit 6 esta puesto, y con el bit 5 puesto no se mueven. El paso es +4 o -4 segun el bit 7 de su ficha.
; ----------------------------------------------------------------------
mueve_los_tres_de_la_lista:
	ld a,(0e1aah)		;6bbf   ; la direccion del decorado
	or a			;6bc2
	ret nz			;6bc3   ; si se esta moviendo, estos no
	ld hl,0e1deh		;6bc4
	ld b,003h		;6bc7   ; tres
bucle_de_los_tres:
	push hl			;6bc9
	push bc			;6bca
	ld a,(hl)			;6bcb
	inc hl			;6bcc
	or a			;6bcd   ; ficha vacia
	jr nz,L_6BD4		;6bce
	ld a,(hl)			;6bd0
	or a			;6bd1
	jr z,L_6C28		;6bd2
L_6BD4:
	inc hl			;6bd4
	ld c,(hl)			;6bd5
	ld a,(0e003h)		;6bd6   ; el contador de cuadros
	ld b,007h		;6bd9   ; uno de cada ocho
	bit 6,c		;6bdb   ; el bit 6: el doble de rapido
	jr nz,L_6BE3		;6bdd
	bit 4,c		;6bdf
	jr z,L_6BE5		;6be1
L_6BE3:
	ld b,003h		;6be3   ; uno de cada cuatro
L_6BE5:
	and b			;6be5
	jr nz,L_6C28		;6be6
	bit 5,c		;6be8   ; el bit 5 los para
	jr nz,L_6C28		;6bea
	push bc			;6bec
	ld a,c			;6bed
	ld bc,00004h		;6bee   ; cuatro pixeles
	bit 7,(hl)		;6bf1   ; el bit 7: hacia el otro lado
	jr z,L_6BF8		;6bf3
	ld bc,0fffch		;6bf5   ; cuatro hacia atras
L_6BF8:
	inc hl			;6bf8
	bit 3,a		;6bf9   ; el bit 3
	jr nz,L_6C00		;6bfb
	call suma_bc_a_la_posicion		;6bfd
L_6C00:
	pop bc			;6c00
	push hl			;6c01
	inc hl			;6c02
	inc hl			;6c03
	inc hl			;6c04

; ----------------------------------------------------------------------
; EL COLOR DEL BICHO, y aqui vuelve a salir el azar del registro R: por defecto 0xE1, o 0xE0 si el bit 2 esta a cero, y entonces una vez de cada dieciseis -`ld a,r / and 00fh`- se pone 0xE2. O sea que de vez en cuando parpadea de otro color, sin ningun contador.
; ----------------------------------------------------------------------
	ld (hl),0e1h		;6c05   ; el color por defecto
	bit 2,e		;6c07   ; el bit 2
	jr nz,L_6C19		;6c09
	ld (hl),0e0h		;6c0b   ; el otro color
	bit 6,c		;6c0d
	jr nz,L_6C17		;6c0f
	ld a,r		;6c11   ; el registro de refresco: el azar
	and 00fh		;6c13   ; una vez de cada dieciseis
	jr nz,L_6C19		;6c15
L_6C17:
	ld (hl),0e2h		;6c17   ; y el tercer color
L_6C19:
	pop hl			;6c19
	call marca_si_esta_en_pantalla		;6c1a   ; esta en pantalla?
	dec hl			;6c1d
	call decide_a_donde_va_el_bicho		;6c1e   ; a donde va
	inc hl			;6c21
	call pinta_el_bicho		;6c22
	call junta_las_dos_fichas		;6c25
L_6C28:
	pop bc			;6c28
	pop hl			;6c29
	ld a,009h		;6c2a   ; nueve bytes por ficha
	call suma_a_a_hl		;6c2c
	djnz bucle_de_los_tres		;6c2f
	ret			;6c31

; ----------------------------------------------------------------------
; LOS TRES DE 0xE1DE, corridos CON el decorado: ocho pixeles en el sentido que lleve (0xE1AA). Es la rutina contraria a la de arriba, que solo actua cuando el decorado esta quieto.
; ----------------------------------------------------------------------
corre_los_tres_con_el_decorado:
	ld a,(0e1aah)		;6c32   ; la direccion del decorado
	or a			;6c35
	ret z			;6c36   ; si esta quieto, aqui no hay nada que hacer
	ld hl,0e1deh		;6c37
	ld b,003h		;6c3a   ; tres
bucle_de_los_tres_con_decorado:
	push hl			;6c3c
	push bc			;6c3d
	ld a,(hl)			;6c3e
	inc hl			;6c3f
	or a			;6c40   ; ficha vacia
	jr nz,L_6C47		;6c41
	ld a,(hl)			;6c43
	or a			;6c44
	jr z,L_6C68		;6c45
L_6C47:
	inc hl			;6c47
	ld c,(hl)			;6c48
	ld a,(0e1aah)		;6c49
	rra			;6c4c   ; ocho hacia un lado
	ld bc,00008h		;6c4d
	jr c,L_6C55		;6c50
	ld bc,0fff8h		;6c52   ; u ocho hacia el otro
L_6C55:
	inc hl			;6c55
	call suma_bc_a_la_posicion		;6c56   ; se corre la ficha
	push hl			;6c59
	inc hl			;6c5a
	inc hl			;6c5b
	inc hl			;6c5c
	inc hl			;6c5d
	call suma_bc_a_la_posicion		;6c5e   ; y su pareja
	pop hl			;6c61
	call marca_si_esta_en_pantalla		;6c62
	call junta_las_dos_fichas		;6c65
L_6C68:
	pop bc			;6c68
	pop hl			;6c69
	ld a,009h		;6c6a   ; nueve bytes por ficha
	call suma_a_a_hl		;6c6c
	djnz bucle_de_los_tres_con_decorado		;6c6f
	ret			;6c71

; ----------------------------------------------------------------------
; SUMAR BC A UNA POSICION DE 16 BITS guardada del reves -byte alto primero-, que es como este cartucho guarda las posiciones de los bichos.
; ----------------------------------------------------------------------
suma_bc_a_la_posicion:
	ld d,(hl)			;6c72   ; el byte alto
	inc hl			;6c73
	ld e,(hl)			;6c74   ; y el bajo
	ex de,hl			;6c75
	add hl,bc			;6c76   ; sumado
	ex de,hl			;6c77
	ld (hl),e			;6c78   ; y devuelto en el mismo orden
	dec hl			;6c79
	ld (hl),d			;6c7a
	ret			;6c7b
marca_si_esta_en_pantalla:
	push hl			;6c7c
	call esta_dentro_de_la_pantalla		;6c7d
	dec hl			;6c80
	set 5,(hl)		;6c81   ; el bit 5: fuera de la pantalla
	jr c,L_6C8C		;6c83
	res 5,(hl)		;6c85   ; dentro: se pinta
	inc hl			;6c87
	inc hl			;6c88
	call pinta_bloque_de_la_ficha		;6c89
L_6C8C:
	pop hl			;6c8c
	ret			;6c8d

; ----------------------------------------------------------------------
; SI UNA POSICION CAE DENTRO DE LA PANTALLA: dos restas encadenadas de 16 bits, la de abajo (0xC0) y la de arriba, y el acarreo final lo dice. La segunda resta lleva 0xFF30, que es restar un numero negativo, o sea sumar.
; ----------------------------------------------------------------------
esta_dentro_de_la_pantalla:
	push hl			;6c8e
	ld d,(hl)			;6c8f   ; la posicion, guardada del reves
	inc hl			;6c90
	ld e,(hl)			;6c91
	ex de,hl			;6c92
	and a			;6c93
	ld bc,000c0h		;6c94   ; el limite de abajo
	sbc hl,bc		;6c97
	and a			;6c99
	ld bc,0ff30h		;6c9a   ; y el de arriba
	sbc hl,bc		;6c9d
	pop hl			;6c9f
	ret			;6ca0

; ----------------------------------------------------------------------
; LA DECISION DEL BICHO, que es la IA del cartucho y cabe en cincuenta instrucciones. Segun su tipo -los dos bits de abajo- usa una ventana u otra (0x20/0x40 o 0x18/0x20) y, por encima de esa distancia, se orienta HACIA EL JUGADOR comparando su posicion con la de el y poniendo o quitando el bit 7. El bit 3 marca si esta cerca, y ademas cuando esta a menos de 0x30 solo reacciona uno de cada cuatro cuadros en vez de uno de cada ocho: de cerca es mas nervioso.
; ----------------------------------------------------------------------
decide_a_donde_va_el_bicho:
	ld a,(hl)			;6ca1   ; su estado
	bit 5,a		;6ca2   ; el bit 5: fuera de la pantalla
	ret nz			;6ca4   ; fuera de la pantalla: no decide nada
	and 003h		;6ca5   ; los dos bits de tipo
	ret z			;6ca7   ; sin tipo, tampoco
	push hl			;6ca8   ; se guarda el puntero
	inc hl			;6ca9
	inc hl			;6caa   ; dos bytes mas alla
	ld c,(hl)			;6cab   ; su posicion
	inc hl			;6cac   ; el siguiente
	ld b,(hl)			;6cad   ; y la fila
	pop hl			;6cae   ; se recupera
	res 6,(hl)		;6caf   ; se limpia la marca de alcance
	cp 001h		;6cb1   ; el tipo 1 va aparte
	jr nz,L_6CC9		;6cb3   ; los demas, por el otro camino
	ld a,(0e1b4h)		;6cb5   ; la posicion del jugador
	sub b			;6cb8   ; menos la del bicho
	cp 008h		;6cb9   ; ocho pixeles
	ret nc			;6cbb   ; si no cabe, no lo alcanza
	ld a,(0e1b2h)		;6cbc   ; el estado del jugador
	cp 007h		;6cbf   ; y solo en el estado 7
	ret nz			;6cc1   ; en los demas no pasa nada
	ld a,(hl)			;6cc2   ; el estado del bicho
	or 0c0h		;6cc3   ; se marcan los dos bits de arriba
	res 3,a		;6cc5   ; y se le quita el 3
	ld (hl),a			;6cc7   ; guardado
	ret			;6cc8
L_6CC9:
	ld de,02040h		;6cc9   ; la ventana de un tipo
	cp 003h		;6ccc   ; el tipo 3
	jr nz,L_6CD5		;6cce   ; los otros, con la primera ventana
	ld de,01820h		;6cd0   ; y la del otro
	set 4,(hl)		;6cd3   ; y se le marca el bit 4
L_6CD5:
	ld a,b			;6cd5   ; la fila del bicho
	sub d			;6cd6   ; menos el alto de la ventana
	ld b,a			;6cd7   ; en B
	ld a,(0e1b4h)		;6cd8   ; la posicion del jugador
	sub b			;6cdb   ; menos la del bicho
	cp e			;6cdc   ; contra la ventana
	set 3,(hl)		;6cdd   ; se marca que esta cerca
	ret nc			;6cdf   ; y si no cabe, se deshace la marca
	res 3,(hl)		;6ce0   ; o que no
	cp 030h		;6ce2   ; la distancia
	ld e,008h		;6ce4   ; reacciona uno de cada ocho
	jr nc,L_6CEA		;6ce6   ; de lejos, uno de cada ocho
	ld e,004h		;6ce8   ; y de cerca, uno de cada cuatro
L_6CEA:
	ld a,(0e1b7h)		;6cea   ; el contador
	and e			;6ced
	ret nz			;6cee
	ld a,(0e1b3h)		;6cef   ; la otra coordenada del jugador
	sub 010h		;6cf2
	cp c			;6cf4
	res 7,(hl)		;6cf5   ; el bit 7 es hacia donde mira
	jr nc,L_6CFB		;6cf7
	set 7,(hl)		;6cf9   ; y se le da la vuelta si el jugador esta al otro lado
L_6CFB:
	ret			;6cfb
pinta_el_bicho:
	push hl			;6cfc
	dec hl			;6cfd
	ld c,(hl)			;6cfe
	bit 5,c		;6cff   ; el bit 5: fuera de la pantalla
	jr nz,L_6D3F		;6d01
	push hl			;6d03
	inc hl			;6d04
	inc hl			;6d05
	ld a,028h		;6d06   ; cuarenta pixeles
	bit 7,c		;6d08   ; el bit 7: hacia donde mira
	jr z,L_6D0E		;6d0a
	ld a,0f8h		;6d0c   ; u ocho hacia atras
L_6D0E:
	add a,(hl)			;6d0e
	ld e,a			;6d0f
	sub 018h		;6d10   ; la banda util
	cp 0a8h		;6d12
	ld a,004h		;6d14
	jr nc,L_6D3A		;6d16
	inc hl			;6d18
	ld d,(hl)			;6d19
	ex de,hl			;6d1a
	ld b,003h		;6d1b   ; tres celdas
	bit 7,c		;6d1d   ; el bit 7: hacia donde mira
	jr z,L_6D23		;6d1f
	ld b,002h		;6d21   ; dos si va al otro lado
L_6D23:
	push bc			;6d23
	call lee_la_celda_de_ahi		;6d24   ; que hay en esa celda
	pop bc			;6d27
	cp 003h		;6d28   ; el indice 3 es por donde puede pasar
	jr nz,L_6D3A		;6d2a
	ld a,008h		;6d2c   ; ocho pixeles
	bit 7,c		;6d2e
	jr z,L_6D33		;6d30
	add a,a			;6d32   ; o dieciseis
L_6D33:
	add a,h			;6d33
	ld h,a			;6d34
	djnz L_6D23		;6d35
	pop hl			;6d37
	jr L_6D3F		;6d38
L_6D3A:
	pop hl			;6d3a
	ld a,080h		;6d3b   ; y si no puede, se da la vuelta (bit 7)
	xor (hl)			;6d3d
	ld (hl),a			;6d3e
L_6D3F:
	pop hl			;6d3f
	ret			;6d40

; ----------------------------------------------------------------------
; JUNTAR LAS DOS FICHAS DE UN BICHO cuando las dos estan en pantalla: copia ocho bytes hacia atras con `lddr`, que es como la pareja sigue a la cabeza sin recalcular nada.
; ----------------------------------------------------------------------
junta_las_dos_fichas:
	call esta_dentro_de_la_pantalla		;6d41   ; la primera ficha en pantalla?
	ret nc			;6d44
	inc hl			;6d45   ; y la segunda, cuatro bytes mas alla
	inc hl			;6d46
	inc hl			;6d47
	inc hl			;6d48
	call esta_dentro_de_la_pantalla		;6d49
	ret nc			;6d4c
	ld d,h			;6d4d
	ld e,l			;6d4e
	inc hl			;6d4f
	ld (hl),000h		;6d50
	ld bc,00008h		;6d52   ; ocho bytes
	lddr		;6d55   ; hacia atras: la cola sigue a la cabeza
	ret			;6d57
busca_la_ficha_de_esa_posicion:
	ld hl,0e1deh		;6d58
	ld b,003h		;6d5b   ; tres fichas
L_6D5D:
	ld a,(hl)			;6d5d
	inc hl			;6d5e
	cp e			;6d5f   ; una coordenada
	jr nz,L_6D65		;6d60
	ld a,(hl)			;6d62
	cp d			;6d63   ; y la otra
	ret z			;6d64
L_6D65:
	ld a,008h		;6d65
	call suma_a_a_hl		;6d67   ; ocho bytes por ficha
	djnz L_6D5D		;6d6a
	ret			;6d6c

; ----------------------------------------------------------------------
; SOLTAR UN BICHO, y solo en el cuadro en que el contador da la vuelta a cero: una vez cada 256 cuadros, o sea cada cinco segundos largos.
; ----------------------------------------------------------------------
suelta_el_bicho_del_cuadro_cero:
	ld a,(0e003h)		;6d6d   ; el contador de cuadros
	or a			;6d70   ; solo cuando da la vuelta
	ret nz			;6d71
	ld de,apunta_el_objeto_en_la_lista_de_cinco		;6d72   ; la rutina que se les aplica
	ld a,093h		;6d75
	jp L_6ACC		;6d77

; ----------------------------------------------------------------------
; LA RUTINA QUE 0x6D72 PASA EN DE, para los objetos de tipo 0x93. Misma forma que la de 0x6AFA pero contra la lista de CINCO de 0xE1F9, y ademas le da un sprite al objeto: busca uno retirado entre los 39 de 0xE135 y lo pone a su nombre.
; ----------------------------------------------------------------------
apunta_el_objeto_en_la_lista_de_cinco:
	ld a,c			;6d7a   ; el numero de objeto
	call busca_en_la_lista_de_cinco		;6d7b   ; ya estaba apuntado?
	ret z			;6d7e
	xor a			;6d7f   ; y si no, un hueco libre
	call busca_en_la_lista_de_cinco		;6d80
	ret nz			;6d83
	push hl			;6d84   ; la ficha del objeto, a IX
	pop ix		;6d85
	push bc			;6d87
	ld de,0e135h		;6d88   ; los 39 sprites
	ld bc,02701h		;6d8b
busca_un_sprite_retirado:
	ld a,(de)			;6d8e   ; este esta retirado?
	cp 0d0h		;6d8f   ; 0xD0: retirado
	jr z,da_de_alta_el_sprite_del_objeto		;6d91
	inc de			;6d93   ; tres bytes por sprite
	inc de			;6d94
	inc de			;6d95
	inc c			;6d96
	djnz busca_un_sprite_retirado		;6d97
L_6D99:
	pop bc			;6d99   ; sin sprite libre, se deja
	ret			;6d9a
da_de_alta_el_sprite_del_objeto:
	ld hl,0e1fah		;6d9b   ; la otra columna de la lista
	ld a,c			;6d9e
	call recorre_la_lista_de_cinco_desde_hl		;6d9f   ; esta ya cogida?
	jr z,L_6D99		;6da2
	ld (ix+001h),c		;6da4   ; el sprite queda a nombre del objeto
	pop bc			;6da7
	ld (ix+000h),c		;6da8
	call hueco_de_sprite_por_indice		;6dab   ; su hueco en el bufer
	ld bc,00003h		;6dae   ; los tres bytes del sprite
	ldir		;6db1
	ex de,hl			;6db3
	dec hl			;6db4
	ld a,(hl)			;6db5
	cp 093h		;6db6   ; segun el tipo
	ld bc,0908bh		;6db8   ; un patron y un color
	jr z,L_6DC0		;6dbb
	ld bc,0a08eh		;6dbd   ; o los otros
L_6DC0:
	ld (hl),c			;6dc0
	ld (ix+002h),b		;6dc1
	ret			;6dc4
busca_en_la_lista_de_cinco:
	ld hl,0e1f9h		;6dc5   ; la lista de cinco
recorre_la_lista_de_cinco_desde_hl:
	ld b,005h		;6dc8   ; cinco entradas
recorre_la_lista_de_cinco:
	cp (hl)			;6dca   ; esta?
	ret z			;6dcb
	inc hl			;6dcc   ; tres bytes por entrada
	inc hl			;6dcd
	inc hl			;6dce
	djnz recorre_la_lista_de_cinco		;6dcf
	ret			;6dd1

; ----------------------------------------------------------------------
; EL BUCLE DE LOS CINCO MOVILES de 0xE1FB. Cada uno guarda el numero del objeto al que va pegado -por tres, que es lo que ocupa cada objeto-, y con IX y IY apuntando a los dos a la vez se decide si sube o baja segun el bit 7.
; ----------------------------------------------------------------------
mueve_los_cinco_moviles:
	ld hl,0e1fbh		;6dd2
	ld bc,00500h		;6dd5   ; cinco
L_6DD8:
	push hl			;6dd8   ; se guardan los dos
	push bc			;6dd9
	ld a,(hl)			;6dda   ; la ficha
	or a			;6ddb   ; ficha vacia
	jr z,L_6E1B		;6ddc   ; vacia: al siguiente
	push hl			;6dde   ; se copia el puntero a IY
	pop iy		;6ddf
	dec hl			;6de1   ; el byte de antes
	ld a,(hl)			;6de2   ; el numero de objeto
	add a,a			;6de3   ; el numero de objeto, por tres
	add a,(hl)			;6de4   ; por tres, que es lo que ocupa cada uno
	inc hl			;6de5   ; y vuelta
	ld de,0e132h		;6de6   ; la lista de objetos
	call suma_a_a_de		;6de9   ; indexada
	push de			;6dec   ; se copia a IX
	pop ix		;6ded
	ld a,(de)			;6def   ; su primer byte
	cp 0d0h		;6df0   ; retirado
	jr z,L_6E36		;6df2   ; retirado: nada que hacer
	ld a,(ix+002h)		;6df4   ; el tipo
	sub 08bh		;6df7   ; los tipos 0x8B a 0x8F
	cp 004h		;6df9   ; tienen que caber en cuatro
	jr c,L_6E01		;6dfb
	cp 005h		;6dfd   ; o ser el quinto
	jr nz,L_6E36		;6dff   ; y los demas no cuentan
L_6E01:
	bit 7,(hl)		;6e01   ; el bit 7: hacia donde
	jr z,L_6E0A		;6e03   ; sin el, el otro camino
	call espera_a_que_toque_moverse		;6e05   ; se espera al turno
	jr L_6E1B		;6e08
L_6E0A:
	call caja_del_movil_contra_el_jugador		;6e0a   ; y se mira contra el jugador
	jr c,el_movil_alcanza_al_jugador		;6e0d
	bit 6,(hl)		;6e0f   ; el bit 6: una rutina u otra
	jr z,L_6E18		;6e11
	call avanza_el_movil_despacio		;6e13
	jr L_6E1B		;6e16
L_6E18:
	call avanza_el_movil_rapido		;6e18
L_6E1B:
	pop bc			;6e1b
	pop hl			;6e1c
	inc hl			;6e1d   ; tres bytes por ficha
	inc hl			;6e1e
	inc hl			;6e1f
	inc c			;6e20
	djnz L_6DD8		;6e21
	ret			;6e23
el_movil_alcanza_al_jugador:
	ex de,hl			;6e24
	ld c,(hl)			;6e25   ; su posicion
	inc hl			;6e26
	ld b,(hl)			;6e27
	dec hl			;6e28
	ex de,hl			;6e29
	push bc			;6e2a
	call retira_el_movil		;6e2b
	pop bc			;6e2e
	ld a,004h		;6e2f   ; el sonido del golpe
	call suma_los_puntos_del_tipo		;6e31
	jr L_6E1B		;6e34
L_6E36:
	call borra_la_ficha		;6e36
	jr L_6E1B		;6e39

; ----------------------------------------------------------------------
; LA CAJA DE UN MOVIL, de 0x10 por 0x10, con el desplazamiento cambiado segun el tipo: el 0x8C no lleva los cuatro pixeles de correccion y el 0x90 lleva ocho en la otra coordenada. Cada bicho tiene su caja, y no hay una tabla: son dos `cp` y dos valores.
; ----------------------------------------------------------------------
caja_del_movil_contra_el_jugador:
	push hl			;6e3b
	push de			;6e3c
	ex de,hl			;6e3d
	ld b,(hl)			;6e3e   ; su posicion
	inc hl			;6e3f
	ld c,(hl)			;6e40
	inc hl			;6e41
	ld a,(hl)			;6e42
	ld d,004h		;6e43   ; cuatro de correccion
	cp 08ch		;6e45   ; salvo el tipo 0x8C
	jr nz,L_6E4B		;6e47
	ld d,000h		;6e49   ; que no lleva ninguna
L_6E4B:
	ld e,004h		;6e4b   ; cuatro en la otra
	cp 090h		;6e4d   ; y el 0x90
	jr nz,L_6E53		;6e4f
	ld e,008h		;6e51   ; lleva ocho
L_6E53:
	ld a,b			;6e53   ; la posicion, corregida
	sub d			;6e54
	ld b,a			;6e55
	ld a,c			;6e56
	sub e			;6e57   ; en las dos coordenadas
	ld c,a			;6e58
	ld de,01010h		;6e59   ; dieciseis por dieciseis
	call mira_tres_cajas		;6e5c
	pop de			;6e5f
	pop hl			;6e60
	ret			;6e61

; ----------------------------------------------------------------------
; EL RITMO DEL MOVIL: una vez de cada dieciseis cuadros, y ademas con el bit 1 de su contador puesto no se hace nada -o sea, se mueve dos veces y descansa dos-. El umbral del nibble bajo cambia con la fase: 6 de la tercera en adelante, 11 antes.
; ----------------------------------------------------------------------
espera_a_que_toque_moverse:
	ld a,(0e003h)		;6e62   ; el contador de cuadros
	and 00fh		;6e65   ; uno de cada dieciseis
	ret nz			;6e67
	inc (hl)			;6e68   ; su propio contador, uno mas
	push hl			;6e69
	bit 1,(hl)		;6e6a   ; el bit 1: dos y dos
	jr nz,L_6EAC		;6e6c
	ex de,hl			;6e6e
L_6E6F:
	call pinta_bloque_de_la_ficha		;6e6f
	pop hl			;6e72
	ld a,(hl)			;6e73
	ld c,a			;6e74
	and 00fh		;6e75   ; el nibble bajo
	ld b,a			;6e77
	ld a,(0e051h)		;6e78   ; el numero de fase
	cp 003h		;6e7b
	ld a,006h		;6e7d   ; de la tercera en adelante, seis
	jr nc,L_6E83		;6e7f
	ld a,00bh		;6e81   ; y antes, once
L_6E83:
	cp b			;6e83
	ret nz			;6e84
	ld a,c			;6e85
	and 070h		;6e86
	or 040h		;6e88   ; se marca el bit 6
	ld (hl),a			;6e8a
	push ix		;6e8b
	pop hl			;6e8d
	ld a,(hl)			;6e8e
	sub 008h		;6e8f   ; ocho pixeles
	ld (hl),a			;6e91
	inc hl			;6e92
	ld a,0e8h		;6e93   ; veinticuatro hacia atras
	bit 4,c		;6e95   ; el bit 4 elige el sentido
	jr nz,L_6E9B		;6e97
	ld a,008h		;6e99   ; u ocho hacia delante
L_6E9B:
	add a,(hl)			;6e9b
	ld (hl),a			;6e9c
	inc hl			;6e9d
	ld (hl),08ch		;6e9e   ; el tipo 0x8C
	dec hl			;6ea0
	dec hl			;6ea1
	jp pinta_bloque_de_la_ficha		;6ea2
borra_la_ficha:
	xor a			;6ea5
	ld (hl),a			;6ea6   ; los tres bytes, a cero
	dec hl			;6ea7
	ld (hl),a			;6ea8
	dec hl			;6ea9
	ld (hl),a			;6eaa
	ret			;6eab
L_6EAC:
	dec hl			;6eac
	dec hl			;6ead
	ld c,(hl)			;6eae
	call hueco_de_sprite_por_indice		;6eaf
	jr L_6E6F		;6eb2

; ----------------------------------------------------------------------
; EL MOVIL LENTO: se atiende una vez de cada dieciseis cuadros, y ademas su propio contador sube solo una vez de cada 32, hasta el tope de 15. Y antes de avanzar MIRA LA PANTALLA: cuenta cuatro celdas hacia abajo y, si alguna no tiene el indice 3, no puede pasar.
; ----------------------------------------------------------------------
avanza_el_movil_despacio:
	ld a,(0e003h)		;6eb4
	ld b,a			;6eb7
	and 00fh		;6eb8   ; uno de cada dieciseis
	ret nz			;6eba
	ld a,b			;6ebb
	and 01fh		;6ebc   ; uno de cada treinta y dos
	jr nz,L_6EC8		;6ebe
	ld a,(hl)			;6ec0
	and 00fh		;6ec1   ; el nibble bajo
	cp 00fh		;6ec3   ; el tope, quince
	jr z,L_6EC8		;6ec5
	inc (hl)			;6ec7   ; uno mas
L_6EC8:
	push hl			;6ec8
	push de			;6ec9
	ld a,014h		;6eca   ; veinte pixeles
	bit 4,(hl)		;6ecc   ; el bit 4: hacia arriba
	jr z,L_6ED2		;6ece
	ld a,0f8h		;6ed0   ; u ocho hacia atras
L_6ED2:
	add a,(ix+001h)		;6ed2
	ld h,a			;6ed5
	ld a,(de)			;6ed6
	ld l,a			;6ed7
	sub 028h		;6ed8   ; la banda util
	cp 078h		;6eda
	jr nc,L_6EF5		;6edc
	call lee_la_celda_de_ahi		;6ede   ; que hay en esa celda
	cp 003h		;6ee1   ; el indice 3 es por donde se puede pasar
	jr nz,el_movil_se_agota		;6ee3
	ld b,004h		;6ee5   ; cuatro celdas
L_6EE7:
	ld a,020h		;6ee7   ; la de abajo, 32 mas alla
	call suma_a_a_de		;6ee9
	call lee_de_vram		;6eec   ; leida de la pantalla
	cp 003h		;6eef   ; y todas tienen que ser el 3
	jr nz,L_6F52		;6ef1
	djnz L_6EE7		;6ef3
L_6EF5:
	pop de			;6ef5   ; los dos punteros que dejo quien llama
	pop hl			;6ef6
	push hl			;6ef7   ; y se vuelven a apilar, que repintar los gasta
	push de			;6ef8
	call repinta_el_movil		;6ef9
	pop de			;6efc
	pop hl			;6efd
	ld a,(de)			;6efe
	sub 028h		;6eff   ; la banda util de este movil
	cp 078h		;6f01   ; y lo ancha que es
	ld a,000h		;6f03   ; fuera de ella no se mueve
	jr nc,L_6F0F		;6f05
	ld a,004h		;6f07   ; cuatro pixeles
	bit 4,(hl)		;6f09   ; el bit 4: hacia el otro lado
	jr z,L_6F0F		;6f0b
	ld a,0fch		;6f0d   ; o cuatro hacia atras
L_6F0F:
	ld c,a			;6f0f   ; el paso, apartado: abajo se le mira un bit
	ex de,hl			;6f10
	inc hl			;6f11   ; el byte de la posicion
	add a,(hl)			;6f12   ; mas el paso
	ld (hl),a			;6f13
	inc hl			;6f14
	bit 2,c		;6f15   ; el bit 2 del PASO, no del estado
	jr z,L_6F23		;6f17
	ld (hl),08ch		;6f19   ; un dibujo
	bit 2,a		;6f1b   ; el bit 2 elige el otro dibujo
	jr z,L_6F21		;6f1d
	ld (hl),08dh		;6f1f
L_6F21:
	jr L_6F2C		;6f21
L_6F23:
	ld a,(hl)			;6f23   ; el dibujo de ahora
	cp 08ch		;6f24   ; el dibujo alterna entre 0x8C y 0x90
	ld (hl),090h		;6f26   ; se escribe uno
	jr z,L_6F2C		;6f28
	ld (hl),08ch		;6f2a   ; y si ya estaba, el otro: alternan
L_6F2C:
	dec hl			;6f2c   ; de vuelta al principio de la ficha
	dec hl			;6f2d
	call pinta_bloque_de_la_ficha		;6f2e
	ld a,001h		;6f31   ; y el sonido del movil
	jp pide_un_sonido		;6f33

; ----------------------------------------------------------------------
; EL MOVIL QUE SE AGOTA. Los tipos 0x86 y 0x8A tienen cuenta atras: cuando su nibble bajo llega a 15, se borra la ficha y el objeto queda retirado. Y con el indice 0x9B delante se le quita el bit 6, o sea que cambia de modo.
; ----------------------------------------------------------------------
el_movil_se_agota:
	pop de			;6f36
	pop hl			;6f37
	cp 086h		;6f38   ; los dos tipos con cuenta atras
	jr z,L_6F40		;6f3a
	cp 08ah		;6f3c
	jr nz,L_6F54		;6f3e
L_6F40:
	ld a,(hl)			;6f40   ; su byte de estado
	and 00fh		;6f41   ; el nibble bajo
	cp 00fh		;6f43   ; el tope, quince
	jr nz,L_6F5A		;6f45   ; mientras no llegue al tope, sigue
retira_el_movil:
	call borra_la_ficha		;6f47   ; se borra la ficha
	call repinta_el_movil		;6f4a   ; y el hueco que dejo, repintado
	ld (ix+000h),0d0h		;6f4d   ; y el objeto queda retirado
	ret			;6f51
L_6F52:
	pop de			;6f52
	pop hl			;6f53
L_6F54:
	cp 09bh		;6f54   ; el indice 0x9B
	jr nz,L_6F5A		;6f56
	res 6,(hl)		;6f58   ; le quita el bit 6
L_6F5A:
	ld a,030h		;6f5a   ; y le da la vuelta a los bits 4 y 5
	xor (hl)			;6f5c   ; los dos bits que dicen hacia donde va
	ld (hl),a			;6f5d
	ret			;6f5e

; ----------------------------------------------------------------------
; EL MOVIL RAPIDO: una vez de cada dieciseis cuadros, y mira DOS celdas -no cuatro- antes de avanzar. Otra vez preguntandole a la pantalla si por ahi se puede pasar.
; ----------------------------------------------------------------------
avanza_el_movil_rapido:
	ld a,(0e003h)		;6f5f   ; el contador de cuadros
	and 00fh		;6f62   ; uno de cada dieciseis
	ret nz			;6f64   ; en los otros quince no se mueve
	push hl			;6f65   ; los dos punteros, guardados
	push de			;6f66
	ld a,024h		;6f67   ; treinta y seis pixeles
	bit 4,(hl)		;6f69   ; el bit 4: hacia arriba
	jr z,L_6F6F		;6f6b   ; con el bit a cero, hacia delante
	ld a,0f8h		;6f6d   ; u ocho hacia atras
L_6F6F:
	ex de,hl			;6f6f
	add a,(hl)			;6f70   ; la posicion mas el paso
	ld e,a			;6f71
	inc hl			;6f72
	ld d,(hl)			;6f73   ; y la otra coordenada, sin tocar
	ex de,hl			;6f74
	ld b,002h		;6f75   ; dos celdas
L_6F77:
	call lee_la_celda_de_ahi		;6f77   ; que hay ahi
	cp 003h		;6f7a   ; el indice 3 es por donde se puede pasar
	jr nz,L_6F9D		;6f7c   ; si no se puede pasar, no se avanza
	ld a,h			;6f7e
	add a,008h		;6f7f   ; la celda de debajo
	ld h,a			;6f81
	djnz L_6F77		;6f82   ; y las dos que hay que mirar
	pop de			;6f84   ; los punteros, de vuelta
	pop hl			;6f85
	push hl			;6f86
	push de			;6f87
	call repinta_el_movil		;6f88
	pop de			;6f8b
	pop hl			;6f8c
	ld a,004h		;6f8d   ; cuatro pixeles
	bit 4,(hl)		;6f8f   ; el bit 4
	jr z,L_6F95		;6f91
	ld a,0fch		;6f93   ; o cuatro hacia atras
L_6F95:
	ex de,hl			;6f95
	add a,(hl)			;6f96   ; aplicado a la posicion
	ld (hl),a			;6f97
	inc hl			;6f98
	inc hl			;6f99   ; y al byte del dibujo
	jp L_6F23		;6f9a   ; el dibujo lo cambia el mismo trozo de arriba
L_6F9D:
	pop de			;6f9d
	pop hl			;6f9e
	jr L_6F5A		;6f9f   ; y si no se puede pasar, se da la vuelta
repinta_el_movil:
	ex de,hl			;6fa1   ; esta puerta recibe la ficha en DE
repinta_el_objeto:
	call elige_la_tabla_de_piezas		;6fa2
	ld de,06fabh		;6fa5   ; su tabla de patrones
	jp pinta_bloque_en_su_sitio		;6fa8   ; y se pinta donde le toque

; ----------------------------------------------------------------------
; DATOS doce_celdas_en_blanco: doce bytes, todos 0x03 -el patron vacio-;
;   0x6FA5 los pasa como "tabla de patrones" para borrar la pieza
;   0x6fab..0x6fb7  (12 bytes)
DATA_doce_celdas_en_blanco:
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; 6fab  ............

; ======================================================================
; CODIGO 0x6fb7..0x71ff  (584 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL PREMIO SOLO SALE DE LA SEXTA FASE EN ADELANTE, con el bit 0 de (0xE05E) a cero y en el cuadro en que el contador da la vuelta: una vez cada 256 cuadros.
; ----------------------------------------------------------------------
suelta_el_premio_de_la_fase_6:
	ld a,(0e051h)		;6fb7   ; el numero de fase
	cp 006h		;6fba   ; de la sexta en adelante
	ret c			;6fbc   ; antes de la sexta no hay premio
	ld a,(0e05eh)		;6fbd
	rra			;6fc0   ; y solo en uno de los dos sentidos de la fase
	ret c			;6fc1
	ld a,(0e003h)		;6fc2
	or a			;6fc5   ; justo en el cuadro en que el contador da la vuelta
	ret nz			;6fc6
L_6FC7:
	ld de,0e132h		;6fc7   ; la lista de objetos
	ld b,028h		;6fca   ; cuarenta entradas

; ----------------------------------------------------------------------
; BUSCAR UN OBJETO QUE VALGA: ni retirado, ni fuera de la banda 0x18..0xA0, y de los tipos 0x93 o 0x94.
; ----------------------------------------------------------------------
busca_un_objeto_util:
	ld a,(de)			;6fcc   ; el primer byte de la ficha
	inc de			;6fcd   ; dos mas alla esta el tipo
	inc de			;6fce
	cp 0d0h		;6fcf   ; retirado
	jr z,L_6FE0		;6fd1   ; los retirados no valen
	sub 018h		;6fd3   ; la banda util
	cp 088h		;6fd5   ; y lo ancha que es
	jr nc,L_6FE0		;6fd7
	ld a,(de)			;6fd9
	sub 093h		;6fda   ; los tipos 0x93 y 0x94
	cp 002h		;6fdc   ; dos tipos seguidos
	jr c,L_6FE4		;6fde
L_6FE0:
	inc de			;6fe0   ; al objeto siguiente: cinco bytes por ficha, dos ya avanzados
	djnz busca_un_objeto_util		;6fe1
	ret			;6fe3
L_6FE4:
	dec de			;6fe4   ; de vuelta al principio de la ficha buena
	dec de			;6fe5
	ld hl,0e208h		;6fe6   ; y ahora se busca hueco en la lista de premios
	ld bc,00300h		;6fe9
L_6FEC:
	ld a,(hl)			;6fec
	or a			;6fed   ; hueco vacio
	jr z,coloca_el_premio		;6fee
	inc hl			;6ff0   ; cinco bytes por hueco
	inc hl			;6ff1
	inc hl			;6ff2
	inc hl			;6ff3
	inc hl			;6ff4
	inc c			;6ff5   ; y el indice va subiendo con el
	djnz L_6FEC		;6ff6
	ret			;6ff8

; ----------------------------------------------------------------------
; COLOCAR EL PREMIO, y aqui el azar vuelve a aparecer: `ld a,r / and 007h` -una entre ocho- decide si el color es 5 o el que hubiera. Se copian dos bytes de la ficha y se le ponen los patrones 0x90 y 0x88.
; ----------------------------------------------------------------------
coloca_el_premio:
	push hl			;6ff9
	ex de,hl			;6ffa
	ld de,0e0e4h		;6ffb   ; su hueco de sprite
	call hueco_de_sprite_en_de		;6ffe   ; el hueco de sprite que le toca
	ld bc,00002h		;7001   ; dos bytes
	ldir		;7004   ; las dos coordenadas, copiadas del objeto
	ex de,hl			;7006
	ld (hl),090h		;7007   ; el patron
	inc hl			;7009   ; y detras el color
	ld (hl),00fh		;700a   ; y su color
	pop hl			;700c
	ld (hl),088h		;700d   ; el otro patron
	inc hl			;700f   ; el byte del color
	ld a,r		;7010   ; el contador de refresco: el azar
	and 007h		;7012   ; una entre ocho
	jr nz,L_7018		;7014   ; las otras siete veces se queda con lo que hubiera
	ld a,005h		;7016   ; y entonces el color 5
L_7018:
	ld (hl),a			;7018   ; el color
	inc hl			;7019   ; el mismo color en los dos bytes
	ld (hl),a			;701a
	inc hl			;701b
	ld (hl),000h		;701c   ; y el tercer byte, a cero
	ret			;701e
mueve_los_premios:
	ld de,0e208h		;701f   ; la lista de premios
	ld bc,00300h		;7022   ; tres, y el indice empieza en cero

; ----------------------------------------------------------------------
; EL REPARTO POR TIPO DE BICHO: los bits 7, 6 y 5 de su estado eligen entre cuatro maneras de moverse. IX apunta a su ficha e IY a su hueco de sprite, de modo que las rutinas de abajo no vuelven a buscarlos.
; ----------------------------------------------------------------------
mueve_un_bicho_por_su_tipo:
	push de			;7025
	push bc			;7026   ; la ficha y el indice, guardados para el final del bucle
	ld a,(de)			;7027   ; el estado del bicho
	or a			;7028   ; parado
	jr z,L_706E		;7029
	ld b,a			;702b   ; el estado, apartado: los tres bits se miran uno a uno
	push de			;702c   ; su ficha
	pop ix		;702d   ; IX se queda con la ficha, y ya no hay que buscarla mas
	ld hl,0e0e4h		;702f   ; su hueco de sprite
	call hueco_de_sprite		;7032   ; y IY con su hueco de sprite
	push hl			;7035
	pop iy		;7036
	call mira_si_el_bicho_se_ve		;7038   ; esta en pantalla?
	jr nc,L_706E		;703b   ; fuera de la pantalla no se mueve
	bit 7,b		;703d   ; el bit 7
	jr z,L_7046		;703f
	call avanza_el_bicho_del_guion		;7041
	jr L_706E		;7044
L_7046:
	bit 6,b		;7046   ; y si no, el 6
	jr z,L_704F		;7048
	call avanza_el_bicho_que_cambia		;704a
	jr mira_el_premio_de_cerca		;704d
L_704F:
	call avanza_el_bicho_lento		;704f   ; y sin ninguno de los dos, el lento
mira_el_premio_de_cerca:
	bit 4,(ix+000h)		;7052   ; el bit 4
	jr nz,L_706E		;7056   ; con el bit 4 puesto, este no coge premios
	push iy		;7058
	pop hl			;705a   ; la posicion del bicho
	ld a,(hl)			;705b
	sub 008h		;705c   ; ocho pixeles
	ld b,a			;705e   ; apartada en B
	inc hl			;705f
	ld a,(hl)			;7060
	sub 004h		;7061   ; y cuatro en la otra
	ld c,a			;7063   ; y la otra en C
	ld de,00c0ch		;7064   ; doce por doce de caja
	push bc			;7067
	call mira_tres_cajas		;7068   ; contra los tres premios
	pop bc			;706b
	jr c,el_bicho_alcanza_al_premio		;706c
L_706E:
	pop bc			;706e   ; el indice y la ficha, de vuelta
	pop de			;706f
	ld a,005h		;7070   ; cinco bytes por ficha
	call suma_a_a_de		;7072   ; a la ficha siguiente
	inc c			;7075   ; y el indice, uno mas
	djnz mueve_un_bicho_por_su_tipo		;7076
	ret			;7078
el_bicho_alcanza_al_premio:
	ld a,c			;7079   ; las dos coordenadas se cruzan: la rutina de abajo las quiere al reves
	ld c,b			;707a
	ld b,a			;707b
	ld a,004h		;707c   ; el sonido
	call suma_los_puntos_del_tipo		;707e   ; los puntos salen del tipo del bicho
	push ix		;7081
	pop hl			;7083   ; la ficha del bicho
	ld (hl),031h		;7084   ; el patron del golpe
	inc hl			;7086
	inc hl			;7087   ; dos bytes mas alla, el dibujo
	call repinta_el_hueco		;7088
	jr L_706E		;708b
esta_en_la_banda_util:
	ld a,(hl)			;708d   ; la coordenada
	sub 010h		;708e   ; la banda util de la pantalla
	cp 0b1h		;7090
L_7092:
	ret c			;7092
	ld (hl),0c3h		;7093   ; fuera de ella, el patron 0xC3: se deja de ver
	xor a			;7095
	ld (de),a			;7096   ; y el hueco queda libre
	ret			;7097
mira_si_el_bicho_se_ve:
	ld a,(hl)			;7098
	sub 008h		;7099
	cp 0b9h		;709b   ; que aqui es un poco mas ancha
	jr L_7092		;709d

; ----------------------------------------------------------------------
; MIRAR TRES CAJAS SEGUIDAS -tres huecos consecutivos de la lista-, cada una de D por E. Devuelve acarreo en la primera que casa.
; ----------------------------------------------------------------------
mira_tres_cajas:
	ld hl,0e114h		;709f
	ld a,003h		;70a2   ; tres
L_70A4:
	ex af,af'			;70a4
	ld a,(hl)			;70a5
	inc hl			;70a6
	cp 0c0h		;70a7   ; por encima de 0xC0 no cuenta
	jr nc,L_70B3		;70a9
	sub b			;70ab
	cp d			;70ac   ; la ventana de una coordenada
	jr nc,L_70B3		;70ad
	ld a,(hl)			;70af
	sub c			;70b0
	cp e			;70b1   ; y la de la otra
	ret c			;70b2
L_70B3:
	inc hl			;70b3   ; tres bytes por hueco
	inc hl			;70b4
	inc hl			;70b5
	ex af,af'			;70b6
	dec a			;70b7
	jr nz,L_70A4		;70b8
	and a			;70ba
	ret			;70bb

; ----------------------------------------------------------------------
; EL BICHO QUE CAMBIA DE PASO, atendido uno de cada cuatro cuadros. Su contador sube o baja segun el bit 3 de lo que se pulsa -o sea, el bicho reacciona a lo que hace el jugador- y de los bits 2 salen los patrones: 0x20 o 0x24, mas 0x28 si el otro bit esta puesto.
; ----------------------------------------------------------------------
avanza_el_bicho_que_cambia:
	ld a,(0e003h)		;70bc   ; el contador de cuadros
	and 003h		;70bf   ; uno de cada cuatro
	ret nz			;70c1
	inc hl			;70c2
	ld a,b			;70c3
	and 00ch		;70c4   ; los dos bits de direccion
	jr z,L_70CF		;70c6
	inc (hl)			;70c8   ; su contador, uno mas
	bit 3,a		;70c9   ; el bit 3
	jr nz,L_70CF		;70cb
	dec (hl)			;70cd   ; o dos menos
	dec (hl)			;70ce
L_70CF:
	ld c,(hl)			;70cf
	inc hl			;70d0
	bit 2,c		;70d1   ; el bit 2 elige el patron
	ld a,020h		;70d3   ; uno
	jr nz,L_70D9		;70d5
	ld a,024h		;70d7   ; o el otro
L_70D9:
	bit 2,b		;70d9
	jr z,L_70DF		;70db
	add a,028h		;70dd   ; y 0x28 mas si toca
L_70DF:
	ld (hl),a			;70df
	dec hl			;70e0
	dec hl			;70e1
	call mira_si_hay_hueco_delante		;70e2
	ret c			;70e5
le_da_la_vuelta_al_bicho:
	ex de,hl			;70e6
	ld a,(hl)			;70e7
	xor 00ch		;70e8   ; le da la vuelta a los bits 2 y 3
	ld (hl),a			;70ea
	inc hl			;70eb
	inc hl			;70ec
	dec (hl)			;70ed   ; su cuenta atras
	ret nz			;70ee
	dec hl			;70ef
	dec hl			;70f0
	ld a,028h		;70f1   ; un patron
	bit 3,(hl)		;70f3   ; el bit 3
	jr z,L_70F9		;70f5
	ld a,024h		;70f7   ; o el otro
L_70F9:
	ld (hl),a			;70f9
	inc hl			;70fa
	ld a,(hl)			;70fb
	inc hl			;70fc
	ld (hl),a			;70fd

; ----------------------------------------------------------------------
; Y OTRA VEZ EL AZAR DEL REGISTRO R: el bit 4 del contador de refresco decide cual de los DOS guiones se le engancha al bicho, el de 0x6576 o el de 0x6572. Sin semilla, sin tabla y sin gastar un solo byte de RAM.
; ----------------------------------------------------------------------
	ld a,r		;70fe   ; el contador de refresco del Z80
	bit 4,a		;7100   ; su bit 4
	ld bc,06576h		;7102   ; un guion
	jr nz,L_710A		;7105
repinta_el_hueco:
	ld bc,06572h		;7107   ; o el otro
L_710A:
	inc hl			;710a
	ld (hl),c			;710b
	inc hl			;710c
	ld (hl),b			;710d
	ret			;710e
avanza_el_bicho_lento:
	ld a,(0e003h)		;710f   ; el contador de cuadros
	rra			;7112   ; uno de cada dos
	ret nc			;7113
	ld e,(ix+003h)		;7114   ; por donde va su guion
	ld d,(ix+004h)		;7117
	ld c,001h		;711a
	ld a,(de)			;711c
	bit 0,b		;711d
	jr nz,L_7125		;711f
	neg		;7121   ; el paso, al reves
	ld c,002h		;7123
L_7125:
	add a,(hl)			;7125   ; aplicado a una coordenada
	ld (hl),a			;7126
	inc hl			;7127
	ld a,b			;7128
	and 00ch		;7129   ; los dos bits de direccion
	jr z,L_7137		;712b
	bit 3,a		;712d   ; el bit 3 elige el sentido
	ld a,(hl)			;712f
	jr z,L_7135		;7130
	add a,c			;7132
	jr L_7136		;7133
L_7135:
	sub c			;7135
L_7136:
	ld (hl),a			;7136
L_7137:
	dec de			;7137   ; el guion retrocede
	bit 0,b		;7138
	jr nz,L_713E		;713a
	inc de			;713c   ; o avanza dos
	inc de			;713d
L_713E:
	ld a,(de)			;713e
	inc a			;713f   ; un 0xFF cierra el guion
	jr z,L_7148		;7140
	inc a			;7142   ; y un 0xFE lo hace volver
	jr nz,L_714E		;7143
	inc de			;7145
	jr L_714E		;7146
L_7148:
	dec de			;7148
	dec de			;7149
	set 0,(ix+000h)		;714a   ; se marca el bit 0
L_714E:
	ld (ix+003h),e		;714e   ; y el guion queda apuntado
	ld (ix+004h),d		;7151
	dec hl			;7154
	push ix		;7155
	pop de			;7157
	call mira_si_hay_hueco_delante		;7158
	ret nc			;715b
	ld a,(hl)			;715c
	and 0f8h		;715d   ; se limpian los tres bits de abajo
	ld (hl),a			;715f
	ld a,(de)			;7160
	and 00ch		;7161
	or 040h		;7163   ; y se marca el bit 6
	ld (de),a			;7165
	ret			;7166

; ----------------------------------------------------------------------
; SI HAY HUECO POR DELANTE, otra vez preguntandole a la PANTALLA: coge la celda 0x10 mas alla -0x10 mas en la otra coordenada si el bit 3 esta puesto- y comprueba que su indice este entre 0xCD y 0xD0. Cuatro indices son "se puede pasar".
; ----------------------------------------------------------------------
mira_si_hay_hueco_delante:
	push hl			;7167
	push de			;7168
	ld a,010h		;7169   ; dieciseis pixeles por delante
	add a,(hl)			;716b
	ld b,a			;716c
	inc hl			;716d
	ld c,(hl)			;716e
	ld a,(de)			;716f
	bit 3,a		;7170   ; el bit 3: tambien en la otra coordenada
	jr z,L_7178		;7172
	ld a,010h		;7174
	add a,c			;7176
	ld c,a			;7177
L_7178:
	ld h,c			;7178
	ld l,b			;7179
	call lee_la_celda_de_ahi		;717a   ; que hay en esa celda
	pop de			;717d
	pop hl			;717e
	sub 0cdh		;717f   ; los indices desde 0xCD
	cp 004h		;7181   ; y cuatro seguidos
	ret			;7183

; ----------------------------------------------------------------------
; EL BICHO DEL GUION, atendido uno de cada ocho cuadros, y con el umbral cambiado por fase: 5 de la tercera en adelante, 16 antes. O sea que en las fases altas se mueve tres veces mas.
; ----------------------------------------------------------------------
avanza_el_bicho_del_guion:
	ld a,(0e003h)		;7184   ; el contador de cuadros
	and 007h		;7187   ; uno de cada ocho
	ret nz			;7189
	push de			;718a
	inc de			;718b
	inc de			;718c
	inc de			;718d
	call alterna_el_dibujo_del_bicho		;718e
	pop de			;7191
	ld a,(0e051h)		;7192   ; el numero de fase
	cp 003h		;7195   ; de la tercera en adelante
	ld a,005h		;7197   ; cinco
	jr nc,L_719D		;7199
	ld a,010h		;719b   ; y antes, dieciseis
L_719D:
	cp b			;719d
	ret nz			;719e
	ld (hl),020h		;719f   ; el patron
	inc hl			;71a1
	ld a,(0e05dh)		;71a2   ; la variante de fase
	cp 011h		;71a5   ; el valor 0x11 tiene azar
	ld (hl),001h		;71a7
	jr nz,L_71B2		;71a9
	ld a,r		;71ab   ; el registro de refresco: el azar otra vez
	and 007h		;71ad   ; tres bits, o sea de 0 a 7
	add a,003h		;71af   ; mas tres: de tres a diez
	ld (hl),a			;71b1
L_71B2:
	ld a,(de)			;71b2
	and 00fh		;71b3
	or 040h		;71b5   ; y se marca el bit 6
	ld (de),a			;71b7
	ret			;71b8
alterna_el_dibujo_del_bicho:
	ex de,hl			;71b9
	inc (hl)			;71ba   ; su contador, uno mas
	ld b,(hl)			;71bb
	ex de,hl			;71bc
	inc hl			;71bd
	inc hl			;71be
	bit 1,b		;71bf   ; el bit 1: dos y dos
	ret nz			;71c1
	ld a,004h		;71c2
	xor (hl)			;71c4   ; y le da la vuelta al bit 2 del patron
	ld (hl),a			;71c5
	ret			;71c6

; ----------------------------------------------------------------------
; SOLTAR UN BICHO NUEVO, y solo en el cuadro en que el contador de cuadros pasa por 0xFF -o sea una vez cada 256 cuadros- y con el bit 0 de (0xE05E) puesto. Busca un hueco libre entre DOS y, al soltarlo, el registro R decide en cual de cuatro sitios aparece.
; ----------------------------------------------------------------------
suelta_un_bicho_nuevo:
	ld a,(0e003h)		;71c7   ; el contador de cuadros
	inc a			;71ca   ; solo cuando vale 0xFF
	ret nz			;71cb
	ld a,(0e05eh)		;71cc   ; la bandera que lo permite
	rra			;71cf
	ret nc			;71d0
	ld hl,0e217h		;71d1
	ld de,0e0c8h		;71d4
	ld bc,00200h		;71d7   ; dos huecos
L_71DA:
	ld a,(hl)			;71da
	or a			;71db   ; libre
	jr nz,L_71E3		;71dc
	ld a,(de)			;71de
	cp 040h		;71df   ; por encima de 0x40 no vale
	jr nc,L_71EC		;71e1
L_71E3:
	inc hl			;71e3
	dec de			;71e4   ; cuatro bytes por hueco
	dec de			;71e5
	dec de			;71e6
	dec de			;71e7
	inc c			;71e8
	djnz L_71DA		;71e9
	ret			;71eb
L_71EC:
	ld a,r		;71ec   ; el registro de refresco: el azar
	and 060h		;71ee   ; dos bits, o sea cuatro sitios
	or 080h		;71f0   ; mas el 0x80
	ld (hl),a			;71f2
	ld hl,071ffh		;71f3   ; los cuatro bytes de su definicion
	call hueco_del_bicho		;71f6
	ld bc,00004h		;71f9   ; copiados
	ldir		;71fc
	ret			;71fe

; ----------------------------------------------------------------------
; DATOS definicion_del_bicho: los cuatro bytes que 0x71F3 copia con `ld
;   bc,00004h / ldir` al hueco que le da hueco_del_bicho
;   0x71ff..0x7203  (4 bytes)
DATA_definicion_del_bicho:
	defb 010h,078h,098h,00fh	; 71ff

; ======================================================================
; CODIGO 0x7203..0x741f  (540 bytes)
; ======================================================================


hueco_del_bicho:
	ld de,0e0c0h		;7203
	ld a,c			;7206   ; el numero por ocho
	add a,a			;7207
	add a,a			;7208
	add a,a			;7209
	jp suma_a_a_de		;720a

; ----------------------------------------------------------------------
; LOS DOS BICHOS SUELTOS, y aqui el azar se usa DOS veces encadenadas: una vez de cada 64 cuadros se tira el dado (`ld a,r / and 007h`) y solo si sale cero se marca el bit 4. O sea, una probabilidad entre ocho, una vez cada 64 cuadros.
; ----------------------------------------------------------------------
mueve_los_dos_bichos_sueltos:
	ld hl,0e217h		;720d
	ld bc,00200h		;7210   ; dos
L_7213:
	push hl			;7213
	push bc			;7214
	ld a,(hl)			;7215
	or a			;7216   ; hueco vacio
	jr z,L_726A		;7217
	ld a,(0e003h)		;7219   ; el contador de cuadros
	ld b,a			;721c
	and 03fh		;721d   ; uno de cada sesenta y cuatro
	jr nz,L_7229		;721f
	ld a,r		;7221   ; y ademas el dado
	and 007h		;7223   ; una entre ocho
	jr nz,L_7229		;7225
	set 4,(hl)		;7227   ; entonces se marca el bit 4
L_7229:
	call hueco_del_bicho		;7229
	ex de,hl			;722c
	call esta_en_la_banda_util		;722d
	inc hl			;7230
	ld a,b			;7231
	and 007h		;7232   ; y uno de cada ocho cuadros
	jr nz,L_7266		;7234
	ld a,(de)			;7236
	and 060h		;7237   ; los bits 5 y 6
	jr z,L_7246		;7239
	inc (hl)			;723b   ; hacia delante
	ld b,0c7h		;723c   ; y su tope
	bit 6,a		;723e   ; el bit 6 elige el sentido
	jr nz,L_7246		;7240
	ld b,018h		;7242   ; el otro tope
	dec (hl)			;7244   ; hacia atras, de dos en dos
	dec (hl)			;7245
L_7246:
	ld a,(hl)			;7246
	cp b			;7247   ; ha llegado al tope?
	jr z,L_7257		;7248
	ld a,(0e051h)		;724a   ; el numero de fase
	cp 003h		;724d
	jr c,L_7266		;724f
	ld a,r		;7251   ; de la tercera en adelante, el azar puede darle la vuelta
	and 07fh		;7253   ; siete bits: una entre 128
	jr nz,L_7266		;7255
L_7257:
	ex de,hl			;7257
	ld a,(hl)			;7258
	xor 060h		;7259   ; le da la vuelta a los dos bits de sentido
	ld (hl),a			;725b
	and 060h		;725c
	jr nz,L_7262		;725e
	set 5,(hl)		;7260   ; y si se quedan a cero, se fuerza uno
L_7262:
	ex de,hl			;7262
	dec hl			;7263
	inc (hl)			;7264
	inc hl			;7265
L_7266:
	dec hl			;7266
	call duplica_la_ficha_del_bicho		;7267
L_726A:
	pop bc			;726a
	pop hl			;726b
	inc hl			;726c   ; un byte por hueco
	inc c			;726d
	djnz L_7213		;726e
	ret			;7270

; ----------------------------------------------------------------------
; DUPLICAR LA FICHA DE UN BICHO cuatro bytes mas alla y ponerle el patron 0x9C: es la SEGUNDA MITAD de la figura, dieciseis pixeles por debajo. Cada bicho son dos sprites que se mueven juntos sin calcularse por separado.
; ----------------------------------------------------------------------
duplica_la_ficha_del_bicho:
	push de			;7271   ; se guarda DE
	ld d,h			;7272   ; se copia el puntero
	ld e,l			;7273
	inc de			;7274
	inc de			;7275
	inc de			;7276
	inc de			;7277   ; cuatro bytes mas alla
	ld bc,00004h		;7278   ; cuatro bytes
	ldir		;727b   ; copiados
	ex de,hl			;727d   ; se cambian
	dec hl			;727e
	dec hl			;727f   ; dos atras
	ld (hl),09ch		;7280   ; el patron de la segunda mitad
	dec hl			;7282   ; el byte de antes
	ld a,010h		;7283   ; y dieciseis pixeles mas alla
	add a,(hl)			;7285   ; mas la columna
	ld (hl),a			;7286   ; guardada
	pop hl			;7287   ; se recupera

; ----------------------------------------------------------------------
; LA ANIMACION DEL BICHO SUELTO: uno de cada cuatro cuadros, y solo con el bit 4 puesto. Sus dos mitades avanzan de patron a la vez, y el nibble bajo da la vuelta de 15 a 1 -no a 0-, que es como se salta el primer dibujo en las vueltas siguientes.
; ----------------------------------------------------------------------
anima_al_bicho_suelto:
	ld a,(0e003h)		;7288   ; el contador de cuadros
	and 003h		;728b   ; uno de cada cuatro
	ret nz			;728d
	bit 4,(hl)		;728e   ; el bit 4
	ret z			;7290
	push de			;7291
	dec de			;7292
	ld b,002h		;7293   ; las dos mitades
L_7295:
	ld a,(de)			;7295
	inc a			;7296   ; el patron, uno mas
	and 00fh		;7297   ; el nibble bajo
	jr nz,L_729D		;7299
	or 001h		;729b   ; al dar la vuelta, empieza por uno
L_729D:
	ld (de),a			;729d
	inc de			;729e   ; cuatro bytes: la otra mitad
	inc de			;729f
	inc de			;72a0
	inc de			;72a1
	djnz L_7295		;72a2
	pop de			;72a4
	cp 00fh		;72a5   ; al llegar a quince
	ret nz			;72a7
	res 4,(hl)		;72a8   ; se apaga el bit 4
	push de			;72aa
	push hl			;72ab
	ld hl,0e219h		;72ac
	ld bc,00300h		;72af
L_72B2:
	ld a,(hl)			;72b2
	or a			;72b3
	jr z,lanza_el_proyectil		;72b4   ; hueco libre
	inc hl			;72b6
	inc c			;72b7   ; el numero de hueco
	djnz L_72B2		;72b8
	pop hl			;72ba
	pop de			;72bb
	ret			;72bc

; ----------------------------------------------------------------------
; LANZAR EL PROYECTIL, y el azar vuelve a decidir: dos bits del registro R se AGREGAN con un `or` al tipo, de modo que no todos salen iguales. Se copian cuatro bytes de ficha, se pone la segunda mitad dieciseis pixeles mas alla con el patron 0xF4 y suena el 0x4A.
; ----------------------------------------------------------------------
lanza_el_proyectil:
	pop de			;72bd
	ld a,(de)			;72be   ; leido
	ld (hl),a			;72bf   ; a la ficha
	ld a,r		;72c0   ; el contador de refresco: el azar
	and 003h		;72c2   ; dos bits
	or (hl)			;72c4   ; al tipo
	ld (hl),a			;72c5   ; guardado
	pop hl			;72c6   ; se recupera
	ld de,0e0f8h		;72c7   ; el bufer de atributos
	call hueco_de_sprite_en_de		;72ca   ; su hueco
	push de			;72cd   ; se guarda
	ld bc,00004h		;72ce   ; cuatro bytes de ficha
	ldir		;72d1   ; copiados
	pop hl			;72d3   ; se recupera
	ld a,010h		;72d4   ; dieciseis pixeles mas alla
	add a,(hl)			;72d6   ; mas la columna
	ld (hl),a			;72d7   ; guardada
	inc hl			;72d8
	inc hl			;72d9   ; dos bytes mas alla
	ld (hl),0f4h		;72da   ; el patron de la segunda mitad
	ld a,04ah		;72dc   ; y el sonido del lanzamiento
	jp pide_un_sonido		;72de

; ----------------------------------------------------------------------
; LOS TRES PROYECTILES. Los dos bits de abajo de su tipo son la velocidad y el bit 6 el sentido, asi que un proyectil rapido y otro lento salen del mismo codigo cambiando dos bits. Cada cuadro avanza esa cantidad y sube el patron.
; ----------------------------------------------------------------------
mueve_los_tres_proyectiles:
	ld hl,0e219h		;72e1
	ld bc,00300h		;72e4   ; de una vez con el byte de al lado
L_72E7:
	ld a,(hl)			;72e7
	or a			;72e8   ; hueco vacio
	jr z,L_7310		;72e9
	push bc			;72eb
	push hl			;72ec
	ex de,hl			;72ed
	ld b,a			;72ee
	ld hl,0e0f8h		;72ef
	call hueco_de_sprite		;72f2
	inc (hl)			;72f5   ; la fila, uno mas
	push hl			;72f6
	inc hl			;72f7
	ld a,b			;72f8
	and 003h		;72f9   ; los dos bits de abajo: la velocidad
	bit 6,b		;72fb   ; el bit 6: el sentido
	jr nz,L_7301		;72fd
	neg		;72ff   ; al reves
L_7301:
	add a,(hl)			;7301   ; aplicado a la columna
	ld (hl),a			;7302
	inc hl			;7303
	inc hl			;7304
	inc (hl)			;7305   ; el patron, uno mas
	set 3,(hl)		;7306   ; y sus bits de color
	res 7,(hl)		;7308
	pop hl			;730a
	call retira_el_proyectil_fuera		;730b
	pop hl			;730e
	pop bc			;730f
L_7310:
	inc hl			;7310
	inc c			;7311
	djnz L_72E7		;7312
	ret			;7314

; ----------------------------------------------------------------------
; RETIRAR EL PROYECTIL que se sale de la banda 0x18..0xC1 o cuyo tipo quede fuera del rango util: se le pone la fila 0xC3 y se borra la ficha.
; ----------------------------------------------------------------------
retira_el_proyectil_fuera:
	ld b,a			;7315
	ld a,(hl)			;7316
	sub 018h		;7317   ; la banda util empieza en 0x18
	cp 0a9h		;7319   ; y mide 0xA9
	jr nc,L_7325		;731b
	ld a,b			;731d
	cp 002h		;731e   ; por debajo de dos
	jr c,L_7325		;7320
	cp 0f0h		;7322   ; o por encima de 0xF0
	ret c			;7324
L_7325:
	ld (hl),0c3h		;7325   ; 0xC3: fuera de la pantalla
	xor a			;7327
	ld (de),a			;7328   ; y la ficha, borrada
	ret			;7329
el_jugador_alcanzado:
	ld hl,0e1b5h		;732a
	ld (hl),00ch		;732d   ; el paso del dibujo
	ld a,(0e003h)		;732f
	and 01fh		;7332   ; uno de cada treinta y dos cuadros
	ret nz			;7334
	inc (hl)			;7335
	ld (0e1b6h),a		;7336
	ld hl,06572h		;7339   ; el guion de la caida
	call arranca_gesto		;733c
	xor a			;733f
	ld (0e032h),a		;7340   ; se apaga el sonido en curso
	ld a,00bh		;7343   ; y suena el 0x0B
	call pide_un_sonido		;7345
	jp pasa_al_estado_siguiente		;7348

; ----------------------------------------------------------------------
; ESTADO 12: la caida final, uno de cada dos cuadros. Al llegar al suelo (0x98) suena el 0x9F y se marca con 0xC3 tanto la posicion como (0xE00C), que es la senal de fin de vida.
; ----------------------------------------------------------------------
estado_12_cayendo:
	ld a,(0e003h)		;734b   ; el contador de cuadros
	rra			;734e   ; uno de cada dos
	ret nc			;734f
	push af			;7350
	call avanza_el_gesto		;7351
	call mira_si_puede_subir		;7354
	pop af			;7357
	bit 2,a		;7358   ; el bit 2 elige el dibujo
	ld a,00ch		;735a
	jr nz,L_735F		;735c
	inc a			;735e
L_735F:
	ld (0e1b5h),a		;735f
	ld hl,0e1b3h		;7362
	ld a,098h		;7365   ; el suelo
	sub (hl)			;7367
	ret nc			;7368   ; si aun no ha llegado, se sigue cayendo
	call mueve_al_jugador		;7369
	ld a,09fh		;736c   ; el sonido del golpe
	call pide_un_sonido		;736e
	ld a,0c3h		;7371   ; la marca de fin
	ld (0e1b3h),a		;7373
	ld (0e00ch),a		;7376   ; y la senal de fin de vida
	ret			;7379
L_737A:
	ret			;737a
llega_arriba_del_todo:
	ld a,09fh		;737b   ; el sonido de llegar
	call pide_un_sonido		;737d
	ld a,(0e1cbh)		;7380
	sub 020h		;7383   ; treinta y dos hacia arriba
	call sube_al_jugador		;7385
	ld a,001h		;7388
	ld (0e1b5h),a		;738a   ; el paso, a uno
	ld (0e001h),a		;738d
	ld a,00ch		;7390   ; y estado 12
	jp pasa_al_estado		;7392

; ----------------------------------------------------------------------
; EL CAMBIO DE FASE. Baja al jugador hasta el suelo de tramo en tramo, limpia 92 bytes de estado propagando un cero con `ldir`, saca los dieciseis sprites de la pantalla y ALTERNA los dos topes laterales segun el bit 0 de (0xE05E): 0x03F0 en una fase y 0x18DF en la siguiente. O sea que el arbol se recorre en un sentido y en el otro.
; ----------------------------------------------------------------------
termina_la_fase:
	call baja_un_tramo		;7395   ; un tramo hacia abajo
	cp 098h		;7398   ; hasta el suelo
	jr nz,termina_la_fase		;739a
	ld hl,0e1f9h		;739c
	ld (hl),000h		;739f   ; un cero
	ld de,0e1fah		;73a1
	ld bc,0005ch		;73a4   ; y el ldir lo arrastra por 92 bytes
	ldir		;73a7
	ld hl,0e0c0h		;73a9
	ld (hl),0c3h		;73ac   ; 0xC3: fuera de la pantalla
	ld de,0e0c1h		;73ae
	ld bc,0000fh		;73b1   ; los dieciseis sprites
	ldir		;73b4
	ld hl,0e05eh		;73b6
	inc (hl)			;73b9   ; el contador de fases
	ld a,(hl)			;73ba
	rra			;73bb   ; su bit 0
	ld hl,003f0h		;73bc   ; unos topes
	jr nc,L_73C4		;73bf
	ld hl,018dfh		;73c1   ; o los otros
L_73C4:
	ld (0e057h),hl		;73c4   ; y quedan puestos
	ld hl,0e1abh		;73c7   ; los topes
	set 1,(hl)		;73ca   ; el bit 1: tope por arriba
	ld de,(0e1c5h)		;73cc   ; la celda de referencia
	inc de			;73d0   ; la de al lado
	call lee_de_vram		;73d1   ; lee de la pantalla
	inc a			;73d4   ; uno mas: 0xFF se convierte en cero
	jr nz,L_741C		;73d5   ; y si no era 0xFF, no toca cambiar de fase
	ld hl,0e051h		;73d7   ; el numero de fase
	ld a,(hl)			;73da
	add a,001h		;73db   ; el numero de fase, en BCD
	daa			;73dd
	ld (hl),a			;73de   ; guardado
	ld hl,0e05ch		;73df   ; y el contador de tandas
	inc (hl)			;73e2   ; y el contador de tandas
	ld a,(hl)			;73e3
	ld b,a			;73e4
	cp 009h		;73e5   ; a las nueve
	ld hl,076ceh		;73e7
	jr nz,L_73EF		;73ea
	ld hl,0778ah		;73ec   ; el otro decorado
L_73EF:
	ld (0e250h),hl		;73ef
	ld a,077h		;73f2
	jr nc,L_7400		;73f4
	ld a,b			;73f6
	and 007h		;73f7   ; tres bits de la tanda
	ld hl,0741fh		;73f9   ; la tabla de ocho variantes
	call suma_a_a_hl		;73fc
	ld a,(hl)			;73ff
L_7400:
	ld (0e05dh),a		;7400
	ld a,090h		;7403   ; el sonido de la fase nueva
	call pide_un_sonido		;7405
	ld hl,05937h		;7408   ; el decorado de la fase
	call descomprime_con_mascara_de_color		;740b
	call duplica_los_tercios_de_color		;740e
	call monta_el_decorado_de_la_fase		;7411
	call pinta_el_marcador		;7414
	ld a,00eh		;7417   ; y estado 14
	jp pasa_al_estado		;7419
L_741C:
	jp pasa_al_estado_siguiente		;741c

; ----------------------------------------------------------------------
; DATOS mascaras_de_color_por_tanda: ocho bytes (0x11 0x33 0xBB 0xEE 0x11 0xBB
;   0xEE 0x11) que 0x73F9 indexa con tres bits del contador de tandas y deja
;   en (0xE05D). De ahi los coge el descompresor de 0x612C, que al sacar cada
;   byte de color mira los nibbles: donde valga 3 pone el de la mascara. O sea
;   que el decorado es SIEMPRE el mismo y lo que cambia de una tanda a otra es
;   el color, sin guardar una segunda copia. OJO: la PRIMERA tanda no sale de
;   aqui, sale de los diecisiete valores iniciales de 0x51C1 -el decimocuarto
;   es (0xE05D) y vale 0x77-; medido en el emulador con la fase 1 y la tanda a
;   cero, y montando la pantalla con ese 0x77 el cotejo contra el volcado da
;   cero bytes de color
;   0x741f..0x7427  (8 bytes)
DATA_mascaras_de_color_por_tanda:
	defb 011h,033h,0bbh,0eeh,011h,0bbh,0eeh,011h	; 741f  .3......

; ======================================================================
; CODIGO 0x7427..0x7565  (318 bytes)
; ======================================================================


arranca_la_fase:
	xor a			;7427
	ld (0e003h),a		;7428   ; el contador de cuadros, a cero
	ld a,004h		;742b
	ld (0e05fh),a		;742d   ; cuatro objetos por recoger
	ld a,(0e05eh)		;7430   ; el contador de fases
	rra			;7433   ; su bit 0
	ld a,08ch		;7434   ; un sonido
	jr nc,L_743A		;7436
	ld a,009h		;7438   ; o el otro, segun el sentido de la fase
L_743A:
	call pide_un_sonido		;743a
L_743D:
	xor a			;743d
	ld (0e001h),a		;743e
	ld a,000h		;7441   ; y estado 0
	jp pasa_al_estado		;7443
estado_13_subiendo_al_final:
	call baja_el_plazo_cada_ocho		;7446
	ld a,(0e1b4h)		;7449   ; la posicion del jugador
	cp 098h		;744c   ; el suelo
	ld a,004h		;744e   ; cuatro
	jr nc,L_7453		;7450
	add a,a			;7452   ; u ocho
L_7453:
	ld (0e009h),a		;7453
	call elige_el_paso_del_dibujo		;7456
	dec hl			;7459
	ld a,098h		;745a   ; cuando llega a 0x98
	cp (hl)			;745c
	ret nz			;745d
	ld a,008h		;745e
	ld (0e1b7h),a		;7460
	jp pasa_al_estado_siguiente		;7463

; ----------------------------------------------------------------------
; ESTADO 14: el remate de la fase. En la novena fase y con poco plazo saca su rotulo; el paso del dibujo alterna con el bit 4 del contador de cuadros -uno de cada dieciseis-, y al acabar reparte DOS MIL puntos y pinta la altura.
; ----------------------------------------------------------------------
estado_14_el_remate:
	call baja_el_plazo_cada_ocho		;7466
	push af			;7469
	ld a,(0e05ch)		;746a   ; el contador de fases
	cp 009h		;746d   ; la novena
	jr nz,L_747E		;746f
	ld a,(0e004h)		;7471
	cp 015h		;7474   ; y con menos de 21 de plazo
	jr nc,L_747E		;7476
	ld hl,075eeh		;7478
	call pinta_dos_bloques_de_3x3		;747b
L_747E:
	ld a,(0e003h)		;747e
	bit 4,a		;7481   ; el bit 4 del contador de cuadros
	ld a,001h		;7483
	jr nz,L_7488		;7485
	inc a			;7487
L_7488:
	ld (0e1b5h),a		;7488   ; y ese es el paso
	pop af			;748b   ; lo que se guardo
	ret p			;748c   ; con el signo puesto, todavia no toca
	ld a,(0e012h)		;748d   ; espera a que pare el sonido
	or a			;7490
	ret nz			;7491   ; mientras suene algo, no se sigue
	ld a,(0e05ch)		;7492   ; el contador de fases
	cp 009h		;7495   ; la novena tiene su propio remate
	jr z,remate_de_la_novena		;7497
	ld hl,07565h		;7499   ; el rotulo "STAGE  CLEAR"
	call pinta_rotulo		;749c   ; pintado
	ld de,02000h		;749f   ; dos mil puntos
	ld (0e241h),de		;74a2   ; apuntados
	call suma_puntos		;74a6   ; y sumados al tanteo
	ld hl,0e242h		;74a9   ; la altura
	ld de,03991h		;74ac   ; su celda en la pantalla
	call imprime_dos_bytes_bcd		;74af   ; y la altura
	ld hl,0b888h		;74b2   ; el bloque de origen
	ld de,075a7h		;74b5   ; su destino
	ld bc,00608h		;74b8   ; seis por ocho
	call pinta_bloque_recortado		;74bb
	ld bc,(075ech)		;74be   ; los dos bytes del tope
	ld a,c			;74c2   ; el bajo
	ld de,0e241h		;74c3   ; donde se compone el resultado

; ----------------------------------------------------------------------
; LA ALTURA QUE FALTA, restada en BCD con `sbc a,(hl) / daa` sobre los dos bytes: es lo que se pinta al acabar la fase.
; ----------------------------------------------------------------------
	ld hl,0e1bch		;74c6   ; y la altura de la que se parte
	sub (hl)			;74c9   ; la altura alcanzada
	daa			;74ca   ; en BCD
	ld (de),a			;74cb   ; guardada
	inc hl			;74cc   ; el byte siguiente
	inc de			;74cd
	ld a,b			;74ce   ; el alto del tope
	sbc a,(hl)			;74cf   ; el byte alto, con acarreo
	daa			;74d0
	ld (de),a			;74d1   ; guardado
	ex de,hl			;74d2
	ld de,03a79h		;74d3   ; la celda donde se pinta
	call imprime_dos_bytes_bcd		;74d6   ; los dos bytes, en BCD
L_74D9:
	ld a,008h		;74d9   ; el sonido del recuento
	call pide_un_sonido		;74db
	ld a,000h		;74de   ; a cero
	ld (0e1b5h),a		;74e0
L_74E3:
	xor a			;74e3
	ld (0e003h),a		;74e4   ; y el contador de cuadros tambien
	jp pasa_al_estado_siguiente		;74e7
remate_de_la_novena:
	ld hl,07600h		;74ea   ; los dos bloques de tres por tres
	call pinta_dos_bloques_de_3x3		;74ed
	ld hl,07595h		;74f0   ; el rotulo "CONGRATULATIONS"
	call pinta_rotulo		;74f3   ; pintado
	jr L_74D9		;74f6

; ----------------------------------------------------------------------
; ESTADO 15: la espera larga, una vez de cada 128 cuadros. Monta el decorado de la fase siguiente, pone el tope de arriba y levanta la senal de (0xE00D).
; ----------------------------------------------------------------------
estado_15_espera_larga:
	ld a,(0e003h)		;74f8   ; el contador de cuadros
	and 07fh		;74fb   ; uno de cada 128
	ret nz			;74fd
	ld a,(0e05ch)		;74fe   ; el contador de fases
	cp 009h		;7501   ; la novena va aparte
	jr z,L_74E3		;7503   ; la novena va por otro lado
	ld hl,0757dh		;7505   ; el bloque comprimido
	call descomprime		;7508   ; a la VRAM
	ld hl,0b888h		;750b
	ld de,075dah		;750e
	ld bc,00608h		;7511
	call pinta_bloque_recortado		;7514
	ld a,080h		;7517   ; el tope de arriba
L_7519:
	ld (0e1abh),a		;7519
	call pinta_el_marcador		;751c
	xor a			;751f
	ld (0e059h),a		;7520
	ld hl,03b83h		;7523
	ld (0e05ah),hl		;7526
	call recorre_el_decorado_entero		;7529
	ld a,001h		;752c
	ld (0e00dh),a		;752e   ; y la senal
	jp L_743D		;7531
estado_16_plazo_de_32:
	ld a,(0e003h)		;7534   ; el contador de cuadros
	or a			;7537
	ret nz			;7538
	ld a,020h		;7539   ; 32 cuadros de plazo
	ld (0e004h),a		;753b
	jp pasa_al_estado_siguiente		;753e
estado_17_reinicia:
	call baja_los_contadores_y_barre		;7541
	ret p			;7544
	ld hl,051c5h		;7545   ; los trece valores iniciales
	ld de,0e054h		;7548
	ld bc,0000dh		;754b   ; trece bytes
	ldir		;754e
	xor a			;7550
	jr L_7519		;7551
pinta_dos_bloques_de_3x3:
	ld de,0390ah		;7553
	ld bc,00303h		;7556   ; tres por tres
	call vuelca_b_filas		;7559
	ld de,03912h		;755c
	ld bc,00303h		;755f   ; y el segundo, ocho celdas mas alla
	jp vuelca_b_filas		;7562

; ----------------------------------------------------------------------
; DATOS guion_0x7565: 24 bytes, 2 tramos, 18 bytes a la VRAM; lo pinta 0x7499
;   0x7565..0x757d  (24 bytes)
DATA_guion_0x7565:
	defb 04ah,039h,053h,054h,041h,047h,045h,000h,000h,043h,04ch,045h,041h,052h,0feh,08bh	; 7565  J9STAGE..CLEAR..
	defb 039h,042h,04fh,04eh,055h,053h,040h,0ffh	; 7575  9BONUS@.

; ----------------------------------------------------------------------
; DATOS bloque_0x757D: 24 bytes comprimidos -> 22 en VRAM (2 tramos: 0x394A
;   0x398B); lo carga 0x7505
;   0x757d..0x7595  (24 bytes)
DATA_bloque_0x757D:
	defb 04ah,039h,004h,003h,084h,006h,088h,089h,08ah,004h,003h,080h,08bh,039h,003h,003h	; 757d  J9...........9..
	defb 084h,006h,088h,089h,08ah,003h,003h,000h	; 758d  ........

; ----------------------------------------------------------------------
; DATOS guion_0x7595: 18 bytes, 1 tramos, 15 bytes a la VRAM; lo pinta 0x74F0
;   0x7595..0x75a7  (18 bytes)
DATA_guion_0x7595:
	defb 0a8h,039h,043h,04fh,04eh,047h,052h,041h,054h,055h,04ch,041h,054h,049h,04fh,04eh	; 7595  .9CONGRATULATION
	defb 053h,0ffh	; 75a5

; ----------------------------------------------------------------------
; DATOS rotulo_castle: seis filas recortadas que 0x74B5 pinta con `ld
;   bc,00608h` -B=6 filas-. La segunda fila lleva el texto "CASTLE" en claro,
;   porque la fuente pone cada letra en su codigo ASCII
;   0x75a7..0x75da  (51 bytes)
DATA_rotulo_castle:
	defb 001h,003h,006h,00eh,001h,003h,000h,088h,010h,043h,041h,053h,054h,04ch,045h,014h	; 75a7  .........CASTLE.
	defb 000h,081h,010h,005h,001h,082h,018h,014h,000h,088h,003h,00dh,00dh,00fh,013h,00dh	; 75b7  ................
	defb 00dh,003h,000h,003h,003h,082h,010h,014h,003h,003h,000h,003h,003h,082h,011h,012h	; 75c7  ................
	defb 003h,003h,000h	; 75d7

; ----------------------------------------------------------------------
; DATOS seis_filas_de_tronco: seis filas iguales de tres bytes (0x08 0x03
;   0x00); se entra por 0x75DA, 0x75DD o mas abajo segun cuantas filas se
;   quieran
;   0x75da..0x75ec  (18 bytes)
DATA_seis_filas_de_tronco:
	defb 008h,003h,000h,008h,003h,000h,008h,003h,000h,008h,003h,000h,008h,003h,000h,008h	; 75da  ................
	defb 003h,000h	; 75ea

; ----------------------------------------------------------------------
; DATOS pareja_para_bc: los dos bytes que 0x74BE carga de golpe con `ld
;   bc,(075ech)`: C=0x03 y B=0x20
;   0x75ec..0x75ee  (2 bytes)
DATA_pareja_para_bc:
	defb 003h,020h	; 75ec

; ----------------------------------------------------------------------
; DATOS cuatro_bloques_de_3x3: 36 bytes en cuatro bloques de tres filas de
;   tres; 0x7478 pinta el par que empieza en 0x75EE y 0x74EA el que empieza en
;   0x7600
;   0x75ee..0x7612  (36 bytes)
DATA_cuatro_bloques_de_3x3:
	defb 0e8h,0e9h,0eah,0eeh,0efh,0f0h,0f4h,0f5h,0f6h,0e5h,0e6h,0e7h,0ebh,0ech,0edh,0f1h	; 75ee  ................
	defb 0f2h,0f3h,0e8h,0e9h,0eah,0eeh,0efh,0f0h,0fch,0fdh,0feh,0e5h,0e6h,0e7h,0f7h,0ech	; 75fe  ................
	defb 0f8h,0f9h,0fah,0fbh	; 760e

; ======================================================================
; CODIGO 0x7612..0x7661  (79 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; BAJAR EL PLAZO UNA VEZ DE CADA OCHO CUADROS, y devolver su bit 0 con el mismo truco del vaiven: `srl a / jr c` hace que el valor suba y baje en vez de solo bajar.
; ----------------------------------------------------------------------
baja_el_plazo_cada_ocho:
	ld a,(0e003h)		;7612   ; el contador de cuadros
	and 007h		;7615   ; uno de cada ocho
	ret nz			;7617
	ld hl,0e004h		;7618
	dec (hl)			;761b   ; el plazo, uno menos
	ret m			;761c   ; si se paso de cero, se sale con el signo
	ld a,(hl)			;761d
	srl a		;761e   ; el bit de abajo al acarreo
	jr c,pinta_el_rotulo_grande		;7620
	xor 01fh		;7622
pinta_el_rotulo_grande:
	add a,060h		;7624
	ld e,a			;7626
	ld d,038h		;7627   ; la fila
	ld hl,(0e250h)		;7629   ; por donde va el guion
	ld a,(hl)			;762c
	inc hl			;762d
	ld h,(hl)			;762e
	ld l,a			;762f
	call prepara_escritura_vram		;7630
L_7633:
	ld a,(hl)			;7633
	and 07fh		;7634   ; los siete bits de abajo
	ld b,a			;7636
	ld a,(hl)			;7637
	inc hl			;7638
	jr z,L_7657		;7639
	cp b			;763b
L_763C:
	ex af,af'			;763c
	ld a,(hl)			;763d   ; un indice del guion
	exx			;763e
	out (c),a		;763f   ; y al puerto de datos
	exx			;7641
	ex af,af'			;7642
	jr z,L_7646		;7643
	inc hl			;7645
L_7646:
	push af			;7646
	ld a,020h		;7647   ; la fila de abajo, 32 celdas
	call suma_a_a_de		;7649
	call prepara_escritura_vram		;764c
	pop af			;764f
	djnz L_763C		;7650
	jr nz,L_7655		;7652
	inc hl			;7654
L_7655:
	jr L_7633		;7655
L_7657:
	ld hl,(0e250h)		;7657   ; por donde va el guion
	inc hl			;765a   ; dos bytes mas alla
	inc hl			;765b
	ld (0e250h),hl		;765c
	xor a			;765f
	ret			;7660

; ----------------------------------------------------------------------
; DATOS columnas_del_decorado_A: dibujado desde la ROM sale EL ARBOL: el
;   tronco en las cuatro primeras columnas y cuatro ramas horizontales. Quince
;   columnas distintas, cada una una tira comprimida que acaba en 0x80. Las
;   quince cierran clavadas: el interprete de 0x7629 saca de cada una VEINTE
;   celdas, ni una mas ni una menos
;   0x7661..0x76ce  (109 bytes)
DATA_columnas_del_decorado_A:
	defb 014h,088h,080h,014h,089h,080h,014h,006h,080h,014h,08ah,080h,004h,003h,001h,0ceh	; 7661  ................
	defb 009h,003h,001h,0ceh,005h,003h,080h,004h,003h,001h,0cdh,009h,003h,001h,0cdh,005h	; 7671  ................
	defb 003h,080h,004h,003h,001h,0cfh,009h,003h,001h,0cfh,005h,003h,080h,004h,003h,001h	; 7681  ................
	defb 0d0h,009h,003h,001h,0d0h,005h,003h,080h,009h,003h,001h,0d0h,00ah,003h,080h,009h	; 7691  ................
	defb 003h,001h,0cfh,00ah,003h,080h,001h,0cfh,008h,003h,001h,0cfh,00ah,003h,080h,001h	; 76a1  ................
	defb 0cdh,008h,003h,001h,0cdh,00ah,003h,080h,001h,0d0h,008h,003h,001h,0cfh,00ah,003h	; 76b1  ................
	defb 080h,001h,0ceh,008h,003h,001h,0ceh,00ah,003h,080h,014h,003h,080h	; 76c1  .............

; ----------------------------------------------------------------------
; DATOS tabla_de_columnas_A: 32 punteros, uno por columna de la pantalla;
;   0x73E7 lo mete en (0xE250) y 0x7629 lo va gastando de dos en dos
;   0x76ce..0x770e  (64 bytes)
DATA_tabla_de_columnas_A:
	defb 061h,076h,064h,076h,067h,076h,06ah,076h,06dh,076h,078h,076h,083h,076h,083h,076h	; 76ce  avdvgvjvmvxv.v.v
	defb 083h,076h,083h,076h,083h,076h,083h,076h,08eh,076h,08eh,076h,0cbh,076h,0cbh,076h	; 76de  .v.v.v.v.v.v.v.v
	defb 0cbh,076h,0cbh,076h,099h,076h,099h,076h,0a0h,076h,0a0h,076h,0b9h,076h,0b9h,076h	; 76ee  .v.v.v.v.v.v.v.v
	defb 0a7h,076h,0a7h,076h,0a7h,076h,0a7h,076h,0a7h,076h,0a7h,076h,0b0h,076h,0c2h,076h	; 76fe  .v.v.v.v.v.v.v.v

; ----------------------------------------------------------------------
; DATOS columnas_del_decorado_B: doce columnas, mismo lenguaje y las doce de
;   veinte celdas. Dibujado desde la ROM, este segundo decorado es EL
;   CASTILLO: muro de ladrillo con ventanas arriba y columnas abajo. Cuadra
;   con el rotulo de 0x75A7, que pone "CASTLE"
;   0x770e..0x778a  (124 bytes)
DATA_columnas_del_decorado_B:
	defb 002h,003h,004h,0e1h,00dh,0dch,001h,0dah,080h,002h,003h,004h,0e0h,00dh,0dbh,001h	; 770e  ................
	defb 0dah,080h,002h,003h,006h,0e1h,00bh,0dch,001h,0dah,080h,002h,003h,006h,0e0h,00bh	; 771e  ................
	defb 0dbh,001h,0dah,080h,002h,003h,006h,0e1h,004h,0dch,007h,0ddh,001h,0dah,080h,002h	; 772e  ................
	defb 003h,003h,0e0h,001h,0d8h,00dh,0dbh,001h,0dah,080h,002h,003h,003h,0e1h,001h,001h	; 773e  ................
	defb 006h,0dch,007h,0ddh,001h,0dah,080h,002h,003h,003h,0e0h,001h,0d9h,00dh,0dbh,001h	; 774e  ................
	defb 0dah,080h,002h,003h,004h,0e1h,006h,0dch,007h,0ddh,001h,0dah,080h,007h,003h,001h	; 775e  ................
	defb 0dfh,004h,0dch,004h,0ddh,001h,0deh,002h,0ddh,001h,0dah,080h,007h,003h,001h,0dfh	; 776e  ................
	defb 00bh,0dch,001h,0dah,080h,006h,003h,00dh,0dch,001h,0dah,080h	; 777e  ............

; ----------------------------------------------------------------------
; DATOS tabla_de_columnas_B: los otros 32 punteros; 0x73EC cambia a este
;   decorado al llegar a la novena tanda
;   0x778a..0x77ca  (64 bytes)
DATA_tabla_de_columnas_B:
	defb 00eh,077h,017h,077h,00eh,077h,017h,077h,00eh,077h,029h,077h,020h,077h,029h,077h	; 778a  .w.w.w.w.w)w w)w
	defb 020h,077h,029h,077h,032h,077h,03dh,077h,048h,077h,055h,077h,048h,077h,017h,077h	; 779a   w)w2w=wHwUwHw.w
	defb 060h,077h,029h,077h,060h,077h,029h,077h,06bh,077h,029h,077h,07ah,077h,03dh,077h	; 77aa  `w)w`w)wkw)wzw=w
	defb 083h,077h,055h,077h,083h,077h,017h,077h,083h,077h,029h,077h,07ah,077h,029h,077h	; 77ba  .wUw.w.w.w)wzw)w

; ======================================================================
; CODIGO 0x77ca..0x79de  (532 bytes)
; ======================================================================


mira_los_bichos_caidos:
	ld hl,0e134h		;77ca
	ld b,028h		;77cd
mira_los_huecos_de_tipo_c0:
	ld a,(hl)			;77cf
	cp 0c0h		;77d0   ; solo los de tipo 0xC0
	jr nz,L_77E0		;77d2
	dec hl			;77d4
	dec hl			;77d5
	ld de,00810h		;77d6   ; ocho por dieciseis de caja
	push bc			;77d9
	call caja_alrededor_del_jugador		;77da
	pop bc			;77dd
	ret c			;77de   ; acarreo: hay contacto
	inc hl			;77df
L_77E0:
	inc hl			;77e0   ; cuatro bytes por hueco
	inc hl			;77e1
	inc hl			;77e2
	djnz mira_los_huecos_de_tipo_c0		;77e3
	and a			;77e5
	ret			;77e6
suelta_el_premio:
	ld b,(hl)			;77e7   ; la posicion
	dec hl			;77e8
	ld c,(hl)			;77e9
	push hl			;77ea
	push bc			;77eb
	call repinta_el_objeto		;77ec
	pop bc			;77ef
	ld a,b			;77f0
	sub 010h		;77f1   ; dieciseis hacia un lado
	ld b,a			;77f3
	ld a,c			;77f4
	sub 008h		;77f5   ; y ocho hacia el otro
	ld c,a			;77f7
	xor a			;77f8
	call suma_los_puntos_del_tipo		;77f9   ; el sonido
	pop hl			;77fc
	ld de,0e225h		;77fd
	ld bc,00300h		;7800   ; tres huecos
L_7803:
	ld a,(de)			;7803
	or a			;7804   ; libre
	jr z,coloca_el_bicho_caido		;7805
	inc de			;7807
	inc c			;7808   ; el numero de hueco
	djnz L_7803		;7809
	jr L_7833		;780b
coloca_el_bicho_caido:
	push hl			;780d
	ld a,(0e1b2h)		;780e   ; el estado del jugador
	cp 005h		;7811   ; el estado 5 lo convierte en premio
	ld hl,0e1b6h		;7813
	jr z,convierte_el_bicho_en_premio		;7816
	inc hl			;7818

; ----------------------------------------------------------------------
; CONVERTIR UN BICHO EN PREMIO: le pone los dos bits de arriba, le copia la posicion al hueco de sprite con un `ldi`, le resta cuatro a la otra coordenada y le clava el patron 0xAC con color 6. El bicho original queda retirado con 0xD0.
; ----------------------------------------------------------------------
convierte_el_bicho_en_premio:
	ld a,(hl)			;7819
	pop hl			;781a
	or 0c0h		;781b   ; los dos bits de arriba
	ld (de),a			;781d
	ld de,0e114h		;781e   ; su hueco de sprite
	call hueco_de_sprite_en_de		;7821
	ldi		;7824   ; un byte de posicion
	ld a,(hl)			;7826
	sub 004h		;7827   ; cuatro menos
	ld (de),a			;7829
	inc de			;782a
	ld a,0ach		;782b   ; el patron del premio
	ld (de),a			;782d
	inc de			;782e
	ld a,006h		;782f   ; y su color
	ld (de),a			;7831
	dec hl			;7832
L_7833:
	ld (hl),0d0h		;7833   ; el bicho, retirado
	ret			;7835

; ----------------------------------------------------------------------
; LOS TRES BICHOS CAIDOS de 0xE225: el bit 6 de su estado decide cual de las dos maneras de moverse les toca. Los que se salen de la pantalla no se tocan.
; ----------------------------------------------------------------------
mueve_los_tres_caidos:
	ld de,0e225h		;7836
	ld bc,00300h		;7839   ; tres
L_783C:
	push bc			;783c
	push de			;783d
	ld a,(de)			;783e
	or a			;783f   ; hueco vacio
	jr z,L_785A		;7840
	ld b,a			;7842
	ld hl,0e114h		;7843   ; su hueco de sprite
	call hueco_de_sprite		;7846
	call esta_en_la_banda_util		;7849   ; esta en pantalla?
	jr nc,L_785A		;784c
	bit 6,b		;784e   ; el bit 6: una manera u otra
	jr z,L_7857		;7850
	call cae_el_bicho		;7852
	jr L_785A		;7855
L_7857:
	call anda_el_bicho		;7857
L_785A:
	pop de			;785a
	pop bc			;785b
	inc de			;785c   ; un byte por hueco
	inc c			;785d
	djnz L_783C		;785e
	ret			;7860

; ----------------------------------------------------------------------
; EL BICHO QUE CAE: cuatro pixeles por vez, con el dibujo alternando por el bit 2 de la propia posicion -o sea cada cuatro pixeles-, y ANTES de seguir mira la celda 0x10 por debajo: si tiene el indice 3, es que hay algo y se para.
; ----------------------------------------------------------------------
cae_el_bicho:
	ld a,(hl)			;7861
	add a,004h		;7862   ; cuatro pixeles
	ld (hl),a			;7864
	ld b,a			;7865
	inc hl			;7866
	inc (hl)			;7867   ; el dibujo, uno mas
	bit 2,a		;7868   ; el bit 2: alterna solo
	jr nz,L_786E		;786a
	dec (hl)			;786c   ; o vuelve atras
	dec (hl)			;786d
L_786E:
	push hl			;786e
	push de			;786f
	ld h,(hl)			;7870
	ld a,b			;7871
	add a,010h		;7872   ; dieciseis por debajo
	ld l,a			;7874
	call lee_la_celda_de_ahi		;7875   ; que hay en esa celda
	pop de			;7878
	pop hl			;7879
	cp 003h		;787a   ; el indice 3: hay algo ahi
	ret z			;787c
	ex de,hl			;787d
	res 6,(hl)		;787e   ; se quita el bit 6: deja de caer
	ret			;7880

; ----------------------------------------------------------------------
; EL BICHO QUE ANDA: dos pixeles en el sentido que diga el bit 3 de su estado, y el dibujo alterna con el bit 1 de la propia posicion. Antes de cada paso mira DOS celdas -la de 0x14 por delante y la de 0x10 por debajo- y, si no puede pasar, se queda.
; ----------------------------------------------------------------------
anda_el_bicho:
	push de			;7881
	inc hl			;7882
	ld a,(de)			;7883
	ld b,a			;7884
	bit 3,a		;7885   ; el bit 3: hacia donde anda
	ld a,002h		;7887   ; dos pixeles hacia delante
	jr nz,L_788D		;7889
	ld a,0feh		;788b   ; o dos hacia atras
L_788D:
	add a,(hl)			;788d
	ld (hl),a			;788e
	dec hl			;788f
	dec (hl)			;7890   ; el dibujo, uno menos
	bit 1,a		;7891   ; el bit 1: alterna solo
	jr nz,L_7897		;7893
	inc (hl)			;7895   ; o dos mas
	inc (hl)			;7896
L_7897:
	push hl			;7897
	pop ix		;7898
	ld a,(hl)			;789a
	add a,014h		;789b   ; veinte pixeles por delante
	inc hl			;789d
	ld h,(hl)			;789e
	ld l,a			;789f
	bit 3,b		;78a0   ; el bit 3 elige que celda mirar
	jr nz,mira_dos_celdas_por_delante		;78a2
	ld a,h			;78a4
	add a,010h		;78a5   ; dieciseis mas abajo
	ld h,a			;78a7

; ----------------------------------------------------------------------
; MIRAR DOS CELDAS, una debajo de otra: la primera tiene que estar entre 0xCD y 0xD0 -por donde se puede pasar- y la de ocho pixeles mas arriba entre 0x8C y 0x8E. Si no, se marca el bit 6.
; ----------------------------------------------------------------------
mira_dos_celdas_por_delante:
	call lee_la_celda_de_ahi		;78a8   ; que hay ahi
	pop de			;78ab
	sub 0cdh		;78ac   ; los indices desde 0xCD
	cp 004h		;78ae   ; cuatro seguidos
	ret c			;78b0
	push de			;78b1
	ld a,l			;78b2
	sub 008h		;78b3   ; ocho pixeles mas arriba
	ld l,a			;78b5
	call lee_la_celda_de_ahi		;78b6
	pop de			;78b9
	sub 08ch		;78ba   ; y ahi, los indices desde 0x8C
	cp 003h		;78bc   ; tres seguidos
	jr c,retira_el_bicho_y_avisa		;78be
	ex de,hl			;78c0
	set 6,(hl)		;78c1   ; y si no, el bit 6
	ret			;78c3

; ----------------------------------------------------------------------
; RETIRAR EL BICHO Y AVISAR A LOS PERSEGUIDORES: borra su ficha, le pone la fila 0xC3 y recorre los tres huecos de 0xE104 buscando alguno que este a menos de 0x10 en las dos coordenadas para apuntarlo.
; ----------------------------------------------------------------------
retira_el_bicho_y_avisa:
	xor a			;78c4
	ld (de),a			;78c5   ; la ficha, a cero
	ld (ix+000h),0c3h		;78c6   ; 0xC3: fuera de la pantalla
	ex de,hl			;78ca
	ld hl,0e104h		;78cb
	ld bc,00300h		;78ce   ; tres huecos
L_78D1:
	ld a,e			;78d1
	sub (hl)			;78d2
	inc hl			;78d3
	cp 010h		;78d4   ; dieciseis pixeles
	jr nc,L_78DE		;78d6
	ld a,d			;78d8
	sub (hl)			;78d9
	cp 010h		;78da   ; y dieciseis en la otra
	jr c,apunta_al_perseguidor		;78dc
L_78DE:
	inc hl			;78de   ; tres bytes por hueco
	inc hl			;78df
	inc hl			;78e0
	inc c			;78e1
	djnz L_78D1		;78e2
L_78E4:
	jp L_6FC7		;78e4
apunta_al_perseguidor:
	inc hl			;78e7   ; dos bytes mas alla
	inc hl			;78e8
	ld a,(hl)			;78e9   ; el tipo
	or a			;78ea   ; vacio: al siguiente
	jr z,L_78E4		;78eb
	ex de,hl			;78ed   ; se cambian
	ld hl,0e21ch		;78ee   ; la tabla de fichas
	ld a,c			;78f1   ; el numero de ficha
	add a,a			;78f2   ; el numero por tres
	add a,c			;78f3   ; por tres, que es lo que ocupa cada una
	call suma_a_a_hl		;78f4   ; indexada
	ld (hl),080h		;78f7   ; se marca el bit 7
	ld hl,0e239h		;78f9   ; el contador de perseguidores
	ld a,(hl)			;78fc
	inc a			;78fd   ; el contador, uno mas
	cp 003h		;78fe   ; el tope son tres
	ret nc			;7900   ; y de ahi no pasa
	ld (hl),a			;7901   ; guardado
	cp 002h		;7902   ; con dos ya esta
	ret z			;7904
	inc hl			;7905   ; el byte siguiente
	ld (hl),080h		;7906   ; se marca
	inc hl			;7908   ; el siguiente
	ld (hl),c			;7909   ; y el numero de ficha detras
	dec de			;790a   ; el byte de antes
	ld a,090h		;790b
	ld (de),a			;790d   ; guardado
	ret			;790e

; ----------------------------------------------------------------------
; EL PERSEGUIDOR EN MARCHA. Con el bit 7 puesto solo se atiende uno de cada ocho cuadros; el bit 3 le anade 0x40 al estado.
; ----------------------------------------------------------------------
mueve_el_perseguidor:
	ld hl,0e23ah		;790f   ; la ficha del perseguidor
	ld a,(hl)			;7912   ; su estado
	or a			;7913   ; vacia
	ret z			;7914   ; sin perseguidor no hay nada que mover
	ld b,a			;7915   ; en B
	ld d,h			;7916   ; se copia el puntero a DE
	ld e,l			;7917
	inc hl			;7918   ; el byte siguiente
	ld c,(hl)			;7919   ; el objeto al que sigue
	ld hl,0e104h		;791a   ; el bufer de atributos
	call hueco_de_sprite		;791d   ; su hueco
	call esta_en_la_banda_util		;7920   ; si esta a la vista
	jr nc,L_7939		;7923   ; fuera: no se dibuja
	bit 7,b		;7925   ; el bit 7 del estado
	jr z,L_793C		;7927
	ld a,(0e003h)		;7929   ; el contador de cuadros
	and 007h		;792c   ; uno de cada ocho
	ret nz			;792e
	call alterna_el_dibujo_del_bicho		;792f   ; el dibujo, alternado
	bit 3,b		;7932   ; el bit 3
	ret z			;7934   ; sin el, ya esta
	ld a,040h		;7935
	ld (de),a			;7937   ; al estado
	ret			;7938   ; y se vuelve
L_7939:
	dec de			;7939
	ld (de),a			;793a
	ret			;793b
L_793C:
	push hl			;793c
	ld e,(hl)			;793d   ; la posicion del premio
	inc hl			;793e
	ld a,(hl)			;793f
	bit 0,a		;7940   ; el bit 0 elige el desplazamiento
	ld b,0f8h		;7942
	jr nz,elige_el_tipo_del_premio		;7944
	ld b,0c8h		;7946

; ----------------------------------------------------------------------
; EL TIPO DEL PREMIO SEGUN DE DONDE VENGA: 0xC5 si el valor es 4, 0xC6 si es 15 y 0xC7 en los demas casos.
; ----------------------------------------------------------------------
elige_el_tipo_del_premio:
	add a,b			;7948
	ld d,a			;7949
	inc hl			;794a
	inc hl			;794b
	ld a,(hl)			;794c
	ld b,0c5h		;794d   ; el primer tipo
	cp 004h		;794f
	jr z,L_7959		;7951
	inc b			;7953   ; el segundo
	cp 00fh		;7954
	jr z,L_7959		;7956
	inc b			;7958   ; y el tercero
L_7959:
	ld a,b			;7959
	ld (0e240h),a		;795a   ; que queda apuntado
	ld (0e23eh),de		;795d
	pop hl			;7961
	ld (hl),0c3h		;7962
	ld hl,0e23ch		;7964
L_7967:
	push hl			;7967
	ld de,0e132h		;7968
	ld bc,02800h		;796b
busca_hueco_de_premio:
	ld a,(de)			;796e
	cp 0d0h		;796f   ; retirado: libre
	jr z,engancha_el_segundo_trozo		;7971
	inc de			;7973   ; tres bytes por objeto
	inc de			;7974
	inc de			;7975
	inc c			;7976
	djnz busca_hueco_de_premio		;7977
	jr baja_el_contador_de_premios		;7979
engancha_el_segundo_trozo:
	ld (hl),c			;797b
	ld hl,0e23eh		;797c
	ld bc,00003h		;797f   ; tres bytes de ficha
	ldir		;7982
	ex de,hl			;7984
	dec hl			;7985
	dec hl			;7986
	ld a,(hl)			;7987
	add a,018h		;7988   ; veinticuatro pixeles mas alla
	ld (hl),a			;798a
	ld (0e23fh),a		;798b   ; y queda apuntada
	dec hl			;798e
	call pinta_bloque_de_la_ficha		;798f
baja_el_contador_de_premios:
	pop hl			;7992
	inc hl			;7993
	ex de,hl			;7994
	ld hl,0e239h		;7995
	dec (hl)			;7998   ; uno menos
	ex de,hl			;7999
	jr nz,L_7967		;799a
	inc de			;799c
	xor a			;799d
	ld (de),a			;799e
	ld a,007h		;799f   ; y al llegar a cero, el sonido 7
	jp pide_un_sonido		;79a1
suma_los_puntos_del_tipo:
	ex af,af'			;79a4
	push bc			;79a5
	ld hl,0e252h		;79a6
	ld bc,00400h		;79a9
L_79AC:
	ld a,(hl)			;79ac
	or a			;79ad   ; hueco vacio
	jr z,L_79B6		;79ae
	inc hl			;79b0
	inc c			;79b1   ; el numero de hueco
	djnz L_79AC		;79b2
	jr cobra_el_objeto		;79b4
L_79B6:
	set 7,(hl)		;79b6

; ----------------------------------------------------------------------
; COBRAR UN OBJETO: saca de la tabla de 0x79DE los puntos que vale -indexada por su tipo, por dos- y los suma con el byte alto, o sea en centenas. Ademas deja el sprite del premio con el color 0x0F.
; ----------------------------------------------------------------------
cobra_el_objeto:
	ld hl,0e120h		;79b8   ; el hueco del sprite
	call hueco_de_sprite		;79bb   ; el suyo
	pop bc			;79be   ; la posicion
	ex af,af'			;79bf   ; el tipo guardado
	ex de,hl			;79c0   ; se cambian
	add a,a			;79c1   ; el tipo por dos
	ld hl,079deh		;79c2   ; la tabla de valores
	call suma_a_a_hl		;79c5   ; indexada
	ld a,(hl)			;79c8   ; el byte bajo
	inc hl			;79c9
	ld h,(hl)			;79ca   ; y el alto
	ex de,hl			;79cb   ; se cambian otra vez
	ld (hl),c			;79cc   ; la columna, al atributo
	inc hl			;79cd
	ld (hl),b			;79ce   ; la fila
	inc hl			;79cf
	ld (hl),a			;79d0   ; el patron
	inc hl			;79d1
	ld (hl),00fh		;79d2   ; el color del premio
	ld e,000h		;79d4   ; el byte bajo de los puntos, a cero
	call suma_puntos		;79d6   ; y se suman los puntos
	ld a,004h		;79d9   ; y suena el aviso
	jp pide_un_sonido		;79db

; ----------------------------------------------------------------------
; DATOS premios: ocho parejas; 0x79C2 indexa con el tipo por dos y saca el
;   patron del premio y los puntos que da
;   0x79de..0x79ee  (16 bytes)
DATA_premios:
	defb 060h,001h,064h,002h,06ch,004h,080h,006h,068h,005h,08ch,010h,088h,020h,084h,030h	; 79de  `.d.l...h.... .0

; ======================================================================
; CODIGO 0x79ee..0x7b14  (294 bytes)
; ======================================================================


limpia_los_huecos_sobrantes:
	ld a,(0e003h)		;79ee
	and 00fh		;79f1
	ret nz			;79f3
	ld hl,0e252h		;79f4
	ld bc,00400h		;79f7
L_79FA:
	bit 7,(hl)		;79fa
	jr z,L_7A0E		;79fc
	inc (hl)			;79fe
	bit 2,(hl)		;79ff
	jr z,L_7A0E		;7a01
	ld (hl),000h		;7a03   ; la ficha, borrada
	ld de,0e120h		;7a05
	call hueco_de_sprite_en_de		;7a08
	ld a,0c3h		;7a0b   ; 0xC3: fuera de la pantalla
	ld (de),a			;7a0d
L_7A0E:
	inc hl			;7a0e
	inc c			;7a0f
	djnz L_79FA		;7a10
	ret			;7a12
pide_un_sonido:
	di			;7a13
	ld d,000h		;7a14   ; D a cero: no se fuerza
	call reparte_el_sonido		;7a16
	ei			;7a19
	ret			;7a1a

; ----------------------------------------------------------------------
; REPARTIR UN SONIDO ENTRE LAS VOCES. El numero decide a que grupo va -por debajo de 0x8C, de 0x8C a 0x8F, o de 0x90 en adelante-, y dentro de los efectos los numeros 9 y 10 tienen su propio hueco. Cada grupo lleva PRIORIDAD: si lo que suena tiene el numero mas alto, el nuevo no entra.
; ----------------------------------------------------------------------
reparte_el_sonido:
	ld c,a			;7a1b   ; el numero de sonido
	ld b,002h		;7a1c   ; dos voces
	ld hl,0e012h		;7a1e   ; la voz de los efectos
	cp 08ch		;7a21   ; por debajo de 0x8C: efecto
	jr c,L_7A2C		;7a23
	cp 090h		;7a25   ; de 0x8C a 0x8F
	jr c,compara_prioridades		;7a27
	inc b			;7a29   ; y de 0x90 en adelante, una voz mas
	jr compara_prioridades		;7a2a
L_7A2C:
	dec b			;7a2c
	and 03fh		;7a2d   ; seis bits
	cp 009h		;7a2f   ; los sonidos 9 y 10 tienen su hueco
	jr z,compara_prioridades		;7a31
	cp 00ah		;7a33
	jr z,L_7A41		;7a35
	ld hl,0e028h		;7a37
	jr compara_prioridades		;7a3a
L_7A3C:
	ld hl,0e012h		;7a3c
	jr compara_prioridades		;7a3f
L_7A41:
	ld hl,0e01dh		;7a41
compara_prioridades:
	dec d			;7a44   ; D dice si se fuerza
	jr z,arranca_la_voz		;7a45
	ld e,(hl)			;7a47   ; la prioridad de lo que esta sonando
	ld a,e			;7a48
	and 03fh		;7a49
	ld (hl),a			;7a4b
	ld a,c			;7a4c
	and 03fh		;7a4d
	cp (hl)			;7a4f   ; contra la del que llega
	ld (hl),e			;7a50
	ret z			;7a51   ; si empatan o pierde, no entra
	ret c			;7a52
	cp 019h		;7a53   ; por debajo de 0x19 va directo
	jr c,arranca_la_voz		;7a55
	and 03fh		;7a57
	ld c,a			;7a59

; ----------------------------------------------------------------------
; ARRANCAR UNA VOZ: la cuenta a uno para que suene en el cuadro siguiente, el numero de sonido y los dos bytes de la partitura, sacados de la tabla de 0x7C58. Los cinco bytes que se salta con `ld a,005h / add a,l` son el resto del estado.
; ----------------------------------------------------------------------
arranca_la_voz:
	add a,a			;7a5a   ; el numero por dos
	ld de,07c58h		;7a5b   ; la tabla de sonidos
	call suma_a_a_de		;7a5e
	dec hl			;7a61
	dec hl			;7a62
L_7A63:
	ld (hl),001h		;7a63   ; la cuenta, a uno: suena ya
	inc hl			;7a65
	ld (hl),001h		;7a66   ; la prioridad
	inc hl			;7a68
	ld (hl),c			;7a69   ; el numero de sonido
	inc hl			;7a6a
	ld a,(de)			;7a6b   ; y su partitura, dos bytes
	ld (hl),a			;7a6c
	inc hl			;7a6d
	inc de			;7a6e
	ld a,(de)			;7a6f
	ld (hl),a			;7a70
	ld a,005h		;7a71   ; cinco bytes mas alla del estado
	add a,l			;7a73
	ld l,a			;7a74
	ld (hl),000h		;7a75   ; las vueltas, a cero
	inc hl			;7a77
	inc hl			;7a78
	inc de			;7a79
	djnz L_7A63		;7a7a   ; y la otra voz
	ret			;7a7c
repite_o_encadena:
	inc hl			;7a7d
	ld a,(ix+009h)		;7a7e   ; las vueltas dadas
	inc a			;7a81   ; una mas
	cp (hl)			;7a82   ; contra las que pide la partitura
	jp z,L_7BA0		;7a83
	jp m,rearranca_el_mismo_sonido		;7a86
	dec a			;7a89
rearranca_el_mismo_sonido:
	ex af,af'			;7a8a
	ld a,(ix+002h)		;7a8b
	push bc			;7a8e
	ld d,001h		;7a8f   ; se fuerza: no se compara prioridad
	call reparte_el_sonido		;7a91
	pop bc			;7a94
	ex af,af'			;7a95
	ld (ix+009h),a		;7a96   ; con las vueltas apuntadas
	ret			;7a99
abre_o_cierra_el_canal:
	ld a,(0e031h)		;7a9a   ; la copia del registro 7
	ld e,a			;7a9d
	ld a,c			;7a9e   ; el canal
	cp 001h		;7a9f
	jr z,L_7AA4		;7aa1
	dec a			;7aa3
L_7AA4:
	rlca			;7aa4   ; tres rotaciones: el bit del canal
	rlca			;7aa5
	rlca			;7aa6
	dec d			;7aa7   ; D=1 pone, D=0 quita
	jr z,L_7AAE		;7aa8
	cpl			;7aaa
	and e			;7aab
	jr L_7AAF		;7aac
L_7AAE:
	or e			;7aae
L_7AAF:
	set 1,a		;7aaf
	bit 4,a		;7ab1
	jr z,escribe_el_mezclador_del_psg		;7ab3
	res 1,a		;7ab5

; ----------------------------------------------------------------------
; EL MEZCLADOR DEL PSG, que es el registro 7 y NO el volumen: sus tres bits de abajo abren o cierran el TONO de cada canal, los tres siguientes el RUIDO, y los dos de arriba dicen si cada puerto de proposito general es de entrada o de salida -el A es por donde se leen los mandos, asi que tiene que quedar como entrada-. El valor de arranque es 0xB8: los tres tonos abiertos, los tres ruidos cerrados y el puerto A como entrada. La copia en (0xE031) es la que consulta el reproductor para abrir y cerrar canales sin releer el PSG.
; ----------------------------------------------------------------------
escribe_el_mezclador_del_psg:
	ld (0e031h),a		;7ab7   ; la copia en RAM
	ld e,a			;7aba   ; el valor, apartado en E
	ld a,007h		;7abb   ; registro 7 del PSG
	jp 00093h		;7abd   ; BIOS WRTPSG - Writes data to PSG-register

; ----------------------------------------------------------------------
; EL REPRODUCTOR, una vez por cuadro y lo primero que hace la interrupcion. TRES voces de once bytes desde 0xE010, recorridas con IX saltando de once en once mientras C va 1, 3, 5: los registros de periodo del PSG. La voz cuyo sonido sea el 0x0B lleva ademas un tratamiento aparte.
; ----------------------------------------------------------------------
suena_un_cuadro:
	ld a,(0e031h)		;7ac0   ; el volumen general
	call escribe_el_mezclador_del_psg		;7ac3
	ld c,001h		;7ac6   ; el primer canal del PSG
	ld ix,0e010h		;7ac8   ; el estado de la primera voz
	exx			;7acc
	ld b,003h		;7acd   ; tres voces
	ld de,0000bh		;7acf   ; once bytes cada una
L_7AD2:
	exx			;7ad2
	ld a,(ix+002h)		;7ad3   ; el sonido de esta voz
	push af			;7ad6
	cp 00bh		;7ad7   ; el 0x0B va aparte
	call z,barrido_del_sonido_0B		;7ad9
	pop af			;7adc
	or a			;7add   ; callada: no se toca
	call nz,avanza_una_voz		;7ade
	inc c			;7ae1   ; dos registros por canal
	inc c			;7ae2
	exx			;7ae3
	add ix,de		;7ae4   ; y once bytes hasta la voz siguiente
	djnz L_7AD2		;7ae6
	exx			;7ae8
	ret			;7ae9

; ----------------------------------------------------------------------
; EL SONIDO 0x0B, que no lee partitura: le SUMA DOS al periodo en cada cuadro -con acarreo al byte alto- de modo que el tono sube solo. Y cuando (0xE032) vale cero, en vez de eso copia cuatro bytes hacia atras con `lddr`. Es el unico sonido con logica propia.
; ----------------------------------------------------------------------
barrido_del_sonido_0B:
	ld hl,0e035h		;7aea   ; su bloque de estado
	ld de,07b17h		;7aed
	ld a,(0e032h)		;7af0   ; la bandera que elige el modo
	cp 000h		;7af3
	jr z,L_7B07		;7af5
	ld a,002h		;7af7   ; dos al periodo
	add a,(hl)			;7af9
	ld (hl),a			;7afa
	dec hl			;7afb
	jr nc,L_7AFF		;7afc
	inc (hl)			;7afe   ; con acarreo al byte alto
L_7AFF:
	dec hl			;7aff
	ld (ix+003h),l		;7b00   ; y queda apuntado
	ld (ix+004h),h		;7b03
	ret			;7b06
L_7B07:
	push bc			;7b07
	ex de,hl			;7b08
	ld bc,00004h		;7b09   ; cuatro bytes
	lddr		;7b0c   ; copiados hacia atras
	ex de,hl			;7b0e
	pop bc			;7b0f
	inc hl			;7b10
	inc hl			;7b11
	jr L_7AFF		;7b12

; ----------------------------------------------------------------------
; DATOS arranque_de_la_voz: los cuatro bytes que 0x7B07 copia HACIA ATRAS con
;   `lddr` desde 0x7B17 a 0xE032..0xE035
;   0x7b14..0x7b18  (4 bytes)
DATA_arranque_de_la_voz:
	defb 001h,021h,0b0h,040h	; 7b14

; ======================================================================
; CODIGO 0x7b18..0x7c4e  (310 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; AVANZAR UNA VOZ. (ix+0) es lo que le queda a la nota; mientras no llegue a cero no se lee nada. El valor 0xFE de la partitura es la marca de repeticion, y los nibbles altos son modificadores: 0x2n cambia el instrumento y 0x1n toca el envolvente.
; ----------------------------------------------------------------------
avanza_una_voz:
	bit 6,a		;7b18   ; el bit 6 del estado
	ld d,001h		;7b1a
	call z,abre_o_cierra_el_canal		;7b1c
	ld a,(ix+002h)		;7b1f
	or a			;7b22
	jp m,sostiene_la_nota		;7b23
	dec (ix+000h)		;7b26   ; lo que le queda a la nota
	ret nz			;7b29   ; todavia suena
L_7B2A:
	ld l,(ix+003h)		;7b2a   ; por donde va la partitura
	ld h,(ix+004h)		;7b2d
	ld a,(hl)			;7b30
	cp 0feh		;7b31   ; 0xFE: volver al principio
	jp z,repite_o_encadena		;7b33
	jr nc,L_7BA0		;7b36
	bit 7,(ix+002h)		;7b38
	jp nz,L_7BDB		;7b3c
	and 0f0h		;7b3f   ; el nibble alto manda
	cp 020h		;7b41   ; 0x2n cambia el instrumento
	jr nz,L_7B4C		;7b43
	ld a,(hl)			;7b45
	and 00fh		;7b46
	ld (ix+001h),a		;7b48   ; el nibble bajo es el numero
	inc hl			;7b4b
L_7B4C:
	ld a,(hl)			;7b4c
	and 0f0h		;7b4d
	cp 010h		;7b4f   ; 0x1n toca el envolvente
	jr nz,mira_el_modificador_de_canal		;7b51
	ld a,(hl)			;7b53
	and 01fh		;7b54   ; y los cinco bits de abajo, su forma
	ld e,a			;7b56
	ld a,006h		;7b57
	call 00093h		;7b59   ; BIOS WRTPSG - Writes data to PSG-register
	ld d,000h		;7b5c
	call abre_o_cierra_el_canal		;7b5e
	inc hl			;7b61
	ld a,(hl)			;7b62
mira_el_modificador_de_canal:
	ld b,(ix+002h)		;7b63
	bit 6,b		;7b66   ; el bit 6: la voz esta encadenada
	jr z,lee_la_nota_de_la_partitura		;7b68
	ld a,c			;7b6a
	cp 003h		;7b6b   ; y solo en el canal 3
	ld a,(hl)			;7b6d
	jr nz,lee_la_nota_de_la_partitura		;7b6e
	inc hl			;7b70
	ld (ix+003h),l		;7b71
	ld (ix+004h),h		;7b74
	call fija_la_duracion_de_la_nota		;7b77
	ret			;7b7a
lee_la_nota_de_la_partitura:
	and 0f0h		;7b7b   ; el nibble alto es la DURACION
	ld b,a			;7b7d
	xor (hl)			;7b7e   ; y el bajo, cruzado, la nota
	ld d,a			;7b7f
	inc hl			;7b80
	ld e,(hl)			;7b81   ; el byte siguiente completa
	inc hl			;7b82
	ld (ix+003h),l		;7b83   ; la partitura queda apuntada
	ld (ix+004h),h		;7b86
	ex de,hl			;7b89
	call escribe_la_nota		;7b8a   ; y se convierte en periodo
	ld a,b			;7b8d
	rrca			;7b8e   ; cuatro giros: la duracion a su sitio
	rrca			;7b8f
	rrca			;7b90
	rrca			;7b91
fija_la_duracion_de_la_nota:
	ld h,a			;7b92
	ld a,(ix+001h)		;7b93   ; la duracion que toca
	ld (ix+000h),a		;7b96
	add a,003h		;7b99   ; y tres mas al contador de apagado
	ld (ix+008h),a		;7b9b
	jr L_7BD2		;7b9e
L_7BA0:
	xor a			;7ba0
	ld (ix+009h),a		;7ba1   ; las vueltas, a cero
	ld d,001h		;7ba4
	call abre_o_cierra_el_canal		;7ba6
	xor a			;7ba9
	ld (ix+002h),a		;7baa   ; y el estado de la voz: se calla
	ld h,a			;7bad
	jr L_7BD2		;7bae
sostiene_la_nota:
	dec (ix+000h)		;7bb0   ; lo que le queda a la nota
	jp z,L_7B2A		;7bb3
	dec (ix+008h)		;7bb6   ; y la cuenta del apagado
	ld a,(ix+008h)		;7bb9
	cp (ix+000h)		;7bbc   ; cuando se juntan, empieza a bajar el volumen
	jr nz,L_7BC6		;7bbf
	cp 003h		;7bc1
	jr c,L_7BC9		;7bc3
	ret			;7bc5
L_7BC6:
	dec (ix+008h)		;7bc6
L_7BC9:
	ld a,(ix+007h)		;7bc9
	dec a			;7bcc
	ret m			;7bcd
	ld (ix+007h),a		;7bce
	ld h,a			;7bd1
L_7BD2:
	ld a,c			;7bd2
	rrca			;7bd3
	add a,088h		;7bd4
	ld e,h			;7bd6
	jp 00093h		;7bd7   ; BIOS WRTPSG - Writes data to PSG-register
L_7BDA:
	ret			;7bda
L_7BDB:
	and 0f0h		;7bdb   ; el nibble alto
	cp 0d0h		;7bdd   ; 0xDn: el paso del arpegio
	ld a,(hl)			;7bdf
	jr nz,L_7BE9		;7be0
	and 00fh		;7be2
	ld (ix+00ah),a		;7be4
	inc hl			;7be7
	ld a,(hl)			;7be8
L_7BE9:
	cp 0f0h		;7be9   ; 0xFn: el vibrato
	jr c,L_7BF4		;7beb
	and 00fh		;7bed   ; el nibble bajo
	ld (ix+006h),a		;7bef
	inc hl			;7bf2
	ld a,(hl)			;7bf3
L_7BF4:
	cp 0e0h		;7bf4   ; 0xEn: el volumen de la voz
	jr c,L_7BFF		;7bf6
	and 00fh		;7bf8   ; el nibble bajo
	ld (ix+005h),a		;7bfa
	inc hl			;7bfd
	ld a,(hl)			;7bfe
L_7BFF:
	and 00fh		;7bff
	ld b,a			;7c01
	ld a,(ix+00ah)		;7c02
	jr z,fija_la_duracion		;7c05
L_7C07:
	add a,(ix+00ah)		;7c07
	djnz L_7C07		;7c0a
fija_la_duracion:
	ld (ix+001h),a		;7c0c   ; la duracion de la nota
	ld a,(hl)			;7c0f   ; el byte de la partitura
	inc hl			;7c10   ; y se avanza
	ld (ix+003h),l		;7c11   ; y por donde se queda la partitura
	ld (ix+004h),h		;7c14
	and 0f0h		;7c17   ; el nibble de arriba
	rrca			;7c19   ; cuatro rotaciones, para bajarlo
	rrca			;7c1a
	rrca			;7c1b
	rrca			;7c1c
	ld b,a			;7c1d   ; en B
	sub 00ch		;7c1e   ; menos doce
	ld (ix+007h),a		;7c20   ; guardado
	jr z,nota_al_psg		;7c23   ; si es justo doce, al PSG
	ld a,(ix+006h)		;7c25   ; el valor de antes
	ld (ix+007h),a		;7c28   ; restituido
nota_al_psg:
	call fija_la_duracion_de_la_nota		;7c2b   ; la duracion
	ld a,b			;7c2e   ; el indice de la nota
	ld hl,07c4eh		;7c2f   ; la escala de doce
	call suma_a_a_hl		;7c32
	ld l,(hl)			;7c35   ; el periodo de esa nota
	ld h,000h		;7c36
	ld a,(ix+005h)		;7c38   ; las octavas a bajar
	or a			;7c3b
	jr z,escribe_la_nota		;7c3c
	ld b,a			;7c3e
L_7C3F:
	add hl,hl			;7c3f   ; doblar el periodo es bajar una octava
	djnz L_7C3F		;7c40
escribe_la_nota:
	ld a,c			;7c42
	ld e,h			;7c43
	call 00093h		;7c44   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,c			;7c47
	dec a			;7c48
	ld e,l			;7c49
	call 00093h		;7c4a   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;7c4d

; ----------------------------------------------------------------------
; DATOS escala_cromatica: los doce periodos; 0x7C2F los baja de octava con
;   `add hl,hl`
;   0x7c4e..0x7c5a  (12 bytes)
DATA_escala_cromatica:
	defb 06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h	; 7c4e  jd_YTPKGC?<8

; ----------------------------------------------------------------------
; DATOS tabla_de_sonidos: 33 punteros
;   0x7c5a..0x7c9c  (66 bytes)
DATA_tabla_de_sonidos:
	defw 07c9dh,07cb5h,07cceh,07cach,07cd9h,07d03h,07d09h,07d56h	; 7c5a
	defw 07d15h,07d37h,07c9ch,07d9dh,07dd5h,07edeh,07effh,07e0eh	; 7c6a
	defw 07e46h,07e79h,07f17h,07f2bh,07f43h,07ebdh,07e9fh,07e83h	; 7c7a
	defw 07d61h,07d79h,07c9ch,07d91h,07c9ch,07c9ch,07c9ch,07c9ch	; 7c8a
	defw 07c9ch	; 7c9a  -> DATA_partituras

; ----------------------------------------------------------------------
; DATOS partituras: los sonidos a los que apunta la tabla
;   0x7c9c..0x7f4e  (690 bytes)
DATA_partituras:
	defb 0ffh,021h,01fh,0e1h,0f0h,02bh,000h,000h,021h,015h,0e1h,040h,02fh,000h,000h,0ffh	; 7c9c  .!...+..!..@/...
	defb 022h,0d0h,0a9h,0d0h,08eh,0d0h,06ah,0feh,002h,021h,0b0h,0e0h,0b0h,0c0h,0b0h,090h	; 7cac  ".....j..!......
	defb 0a0h,060h,022h,000h,000h,021h,0b1h,010h,0b0h,0e0h,0b0h,0c0h,0a0h,090h,022h,000h	; 7cbc  .`"..!........".
	defb 000h,0ffh,021h,0f0h,0c4h,0f0h,0bah,022h,0b0h,09ch,0c0h,081h,0ffh,021h,0d0h,050h	; 7ccc  ..!....".....!.P
	defb 0d0h,053h,0d0h,055h,0d0h,065h,0d0h,065h,0d0h,06ah,0d0h,070h,0d0h,075h,0d0h,07ah	; 7cdc  .S.U.e.e.j.p.u.z
	defb 0d0h,080h,0d0h,088h,0d0h,090h,0d0h,098h,0d0h,0a0h,0d0h,0a8h,0d0h,0b0h,0d0h,0bah	; 7cec  ................
	defb 0d0h,095h,0d0h,0a0h,0d0h,0a8h,0ffh,021h,0f1h,094h,0f0h,0fah,0ffh,023h,0d0h,06bh	; 7cfc  .......!.....#.k
	defb 0d0h,05fh,0d0h,055h,0d0h,050h,0d0h,047h,0ffh,021h,0c3h,057h,0d3h,05ah,0c3h,052h	; 7d0c  ._.U.P.G.!.W.Z.R
	defb 0d3h,056h,0c3h,051h,0d3h,059h,024h,000h,000h,021h,0c3h,027h,0d3h,02ah,0c3h,022h	; 7d1c  .V.Q.Y$..!.'.*."
	defb 0d3h,026h,0c3h,02ah,0c3h,025h,024h,000h,000h,0feh,0ffh,021h,01bh,00dh,01eh,00dh	; 7d2c  .&.*.%$....!....
	defb 01ch,00dh,01fh,00dh,01dh,00dh,01ah,00dh,01bh,00dh,017h,00fh,01ch,00fh,019h,00eh	; 7d3c  ................
	defb 022h,014h,00dh,015h,00ch,00bh,00ah,009h,008h,0ffh,024h,0b1h,01dh,0b0h,0d5h,0b0h	; 7d4c  ".........$.....
	defb 0a9h,0c0h,08eh,0feh,002h,024h,0c0h,0f6h,0b1h,006h,0b1h,016h,022h,0a1h,036h,091h	; 7d5c  .....$......".6.
	defb 046h,081h,066h,071h,086h,061h,0b6h,051h,0aeh,024h,000h,000h,0ffh,024h,0c0h,0f0h	; 7d6c  F.fq.a.Q.$...$..
	defb 0b1h,000h,0b1h,010h,022h,0a1h,030h,091h,040h,081h,060h,071h,080h,061h,0b0h,051h	; 7d7c  ....".0.@.`q.a.Q
	defb 0a8h,024h,000h,000h,0ffh,022h,0c2h,005h,0c2h,00eh,0c3h,022h,0c2h,0cch,0c2h,0fbh	; 7d8c  .$..."....."....
	defb 0ffh,0d5h,0fch,0e2h,001h,052h,050h,051h,001h,052h,050h,051h,001h,051h,091h,071h	; 7d9c  .....RPQ.RPQ.Q.q
	defb 051h,0e1h,005h,001h,022h,0e2h,0a0h,0a1h,0e1h,021h,002h,0e2h,090h,091h,091h,0a2h	; 7dac  Q..."....!......
	defb 040h,041h,041h,0e1h,005h,001h,022h,0e2h,0a0h,0a1h,0e1h,021h,002h,0e2h,090h,091h	; 7dbc  @AA..."....!....
	defb 091h,0a2h,040h,041h,041h,053h,0c1h,0feh,0ffh,0d5h,0fdh,0e3h,0c1h,001h,091h,051h	; 7dcc  ..@AAS.........Q
	defb 091h,001h,091h,051h,091h,001h,091h,051h,091h,001h,091h,051h,091h,021h,0a1h,051h	; 7ddc  ...Q...Q...Q.!.Q
	defb 0a1h,001h,091h,051h,091h,001h,071h,041h,071h,0c1h,051h,091h,0e2h,001h,0e3h,021h	; 7dec  ...Q..qAq.Q....!
	defb 0a1h,051h,0a1h,001h,091h,051h,091h,001h,071h,041h,071h,0e2h,001h,0e3h,051h,091h	; 7dfc  .Q...Q..qAq...Q.
	defb 0c1h,0ffh,0d5h,0fdh,0e1h,040h,000h,0e2h,071h,0e1h,040h,000h,0e2h,071h,0b1h,0e1h	; 7e0c  .....@..q.@..q..
	defb 021h,023h,020h,0e2h,0b0h,071h,0e1h,020h,0e2h,0b0h,071h,0e1h,001h,041h,043h,040h	; 7e1c  !# ..q. ..q..AC@
	defb 000h,0e2h,071h,0e1h,040h,000h,0e2h,071h,0b1h,0e1h,021h,023h,020h,0e2h,0b0h,071h	; 7e2c  ..q.@..q..!# ..q
	defb 0e1h,020h,0e2h,0b0h,071h,0e1h,001h,041h,003h,0ffh,0d5h,0fdh,0e2h,001h,071h,001h	; 7e3c  . ..q..A......q.
	defb 071h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h	; 7e4c  q.q.Q.q.Q.q.Q.q.
	defb 051h,001h,071h,001h,071h,001h,071h,001h,071h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h	; 7e5c  Q.q.q.q.q.q.Q.q.
	defb 051h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h,051h,001h,001h,003h,0ffh,0dfh,0fch,0e2h	; 7e6c  Q.q.Q.q.Q.......
	defb 0cfh,0d5h,0c7h,041h,041h,043h,0ffh,0d5h,0fdh,0e1h,021h,021h,021h,021h,021h,0e2h	; 7e7c  ...AAC....!!!!!.
	defb 0b1h,091h,071h,041h,071h,071h,071h,091h,071h,061h,041h,021h,0b3h,0b1h,021h,093h	; 7e8c  ..qAqqq.qaA!..!.
	defb 091h,079h,0ffh,0d5h,0fch,0e3h,0c1h,0b1h,0b1h,0b1h,0c1h,0b1h,0b1h,0b1h,0c1h,0b1h	; 7e9c  .y..............
	defb 0b1h,0b1h,0c1h,0b1h,0b1h,0b1h,0c1h,0b1h,0b1h,0b1h,0e2h,0c1h,001h,001h,001h,0c9h	; 7eac  ................
	defb 0ffh,0d5h,0fbh,0e3h,021h,071h,071h,071h,021h,071h,071h,071h,041h,071h,071h,071h	; 7ebc  ....!qqq!qqqAqqq
	defb 041h,071h,071h,071h,021h,071h,071h,071h,021h,061h,061h,061h,071h,021h,0b1h,091h	; 7ecc  Aqqq!qqq!aaaq!..
	defb 071h,0ffh,0d7h,0fdh,0e1h,000h,020h,040h,050h,071h,071h,090h,0b0h,0e0h,000h,0e1h	; 7edc  q..... @Pqq.....
	defb 090h,071h,0c1h,050h,090h,070h,050h,040h,070h,050h,040h,020h,050h,040h,020h,001h	; 7eec  .q.P.pP@pP@ P@ .
	defb 0c1h,0feh,002h,0d7h,0fch,0e2h,001h,041h,001h,041h,001h,051h,001h,041h,0e3h,0b1h	; 7efc  .......A.A.Q.A..
	defb 0e2h,021h,001h,041h,0e3h,071h,0e2h,051h,001h,041h,0ffh,0d3h,0fdh,0e2h,073h,071h	; 7f0c  .!.A.q.Q.A....sq
	defb 073h,0b1h,0e1h,023h,0e2h,0b1h,073h,071h,093h,091h,021h,041h,061h,07bh,0ffh,0d3h	; 7f1c  s..#..sq..!Aa{..
	defb 0fdh,0e4h,073h,0e3h,021h,0b3h,021h,0e4h,073h,0e3h,021h,0b3h,0c1h,073h,0c1h,063h	; 7f2c  ..s.!.!.s.!..s.c
	defb 0e2h,001h,0e3h,0b3h,0c1h,0b5h,0ffh,0d3h,0fdh,0e3h,0cfh,0c7h,003h,0c1h,025h,073h	; 7f3c  ..............%s
	defb 0c1h,075h	; 7f4c

; ----------------------------------------------------------------------
; DATOS relleno_final: 178 bytes de 0xFF hasta el final del cartucho
;   0x7f4e..0x8000  (178 bytes)
DATA_relleno_final:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f4e  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f5e  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f6e  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f7e  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f8e  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7f9e  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fae  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fbe  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fce  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fde  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 7fee  ................
	defb 0ffh,0ffh	; 7ffe
