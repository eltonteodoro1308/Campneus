#include 'protheus.ch'
#include 'parmtype.ch'

/*
	Este ponto de entrada pertence a rotina de digitação de conhecimento de frete, MATA116().
	É executado na rotina de inclusão do conhecimento de frete, A116INCLUI(),
	quando a tela com o conhecimento e os itens são montados.
	Ariane Galindo
	08/06/2017
*/
User Function MT116GRV()

	If AllTrim(cESPECIE) == 'CTE'
		aNFEDanfe[18] := "N - Normal"	
	EndIf

return