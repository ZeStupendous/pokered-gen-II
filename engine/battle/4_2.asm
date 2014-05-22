Func_137aa: ; 137aa (4:77aa)
	ld a, [W_ISLINKBATTLE] ; $d12b
	cp $4
	jr nz, .asm_137eb
	ld a, [W_ENEMYMONNUMBER] ; $cfe8
	ld hl, $d8a8
	ld bc, $2c
	call AddNTimes
	ld a, [W_ENEMYMONSTATUS] ; $cfe9
	ld [hl], a
	call ClearScreen
	callab Func_372d6
	ld a, [$cf0b]
	cp $1
	ld de, YouWinText
	jr c, .asm_137de
	ld de, YouLoseText
	jr z, .asm_137de
	ld de, DrawText
.asm_137de
	FuncCoord 6, 8 ; $c446
	ld hl, Coord
	call PlaceString
	ld c, $c8
	call DelayFrames
	jr .asm_1380a
.asm_137eb
	ld a, [$cf0b]
	and a
	jr nz, .asm_13813
	ld hl, $cce5
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, .asm_1380a
	ld de, wPlayerMoney + 2 ; $d349
	ld c, $3
	ld a, $b
	call Predef ; indirect jump to Func_f81d (f81d (3:781d))
	ld hl, PickUpPayDayMoneyText
	call PrintText
.asm_1380a
	xor a
	ld [$ccd4], a
	ld a, $2a
	call Predef ; indirect jump to Func_3ad1c (3ad1c (e:6d1c))
.asm_13813
	xor a
	ld [$d083], a
	ld [$c02a], a
	ld [W_ISINBATTLE], a ; $d057
	ld [W_BATTLETYPE], a ; $d05a
	ld [W_MOVEMISSED], a ; $d05f
	ld [W_CUROPPONENT], a ; $d059
	ld [$d11f], a
	ld [$d120], a
	ld [$d078], a
	ld hl, $cc2b
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wListScrollOffset], a ; $cc36
	ld hl, $d060
	ld b, $18
.asm_1383e
	ld [hli], a
	dec b
	jr nz, .asm_1383e
	ld hl, $d72c
	set 0, [hl]
	call WaitForSoundToFinish
	call GBPalWhiteOut
	ld a, $ff
	ld [$d42f], a
	ret

YouWinText: ; 13853 (4:7853)
	db "YOU WIN@"

YouLoseText: ; 1385b (4:785b)
	db "YOU LOSE@"

DrawText: ; 13864 (4:7864)
	db "  DRAW@"

PickUpPayDayMoneyText: ; 1386b (4:786b)
	TX_FAR _PickUpPayDayMoneyText
	db "@"

Func_13870: ; 13870 (4:7870)
	ld a, [$cc57]
	and a
	ret nz
	ld a, [$d736]
	and a
	ret nz
	callab Func_c49d
	jr nc, .asm_13888
.asm_13884
	ld a, $1
	and a
	ret
.asm_13888
	callab Func_128d8
	jr z, .asm_13884
	ld a, [$d0db]
	and a
	jr z, .asm_1389e
	dec a
	jr z, .asm_13905
	ld [$d0db], a
.asm_1389e
	FuncCoord 9, 9 ; $c45d
	ld hl, Coord
	ld c, [hl]
	ld a, [W_GRASSTILE]
	cp c
	ld a, [W_GRASSRATE] ; $d887
	jr z, .asm_138c4
	ld a, $14
	cp c
	ld a, [W_WATERRATE] ; $d8a4
	jr z, .asm_138c4
	ld a, [W_CURMAP] ; $d35e
	cp REDS_HOUSE_1F
	jr c, .asm_13912
	ld a, [W_CURMAPTILESET] ; $d367
	cp FOREST ; Viridian Forest/Safari Zone
	jr z, .asm_13912
	ld a, [W_GRASSRATE] ; $d887
.asm_138c4
	ld b, a
	ld a, [H_RAND1] ; $ffd3
	cp b
	jr nc, .asm_13912
	ld a, [H_RAND2] ; $ffd4
	ld b, a
	ld hl, WildMonEncounterSlotChances ; $7918
.asm_138d0
	ld a, [hli]
	cp b
	jr nc, .asm_138d7
	inc hl
	jr .asm_138d0
.asm_138d7
	ld c, [hl]
	ld hl, W_GRASSMONS ; $d888
	FuncCoord 8, 9 ; $c45c
	ld a, [Coord]
	cp $14
	jr nz, .asm_138e5
	ld hl, W_WATERMONS ; $d8a5 (aliases: W_ENEMYMON1HP)
.asm_138e5
	ld b, $0
	add hl, bc
	ld a, [hli]
	ld [W_CURENEMYLVL], a ; $d127
	ld a, [hl]
	ld [$cf91], a
	ld [W_ENEMYMONID], a
	ld a, [$d0db]
	and a
	jr z, .asm_13916
	ld a, [W_PARTYMON1_LEVEL] ; $d18c
	ld b, a
	ld a, [W_CURENEMYLVL] ; $d127
	cp b
	jr c, .asm_13912
	jr .asm_13916
.asm_13905
	ld [$d0db], a
	ld a, $d2
	ld [H_DOWNARROWBLINKCNT2], a ; $ff8c
	call EnableAutoTextBoxDrawing
	call DisplayTextID
.asm_13912
	ld a, $1
	and a
	ret
.asm_13916
	xor a
	ret

WildMonEncounterSlotChances: ; 13918 (4:7918)
; There are 10 slots for wild pokemon, and this is the table that defines how common each of
; those 10 slots is. A random number is generated and then the first byte of each pair in this
; table is compared against that random number. If the random number is less than or equal
; to the first byte, then that slot is chosen.  The second byte is double the slot number.
	db $32, $00 ; 51/256 = 19.9% chance of slot 0
	db $65, $02 ; 51/256 = 19.9% chance of slot 1
	db $8C, $04 ; 39/256 = 15.2% chance of slot 2
	db $A5, $06 ; 25/256 =  9.8% chance of slot 3
	db $BE, $08 ; 25/256 =  9.8% chance of slot 4
	db $D7, $0A ; 25/256 =  9.8% chance of slot 5
	db $E4, $0C ; 13/256 =  5.1% chance of slot 6
	db $F1, $0E ; 13/256 =  5.1% chance of slot 7
	db $FC, $10 ; 11/256 =  4.3% chance of slot 8
	db $FF, $12 ;  3/256 =  1.2% chance of slot 9

RecoilEffect_: ; 1392c (4:792c)
	ld a, [H_WHOSETURN] ; $fff3
	and a
	ld a, [W_PLAYERMOVENUM] ; $cfd2
	ld hl, W_PLAYERMONMAXHP ; $d023
	jr z, .asm_1393d
	ld a, [W_ENEMYMOVENUM] ; $cfcc
	ld hl, W_ENEMYMONMAXHP ; $cff4
.asm_1393d
	ld d, a
	ld a, [W_DAMAGE] ; $d0d7
	ld b, a
	ld a, [W_DAMAGE + 1]
	ld c, a
	srl b
	rr c
	ld a, d
	cp STRUGGLE
	jr z, .asm_13953
	srl b
	rr c
.asm_13953
	ld a, b
	or c
	jr nz, .asm_13958
	inc c
.asm_13958
	ld a, [hli]
	ld [wHPBarMaxHP+1], a
	ld a, [hl]
	ld [wHPBarMaxHP], a
	push bc
	ld bc, $fff2
	add hl, bc
	pop bc
	ld a, [hl]
	ld [wHPBarOldHP], a
	sub c
	ld [hld], a
	ld [wHPBarNewHP], a
	ld a, [hl]
	ld [wHPBarOldHP+1], a
	sbc b
	ld [hl], a
	ld [wHPBarNewHP+1], a
	jr nc, .asm_13982
	xor a
	ld [hli], a
	ld [hl], a
	ld hl, wHPBarNewHP
	ld [hli], a
	ld [hl], a
.asm_13982
	FuncCoord 10, 9 ; $c45e
	ld hl, Coord
	ld a, [H_WHOSETURN] ; $fff3
	and a
	ld a, $1
	jr z, .asm_13990
	FuncCoord 2, 2 ; $c3ca
	ld hl, Coord
	xor a
.asm_13990
	ld [wListMenuID], a ; $cf94
	ld a, $48
	call Predef ; indirect jump to UpdateHPBar (fa1d (3:7a1d))
	ld hl, HitWithRecoilText ; $799e
	jp PrintText
HitWithRecoilText: ; 1399e (4:799e)
	TX_FAR _HitWithRecoilText
	db "@"

ConversionEffect_: ; 139a3 (4:79a3)
	ld hl, W_ENEMYMONTYPE1
	ld de, W_PLAYERMONTYPE1
	ld a, [H_WHOSETURN]
	and a
	ld a, [W_ENEMYBATTSTATUS1]
	jr z, .asm_139b8
	push hl
	ld h, d
	ld l, e
	pop de
	ld a, [W_PLAYERBATTSTATUS1]
.asm_139b8
	bit 6, a ; is mon immune to typical attacks (dig/fly)
	jr nz, PrintButItFailedText
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ld hl, Func_3fba8
	call Func_139d5
	ld hl, ConvertedTypeText
	jp PrintText

ConvertedTypeText: ; 139cd (4:79cd)
	TX_FAR _ConvertedTypeText
	db "@"

PrintButItFailedText: ; 139d2 (4:79d2)
	ld hl, PrintButItFailedText_
Func_139d5: ; 139d5 (4:79d5)
	ld b, BANK(PrintButItFailedText_)
	jp Bankswitch

HazeEffect_: ; 139da (4:79da)
	ld a, $7
	ld hl, wPlayerMonAttackMod
	call Func_13a43
	ld hl, wEnemyMonAttackMod
	call Func_13a43
	ld hl, $cd12
	ld de, W_PLAYERMONATK
	call Func_13a4a
	ld hl, $cd26
	ld de, W_ENEMYMONATTACK
	call Func_13a4a
	ld hl, W_ENEMYMONSTATUS
	ld de, wEnemySelectedMove
	ld a, [H_WHOSETURN]
	and a
	jr z, .asm_13a09
	ld hl, W_PLAYERMONSTATUS
	dec de

.asm_13a09
	ld a, [hl]
	ld [hl], $0
	and $27
	jr z, .asm_13a13
	ld a, $ff
	ld [de], a

.asm_13a13
	xor a
	ld [W_PLAYERDISABLEDMOVE], a
	ld [W_ENEMYDISABLEDMOVE], a
	ld hl, $ccee
	ld [hli], a
	ld [hl], a
	ld hl, W_PLAYERBATTSTATUS1
	call Func_13a37
	ld hl, W_ENEMYBATTSTATUS1
	call Func_13a37
	ld hl, Func_3fba8
	call Func_139d5
	ld hl, StatusChangesEliminatedText
	jp PrintText

Func_13a37: ; 13a37 (4:7a37)
	res 7, [hl]
	inc hl
	ld a, [hl]
	and $78
	ld [hli], a
	ld a, [hl]
	and $f8
	ld [hl], a
	ret

Func_13a43: ; 13a43 (4:7a43)
	ld b, $8
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

Func_13a4a: ; 13a4a (4:7a4a)
	ld b, $8
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ret

StatusChangesEliminatedText: ; 13a53 (4:7a53)
	TX_FAR _StatusChangesEliminatedText
	db "@"

GetTrainerName_: ; 13a58 (4:7a58)
	ld hl, W_GRASSRATE ; $d887
	ld a, [W_ISLINKBATTLE] ; $d12b
	and a
	jr nz, .rival
	ld hl, W_RIVALNAME ; $d34a
	ld a, [W_TRAINERCLASS] ; $d031
	cp SONY1
	jr z, .rival
	cp SONY2
	jr z, .rival
	cp SONY3
	jr z, .rival
	ld [$d0b5], a
	ld a, TRAINER_NAME
	ld [W_LISTTYPE], a
	ld a, $e
	ld [$d0b7], a
	call GetName
	ld hl, $cd6d
.rival
	ld de, W_TRAINERNAME
	ld bc, $d
	jp CopyData
