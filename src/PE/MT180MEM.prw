#include "rwmake.ch"
#include "protheus.ch"

/*
	Ponto de entrada do fonte MATA180 para gravar os campos MEMOs customizados ( SYP )
	Ariane Galindo
	11/07/2016
*/
User Function MT180MEM()
	Local aRet := {}
	aAdd(aRet, {'B5_ZZCAPLI', 'B5_ZZMAPLI'})
Return aRet
