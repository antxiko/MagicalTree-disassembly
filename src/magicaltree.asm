; ==========================================================================
; MAGICAL TREE - Konami - MSX1 - cartucho RC-713 de 16 KB en la pagina 1
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; DATOS sin identificar  0x4000..0x4010  (16 bytes)
DATA_4000:
	defb 041h,042h,077h,040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 4000  ABw@............

; ======================================================================
; CODIGO 0x4010..0x405e  (78 bytes)
; ======================================================================


L_4010:
	call L_44BE		;4010
	exx			;4013
	out (c),a		;4014
	exx			;4016
	ei			;4017
	ret			;4018
L_4019:
	call L_44CD		;4019
	exx			;401c
	in a,(c)		;401d
	exx			;401f
	ei			;4020
	ret			;4021
L_4022:
	add a,l			;4022
	ld l,a			;4023
	ret nc			;4024
	inc h			;4025
	ret			;4026
L_4027:
	add a,e			;4027
	ld e,a			;4028
	ret nc			;4029
	inc d			;402a
	ret			;402b
L_402C:
	di			;402c
	call 0013eh		;402d   ; BIOS RDVDP - Reads VDP status register
	call L_7AC0		;4030
	ld hl,0e005h		;4033
	bit 0,(hl)		;4036
	jr nz,L_4047		;4038
	inc (hl)			;403a
	ei			;403b
	call L_4522		;403c
	call L_40A7		;403f
	di			;4042
	xor a			;4043
	ld (0e005h),a		;4044
L_4047:
	ei			;4047
	reti		;4048
L_404A:
	add a,a			;404a
	pop hl			;404b
	call L_4022		;404c
	ld e,(hl)			;404f
	inc hl			;4050
	ld d,(hl)			;4051
	ex de,hl			;4052
	jp (hl)			;4053
L_4054:
	ld c,(hl)			;4054
	ld a,(de)			;4055
	ld (hl),a			;4056
	ld a,c			;4057
	ld (de),a			;4058
	inc hl			;4059
	inc de			;405a
	djnz L_4054		;405b
	ret			;405d

; ----------------------------------------------------------------------
; DATOS sin identificar  0x405e..0x4062  (4 bytes)
DATA_405E:
	defb 00eh,000h,018h,002h	; 405e

; ======================================================================
; CODIGO 0x4062..0x40c3  (97 bytes)
; ======================================================================


L_4062:
	ld c,0ffh		;4062
L_4064:
	ld e,(hl)			;4064
	inc hl			;4065
	ld d,(hl)			;4066
	inc hl			;4067
L_4068:
	ld a,(hl)			;4068
	inc hl			;4069
	ld b,a			;406a
	inc b			;406b
	ret z			;406c
	inc b			;406d
	jr z,L_4064		;406e
	and c			;4070
	call L_4010		;4071
	inc de			;4074
	jr L_4068		;4075
L_4077:
	di			;4077
	im 1		;4078
	ld a,0c3h		;407a
	ld (0fd9ah),a		;407c
	ld hl,0402ch		;407f
	ld (0fd9bh),hl		;4082
	ld sp,0e400h		;4085
	ld hl,0e000h		;4088
	ld de,0e001h		;408b
	ld bc,003ffh		;408e
	ld (hl),000h		;4091
	ldir		;4093
	ld a,001h		;4095
	ld (0e005h),a		;4097
	call L_44DA		;409a
	xor a			;409d
	ld (0e005h),a		;409e
	call 0013eh		;40a1   ; BIOS RDVDP - Reads VDP status register
	ei			;40a4
L_40A5:
	jr L_40A5		;40a5
L_40A7:
	ld hl,0e003h		;40a7
	inc (hl)			;40aa
	ld a,(0e002h)		;40ab
	and 040h		;40ae
	ld hl,043aah		;40b0
	jr nz,L_40B8		;40b3
	ld hl,04557h		;40b5
L_40B8:
	ld a,(0e000h)		;40b8
	cp 008h		;40bb
	jr z,L_40C0		;40bd
	push hl			;40bf
L_40C0:
	call L_404A		;40c0

; ----------------------------------------------------------------------
; DATOS sin identificar  0x40c3..0x40e3  (32 bytes)
DATA_40C3:
	defb 0e3h,040h,0f0h,040h,002h,041h,014h,041h,016h,041h,01dh,041h,026h,041h,02fh,041h	; 40c3  .@.@.A.A.A.A&A/A
	defb 00eh,042h,03bh,041h,05eh,041h,084h,041h,095h,041h,0cfh,041h,0e3h,041h,003h,042h	; 40d3  .B;A^A.A.A.A.A.B

; ======================================================================
; CODIGO 0x40e3..0x4247  (356 bytes)
; ======================================================================


L_40E3:
	call L_42B3		;40e3
	ret p			;40e6
	call L_4257		;40e7
	call L_44EE		;40ea
	jp L_417F		;40ed
L_40F0:
	ld a,(0e003h)		;40f0
	rra			;40f3
	ret nc			;40f4
	call L_48BE		;40f5
	ret nz			;40f8
	ld hl,047bch		;40f9
	call L_4062		;40fc
	xor a			;40ff
	jr L_417C		;4100
L_4102:
	ld hl,0e004h		;4102
	dec (hl)			;4105
	ret nz			;4106
	ld de,03880h		;4107
	ld bc,00100h		;410a
	xor a			;410d
	ld (0e00ah),a		;410e
	call L_442C		;4111
L_4114:
	jr L_417F		;4114
L_4116:
	call L_43E7		;4116
	ret c			;4119
	xor a			;411a
	jr L_417C		;411b
L_411D:
	ld hl,0e004h		;411d
	dec (hl)			;4120
	jp nz,L_4282		;4121
	jr L_417A		;4124
L_4126:
	call L_42B3		;4126
	ret p			;4129
	call L_53C2		;412a
	jr L_417A		;412d
L_412F:
	call L_53DE		;412f
	ld a,(0e00ch)		;4132
	or a			;4135
	ret z			;4136
L_4137:
	xor a			;4137
	jp L_41FA		;4138
L_413B:
	ld a,(0e00dh)		;413b
	or a			;413e
	jr nz,L_415C		;413f
	call L_42B3		;4141
	ret p			;4144
	ld hl,0e050h		;4145
	dec (hl)			;4148
	call L_4343		;4149
	ld a,(0e002h)		;414c
	and 020h		;414f
	jr z,L_4159		;4151
	ld hl,047b1h		;4153
	call L_42A4		;4156
L_4159:
	call L_51D2		;4159
L_415C:
	jr L_417F		;415c
L_415E:
	ld a,(0e012h)		;415e
	or a			;4161
	ret nz			;4162
	ld a,(0e05eh)		;4163
	rra			;4166
	ld a,009h		;4167
	jr c,L_416D		;4169
	ld a,08ch		;416b
L_416D:
	call L_7A13		;416d
	xor a			;4170
	ld (0e001h),a		;4171
	ld hl,00000h		;4174
	ld (0e00ch),hl		;4177
L_417A:
	ld a,020h		;417a
L_417C:
	ld (0e004h),a		;417c
L_417F:
	ld hl,0e000h		;417f
	inc (hl)			;4182
	ret			;4183
L_4184:
	call L_51DE		;4184
	ld hl,0e00ch		;4187
	ld a,(hl)			;418a
	or a			;418b
	jr nz,L_417A		;418c
	inc hl			;418e
	or (hl)			;418f
	ret z			;4190
	ld a,00fh		;4191
	jr L_41FA		;4193
L_4195:
	ld a,(0e050h)		;4195
	or a			;4198
	jr nz,L_41C5		;4199
	ld a,(0e012h)		;419b
	or a			;419e
	ret nz			;419f
	ld a,093h		;41a0
	call L_7A13		;41a2
	ld hl,047a4h		;41a5
	call L_42A4		;41a8
	ld hl,04247h		;41ab
	call L_4062		;41ae
	ld hl,0e1bdh		;41b1
	ld de,039f1h		;41b4
	call L_66E2		;41b7
	call L_4343		;41ba
	ld a,00dh		;41bd
	ld (0e000h),a		;41bf
	xor a			;41c2
	jr L_417C		;41c3
L_41C5:
	ld a,(0e080h)		;41c5
	or a			;41c8
	jr nz,L_417F		;41c9
L_41CB:
	ld a,009h		;41cb
	jr L_41FA		;41cd
L_41CF:
	ld hl,0e050h		;41cf
	ld de,0e080h		;41d2
	ld b,020h		;41d5
	call L_4054		;41d7
	ld hl,0e002h		;41da
	ld a,(hl)			;41dd
	xor 080h		;41de
	ld (hl),a			;41e0
	jr L_41CB		;41e1
L_41E3:
	ld hl,0e004h		;41e3
	dec (hl)			;41e6
	ret nz			;41e7
	ld a,(0e080h)		;41e8
	or a			;41eb
	jr nz,L_41F8		;41ec
	ld hl,0e002h		;41ee
	ld a,(hl)			;41f1
	and 0bfh		;41f2
	ld (hl),a			;41f4
	jp L_4137		;41f5
L_41F8:
	ld a,00dh		;41f8
L_41FA:
	ld (0e000h),a		;41fa
	ld a,020h		;41fd
	ld (0e004h),a		;41ff
	ret			;4202
L_4203:
	ld hl,0e004h		;4203
	dec (hl)			;4206
	ret nz			;4207
	ld a,009h		;4208
	ld (0e000h),a		;420a
	ret			;420d
L_420E:
	ld a,(0e001h)		;420e
	or a			;4211
	jr nz,L_422C		;4212
	ld a,096h		;4214
	call L_7A13		;4216
	ld a,050h		;4219
	ld (0e004h),a		;421b
	call L_4422		;421e
	call L_425D		;4221
	call L_43DC		;4224
	ld hl,0e001h		;4227
	inc (hl)			;422a
	ret			;422b
L_422C:
	ld hl,0e004h		;422c
	dec (hl)			;422f
	jr z,L_4241		;4230
	bit 3,(hl)		;4232
	jp nz,L_43DC		;4234
	call L_4299		;4237
	ld bc,0001bh		;423a
	xor a			;423d
	jp L_442C		;423e
L_4241:
	call L_518E		;4241
	jp L_417A		;4244

; ----------------------------------------------------------------------
; DATOS sin identificar  0x4247..0x4257  (16 bytes)
DATA_4247:
	defb 0e9h,039h,03bh,048h,045h,049h,047h,048h,054h,040h,0feh,0f5h,039h,018h,03bh,0ffh	; 4247  .9;HEIGHT@..9.;.

; ======================================================================
; CODIGO 0x4257..0x43aa  (339 bytes)
; ======================================================================


L_4257:
	call L_489F		;4257
	call L_447E		;425a
L_425D:
	ld a,070h		;425d
	ld de,01600h		;425f
	call L_4488		;4262
	ld hl,047d2h		;4265
	call L_449B		;4268
	ld de,00600h		;426b
	ld b,010h		;426e
L_4270:
	push bc			;4270
	push de			;4271
	ld hl,04894h		;4272
	call L_449F		;4275
	pop hl			;4278
	ld bc,00010h		;4279
	add hl,bc			;427c
	ex de,hl			;427d
	pop bc			;427e
	djnz L_4270		;427f
	ret			;4281
L_4282:
	ld bc,03e3fh		;4282
	bit 3,(hl)		;4285
	jr nz,L_428C		;4287
	ld bc,00000h		;4289
L_428C:
	call L_4299		;428c
	ld a,b			;428f
	call L_4010		;4290
	ld a,c			;4293
	inc de			;4294
	call L_4010		;4295
	ret			;4298
L_4299:
	ld a,(0e042h)		;4299
	add a,014h		;429c
	rrca			;429e
	rrca			;429f
	ld e,a			;42a0
	ld d,07ah		;42a1
	ret			;42a3
L_42A4:
	call L_4062		;42a4
	ld a,(0e002h)		;42a7
	or a			;42aa
	ret p			;42ab
	ld a,032h		;42ac
	dec de			;42ae
	call L_4010		;42af
	ret			;42b2
L_42B3:
	ld hl,0e003h		;42b3
	dec (hl)			;42b6
	inc hl			;42b7
	ld b,018h		;42b8
	dec (hl)			;42ba
	ret m			;42bb
	ld a,(hl)			;42bc
	srl a		;42bd
	jr c,L_42C3		;42bf
	xor 01fh		;42c1
L_42C3:
	ld e,a			;42c3
	ld d,038h		;42c4
L_42C6:
	xor a			;42c6
	call L_4010		;42c7
	ld a,020h		;42ca
	call L_4027		;42cc
	djnz L_42C6		;42cf
L_42D1:
	ld de,03b00h		;42d1
	ld a,0d0h		;42d4
	call L_4010		;42d6
	xor a			;42d9
	ret			;42da
L_42DB:
	ld a,(0e002h)		;42db
	add a,a			;42de
	ret p			;42df
	ld hl,0e049h		;42e0
	jr nc,L_42E7		;42e3
	ld l,046h		;42e5
L_42E7:
	ld a,(hl)			;42e7
	add a,e			;42e8
	daa			;42e9
	ld (hl),a			;42ea
	ld e,a			;42eb
	inc l			;42ec
	ld a,(hl)			;42ed
	adc a,d			;42ee
	daa			;42ef
	ld (hl),a			;42f0
	ld d,a			;42f1
	inc hl			;42f2
	jr nc,L_4329		;42f3
	ld a,(hl)			;42f5
	add a,001h		;42f6
	daa			;42f8
	ld (hl),a			;42f9
	jr nc,L_4309		;42fa
	ld bc,09999h		;42fc
	ld (0e043h),bc		;42ff
	ld (0e044h),bc		;4303
	jr L_4367		;4307
L_4309:
	ld a,(0e052h)		;4309
	cp (hl)			;430c
	jr nc,L_4329		;430d
	push de			;430f
	push hl			;4310
	add a,002h		;4311
	daa			;4313
	jr nc,L_4318		;4314
	ld a,0ffh		;4316
L_4318:
	ld (0e052h),a		;4318
	ld hl,0e050h		;431b
	inc (hl)			;431e
	call L_43C4		;431f
	ld a,008h		;4322
	call L_7A13		;4324
	pop hl			;4327
	pop de			;4328
L_4329:
	ld a,(0e045h)		;4329
	ld b,(hl)			;432c
	sub b			;432d
	jr c,L_4339		;432e
	jr nz,L_4370		;4330
	ld hl,(0e043h)		;4332
	sbc hl,de		;4335
	jr nc,L_4370		;4337
L_4339:
	ld (0e043h),de		;4339
	ld a,b			;433d
	ld (0e045h),a		;433e
	jr L_4367		;4341
L_4343:
	ld hl,04710h		;4343
	call L_4062		;4346
	ld a,(0e002h)		;4349
	bit 5,a		;434c
	jr z,L_435E		;434e
	ld hl,04725h		;4350
	call L_4062		;4353
	ld a,(0e002h)		;4356
	xor 080h		;4359
	call L_4373		;435b
L_435E:
	call L_43C4		;435e
	call L_66BC		;4361
	call L_4385		;4364
L_4367:
	ld hl,0e045h		;4367
	ld de,0380fh		;436a
	call L_4381		;436d
L_4370:
	ld a,(0e002h)		;4370
L_4373:
	ld de,03805h		;4373
	ld hl,0e04bh		;4376
	add a,a			;4379
	jr nc,L_4381		;437a
	ld e,025h		;437c
	ld hl,0e048h		;437e
L_4381:
	ld b,003h		;4381
	jr L_438D		;4383
L_4385:
	ld de,0381ch		;4385
	ld hl,0e051h		;4388
	ld b,001h		;438b
L_438D:
	ld a,(hl)			;438d
	push af			;438e
	and 00fh		;438f
	or 030h		;4391
	ld c,a			;4393
	pop af			;4394
	and 0f0h		;4395
	rra			;4397
	rra			;4398
	rra			;4399
	rra			;439a
	or 030h		;439b
	call L_4010		;439d
	inc de			;43a0
	ld a,c			;43a1
	call L_4010		;43a2
	dec hl			;43a5
	inc de			;43a6
	djnz L_438D		;43a7
	ret			;43a9

; ----------------------------------------------------------------------
; DATOS sin identificar  0x43aa..0x43c4  (26 bytes)
DATA_43AA:
	defb 02ah,002h,0e0h,03eh,01fh,0a4h,0c0h,04fh,0cbh,06ch,028h,001h,00dh,0cbh,07dh,021h	; 43aa  *..>...O.l(...}!
	defb 01fh,047h,028h,003h,021h,025h,047h,0c3h,064h,040h	; 43ba  .G(.!%G.d@

; ======================================================================
; CODIGO 0x43c4..0x44ff  (315 bytes)
; ======================================================================


L_43C4:
	ld de,0383dh		;43c4
	ld a,(0e050h)		;43c7
	ld c,a			;43ca
	ld b,005h		;43cb
	ld a,02eh		;43cd
L_43CF:
	dec c			;43cf
	jp p,L_43D5		;43d0
	ld a,000h		;43d3
L_43D5:
	call L_4010		;43d5
	dec de			;43d8
	djnz L_43CF		;43d9
	ret			;43db
L_43DC:
	ld a,000h		;43dc
	ld (0e00ah),a		;43de
L_43E1:
	call L_43E7		;43e1
	jr c,L_43E1		;43e4
	ret			;43e6
L_43E7:
	ld hl,0e00ah		;43e7
	ld a,(hl)			;43ea
	inc (hl)			;43eb
	cp 00fh		;43ec
	jr nc,L_4417		;43ee
	ld de,03889h		;43f0
	ld c,a			;43f3
	add a,e			;43f4
	ld e,a			;43f5
	ld a,c			;43f6
	add a,a			;43f7
	add a,0c0h		;43f8
	ld c,a			;43fa
	ld b,002h		;43fb
L_43FD:
	ld a,c			;43fd
	call L_4010		;43fe
	ld a,020h		;4401
	call L_4027		;4403
	inc c			;4406
	djnz L_43FD		;4407
	ld a,e			;4409
	sub 0cch		;440a
	cp 002h		;440c
	jr nc,L_4415		;440e
	add a,0deh		;4410
	call L_4010		;4412
L_4415:
	scf			;4415
	ret			;4416
L_4417:
	push af			;4417
	ld hl,0472bh		;4418
	call z,L_4062		;441b
	pop af			;441e
	cp 034h		;441f
	ret			;4421
L_4422:
	call L_42D1		;4422
	ld de,07800h		;4425
	ld bc,00300h		;4428
	xor a			;442b
L_442C:
	call L_44BE		;442c
L_442F:
	ex af,af'			;442f
L_4430:
	ex af,af'			;4430
	exx			;4431
	out (c),a		;4432
	exx			;4434
	ex af,af'			;4435
	dec bc			;4436
	ld a,b			;4437
	or c			;4438
	jr nz,L_4430		;4439
	ei			;443b
	ret			;443c
L_443D:
	ld a,(hl)			;443d
	inc hl			;443e
	jr L_442F		;443f
L_4441:
	di			;4441
	call L_44BE		;4442
L_4445:
	ld a,(hl)			;4445
	exx			;4446
	out (c),a		;4447
	exx			;4449
	inc hl			;444a
	dec bc			;444b
	ld a,b			;444c
	or c			;444d
	jr nz,L_4445		;444e
	ei			;4450
	ret			;4451
L_4452:
	call L_4019		;4452
	ex de,hl			;4455
	call L_4010		;4456
	ex de,hl			;4459
	inc hl			;445a
	inc de			;445b
	dec bc			;445c
	ld a,c			;445d
	or b			;445e
	jr nz,L_4452		;445f
	ret			;4461
L_4462:
	ld de,02000h		;4462
	ld hl,02800h		;4465
L_4468:
	ld bc,00800h		;4468
	call L_4452		;446b
	ld bc,00800h		;446e
	jr L_4452		;4471
L_4473:
	call L_4462		;4473
L_4476:
	ld de,00000h		;4476
	ld hl,00800h		;4479
	jr L_4468		;447c
L_447E:
	ld a,0f0h		;447e
	ld de,00180h		;4480
	call L_4488		;4483
	jr L_4473		;4486
L_4488:
	ld bc,00180h		;4488
	call L_442C		;448b
	ld hl,045b8h		;448e
	ld a,020h		;4491
	add a,d			;4493
	ld d,a			;4494
	ld bc,00180h		;4495
	jp L_4441		;4498
L_449B:
	ld e,(hl)			;449b
	inc hl			;449c
	ld d,(hl)			;449d
	inc hl			;449e
L_449F:
	di			;449f
	call L_44BE		;44a0
L_44A3:
	ld a,(hl)			;44a3
	and 07fh		;44a4
	ld c,a			;44a6
	ld a,(hl)			;44a7
	inc hl			;44a8
	jr nz,L_44B0		;44a9
	cp c			;44ab
	jr nz,L_449B		;44ac
	ei			;44ae
	ret			;44af
L_44B0:
	ld b,000h		;44b0
	cp c			;44b2
	push af			;44b3
	call nz,L_4445		;44b4
	pop af			;44b7
	call z,L_443D		;44b8
	di			;44bb
	jr L_44A3		;44bc
L_44BE:
	ex af,af'			;44be
	ex de,hl			;44bf
	call 00053h		;44c0   ; BIOS SETWRT - Enables VDP to write
	di			;44c3
	ex de,hl			;44c4
	exx			;44c5
	ld a,(00006h)		;44c6
	ld c,a			;44c9
	exx			;44ca
	ex af,af'			;44cb
	ret			;44cc
L_44CD:
	ex de,hl			;44cd
	call 00050h		;44ce   ; BIOS SETRD - Enables VDP to read
	di			;44d1
	ex de,hl			;44d2
	exx			;44d3
	ld a,(00007h)		;44d4
	ld c,a			;44d7
	exx			;44d8
	ret			;44d9
L_44DA:
	ld a,0b8h		;44da
	call L_7AB7		;44dc
	ld a,09fh		;44df
	call L_7A13		;44e1
	ld de,00000h		;44e4
	ld bc,04000h		;44e7
	xor a			;44ea
	call L_442C		;44eb
L_44EE:
	ld hl,044ffh		;44ee
	ld d,008h		;44f1
	ld c,000h		;44f3
L_44F5:
	ld b,(hl)			;44f5
	call 00047h		;44f6   ; BIOS WRTVDP - Writes data in the VDP-register
	inc hl			;44f9
	inc c			;44fa
	dec d			;44fb
	jr nz,L_44F5		;44fc
	ret			;44fe

; ----------------------------------------------------------------------
; DATOS sin identificar  0x44ff..0x4507  (8 bytes)
DATA_44FF:
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e1h	; 44ff  .....v..

; ======================================================================
; CODIGO 0x4507..0x4557  (80 bytes)
; ======================================================================


L_4507:
	ld e,08fh		;4507
	ld hl,0e002h		;4509
	bit 7,(hl)		;450c
	jr z,L_4512		;450e
	set 6,e		;4510
L_4512:
	ld a,00fh		;4512
	call 00093h		;4514   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00eh		;4517
	di			;4519
	call 00096h		;451a   ; BIOS RDPSG - Reads value from PSG-register
	ei			;451d
	cpl			;451e
	and 03fh		;451f
	ret			;4521
L_4522:
	call L_4507		;4522
	bit 4,(hl)		;4525
	call nz,L_4532		;4527
	ld hl,0e009h		;452a
	ld c,(hl)			;452d
	ld (hl),a			;452e
	dec hl			;452f
	ld (hl),c			;4530
	ret			;4531
L_4532:
	ld a,007h		;4532
	call 00141h		;4534   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4537
	rrca			;4538
	and 020h		;4539
	ld e,a			;453b
	ld a,008h		;453c
	call 00141h		;453e   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;4541
	rrca			;4542
	rrca			;4543
	ld b,a			;4544
	and 004h		;4545
	or e			;4547
	ld c,a			;4548
	ld a,b			;4549
	rrca			;454a
	rrca			;454b
	ld b,a			;454c
	and 018h		;454d
	or c			;454f
	ld c,a			;4550
	ld a,b			;4551
	rrca			;4552
	and 003h		;4553
	or c			;4555
	ret			;4556

; ----------------------------------------------------------------------
; DATOS sin identificar  0x4557..0x489f  (840 bytes)
DATA_4557:
	defb 01eh,08fh,0cdh,012h,045h,057h,01eh,0cfh,0cdh,012h,045h,0b2h,057h,0cdh,032h,045h	; 4557  ....EW....E.W.2E
	defb 0b2h,021h,040h,0e0h,04eh,077h,023h,071h,047h,0a9h,0a0h,0c8h,047h,03eh,000h,032h	; 4567  .!@.Nw#qG...G>.2
	defb 004h,0e0h,03eh,005h,021h,000h,0e0h,0beh,020h,019h,078h,0feh,010h,038h,018h,021h	; 4577  ..>.!... .x..8.!
	defb 0b4h,045h,03ah,042h,0e0h,0cdh,022h,040h,07eh,032h,002h,0e0h,021h,008h,000h,022h	; 4587  .E:B.."@~2..!.."
	defb 000h,0e0h,0c9h,077h,0c3h,01eh,042h,0c5h,0cdh,089h,042h,0f1h,021h,042h,0e0h,046h	; 4597  ...w..B...B.!B.F
	defb 01fh,030h,001h,005h,01fh,030h,001h,004h,078h,0e6h,003h,077h,0c9h,040h,060h,050h	; 45a7  .0...0..x..w.@`P
	defb 070h,000h,01ch,022h,063h,063h,063h,022h,01ch,000h,018h,038h,018h,018h,018h,018h	; 45b7  p.."ccc"...8....
	defb 07eh,000h,03eh,063h,003h,00eh,03ch,070h,07fh,000h,03eh,063h,003h,00eh,003h,063h	; 45c7  ~.>c..<p..>c...c
	defb 03eh,000h,00eh,01eh,036h,066h,066h,07fh,006h,000h,07fh,060h,07eh,063h,003h,063h	; 45d7  >...6ff....`~c.c
	defb 03eh,000h,03eh,063h,060h,07eh,063h,063h,03eh,000h,07fh,063h,006h,00ch,018h,018h	; 45e7  >.>c`~cc>..c....
	defb 018h,000h,03eh,063h,063h,03eh,063h,063h,03eh,000h,03eh,063h,063h,03fh,003h,063h	; 45f7  ..>cc>cc>.>cc?.c
	defb 03eh,03ch,042h,099h,0a1h,0a1h,099h,042h,03ch,000h,024h,024h,024h,000h,000h,000h	; 4607  ><B....B<.$$$...
	defb 000h,000h,000h,002h,000h,08ah,0aah,0aah,0dah,000h,000h,008h,048h,0eeh,04ah,04ah	; 4617  ............H.JJ
	defb 06ah,000h,00fh,01fh,0ffh,0ffh,0ffh,0ffh,00fh,000h,000h,0feh,0e0h,0e0h,0c0h,0c0h	; 4627  j...............
	defb 080h,000h,000h,000h,000h,07eh,000h,000h,000h,000h,01ch,036h,063h,063h,07fh,063h	; 4637  .....~.....6cc.c
	defb 063h,000h,07eh,063h,063h,07eh,063h,063h,07eh,000h,03eh,063h,060h,060h,060h,063h	; 4647  c.~cc~cc~.>c```c
	defb 03eh,000h,07ch,066h,063h,063h,063h,066h,07ch,000h,07fh,060h,060h,07eh,060h,060h	; 4657  >.|fcccf|..``~``
	defb 07fh,000h,07fh,060h,060h,07eh,060h,060h,060h,000h,03eh,063h,060h,067h,063h,063h	; 4667  ...``~```.>c`gcc
	defb 03fh,000h,063h,063h,063h,07fh,063h,063h,063h,000h,03ch,018h,018h,018h,018h,018h	; 4677  ?.ccc.ccc.<.....
	defb 03ch,000h,01fh,006h,006h,006h,006h,066h,03ch,000h,063h,066h,06ch,078h,07ch,06eh	; 4687  <......f<.cflx|n
	defb 067h,000h,060h,060h,060h,060h,060h,060h,07fh,000h,063h,077h,07fh,07fh,06bh,063h	; 4697  g.``````..cw..kc
	defb 063h,000h,063h,073h,07bh,07fh,06fh,067h,063h,000h,03eh,063h,063h,063h,063h,063h	; 46a7  c.cs{.ogc.>ccccc
	defb 03eh,000h,07eh,063h,063h,063h,07eh,060h,060h,000h,03eh,063h,063h,063h,06fh,066h	; 46b7  >.~ccc~``.>cccof
	defb 03dh,000h,07eh,063h,063h,062h,07ch,066h,063h,000h,03eh,063h,060h,03eh,003h,063h	; 46c7  =.~ccb|fc.>c`>.c
	defb 03eh,000h,07eh,018h,018h,018h,018h,018h,018h,000h,063h,063h,063h,063h,063h,063h	; 46d7  >.~.......cccccc
	defb 03eh,000h,063h,063h,063h,063h,036h,01ch,008h,000h,063h,063h,06bh,06bh,07fh,077h	; 46e7  >.cccc6...cckk.w
	defb 022h,000h,063h,076h,03ch,01ch,01eh,037h,063h,000h,066h,066h,07eh,03ch,018h,018h	; 46f7  ".cv<..7c.ff~<..
	defb 018h,000h,07fh,007h,00eh,01ch,038h,070h,07fh,00ch,038h,048h,049h,040h,0feh,016h	; 4707  ......8p..8HI@..
	defb 038h,053h,054h,041h,047h,045h,040h,0feh,002h,038h,031h,050h,040h,0ffh,022h,038h	; 4717  8STAGE@..81P@."8
	defb 032h,050h,040h,0ffh,0abh,039h,050h,04ch,041h,059h,000h,053h,045h,04ch,045h,043h	; 4727  2P@..9PLAY.SELEC
	defb 054h,0feh,007h,03ah,0c1h,0e0h,0dch,0d1h,0e9h,0d5h,0e2h,000h,000h,0cch,0cdh,000h	; 4737  T..:............
	defb 0dah,0dfh,0e9h,0e3h,0e4h,0d9h,0d3h,0dbh,0feh,047h,03ah,0c2h,0e0h,0dch,0d1h,0e9h	; 4747  .........G:.....
	defb 0d5h,0e2h,0e3h,000h,0cch,0cdh,000h,0dah,0dfh,0e9h,0e3h,0e4h,0d9h,0d3h,0dbh,0feh	; 4757  ................
	defb 087h,03ah,0c1h,0e0h,0dch,0d1h,0e9h,0d5h,0e2h,000h,000h,0cch,0cdh,000h,0dbh,0d5h	; 4767  .:..............
	defb 0e9h,0d2h,0dfh,0d1h,0e2h,0d4h,0feh,0c7h,03ah,0c2h,0e0h,0dch,0d1h,0e9h,0d5h,0e2h	; 4777  ........:.......
	defb 0e3h,000h,0cch,0cdh,000h,0dbh,0d5h,0e9h,0d2h,0dfh,0d1h,0e2h,0d4h,0feh,00bh,039h	; 4787  ...............9
	defb 03ah,04bh,04fh,04eh,041h,04dh,049h,000h,031h,039h,038h,034h,0ffh,06bh,039h,047h	; 4797  :KONAMI.1984.k9G
	defb 041h,04dh,045h,000h,000h,04fh,056h,045h,052h,0feh,02ch,039h,050h,04ch,041h,059h	; 47a7  AME..OVER.,9PLAY
	defb 045h,052h,000h,031h,0ffh,066h,039h,040h,000h,056h,049h,044h,045h,04fh,000h,043h	; 47b7  ER.1.f9@.VIDEO.C
	defb 041h,052h,054h,052h,049h,044h,047h,045h,000h,040h,0ffh,000h,026h,083h,078h,07ch	; 47c7  ARTRIDGE.@..&.x|
	defb 07eh,003h,07fh,082h,07bh,079h,008h,078h,089h,00fh,01fh,03fh,07fh,0ffh,0ffh,0efh	; 47d7  ~...{y.x...?....
	defb 0cfh,08fh,007h,00fh,005h,000h,08bh,03fh,03fh,007h,001h,03fh,07fh,071h,071h,07fh	; 47e7  .......??..?.qq.
	defb 07fh,03dh,005h,000h,0a3h,081h,0c3h,0c7h,0c7h,0c7h,0c3h,0c1h,0c3h,0c1h,0c7h,0efh	; 47f7  .=..............
	defb 000h,000h,000h,00eh,01eh,0feh,0f8h,0bch,01ch,0bch,0f8h,0f0h,080h,0f0h,0fch,01eh	; 4807  ................
	defb 040h,0e0h,0e0h,040h,000h,0e3h,0e7h,0e7h,004h,0eeh,084h,0e7h,0e7h,0e3h,0e0h,004h	; 4817  @..@............
	defb 000h,08ch,0f0h,0f3h,0f3h,010h,000h,003h,007h,007h,017h,0f7h,0f7h,0f3h,005h,000h	; 4827  ................
	defb 08bh,0f8h,0fch,07ch,01ch,0fch,0fch,01ch,01ch,0fch,0fch,0eeh,010h,0e0h,003h,01fh	; 4837  ...|............
	defb 00dh,001h,003h,0feh,00dh,0e0h,005h,000h,084h,0eeh,0feh,0feh,0f0h,007h,0e0h,005h	; 4847  ................
	defb 000h,083h,01eh,07fh,073h,088h,0e1h,0ffh,0ffh,0e0h,0f0h,07fh,07fh,01fh,005h,000h	; 4857  ....s...........
	defb 083h,003h,08fh,08eh,088h,0dch,0dfh,0dfh,01ch,05eh,0cfh,0cfh,083h,005h,000h,083h	; 4867  .........^......
	defb 0c0h,0f0h,070h,088h,038h,0f8h,0f8h,000h,008h,0f8h,0f8h,0f0h,085h,00eh,00eh,00fh	; 4877  ..p.8...........
	defb 007h,001h,003h,000h,085h,00eh,00eh,01eh,0fch,0f0h,003h,000h,000h,002h,0c1h,002h	; 4887  ................
	defb 021h,006h,031h,003h,0e1h,003h,0f1h,000h	; 4897  !.1.....

; ======================================================================
; CODIGO 0x489f..0x48f9  (90 bytes)
; ======================================================================


L_489F:
	ld a,011h		;489f
	ld (0e00ah),a		;48a1
	ld hl,00000h		;48a4
	ld (0e00eh),hl		;48a7
	ld hl,048f9h		;48aa
	ld de,02300h		;48ad
	call L_449F		;48b0
	ld de,00300h		;48b3
	ld bc,000d0h		;48b6
	ld a,0f0h		;48b9
	jp L_442C		;48bb
L_48BE:
	ld hl,(0e00eh)		;48be
	ld de,00020h		;48c1
	add hl,de			;48c4
	ld (0e00eh),hl		;48c5
	ex de,hl			;48c8
	or a			;48c9
	ld hl,03aaah		;48ca
	sbc hl,de		;48cd
	ex de,hl			;48cf
	ld a,060h		;48d0
	ld b,003h		;48d2
	call L_48EA		;48d4
	ld bc,00b0ch		;48d7
	call L_48EA		;48da
	ld b,c			;48dd
	call L_48EA		;48de
	xor a			;48e1
	call L_442C		;48e2
	ld hl,0e00ah		;48e5
	dec (hl)			;48e8
	ret			;48e9
L_48EA:
	push de			;48ea
L_48EB:
	call L_4010		;48eb
	inc de			;48ee
	inc a			;48ef
	djnz L_48EB		;48f0
	pop de			;48f2
	ld hl,00020h		;48f3
	add hl,de			;48f6
	ex de,hl			;48f7
	ret			;48f8

; ----------------------------------------------------------------------
; DATOS sin identificar  0x48f9..0x498c  (147 bytes)
DATA_48F9:
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


L_498C:
	call L_4992		;498c
	jp L_4019		;498f
L_4992:
	ld a,l			;4992
	ld e,h			;4993
	rra			;4994
	rra			;4995
	rra			;4996
	rra			;4997
	rr e		;4998
	rra			;499a
	rr e		;499b
	rra			;499d
	rr e		;499e
	and 003h		;49a0
	add a,038h		;49a2
	ld d,a			;49a4
	ret			;49a5
L_49A6:
	push bc			;49a6
	ld b,000h		;49a7
	call L_4441		;49a9
	pop bc			;49ac
	ld a,020h		;49ad
	call L_4027		;49af
	djnz L_49A6		;49b2
	ret			;49b4
L_49B5:
	call L_4A0E		;49b5
L_49B8:
	ld a,(hl)			;49b8
	inc hl			;49b9
	ld h,(hl)			;49ba
	ld l,a			;49bb
L_49BC:
	ld a,l			;49bc
	sub 018h		;49bd
	cp 0a8h		;49bf
	jr nc,L_49E3		;49c1
	push hl			;49c3
	push de			;49c4
	call L_4992		;49c5
	pop hl			;49c8
	push bc			;49c9
	ld a,c			;49ca
	cp 007h		;49cb
	jr nc,L_49D6		;49cd
	ld b,000h		;49cf
	call L_4441		;49d1
	jr L_49D9		;49d4
L_49D6:
	call L_449F		;49d6
L_49D9:
	ex de,hl			;49d9
	pop bc			;49da
	pop hl			;49db
L_49DC:
	ld a,l			;49dc
	add a,008h		;49dd
	ld l,a			;49df
	djnz L_49BC		;49e0
	ret			;49e2
L_49E3:
	ld a,c			;49e3
	cp 007h		;49e4
	jr nc,L_49ED		;49e6
	call L_4027		;49e8
	jr L_49DC		;49eb
L_49ED:
	ld a,(de)			;49ed
	inc de			;49ee
	or a			;49ef
	jr z,L_49DC		;49f0
	jp p,L_49FC		;49f2
	and 07fh		;49f5
L_49F7:
	call L_4027		;49f7
	jr L_49ED		;49fa
L_49FC:
	ld a,001h		;49fc
	jr L_49F7		;49fe
L_4A00:
	ld a,l			;4a00
	sub 018h		;4a01
	cp 0a8h		;4a03
	ret nc			;4a05
	call L_4992		;4a06
	ld a,003h		;4a09
	jp L_442C		;4a0b
L_4A0E:
	push hl			;4a0e
	inc hl			;4a0f
	inc hl			;4a10
	ld a,(hl)			;4a11
	bit 7,a		;4a12
	ld hl,05130h		;4a14
	jr z,L_4A2C		;4a17
	ld hl,05188h		;4a19
	bit 5,a		;4a1c
	jr nz,L_4A2A		;4a1e
	ld hl,05146h		;4a20
	bit 6,a		;4a23
	jr z,L_4A2A		;4a25
	ld hl,05170h		;4a27
L_4A2A:
	and 01fh		;4a2a
L_4A2C:
	add a,a			;4a2c
	call L_4022		;4a2d
	ld e,(hl)			;4a30
	inc hl			;4a31
	ld d,(hl)			;4a32
	pop hl			;4a33
	ex de,hl			;4a34
	ld b,(hl)			;4a35
	inc hl			;4a36
	ld c,(hl)			;4a37
	inc hl			;4a38
	ex de,hl			;4a39
	ret			;4a3a
L_4A3B:
	ld a,c			;4a3b
	add a,a			;4a3c
	add a,a			;4a3d
	jp L_4022		;4a3e
L_4A41:
	ld a,c			;4a41
	add a,a			;4a42
	add a,a			;4a43
	jp L_4027		;4a44
L_4A47:
	ld a,c			;4a47
	add a,a			;4a48
	add a,c			;4a49
	ld hl,0e132h		;4a4a
	jp L_4022		;4a4d

; ----------------------------------------------------------------------
; DATOS sin identificar  0x4a50..0x518e  (1854 bytes)
DATA_4A50:
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
	defb 050h,04ah,014h,078h,04ah,000h,078h,04ah,015h,0a2h,04ah,012h,0c6h,04ah,013h,0ech	; 4d30  PJ.xJ.xJ..J..J..
	defb 04ah,011h,00eh,04bh,012h,032h,04bh,014h,05ah,04bh,012h,07eh,04bh,011h,0a0h,04bh	; 4d40  J..K.2K.ZK.~K..K
	defb 011h,0c2h,04bh,010h,0e2h,04bh,012h,006h,04ch,012h,02ah,04ch,013h,050h,04ch,012h	; 4d50  ..K..K..L.*L.PL.
	defb 0d0h,04ch,006h,0deh,04ch,00ch,074h,04ch,00ch,08ch,04ch,00dh,0a6h,04ch,00bh,0bch	; 4d60  .L..L.tL..L..L..
	defb 04ch,00ah,00eh,04dh,010h,0f8h,04ch,00ah,0e2h,04ch,00ah,017h,006h,003h,004h,010h	; 4d70  L..M..L..L......
	defb 00fh,014h,00ch,011h,003h,013h,004h,010h,00dh,015h,014h,016h,018h,012h,007h,000h	; 4d80  ................
	defb 010h,00ch,009h,014h,011h,007h,012h,007h,010h,015h,00eh,00dh,016h,018h,000h,013h	; 4d90  ................
	defb 002h,010h,00fh,00bh,015h,011h,002h,012h,005h,007h,010h,008h,00fh,00ch,016h,018h	; 4da0  ................
	defb 003h,007h,004h,010h,00dh,00bh,008h,011h,012h,003h,002h,010h,008h,00ah,015h,008h	; 4db0  ................
	defb 016h,018h,002h,007h,004h,010h,009h,00fh,00bh,009h,014h,009h,00eh,014h,00ah,00fh	; 4dc0  ................
	defb 00bh,00ch,016h,018h,007h,006h,005h,010h,00dh,009h,00ch,015h,011h,012h,006h,007h	; 4dd0  ................
	defb 010h,015h,008h,00ah,016h,018h,007h,013h,000h,010h,009h,00ch,00dh,008h,011h,007h	; 4de0  ................
	defb 005h,002h,007h,010h,008h,009h,00eh,016h,018h,012h,000h,002h,005h,010h,015h,00ch	; 4df0  ................
	defb 009h,00eh,00ah,014h,00dh,009h,00eh,015h,016h,018h,003h,002h,000h,006h,007h,005h	; 4e00  ................
	defb 007h,013h,000h,010h,014h,00ah,00dh,009h,00eh,00dh,016h,07bh,04dh,08ch,04dh,09dh	; 4e10  ...........{M.M.
	defb 04dh,0afh,04dh,0c1h,04dh,0d3h,04dh,0e5h,04dh,0f8h,04dh,009h,04eh,07bh,04dh,001h	; 4e20  M.M.M.M.M.M.N{M.
	defb 005h,0cdh,0cfh,0cfh,0cfh,0d0h,001h,007h,001h,0cdh,005h,0cfh,001h,0d0h,000h,001h	; 4e30  ................
	defb 009h,001h,0cdh,007h,0cfh,001h,0d0h,000h,001h,00bh,001h,0cdh,009h,0cfh,001h,0d0h	; 4e40  ................
	defb 000h,001h,00fh,001h,0cdh,00dh,0cfh,001h,0d0h,000h,001h,005h,0d0h,0cfh,0cfh,0cfh	; 4e50  ................
	defb 0ceh,001h,007h,001h,0d0h,005h,0cfh,001h,0ceh,000h,001h,009h,001h,0d0h,007h,0cfh	; 4e60  ................
	defb 001h,0ceh,000h,001h,00bh,001h,0d0h,009h,0cfh,001h,0ceh,000h,001h,00fh,001h,0d0h	; 4e70  ................
	defb 00dh,0cfh,001h,0ceh,000h,005h,001h,086h,086h,08bh,08ch,086h,005h,001h,08ah,08ah	; 4e80  ................
	defb 08dh,08eh,08ah,004h,001h,086h,01ch,01dh,086h,004h,001h,08ah,01eh,01fh,08ah,005h	; 4e90  ................
	defb 020h,00eh,003h,084h,086h,088h,089h,08ah,004h,003h,083h,078h,079h,07ah,007h,003h	; 4ea0   ..........xyz..
	defb 000h,085h,003h,003h,07dh,07eh,07fh,009h,003h,084h,086h,088h,089h,08ah,004h,003h	; 4eb0  ....}~..........
	defb 083h,078h,079h,07ah,007h,003h,000h,08ah,07bh,07ch,005h,005h,005h,080h,081h,07dh	; 4ec0  .xyz....{|.....}
	defb 07eh,07fh,004h,003h,084h,086h,088h,089h,08ah,004h,003h,083h,078h,079h,07ah,005h	; 4ed0  ~...........xyz.
	defb 003h,082h,07dh,07eh,000h,00ah,075h,088h,074h,076h,077h,077h,086h,088h,089h,08ah	; 4ee0  ..}~..u.tvww....
	defb 004h,003h,08ah,078h,079h,07ah,003h,07dh,07eh,07dh,07ch,005h,005h,000h,00eh,004h	; 4ef0  ...xyz.}~}|.....
	defb 084h,086h,088h,089h,08ah,004h,004h,083h,071h,072h,073h,007h,004h,000h,004h,020h	; 4f00  ........qrs.... 
	defb 00eh,004h,084h,086h,088h,089h,08ah,004h,004h,083h,06dh,06eh,06fh,007h,004h,000h	; 4f10  ..........mno...
	defb 00eh,068h,084h,086h,088h,089h,08ah,004h,068h,083h,069h,06ah,06bh,007h,068h,000h	; 4f20  .h......h.ijk.h.
	defb 00eh,064h,084h,086h,088h,089h,08ah,004h,064h,083h,066h,067h,065h,007h,064h,000h	; 4f30  .d......d.fge.d.
	defb 00dh,062h,086h,085h,086h,088h,089h,08ah,087h,003h,062h,083h,082h,083h,084h,007h	; 4f40  .b........b.....
	defb 062h,000h,001h,020h,00eh,061h,084h,060h,061h,061h,063h,00eh,061h,000h,003h,001h	; 4f50  b.. .a.`aac.a...
	defb 0d4h,0d5h,003h,004h,003h,003h,09bh,003h,0c3h,022h,0c4h,003h,023h,003h,003h,003h	; 4f60  ........."..#...
	defb 003h,005h,003h,003h,09bh,003h,0beh,024h,0bfh,0c0h,025h,0c1h,003h,0c2h,003h,003h	; 4f70  .......$..%.....
	defb 003h,003h,004h,003h,003h,09bh,003h,0bch,020h,0bdh,003h,021h,003h,003h,003h,003h	; 4f80  ........ ..!....
	defb 001h,020h,083h,0a9h,089h,08ah,00dh,003h,00dh,003h,083h,006h,088h,0b1h,000h,004h	; 4f90  . ..............
	defb 020h,083h,0a9h,089h,0aah,005h,0abh,083h,091h,094h,097h,004h,0abh,082h,0adh,0aeh	; 4fa0   ...............
	defb 004h,0abh,083h,091h,094h,097h,005h,0abh,083h,0afh,0b0h,0b1h,000h,082h,0a9h,0a3h	; 4fb0  ................
	defb 006h,0a4h,083h,092h,095h,098h,004h,0a4h,082h,0a5h,0a6h,004h,0a4h,083h,092h,095h	; 4fc0  ................
	defb 098h,006h,0a4h,082h,0a7h,0a8h,000h,081h,09dh,007h,09ch,090h,093h,096h,099h,09ch	; 4fd0  ................
	defb 09ch,09eh,0a0h,088h,089h,0a1h,0a2h,09ch,09ch,093h,096h,099h,007h,09ch,081h,09fh	; 4fe0  ................
	defb 000h,008h,003h,083h,078h,079h,07ah,003h,003h,084h,006h,088h,089h,08ah,003h,003h	; 4ff0  ....xyz.........
	defb 083h,078h,079h,07ah,008h,003h,000h,001h,020h,00eh,003h,084h,006h,088h,089h,08ah	; 5000  .xyz.... .......
	defb 00eh,003h,000h,004h,020h,082h,0b2h,0ach,006h,0abh,083h,091h,094h,097h,003h,0abh	; 5010  .... ...........
	defb 084h,0afh,0b0h,089h,0aah,003h,0abh,083h,091h,094h,097h,007h,0abh,081h,0b3h,000h	; 5020  ................
	defb 082h,0a9h,0a6h,006h,0a4h,083h,092h,095h,098h,004h,0a4h,082h,0a7h,0a3h,004h,0a4h	; 5030  ................
	defb 083h,092h,095h,098h,006h,0a4h,082h,0a5h,0b1h,000h,084h,0a9h,089h,08ah,0a2h,004h	; 5040  ................
	defb 09ch,083h,093h,096h,099h,00ah,09ch,083h,093h,096h,099h,004h,09ch,084h,09eh,0a0h	; 5050  ................
	defb 088h,0b1h,000h,083h,0a9h,089h,08ah,005h,003h,083h,078h,079h,07ah,00ah,003h,083h	; 5060  ..........xyz...
	defb 078h,079h,07ah,005h,003h,083h,006h,088h,0b1h,000h,001h,001h,09bh,002h,001h,09bh	; 5070  xyz.............
	defb 003h,003h,001h,09bh,09ah,09bh,001h,009h,001h,0cdh,003h,0cfh,085h,0d3h,0d2h,0d1h	; 5080  ................
	defb 0d0h,0d0h,000h,002h,003h,078h,079h,07ah,003h,003h,003h,001h,003h,078h,079h,07ah	; 5090  .....xyz.....xyz
	defb 002h,001h,086h,0d6h,002h,001h,08ah,0d7h,005h,002h,003h,003h,0c9h,0cah,028h,029h	; 50a0  ..............()
	defb 0cbh,0cch,003h,003h,004h,003h,003h,003h,003h,0c5h,026h,0c6h,0c7h,027h,0c8h,003h	; 50b0  ..........&..'..
	defb 003h,003h,004h,002h,003h,003h,02ah,02bh,02ch,02dh,003h,003h,001h,020h,010h,00ah	; 50c0  ......*+,-... ..
	defb 001h,00ch,00fh,00ah,000h,001h,020h,0a0h,00ah,00ah,00bh,00ah,00ah,00bh,00ah,00ah	; 50d0  ...... .........
	defb 00bh,00ah,00ah,00bh,00ah,00ah,00bh,00ah,00ch,00ah,00bh,00ah,00ah,00bh,00ah,00ah	; 50e0  ................
	defb 00bh,00ah,00ah,00bh,00ah,00ah,00bh,00ah,000h,003h,002h,00ah,00ah,02fh,008h,007h	; 50f0  ............./..
	defb 009h,003h,002h,003h,003h,003h,003h,019h,01ah,003h,002h,003h,003h,003h,003h,01bh	; 5100  ................
	defb 01bh,003h,002h,003h,003h,019h,01ah,01bh,01bh,002h,002h,003h,003h,0b6h,0b7h,002h	; 5110  ................
	defb 003h,003h,003h,003h,0e2h,0e3h,0e4h,002h,002h,003h,003h,0bah,0bbh,001h,001h,003h	; 5120  ................
	defb 02fh,04eh,036h,04eh,03fh,04eh,048h,04eh,051h,04eh,05ah,04eh,061h,04eh,06ah,04eh	; 5130  /N6N?NHNQNZNaNjN
	defb 073h,04eh,07ch,04eh,086h,050h,085h,04eh,08ch,04eh,09fh,04eh,00eh,04fh,052h,04fh	; 5140  sN|N.P.N.N.N.ORO
	defb 093h,050h,07dh,050h,09fh,04fh,090h,04fh,007h,050h,013h,050h,0a0h,050h,0a8h,050h	; 5150  .P}P.O.O.P.P.P.P
	defb 0b4h,050h,0a4h,050h,081h,050h,0c2h,050h,0cch,050h,0d5h,050h,093h,04eh,099h,04eh	; 5160  .P.P.P.P.P.P.N.N
	defb 05eh,04fh,063h,04fh,09bh,050h,07ah,050h,0f9h,050h,001h,051h,009h,051h,011h,051h	; 5170  ^OcO.PzP.P.Q.Q.Q
	defb 019h,051h,01fh,051h,027h,051h,02dh,051h,063h,04fh,071h,04fh,082h,04fh	; 5180  .Q.Q'Q-QcOqO.O

; ======================================================================
; CODIGO 0x518e..0x51c1  (51 bytes)
; ======================================================================


L_518E:
	ld hl,0e049h		;518e
	ld bc,000e7h		;5191
	ld a,(0e002h)		;5194
	and 020h		;5197
	push af			;5199
	jr z,L_51A1		;519a
	ld l,046h		;519c
	inc bc			;519e
	inc bc			;519f
	inc bc			;51a0
L_51A1:
	ld d,h			;51a1
	ld e,l			;51a2
	inc e			;51a3
	ld (hl),000h		;51a4
	ldir		;51a6
	ld hl,051c1h		;51a8
	ld de,0e050h		;51ab
	ld bc,00011h		;51ae
	ldir		;51b1
	pop af			;51b3
	ret z			;51b4
	ld hl,0e050h		;51b5
	ld de,0e080h		;51b8
	ld bc,00020h		;51bb
	ldir		;51be
	ret			;51c0

; ----------------------------------------------------------------------
; DATOS sin identificar  0x51c1..0x51d2  (17 bytes)
DATA_51C1:
	defb 003h,001h,000h,000h,000h,000h,084h,0f0h,003h,000h,083h,03bh,000h,077h,000h,004h	; 51c1  ...........;.w..
	defb 000h	; 51d1

; ======================================================================
; CODIGO 0x51d2..0x5394  (450 bytes)
; ======================================================================


L_51D2:
	call L_60C9		;51d2
	call L_52AE		;51d5
	call L_5321		;51d8
	jp L_52A2		;51db
L_51DE:
	ld a,(0e001h)		;51de
	or a			;51e1
	jp nz,L_5227		;51e2
	call L_52A2		;51e5
	call L_5242		;51e8
	jr c,L_522F		;51eb
	call L_77CA		;51ed
	jr nc,L_51F5		;51f0
	call L_77E7		;51f2
L_51F5:
	call L_6170		;51f5
	call L_6B22		;51f8
	call L_6AB9		;51fb
	call L_6BBF		;51fe
	call L_6DD2		;5201
	call L_6D6D		;5204
	call L_71C7		;5207
	call L_6FB7		;520a
	call L_701F		;520d
	call L_720D		;5210
	call L_72E1		;5213
	call L_7836		;5216
	call L_790F		;5219
	call L_79EE		;521c
L_521F:
	call L_66C2		;521f
	xor a			;5222
	ld (0e1aah),a		;5223
	ret			;5226
L_5227:
	call L_52A2		;5227
	call L_6170		;522a
	jr L_521F		;522d
L_522F:
	ld a,09ch		;522f
	call L_7A13		;5231
	ld a,008h		;5234
	ld (0e1b2h),a		;5236
	xor a			;5239
	ld (0e003h),a		;523a
	inc a			;523d
	ld (0e001h),a		;523e
	ret			;5241
L_5242:
	call L_61A3		;5242
	ld a,(0e1b2h)		;5245
	cp 004h		;5248
	ret z			;524a
	cp 003h		;524b
	jr nz,L_5254		;524d
	ld a,(0e1c8h)		;524f
	and a			;5252
	ret m			;5253
L_5254:
	ld hl,0e1bfh		;5254
	ld b,002h		;5257
L_5259:
	ld a,(hl)			;5259
	ld c,a			;525a
	sub 020h		;525b
	cp 00eh		;525d
	ret c			;525f
	inc hl			;5260
	djnz L_5259		;5261
	ld hl,0e0e4h		;5263
	ld de,01010h		;5266
	ld b,008h		;5269
L_526B:
	push bc			;526b
	call L_5284		;526c
	pop bc			;526f
	inc hl			;5270
	jr nc,L_527E		;5271
	ld a,(hl)			;5273
	cp 090h		;5274
	jr z,L_527E		;5276
	cp 094h		;5278
	jr z,L_527E		;527a
	scf			;527c
	ret			;527d
L_527E:
	inc hl			;527e
	inc hl			;527f
	djnz L_526B		;5280
	xor a			;5282
	ret			;5283
L_5284:
	ld bc,(0e1b3h)		;5284
	ld a,008h		;5288
	add a,c			;528a
	sub (hl)			;528b
	cp e			;528c
	jr c,L_5294		;528d
	ld a,018h		;528f
	add a,c			;5291
	sub (hl)			;5292
	cp e			;5293
L_5294:
	inc hl			;5294
	ret nc			;5295
	ld a,006h		;5296
	add a,b			;5298
	sub (hl)			;5299
	cp d			;529a
	ret c			;529b
	ld a,00ah		;529c
	add a,b			;529e
	sub (hl)			;529f
	cp d			;52a0
	ret			;52a1
L_52A2:
	ld hl,0e0b0h		;52a2
	ld de,03b00h		;52a5
	ld bc,00080h		;52a8
	jp L_4441		;52ab
L_52AE:
	ld hl,0e131h		;52ae
	ld de,0e132h		;52b1
	ld (hl),000h		;52b4
	ld bc,00124h		;52b6
	ldir		;52b9
L_52BB:
	ld hl,0e132h		;52bb
	ld de,0e133h		;52be
	ld (hl),0d0h		;52c1
	ld bc,00077h		;52c3
	ldir		;52c6
	ld de,03b80h		;52c8
	ld a,(0e05ch)		;52cb
	add a,a			;52ce
	ld hl,04e1bh		;52cf
	call L_4022		;52d2
	ld a,(hl)			;52d5
	inc hl			;52d6
	ld h,(hl)			;52d7
	ld l,a			;52d8
L_52D9:
	push hl			;52d9
	ld a,(hl)			;52da
	call L_52E6		;52db
	pop hl			;52de
	ld a,(hl)			;52df
	inc hl			;52e0
	cp 016h		;52e1
	jr nz,L_52D9		;52e3
	ret			;52e5
L_52E6:
	ld l,a			;52e6
	add a,a			;52e7
	add a,l			;52e8
	ld hl,04d30h		;52e9
	call L_4022		;52ec
	ld a,(hl)			;52ef
	inc hl			;52f0
	ld c,(hl)			;52f1
	inc hl			;52f2
	ld b,(hl)			;52f3
	ld l,a			;52f4
	ld h,c			;52f5
L_52F6:
	ld a,(hl)			;52f6
	cp 0ffh		;52f7
	jr z,L_5312		;52f9
	and 0f8h		;52fb
	ld c,a			;52fd
	ld a,(hl)			;52fe
	and 007h		;52ff
	call L_4010		;5301
	inc de			;5304
	inc hl			;5305
	ld a,(hl)			;5306
	inc hl			;5307
	call L_4010		;5308
	inc de			;530b
	ld a,c			;530c
	call L_4010		;530d
	jr L_531D		;5310
L_5312:
	inc hl			;5312
	push bc			;5313
	ld bc,00003h		;5314
	call L_4441		;5317
	pop bc			;531a
	inc de			;531b
	inc de			;531c
L_531D:
	inc de			;531d
	djnz L_52F6		;531e
	ret			;5320
L_5321:
	call L_5363		;5321
	call L_5346		;5324
	ld hl,0e0d3h		;5327
	ld de,0539dh		;532a
	ld b,005h		;532d
L_532F:
	ld a,(de)			;532f
	ld (hl),a			;5330
	inc de			;5331
	inc hl			;5332
	inc hl			;5333
	inc hl			;5334
	inc hl			;5335
	djnz L_532F		;5336
	ld hl,05398h		;5338
	ld de,0e1b3h		;533b
	ld bc,00005h		;533e
	ldir		;5341
	jp L_6584		;5343
L_5346:
	ld de,0e0b0h		;5346
	ld hl,05394h		;5349
	ld bc,00404h		;534c
L_534F:
	push hl			;534f
	push bc			;5350
	ld b,000h		;5351
	ldir		;5353
	pop bc			;5355
	pop hl			;5356
	djnz L_534F		;5357
	ld h,d			;5359
	ld l,e			;535a
	ld (hl),0c3h		;535b
	inc de			;535d
	ld c,06fh		;535e
	ldir		;5360
	ret			;5362
L_5363:
	ld a,(0e059h)		;5363
	ld hl,(0e05ah)		;5366
	push af			;5369
	push hl			;536a
	dec hl			;536b
	dec hl			;536c
	dec hl			;536d
	ld (0e1c5h),hl		;536e
	call 0004ah		;5371   ; BIOS RDVRM - Reads the content of VRAM
	dec a			;5374
	ld (0e1c4h),a		;5375
	ld a,001h		;5378
	ld (0e1aah),a		;537a
	ld b,01ah		;537d
L_537F:
	push bc			;537f
	call L_6749		;5380
	pop bc			;5383
	djnz L_537F		;5384
	pop hl			;5386
	pop af			;5387
	ld (0e059h),a		;5388
	ld (0e05ah),hl		;538b
	ld hl,0e1abh		;538e
	set 1,(hl)		;5391
	ret			;5393

; ----------------------------------------------------------------------
; DATOS sin identificar  0x5394..0x53a2  (14 bytes)
DATA_5394:
	defb 008h,000h,000h,000h,098h,020h,000h,000h,008h,009h,001h,009h,006h,009h	; 5394  ..... ........

; ======================================================================
; CODIGO 0x53a2..0x53e4  (66 bytes)
; ======================================================================


L_53A2:
	ld hl,0e24dh		;53a2
	ld de,(0e24eh)		;53a5
	dec (hl)			;53a9
	jr nz,L_53BC		;53aa
	inc de			;53ac
	inc de			;53ad
	ld a,(de)			;53ae
	cp 0ffh		;53af
	jr nz,L_53B7		;53b1
	ld (0e00ch),a		;53b3
	ret			;53b6
L_53B7:
	ld (hl),a			;53b7
	ld (0e24eh),de		;53b8
L_53BC:
	inc de			;53bc
	ld a,(de)			;53bd
	ld (0e009h),a		;53be
	ret			;53c1
L_53C2:
	call L_518E		;53c2
	call L_4343		;53c5
	call L_51D2		;53c8
	xor a			;53cb
	ld (0e00ch),a		;53cc
	ld (0e001h),a		;53cf
	ld a,096h		;53d2
	ld (0e24dh),a		;53d4
	ld hl,053e4h		;53d7
	ld (0e24eh),hl		;53da
	ret			;53dd
L_53DE:
	call L_53A2		;53de
	jp L_51DE		;53e1

; ----------------------------------------------------------------------
; DATOS sin identificar  0x53e4..0x60c9  (3301 bytes)
DATA_53E4:
	defb 000h,008h,0e0h,001h,020h,004h,022h,014h,015h,004h,022h,010h,015h,008h,022h,018h	; 53e4  .... ."..."...".
	defb 001h,002h,030h,008h,001h,001h,020h,004h,022h,014h,008h,004h,024h,014h,001h,008h	; 53f4  ..0... ."...$...
	defb 022h,018h,008h,008h,024h,018h,020h,008h,022h,018h,008h,008h,024h,014h,014h,004h	; 5404  "...$. ."...$...
	defb 022h,010h,008h,004h,038h,014h,008h,008h,022h,018h,020h,008h,020h,004h,022h,014h	; 5414  "...8...". . .".
	defb 001h,004h,030h,014h,008h,008h,022h,018h,004h,004h,022h,010h,040h,000h,038h,014h	; 5424  ..0..."...".@.8.
	defb 001h,000h,022h,010h,001h,000h,001h,018h,040h,001h,040h,018h,001h,004h,0a0h,014h	; 5434  ..".....@.@.....
	defb 0ffh,038h,020h,098h,0b0h,0b0h,0b0h,0b8h,09ch,08fh,087h,07bh,06eh,051h,0e1h,041h	; 5444  .8 ........{nQ.A
	defb 0e1h,071h,039h,01dh,00dh,00dh,00dh,01dh,039h,0f1h,0e1h,0deh,004h,000h,003h,0ffh	; 5454  .q9.....9.......
	defb 005h,000h,084h,0ffh,010h,038h,010h,008h,080h,082h,0ffh,0ffh,00ch,000h,004h,0ffh	; 5464  .....8..........
	defb 012h,003h,084h,007h,03fh,0ffh,0ffh,004h,0c0h,082h,0e0h,0fch,004h,0ffh,00eh,0c0h	; 5474  ....?...........
	defb 088h,018h,03ch,07eh,0ffh,07eh,066h,066h,07eh,087h,000h,000h,008h,01ch,03eh,07fh	; 5484  ..<~.~ff~.....>.
	defb 07fh,008h,01ch,004h,000h,001h,068h,004h,054h,098h,000h,00fh,01fh,01fh,00fh,007h	; 5494  ......h.T.......
	defb 003h,001h,000h,0f0h,0f8h,0f8h,0f0h,0e0h,0c0h,080h,000h,07eh,07eh,0f0h,0f0h,07eh	; 54a4  ...........~~..~
	defb 03ch,018h,082h,0d3h,091h,008h,080h,083h,084h,0cch,0deh,003h,0ffh,082h,0d7h,093h	; 54b4  <...............
	defb 008h,003h,083h,043h,067h,0f7h,003h,007h,0f0h,024h,0ffh,099h,024h,024h,099h,099h	; 54c4  ...Cg....$..$$..
	defb 000h,000h,0ffh,000h,0ffh,081h,081h,081h,000h,024h,0ffh,000h,0ffh,000h,0ffh,000h	; 54d4  .........$......
	defb 0ffh,000h,0ffh,000h,0ffh,000h,07eh,07eh,07eh,010h,030h,070h,050h,024h,0ffh,099h	; 54e4  ......~~~.0pP$..
	defb 000h,000h,0ffh,000h,0ffh,000h,0ffh,000h,0ffh,0c3h,0ffh,099h,000h,099h,099h,066h	; 54f4  ...............f
	defb 07eh,03ch,018h,03ch,03ch,03ch,07eh,0e7h,000h,009h,009h,006h,00fh,01bh,01bh,019h	; 5504  ~<.<<<~.........
	defb 01fh,090h,090h,060h,0f0h,0d8h,0d8h,098h,0f8h,00ch,00fh,006h,00fh,009h,009h,006h	; 5514  ...`............
	defb 01fh,030h,0f0h,060h,0f0h,090h,090h,060h,0f8h,039h,079h,0f5h,093h,0fch,006h,00eh	; 5524  .0.`...`.9y.....
	defb 000h,09ch,09eh,0afh,0c9h,03fh,060h,070h,000h,090h,018h,081h,024h,05ah,0dbh,0ffh	; 5534  .....?`p....$Z..
	defb 066h,03ch,076h,08ah,087h,082h,087h,08eh,09ch,0b8h,080h,000h,023h,090h,081h,0e7h	; 5544  f<v.........#...
	defb 0ffh,0cfh,09dh,01bh,032h,000h,0ffh,0ffh,0ffh,0cfh,09dh,01bh,032h,000h,008h,0ffh	; 5554  ....2.......2...
	defb 091h,0c1h,0f0h,0f8h,0cfh,09dh,01bh,032h,000h,0ffh,0ffh,0ffh,0cfh,09dh,01bh,032h	; 5564  .......2.......2
	defb 000h,007h,006h,0e7h,082h,007h,0e0h,006h,0e7h,0a9h,0e0h,0ffh,0ffh,0ffh,0efh,0ddh	; 5574  ................
	defb 099h,000h,0ffh,0aah,099h,0ffh,0aah,0ffh,0ffh,099h,0ffh,0e0h,0e7h,0e7h,0e7h,0e7h	; 5584  ................
	defb 0ffh,0e7h,0e0h,0ffh,0aah,0ffh,099h,0ffh,0ffh,0ffh,0ffh,0f8h,018h,018h,018h,018h	; 5594  ................
	defb 0ffh,018h,0f8h,008h,0ffh,001h,0e0h,006h,0e7h,082h,0e0h,000h,006h,0ffh,082h,000h	; 55a4  ................
	defb 007h,006h,0e7h,001h,007h,008h,0ffh,001h,0e0h,006h,0e7h,082h,0e0h,000h,006h,0ffh	; 55b4  ................
	defb 082h,000h,007h,006h,0e7h,089h,007h,080h,0e0h,0fch,0ffh,0ffh,0ffh,0ffh,055h,007h	; 55c4  ..............U.
	defb 0ffh,001h,055h,004h,000h,003h,0ffh,001h,055h,005h,000h,002h,0ffh,082h,055h,01fh	; 55d4  ..U.....U.....U.
	defb 006h,018h,082h,01fh,0ffh,006h,000h,082h,0ffh,0f8h,006h,018h,08ch,0f8h,0ffh,0ffh	; 55e4  ................
	defb 0ffh,0ffh,0f8h,0e0h,0c0h,000h,0feh,0f8h,0c0h,005h,000h,09bh,0ffh,0ffh,0ffh,0fch	; 55f4  ................
	defb 0f0h,0e0h,080h,000h,0ffh,0ffh,0ffh,03fh,00fh,007h,001h,000h,0ffh,0ffh,0ffh,0ffh	; 5604  .......?........
	defb 0ffh,07fh,03fh,000h,07fh,01fh,003h,005h,000h,089h,0ffh,0ffh,0ffh,0ffh,01fh,007h	; 5614  ..?.............
	defb 003h,000h,0e0h,005h,0e7h,083h,0c3h,081h,000h,007h,0ffh,001h,007h,005h,0e7h,08ah	; 5624  ................
	defb 0c3h,081h,0feh,0fch,0f8h,0f0h,0e0h,0c0h,002h,009h,008h,0ffh,088h,07fh,03fh,01fh	; 5634  ..............?.
	defb 00fh,007h,003h,040h,080h,008h,0d6h,008h,088h,008h,0f8h,082h,01ch,03eh,00dh,07fh	; 5644  ...@.........>..
	defb 001h,0ffh,082h,038h,07ch,00dh,0feh,011h,0ffh,002h,01fh,005h,018h,002h,01fh,006h	; 5654  ...8|...........
	defb 018h,002h,01fh,006h,018h,083h,01fh,0ffh,0ffh,005h,000h,08ah,0ffh,000h,0ffh,0ffh	; 5664  ................
	defb 000h,0ffh,0ffh,0ffh,0ffh,000h,006h,0ffh,083h,000h,0f8h,0f8h,005h,018h,002h,0f8h	; 5674  ................
	defb 006h,018h,002h,0f8h,006h,018h,091h,0f8h,010h,01eh,033h,072h,052h,0f7h,0f7h,0f7h	; 5684  ..........3rR...
	defb 010h,018h,01ch,014h,010h,030h,070h,050h,004h,0ffh,004h,000h,084h,01fh,00fh,007h	; 5694  .....0pP........
	defb 001h,004h,000h,005h,0ffh,0d3h,03fh,007h,001h,0f8h,0f0h,0e0h,080h,000h,000h,000h	; 56a4  ......?.........
	defb 000h,0ffh,0ffh,00fh,001h,001h,000h,000h,000h,0ffh,0e0h,0c0h,080h,0fch,0f8h,0f8h	; 56b4  ................
	defb 0f8h,0ffh,0ffh,0c0h,0ffh,0ffh,0fch,0e0h,080h,08ch,086h,083h,083h,0c0h,060h,038h	; 56c4  ..............`8
	defb 00fh,000h,000h,000h,0ffh,000h,000h,000h,0ffh,007h,003h,001h,0f8h,01ch,00ch,004h	; 56d4  ................
	defb 004h,0e0h,0c0h,080h,01fh,030h,060h,040h,04fh,016h,036h,066h,0c6h,006h,00eh,01eh	; 56e4  .....0`@O.6f....
	defb 0fch,070h,070h,070h,070h,060h,040h,000h,000h,008h,001h,088h,007h,01fh,03fh,00fh	; 56f4  .pppp`@.......?.
	defb 003h,080h,080h,0e0h,005h,000h,003h,0ffh,005h,000h,0a3h,03fh,07fh,0ffh,003h,001h	; 5704  ...........?....
	defb 000h,000h,000h,0f8h,0fch,0feh,0c0h,080h,000h,000h,000h,01fh,03fh,07fh,000h,000h	; 5714  ............?...
	defb 000h,001h,007h,0feh,0feh,0fch,029h,029h,029h,029h,069h,069h,0e9h,0e9h,008h,070h	; 5724  ......))))ii...p
	defb 084h,0ffh,0feh,0f8h,0c0h,004h,000h,088h,00fh,007h,003h,001h,000h,0c0h,0e0h,0f0h	; 5734  ................
	defb 010h,000h,090h,005h,013h,04ah,02bh,03fh,016h,016h,01fh,0a0h,0c8h,052h,0d4h,0fch	; 5744  .....J+?.....R..
	defb 068h,068h,0f8h,010h,000h,0a0h,000h,000h,07fh,080h,07fh,000h,000h,000h,080h,0c7h	; 5754  hh..............
	defb 0c7h,0fdh,0c7h,0c7h,080h,0c0h,000h,000h,001h,003h,003h,003h,003h,001h,000h,000h	; 5764  ................
	defb 080h,0c0h,0c0h,0c0h,0c0h,080h,006h,000h,082h,001h,003h,006h,000h,086h,080h,0c0h	; 5774  ................
	defb 003h,003h,003h,001h,004h,000h,003h,0c0h,001h,080h,004h,000h,003h,07eh,007h,000h	; 5784  .............~..
	defb 08eh,001h,003h,003h,003h,003h,001h,000h,000h,080h,0c0h,0c0h,0c0h,0c0h,080h,007h	; 5794  ................
	defb 000h,001h,01fh,007h,000h,085h,0f8h,00fh,00fh,007h,003h,004h,000h,084h,0f0h,0f0h	; 57a4  ................
	defb 0e0h,0c0h,008h,000h,084h,00ch,00fh,006h,00fh,004h,000h,087h,030h,0f0h,060h,0f0h	; 57b4  ............0.`.
	defb 003h,007h,00eh,005h,000h,083h,0c0h,0e0h,070h,005h,000h,09bh,03eh,078h,060h,0e3h	; 57c4  ........p...>x`.
	defb 0c3h,001h,00fh,03fh,07ch,01eh,006h,0c7h,0c3h,080h,0f0h,0fch,03eh,07fh,070h,0f0h	; 57d4  ...?|.......>.p.
	defb 013h,030h,070h,050h,03eh,078h,0e0h,005h,000h,007h,018h,089h,0f8h,03eh,078h,070h	; 57e4  .0pP>x.......>xp
	defb 0f0h,013h,030h,070h,000h,007h,018h,08bh,01fh,018h,018h,07eh,0e3h,0d1h,091h,091h	; 57f4  ..0p.......~....
	defb 0d1h,07eh,03ch,006h,000h,090h,0dbh,092h,06ch,0feh,029h,045h,093h,0ffh,0dbh,049h	; 5804  .~<.....l.)E...I
	defb 036h,07fh,094h,0a2h,0c9h,0ffh,002h,0ffh,006h,0c0h,002h,0ffh,006h,003h,088h,000h	; 5814  6...............
	defb 038h,07ch,0ffh,09fh,06fh,0e6h,0fdh,001h,000h,003h,0dfh,001h,000h,003h,0feh,001h	; 5824  8|..o...........
	defb 0ffh,003h,020h,001h,0ffh,003h,001h,00ah,066h,087h,03ch,081h,081h,03ch,066h,066h	; 5834  .. .....f.<..<ff
	defb 0ffh,003h,020h,001h,0ffh,003h,001h,001h,0ffh,003h,001h,001h,0ffh,003h,020h,001h	; 5844  .. ........... .
	defb 0ffh,003h,001h,001h,0ffh,003h,020h,087h,000h,000h,00ch,03eh,0ffh,03eh,00ch,005h	; 5854  ...... ....>.>..
	defb 000h,081h,0ffh,005h,000h,086h,07ch,0f8h,0f0h,0f8h,07ch,000h,0e8h,006h,003h,01dh	; 5864  ......|...|.....
	defb 00eh,007h,03ah,01dh,00ah,0abh,055h,0aah,055h,07eh,0c3h,081h,081h,060h,0c0h,0b8h	; 5874  ..:...U.U~...`..
	defb 070h,0e0h,05ch,0b8h,050h,000h,0feh,0feh,0feh,000h,0feh,0fch,0fch,000h,000h,000h	; 5884  p.\.P...........
	defb 008h,000h,000h,0ffh,000h,020h,030h,030h,030h,050h,090h,060h,03fh,03ah,01dh,002h	; 5894  ..... 000P.`?:..
	defb 03dh,00eh,033h,01dh,00ah,03ch,07eh,0dbh,0dbh,0ffh,0dbh,0e7h,07eh,05ch,0b8h,040h	; 58a4  =.3..<~.....~\.@
	defb 0bch,070h,0cch,0b8h,050h,0fch,0fch,0fch,0bdh,0adh,0c9h,0e1h,0f3h,03ch,07eh,0dbh	; 58b4  .p..P........<~.
	defb 0dbh,0ffh,0dbh,0e7h,07eh,03fh,03fh,03fh,0bdh,0b5h,093h,087h,0cfh,003h,007h,00fh	; 58c4  ....~???........
	defb 00fh,00eh,00eh,007h,003h,0bbh,07eh,03ch,018h,018h,018h,099h,099h,0ffh,0c0h,0e0h	; 58d4  ......~<........
	defb 0f0h,0f0h,070h,070h,0e0h,0c0h,003h,007h,00fh,00fh,00eh,00eh,007h,003h,081h,0c3h	; 58e4  ..pp............
	defb 0e7h,0ffh,0ffh,07eh,07eh,03ch,0c0h,0e0h,0f0h,0f0h,070h,070h,0e0h,0c0h,022h,01dh	; 58f4  ...~~<....pp..".
	defb 017h,01ch,007h,002h,07eh,03fh,044h,0b8h,0e8h,038h,0e0h,040h,07eh,0fch,00fh,007h	; 5904  ....~?D..8.@~...
	defb 003h,005h,000h,082h,07eh,03ch,005h,018h,084h,0ffh,0f0h,0e0h,0c0h,005h,000h,084h	; 5914  ....~<..........
	defb 073h,07fh,03fh,01eh,004h,000h,083h,081h,0c3h,0e7h,005h,0ffh,083h,0ceh,0feh,078h	; 5924  s.?............x
	defb 005h,000h,000h,008h,000h,008h,011h,008h,022h,008h,033h,008h,044h,008h,0cch,008h	; 5934  ........".3.D...
	defb 066h,018h,016h,006h,086h,002h,098h,005h,086h,083h,018h,019h,018h,004h,036h,084h	; 5944  f.............6.
	defb 038h,038h,039h,038h,040h,063h,004h,0a1h,004h,091h,018h,0f1h,002h,043h,001h,0e3h	; 5954  8898@c.......C..
	defb 005h,043h,002h,053h,001h,0e3h,005h,053h,002h,043h,001h,0e3h,002h,045h,003h,043h	; 5964  .C.S...S.C...E.C
	defb 01dh,064h,003h,068h,002h,013h,004h,01eh,002h,016h,004h,06eh,084h,0ceh,0c6h,0ceh	; 5974  .d.h.......n....
	defb 0ceh,002h,013h,006h,0e6h,005h,0e6h,083h,0e3h,063h,0e3h,001h,073h,003h,063h,084h	; 5984  .........c..s.c.
	defb 013h,013h,01eh,006h,008h,06eh,002h,063h,002h,06fh,084h,0f3h,0f3h,0f6h,0a6h,002h	; 5994  .....n.c.o......
	defb 0a6h,002h,096h,002h,063h,002h,0f3h,003h,0f3h,085h,093h,063h,093h,063h,093h,003h	; 59a4  ....c......c.c..
	defb 0f3h,085h,093h,063h,093h,063h,093h,002h,063h,005h,0f3h,081h,093h,002h,063h,005h	; 59b4  ...c.c..c.....c.
	defb 0f3h,081h,093h,090h,063h,093h,063h,093h,096h,063h,0f3h,0f3h,063h,093h,063h,093h	; 59c4  ....c.c..c..c.c.
	defb 096h,063h,0f3h,0f3h,082h,0a3h,031h,006h,091h,008h,016h,080h,000h,003h,003h,0a6h	; 59d4  .c....1.........
	defb 00dh,0ach,008h,0a0h,003h,0a6h,005h,0ach,008h,0e2h,007h,0efh,081h,02fh,008h,0efh	; 59e4  ............./..
	defb 001h,0f0h,006h,0e2h,0a1h,0f0h,02eh,02eh,0e0h,02eh,0e0h,0f0h,02eh,0e0h,0efh,02fh	; 59f4  .............../
	defb 0efh,02fh,0efh,0f0h,02fh,0efh,0f0h,02eh,0e0h,02eh,0e0h,0f0h,020h,0f0h,0feh,0f2h	; 5a04  ./../....... ...
	defb 0feh,0f2h,0feh,0f0h,0f2h,0feh,040h,04fh,007h,0c3h,001h,0ceh,007h,0c0h,001h,0ceh	; 5a14  ......@O........
	defb 007h,0c3h,001h,0ceh,007h,0c3h,001h,0ceh,018h,0f3h,038h,03ch,018h,0afh,008h,0a6h	; 5a24  ..........8<....
	defb 008h,060h,008h,0a6h,010h,089h,008h,086h,00eh,016h,002h,0e6h,00eh,016h,002h,0e6h	; 5a34  .`..............
	defb 010h,000h,005h,0f6h,003h,0f8h,003h,0f9h,001h,0f8h,003h,0f9h,001h,0f8h,084h,0f9h	; 5a44  ................
	defb 0f6h,0f6h,0f6h,004h,0f3h,005h,0f6h,003h,0f8h,003h,09fh,004h,098h,001h,0f0h,004h	; 5a54  ................
	defb 06fh,004h,03fh,005h,0f6h,003h,0f8h,003h,0f9h,085h,0f8h,0f9h,0f9h,0f9h,0f8h,004h	; 5a64  o.?.............
	defb 0f6h,004h,0f3h,002h,083h,003h,063h,084h,058h,078h,078h,073h,003h,083h,085h,073h	; 5a74  ......c.Xxxs...s
	defb 083h,083h,083h,090h,007h,063h,008h,063h,001h,090h,00fh,063h,008h,096h,004h,098h	; 5a84  .....c.c...c....
	defb 004h,086h,083h,090h,086h,086h,005h,063h,028h,089h,010h,096h,005h,068h,003h,098h	; 5a94  .......c(....h..
	defb 010h,086h,002h,036h,006h,086h,002h,036h,006h,086h,006h,086h,002h,089h,008h,098h	; 5aa4  ...6...6........
	defb 008h,096h,00ch,036h,004h,086h,010h,063h,010h,0f3h,001h,053h,002h,0e3h,006h,0f3h	; 5ab4  ...6...c...S....
	defb 083h,0e3h,073h,053h,004h,043h,003h,0f3h,001h,0feh,004h,0f3h,085h,0a3h,0a3h,0a6h	; 5ac4  ..sS.C..........
	defb 0b1h,0a6h,003h,0a3h,017h,013h,001h,063h,007h,013h,084h,063h,0e3h,063h,0e3h,005h	; 5ad4  .......c...c.c..
	defb 063h,083h,0e3h,063h,0e3h,005h,063h,082h,0e3h,063h,006h,0e3h,003h,063h,085h,0e3h	; 5ae4  c..c..c..c...c..
	defb 063h,0e3h,063h,0e3h,003h,063h,085h,0e3h,063h,0e3h,063h,0e3h,010h,083h,083h,0e3h	; 5af4  c.c..c..c.c.....
	defb 093h,0e3h,005h,093h,083h,0e3h,093h,0e3h,005h,093h,006h,063h,002h,0f3h,006h,063h	; 5b04  ...........c...c
	defb 002h,0f3h,002h,063h,006h,0f3h,002h,063h,006h,0f3h,002h,0c9h,001h,0c8h,002h,0c6h	; 5b14  ...c...c........
	defb 003h,036h,002h,0c9h,001h,0c8h,002h,0c6h,003h,036h,002h,0c9h,083h,0c8h,0c6h,0c3h	; 5b24  .6.......6......
	defb 003h,063h,083h,0c9h,0c6h,0c6h,005h,003h,003h,0f9h,082h,0f8h,0f6h,003h,0f3h,002h	; 5b34  .c..............
	defb 0c9h,08ah,0c8h,0c6h,0c3h,063h,063h,00fh,0f9h,0f9h,0f8h,0f6h,004h,0f3h,003h,063h	; 5b44  .....cc........c
	defb 005h,086h,008h,063h,002h,064h,002h,0e4h,004h,04fh,002h,064h,002h,0e4h,004h,04fh	; 5b54  ...c.d...O.d...O
	defb 010h,047h,018h,0feh,00ah,086h,004h,081h,002h,086h,008h,047h,008h,089h,008h,068h	; 5b64  .G.........G...h
	defb 004h,043h,081h,0f0h,003h,043h,008h,063h,004h,0f3h,081h,063h,003h,0f3h,00dh,0f8h	; 5b74  .C...C.c...c....
	defb 003h,0f1h,008h,0f8h,005h,086h,003h,081h,003h,098h,085h,081h,091h,091h,096h,091h	; 5b84  ................
	defb 007h,0f8h,001h,081h,008h,0f8h,007h,091h,001h,096h,008h,0f8h,008h,081h,007h,091h	; 5b94  ................
	defb 001h,096h,008h,081h,008h,098h,007h,096h,001h,090h,010h,098h,008h,0d9h,008h,098h	; 5ba4  ................
	defb 081h,0f8h,005h,0f9h,002h,098h,001h,0f8h,005h,0f9h,002h,098h,008h,098h,007h,096h	; 5bb4  ................
	defb 001h,090h,010h,098h,008h,0d9h,008h,098h,000h,000h,000h,040h,023h,027h,014h,009h	; 5bc4  ...........@#'..
	defb 007h,02ch,009h,019h,030h,031h,018h,00ch,000h,000h,000h,000h,0e0h,0f0h,008h,0f4h	; 5bd4  .,..01..........
	defb 0f8h,00ch,024h,024h,000h,020h,0c0h,000h,000h,000h,0e0h,0b0h,0d0h,058h,02bh,036h	; 5be4  ..$$. .......X+6
	defb 018h,013h,036h,026h,00fh,00eh,007h,003h,003h,000h,000h,000h,000h,000h,0f0h,008h	; 5bf4  ..6&............
	defb 004h,0f0h,0d8h,0d8h,0f8h,0d8h,038h,0f0h,0e0h,004h,006h,006h,007h,007h,000h,007h	; 5c04  ......8.........
	defb 007h,003h,000h,000h,000h,000h,000h,000h,000h,020h,020h,020h,060h,060h,000h,0e0h	; 5c14  .........   ``..
	defb 0e0h,0c0h,000h,000h,000h,000h,000h,000h,000h,003h,019h,039h,078h,0f0h,0e7h,000h	; 5c24  ...........9x...
	defb 000h,00ch,03eh,03ch,038h,01eh,000h,000h,000h,0c0h,0d8h,0dch,09fh,087h,0e0h,000h	; 5c34  ..><8...........
	defb 010h,030h,03ah,03eh,01eh,018h,000h,000h,000h,00bh,019h,01ch,01ch,00fh,000h,000h	; 5c44  .0:>............
	defb 000h,00fh,00fh,00bh,003h,000h,000h,000h,000h,0e0h,0c0h,0c0h,0d0h,0f8h,018h,000h	; 5c54  ................
	defb 000h,0c0h,080h,0c0h,0e0h,000h,000h,000h,000h,000h,00eh,00eh,00ch,00ch,00fh,007h	; 5c64  ................
	defb 006h,000h,003h,003h,003h,003h,000h,000h,000h,0c0h,060h,060h,060h,060h,0f8h,008h	; 5c74  ..........````..
	defb 000h,000h,0c0h,0c0h,0e0h,0f0h,000h,000h,000h,007h,001h,001h,003h,003h,000h,000h	; 5c84  ................
	defb 001h,003h,000h,000h,000h,000h,000h,000h,000h,020h,090h,090h,090h,090h,000h,0f0h	; 5c94  ......... ......
	defb 0f0h,0e0h,000h,000h,000h,000h,000h,000h,000h,003h,019h,039h,071h,061h,007h,018h	; 5ca4  ...........9qa..
	defb 0f8h,0fch,0c0h,080h,000h,000h,000h,000h,000h,0c3h,0dbh,09fh,09eh,08ch,0e0h,011h	; 5cb4  ................
	defb 01bh,03fh,01fh,006h,000h,000h,000h,000h,000h,003h,000h,006h,000h,00ch,000h,00ch	; 5cc4  .?..............
	defb 000h,00ch,001h,00dh,001h,00ch,000h,019h,034h,080h,000h,0c0h,000h,060h,000h,060h	; 5cd4  ........4....`.`
	defb 000h,0f8h,024h,054h,024h,0f8h,000h,004h,0f8h,000h,000h,000h,000h,000h,001h,006h	; 5ce4  ..$T$...........
	defb 000h,018h,000h,030h,000h,060h,000h,040h,0a0h,000h,000h,000h,000h,000h,000h,0c0h	; 5cf4  ...0.`.@........
	defb 000h,030h,000h,038h,03eh,049h,055h,049h,03eh,000h,01bh,009h,000h,001h,066h,005h	; 5d04  .0.8>IUI>.....f.
	defb 029h,001h,026h,009h,000h,001h,030h,005h,048h,001h,030h,009h,000h,087h,071h,08ah	; 5d14  ).&...0.H.0...q.
	defb 08ah,012h,022h,042h,0f9h,009h,000h,001h,08ch,005h,052h,081h,08ch,008h,000h,088h	; 5d24  .."B......R.....
	defb 040h,079h,042h,042h,07ah,00ah,04ah,079h,009h,000h,001h,08ch,005h,052h,081h,08ch	; 5d34  @yBBz.Jy.....R..
	defb 009h,000h,087h,031h,072h,0d2h,092h,0fah,012h,011h,009h,000h,001h,08ch,005h,052h	; 5d44  ...1r..........R
	defb 081h,08ch,009h,000h,087h,001h,005h,00fh,00dh,00fh,00dh,00eh,00ah,000h,086h,0a0h	; 5d54  ................
	defb 0f0h,0b0h,0f0h,0b0h,070h,003h,000h,089h,001h,003h,003h,000h,000h,006h,007h,007h	; 5d64  ....p...........
	defb 003h,004h,000h,08ch,007h,039h,071h,0f1h,0e1h,081h,00fh,00fh,078h,0f8h,0fch,0f8h	; 5d74  .....9q.....x...
	defb 004h,000h,08ch,0e0h,09ch,08eh,08fh,087h,081h,0f0h,0f0h,01eh,01fh,03fh,01fh,007h	; 5d84  .............?..
	defb 000h,089h,080h,0c0h,0c0h,000h,000h,060h,0e0h,0e0h,0c0h,004h,000h,010h,000h,090h	; 5d94  .......`........
	defb 03fh,079h,0f1h,0e1h,0e1h,071h,03fh,01fh,008h,018h,03ch,03eh,01ch,01ch,03ch,07dh	; 5da4  ?y...q?...<>..<}
	defb 009h,000h,087h,071h,08ah,082h,0f2h,08ah,08ah,071h,009h,000h,081h,08ch,005h,052h	; 5db4  ...q.....q.....R
	defb 081h,08ch,009h,000h,087h,062h,095h,015h,025h,015h,095h,062h,009h,000h,001h,022h	; 5dc4  .....b..%..b..."
	defb 005h,055h,081h,022h,009h,000h,087h,062h,095h,095h,015h,065h,085h,0f2h,009h,000h	; 5dd4  .U."...b...e....
	defb 001h,022h,005h,055h,081h,022h,009h,000h,001h,064h,005h,02ah,081h,024h,009h,000h	; 5de4  .".U."...d.*.$..
	defb 001h,044h,005h,0aah,081h,044h,004h,000h,088h,001h,006h,00fh,007h,00fh,00bh,007h	; 5df4  .D...D..........
	defb 002h,008h,000h,0b9h,0c0h,0c0h,0e0h,0e0h,0f0h,0f0h,0d0h,0e0h,0c0h,000h,000h,000h	; 5e04  ................
	defb 006h,00dh,01eh,02fh,037h,07fh,07fh,07fh,03fh,06fh,07fh,0ffh,0ffh,0b5h,07bh,034h	; 5e14  .../7...?o....{4
	defb 030h,078h,0bch,0fch,0fah,0ffh,0ffh,0feh,0f4h,0feh,0ffh,0ffh,0ffh,0fah,0bch,078h	; 5e24  0x.............x
	defb 000h,000h,01bh,037h,07fh,03fh,0ffh,0ffh,05fh,03fh,01fh,00fh,007h,005h,000h,0aeh	; 5e34  ...7.?.._?......
	defb 01ch,0beh,0ffh,0ffh,0f3h,0e9h,0edh,0f3h,0feh,0f5h,07bh,07fh,03eh,01ch,000h,000h	; 5e44  ..........{.>...
	defb 070h,0f8h,0fdh,0ffh,0cfh,097h,0b7h,0cfh,07fh,0afh,0dfh,07eh,038h,000h,000h,000h	; 5e54  p..........~8...
	defb 018h,0bch,0feh,0feh,0ffh,0ffh,0ffh,0feh,0f4h,0b8h,050h,000h,000h,000h,084h,000h	; 5e64  ..........P.....
	defb 000h,001h,003h,00ch,007h,084h,000h,000h,0c0h,0e0h,00ch,0f0h,090h,0fch,09eh,08fh	; 5e74  ................
	defb 087h,087h,08eh,0fch,0f8h,010h,018h,03ch,07ch,038h,038h,03ch,03eh,010h,000h,082h	; 5e84  .......<|88<>...
	defb 000h,006h,004h,00eh,002h,000h,083h,007h,007h,003h,006h,000h,081h,060h,004h,070h	; 5e94  .............`.p
	defb 002h,000h,083h,0e0h,0e0h,0c0h,005h,000h,007h,000h,089h,003h,007h,01fh,01eh,01dh	; 5ea4  ................
	defb 01fh,00ch,00fh,007h,007h,000h,089h,0c0h,0e0h,0f8h,038h,0f8h,0b8h,070h,0f0h,0e0h	; 5eb4  ..........8..p..
	defb 0a0h,000h,000h,060h,0f0h,0f9h,0fbh,073h,077h,079h,07eh,03ch,03dh,01fh,019h,001h	; 5ec4  ...`...swy~<=...
	defb 001h,002h,00ah,00ah,002h,08ch,0fch,0feh,0feh,09eh,07eh,03eh,0bch,0fch,098h,080h	; 5ed4  ..........~>....
	defb 080h,004h,000h,09ch,019h,03fh,07fh,07fh,07dh,07bh,07eh,03dh,03fh,019h,001h,001h	; 5ee4  .....?..}{~=?...
	defb 002h,002h,006h,00fh,09fh,0dfh,0ceh,0eeh,0beh,0deh,07ch,0bch,0f8h,098h,080h,080h	; 5ef4  ..........|.....
	defb 005h,000h,082h,007h,00fh,007h,01fh,08bh,00fh,007h,000h,000h,000h,004h,004h,0e4h	; 5f04  ................
	defb 0f4h,0f8h,0fch,005h,0f8h,082h,0f0h,0e0h,088h,007h,00fh,00fh,00fh,000h,007h,007h	; 5f14  ................
	defb 003h,008h,000h,088h,0e0h,0f0h,0f0h,0f0h,000h,0e0h,0e0h,0c0h,008h,000h,005h,000h	; 5f24  ................
	defb 09bh,010h,01fh,0afh,0e0h,060h,0e0h,0f0h,0f8h,078h,030h,000h,002h,00ah,00ah,002h	; 5f34  .....`...x0.....
	defb 004h,00ch,0f8h,0f0h,000h,000h,000h,00ch,01eh,01eh,00eh,00ch,088h,000h,07fh,0f8h	; 5f44  ................
	defb 0f8h,07ch,01ch,078h,0f8h,009h,000h,08bh,0f0h,010h,018h,038h,078h,07ch,03ch,01ch	; 5f54  .|.x.......8x|<.
	defb 01ch,01eh,01fh,004h,000h,005h,000h,09bh,010h,01fh,00fh,000h,000h,000h,018h,078h	; 5f64  ...............x
	defb 078h,070h,030h,002h,00ah,00ah,002h,004h,008h,0f8h,0f5h,007h,006h,007h,00fh,01fh	; 5f74  xp0.............
	defb 01eh,00ch,000h,08ch,000h,00fh,008h,018h,01ch,01eh,03eh,03ch,038h,038h,078h,0f8h	; 5f84  ..........><88x.
	defb 005h,000h,087h,0feh,01fh,01fh,03eh,038h,01eh,01fh,008h,000h,08ch,000h,000h,001h	; 5f94  ......>8........
	defb 001h,010h,001h,003h,000h,002h,000h,003h,002h,004h,000h,08ch,004h,004h,084h,084h	; 5fa4  ................
	defb 008h,084h,0c0h,000h,040h,000h,0c0h,040h,004h,000h,090h,000h,01fh,01eh,00eh,00fh	; 5fb4  ....@..@........
	defb 01eh,01ch,03fh,03dh,03fh,03ch,03dh,01fh,019h,011h,001h,090h,002h,0fah,07ah,072h	; 5fc4  ..?=?<=.......zr
	defb 0f4h,078h,038h,0f8h,0bch,0fch,03ch,0bch,0f8h,098h,088h,080h,005h,000h,09bh,010h	; 5fd4  .x8...<.........
	defb 01fh,00fh,020h,060h,0e0h,0f0h,0f8h,078h,030h,0c0h,002h,00ah,00ah,00ah,004h,008h	; 5fe4  .. `...x0.......
	defb 0f8h,0f0h,004h,006h,007h,00fh,01fh,01eh,00ch,003h,089h,0f0h,07fh,078h,038h,01ch	; 5ff4  .............x8.
	defb 00eh,006h,006h,002h,007h,000h,089h,00fh,0feh,01eh,01ch,038h,070h,060h,060h,040h	; 6004  ...........8p``@
	defb 007h,000h,08ch,000h,000h,007h,00fh,000h,01fh,01ch,008h,00ah,000h,002h,001h,006h	; 6014  ................
	defb 000h,08ah,0e0h,0f0h,000h,0f8h,038h,010h,050h,000h,040h,080h,004h,000h,0a0h,000h	; 6024  ......8.P.@.....
	defb 078h,070h,070h,0ffh,0e0h,0e3h,0f7h,0f5h,07fh,07dh,03eh,03fh,019h,011h,001h,000h	; 6034  xpp......}>?....
	defb 01eh,00eh,00eh,0ffh,007h,0c7h,0efh,0afh,0feh,0beh,07ch,0fch,098h,088h,080h,020h	; 6044  ..........|.... 
	defb 000h,082h,001h,003h,003h,000h,09bh,010h,03fh,02fh,060h,060h,060h,070h,038h,018h	; 6054  ........?/```p8.
	defb 010h,000h,082h,0cah,00ah,002h,004h,008h,0fch,0f4h,006h,006h,006h,00eh,01ch,01ch	; 6064  ................
	defb 008h,000h,08ch,000h,00fh,018h,038h,03ch,01eh,01ch,00eh,00eh,007h,003h,003h,005h	; 6074  ......8<........
	defb 000h,08bh,0f0h,018h,01ch,03ch,078h,038h,070h,070h,0e0h,0c0h,0c0h,004h,000h,09eh	; 6084  .....<x8pp......
	defb 003h,006h,00ch,01fh,003h,007h,00fh,01eh,03fh,07fh,0ffh,00fh,01fh,03fh,07fh,0feh	; 6094  ........?....?..
	defb 000h,000h,000h,0e0h,0c0h,080h,000h,000h,0fch,0f8h,0f0h,0e0h,0c0h,080h,002h,000h	; 60a4  ................
	defb 083h,008h,008h,00ch,006h,00fh,001h,003h,006h,000h,083h,010h,010h,030h,006h,0f0h	; 60b4  .............0..
	defb 001h,0c0h,006h,000h,000h	; 60c4

; ======================================================================
; CODIGO 0x60c9..0x617a  (177 bytes)
; ======================================================================


L_60C9:
	ld hl,05445h		;60c9
	call L_449B		;60cc
	ld hl,05937h		;60cf
	call L_612C		;60d2
	call L_4473		;60d5
	ld de,01800h		;60d8
	ld hl,05bcdh		;60db
	ld bc,00140h		;60de
	call L_4441		;60e1
	ld de,05bcdh		;60e4
	ld hl,05bddh		;60e7
	ld b,00ah		;60ea
	ld ix,0e0b0h		;60ec
L_60F0:
	push bc			;60f0
	ld b,010h		;60f1
L_60F3:
	ld a,(de)			;60f3
	exx			;60f4
	ld h,a			;60f5
	exx			;60f6
	ld a,(hl)			;60f7
	exx			;60f8
	ld l,a			;60f9
	ld b,010h		;60fa
L_60FC:
	add hl,hl			;60fc
	rr (ix+000h)		;60fd
	rr (ix+010h)		;6101
	djnz L_60FC		;6105
	exx			;6107
	inc hl			;6108
	inc de			;6109
	inc ix		;610a
	djnz L_60F3		;610c
	ld c,010h		;610e
	add hl,bc			;6110
	ex de,hl			;6111
	add hl,bc			;6112
	ex de,hl			;6113
	add ix,bc		;6114
	pop bc			;6116
	djnz L_60F0		;6117
	ld de,01940h		;6119
	ld hl,0e0b0h		;611c
	ld bc,00140h		;611f
	call L_4441		;6122
	ld hl,05d0dh		;6125
	call L_449B		;6128
	ret			;612b
L_612C:
	ld e,(hl)			;612c
	inc hl			;612d
	ld d,(hl)			;612e
	inc hl			;612f
	ld a,(0e05dh)		;6130
	ld c,a			;6133
	di			;6134
	call L_44BE		;6135
	ld a,c			;6138
	and 0f0h		;6139
	ld d,a			;613b
	ld a,c			;613c
	and 00fh		;613d
	ld e,a			;613f
L_6140:
	ld a,(hl)			;6140
	and 07fh		;6141
	ld b,a			;6143
	ld a,(hl)			;6144
	inc hl			;6145
	jr nz,L_614D		;6146
	cp b			;6148
	jr nz,L_612C		;6149
	ei			;614b
	ret			;614c
L_614D:
	cp b			;614d
L_614E:
	ex af,af'			;614e
	ld a,0f0h		;614f
	and (hl)			;6151
	cp 030h		;6152
	jr nz,L_6157		;6154
	ld a,d			;6156
L_6157:
	ld c,a			;6157
	ld a,00fh		;6158
	and (hl)			;615a
	cp 003h		;615b
	jr nz,L_6160		;615d
	ld a,e			;615f
L_6160:
	or c			;6160
	exx			;6161
	out (c),a		;6162
	exx			;6164
	ex af,af'			;6165
	jr z,L_6169		;6166
	inc hl			;6168
L_6169:
	djnz L_614E		;6169
	jr nz,L_616E		;616b
	inc hl			;616d
L_616E:
	jr L_6140		;616e
L_6170:
	ld a,(0e1b2h)		;6170
	ld hl,061a0h		;6173
	push hl			;6176
	call L_404A		;6177

; ----------------------------------------------------------------------
; DATOS sin identificar  0x617a..0x61a3  (41 bytes)
DATA_617A:
	defb 0bfh,061h,00bh,063h,0e4h,061h,00bh,063h,0c3h,063h,0e1h,063h,057h,069h,04fh,06ah	; 617a  .a.c.a.c.c.cWiOj
	defb 02ah,073h,04bh,073h,07ah,073h,07ah,073h,095h,073h,027h,074h,046h,074h,066h,074h	; 618a  *sKszszs.s'tFtft
	defb 0f8h,074h,034h,075h,041h,075h,0c3h,084h,065h	; 619a  .t4uAu..e

; ======================================================================
; CODIGO 0x61a3..0x61de  (59 bytes)
; ======================================================================


L_61A3:
	ld hl,(0e1b3h)		;61a3
	ld bc,00408h		;61a6
	add hl,bc			;61a9
	call L_4992		;61aa
	ld hl,0e1bfh		;61ad
	ld b,002h		;61b0
L_61B2:
	call L_4019		;61b2
	ld (hl),a			;61b5
	inc hl			;61b6
	ld a,020h		;61b7
	call L_4027		;61b9
	djnz L_61B2		;61bc
	ret			;61be
L_61BF:
	call L_6490		;61bf
	call L_64B7		;61c2
	jp nz,L_62DB		;61c5
	ld a,(0e009h)		;61c8
	rra			;61cb
	ret nc			;61cc
	call L_6A03		;61cd
	ret nc			;61d0
	call L_69E7		;61d1
	ret nc			;61d4
	ld a,(0e1d1h)		;61d5
	cp 00ah		;61d8
	ret nz			;61da
	jp L_62B0		;61db

; ----------------------------------------------------------------------
; DATOS sin identificar  0x61de..0x61e4  (6 bytes)
DATA_61DE:
	defb 001h,002h,003h,005h,006h,007h	; 61de

; ======================================================================
; CODIGO 0x61e4..0x6485  (673 bytes)
; ======================================================================


L_61E4:
	call L_66AF		;61e4
	jp nc,L_62E6		;61e7
	ld a,(0e009h)		;61ea
	and 00ch		;61ed
	jp z,L_6287		;61ef
	ld hl,0e134h		;61f2
	ld b,028h		;61f5
L_61F7:
	push bc			;61f7
	push hl			;61f8
	ld a,(hl)			;61f9
	sub 0c5h		;61fa
	cp 006h		;61fc
	jr nc,L_6219		;61fe
	dec hl			;6200
	dec hl			;6201
	ld a,(hl)			;6202
	cp 0d0h		;6203
	jr z,L_6219		;6205
	ld bc,(0e1b3h)		;6207
	sub c			;620b
	cp 018h		;620c
	jr nc,L_6219		;620e
	inc hl			;6210
	ld a,(hl)			;6211
	add a,008h		;6212
	sub b			;6214
	cp 010h		;6215
	jr c,L_6223		;6217
L_6219:
	pop hl			;6219
	pop bc			;621a
	inc hl			;621b
	inc hl			;621c
	inc hl			;621d
	djnz L_61F7		;621e
	jp L_6287		;6220
L_6223:
	pop hl			;6223
	pop bc			;6224
	dec hl			;6225
	dec hl			;6226
	push hl			;6227
	call L_6FA2		;6228
	pop hl			;622b
	ld c,(hl)			;622c
	ld (hl),0d0h		;622d
	inc hl			;622f
	ld b,(hl)			;6230
	inc hl			;6231
	ld a,(hl)			;6232
	ld d,a			;6233
	sub 0c5h		;6234
	cp 003h		;6236
	ld a,d			;6238
	jr nc,L_6241		;6239
	ld hl,0e05fh		;623b
	dec (hl)			;623e
	jr L_627B		;623f
L_6241:
	push af			;6241
	push bc			;6242
	ld b,a			;6243
	ld de,(0e05ah)		;6244
	ld a,0b8h		;6248
	sub c			;624a
	and 0f8h		;624b
	rrca			;624d
	rrca			;624e
	rrca			;624f
	ld c,a			;6250
	ld a,(0e059h)		;6251
	add a,c			;6254
L_6255:
	ex af,af'			;6255
	call L_4019		;6256
	ld c,a			;6259
	ex af,af'			;625a
	sub c			;625b
	jr z,L_6263		;625c
	inc de			;625e
	inc de			;625f
	inc de			;6260
	jr L_6255		;6261
L_6263:
	inc de			;6263
	call L_4019		;6264
	cp b			;6267
	jr nz,L_6271		;6268
	ld a,0cbh		;626a
	call L_4010		;626c
	jr L_6279		;626f
L_6271:
	inc de			;6271
	inc de			;6272
	call L_4019		;6273
	or a			;6276
	jr z,L_6263		;6277
L_6279:
	pop bc			;6279
	pop af			;627a
L_627B:
	sub 0c5h		;627b
	ld hl,061deh		;627d
	call L_4022		;6280
	ld a,(hl)			;6283
	call L_79A4		;6284
L_6287:
	call L_6490		;6287
	call L_64B7		;628a
	jr nz,L_62DB		;628d
	call L_645B		;628f
	ret z			;6292
	push af			;6293
	call L_6A03		;6294
	jr nc,L_62CF		;6297
	call L_69E7		;6299
	jr nc,L_62CF		;629c
	pop af			;629e
	rra			;629f
	jr c,L_62BA		;62a0
	ld a,(0e1d9h)		;62a2
	ld hl,0e1b3h		;62a5
	sub (hl)			;62a8
	cp 024h		;62a9
	jr nc,L_62D3		;62ab
	call L_62F6		;62ad
L_62B0:
	ld a,006h		;62b0
	ld (0e1b5h),a		;62b2
	ld a,006h		;62b5
	jp L_6486		;62b7
L_62BA:
	ld hl,(0e1b3h)		;62ba
	ld a,l			;62bd
	sub 008h		;62be
	ld l,a			;62c0
	ld a,h			;62c1
	add a,004h		;62c2
	ld h,a			;62c4
	call L_498C		;62c5
	sub 078h		;62c8
	cp 003h		;62ca
	jr c,L_62B0		;62cc
	ret			;62ce
L_62CF:
	pop af			;62cf
	bit 1,a		;62d0
	ret z			;62d2
L_62D3:
	call L_62F6		;62d3
	ld a,005h		;62d6
	jp L_6486		;62d8
L_62DB:
	ld hl,06572h		;62db
L_62DE:
	call L_654E		;62de
	ld a,003h		;62e1
	jp L_6486		;62e3
L_62E6:
	ld hl,06572h		;62e6
	call L_6558		;62e9
	ld a,005h		;62ec
	call L_7A13		;62ee
	ld a,004h		;62f1
	jp L_6486		;62f3
L_62F6:
	ld b,004h		;62f6
L_62F8:
	push bc			;62f8
	ld a,008h		;62f9
	call L_670A		;62fb
	call L_6584		;62fe
	call L_52A2		;6301
	call L_63AC		;6304
	pop bc			;6307
	djnz L_62F8		;6308
	ret			;630a
L_630B:
	call L_64C1		;630b
	call L_6465		;630e
	jr z,L_6373		;6311
	ld a,(0e1c7h)		;6313
	or a			;6316
	jr z,L_638E		;6317
	call L_63AC		;6319
	ld hl,(0e1b3h)		;631c
	ld bc,00018h		;631f
	add hl,bc			;6322
	call L_6665		;6323
	jr nc,L_6359		;6326
	ld a,002h		;6328
	call L_7A13		;632a
	ld a,(0e1c8h)		;632d
	or a			;6330
	jp m,L_6344		;6331
L_6334:
	ld a,(0e1cbh)		;6334
	sub 020h		;6337
	call L_6706		;6339
	call L_6368		;633c
	ld a,002h		;633f
	jp L_6486		;6341
L_6344:
	ld bc,(0e054h)		;6344
	ld hl,(0e1bah)		;6348
	sbc hl,bc		;634b
	ld bc,00080h		;634d
	sbc hl,bc		;6350
	jr c,L_6334		;6352
	ld a,004h		;6354
	jp L_6486		;6356
L_6359:
	ld hl,0e1b3h		;6359
	ld a,098h		;635c
	sub (hl)			;635e
	ret nc			;635f
	call L_670A		;6360
	ld a,000h		;6363
	jp L_6486		;6365
L_6368:
	ld a,(0e1b3h)		;6368
	cp 048h		;636b
	ret nc			;636d
	call L_6470		;636e
	jr L_6368		;6371
L_6373:
	call L_6368		;6373
	ld a,002h		;6376
	call L_7A13		;6378
	ld hl,0e1b4h		;637b
	ld a,(hl)			;637e
	add a,004h		;637f
	and 0f8h		;6381
	sub 004h		;6383
	ld (hl),a			;6385
	inc hl			;6386
	ld (hl),00ah		;6387
	ld a,007h		;6389
	jp L_6486		;638b
L_638E:
	ld a,(0e1beh)		;638e
	neg		;6391
	cp 005h		;6393
	ret c			;6395
L_6396:
	ld hl,0e1b3h		;6396
	ld a,048h		;6399
	sub (hl)			;639b
	ret c			;639c
	cp 008h		;639d
	ret c			;639f
	ld a,(0e1abh)		;63a0
	rra			;63a3
	ret c			;63a4
	ld a,(hl)			;63a5
	add a,008h		;63a6
	ld (hl),a			;63a8
	jp L_672E		;63a9
L_63AC:
	ld hl,0e1b3h		;63ac
	ld a,(hl)			;63af
	sub 088h		;63b0
	ret c			;63b2
	cp 008h		;63b3
	ret c			;63b5
	ld a,(0e1abh)		;63b6
	bit 1,a		;63b9
	ret nz			;63bb
	ld a,(hl)			;63bc
	sub 008h		;63bd
	ld (hl),a			;63bf
	jp L_6732		;63c0
L_63C3:
	call L_64C5		;63c3
	call L_63AC		;63c6
	ld hl,(0e1b3h)		;63c9
	call L_6665		;63cc
	jr nc,L_6359		;63cf
	ld a,(0e1cbh)		;63d1
	call L_6706		;63d4
	ld a,006h		;63d7
	call L_7A13		;63d9
	ld a,005h		;63dc
	jp L_6486		;63de
L_63E1:
	ld a,(0e009h)		;63e1
	ld (0e1b7h),a		;63e4
	call L_66AF		;63e7
	jp nc,L_62E6		;63ea
	ld a,(0e003h)		;63ed
	rra			;63f0
	call c,L_6490		;63f1
	ld a,(0e009h)		;63f4
	and 00ch		;63f7
	jr z,L_6400		;63f9
	ld a,002h		;63fb
	call L_7A13		;63fd
L_6400:
	ld a,(0e1b8h)		;6400
	bit 2,a		;6403
	ld b,008h		;6405
	jr nz,L_6410		;6407
	ld a,(0e009h)		;6409
	or a			;640c
	jr z,L_6410		;640d
	inc b			;640f
L_6410:
	ld a,b			;6410
	ld (0e1b5h),a		;6411
	call L_645B		;6414
	ret z			;6417
	rra			;6418
	jr nc,L_6434		;6419
	ld b,004h		;641b
L_641D:
	push bc			;641d
	ld a,0f8h		;641e
	call L_670A		;6420
	call L_6584		;6423
	call L_52A2		;6426
	call L_6396		;6429
	pop bc			;642c
	djnz L_641D		;642d
	ld a,002h		;642f
	jp L_6486		;6431
L_6434:
	call L_6A03		;6434
	jr nc,L_644A		;6437
	call L_69E7		;6439
	jr nc,L_644A		;643c
	ld a,(0e1d9h)		;643e
	ld hl,0e1b3h		;6441
	cp (hl)			;6444
	jr nz,L_644A		;6445
	jp L_62B0		;6447
L_644A:
	call L_6465		;644a
	jp z,L_6373		;644d
	ld hl,06572h		;6450
	call L_6558		;6453
	ld a,003h		;6456
	jp L_6486		;6458
L_645B:
	ld hl,0e008h		;645b
	ld a,(hl)			;645e
	cpl			;645f
	and 003h		;6460
	inc hl			;6462
	and (hl)			;6463
	ret			;6464
L_6465:
	call L_61A3		;6465
	ld a,09bh		;6468
	dec hl			;646a
	cp (hl)			;646b
	ret z			;646c
	dec hl			;646d
	cp (hl)			;646e
	ret			;646f
L_6470:
	ld hl,0e1b3h		;6470
	ld a,(hl)			;6473
	add a,008h		;6474
	ld (hl),a			;6476
	call L_6584		;6477
	call L_52A2		;647a
	call L_672E		;647d
	ld hl,0e1b3h		;6480
	ld a,(hl)			;6483
	ret			;6484

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6485..0x6486  (1 bytes)
DATA_6485:
	defb 0afh	; 6485

; ======================================================================
; CODIGO 0x6486..0x6571  (235 bytes)
; ======================================================================


L_6486:
	ld hl,0e1b2h		;6486
	ld (hl),a			;6489
	ret			;648a
L_648B:
	ld hl,0e1b2h		;648b
	inc (hl)			;648e
	ret			;648f
L_6490:
	ld a,(0e009h)		;6490
	and 00ch		;6493
	ld (0e1b6h),a		;6495
	ld hl,0e1b4h		;6498
	ld de,0e1b8h		;649b
	jr z,L_64B3		;649e
	ex de,hl			;64a0
	inc (hl)			;64a1
	ex de,hl			;64a2
	ld (0e1b7h),a		;64a3
	ld c,001h		;64a6
	call L_6530		;64a8
	ld a,(de)			;64ab
	and 00ch		;64ac
	rrca			;64ae
	rrca			;64af
L_64B0:
	inc hl			;64b0
	ld (hl),a			;64b1
	ret			;64b2
L_64B3:
	ld a,003h		;64b3
	jr L_64B0		;64b5
L_64B7:
	ld hl,0e008h		;64b7
	ld a,(hl)			;64ba
	cpl			;64bb
	and 030h		;64bc
	inc hl			;64be
	and (hl)			;64bf
	ret			;64c0
L_64C1:
	ld c,002h		;64c1
	jr L_64C7		;64c3
L_64C5:
	ld c,001h		;64c5
L_64C7:
	ld a,(0e1c7h)		;64c7
	ld b,a			;64ca
	ld hl,0e1c8h		;64cb
	bit 0,b		;64ce
	jr nz,L_64D5		;64d0
	inc (hl)			;64d2
	jr L_64D6		;64d3
L_64D5:
	dec (hl)			;64d5
L_64D6:
	ld a,(hl)			;64d6
	cp 008h		;64d7
	ld a,003h		;64d9
	jr c,L_64DF		;64db
	ld a,005h		;64dd
L_64DF:
	ld (0e1b5h),a		;64df
	ld hl,0e1b3h		;64e2
	ld de,(0e1c9h)		;64e5
	ld a,(de)			;64e9
	bit 0,b		;64ea
	jr nz,L_64F0		;64ec
	neg		;64ee
L_64F0:
	push bc			;64f0
	ld c,a			;64f1
	add a,(hl)			;64f2
	cp 018h		;64f3
	jr nc,L_64FA		;64f5
	ld a,(hl)			;64f7
	ld c,000h		;64f8
L_64FA:
	ld (hl),a			;64fa
	inc hl			;64fb
	ld a,c			;64fc
	ld (0e1beh),a		;64fd
	pop bc			;6500
	bit 0,b		;6501
	jr z,L_6507		;6503
	ld c,001h		;6505
L_6507:
	neg		;6507
	push hl			;6509
	push de			;650a
	call L_6713		;650b
	pop de			;650e
	pop hl			;650f
	call L_6530		;6510
	bit 0,b		;6513
	jr nz,L_651A		;6515
	inc de			;6517
	jr L_651B		;6518
L_651A:
	dec de			;651a
L_651B:
	ld a,(de)			;651b
	inc a			;651c
	jr nz,L_652A		;651d
	dec de			;651f
	dec de			;6520
	inc a			;6521
	ld (0e1c7h),a		;6522
L_6525:
	ld (0e1c9h),de		;6525
	ret			;6529
L_652A:
	inc a			;652a
	jr nz,L_6525		;652b
	inc de			;652d
	jr L_6525		;652e
L_6530:
	ld a,(0e1b6h)		;6530
	or a			;6533
	ret z			;6534
	bit 3,a		;6535
	ld a,(hl)			;6537
	push hl			;6538
	ld hl,0e057h		;6539
	jr z,L_6545		;653c
	add a,c			;653e
	cp (hl)			;653f
	jr c,L_6543		;6540
	sub c			;6542
L_6543:
	jr L_654B		;6543
L_6545:
	sub c			;6545
	inc hl			;6546
	cp (hl)			;6547
	jr nc,L_654B		;6548
	add a,c			;654a
L_654B:
	pop hl			;654b
	ld (hl),a			;654c
	ret			;654d
L_654E:
	push hl			;654e
	ld a,003h		;654f
	call L_7A13		;6551
	pop hl			;6554
	xor a			;6555
	jr L_655A		;6556
L_6558:
	ld a,001h		;6558
L_655A:
	ld (0e1c9h),hl		;655a
	ld (0e1c7h),a		;655d
	xor a			;6560
	ld (0e1c8h),a		;6561
	ld a,(0e1b3h)		;6564
	ld (0e1b9h),a		;6567
	ld hl,(0e054h)		;656a
	ld (0e1bah),hl		;656d
	ret			;6570

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6571..0x6584  (19 bytes)
DATA_6571:
	defb 0feh,008h,008h,008h,004h,004h,002h,002h,002h,002h,002h,001h,001h,001h,000h,000h	; 6571  ................
	defb 000h,000h,0ffh	; 6581

; ======================================================================
; CODIGO 0x6584..0x65ff  (123 bytes)
; ======================================================================


L_6584:
	ld hl,0e1b3h		;6584
	ld b,(hl)			;6587
	ld a,(0e1b2h)		;6588
	cp 005h		;658b
	jr z,L_659D		;658d
	cp 00fh		;658f
	jr nc,L_65D7		;6591
	inc b			;6593
	inc b			;6594
	inc b			;6595
	inc b			;6596
	sub 006h		;6597
	cp 006h		;6599
	jr nc,L_65A2		;659b
L_659D:
	ld a,008h		;659d
	ld (0e1b7h),a		;659f
L_65A2:
	inc hl			;65a2
	ld c,(hl)			;65a3
	inc hl			;65a4
	ld a,(hl)			;65a5
	bit 0,a		;65a6
	jr z,L_65AB		;65a8
	inc b			;65aa
L_65AB:
	ld de,065ffh		;65ab
	add a,a			;65ae
	add a,a			;65af
	call L_4027		;65b0
	ld hl,0e0d0h		;65b3
	call L_664C		;65b6
	ld a,010h		;65b9
	add a,b			;65bb
	ld b,a			;65bc
	call L_664C		;65bd
	ld (hl),0c3h		;65c0
	ld a,(0e1b5h)		;65c2
	cp 006h		;65c5
	ret c			;65c7
	ld hl,0e0d4h		;65c8
	ld a,(hl)			;65cb
	sub 003h		;65cc
	ld (hl),a			;65ce
	ld hl,0e0dch		;65cf
	ld a,(hl)			;65d2
	sub 003h		;65d3
	ld (hl),a			;65d5
	ret			;65d6
L_65D7:
	inc b			;65d7
	inc b			;65d8
	inc hl			;65d9
	ld c,(hl)			;65da
	inc hl			;65db
	ld a,(hl)			;65dc
	add a,a			;65dd
	add a,a			;65de
	add a,(hl)			;65df
	ld de,06638h		;65e0
	call L_4027		;65e3
	ld hl,0e0d0h		;65e6
	call L_664C		;65e9
	ld a,010h		;65ec
	add a,b			;65ee
	ld b,a			;65ef
	call L_664C		;65f0
	ld a,c			;65f3
	sub 008h		;65f4
	ld (0e0d9h),a		;65f6
	ld a,c			;65f9
	add a,008h		;65fa
	ld c,a			;65fc
	jr $+82		;65fd

; ----------------------------------------------------------------------
; DATOS sin identificar  0x65ff..0x664c  (77 bytes)
DATA_65FF:
	defb 004h,000h,00ch,008h,004h,000h,010h,008h,004h,000h,014h,018h,004h,000h,014h,018h	; 65ff  ................
	defb 000h,000h,000h,000h,004h,000h,01ch,008h,0c0h,0b8h,0c4h,0bch,0c8h,0b8h,0cch,0bch	; 660f  ................
	defb 0d4h,0b8h,0c4h,0bch,0e4h,0b8h,0cch,0bch,0ech,0b8h,0f0h,0bch,0d8h,0b8h,0dch,0bch	; 661f  ................
	defb 0b0h,0b8h,0c4h,0bch,0b4h,0b8h,0cch,0bch,0e8h,004h,000h,07ch,0a8h,0a4h,004h,000h	; 662f  ...........|....
	defb 074h,0a8h,0a4h,004h,000h,07ch,0a8h,078h,004h,000h,074h,0a8h,078h	; 663f  t....|.x..t.x

; ======================================================================
; CODIGO 0x664c..0x66e7  (155 bytes)
; ======================================================================


L_664C:
	call L_664F		;664c
L_664F:
	ld (hl),b			;664f
	inc hl			;6650
	ld (hl),c			;6651
	inc hl			;6652
	ld a,(0e1b7h)		;6653
	bit 3,a		;6656
	ld a,(de)			;6658
	jr nz,L_6660		;6659
	ld a,028h		;665b
	ex de,hl			;665d
	add a,(hl)			;665e
	ex de,hl			;665f
L_6660:
	ld (hl),a			;6660
	inc de			;6661
	inc hl			;6662
	inc hl			;6663
	ret			;6664
L_6665:
	ex de,hl			;6665
	ld hl,0e132h		;6666
	ld b,028h		;6669
L_666B:
	push bc			;666b
	push hl			;666c
	ld a,(hl)			;666d
	cp 0d0h		;666e
	jr z,L_6679		;6670
	inc hl			;6672
	inc hl			;6673
	ld a,(hl)			;6674
	and 0f0h		;6675
	jr z,L_6682		;6677
L_6679:
	pop hl			;6679
	pop bc			;667a
	inc hl			;667b
	inc hl			;667c
	inc hl			;667d
	djnz L_666B		;667e
	and a			;6680
	ret			;6681
L_6682:
	dec hl			;6682
	dec hl			;6683
	push de			;6684
	call L_66A5		;6685
	pop de			;6688
	ld a,e			;6689
	sub (hl)			;668a
	cp 009h		;668b
	jr nc,L_6679		;668d
	inc hl			;668f
	ld a,d			;6690
	sub (hl)			;6691
	add a,008h		;6692
	cp c			;6694
	jr nc,L_6679		;6695
	ld a,c			;6697
	pop hl			;6698
	pop bc			;6699
	ld de,0e1cbh		;669a
	ld bc,00003h		;669d
	ldir		;66a0
	ld (de),a			;66a2
	scf			;66a3
	ret			;66a4
L_66A5:
	call L_4A0E		;66a5
	ld a,c			;66a8
	add a,a			;66a9
	add a,a			;66aa
	add a,a			;66ab
	inc a			;66ac
	ld c,a			;66ad
	ret			;66ae
L_66AF:
	ld a,(0e1b4h)		;66af
	ld hl,0e1cch		;66b2
	sub (hl)			;66b5
	add a,008h		;66b6
	inc hl			;66b8
	inc hl			;66b9
	cp (hl)			;66ba
	ret			;66bb
L_66BC:
	ld hl,066e7h		;66bc
	call L_4062		;66bf
L_66C2:
	ld hl,(0e054h)		;66c2
	srl h		;66c5
	rr l		;66c7
	srl h		;66c9
	rr l		;66cb
	srl h		;66cd
	rr l		;66cf
	srl h		;66d1
	rr l		;66d3
	call L_66F5		;66d5
	ld (0e1bch),de		;66d8
	ld hl,0e1bdh		;66dc
	ld de,0385ah		;66df
L_66E2:
	ld b,002h		;66e2
	jp L_438D		;66e4

; ----------------------------------------------------------------------
; DATOS sin identificar  0x66e7..0x66f5  (14 bytes)
DATA_66E7:
	defb 053h,038h,048h,045h,049h,047h,048h,054h,040h,0feh,05eh,038h,018h,0ffh	; 66e7  S8HEIGHT@.^8..

; ======================================================================
; CODIGO 0x66f5..0x6a42  (845 bytes)
; ======================================================================


L_66F5:
	ld b,010h		;66f5
	ld de,00000h		;66f7
L_66FA:
	add hl,hl			;66fa
	ld a,e			;66fb
	adc a,a			;66fc
	daa			;66fd
	ld e,a			;66fe
	ld a,d			;66ff
	adc a,a			;6700
	daa			;6701
	ld d,a			;6702
	djnz L_66FA		;6703
	ret			;6705
L_6706:
	ld hl,0e1b3h		;6706
	sub (hl)			;6709
L_670A:
	push af			;670a
	ld hl,0e1b3h		;670b
	add a,(hl)			;670e
	ld (hl),a			;670f
	pop af			;6710
	neg		;6711
L_6713:
	ld hl,(0e054h)		;6713
	ld d,000h		;6716
	ld e,a			;6718
	or a			;6719
	jp p,L_6729		;671a
	neg		;671d
	ld e,a			;671f
	and a			;6720
	sbc hl,de		;6721
	jr nc,L_672A		;6723
	ld h,d			;6725
	ld l,d			;6726
	jr L_672A		;6727
L_6729:
	add hl,de			;6729
L_672A:
	ld (0e054h),hl		;672a
	ret			;672d
L_672E:
	ld a,001h		;672e
	jr L_6734		;6730
L_6732:
	ld a,002h		;6732
L_6734:
	ld hl,0e1aah		;6734
	ld (hl),a			;6737
	inc hl			;6738
	or a			;6739
	ret z			;673a
	and (hl)			;673b
	ld (hl),a			;673c
	or a			;673d
	jr z,L_6744		;673e
	dec hl			;6740
	ld (hl),000h		;6741
	ret			;6743
L_6744:
	dec hl			;6744
	ld a,(hl)			;6745
	rra			;6746
	jr nc,L_678F		;6747
L_6749:
	ld hl,0e1c4h		;6749
	ld de,(0e1c5h)		;674c
	inc (hl)			;6750
	call L_4019		;6751
	cp (hl)			;6754
	jr nz,L_6768		;6755
	inc de			;6757
	call L_4019		;6758
	cp 0ffh		;675b
	jr z,L_6788		;675d
	ld (hl),000h		;675f
	call L_67EC		;6761
	ld (0e1c5h),de		;6764
L_6768:
	call L_6889		;6768
	ld hl,0e059h		;676b
	ld de,(0e05ah)		;676e
	inc (hl)			;6772
	call L_4019		;6773
	cp (hl)			;6776
	ret nz			;6777
	ld (hl),000h		;6778
L_677A:
	inc de			;677a
	inc de			;677b
	inc de			;677c
	call L_4019		;677d
	or a			;6780
	jr z,L_677A		;6781
	ld (0e05ah),de		;6783
	ret			;6787
L_6788:
	ld hl,0e1abh		;6788
	set 0,(hl)		;678b
	jr L_6768		;678d
L_678F:
	ld hl,0e059h		;678f
	ld de,(0e05ah)		;6792
	dec (hl)			;6796
L_6797:
	dec de			;6797
	dec de			;6798
	dec de			;6799
	call L_4019		;679a
	or a			;679d
	jr z,L_6797		;679e
	ld a,(hl)			;67a0
	or a			;67a1
	jr nz,L_67D3		;67a2
L_67A4:
	inc de			;67a4
	call L_4019		;67a5
	ld b,a			;67a8
	ld a,(0e056h)		;67a9
	cp b			;67ac
	jr nz,L_67B4		;67ad
	ld hl,0e1abh		;67af
	set 1,(hl)		;67b2
L_67B4:
	call L_67EC		;67b4
L_67B7:
	call L_6889		;67b7
	ld hl,0e1c4h		;67ba
	ld de,(0e1c5h)		;67bd
	dec (hl)			;67c1
	ret p			;67c2
L_67C3:
	dec de			;67c3
	dec de			;67c4
	dec de			;67c5
	call L_4019		;67c6
	or a			;67c9
	jr z,L_67C3		;67ca
	dec a			;67cc
	ld (hl),a			;67cd
	ld (0e1c5h),de		;67ce
	ret			;67d2
L_67D3:
	jp p,L_67B7		;67d3
	call L_4019		;67d6
	dec a			;67d9
	ld (hl),a			;67da
	ld (0e05ah),de		;67db
	jr nz,L_67B7		;67df
L_67E1:
	dec de			;67e1
	dec de			;67e2
	dec de			;67e3
	call L_4019		;67e4
	or a			;67e7
	jr z,L_67E1		;67e8
	jr L_67A4		;67ea
L_67EC:
	ld hl,0e132h		;67ec
	ld b,028h		;67ef
L_67F1:
	ld a,0d0h		;67f1
	cp (hl)			;67f3
	jr z,L_67FC		;67f4
	inc hl			;67f6
	inc hl			;67f7
	inc hl			;67f8
	djnz L_67F1		;67f9
	ret			;67fb
L_67FC:
	push bc			;67fc
	ld a,(0e1aah)		;67fd
	rra			;6800
	ld (hl),0e8h		;6801
	jr c,L_6807		;6803
	ld (hl),0c0h		;6805
L_6807:
	ld (0e1dch),hl		;6807
	inc hl			;680a
	call L_4019		;680b
	ld b,a			;680e
	inc de			;680f
	call L_4019		;6810
	ld (hl),a			;6813
	inc hl			;6814
	ld (hl),b			;6815
	ld a,b			;6816
	and 0e0h		;6817
	cp 0e0h		;6819
	jr nz,L_6875		;681b
	push de			;681d
	push hl			;681e
	call L_6D58		;681f
	jr z,L_6881		;6822
	push de			;6824
	ld de,00000h		;6825
	call L_6D58		;6828
	pop de			;682b
	jr nz,L_6873		;682c
	ld (hl),d			;682e
	dec hl			;682f
	ld (hl),e			;6830
	inc hl			;6831
	inc hl			;6832
	ld a,(0e051h)		;6833
	ld c,a			;6836
	cp 001h		;6837
	ld b,003h		;6839
	jr nz,L_683E		;683b
	ld b,a			;683d
L_683E:
	ld a,r		;683e
	and b			;6840
	ld (hl),a			;6841
	cp 003h		;6842
	jr nz,L_684C		;6844
	ld a,c			;6846
	cp 002h		;6847
	jr nz,L_684C		;6849
	dec (hl)			;684b
L_684C:
	ld a,(0e1aah)		;684c
	rra			;684f
	jr c,L_6854		;6850
	set 7,(hl)		;6852
L_6854:
	inc hl			;6854
	ld de,(0e1dch)		;6855
	push de			;6859
	push hl			;685a
	ld a,(de)			;685b
	ld (hl),000h		;685c
	cp 0e8h		;685e
	jr nz,L_6864		;6860
	ld (hl),0ffh		;6862
L_6864:
	inc hl			;6864
	ex de,hl			;6865
	ld bc,00003h		;6866
	ldir		;6869
	pop hl			;686b
	ld c,002h		;686c
	ldir		;686e
	pop hl			;6870
	ld (hl),0d0h		;6871
L_6873:
	pop hl			;6873
	pop de			;6874
L_6875:
	pop bc			;6875
	inc hl			;6876
	inc de			;6877
	call L_4019		;6878
	or a			;687b
	ret nz			;687c
	inc de			;687d
	jp L_67EC		;687e
L_6881:
	pop hl			;6881
	pop de			;6882
	dec hl			;6883
	dec hl			;6884
	ld (hl),0d0h		;6885
	jr L_6875		;6887
L_6889:
	ld hl,0e132h		;6889
	ld b,028h		;688c
L_688E:
	push hl			;688e
	push bc			;688f
	ld a,(hl)			;6890
	cp 0d0h		;6891
	jr z,L_68EC		;6893
	call L_4A0E		;6895
	push bc			;6898
	push de			;6899
	push hl			;689a
	ld a,(0e1aah)		;689b
	or a			;689e
	jr z,L_68D5		;689f
	ld d,(hl)			;68a1
	rra			;68a2
	ld a,0f8h		;68a3
	jr nc,L_68A9		;68a5
	ld a,008h		;68a7
L_68A9:
	add a,(hl)			;68a9
	ld (hl),a			;68aa
	sub 0c0h		;68ab
	cp 030h		;68ad
	jr nc,L_68B3		;68af
	ld (hl),0d0h		;68b1
L_68B3:
	ld a,(0e1abh)		;68b3
	add a,a			;68b6
	jr c,L_68D5		;68b7
	inc hl			;68b9
	ld a,(hl)			;68ba
	inc hl			;68bb
	ld e,(hl)			;68bc
	ld h,a			;68bd
	ld l,d			;68be
	ld a,(0e1aah)		;68bf
	rra			;68c2
	jr c,L_68CC		;68c3
	dec b			;68c5
	ld a,b			;68c6
	add a,a			;68c7
	add a,a			;68c8
	add a,a			;68c9
	add a,l			;68ca
	ld l,a			;68cb
L_68CC:
	bit 7,e		;68cc
	jr nz,L_68D5		;68ce
	ld b,000h		;68d0
	call L_4A00		;68d2
L_68D5:
	pop hl			;68d5
	pop de			;68d6
	pop bc			;68d7
	push hl			;68d8
	inc hl			;68d9
	inc hl			;68da
	ld a,(hl)			;68db
	and 0c0h		;68dc
	cp 0c0h		;68de
	pop hl			;68e0
	jr z,L_68EC		;68e1
	ld a,(0e1abh)		;68e3
	add a,a			;68e6
	jr c,L_68EC		;68e7
	call L_49B8		;68e9
L_68EC:
	pop bc			;68ec
	pop hl			;68ed
	inc hl			;68ee
	inc hl			;68ef
	inc hl			;68f0
	djnz L_688E		;68f1
	ld a,(0e1abh)		;68f3
	add a,a			;68f6
	ret c			;68f7
	ld hl,0e134h		;68f8
	ld b,028h		;68fb
L_68FD:
	push hl			;68fd
	push bc			;68fe
	bit 6,(hl)		;68ff
	jr z,L_690D		;6901
	dec hl			;6903
	dec hl			;6904
	ld a,(hl)			;6905
	cp 0d0h		;6906
	jr z,L_690D		;6908
	call L_49B5		;690a
L_690D:
	pop bc			;690d
	pop hl			;690e
	inc hl			;690f
	inc hl			;6910
	inc hl			;6911
	inc c			;6912
	djnz L_68FD		;6913
	call L_6C32		;6915
	ld a,(0e1aah)		;6918
	and 003h		;691b
	ret z			;691d
	ld c,a			;691e
	ld hl,0e0e4h		;691f
	ld b,011h		;6922
	call L_693B		;6924
	ld hl,0e0c0h		;6927
	ld b,004h		;692a
	call L_693B		;692c
	ld hl,0e104h		;692f
	ld de,03b54h		;6932
	ld bc,00008h		;6935
	jp L_4441		;6938
L_693B:
	ld a,(hl)			;693b
	sub 008h		;693c
	cp 0b9h		;693e
	jr c,L_6946		;6940
	ld (hl),0c3h		;6942
	jr L_6950		;6944
L_6946:
	ld a,008h		;6946
	bit 1,c		;6948
	jr z,L_694E		;694a
	ld a,0f8h		;694c
L_694E:
	add a,(hl)			;694e
	ld (hl),a			;694f
L_6950:
	inc hl			;6950
	inc hl			;6951
	inc hl			;6952
	inc hl			;6953
	djnz L_693B		;6954
	ret			;6956
L_6957:
	ld a,(0e009h)		;6957
	rra			;695a
	jr nc,L_6962		;695b
	ld a,(0e003h)		;695d
	rra			;6960
	ret nc			;6961
L_6962:
	ld a,(0e009h)		;6962
	and 003h		;6965
	ret z			;6967
	rra			;6968
	jr nc,L_699F		;6969
	call L_69BC		;696b
	call L_6396		;696e
	call L_6A03		;6971
	ld a,(0e1b3h)		;6974
	add a,008h		;6977
	ld b,a			;6979
	ld hl,0e1cfh		;697a
	ld a,(hl)			;697d
	cp 0c0h		;697e
	ret nc			;6980
	cp b			;6981
	ret c			;6982
	call L_66A5		;6983
	ld de,0e1cbh		;6986
	push de			;6989
	ld bc,00003h		;698a
	ldir		;698d
	ld (de),a			;698f
	pop hl			;6990
	inc hl			;6991
	inc hl			;6992
	ld a,(hl)			;6993
	cp 00ah		;6994
	jp z,L_6334		;6996
	ld (0e056h),a		;6999
	jp L_737B		;699c
L_699F:
	call L_69BC		;699f
	call L_6A03		;69a2
	call L_63AC		;69a5
	ld hl,(0e1b3h)		;69a8
	ld a,l			;69ab
	add a,024h		;69ac
	ld l,a			;69ae
	call L_6665		;69af
	jp nc,L_6359		;69b2
	jp L_6334		;69b5
L_69B8:
	ld a,00ah		;69b8
	jr L_69BE		;69ba
L_69BC:
	ld a,006h		;69bc
L_69BE:
	push af			;69be
	call L_69CF		;69bf
	pop af			;69c2
	ld hl,0e1b3h		;69c3
	bit 2,(hl)		;69c6
	jr nz,L_69CB		;69c8
	inc a			;69ca
L_69CB:
	inc hl			;69cb
	inc hl			;69cc
	ld (hl),a			;69cd
	ret			;69ce
L_69CF:
	ld a,(0e009h)		;69cf
	and 003h		;69d2
	ld (0e1b6h),a		;69d4
	ret z			;69d7
	ld hl,0e1b3h		;69d8
	rra			;69db
	jr nc,L_69DF		;69dc
	dec a			;69de
L_69DF:
	call L_670A		;69df
	ld a,002h		;69e2
	jp L_7A13		;69e4
L_69E7:
	ld hl,0e1d2h		;69e7
	ld b,(hl)			;69ea
L_69EB:
	inc hl			;69eb
	ld a,(0e1b4h)		;69ec
	sub (hl)			;69ef
	cp 008h		;69f0
	jr c,L_69F8		;69f2
	djnz L_69EB		;69f4
	and a			;69f6
	ret			;69f7
L_69F8:
	ld de,0e1dah		;69f8
	ldd		;69fb
	ld a,(0e1cfh)		;69fd
	ld (de),a			;6a00
	scf			;6a01
	ret			;6a02
L_6A03:
	ld hl,0e132h		;6a03
	ld b,028h		;6a06
L_6A08:
	ld a,(hl)			;6a08
	inc hl			;6a09
	inc hl			;6a0a
	cp 0d0h		;6a0b
	jr z,L_6A1C		;6a0d
	ld a,(hl)			;6a0f
	cp 087h		;6a10
	jr z,L_6A21		;6a12
	cp 00ah		;6a14
	jr z,L_6A21		;6a16
	cp 08ah		;6a18
	jr z,L_6A21		;6a1a
L_6A1C:
	inc hl			;6a1c
	djnz L_6A08		;6a1d
	and a			;6a1f
	ret			;6a20
L_6A21:
	dec hl			;6a21
	dec hl			;6a22
	ld de,0e1cfh		;6a23
	ld bc,00003h		;6a26
	ldir		;6a29
	ld hl,06a42h		;6a2b
L_6A2E:
	cp (hl)			;6a2e
	jr z,L_6A3A		;6a2f
	ld c,(hl)			;6a31
	inc c			;6a32
	ret z			;6a33
	inc hl			;6a34
	inc hl			;6a35
	inc hl			;6a36
	inc hl			;6a37
	jr L_6A2E		;6a38
L_6A3A:
	inc hl			;6a3a
	ld bc,00003h		;6a3b
	ldir		;6a3e
	scf			;6a40
	ret			;6a41

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6a42..0x6a4f  (13 bytes)
DATA_6A42:
	defb 00ah,001h,0b0h,000h,087h,002h,040h,0a8h,08ah,002h,040h,0a8h,0ffh	; 6a42  ......@...@..

; ======================================================================
; CODIGO 0x6a4f..0x6afa  (171 bytes)
; ======================================================================


L_6A4F:
	ld a,(0e009h)		;6a4f
	ld b,a			;6a52
	and 00ch		;6a53
	jr z,L_6A5C		;6a55
	call L_64B7		;6a57
	jr nz,L_6A93		;6a5a
L_6A5C:
	ld a,b			;6a5c
	and 003h		;6a5d
	ret z			;6a5f
	rra			;6a60
	jr nc,L_6A7C		;6a61
	ld a,(0e003h)		;6a63
	rra			;6a66
	ret c			;6a67
	call L_69B8		;6a68
	call L_6396		;6a6b
	ld hl,(0e1b3h)		;6a6e
	ld bc,0000ch		;6a71
	add hl,bc			;6a74
	call L_6665		;6a75
	ret nc			;6a78
	jp L_6334		;6a79
L_6A7C:
	call L_69B8		;6a7c
	call L_63AC		;6a7f
	call L_61A3		;6a82
	ld a,(0e1bfh)		;6a85
	cp 003h		;6a88
	ret nz			;6a8a
	ld a,008h		;6a8b
	call L_670A		;6a8d
	jp L_62E6		;6a90
L_6A93:
	ld hl,(0e1b3h)		;6a93
	ld a,(0e009h)		;6a96
	ld b,a			;6a99
	bit 3,a		;6a9a
	ld a,00dh		;6a9c
	jr nz,L_6AA2		;6a9e
	ld a,0fbh		;6aa0
L_6AA2:
	add a,h			;6aa2
	ld h,a			;6aa3
	ld (0e1b3h),hl		;6aa4
	ld hl,0e1b5h		;6aa7
	ld (hl),005h		;6aaa
	ld a,b			;6aac
	and 00ch		;6aad
	inc hl			;6aaf
	ld (hl),a			;6ab0
	inc hl			;6ab1
	ld (hl),a			;6ab2
	ld hl,06576h		;6ab3
	jp L_62DE		;6ab6
L_6AB9:
	call L_6B1A		;6ab9
	ret nc			;6abc
	ld a,(0e05fh)		;6abd
	or a			;6ac0
	ret z			;6ac1
	ld a,(0e23ah)		;6ac2
	or a			;6ac5
	ret nz			;6ac6
	ld a,080h		;6ac7
	ld de,06afah		;6ac9
L_6ACC:
	ld hl,0e137h		;6acc
	ld bc,02701h		;6acf
L_6AD2:
	push af			;6ad2
	push de			;6ad3
	push hl			;6ad4
	push bc			;6ad5
	cp (hl)			;6ad6
	jr z,L_6ADD		;6ad7
	inc a			;6ad9
	cp (hl)			;6ada
	jr nz,L_6AED		;6adb
L_6ADD:
	dec hl			;6add
	dec hl			;6ade
	ld a,(hl)			;6adf
	cp 0d0h		;6ae0
	jr z,L_6AED		;6ae2
	sub 018h		;6ae4
	cp 078h		;6ae6
	jr nc,L_6AED		;6ae8
	call L_6AF8		;6aea
L_6AED:
	pop bc			;6aed
	pop hl			;6aee
	pop de			;6aef
	pop af			;6af0
	inc hl			;6af1
	inc hl			;6af2
	inc hl			;6af3
	inc c			;6af4
	djnz L_6AD2		;6af5
	ret			;6af7
L_6AF8:
	ex de,hl			;6af8
	jp (hl)			;6af9

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6afa..0x6b1a  (32 bytes)
DATA_6AFA:
	defb 079h,0cdh,00dh,06bh,0c8h,0afh,0cdh,00dh,06bh,0c0h,02bh,036h,001h,023h,071h,023h	; 6afa  y..k....k.+6.#q#
	defb 036h,040h,0c9h,021h,01dh,0e2h,006h,003h,0beh,0c8h,023h,023h,023h,010h,0f9h,0c9h	; 6b0a  6@.!......###...

; ======================================================================
; CODIGO 0x6b1a..0x6bbb  (161 bytes)
; ======================================================================


L_6B1A:
	ld a,(0e1bch)		;6b1a
	and 0f0h		;6b1d
	cp 050h		;6b1f
	ret			;6b21
L_6B22:
	ld a,(0e003h)		;6b22
	and 01fh		;6b25
	ret nz			;6b27
	ld hl,0e21ch		;6b28
	ld bc,00300h		;6b2b
L_6B2E:
	push hl			;6b2e
	push bc			;6b2f
	ld a,(hl)			;6b30
	or a			;6b31
	jr z,L_6B65		;6b32
	inc hl			;6b34
	ld a,(hl)			;6b35
	ld e,a			;6b36
	add a,a			;6b37
	add a,e			;6b38
	ld de,0e132h		;6b39
	call L_4027		;6b3c
	ld a,(de)			;6b3f
	sub 018h		;6b40
	cp 078h		;6b42
	jr nc,L_6B56		;6b44
	inc de			;6b46
	inc de			;6b47
	ld a,(de)			;6b48
	cp 080h		;6b49
	jr z,L_6B51		;6b4b
	cp 081h		;6b4d
	jr nz,L_6B56		;6b4f
L_6B51:
	call L_6B6E		;6b51
	jr L_6B65		;6b54
L_6B56:
	xor a			;6b56
	ld (hl),a			;6b57
	dec hl			;6b58
	ld (hl),a			;6b59
	inc hl			;6b5a
	inc hl			;6b5b
	ld (hl),a			;6b5c
	ld hl,0e104h		;6b5d
	call L_4A3B		;6b60
	ld (hl),0c3h		;6b63
L_6B65:
	pop bc			;6b65
	pop hl			;6b66
	inc hl			;6b67
	inc hl			;6b68
	inc hl			;6b69
	inc c			;6b6a
	djnz L_6B2E		;6b6b
	ret			;6b6d
L_6B6E:
	dec hl			;6b6e
	bit 7,(hl)		;6b6f
	ret nz			;6b71
	inc hl			;6b72
	inc hl			;6b73
	inc (hl)			;6b74
	ld a,(0e23ah)		;6b75
	or a			;6b78
	jr nz,L_6BB2		;6b79
	ld a,(hl)			;6b7b
	bit 6,a		;6b7c
	jr z,L_6BB2		;6b7e
	and 006h		;6b80
	rra			;6b82
	push de			;6b83
	ld de,06bbbh		;6b84
	call L_4027		;6b87
	ld a,(de)			;6b8a
	ex af,af'			;6b8b
	pop de			;6b8c
	dec de			;6b8d
	dec de			;6b8e
	ex de,hl			;6b8f
	ld de,0e104h		;6b90
	call L_4A41		;6b93
	ld a,(hl)			;6b96
	add a,00dh		;6b97
	ld (de),a			;6b99
	inc hl			;6b9a
	inc de			;6b9b
	ld c,(hl)			;6b9c
	inc hl			;6b9d
	ld a,(hl)			;6b9e
	cp 080h		;6b9f
	ld b,005h		;6ba1
	jr nz,L_6BA7		;6ba3
	ld b,004h		;6ba5
L_6BA7:
	ld a,c			;6ba7
	sub b			;6ba8
	ld (de),a			;6ba9
	inc de			;6baa
	ex de,hl			;6bab
	ld (hl),0a0h		;6bac
	ex af,af'			;6bae
	inc hl			;6baf
	ld (hl),a			;6bb0
	ret			;6bb1
L_6BB2:
	ld hl,0e104h		;6bb2
	call L_4A3B		;6bb5
	ld (hl),0c3h		;6bb8
	ret			;6bba

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6bbb..0x6bbf  (4 bytes)
DATA_6BBB:
	defb 000h,004h,00fh,00ch	; 6bbb

; ======================================================================
; CODIGO 0x6bbf..0x6d7a  (443 bytes)
; ======================================================================


L_6BBF:
	ld a,(0e1aah)		;6bbf
	or a			;6bc2
	ret nz			;6bc3
	ld hl,0e1deh		;6bc4
	ld b,003h		;6bc7
L_6BC9:
	push hl			;6bc9
	push bc			;6bca
	ld a,(hl)			;6bcb
	inc hl			;6bcc
	or a			;6bcd
	jr nz,L_6BD4		;6bce
	ld a,(hl)			;6bd0
	or a			;6bd1
	jr z,L_6C28		;6bd2
L_6BD4:
	inc hl			;6bd4
	ld c,(hl)			;6bd5
	ld a,(0e003h)		;6bd6
	ld b,007h		;6bd9
	bit 6,c		;6bdb
	jr nz,L_6BE3		;6bdd
	bit 4,c		;6bdf
	jr z,L_6BE5		;6be1
L_6BE3:
	ld b,003h		;6be3
L_6BE5:
	and b			;6be5
	jr nz,L_6C28		;6be6
	bit 5,c		;6be8
	jr nz,L_6C28		;6bea
	push bc			;6bec
	ld a,c			;6bed
	ld bc,00004h		;6bee
	bit 7,(hl)		;6bf1
	jr z,L_6BF8		;6bf3
	ld bc,0fffch		;6bf5
L_6BF8:
	inc hl			;6bf8
	bit 3,a		;6bf9
	jr nz,L_6C00		;6bfb
	call L_6C72		;6bfd
L_6C00:
	pop bc			;6c00
	push hl			;6c01
	inc hl			;6c02
	inc hl			;6c03
	inc hl			;6c04
	ld (hl),0e1h		;6c05
	bit 2,e		;6c07
	jr nz,L_6C19		;6c09
	ld (hl),0e0h		;6c0b
	bit 6,c		;6c0d
	jr nz,L_6C17		;6c0f
	ld a,r		;6c11
	and 00fh		;6c13
	jr nz,L_6C19		;6c15
L_6C17:
	ld (hl),0e2h		;6c17
L_6C19:
	pop hl			;6c19
	call L_6C7C		;6c1a
	dec hl			;6c1d
	call L_6CA1		;6c1e
	inc hl			;6c21
	call L_6CFC		;6c22
	call L_6D41		;6c25
L_6C28:
	pop bc			;6c28
	pop hl			;6c29
	ld a,009h		;6c2a
	call L_4022		;6c2c
	djnz L_6BC9		;6c2f
	ret			;6c31
L_6C32:
	ld a,(0e1aah)		;6c32
	or a			;6c35
	ret z			;6c36
	ld hl,0e1deh		;6c37
	ld b,003h		;6c3a
L_6C3C:
	push hl			;6c3c
	push bc			;6c3d
	ld a,(hl)			;6c3e
	inc hl			;6c3f
	or a			;6c40
	jr nz,L_6C47		;6c41
	ld a,(hl)			;6c43
	or a			;6c44
	jr z,L_6C68		;6c45
L_6C47:
	inc hl			;6c47
	ld c,(hl)			;6c48
	ld a,(0e1aah)		;6c49
	rra			;6c4c
	ld bc,00008h		;6c4d
	jr c,L_6C55		;6c50
	ld bc,0fff8h		;6c52
L_6C55:
	inc hl			;6c55
	call L_6C72		;6c56
	push hl			;6c59
	inc hl			;6c5a
	inc hl			;6c5b
	inc hl			;6c5c
	inc hl			;6c5d
	call L_6C72		;6c5e
	pop hl			;6c61
	call L_6C7C		;6c62
	call L_6D41		;6c65
L_6C68:
	pop bc			;6c68
	pop hl			;6c69
	ld a,009h		;6c6a
	call L_4022		;6c6c
	djnz L_6C3C		;6c6f
	ret			;6c71
L_6C72:
	ld d,(hl)			;6c72
	inc hl			;6c73
	ld e,(hl)			;6c74
	ex de,hl			;6c75
	add hl,bc			;6c76
	ex de,hl			;6c77
	ld (hl),e			;6c78
	dec hl			;6c79
	ld (hl),d			;6c7a
	ret			;6c7b
L_6C7C:
	push hl			;6c7c
	call L_6C8E		;6c7d
	dec hl			;6c80
	set 5,(hl)		;6c81
	jr c,L_6C8C		;6c83
	res 5,(hl)		;6c85
	inc hl			;6c87
	inc hl			;6c88
	call L_49B5		;6c89
L_6C8C:
	pop hl			;6c8c
	ret			;6c8d
L_6C8E:
	push hl			;6c8e
	ld d,(hl)			;6c8f
	inc hl			;6c90
	ld e,(hl)			;6c91
	ex de,hl			;6c92
	and a			;6c93
	ld bc,000c0h		;6c94
	sbc hl,bc		;6c97
	and a			;6c99
	ld bc,0ff30h		;6c9a
	sbc hl,bc		;6c9d
	pop hl			;6c9f
	ret			;6ca0
L_6CA1:
	ld a,(hl)			;6ca1
	bit 5,a		;6ca2
	ret nz			;6ca4
	and 003h		;6ca5
	ret z			;6ca7
	push hl			;6ca8
	inc hl			;6ca9
	inc hl			;6caa
	ld c,(hl)			;6cab
	inc hl			;6cac
	ld b,(hl)			;6cad
	pop hl			;6cae
	res 6,(hl)		;6caf
	cp 001h		;6cb1
	jr nz,L_6CC9		;6cb3
	ld a,(0e1b4h)		;6cb5
	sub b			;6cb8
	cp 008h		;6cb9
	ret nc			;6cbb
	ld a,(0e1b2h)		;6cbc
	cp 007h		;6cbf
	ret nz			;6cc1
	ld a,(hl)			;6cc2
	or 0c0h		;6cc3
	res 3,a		;6cc5
	ld (hl),a			;6cc7
	ret			;6cc8
L_6CC9:
	ld de,02040h		;6cc9
	cp 003h		;6ccc
	jr nz,L_6CD5		;6cce
	ld de,01820h		;6cd0
	set 4,(hl)		;6cd3
L_6CD5:
	ld a,b			;6cd5
	sub d			;6cd6
	ld b,a			;6cd7
	ld a,(0e1b4h)		;6cd8
	sub b			;6cdb
	cp e			;6cdc
	set 3,(hl)		;6cdd
	ret nc			;6cdf
	res 3,(hl)		;6ce0
	cp 030h		;6ce2
	ld e,008h		;6ce4
	jr nc,L_6CEA		;6ce6
	ld e,004h		;6ce8
L_6CEA:
	ld a,(0e1b7h)		;6cea
	and e			;6ced
	ret nz			;6cee
	ld a,(0e1b3h)		;6cef
	sub 010h		;6cf2
	cp c			;6cf4
	res 7,(hl)		;6cf5
	jr nc,L_6CFB		;6cf7
	set 7,(hl)		;6cf9
L_6CFB:
	ret			;6cfb
L_6CFC:
	push hl			;6cfc
	dec hl			;6cfd
	ld c,(hl)			;6cfe
	bit 5,c		;6cff
	jr nz,L_6D3F		;6d01
	push hl			;6d03
	inc hl			;6d04
	inc hl			;6d05
	ld a,028h		;6d06
	bit 7,c		;6d08
	jr z,L_6D0E		;6d0a
	ld a,0f8h		;6d0c
L_6D0E:
	add a,(hl)			;6d0e
	ld e,a			;6d0f
	sub 018h		;6d10
	cp 0a8h		;6d12
	ld a,004h		;6d14
	jr nc,L_6D3A		;6d16
	inc hl			;6d18
	ld d,(hl)			;6d19
	ex de,hl			;6d1a
	ld b,003h		;6d1b
	bit 7,c		;6d1d
	jr z,L_6D23		;6d1f
	ld b,002h		;6d21
L_6D23:
	push bc			;6d23
	call L_498C		;6d24
	pop bc			;6d27
	cp 003h		;6d28
	jr nz,L_6D3A		;6d2a
	ld a,008h		;6d2c
	bit 7,c		;6d2e
	jr z,L_6D33		;6d30
	add a,a			;6d32
L_6D33:
	add a,h			;6d33
	ld h,a			;6d34
	djnz L_6D23		;6d35
	pop hl			;6d37
	jr L_6D3F		;6d38
L_6D3A:
	pop hl			;6d3a
	ld a,080h		;6d3b
	xor (hl)			;6d3d
	ld (hl),a			;6d3e
L_6D3F:
	pop hl			;6d3f
	ret			;6d40
L_6D41:
	call L_6C8E		;6d41
	ret nc			;6d44
	inc hl			;6d45
	inc hl			;6d46
	inc hl			;6d47
	inc hl			;6d48
	call L_6C8E		;6d49
	ret nc			;6d4c
	ld d,h			;6d4d
	ld e,l			;6d4e
	inc hl			;6d4f
	ld (hl),000h		;6d50
	ld bc,00008h		;6d52
	lddr		;6d55
	ret			;6d57
L_6D58:
	ld hl,0e1deh		;6d58
	ld b,003h		;6d5b
L_6D5D:
	ld a,(hl)			;6d5d
	inc hl			;6d5e
	cp e			;6d5f
	jr nz,L_6D65		;6d60
	ld a,(hl)			;6d62
	cp d			;6d63
	ret z			;6d64
L_6D65:
	ld a,008h		;6d65
	call L_4022		;6d67
	djnz L_6D5D		;6d6a
	ret			;6d6c
L_6D6D:
	ld a,(0e003h)		;6d6d
	or a			;6d70
	ret nz			;6d71
	ld de,06d7ah		;6d72
	ld a,093h		;6d75
	jp L_6ACC		;6d77

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6d7a..0x6dd2  (88 bytes)
DATA_6D7A:
	defb 079h,0cdh,0c5h,06dh,0c8h,0afh,0cdh,0c5h,06dh,0c0h,0e5h,0ddh,0e1h,0c5h,011h,035h	; 6d7a  y..m....m......5
	defb 0e1h,001h,001h,027h,01ah,0feh,0d0h,028h,008h,013h,013h,013h,00ch,010h,0f5h,0c1h	; 6d8a  ...'...(........
	defb 0c9h,021h,0fah,0e1h,079h,0cdh,0c8h,06dh,028h,0f5h,0ddh,071h,001h,0c1h,0ddh,071h	; 6d9a  .!..y..m(..q...q
	defb 000h,0cdh,047h,04ah,001h,003h,000h,0edh,0b0h,0ebh,02bh,07eh,0feh,093h,001h,08bh	; 6daa  ..GJ......+~....
	defb 090h,028h,003h,001h,08eh,0a0h,071h,0ddh,070h,002h,0c9h,021h,0f9h,0e1h,006h,005h	; 6dba  .(....q.p..!....
	defb 0beh,0c8h,023h,023h,023h,010h,0f9h,0c9h	; 6dca  ..###...

; ======================================================================
; CODIGO 0x6dd2..0x6fab  (473 bytes)
; ======================================================================


L_6DD2:
	ld hl,0e1fbh		;6dd2
	ld bc,00500h		;6dd5
L_6DD8:
	push hl			;6dd8
	push bc			;6dd9
	ld a,(hl)			;6dda
	or a			;6ddb
	jr z,L_6E1B		;6ddc
	push hl			;6dde
	pop iy		;6ddf
	dec hl			;6de1
	ld a,(hl)			;6de2
	add a,a			;6de3
	add a,(hl)			;6de4
	inc hl			;6de5
	ld de,0e132h		;6de6
	call L_4027		;6de9
	push de			;6dec
	pop ix		;6ded
	ld a,(de)			;6def
	cp 0d0h		;6df0
	jr z,L_6E36		;6df2
	ld a,(ix+002h)		;6df4
	sub 08bh		;6df7
	cp 004h		;6df9
	jr c,L_6E01		;6dfb
	cp 005h		;6dfd
	jr nz,L_6E36		;6dff
L_6E01:
	bit 7,(hl)		;6e01
	jr z,L_6E0A		;6e03
	call L_6E62		;6e05
	jr L_6E1B		;6e08
L_6E0A:
	call L_6E3B		;6e0a
	jr c,L_6E24		;6e0d
	bit 6,(hl)		;6e0f
	jr z,L_6E18		;6e11
	call L_6EB4		;6e13
	jr L_6E1B		;6e16
L_6E18:
	call L_6F5F		;6e18
L_6E1B:
	pop bc			;6e1b
	pop hl			;6e1c
	inc hl			;6e1d
	inc hl			;6e1e
	inc hl			;6e1f
	inc c			;6e20
	djnz L_6DD8		;6e21
	ret			;6e23
L_6E24:
	ex de,hl			;6e24
	ld c,(hl)			;6e25
	inc hl			;6e26
	ld b,(hl)			;6e27
	dec hl			;6e28
	ex de,hl			;6e29
	push bc			;6e2a
	call L_6F47		;6e2b
	pop bc			;6e2e
	ld a,004h		;6e2f
	call L_79A4		;6e31
	jr L_6E1B		;6e34
L_6E36:
	call L_6EA5		;6e36
	jr L_6E1B		;6e39
L_6E3B:
	push hl			;6e3b
	push de			;6e3c
	ex de,hl			;6e3d
	ld b,(hl)			;6e3e
	inc hl			;6e3f
	ld c,(hl)			;6e40
	inc hl			;6e41
	ld a,(hl)			;6e42
	ld d,004h		;6e43
	cp 08ch		;6e45
	jr nz,L_6E4B		;6e47
	ld d,000h		;6e49
L_6E4B:
	ld e,004h		;6e4b
	cp 090h		;6e4d
	jr nz,L_6E53		;6e4f
	ld e,008h		;6e51
L_6E53:
	ld a,b			;6e53
	sub d			;6e54
	ld b,a			;6e55
	ld a,c			;6e56
	sub e			;6e57
	ld c,a			;6e58
	ld de,01010h		;6e59
	call L_709F		;6e5c
	pop de			;6e5f
	pop hl			;6e60
	ret			;6e61
L_6E62:
	ld a,(0e003h)		;6e62
	and 00fh		;6e65
	ret nz			;6e67
	inc (hl)			;6e68
	push hl			;6e69
	bit 1,(hl)		;6e6a
	jr nz,L_6EAC		;6e6c
	ex de,hl			;6e6e
L_6E6F:
	call L_49B5		;6e6f
	pop hl			;6e72
	ld a,(hl)			;6e73
	ld c,a			;6e74
	and 00fh		;6e75
	ld b,a			;6e77
	ld a,(0e051h)		;6e78
	cp 003h		;6e7b
	ld a,006h		;6e7d
	jr nc,L_6E83		;6e7f
	ld a,00bh		;6e81
L_6E83:
	cp b			;6e83
	ret nz			;6e84
	ld a,c			;6e85
	and 070h		;6e86
	or 040h		;6e88
	ld (hl),a			;6e8a
	push ix		;6e8b
	pop hl			;6e8d
	ld a,(hl)			;6e8e
	sub 008h		;6e8f
	ld (hl),a			;6e91
	inc hl			;6e92
	ld a,0e8h		;6e93
	bit 4,c		;6e95
	jr nz,L_6E9B		;6e97
	ld a,008h		;6e99
L_6E9B:
	add a,(hl)			;6e9b
	ld (hl),a			;6e9c
	inc hl			;6e9d
	ld (hl),08ch		;6e9e
	dec hl			;6ea0
	dec hl			;6ea1
	jp L_49B5		;6ea2
L_6EA5:
	xor a			;6ea5
	ld (hl),a			;6ea6
	dec hl			;6ea7
	ld (hl),a			;6ea8
	dec hl			;6ea9
	ld (hl),a			;6eaa
	ret			;6eab
L_6EAC:
	dec hl			;6eac
	dec hl			;6ead
	ld c,(hl)			;6eae
	call L_4A47		;6eaf
	jr L_6E6F		;6eb2
L_6EB4:
	ld a,(0e003h)		;6eb4
	ld b,a			;6eb7
	and 00fh		;6eb8
	ret nz			;6eba
	ld a,b			;6ebb
	and 01fh		;6ebc
	jr nz,L_6EC8		;6ebe
	ld a,(hl)			;6ec0
	and 00fh		;6ec1
	cp 00fh		;6ec3
	jr z,L_6EC8		;6ec5
	inc (hl)			;6ec7
L_6EC8:
	push hl			;6ec8
	push de			;6ec9
	ld a,014h		;6eca
	bit 4,(hl)		;6ecc
	jr z,L_6ED2		;6ece
	ld a,0f8h		;6ed0
L_6ED2:
	add a,(ix+001h)		;6ed2
	ld h,a			;6ed5
	ld a,(de)			;6ed6
	ld l,a			;6ed7
	sub 028h		;6ed8
	cp 078h		;6eda
	jr nc,L_6EF5		;6edc
	call L_498C		;6ede
	cp 003h		;6ee1
	jr nz,L_6F36		;6ee3
	ld b,004h		;6ee5
L_6EE7:
	ld a,020h		;6ee7
	call L_4027		;6ee9
	call L_4019		;6eec
	cp 003h		;6eef
	jr nz,L_6F52		;6ef1
	djnz L_6EE7		;6ef3
L_6EF5:
	pop de			;6ef5
	pop hl			;6ef6
	push hl			;6ef7
	push de			;6ef8
	call L_6FA1		;6ef9
	pop de			;6efc
	pop hl			;6efd
	ld a,(de)			;6efe
	sub 028h		;6eff
	cp 078h		;6f01
	ld a,000h		;6f03
	jr nc,L_6F0F		;6f05
	ld a,004h		;6f07
	bit 4,(hl)		;6f09
	jr z,L_6F0F		;6f0b
	ld a,0fch		;6f0d
L_6F0F:
	ld c,a			;6f0f
	ex de,hl			;6f10
	inc hl			;6f11
	add a,(hl)			;6f12
	ld (hl),a			;6f13
	inc hl			;6f14
	bit 2,c		;6f15
	jr z,L_6F23		;6f17
	ld (hl),08ch		;6f19
	bit 2,a		;6f1b
	jr z,L_6F21		;6f1d
	ld (hl),08dh		;6f1f
L_6F21:
	jr L_6F2C		;6f21
L_6F23:
	ld a,(hl)			;6f23
	cp 08ch		;6f24
	ld (hl),090h		;6f26
	jr z,L_6F2C		;6f28
	ld (hl),08ch		;6f2a
L_6F2C:
	dec hl			;6f2c
	dec hl			;6f2d
	call L_49B5		;6f2e
	ld a,001h		;6f31
	jp L_7A13		;6f33
L_6F36:
	pop de			;6f36
	pop hl			;6f37
	cp 086h		;6f38
	jr z,L_6F40		;6f3a
	cp 08ah		;6f3c
	jr nz,L_6F54		;6f3e
L_6F40:
	ld a,(hl)			;6f40
	and 00fh		;6f41
	cp 00fh		;6f43
	jr nz,L_6F5A		;6f45
L_6F47:
	call L_6EA5		;6f47
	call L_6FA1		;6f4a
	ld (ix+000h),0d0h		;6f4d
	ret			;6f51
L_6F52:
	pop de			;6f52
	pop hl			;6f53
L_6F54:
	cp 09bh		;6f54
	jr nz,L_6F5A		;6f56
	res 6,(hl)		;6f58
L_6F5A:
	ld a,030h		;6f5a
	xor (hl)			;6f5c
	ld (hl),a			;6f5d
	ret			;6f5e
L_6F5F:
	ld a,(0e003h)		;6f5f
	and 00fh		;6f62
	ret nz			;6f64
	push hl			;6f65
	push de			;6f66
	ld a,024h		;6f67
	bit 4,(hl)		;6f69
	jr z,L_6F6F		;6f6b
	ld a,0f8h		;6f6d
L_6F6F:
	ex de,hl			;6f6f
	add a,(hl)			;6f70
	ld e,a			;6f71
	inc hl			;6f72
	ld d,(hl)			;6f73
	ex de,hl			;6f74
	ld b,002h		;6f75
L_6F77:
	call L_498C		;6f77
	cp 003h		;6f7a
	jr nz,L_6F9D		;6f7c
	ld a,h			;6f7e
	add a,008h		;6f7f
	ld h,a			;6f81
	djnz L_6F77		;6f82
	pop de			;6f84
	pop hl			;6f85
	push hl			;6f86
	push de			;6f87
	call L_6FA1		;6f88
	pop de			;6f8b
	pop hl			;6f8c
	ld a,004h		;6f8d
	bit 4,(hl)		;6f8f
	jr z,L_6F95		;6f91
	ld a,0fch		;6f93
L_6F95:
	ex de,hl			;6f95
	add a,(hl)			;6f96
	ld (hl),a			;6f97
	inc hl			;6f98
	inc hl			;6f99
	jp L_6F23		;6f9a
L_6F9D:
	pop de			;6f9d
	pop hl			;6f9e
	jr L_6F5A		;6f9f
L_6FA1:
	ex de,hl			;6fa1
L_6FA2:
	call L_4A0E		;6fa2
	ld de,06fabh		;6fa5
	jp L_49B8		;6fa8

; ----------------------------------------------------------------------
; DATOS sin identificar  0x6fab..0x6fb7  (12 bytes)
DATA_6FAB:
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; 6fab  ............

; ======================================================================
; CODIGO 0x6fb7..0x71ff  (584 bytes)
; ======================================================================


L_6FB7:
	ld a,(0e051h)		;6fb7
	cp 006h		;6fba
	ret c			;6fbc
	ld a,(0e05eh)		;6fbd
	rra			;6fc0
	ret c			;6fc1
	ld a,(0e003h)		;6fc2
	or a			;6fc5
	ret nz			;6fc6
L_6FC7:
	ld de,0e132h		;6fc7
	ld b,028h		;6fca
L_6FCC:
	ld a,(de)			;6fcc
	inc de			;6fcd
	inc de			;6fce
	cp 0d0h		;6fcf
	jr z,L_6FE0		;6fd1
	sub 018h		;6fd3
	cp 088h		;6fd5
	jr nc,L_6FE0		;6fd7
	ld a,(de)			;6fd9
	sub 093h		;6fda
	cp 002h		;6fdc
	jr c,L_6FE4		;6fde
L_6FE0:
	inc de			;6fe0
	djnz L_6FCC		;6fe1
	ret			;6fe3
L_6FE4:
	dec de			;6fe4
	dec de			;6fe5
	ld hl,0e208h		;6fe6
	ld bc,00300h		;6fe9
L_6FEC:
	ld a,(hl)			;6fec
	or a			;6fed
	jr z,L_6FF9		;6fee
	inc hl			;6ff0
	inc hl			;6ff1
	inc hl			;6ff2
	inc hl			;6ff3
	inc hl			;6ff4
	inc c			;6ff5
	djnz L_6FEC		;6ff6
	ret			;6ff8
L_6FF9:
	push hl			;6ff9
	ex de,hl			;6ffa
	ld de,0e0e4h		;6ffb
	call L_4A41		;6ffe
	ld bc,00002h		;7001
	ldir		;7004
	ex de,hl			;7006
	ld (hl),090h		;7007
	inc hl			;7009
	ld (hl),00fh		;700a
	pop hl			;700c
	ld (hl),088h		;700d
	inc hl			;700f
	ld a,r		;7010
	and 007h		;7012
	jr nz,L_7018		;7014
	ld a,005h		;7016
L_7018:
	ld (hl),a			;7018
	inc hl			;7019
	ld (hl),a			;701a
	inc hl			;701b
	ld (hl),000h		;701c
	ret			;701e
L_701F:
	ld de,0e208h		;701f
	ld bc,00300h		;7022
L_7025:
	push de			;7025
	push bc			;7026
	ld a,(de)			;7027
	or a			;7028
	jr z,L_706E		;7029
	ld b,a			;702b
	push de			;702c
	pop ix		;702d
	ld hl,0e0e4h		;702f
	call L_4A3B		;7032
	push hl			;7035
	pop iy		;7036
	call L_7098		;7038
	jr nc,L_706E		;703b
	bit 7,b		;703d
	jr z,L_7046		;703f
	call L_7184		;7041
	jr L_706E		;7044
L_7046:
	bit 6,b		;7046
	jr z,L_704F		;7048
	call L_70BC		;704a
	jr L_7052		;704d
L_704F:
	call L_710F		;704f
L_7052:
	bit 4,(ix+000h)		;7052
	jr nz,L_706E		;7056
	push iy		;7058
	pop hl			;705a
	ld a,(hl)			;705b
	sub 008h		;705c
	ld b,a			;705e
	inc hl			;705f
	ld a,(hl)			;7060
	sub 004h		;7061
	ld c,a			;7063
	ld de,00c0ch		;7064
	push bc			;7067
	call L_709F		;7068
	pop bc			;706b
	jr c,L_7079		;706c
L_706E:
	pop bc			;706e
	pop de			;706f
	ld a,005h		;7070
	call L_4027		;7072
	inc c			;7075
	djnz L_7025		;7076
	ret			;7078
L_7079:
	ld a,c			;7079
	ld c,b			;707a
	ld b,a			;707b
	ld a,004h		;707c
	call L_79A4		;707e
	push ix		;7081
	pop hl			;7083
	ld (hl),031h		;7084
	inc hl			;7086
	inc hl			;7087
	call L_7107		;7088
	jr L_706E		;708b
L_708D:
	ld a,(hl)			;708d
	sub 010h		;708e
	cp 0b1h		;7090
L_7092:
	ret c			;7092
	ld (hl),0c3h		;7093
	xor a			;7095
	ld (de),a			;7096
	ret			;7097
L_7098:
	ld a,(hl)			;7098
	sub 008h		;7099
	cp 0b9h		;709b
	jr L_7092		;709d
L_709F:
	ld hl,0e114h		;709f
	ld a,003h		;70a2
L_70A4:
	ex af,af'			;70a4
	ld a,(hl)			;70a5
	inc hl			;70a6
	cp 0c0h		;70a7
	jr nc,L_70B3		;70a9
	sub b			;70ab
	cp d			;70ac
	jr nc,L_70B3		;70ad
	ld a,(hl)			;70af
	sub c			;70b0
	cp e			;70b1
	ret c			;70b2
L_70B3:
	inc hl			;70b3
	inc hl			;70b4
	inc hl			;70b5
	ex af,af'			;70b6
	dec a			;70b7
	jr nz,L_70A4		;70b8
	and a			;70ba
	ret			;70bb
L_70BC:
	ld a,(0e003h)		;70bc
	and 003h		;70bf
	ret nz			;70c1
	inc hl			;70c2
	ld a,b			;70c3
	and 00ch		;70c4
	jr z,L_70CF		;70c6
	inc (hl)			;70c8
	bit 3,a		;70c9
	jr nz,L_70CF		;70cb
	dec (hl)			;70cd
	dec (hl)			;70ce
L_70CF:
	ld c,(hl)			;70cf
	inc hl			;70d0
	bit 2,c		;70d1
	ld a,020h		;70d3
	jr nz,L_70D9		;70d5
	ld a,024h		;70d7
L_70D9:
	bit 2,b		;70d9
	jr z,L_70DF		;70db
	add a,028h		;70dd
L_70DF:
	ld (hl),a			;70df
	dec hl			;70e0
	dec hl			;70e1
	call L_7167		;70e2
	ret c			;70e5
	ex de,hl			;70e6
	ld a,(hl)			;70e7
	xor 00ch		;70e8
	ld (hl),a			;70ea
	inc hl			;70eb
	inc hl			;70ec
	dec (hl)			;70ed
	ret nz			;70ee
	dec hl			;70ef
	dec hl			;70f0
	ld a,028h		;70f1
	bit 3,(hl)		;70f3
	jr z,L_70F9		;70f5
	ld a,024h		;70f7
L_70F9:
	ld (hl),a			;70f9
	inc hl			;70fa
	ld a,(hl)			;70fb
	inc hl			;70fc
	ld (hl),a			;70fd
	ld a,r		;70fe
	bit 4,a		;7100
	ld bc,06576h		;7102
	jr nz,L_710A		;7105
L_7107:
	ld bc,06572h		;7107
L_710A:
	inc hl			;710a
	ld (hl),c			;710b
	inc hl			;710c
	ld (hl),b			;710d
	ret			;710e
L_710F:
	ld a,(0e003h)		;710f
	rra			;7112
	ret nc			;7113
	ld e,(ix+003h)		;7114
	ld d,(ix+004h)		;7117
	ld c,001h		;711a
	ld a,(de)			;711c
	bit 0,b		;711d
	jr nz,L_7125		;711f
	neg		;7121
	ld c,002h		;7123
L_7125:
	add a,(hl)			;7125
	ld (hl),a			;7126
	inc hl			;7127
	ld a,b			;7128
	and 00ch		;7129
	jr z,L_7137		;712b
	bit 3,a		;712d
	ld a,(hl)			;712f
	jr z,L_7135		;7130
	add a,c			;7132
	jr L_7136		;7133
L_7135:
	sub c			;7135
L_7136:
	ld (hl),a			;7136
L_7137:
	dec de			;7137
	bit 0,b		;7138
	jr nz,L_713E		;713a
	inc de			;713c
	inc de			;713d
L_713E:
	ld a,(de)			;713e
	inc a			;713f
	jr z,L_7148		;7140
	inc a			;7142
	jr nz,L_714E		;7143
	inc de			;7145
	jr L_714E		;7146
L_7148:
	dec de			;7148
	dec de			;7149
	set 0,(ix+000h)		;714a
L_714E:
	ld (ix+003h),e		;714e
	ld (ix+004h),d		;7151
	dec hl			;7154
	push ix		;7155
	pop de			;7157
	call L_7167		;7158
	ret nc			;715b
	ld a,(hl)			;715c
	and 0f8h		;715d
	ld (hl),a			;715f
	ld a,(de)			;7160
	and 00ch		;7161
	or 040h		;7163
	ld (de),a			;7165
	ret			;7166
L_7167:
	push hl			;7167
	push de			;7168
	ld a,010h		;7169
	add a,(hl)			;716b
	ld b,a			;716c
	inc hl			;716d
	ld c,(hl)			;716e
	ld a,(de)			;716f
	bit 3,a		;7170
	jr z,L_7178		;7172
	ld a,010h		;7174
	add a,c			;7176
	ld c,a			;7177
L_7178:
	ld h,c			;7178
	ld l,b			;7179
	call L_498C		;717a
	pop de			;717d
	pop hl			;717e
	sub 0cdh		;717f
	cp 004h		;7181
	ret			;7183
L_7184:
	ld a,(0e003h)		;7184
	and 007h		;7187
	ret nz			;7189
	push de			;718a
	inc de			;718b
	inc de			;718c
	inc de			;718d
	call L_71B9		;718e
	pop de			;7191
	ld a,(0e051h)		;7192
	cp 003h		;7195
	ld a,005h		;7197
	jr nc,L_719D		;7199
	ld a,010h		;719b
L_719D:
	cp b			;719d
	ret nz			;719e
	ld (hl),020h		;719f
	inc hl			;71a1
	ld a,(0e05dh)		;71a2
	cp 011h		;71a5
	ld (hl),001h		;71a7
	jr nz,L_71B2		;71a9
	ld a,r		;71ab
	and 007h		;71ad
	add a,003h		;71af
	ld (hl),a			;71b1
L_71B2:
	ld a,(de)			;71b2
	and 00fh		;71b3
	or 040h		;71b5
	ld (de),a			;71b7
	ret			;71b8
L_71B9:
	ex de,hl			;71b9
	inc (hl)			;71ba
	ld b,(hl)			;71bb
	ex de,hl			;71bc
	inc hl			;71bd
	inc hl			;71be
	bit 1,b		;71bf
	ret nz			;71c1
	ld a,004h		;71c2
	xor (hl)			;71c4
	ld (hl),a			;71c5
	ret			;71c6
L_71C7:
	ld a,(0e003h)		;71c7
	inc a			;71ca
	ret nz			;71cb
	ld a,(0e05eh)		;71cc
	rra			;71cf
	ret nc			;71d0
	ld hl,0e217h		;71d1
	ld de,0e0c8h		;71d4
	ld bc,00200h		;71d7
L_71DA:
	ld a,(hl)			;71da
	or a			;71db
	jr nz,L_71E3		;71dc
	ld a,(de)			;71de
	cp 040h		;71df
	jr nc,L_71EC		;71e1
L_71E3:
	inc hl			;71e3
	dec de			;71e4
	dec de			;71e5
	dec de			;71e6
	dec de			;71e7
	inc c			;71e8
	djnz L_71DA		;71e9
	ret			;71eb
L_71EC:
	ld a,r		;71ec
	and 060h		;71ee
	or 080h		;71f0
	ld (hl),a			;71f2
	ld hl,071ffh		;71f3
	call L_7203		;71f6
	ld bc,00004h		;71f9
	ldir		;71fc
	ret			;71fe

; ----------------------------------------------------------------------
; DATOS sin identificar  0x71ff..0x7203  (4 bytes)
DATA_71FF:
	defb 010h,078h,098h,00fh	; 71ff

; ======================================================================
; CODIGO 0x7203..0x741f  (540 bytes)
; ======================================================================


L_7203:
	ld de,0e0c0h		;7203
	ld a,c			;7206
	add a,a			;7207
	add a,a			;7208
	add a,a			;7209
	jp L_4027		;720a
L_720D:
	ld hl,0e217h		;720d
	ld bc,00200h		;7210
L_7213:
	push hl			;7213
	push bc			;7214
	ld a,(hl)			;7215
	or a			;7216
	jr z,L_726A		;7217
	ld a,(0e003h)		;7219
	ld b,a			;721c
	and 03fh		;721d
	jr nz,L_7229		;721f
	ld a,r		;7221
	and 007h		;7223
	jr nz,L_7229		;7225
	set 4,(hl)		;7227
L_7229:
	call L_7203		;7229
	ex de,hl			;722c
	call L_708D		;722d
	inc hl			;7230
	ld a,b			;7231
	and 007h		;7232
	jr nz,L_7266		;7234
	ld a,(de)			;7236
	and 060h		;7237
	jr z,L_7246		;7239
	inc (hl)			;723b
	ld b,0c7h		;723c
	bit 6,a		;723e
	jr nz,L_7246		;7240
	ld b,018h		;7242
	dec (hl)			;7244
	dec (hl)			;7245
L_7246:
	ld a,(hl)			;7246
	cp b			;7247
	jr z,L_7257		;7248
	ld a,(0e051h)		;724a
	cp 003h		;724d
	jr c,L_7266		;724f
	ld a,r		;7251
	and 07fh		;7253
	jr nz,L_7266		;7255
L_7257:
	ex de,hl			;7257
	ld a,(hl)			;7258
	xor 060h		;7259
	ld (hl),a			;725b
	and 060h		;725c
	jr nz,L_7262		;725e
	set 5,(hl)		;7260
L_7262:
	ex de,hl			;7262
	dec hl			;7263
	inc (hl)			;7264
	inc hl			;7265
L_7266:
	dec hl			;7266
	call L_7271		;7267
L_726A:
	pop bc			;726a
	pop hl			;726b
	inc hl			;726c
	inc c			;726d
	djnz L_7213		;726e
	ret			;7270
L_7271:
	push de			;7271
	ld d,h			;7272
	ld e,l			;7273
	inc de			;7274
	inc de			;7275
	inc de			;7276
	inc de			;7277
	ld bc,00004h		;7278
	ldir		;727b
	ex de,hl			;727d
	dec hl			;727e
	dec hl			;727f
	ld (hl),09ch		;7280
	dec hl			;7282
	ld a,010h		;7283
	add a,(hl)			;7285
	ld (hl),a			;7286
	pop hl			;7287
	ld a,(0e003h)		;7288
	and 003h		;728b
	ret nz			;728d
	bit 4,(hl)		;728e
	ret z			;7290
	push de			;7291
	dec de			;7292
	ld b,002h		;7293
L_7295:
	ld a,(de)			;7295
	inc a			;7296
	and 00fh		;7297
	jr nz,L_729D		;7299
	or 001h		;729b
L_729D:
	ld (de),a			;729d
	inc de			;729e
	inc de			;729f
	inc de			;72a0
	inc de			;72a1
	djnz L_7295		;72a2
	pop de			;72a4
	cp 00fh		;72a5
	ret nz			;72a7
	res 4,(hl)		;72a8
	push de			;72aa
	push hl			;72ab
	ld hl,0e219h		;72ac
	ld bc,00300h		;72af
L_72B2:
	ld a,(hl)			;72b2
	or a			;72b3
	jr z,L_72BD		;72b4
	inc hl			;72b6
	inc c			;72b7
	djnz L_72B2		;72b8
	pop hl			;72ba
	pop de			;72bb
	ret			;72bc
L_72BD:
	pop de			;72bd
	ld a,(de)			;72be
	ld (hl),a			;72bf
	ld a,r		;72c0
	and 003h		;72c2
	or (hl)			;72c4
	ld (hl),a			;72c5
	pop hl			;72c6
	ld de,0e0f8h		;72c7
	call L_4A41		;72ca
	push de			;72cd
	ld bc,00004h		;72ce
	ldir		;72d1
	pop hl			;72d3
	ld a,010h		;72d4
	add a,(hl)			;72d6
	ld (hl),a			;72d7
	inc hl			;72d8
	inc hl			;72d9
	ld (hl),0f4h		;72da
	ld a,04ah		;72dc
	jp L_7A13		;72de
L_72E1:
	ld hl,0e219h		;72e1
	ld bc,00300h		;72e4
L_72E7:
	ld a,(hl)			;72e7
	or a			;72e8
	jr z,L_7310		;72e9
	push bc			;72eb
	push hl			;72ec
	ex de,hl			;72ed
	ld b,a			;72ee
	ld hl,0e0f8h		;72ef
	call L_4A3B		;72f2
	inc (hl)			;72f5
	push hl			;72f6
	inc hl			;72f7
	ld a,b			;72f8
	and 003h		;72f9
	bit 6,b		;72fb
	jr nz,L_7301		;72fd
	neg		;72ff
L_7301:
	add a,(hl)			;7301
	ld (hl),a			;7302
	inc hl			;7303
	inc hl			;7304
	inc (hl)			;7305
	set 3,(hl)		;7306
	res 7,(hl)		;7308
	pop hl			;730a
	call L_7315		;730b
	pop hl			;730e
	pop bc			;730f
L_7310:
	inc hl			;7310
	inc c			;7311
	djnz L_72E7		;7312
	ret			;7314
L_7315:
	ld b,a			;7315
	ld a,(hl)			;7316
	sub 018h		;7317
	cp 0a9h		;7319
	jr nc,L_7325		;731b
	ld a,b			;731d
	cp 002h		;731e
	jr c,L_7325		;7320
	cp 0f0h		;7322
	ret c			;7324
L_7325:
	ld (hl),0c3h		;7325
	xor a			;7327
	ld (de),a			;7328
	ret			;7329
L_732A:
	ld hl,0e1b5h		;732a
	ld (hl),00ch		;732d
	ld a,(0e003h)		;732f
	and 01fh		;7332
	ret nz			;7334
	inc (hl)			;7335
	ld (0e1b6h),a		;7336
	ld hl,06572h		;7339
	call L_6558		;733c
	xor a			;733f
	ld (0e032h),a		;7340
	ld a,00bh		;7343
	call L_7A13		;7345
	jp L_648B		;7348
L_734B:
	ld a,(0e003h)		;734b
	rra			;734e
	ret nc			;734f
	push af			;7350
	call L_64C5		;7351
	call L_63AC		;7354
	pop af			;7357
	bit 2,a		;7358
	ld a,00ch		;735a
	jr nz,L_735F		;735c
	inc a			;735e
L_735F:
	ld (0e1b5h),a		;735f
	ld hl,0e1b3h		;7362
	ld a,098h		;7365
	sub (hl)			;7367
	ret nc			;7368
	call L_670A		;7369
	ld a,09fh		;736c
	call L_7A13		;736e
	ld a,0c3h		;7371
	ld (0e1b3h),a		;7373
	ld (0e00ch),a		;7376
	ret			;7379
L_737A:
	ret			;737a
L_737B:
	ld a,09fh		;737b
	call L_7A13		;737d
	ld a,(0e1cbh)		;7380
	sub 020h		;7383
	call L_6706		;7385
	ld a,001h		;7388
	ld (0e1b5h),a		;738a
	ld (0e001h),a		;738d
	ld a,00ch		;7390
	jp L_6486		;7392
L_7395:
	call L_6470		;7395
	cp 098h		;7398
	jr nz,L_7395		;739a
	ld hl,0e1f9h		;739c
	ld (hl),000h		;739f
	ld de,0e1fah		;73a1
	ld bc,0005ch		;73a4
	ldir		;73a7
	ld hl,0e0c0h		;73a9
	ld (hl),0c3h		;73ac
	ld de,0e0c1h		;73ae
	ld bc,0000fh		;73b1
	ldir		;73b4
	ld hl,0e05eh		;73b6
	inc (hl)			;73b9
	ld a,(hl)			;73ba
	rra			;73bb
	ld hl,003f0h		;73bc
	jr nc,L_73C4		;73bf
	ld hl,018dfh		;73c1
L_73C4:
	ld (0e057h),hl		;73c4
	ld hl,0e1abh		;73c7
	set 1,(hl)		;73ca
	ld de,(0e1c5h)		;73cc
	inc de			;73d0
	call L_4019		;73d1
	inc a			;73d4
	jr nz,L_741C		;73d5
	ld hl,0e051h		;73d7
	ld a,(hl)			;73da
	add a,001h		;73db
	daa			;73dd
	ld (hl),a			;73de
	ld hl,0e05ch		;73df
	inc (hl)			;73e2
	ld a,(hl)			;73e3
	ld b,a			;73e4
	cp 009h		;73e5
	ld hl,076ceh		;73e7
	jr nz,L_73EF		;73ea
	ld hl,0778ah		;73ec
L_73EF:
	ld (0e250h),hl		;73ef
	ld a,077h		;73f2
	jr nc,L_7400		;73f4
	ld a,b			;73f6
	and 007h		;73f7
	ld hl,0741fh		;73f9
	call L_4022		;73fc
	ld a,(hl)			;73ff
L_7400:
	ld (0e05dh),a		;7400
	ld a,090h		;7403
	call L_7A13		;7405
	ld hl,05937h		;7408
	call L_612C		;740b
	call L_4476		;740e
	call L_52BB		;7411
	call L_4343		;7414
	ld a,00eh		;7417
	jp L_6486		;7419
L_741C:
	jp L_648B		;741c

; ----------------------------------------------------------------------
; DATOS sin identificar  0x741f..0x7427  (8 bytes)
DATA_741F:
	defb 011h,033h,0bbh,0eeh,011h,0bbh,0eeh,011h	; 741f  .3......

; ======================================================================
; CODIGO 0x7427..0x7565  (318 bytes)
; ======================================================================


L_7427:
	xor a			;7427
	ld (0e003h),a		;7428
	ld a,004h		;742b
	ld (0e05fh),a		;742d
	ld a,(0e05eh)		;7430
	rra			;7433
	ld a,08ch		;7434
	jr nc,L_743A		;7436
	ld a,009h		;7438
L_743A:
	call L_7A13		;743a
L_743D:
	xor a			;743d
	ld (0e001h),a		;743e
	ld a,000h		;7441
	jp L_6486		;7443
L_7446:
	call L_7612		;7446
	ld a,(0e1b4h)		;7449
	cp 098h		;744c
	ld a,004h		;744e
	jr nc,L_7453		;7450
	add a,a			;7452
L_7453:
	ld (0e009h),a		;7453
	call L_6490		;7456
	dec hl			;7459
	ld a,098h		;745a
	cp (hl)			;745c
	ret nz			;745d
	ld a,008h		;745e
	ld (0e1b7h),a		;7460
	jp L_648B		;7463
L_7466:
	call L_7612		;7466
	push af			;7469
	ld a,(0e05ch)		;746a
	cp 009h		;746d
	jr nz,L_747E		;746f
	ld a,(0e004h)		;7471
	cp 015h		;7474
	jr nc,L_747E		;7476
	ld hl,075eeh		;7478
	call L_7553		;747b
L_747E:
	ld a,(0e003h)		;747e
	bit 4,a		;7481
	ld a,001h		;7483
	jr nz,L_7488		;7485
	inc a			;7487
L_7488:
	ld (0e1b5h),a		;7488
	pop af			;748b
	ret p			;748c
	ld a,(0e012h)		;748d
	or a			;7490
	ret nz			;7491
	ld a,(0e05ch)		;7492
	cp 009h		;7495
	jr z,L_74EA		;7497
	ld hl,07565h		;7499
	call L_4062		;749c
	ld de,02000h		;749f
	ld (0e241h),de		;74a2
	call L_42DB		;74a6
	ld hl,0e242h		;74a9
	ld de,03991h		;74ac
	call L_66E2		;74af
	ld hl,0b888h		;74b2
	ld de,075a7h		;74b5
	ld bc,00608h		;74b8
	call L_49BC		;74bb
	ld bc,(075ech)		;74be
	ld a,c			;74c2
	ld de,0e241h		;74c3
	ld hl,0e1bch		;74c6
	sub (hl)			;74c9
	daa			;74ca
	ld (de),a			;74cb
	inc hl			;74cc
	inc de			;74cd
	ld a,b			;74ce
	sbc a,(hl)			;74cf
	daa			;74d0
	ld (de),a			;74d1
	ex de,hl			;74d2
	ld de,03a79h		;74d3
	call L_66E2		;74d6
L_74D9:
	ld a,008h		;74d9
	call L_7A13		;74db
	ld a,000h		;74de
	ld (0e1b5h),a		;74e0
L_74E3:
	xor a			;74e3
	ld (0e003h),a		;74e4
	jp L_648B		;74e7
L_74EA:
	ld hl,07600h		;74ea
	call L_7553		;74ed
	ld hl,07595h		;74f0
	call L_4062		;74f3
	jr L_74D9		;74f6
L_74F8:
	ld a,(0e003h)		;74f8
	and 07fh		;74fb
	ret nz			;74fd
	ld a,(0e05ch)		;74fe
	cp 009h		;7501
	jr z,L_74E3		;7503
	ld hl,0757dh		;7505
	call L_449B		;7508
	ld hl,0b888h		;750b
	ld de,075dah		;750e
	ld bc,00608h		;7511
	call L_49BC		;7514
	ld a,080h		;7517
L_7519:
	ld (0e1abh),a		;7519
	call L_4343		;751c
	xor a			;751f
	ld (0e059h),a		;7520
	ld hl,03b83h		;7523
	ld (0e05ah),hl		;7526
	call L_5363		;7529
	ld a,001h		;752c
	ld (0e00dh),a		;752e
	jp L_743D		;7531
L_7534:
	ld a,(0e003h)		;7534
	or a			;7537
	ret nz			;7538
	ld a,020h		;7539
	ld (0e004h),a		;753b
	jp L_648B		;753e
L_7541:
	call L_42B3		;7541
	ret p			;7544
	ld hl,051c5h		;7545
	ld de,0e054h		;7548
	ld bc,0000dh		;754b
	ldir		;754e
	xor a			;7550
	jr L_7519		;7551
L_7553:
	ld de,0390ah		;7553
	ld bc,00303h		;7556
	call L_49A6		;7559
	ld de,03912h		;755c
	ld bc,00303h		;755f
	jp L_49A6		;7562

; ----------------------------------------------------------------------
; DATOS sin identificar  0x7565..0x7612  (173 bytes)
DATA_7565:
	defb 04ah,039h,053h,054h,041h,047h,045h,000h,000h,043h,04ch,045h,041h,052h,0feh,08bh	; 7565  J9STAGE..CLEAR..
	defb 039h,042h,04fh,04eh,055h,053h,040h,0ffh,04ah,039h,004h,003h,084h,006h,088h,089h	; 7575  9BONUS@.J9......
	defb 08ah,004h,003h,080h,08bh,039h,003h,003h,084h,006h,088h,089h,08ah,003h,003h,000h	; 7585  .....9..........
	defb 0a8h,039h,043h,04fh,04eh,047h,052h,041h,054h,055h,04ch,041h,054h,049h,04fh,04eh	; 7595  .9CONGRATULATION
	defb 053h,0ffh,001h,003h,006h,00eh,001h,003h,000h,088h,010h,043h,041h,053h,054h,04ch	; 75a5  S..........CASTL
	defb 045h,014h,000h,081h,010h,005h,001h,082h,018h,014h,000h,088h,003h,00dh,00dh,00fh	; 75b5  E...............
	defb 013h,00dh,00dh,003h,000h,003h,003h,082h,010h,014h,003h,003h,000h,003h,003h,082h	; 75c5  ................
	defb 011h,012h,003h,003h,000h,008h,003h,000h,008h,003h,000h,008h,003h,000h,008h,003h	; 75d5  ................
	defb 000h,008h,003h,000h,008h,003h,000h,003h,020h,0e8h,0e9h,0eah,0eeh,0efh,0f0h,0f4h	; 75e5  ........ .......
	defb 0f5h,0f6h,0e5h,0e6h,0e7h,0ebh,0ech,0edh,0f1h,0f2h,0f3h,0e8h,0e9h,0eah,0eeh,0efh	; 75f5  ................
	defb 0f0h,0fch,0fdh,0feh,0e5h,0e6h,0e7h,0f7h,0ech,0f8h,0f9h,0fah,0fbh	; 7605  .............

; ======================================================================
; CODIGO 0x7612..0x7661  (79 bytes)
; ======================================================================


L_7612:
	ld a,(0e003h)		;7612
	and 007h		;7615
	ret nz			;7617
	ld hl,0e004h		;7618
	dec (hl)			;761b
	ret m			;761c
	ld a,(hl)			;761d
	srl a		;761e
	jr c,L_7624		;7620
	xor 01fh		;7622
L_7624:
	add a,060h		;7624
	ld e,a			;7626
	ld d,038h		;7627
	ld hl,(0e250h)		;7629
	ld a,(hl)			;762c
	inc hl			;762d
	ld h,(hl)			;762e
	ld l,a			;762f
	call L_44BE		;7630
L_7633:
	ld a,(hl)			;7633
	and 07fh		;7634
	ld b,a			;7636
	ld a,(hl)			;7637
	inc hl			;7638
	jr z,L_7657		;7639
	cp b			;763b
L_763C:
	ex af,af'			;763c
	ld a,(hl)			;763d
	exx			;763e
	out (c),a		;763f
	exx			;7641
	ex af,af'			;7642
	jr z,L_7646		;7643
	inc hl			;7645
L_7646:
	push af			;7646
	ld a,020h		;7647
	call L_4027		;7649
	call L_44BE		;764c
	pop af			;764f
	djnz L_763C		;7650
	jr nz,L_7655		;7652
	inc hl			;7654
L_7655:
	jr L_7633		;7655
L_7657:
	ld hl,(0e250h)		;7657
	inc hl			;765a
	inc hl			;765b
	ld (0e250h),hl		;765c
	xor a			;765f
	ret			;7660

; ----------------------------------------------------------------------
; DATOS sin identificar  0x7661..0x77ca  (361 bytes)
DATA_7661:
	defb 014h,088h,080h,014h,089h,080h,014h,006h,080h,014h,08ah,080h,004h,003h,001h,0ceh	; 7661  ................
	defb 009h,003h,001h,0ceh,005h,003h,080h,004h,003h,001h,0cdh,009h,003h,001h,0cdh,005h	; 7671  ................
	defb 003h,080h,004h,003h,001h,0cfh,009h,003h,001h,0cfh,005h,003h,080h,004h,003h,001h	; 7681  ................
	defb 0d0h,009h,003h,001h,0d0h,005h,003h,080h,009h,003h,001h,0d0h,00ah,003h,080h,009h	; 7691  ................
	defb 003h,001h,0cfh,00ah,003h,080h,001h,0cfh,008h,003h,001h,0cfh,00ah,003h,080h,001h	; 76a1  ................
	defb 0cdh,008h,003h,001h,0cdh,00ah,003h,080h,001h,0d0h,008h,003h,001h,0cfh,00ah,003h	; 76b1  ................
	defb 080h,001h,0ceh,008h,003h,001h,0ceh,00ah,003h,080h,014h,003h,080h,061h,076h,064h	; 76c1  .............avd
	defb 076h,067h,076h,06ah,076h,06dh,076h,078h,076h,083h,076h,083h,076h,083h,076h,083h	; 76d1  vgvjvmvxv.v.v.v.
	defb 076h,083h,076h,083h,076h,08eh,076h,08eh,076h,0cbh,076h,0cbh,076h,0cbh,076h,0cbh	; 76e1  v.v.v.v.v.v.v.v.
	defb 076h,099h,076h,099h,076h,0a0h,076h,0a0h,076h,0b9h,076h,0b9h,076h,0a7h,076h,0a7h	; 76f1  v.v.v.v.v.v.v.v.
	defb 076h,0a7h,076h,0a7h,076h,0a7h,076h,0a7h,076h,0b0h,076h,0c2h,076h,002h,003h,004h	; 7701  v.v.v.v.v.v.v...
	defb 0e1h,00dh,0dch,001h,0dah,080h,002h,003h,004h,0e0h,00dh,0dbh,001h,0dah,080h,002h	; 7711  ................
	defb 003h,006h,0e1h,00bh,0dch,001h,0dah,080h,002h,003h,006h,0e0h,00bh,0dbh,001h,0dah	; 7721  ................
	defb 080h,002h,003h,006h,0e1h,004h,0dch,007h,0ddh,001h,0dah,080h,002h,003h,003h,0e0h	; 7731  ................
	defb 001h,0d8h,00dh,0dbh,001h,0dah,080h,002h,003h,003h,0e1h,001h,001h,006h,0dch,007h	; 7741  ................
	defb 0ddh,001h,0dah,080h,002h,003h,003h,0e0h,001h,0d9h,00dh,0dbh,001h,0dah,080h,002h	; 7751  ................
	defb 003h,004h,0e1h,006h,0dch,007h,0ddh,001h,0dah,080h,007h,003h,001h,0dfh,004h,0dch	; 7761  ................
	defb 004h,0ddh,001h,0deh,002h,0ddh,001h,0dah,080h,007h,003h,001h,0dfh,00bh,0dch,001h	; 7771  ................
	defb 0dah,080h,006h,003h,00dh,0dch,001h,0dah,080h,00eh,077h,017h,077h,00eh,077h,017h	; 7781  ..........w.w.w.
	defb 077h,00eh,077h,029h,077h,020h,077h,029h,077h,020h,077h,029h,077h,032h,077h,03dh	; 7791  w.w)w w)w w)w2w=
	defb 077h,048h,077h,055h,077h,048h,077h,017h,077h,060h,077h,029h,077h,060h,077h,029h	; 77a1  wHwUwHw.w`w)w`w)
	defb 077h,06bh,077h,029h,077h,07ah,077h,03dh,077h,083h,077h,055h,077h,083h,077h,017h	; 77b1  wkw)wzw=w.wUw.w.
	defb 077h,083h,077h,029h,077h,07ah,077h,029h,077h	; 77c1  w.w)wzw)w

; ======================================================================
; CODIGO 0x77ca..0x79de  (532 bytes)
; ======================================================================


L_77CA:
	ld hl,0e134h		;77ca
	ld b,028h		;77cd
L_77CF:
	ld a,(hl)			;77cf
	cp 0c0h		;77d0
	jr nz,L_77E0		;77d2
	dec hl			;77d4
	dec hl			;77d5
	ld de,00810h		;77d6
	push bc			;77d9
	call L_5284		;77da
	pop bc			;77dd
	ret c			;77de
	inc hl			;77df
L_77E0:
	inc hl			;77e0
	inc hl			;77e1
	inc hl			;77e2
	djnz L_77CF		;77e3
	and a			;77e5
	ret			;77e6
L_77E7:
	ld b,(hl)			;77e7
	dec hl			;77e8
	ld c,(hl)			;77e9
	push hl			;77ea
	push bc			;77eb
	call L_6FA2		;77ec
	pop bc			;77ef
	ld a,b			;77f0
	sub 010h		;77f1
	ld b,a			;77f3
	ld a,c			;77f4
	sub 008h		;77f5
	ld c,a			;77f7
	xor a			;77f8
	call L_79A4		;77f9
	pop hl			;77fc
	ld de,0e225h		;77fd
	ld bc,00300h		;7800
L_7803:
	ld a,(de)			;7803
	or a			;7804
	jr z,L_780D		;7805
	inc de			;7807
	inc c			;7808
	djnz L_7803		;7809
	jr L_7833		;780b
L_780D:
	push hl			;780d
	ld a,(0e1b2h)		;780e
	cp 005h		;7811
	ld hl,0e1b6h		;7813
	jr z,L_7819		;7816
	inc hl			;7818
L_7819:
	ld a,(hl)			;7819
	pop hl			;781a
	or 0c0h		;781b
	ld (de),a			;781d
	ld de,0e114h		;781e
	call L_4A41		;7821
	ldi		;7824
	ld a,(hl)			;7826
	sub 004h		;7827
	ld (de),a			;7829
	inc de			;782a
	ld a,0ach		;782b
	ld (de),a			;782d
	inc de			;782e
	ld a,006h		;782f
	ld (de),a			;7831
	dec hl			;7832
L_7833:
	ld (hl),0d0h		;7833
	ret			;7835
L_7836:
	ld de,0e225h		;7836
	ld bc,00300h		;7839
L_783C:
	push bc			;783c
	push de			;783d
	ld a,(de)			;783e
	or a			;783f
	jr z,L_785A		;7840
	ld b,a			;7842
	ld hl,0e114h		;7843
	call L_4A3B		;7846
	call L_708D		;7849
	jr nc,L_785A		;784c
	bit 6,b		;784e
	jr z,L_7857		;7850
	call L_7861		;7852
	jr L_785A		;7855
L_7857:
	call L_7881		;7857
L_785A:
	pop de			;785a
	pop bc			;785b
	inc de			;785c
	inc c			;785d
	djnz L_783C		;785e
	ret			;7860
L_7861:
	ld a,(hl)			;7861
	add a,004h		;7862
	ld (hl),a			;7864
	ld b,a			;7865
	inc hl			;7866
	inc (hl)			;7867
	bit 2,a		;7868
	jr nz,L_786E		;786a
	dec (hl)			;786c
	dec (hl)			;786d
L_786E:
	push hl			;786e
	push de			;786f
	ld h,(hl)			;7870
	ld a,b			;7871
	add a,010h		;7872
	ld l,a			;7874
	call L_498C		;7875
	pop de			;7878
	pop hl			;7879
	cp 003h		;787a
	ret z			;787c
	ex de,hl			;787d
	res 6,(hl)		;787e
	ret			;7880
L_7881:
	push de			;7881
	inc hl			;7882
	ld a,(de)			;7883
	ld b,a			;7884
	bit 3,a		;7885
	ld a,002h		;7887
	jr nz,L_788D		;7889
	ld a,0feh		;788b
L_788D:
	add a,(hl)			;788d
	ld (hl),a			;788e
	dec hl			;788f
	dec (hl)			;7890
	bit 1,a		;7891
	jr nz,L_7897		;7893
	inc (hl)			;7895
	inc (hl)			;7896
L_7897:
	push hl			;7897
	pop ix		;7898
	ld a,(hl)			;789a
	add a,014h		;789b
	inc hl			;789d
	ld h,(hl)			;789e
	ld l,a			;789f
	bit 3,b		;78a0
	jr nz,L_78A8		;78a2
	ld a,h			;78a4
	add a,010h		;78a5
	ld h,a			;78a7
L_78A8:
	call L_498C		;78a8
	pop de			;78ab
	sub 0cdh		;78ac
	cp 004h		;78ae
	ret c			;78b0
	push de			;78b1
	ld a,l			;78b2
	sub 008h		;78b3
	ld l,a			;78b5
	call L_498C		;78b6
	pop de			;78b9
	sub 08ch		;78ba
	cp 003h		;78bc
	jr c,L_78C4		;78be
	ex de,hl			;78c0
	set 6,(hl)		;78c1
	ret			;78c3
L_78C4:
	xor a			;78c4
	ld (de),a			;78c5
	ld (ix+000h),0c3h		;78c6
	ex de,hl			;78ca
	ld hl,0e104h		;78cb
	ld bc,00300h		;78ce
L_78D1:
	ld a,e			;78d1
	sub (hl)			;78d2
	inc hl			;78d3
	cp 010h		;78d4
	jr nc,L_78DE		;78d6
	ld a,d			;78d8
	sub (hl)			;78d9
	cp 010h		;78da
	jr c,L_78E7		;78dc
L_78DE:
	inc hl			;78de
	inc hl			;78df
	inc hl			;78e0
	inc c			;78e1
	djnz L_78D1		;78e2
L_78E4:
	jp L_6FC7		;78e4
L_78E7:
	inc hl			;78e7
	inc hl			;78e8
	ld a,(hl)			;78e9
	or a			;78ea
	jr z,L_78E4		;78eb
	ex de,hl			;78ed
	ld hl,0e21ch		;78ee
	ld a,c			;78f1
	add a,a			;78f2
	add a,c			;78f3
	call L_4022		;78f4
	ld (hl),080h		;78f7
	ld hl,0e239h		;78f9
	ld a,(hl)			;78fc
	inc a			;78fd
	cp 003h		;78fe
	ret nc			;7900
	ld (hl),a			;7901
	cp 002h		;7902
	ret z			;7904
	inc hl			;7905
	ld (hl),080h		;7906
	inc hl			;7908
	ld (hl),c			;7909
	dec de			;790a
	ld a,090h		;790b
	ld (de),a			;790d
	ret			;790e
L_790F:
	ld hl,0e23ah		;790f
	ld a,(hl)			;7912
	or a			;7913
	ret z			;7914
	ld b,a			;7915
	ld d,h			;7916
	ld e,l			;7917
	inc hl			;7918
	ld c,(hl)			;7919
	ld hl,0e104h		;791a
	call L_4A3B		;791d
	call L_708D		;7920
	jr nc,L_7939		;7923
	bit 7,b		;7925
	jr z,L_793C		;7927
	ld a,(0e003h)		;7929
	and 007h		;792c
	ret nz			;792e
	call L_71B9		;792f
	bit 3,b		;7932
	ret z			;7934
	ld a,040h		;7935
	ld (de),a			;7937
	ret			;7938
L_7939:
	dec de			;7939
	ld (de),a			;793a
	ret			;793b
L_793C:
	push hl			;793c
	ld e,(hl)			;793d
	inc hl			;793e
	ld a,(hl)			;793f
	bit 0,a		;7940
	ld b,0f8h		;7942
	jr nz,L_7948		;7944
	ld b,0c8h		;7946
L_7948:
	add a,b			;7948
	ld d,a			;7949
	inc hl			;794a
	inc hl			;794b
	ld a,(hl)			;794c
	ld b,0c5h		;794d
	cp 004h		;794f
	jr z,L_7959		;7951
	inc b			;7953
	cp 00fh		;7954
	jr z,L_7959		;7956
	inc b			;7958
L_7959:
	ld a,b			;7959
	ld (0e240h),a		;795a
	ld (0e23eh),de		;795d
	pop hl			;7961
	ld (hl),0c3h		;7962
	ld hl,0e23ch		;7964
L_7967:
	push hl			;7967
	ld de,0e132h		;7968
	ld bc,02800h		;796b
L_796E:
	ld a,(de)			;796e
	cp 0d0h		;796f
	jr z,L_797B		;7971
	inc de			;7973
	inc de			;7974
	inc de			;7975
	inc c			;7976
	djnz L_796E		;7977
	jr L_7992		;7979
L_797B:
	ld (hl),c			;797b
	ld hl,0e23eh		;797c
	ld bc,00003h		;797f
	ldir		;7982
	ex de,hl			;7984
	dec hl			;7985
	dec hl			;7986
	ld a,(hl)			;7987
	add a,018h		;7988
	ld (hl),a			;798a
	ld (0e23fh),a		;798b
	dec hl			;798e
	call L_49B5		;798f
L_7992:
	pop hl			;7992
	inc hl			;7993
	ex de,hl			;7994
	ld hl,0e239h		;7995
	dec (hl)			;7998
	ex de,hl			;7999
	jr nz,L_7967		;799a
	inc de			;799c
	xor a			;799d
	ld (de),a			;799e
	ld a,007h		;799f
	jp L_7A13		;79a1
L_79A4:
	ex af,af'			;79a4
	push bc			;79a5
	ld hl,0e252h		;79a6
	ld bc,00400h		;79a9
L_79AC:
	ld a,(hl)			;79ac
	or a			;79ad
	jr z,L_79B6		;79ae
	inc hl			;79b0
	inc c			;79b1
	djnz L_79AC		;79b2
	jr L_79B8		;79b4
L_79B6:
	set 7,(hl)		;79b6
L_79B8:
	ld hl,0e120h		;79b8
	call L_4A3B		;79bb
	pop bc			;79be
	ex af,af'			;79bf
	ex de,hl			;79c0
	add a,a			;79c1
	ld hl,079deh		;79c2
	call L_4022		;79c5
	ld a,(hl)			;79c8
	inc hl			;79c9
	ld h,(hl)			;79ca
	ex de,hl			;79cb
	ld (hl),c			;79cc
	inc hl			;79cd
	ld (hl),b			;79ce
	inc hl			;79cf
	ld (hl),a			;79d0
	inc hl			;79d1
	ld (hl),00fh		;79d2
	ld e,000h		;79d4
	call L_42DB		;79d6
	ld a,004h		;79d9
	jp L_7A13		;79db

; ----------------------------------------------------------------------
; DATOS sin identificar  0x79de..0x79ee  (16 bytes)
DATA_79DE:
	defb 060h,001h,064h,002h,06ch,004h,080h,006h,068h,005h,08ch,010h,088h,020h,084h,030h	; 79de  `.d.l...h.... .0

; ======================================================================
; CODIGO 0x79ee..0x7a3c  (78 bytes)
; ======================================================================


L_79EE:
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
	ld (hl),000h		;7a03
	ld de,0e120h		;7a05
	call L_4A41		;7a08
	ld a,0c3h		;7a0b
	ld (de),a			;7a0d
L_7A0E:
	inc hl			;7a0e
	inc c			;7a0f
	djnz L_79FA		;7a10
	ret			;7a12
L_7A13:
	di			;7a13
	ld d,000h		;7a14
	call L_7A1B		;7a16
	ei			;7a19
	ret			;7a1a
L_7A1B:
	ld c,a			;7a1b
	ld b,002h		;7a1c
	ld hl,0e012h		;7a1e
	cp 08ch		;7a21
	jr c,L_7A2C		;7a23
	cp 090h		;7a25
	jr c,$+29		;7a27
	inc b			;7a29
	jr $+26		;7a2a
L_7A2C:
	dec b			;7a2c
	and 03fh		;7a2d
	cp 009h		;7a2f
	jr z,$+19		;7a31
	cp 00ah		;7a33
	jr z,$+12		;7a35
	ld hl,0e028h		;7a37
	jr $+10		;7a3a

; ----------------------------------------------------------------------
; DATOS sin identificar  0x7a3c..0x7a41  (5 bytes)
DATA_7A3C:
	defb 021h,012h,0e0h,018h,003h	; 7a3c

; ======================================================================
; CODIGO 0x7a41..0x7b14  (211 bytes)
; ======================================================================


L_7A41:
	ld hl,0e01dh		;7a41
L_7A44:
	dec d			;7a44
	jr z,L_7A5A		;7a45
	ld e,(hl)			;7a47
	ld a,e			;7a48
	and 03fh		;7a49
	ld (hl),a			;7a4b
	ld a,c			;7a4c
	and 03fh		;7a4d
	cp (hl)			;7a4f
	ld (hl),e			;7a50
	ret z			;7a51
	ret c			;7a52
	cp 019h		;7a53
	jr c,L_7A5A		;7a55
	and 03fh		;7a57
	ld c,a			;7a59
L_7A5A:
	add a,a			;7a5a
	ld de,07c58h		;7a5b
	call L_4027		;7a5e
	dec hl			;7a61
	dec hl			;7a62
L_7A63:
	ld (hl),001h		;7a63
	inc hl			;7a65
	ld (hl),001h		;7a66
	inc hl			;7a68
	ld (hl),c			;7a69
	inc hl			;7a6a
	ld a,(de)			;7a6b
	ld (hl),a			;7a6c
	inc hl			;7a6d
	inc de			;7a6e
	ld a,(de)			;7a6f
	ld (hl),a			;7a70
	ld a,005h		;7a71
	add a,l			;7a73
	ld l,a			;7a74
	ld (hl),000h		;7a75
	inc hl			;7a77
	inc hl			;7a78
	inc de			;7a79
	djnz L_7A63		;7a7a
	ret			;7a7c
L_7A7D:
	inc hl			;7a7d
	ld a,(ix+009h)		;7a7e
	inc a			;7a81
	cp (hl)			;7a82
	jp z,L_7BA0		;7a83
	jp m,L_7A8A		;7a86
	dec a			;7a89
L_7A8A:
	ex af,af'			;7a8a
	ld a,(ix+002h)		;7a8b
	push bc			;7a8e
	ld d,001h		;7a8f
	call L_7A1B		;7a91
	pop bc			;7a94
	ex af,af'			;7a95
	ld (ix+009h),a		;7a96
	ret			;7a99
L_7A9A:
	ld a,(0e031h)		;7a9a
	ld e,a			;7a9d
	ld a,c			;7a9e
	cp 001h		;7a9f
	jr z,L_7AA4		;7aa1
	dec a			;7aa3
L_7AA4:
	rlca			;7aa4
	rlca			;7aa5
	rlca			;7aa6
	dec d			;7aa7
	jr z,L_7AAE		;7aa8
	cpl			;7aaa
	and e			;7aab
	jr L_7AAF		;7aac
L_7AAE:
	or e			;7aae
L_7AAF:
	set 1,a		;7aaf
	bit 4,a		;7ab1
	jr z,L_7AB7		;7ab3
	res 1,a		;7ab5
L_7AB7:
	ld (0e031h),a		;7ab7
	ld e,a			;7aba
	ld a,007h		;7abb
	jp 00093h		;7abd   ; BIOS WRTPSG - Writes data to PSG-register
L_7AC0:
	ld a,(0e031h)		;7ac0
	call L_7AB7		;7ac3
	ld c,001h		;7ac6
	ld ix,0e010h		;7ac8
	exx			;7acc
	ld b,003h		;7acd
	ld de,0000bh		;7acf
L_7AD2:
	exx			;7ad2
	ld a,(ix+002h)		;7ad3
	push af			;7ad6
	cp 00bh		;7ad7
	call z,L_7AEA		;7ad9
	pop af			;7adc
	or a			;7add
	call nz,L_7B18		;7ade
	inc c			;7ae1
	inc c			;7ae2
	exx			;7ae3
	add ix,de		;7ae4
	djnz L_7AD2		;7ae6
	exx			;7ae8
	ret			;7ae9
L_7AEA:
	ld hl,0e035h		;7aea
	ld de,07b17h		;7aed
	ld a,(0e032h)		;7af0
	cp 000h		;7af3
	jr z,L_7B07		;7af5
	ld a,002h		;7af7
	add a,(hl)			;7af9
	ld (hl),a			;7afa
	dec hl			;7afb
	jr nc,L_7AFF		;7afc
	inc (hl)			;7afe
L_7AFF:
	dec hl			;7aff
	ld (ix+003h),l		;7b00
	ld (ix+004h),h		;7b03
	ret			;7b06
L_7B07:
	push bc			;7b07
	ex de,hl			;7b08
	ld bc,00004h		;7b09
	lddr		;7b0c
	ex de,hl			;7b0e
	pop bc			;7b0f
	inc hl			;7b10
	inc hl			;7b11
	jr L_7AFF		;7b12

; ----------------------------------------------------------------------
; DATOS sin identificar  0x7b14..0x7b18  (4 bytes)
DATA_7B14:
	defb 001h,021h,0b0h,040h	; 7b14

; ======================================================================
; CODIGO 0x7b18..0x7bda  (194 bytes)
; ======================================================================


L_7B18:
	bit 6,a		;7b18
	ld d,001h		;7b1a
	call z,L_7A9A		;7b1c
	ld a,(ix+002h)		;7b1f
	or a			;7b22
	jp m,L_7BB0		;7b23
	dec (ix+000h)		;7b26
	ret nz			;7b29
L_7B2A:
	ld l,(ix+003h)		;7b2a
	ld h,(ix+004h)		;7b2d
	ld a,(hl)			;7b30
	cp 0feh		;7b31
	jp z,L_7A7D		;7b33
	jr nc,L_7BA0		;7b36
	bit 7,(ix+002h)		;7b38
	jp nz,L_7BDB		;7b3c
	and 0f0h		;7b3f
	cp 020h		;7b41
	jr nz,L_7B4C		;7b43
	ld a,(hl)			;7b45
	and 00fh		;7b46
	ld (ix+001h),a		;7b48
	inc hl			;7b4b
L_7B4C:
	ld a,(hl)			;7b4c
	and 0f0h		;7b4d
	cp 010h		;7b4f
	jr nz,L_7B63		;7b51
	ld a,(hl)			;7b53
	and 01fh		;7b54
	ld e,a			;7b56
	ld a,006h		;7b57
	call 00093h		;7b59   ; BIOS WRTPSG - Writes data to PSG-register
	ld d,000h		;7b5c
	call L_7A9A		;7b5e
	inc hl			;7b61
	ld a,(hl)			;7b62
L_7B63:
	ld b,(ix+002h)		;7b63
	bit 6,b		;7b66
	jr z,L_7B7B		;7b68
	ld a,c			;7b6a
	cp 003h		;7b6b
	ld a,(hl)			;7b6d
	jr nz,L_7B7B		;7b6e
	inc hl			;7b70
	ld (ix+003h),l		;7b71
	ld (ix+004h),h		;7b74
	call L_7B92		;7b77
	ret			;7b7a
L_7B7B:
	and 0f0h		;7b7b
	ld b,a			;7b7d
	xor (hl)			;7b7e
	ld d,a			;7b7f
	inc hl			;7b80
	ld e,(hl)			;7b81
	inc hl			;7b82
	ld (ix+003h),l		;7b83
	ld (ix+004h),h		;7b86
	ex de,hl			;7b89
	call L_7C42		;7b8a
	ld a,b			;7b8d
	rrca			;7b8e
	rrca			;7b8f
	rrca			;7b90
	rrca			;7b91
L_7B92:
	ld h,a			;7b92
	ld a,(ix+001h)		;7b93
	ld (ix+000h),a		;7b96
	add a,003h		;7b99
	ld (ix+008h),a		;7b9b
	jr L_7BD2		;7b9e
L_7BA0:
	xor a			;7ba0
	ld (ix+009h),a		;7ba1
	ld d,001h		;7ba4
	call L_7A9A		;7ba6
	xor a			;7ba9
	ld (ix+002h),a		;7baa
	ld h,a			;7bad
	jr L_7BD2		;7bae
L_7BB0:
	dec (ix+000h)		;7bb0
	jp z,L_7B2A		;7bb3
	dec (ix+008h)		;7bb6
	ld a,(ix+008h)		;7bb9
	cp (ix+000h)		;7bbc
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

; ----------------------------------------------------------------------
; DATOS sin identificar  0x7bda..0x7bdb  (1 bytes)
DATA_7BDA:
	defb 0c9h	; 7bda

; ======================================================================
; CODIGO 0x7bdb..0x7c4e  (115 bytes)
; ======================================================================


L_7BDB:
	and 0f0h		;7bdb
	cp 0d0h		;7bdd
	ld a,(hl)			;7bdf
	jr nz,L_7BE9		;7be0
	and 00fh		;7be2
	ld (ix+00ah),a		;7be4
	inc hl			;7be7
	ld a,(hl)			;7be8
L_7BE9:
	cp 0f0h		;7be9
	jr c,L_7BF4		;7beb
	and 00fh		;7bed
	ld (ix+006h),a		;7bef
	inc hl			;7bf2
	ld a,(hl)			;7bf3
L_7BF4:
	cp 0e0h		;7bf4
	jr c,L_7BFF		;7bf6
	and 00fh		;7bf8
	ld (ix+005h),a		;7bfa
	inc hl			;7bfd
	ld a,(hl)			;7bfe
L_7BFF:
	and 00fh		;7bff
	ld b,a			;7c01
	ld a,(ix+00ah)		;7c02
	jr z,L_7C0C		;7c05
L_7C07:
	add a,(ix+00ah)		;7c07
	djnz L_7C07		;7c0a
L_7C0C:
	ld (ix+001h),a		;7c0c
	ld a,(hl)			;7c0f
	inc hl			;7c10
	ld (ix+003h),l		;7c11
	ld (ix+004h),h		;7c14
	and 0f0h		;7c17
	rrca			;7c19
	rrca			;7c1a
	rrca			;7c1b
	rrca			;7c1c
	ld b,a			;7c1d
	sub 00ch		;7c1e
	ld (ix+007h),a		;7c20
	jr z,L_7C2B		;7c23
	ld a,(ix+006h)		;7c25
	ld (ix+007h),a		;7c28
L_7C2B:
	call L_7B92		;7c2b
	ld a,b			;7c2e
	ld hl,07c4eh		;7c2f
	call L_4022		;7c32
	ld l,(hl)			;7c35
	ld h,000h		;7c36
	ld a,(ix+005h)		;7c38
	or a			;7c3b
	jr z,L_7C42		;7c3c
	ld b,a			;7c3e
L_7C3F:
	add hl,hl			;7c3f
	djnz L_7C3F		;7c40
L_7C42:
	ld a,c			;7c42
	ld e,h			;7c43
	call 00093h		;7c44   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,c			;7c47
	dec a			;7c48
	ld e,l			;7c49
	call 00093h		;7c4a   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;7c4d

; ----------------------------------------------------------------------
; DATOS sin identificar  0x7c4e..0x8000  (946 bytes)
DATA_7C4E:
	defb 06ah,064h,05fh,059h,054h,050h,04bh,047h,043h,03fh,03ch,038h,09dh,07ch,0b5h,07ch	; 7c4e  jd_YTPKGC?<8.|.|
	defb 0ceh,07ch,0ach,07ch,0d9h,07ch,003h,07dh,009h,07dh,056h,07dh,015h,07dh,037h,07dh	; 7c5e  .|.|.|.}.}V}.}7}
	defb 09ch,07ch,09dh,07dh,0d5h,07dh,0deh,07eh,0ffh,07eh,00eh,07eh,046h,07eh,079h,07eh	; 7c6e  .|.}.}.~.~.~F~y~
	defb 017h,07fh,02bh,07fh,043h,07fh,0bdh,07eh,09fh,07eh,083h,07eh,061h,07dh,079h,07dh	; 7c7e  ..+.C..~.~.~a}y}
	defb 09ch,07ch,091h,07dh,09ch,07ch,09ch,07ch,09ch,07ch,09ch,07ch,09ch,07ch,0ffh,021h	; 7c8e  .|.}.|.|.|.|.|.!
	defb 01fh,0e1h,0f0h,02bh,000h,000h,021h,015h,0e1h,040h,02fh,000h,000h,0ffh,022h,0d0h	; 7c9e  ...+..!..@/...".
	defb 0a9h,0d0h,08eh,0d0h,06ah,0feh,002h,021h,0b0h,0e0h,0b0h,0c0h,0b0h,090h,0a0h,060h	; 7cae  ....j..!.......`
	defb 022h,000h,000h,021h,0b1h,010h,0b0h,0e0h,0b0h,0c0h,0a0h,090h,022h,000h,000h,0ffh	; 7cbe  "..!........"...
	defb 021h,0f0h,0c4h,0f0h,0bah,022h,0b0h,09ch,0c0h,081h,0ffh,021h,0d0h,050h,0d0h,053h	; 7cce  !....".....!.P.S
	defb 0d0h,055h,0d0h,065h,0d0h,065h,0d0h,06ah,0d0h,070h,0d0h,075h,0d0h,07ah,0d0h,080h	; 7cde  .U.e.e.j.p.u.z..
	defb 0d0h,088h,0d0h,090h,0d0h,098h,0d0h,0a0h,0d0h,0a8h,0d0h,0b0h,0d0h,0bah,0d0h,095h	; 7cee  ................
	defb 0d0h,0a0h,0d0h,0a8h,0ffh,021h,0f1h,094h,0f0h,0fah,0ffh,023h,0d0h,06bh,0d0h,05fh	; 7cfe  .....!.....#.k._
	defb 0d0h,055h,0d0h,050h,0d0h,047h,0ffh,021h,0c3h,057h,0d3h,05ah,0c3h,052h,0d3h,056h	; 7d0e  .U.P.G.!.W.Z.R.V
	defb 0c3h,051h,0d3h,059h,024h,000h,000h,021h,0c3h,027h,0d3h,02ah,0c3h,022h,0d3h,026h	; 7d1e  .Q.Y$..!.'.*.".&
	defb 0c3h,02ah,0c3h,025h,024h,000h,000h,0feh,0ffh,021h,01bh,00dh,01eh,00dh,01ch,00dh	; 7d2e  .*.%$....!......
	defb 01fh,00dh,01dh,00dh,01ah,00dh,01bh,00dh,017h,00fh,01ch,00fh,019h,00eh,022h,014h	; 7d3e  ..............".
	defb 00dh,015h,00ch,00bh,00ah,009h,008h,0ffh,024h,0b1h,01dh,0b0h,0d5h,0b0h,0a9h,0c0h	; 7d4e  ........$.......
	defb 08eh,0feh,002h,024h,0c0h,0f6h,0b1h,006h,0b1h,016h,022h,0a1h,036h,091h,046h,081h	; 7d5e  ...$......".6.F.
	defb 066h,071h,086h,061h,0b6h,051h,0aeh,024h,000h,000h,0ffh,024h,0c0h,0f0h,0b1h,000h	; 7d6e  fq.a.Q.$...$....
	defb 0b1h,010h,022h,0a1h,030h,091h,040h,081h,060h,071h,080h,061h,0b0h,051h,0a8h,024h	; 7d7e  ..".0.@.`q.a.Q.$
	defb 000h,000h,0ffh,022h,0c2h,005h,0c2h,00eh,0c3h,022h,0c2h,0cch,0c2h,0fbh,0ffh,0d5h	; 7d8e  ..."....."......
	defb 0fch,0e2h,001h,052h,050h,051h,001h,052h,050h,051h,001h,051h,091h,071h,051h,0e1h	; 7d9e  ...RPQ.RPQ.Q.qQ.
	defb 005h,001h,022h,0e2h,0a0h,0a1h,0e1h,021h,002h,0e2h,090h,091h,091h,0a2h,040h,041h	; 7dae  .."....!......@A
	defb 041h,0e1h,005h,001h,022h,0e2h,0a0h,0a1h,0e1h,021h,002h,0e2h,090h,091h,091h,0a2h	; 7dbe  A..."....!......
	defb 040h,041h,041h,053h,0c1h,0feh,0ffh,0d5h,0fdh,0e3h,0c1h,001h,091h,051h,091h,001h	; 7dce  @AAS.........Q..
	defb 091h,051h,091h,001h,091h,051h,091h,001h,091h,051h,091h,021h,0a1h,051h,0a1h,001h	; 7dde  .Q...Q...Q.!.Q..
	defb 091h,051h,091h,001h,071h,041h,071h,0c1h,051h,091h,0e2h,001h,0e3h,021h,0a1h,051h	; 7dee  .Q..qAq.Q....!.Q
	defb 0a1h,001h,091h,051h,091h,001h,071h,041h,071h,0e2h,001h,0e3h,051h,091h,0c1h,0ffh	; 7dfe  ...Q..qAq...Q...
	defb 0d5h,0fdh,0e1h,040h,000h,0e2h,071h,0e1h,040h,000h,0e2h,071h,0b1h,0e1h,021h,023h	; 7e0e  ...@..q.@..q..!#
	defb 020h,0e2h,0b0h,071h,0e1h,020h,0e2h,0b0h,071h,0e1h,001h,041h,043h,040h,000h,0e2h	; 7e1e   ..q. ..q..AC@..
	defb 071h,0e1h,040h,000h,0e2h,071h,0b1h,0e1h,021h,023h,020h,0e2h,0b0h,071h,0e1h,020h	; 7e2e  q.@..q..!# ..q. 
	defb 0e2h,0b0h,071h,0e1h,001h,041h,003h,0ffh,0d5h,0fdh,0e2h,001h,071h,001h,071h,0e3h	; 7e3e  ..q..A......q.q.
	defb 071h,0e2h,051h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h,051h,001h	; 7e4e  q.Q.q.Q.q.Q.q.Q.
	defb 071h,001h,071h,001h,071h,001h,071h,0e3h,071h,0e2h,051h,0e3h,071h,0e2h,051h,0e3h	; 7e5e  q.q.q.q.q.Q.q.Q.
	defb 071h,0e2h,051h,0e3h,071h,0e2h,051h,001h,001h,003h,0ffh,0dfh,0fch,0e2h,0cfh,0d5h	; 7e6e  q.Q.q.Q.........
	defb 0c7h,041h,041h,043h,0ffh,0d5h,0fdh,0e1h,021h,021h,021h,021h,021h,0e2h,0b1h,091h	; 7e7e  .AAC....!!!!!...
	defb 071h,041h,071h,071h,071h,091h,071h,061h,041h,021h,0b3h,0b1h,021h,093h,091h,079h	; 7e8e  qAqqq.qaA!..!..y
	defb 0ffh,0d5h,0fch,0e3h,0c1h,0b1h,0b1h,0b1h,0c1h,0b1h,0b1h,0b1h,0c1h,0b1h,0b1h,0b1h	; 7e9e  ................
	defb 0c1h,0b1h,0b1h,0b1h,0c1h,0b1h,0b1h,0b1h,0e2h,0c1h,001h,001h,001h,0c9h,0ffh,0d5h	; 7eae  ................
	defb 0fbh,0e3h,021h,071h,071h,071h,021h,071h,071h,071h,041h,071h,071h,071h,041h,071h	; 7ebe  ..!qqq!qqqAqqqAq
	defb 071h,071h,021h,071h,071h,071h,021h,061h,061h,061h,071h,021h,0b1h,091h,071h,0ffh	; 7ece  qq!qqq!aaaq!..q.
	defb 0d7h,0fdh,0e1h,000h,020h,040h,050h,071h,071h,090h,0b0h,0e0h,000h,0e1h,090h,071h	; 7ede  .... @Pqq......q
	defb 0c1h,050h,090h,070h,050h,040h,070h,050h,040h,020h,050h,040h,020h,001h,0c1h,0feh	; 7eee  .P.pP@pP@ P@ ...
	defb 002h,0d7h,0fch,0e2h,001h,041h,001h,041h,001h,051h,001h,041h,0e3h,0b1h,0e2h,021h	; 7efe  .....A.A.Q.A...!
	defb 001h,041h,0e3h,071h,0e2h,051h,001h,041h,0ffh,0d3h,0fdh,0e2h,073h,071h,073h,0b1h	; 7f0e  .A.q.Q.A....sqs.
	defb 0e1h,023h,0e2h,0b1h,073h,071h,093h,091h,021h,041h,061h,07bh,0ffh,0d3h,0fdh,0e4h	; 7f1e  .#..sq..!Aa{....
	defb 073h,0e3h,021h,0b3h,021h,0e4h,073h,0e3h,021h,0b3h,0c1h,073h,0c1h,063h,0e2h,001h	; 7f2e  s.!.!.s.!..s.c..
	defb 0e3h,0b3h,0c1h,0b5h,0ffh,0d3h,0fdh,0e3h,0cfh,0c7h,003h,0c1h,025h,073h,0c1h,075h	; 7f3e  ............%s.u
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
