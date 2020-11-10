const_value = -1
	const MOVE_NIDORINO_RIGHT
	const MOVE_GENGAR_RIGHT
	const MOVE_GENGAR_LEFT

ANIMATION_END EQU 80

const_value = 3
	const GENGAR_INTRO_TILES1
	const GENGAR_INTRO_TILES2
	const GENGAR_INTRO_TILES3

PlayIntro:
	xor a
	ld [hJoyHeld], a
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a
	call PlayShootingStar
	callab PlayIntroScene
	xor a
	ld [hSCX], a
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearSprites
	call DelayFrame
	ret

InitIntroNidorinoOAM:
	ld hl, wOAMBuffer
	ld d, 0
.loop
	push bc
	ld a, [wBaseCoordY]
	ld e, a
.innerLoop
	ld a, e
	add 8
	ld e, a
	ld [hli], a ; Y
	ld a, [wBaseCoordX]
	ld [hli], a ; X
	ld a, d
	ld [hli], a ; tile
	ld a, OAM_BEHIND_BG
	ld [hli], a ; attributes
	inc d
	dec c
	jr nz, .innerLoop
	ld a, [wBaseCoordX]
	add 8
	ld [wBaseCoordX], a
	pop bc
	dec b
	jr nz, .loop
	ret

IntroClearScreen:
	ld hl, vBGMap1
	ld bc, BG_MAP_WIDTH * SCREEN_HEIGHT
	jr IntroClearCommon

IntroClearMiddleOfScreen:
; clear the area of the tile map between the black bars on the top and bottom
	coord hl, 0, 4
	ld bc, SCREEN_WIDTH * 10

IntroClearCommon:
	ld [hl], 0
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, IntroClearCommon
	ret

IntroPlaceBlackTiles:
	ld a, 1
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	ret

CopyTileIDsFromList_ZeroBaseTileID:
	ld c, 0
	predef_jump CopyTileIDsFromList

PlayShootingStar:
	ld b, SET_PAL_GAME_FREAK_INTRO
	call RunPaletteCommand
	callba LoadCopyrightAndTextBoxTiles
	ldPal a, BLACK, DARK_GRAY, LIGHT_GRAY, WHITE
	ld [rBGP], a
	call UpdateGBCPal_BGP
	ld c, 180
	call DelayFrames
	call ClearScreen
	call DisableLCD
	xor a
	ld [wCurOpponent], a
	call IntroDrawBlackBars
; write the black and white tiles
	ld hl, vChars2
	ld bc, $10
	xor a
	call FillMemory
	ld hl, vChars2 + $10
	ld bc, $10
	ld a, $ff
	call FillMemory
; copy gamefreak logo and others
	ld hl, GameFreakIntro
	ld de, vChars2 + $600
	ld bc, GameFreakIntroEnd - GameFreakIntro
	ld a, BANK(GameFreakIntro)
	call FarCopyData
	ld hl, GameFreakIntro
	ld de, vChars1
	ld bc, GameFreakIntroEnd - GameFreakIntro
	ld a, BANK(GameFreakIntro)
	call FarCopyData
	ld hl, MSU1LogoGFX
	ld de, vChars1 + $300
	ld bc, MSU1LogoGFXEnd - MSU1LogoGFX
	ld a, BANK(MSU1LogoGFX)
	call FarCopyData
	call EnableLCD
	ld hl, rLCDC
	res 5, [hl]
	set 3, [hl]

	ld a, [hGBC]
	cpl			; !GBC
	ld b, a
	ld a, [wOnSGB]
	and b
	call nz, MSU1_Intro	; when purely SGB is detected

	coord hl, 0, 4
	ld bc, 20 * 10
	ld a, $7f
	call FillMemory

	ld c, 64
	call DelayFrames
	callba AnimateShootingStar
	jr c, .next ; skip the delay if the user interrupted the animation
	ld c, 40
	call DelayFrames
.next
	call IntroClearMiddleOfScreen
	call ClearSprites
	jp Delay3

IntroDrawBlackBars:
; clear the screen and draw black bars on the top and bottom
	call IntroClearScreen
	coord hl, 0, 0
	ld c, SCREEN_WIDTH * 4
	call IntroPlaceBlackTiles
	coord hl, 0, 14
	ld c, SCREEN_WIDTH * 4
	call IntroPlaceBlackTiles
	ld hl, vBGMap1
	ld c,  BG_MAP_WIDTH * 4
	call IntroPlaceBlackTiles
	ld hl, vBGMap1 + BG_MAP_WIDTH * 14
	ld c,  BG_MAP_WIDTH * 4
	jp IntroPlaceBlackTiles

EmptyFunc4:
	ret

MSU1_Intro:
	coord hl, 5, 7
	ld a, $B0-1
	ld b, 4
.ou_loop
	ld c, 10
.inn_loop
	inc a
	ld [hli], a
	dec c
	jr nz, .inn_loop
	dec b
	jr z, .fin
	ld de, 10
	add hl, de
	jr .ou_loop
.fin
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	ld c, 3 * 60	; 3 seconds
.wait_for_user
	call CheckForUserInterruption
	ret c
	jr nz, .wait_for_user
	ret

GameFreakIntro:
	INCBIN "gfx/gamefreak_intro.2bpp"
	INCBIN "gfx/gamefreak_logo.2bpp"
	rept 16
	db $00 ; blank tile
	endr
GameFreakIntroEnd:
