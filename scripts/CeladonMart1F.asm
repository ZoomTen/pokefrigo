CeladonMart1F_Script:
	call EnableAutoTextBoxDrawing
	ret

CeladonMart1F_TextPointers:
	dw CeladonMart1Text1
	dw CeladonMart1Text2
	dw CeladonMart1Text3

CeladonMart1Text1:
	TX_FAR _CeladonMart1Text1
	db "@"

CeladonMart1Text2:
	TX_FAR _CeladonMart1Text2
	db "@"

CeladonMart1Text3:
	TX_FAR _CeladonMart1Text3
	db "@"
