#include 'protheus.ch'
#include 'parmtype.ch'

/*
	Este ponto de entrada pertence a rotina de digita��o de conhecimento de frete, MATA116().
	� executado na rotina de inclus�o do conhecimento de frete, A116INCLUI(),
	quando a tela com o conhecimento e os itens s�o montados.
	Ariane Galindo
	08/06/2017
*/
User Function MT116GRV()

	If AllTrim(cESPECIE) == 'CTE'
		aNFEDanfe[18] := "N - Normal"	
	EndIf

return