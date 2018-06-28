#INCLUDE "PROTHEUS.CH"

User Function MA103BUT()
	/*
	retirado para testes GFE
	*/

	Local aArea    := GetArea()
	Local aRet     := {}
	Local lIntGfe	:= SuperGetMV("MV_INTGFE",,.F.)

	//If !lIntGfe
		AAdd( aRet , { "S4WB001N" , {|| U_COMA0041() } , OemToAnsi("Amarracao NF Saida") } )  
	//EndIf
	
	RestArea(aArea)

Return aRet