Func_46981: ; 46981 (11:6981)
	xor a
	ld [$d71e], a
	ld a, [$d72d]
	bit 4, a
	ret nz
	call ArePlayerCoordsInArray
	ret nc
	ld a, [wWhichTrade] ; $cd3d
	ld [$d71e], a
	ld hl, $d72d
	set 4, [hl]
	ld hl, $d732
	set 4, [hl]
	ret

Func_469a0: ; 469a0 (11:69a0)
	ld hl, $ffeb
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld de, $0
	ld hl, HiddenObjectMaps ; $6a40
.asm_469ae
	ld a, [hli]
	ld b, a
	cp $ff
	jr z, .asm_469fc
	ld a, [W_CURMAP] ; $d35e
	cp b
	jr z, .asm_469be
	inc de
	inc de
	jr .asm_469ae
.asm_469be
	ld hl, HiddenObjectPointers ; $6a96
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld hl, wWhichTrade ; $cd3d
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	pop hl
.asm_469ce
	ld a, [hli]
	cp $ff
	jr z, .asm_469fc
	ld [$cd40], a
	ld b, a
	ld a, [hli]
	ld [$cd41], a
	ld c, a
	call Func_46a01
	ld a, [$ffea]
	and a
	jr z, .asm_469f0
	inc hl
	inc hl
	inc hl
	inc hl
	push hl
	ld hl, $cd3f
	inc [hl]
	pop hl
	jr .asm_469ce
.asm_469f0
	ld a, [hli]
	ld [wWhichTrade], a ; $cd3d
	ld a, [hli]
	ld [$cd3e], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret
.asm_469fc
	ld a, $ff
	ld [$ffee], a
	ret

Func_46a01: ; 46a01 (11:6a01)
	ld a, [$c109]
	cp $4
	jr z, .asm_46a16
	cp $8
	jr z, .asm_46a25
	cp $c
	jr z, .asm_46a2b
	ld a, [W_YCOORD] ; $d361
	inc a
	jr .asm_46a1a
.asm_46a16
	ld a, [W_YCOORD] ; $d361
	dec a
.asm_46a1a
	cp b
	jr nz, .asm_46a3b
	ld a, [W_XCOORD] ; $d362
	cp c
	jr nz, .asm_46a3b
	jr .asm_46a38
.asm_46a25
	ld a, [W_XCOORD] ; $d362
	dec a
	jr .asm_46a2f
.asm_46a2b
	ld a, [W_XCOORD] ; $d362
	inc a
.asm_46a2f
	cp c
	jr nz, .asm_46a3b
	ld a, [W_YCOORD] ; $d361
	cp b
	jr nz, .asm_46a3b
.asm_46a38
	xor a
	jr .asm_46a3d
.asm_46a3b
	ld a, $ff
.asm_46a3d
	ld [$ffea], a
	ret

INCLUDE "data/hidden_objects.asm"
