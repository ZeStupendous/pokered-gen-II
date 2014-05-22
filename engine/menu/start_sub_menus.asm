StartMenu_Pokedex: ; 13095 (4:7095)
	ld a,$29
	call Predef
	call LoadScreenTilesFromBuffer2 ; restore saved screen
	call Delay3
	call LoadGBPal
	call UpdateSprites
	jp RedisplayStartMenu

StartMenu_Pokemon: ; 130a9 (4:70a9)
	ld a,[W_NUMINPARTY]
	and a
	jp z,RedisplayStartMenu
	xor a
	ld [$cc35],a
	ld [$d07d],a
	ld [$cfcb],a
	call DisplayPartyMenu
	jr .checkIfPokemonChosen
.loop
	xor a
	ld [$cc35],a
	ld [$d07d],a
	call GoBackToPartyMenu
.checkIfPokemonChosen
	jr nc,.chosePokemon
.exitMenu
	call GBPalWhiteOutWithDelay3
	call Func_3dbe
	call LoadGBPal
	jp RedisplayStartMenu
.chosePokemon
	call SaveScreenTilesToBuffer1 ; save screen
	ld a,$04
	ld [$d125],a
	call DisplayTextBoxID ; display pokemon menu options
	ld hl,$cd3d
	ld bc,$020c ; max menu item ID, top menu item Y
	ld e,5
.adjustMenuVariablesLoop
	dec e
	jr z,.storeMenuVariables
	ld a,[hli]
	and a
	jr z,.storeMenuVariables
	inc b
	dec c
	dec c
	jr .adjustMenuVariablesLoop
.storeMenuVariables
	ld hl,wTopMenuItemY
	ld a,c
	ld [hli],a ; top menu item Y
	ld a,[$fff7]
	ld [hli],a ; top menu item X
	xor a
	ld [hli],a ; current menu item ID
	inc hl
	ld a,b
	ld [hli],a ; max menu item ID
	ld a,%00000011 ; A button, B button
	ld [hli],a ; menu watched keys
	xor a
	ld [hl],a
	call HandleMenuInput
	push af
	call LoadScreenTilesFromBuffer1 ; restore saved screen
	pop af
	bit 1,a ; was the B button pressed?
	jp nz,.loop
; if the B button wasn't pressed
	ld a,[wMaxMenuItem]
	ld b,a
	ld a,[wCurrentMenuItem] ; menu selection
	cp b
	jp z,.exitMenu ; if the player chose Cancel
	dec b
	cp b
	jr z,.choseSwitch
	dec b
	cp b
	jp z,.choseStats
	ld c,a
	ld b,0
	ld hl,$cd3d
	add hl,bc
	jp .choseOutOfBattleMove
.choseSwitch
	ld a,[W_NUMINPARTY]
	cp a,2 ; is there more than one pokemon in the party?
	jp c,StartMenu_Pokemon ; if not, no switching
	call SwitchPartyMon_Stats
	ld a,$04 ; swap pokemon positions menu
	ld [$d07d],a
	call GoBackToPartyMenu
	jp .checkIfPokemonChosen
.choseStats
	call CleanLCD_OAM
	xor a
	ld [$cc49],a
	ld a,$36
	call Predef
	ld a,$37
	call Predef
	call ReloadMapData
	jp StartMenu_Pokemon
.choseOutOfBattleMove
	push hl
	ld a,[wWhichPokemon]
	ld hl,W_PARTYMON1NAME
	call GetPartyMonName
	pop hl
	ld a,[hl]
	dec a
	add a
	ld b,0
	ld c,a
	ld hl,.outOfBattleMovePointers
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[W_OBTAINEDBADGES] ; badges obtained
	jp [hl]
.outOfBattleMovePointers
	dw .cut
	dw .fly
	dw .surf
	dw .surf
	dw .strength
	dw .flash
	dw .dig
	dw .teleport
	dw .softboiled
.fly
	bit 2,a ; does the player have the Thunder Badge?
	jp z,.newBadgeRequired
	call CheckIfInOutsideMap
	jr z,.canFly
	ld a,[wWhichPokemon]
	ld hl,W_PARTYMON1NAME
	call GetPartyMonName
	ld hl,.cannotFlyHereText
	call PrintText
	jp .loop
.canFly
	call ChooseFlyDestination
	ld a,[$d732]
	bit 3,a ; did the player decide to fly?
	jp nz,.goBackToMap
	call LoadFontTilePatterns
	ld hl,$d72e
	set 1,[hl]
	jp StartMenu_Pokemon
.cut
	bit 1,a ; does the player have the Cascade Badge?
	jp z,.newBadgeRequired
	ld a,$3c
	call Predef
	ld a,[$cd6a]
	and a
	jp z,.loop
	jp CloseTextDisplay
.surf
	bit 4,a ; does the player have the Soul Badge?
	jp z,.newBadgeRequired
	callba CheckForForcedBikeSurf
	ld hl,$d728
	bit 1,[hl]
	res 1,[hl]
	jp z,.loop
	ld a,SURFBOARD
	ld [$cf91],a
	ld [$d152],a
	call UseItem
	ld a,[$cd6a]
	and a
	jp z,.loop
	call GBPalWhiteOutWithDelay3
	jp .goBackToMap
.strength
	bit 3,a ; does the player have the Rainbow Badge?
	jp z,.newBadgeRequired
	ld a,$5b
	call Predef
	call GBPalWhiteOutWithDelay3
	jp .goBackToMap
.flash
	bit 0,a ; does the player have the Boulder Badge?
	jp z,.newBadgeRequired
	xor a
	ld [$d35d],a
	ld hl,.flashLightsAreaText
	call PrintText
	call GBPalWhiteOutWithDelay3
	jp .goBackToMap
.flashLightsAreaText
	TX_FAR _FlashLightsAreaText
	db "@"
.dig
	ld a,ESCAPE_ROPE
	ld [$cf91],a
	ld [$d152],a
	call UseItem
	ld a,[$cd6a]
	and a
	jp z,.loop
	call GBPalWhiteOutWithDelay3
	jp .goBackToMap
.teleport
	call CheckIfInOutsideMap
	jr z,.canTeleport
	ld a,[wWhichPokemon]
	ld hl,W_PARTYMON1NAME
	call GetPartyMonName
	ld hl,.cannotUseTeleportNowText
	call PrintText
	jp .loop
.canTeleport
	ld hl,.warpToLastPokemonCenterText
	call PrintText
	ld hl,$d732
	set 3,[hl]
	set 6,[hl]
	ld hl,$d72e
	set 1,[hl]
	res 4,[hl]
	ld c,60
	call DelayFrames
	call GBPalWhiteOutWithDelay3 ; zero all three palettes and wait 3 V-blanks
	jp .goBackToMap
.warpToLastPokemonCenterText
	TX_FAR _WarpToLastPokemonCenterText
	db "@"
.cannotUseTeleportNowText
	TX_FAR _CannotUseTeleportNowText
	db "@"
.cannotFlyHereText
	TX_FAR _CannotFlyHereText
	db "@"
.softboiled
	ld hl,W_PARTYMON1_MAXHP
	ld a,[wWhichPokemon]
	ld bc,44
	call AddNTimes
	ld a,[hli]
	ld [H_DIVIDEND],a
	ld a,[hl]
	ld [H_DIVIDEND + 1],a
	ld a,5
	ld [H_DIVISOR],a
	ld b,2 ; number of bytes
	call Divide
	ld bc,-33
	add hl,bc
	ld a,[hld]
	ld b,a
	ld a,[H_QUOTIENT + 3]
	sub b
	ld b,[hl]
	ld a,[H_QUOTIENT + 2]
	sbc b
	jp nc,.notHealthyEnough
	ld a,[$cc2b]
	push af
	ld a,POTION
	ld [$cf91],a
	ld [$d152],a
	call UseItem
	pop af
	ld [$cc2b],a
	jp .loop
.notHealthyEnough ; if current HP is less than 1/5 of max HP
	ld hl,.notHealthyEnoughText
	call PrintText
	jp .loop
.notHealthyEnoughText
	TX_FAR _NotHealthyEnoughText
	db "@"
.goBackToMap
	call Func_3dbe
	jp CloseTextDisplay
.newBadgeRequired
	ld hl,.newBadgeRequiredText
	call PrintText
	jp .loop
.newBadgeRequiredText
	TX_FAR _NewBadgeRequiredText
	db "@"

; writes a blank tile to all possible menu cursor positions on the party menu
ErasePartyMenuCursors: ; 132ed (4:72ed)
	FuncCoord 0,1
	ld hl,Coord
	ld bc,2 * 20 ; menu cursor positions are 2 rows apart
	ld a,6 ; 6 menu cursor positions
.loop
	ld [hl]," "
	add hl,bc
	dec a
	jr nz,.loop
	ret

ItemMenuLoop: ; 132fc (4:72fc)
	call LoadScreenTilesFromBuffer2DisableBGTransfer ; restore saved screen
	call GoPAL_SET_CF1C

StartMenu_Item: ; 13302 (4:7302)
	ld a,[W_ISLINKBATTLE]
	dec a
	jr nz,.notInLinkBattle
	ld hl,CannotUseItemsHereText
	call PrintText
	jr .exitMenu
.notInLinkBattle
	ld bc,wNumBagItems
	ld hl,$cf8b
	ld a,c
	ld [hli],a
	ld [hl],b ; store item bag pointer at $cf8b (for DisplayListMenuID)
	xor a
	ld [$cf93],a
	ld a,ITEMLISTMENU
	ld [wListMenuID],a
	ld a,[$cc2c]
	ld [wCurrentMenuItem],a
	call DisplayListMenuID
	ld a,[wCurrentMenuItem]
	ld [$cc2c],a
	jr nc,.choseItem
.exitMenu
	call LoadScreenTilesFromBuffer2 ; restore saved screen
	call LoadTextBoxTilePatterns
	call UpdateSprites ; move sprites
	jp RedisplayStartMenu
.choseItem
; erase menu cursor (blank each tile in front of an item name)
	ld a," "
	FuncCoord 5,4
	ld [Coord],a
	FuncCoord 5,6
	ld [Coord],a
	FuncCoord 5,8
	ld [Coord],a
	FuncCoord 5,10
	ld [Coord],a
	call PlaceUnfilledArrowMenuCursor
	xor a
	ld [$cc35],a
	ld a,[$cf91]
	cp a,BICYCLE
	jp z,.useOrTossItem
.notBicycle1
	ld a,$06 ; use/toss menu
	ld [$d125],a
	call DisplayTextBoxID
	ld hl,wTopMenuItemY
	ld a,11
	ld [hli],a ; top menu item Y
	ld a,14
	ld [hli],a ; top menu item X
	xor a
	ld [hli],a ; current menu item ID
	inc hl
	inc a ; a = 1
	ld [hli],a ; max menu item ID
	ld a,%00000011 ; A button, B button
	ld [hli],a ; menu watched keys
	xor a
	ld [hl],a ; old menu item id
	call HandleMenuInput
	call PlaceUnfilledArrowMenuCursor
	bit 1,a ; was the B button pressed?
	jr z,.useOrTossItem
	jp ItemMenuLoop
.useOrTossItem ; if the player made the choice to use or toss the item
	ld a,[$cf91]
	ld [$d11e],a
	call GetItemName
	call CopyStringToCF4B ; copy name to $cf4b
	ld a,[$cf91]
	cp a,BICYCLE
	jr nz,.notBicycle2
	ld a,[$d732]
	bit 5,a
	jr z,.useItem_closeMenu
	ld hl,CannotGetOffHereText
	call PrintText
	jp ItemMenuLoop
.notBicycle2
	ld a,[wCurrentMenuItem]
	and a
	jr nz,.tossItem
.useItem
	ld [$d152],a
	ld a,[$cf91]
	cp a,HM_01
	jr nc,.useItem_partyMenu
	ld hl,UsableItems_CloseMenu
	ld de,1
	call IsInArray
	jr c,.useItem_closeMenu
	ld a,[$cf91]
	ld hl,UsableItems_PartyMenu
	ld de,1
	call IsInArray
	jr c,.useItem_partyMenu
	call UseItem
	jp ItemMenuLoop
.useItem_closeMenu
	xor a
	ld [$d152],a
	call UseItem
	ld a,[$cd6a]
	and a
	jp z,ItemMenuLoop
	jp CloseStartMenu
.useItem_partyMenu
	ld a,[$cfcb]
	push af
	call UseItem
	ld a,[$cd6a]
	cp a,$02
	jp z,.partyMenuNotDisplayed
	call GBPalWhiteOutWithDelay3
	call Func_3dbe
	pop af
	ld [$cfcb],a
	jp StartMenu_Item
.partyMenuNotDisplayed
	pop af
	ld [$cfcb],a
	jp ItemMenuLoop
.tossItem
	call IsKeyItem
	ld a,[$d124]
	and a
	jr nz,.skipAskingQuantity
	ld a,[$cf91]
	call IsItemHM
	jr c,.skipAskingQuantity
	call DisplayChooseQuantityMenu
	inc a
	jr z,.tossZeroItems
.skipAskingQuantity
	ld hl,wNumBagItems
	call TossItem
.tossZeroItems
	jp ItemMenuLoop

CannotUseItemsHereText: ; 1342a (4:742a)
	TX_FAR _CannotUseItemsHereText
	db "@"

CannotGetOffHereText: ; 1342f (4:742f)
	TX_FAR _CannotGetOffHereText
	db "@"

; items which bring up the party menu when used
UsableItems_PartyMenu: ; 13434 (4:7434)
	db MOON_STONE
	db ANTIDOTE
	db BURN_HEAL
	db ICE_HEAL
	db AWAKENING
	db PARLYZ_HEAL
	db FULL_RESTORE
	db MAX_POTION
	db HYPER_POTION
	db SUPER_POTION
	db POTION
	db FIRE_STONE
	db THUNDER_STONE
	db WATER_STONE
	db HP_UP
	db PROTEIN
	db IRON
	db CARBOS
	db CALCIUM
	db RARE_CANDY
	db LEAF_STONE
	db FULL_HEAL
	db REVIVE
	db MAX_REVIVE
	db FRESH_WATER
	db SODA_POP
	db LEMONADE
	db X_ATTACK
	db X_DEFEND
	db X_SPEED
	db X_SPECIAL
	db PP_UP
	db ETHER
	db MAX_ETHER
	db ELIXER
	db MAX_ELIXER
	db $ff

; items which close the item menu when used
UsableItems_CloseMenu: ; 13459 (4:7459)
	db ESCAPE_ROPE
	db ITEMFINDER
	db POKE_FLUTE
	db OLD_ROD
	db GOOD_ROD
	db SUPER_ROD
	db $ff

StartMenu_TrainerInfo: ; 13460 (4:7460)
	call GBPalWhiteOut
	call ClearScreen
	call UpdateSprites ; move sprites
	ld a,[$ffd7]
	push af
	xor a
	ld [$ffd7],a
	call DrawTrainerInfo
	ld a,$2e
	call Predef ; draw badges
	ld b,$0d
	call GoPAL_SET
	call GBPalNormal
	call WaitForTextScrollButtonPress ; wait for button press
	call GBPalWhiteOut
	call LoadFontTilePatterns
	call LoadScreenTilesFromBuffer2 ; restore saved screen
	call GoPAL_SET_CF1C
	call ReloadMapData
	call LoadGBPal
	pop af
	ld [$ffd7],a
	jp RedisplayStartMenu

; loads tile patterns and draws everything except for gym leader faces / badges
DrawTrainerInfo: ; 1349a (4:749a)
	ld de,RedPicFront
	ld bc,(BANK(RedPicFront) << 8) | $01
	ld a,$3b
	call Predef
	call DisableLCD
	FuncCoord 0,2
	ld hl,Coord
	ld a," "
	call TrainerInfo_DrawVerticalLine
	FuncCoord 1,2
	ld hl,Coord
	call TrainerInfo_DrawVerticalLine
	ld hl,$9070
	ld de,$9000
	ld bc,$01c0
	call CopyData
	ld hl,TrainerInfoTextBoxTileGraphics ; $7b98 ; trainer info text box tile patterns
	ld de,$9770
	ld bc,$0080
	push bc
	call TrainerInfo_FarCopyData
	ld hl,BlankLeaderNames ; $7c28
	ld de,$9600
	ld bc,$0170
	call TrainerInfo_FarCopyData
	pop bc
	ld hl,BadgeNumbersTileGraphics  ; $7d98 ; badge number tile patterns
	ld de,$8d80
	call TrainerInfo_FarCopyData
	ld hl,GymLeaderFaceAndBadgeTileGraphics  ; $6a9e ; gym leader face and badge tile patterns
	ld de,$9200
	ld bc,$0400
	ld a,$03
	call FarCopyData2
	ld hl,TextBoxGraphics ; $6288
	ld de,$00d0
	add hl,de ; hl = colon tile pattern
	ld de,$8d60
	ld bc,$0010
	ld a,$04
	push bc
	call FarCopyData2
	pop bc
	ld hl,TrainerInfoTextBoxTileGraphics + $80  ; $7c18 ; background tile pattern
	ld de,$8d70
	call TrainerInfo_FarCopyData
	call EnableLCD
	ld hl,$cd3d
	ld a,18 + 1
	ld [hli],a
	dec a
	ld [hli],a
	ld [hl],1
	FuncCoord 0,0
	ld hl,Coord
	call TrainerInfo_DrawTextBox
	ld hl,$cd3d
	ld a,16 + 1
	ld [hli],a
	dec a
	ld [hli],a
	ld [hl],3
	FuncCoord 1,10
	ld hl,Coord
	call TrainerInfo_DrawTextBox
	FuncCoord 0,10
	ld hl,Coord
	ld a,$d7
	call TrainerInfo_DrawVerticalLine
	FuncCoord 19,10
	ld hl,Coord
	call TrainerInfo_DrawVerticalLine
	FuncCoord 6,9
	ld hl,Coord
	ld de,TrainerInfo_BadgesText
	call PlaceString
	FuncCoord 2,2
	ld hl,Coord
	ld de,TrainerInfo_NameMoneyTimeText
	call PlaceString
	FuncCoord 7,2
	ld hl,Coord
	ld de,W_PLAYERNAME
	call PlaceString
	FuncCoord 8,4
	ld hl,Coord
	ld de,wPlayerMoney
	ld c,$e3
	call PrintBCDNumber
	FuncCoord 9,6
	ld hl,Coord
	ld de,$da41 ; hours
	ld bc,$4103
	call PrintNumber
	ld [hl],$d6 ; colon tile ID
	inc hl
	ld de,$da43 ; minutes
	ld bc,$8102
	jp PrintNumber

TrainerInfo_FarCopyData: ; 1357f (4:757f)
	ld a,$0b
	jp FarCopyData2

TrainerInfo_NameMoneyTimeText: ; 13584 (4:7584)
	db   "NAME/"
	next "MONEY/"
	next "TIME/@"

; $76 is a circle tile
TrainerInfo_BadgesText: ; 13597 (4:7597)
	db $76,"BADGES",$76,"@"

; draws a text box on the trainer info screen
; height is always 6
; INPUT:
; hl = destination address
; [$cd3d] = width + 1
; [$cd3e] = width
; [$cd3f] = distance from the end of a text box row to the start of the next
TrainerInfo_DrawTextBox: ; 135a0 (4:75a0)
	ld a,$79 ; upper left corner tile ID
	ld de,$7a7b ; top edge and upper right corner tile ID's
	call TrainerInfo_DrawHorizontalEdge ; draw top edge
	call TrainerInfo_NextTextBoxRow
	ld a,[$cd3d] ; width of the text box plus one
	ld e,a
	ld d,0
	ld c,6 ; height of the text box
.loop
	ld [hl],$7c ; left edge tile ID
	add hl,de
	ld [hl],$78 ; right edge tile ID
	call TrainerInfo_NextTextBoxRow
	dec c
	jr nz,.loop
	ld a,$7d ; lower left corner tile ID
	ld de,$777e ; bottom edge and lower right corner tile ID's

TrainerInfo_DrawHorizontalEdge: ; 135c3 (4:75c3)
	ld [hli],a ; place left corner tile
	ld a,[$cd3e] ; width of the text box
	ld c,a
	ld a,d
.loop
	ld [hli],a ; place edge tile
	dec c
	jr nz,.loop
	ld a,e
	ld [hl],a ; place right corner tile
	ret

TrainerInfo_NextTextBoxRow: ; 135d0 (4:75d0)
	ld a,[$cd3f] ; distance to the start of the next row
.loop
	inc hl
	dec a
	jr nz,.loop
	ret

; draws a vertical line
; INPUT:
; hl = address of top tile in the line
; a = tile ID
TrainerInfo_DrawVerticalLine: ; 135d8 (4:75d8)
	ld de,20
	ld c,8
.loop
	ld [hl],a
	add hl,de
	dec c
	jr nz,.loop
	ret

StartMenu_SaveReset: ; 135e3 (4:75e3)
	ld a,[$d72e]
	bit 6,a ; is the player using the link feature?
	jp nz,InitGame
	ld a,$3f
	call Predef ; save the game
	call LoadScreenTilesFromBuffer2 ; restore saved screen
	jp HoldTextDisplayOpen

StartMenu_Option: ; 135f6 (4:75f6)
	xor a
	ld [H_AUTOBGTRANSFERENABLED],a
	call ClearScreen
	call UpdateSprites
	callab DisplayOptionMenu
	call LoadScreenTilesFromBuffer2 ; restore saved screen
	call LoadTextBoxTilePatterns
	call UpdateSprites
	jp RedisplayStartMenu

SwitchPartyMon: ; 13613 (4:7613)
	call SwitchPartyMon_Stats
	ld a, [wWhichTrade] ; $cd3d
	call SwitchPartyMon_OAM
	ld a, [wCurrentMenuItem] ; $cc26
	call SwitchPartyMon_OAM
	jp RedrawPartyMenu_

SwitchPartyMon_OAM: ; 13625 (4:7625)
	push af
	ld hl, wTileMap
	ld bc, $28
	call AddNTimes
	ld c, $28
	ld a, $7f
.asm_13633
	ld [hli], a
	dec c
	jr nz, .asm_13633
	pop af
	ld hl, wOAMBuffer
	ld bc, $10
	call AddNTimes
	ld de, $4
	ld c, e
.asm_13645
	ld [hl], $a0
	add hl, de
	dec c
	jr nz, .asm_13645
	call WaitForSoundToFinish
	ld a, (SFX_02_58 - SFX_Headers_02) / 3
	jp PlaySound

SwitchPartyMon_Stats: ; 13653 (4:7653)
	ld a, [$cc35]
	and a
	jr nz, .asm_13661
	ld a, [wWhichPokemon] ; $cf92
	inc a
	ld [$cc35], a
	ret
.asm_13661
	xor a
	ld [$d07d], a
	ld a, [$cc35]
	dec a
	ld b, a
	ld a, [wCurrentMenuItem] ; $cc26
	ld [wWhichTrade], a ; $cd3d
	cp b
	jr nz, .asm_1367b
	xor a
	ld [$cc35], a
	ld [$d07d], a
	ret
.asm_1367b
	ld a, b
	ld [$cc35], a
	push hl
	push de
	ld hl, W_PARTYMON1 ; $d164
	ld d, h
	ld e, l
	ld a, [wCurrentMenuItem] ; $cc26
	add l
	ld l, a
	jr nc, .asm_1368e
	inc h
.asm_1368e
	ld a, [$cc35]
	add e
	ld e, a
	jr nc, .asm_13696
	inc d
.asm_13696
	ld a, [hl]
	ld [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ld a, [de]
	ld [hl], a
	ld a, [H_DIVIDEND] ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ld [de], a
	ld hl, W_PARTYMON1_NUM ; $d16b (aliases: W_PARTYMON1DATA)
	ld bc, $2c
	ld a, [wCurrentMenuItem] ; $cc26
	call AddNTimes
	push hl
	ld de, $cc97
	ld bc, $2c
	call CopyData
	ld hl, W_PARTYMON1_NUM ; $d16b (aliases: W_PARTYMON1DATA)
	ld bc, $2c
	ld a, [$cc35]
	call AddNTimes
	pop de
	push hl
	ld bc, $2c
	call CopyData
	pop de
	ld hl, $cc97
	ld bc, $2c
	call CopyData
	ld hl, W_PARTYMON1OT ; $d273
	ld a, [wCurrentMenuItem] ; $cc26
	call SkipFixedLengthTextEntries
	push hl
	ld de, $cc97
	ld bc, $b
	call CopyData
	ld hl, W_PARTYMON1OT ; $d273
	ld a, [$cc35]
	call SkipFixedLengthTextEntries
	pop de
	push hl
	ld bc, $b
	call CopyData
	pop de
	ld hl, $cc97
	ld bc, $b
	call CopyData
	ld hl, W_PARTYMON1NAME ; $d2b5
	ld a, [wCurrentMenuItem] ; $cc26
	call SkipFixedLengthTextEntries
	push hl
	ld de, $cc97
	ld bc, $b
	call CopyData
	ld hl, W_PARTYMON1NAME ; $d2b5
	ld a, [$cc35]
	call SkipFixedLengthTextEntries
	pop de
	push hl
	ld bc, $b
	call CopyData
	pop de
	ld hl, $cc97
	ld bc, $b
	call CopyData
	ld a, [$cc35]
	ld [wWhichTrade], a ; $cd3d
	xor a
	ld [$cc35], a
	ld [$d07d], a
	pop de
	pop hl
	ret
