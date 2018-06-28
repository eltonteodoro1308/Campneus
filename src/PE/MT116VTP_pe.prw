#Include "Protheus.ch"

******************************************************************************************************************************************************
// MT116VTP - Waldir Baldin - 30/11/2011 - Rotina de PE, reponsável por pegar os valores digitados na tela de Conhecimento de Frete e 
//											disponibiliza-los para uso em um PE futuro.
******************************************************************************************************************************************************
User Function MT116VTP()
	Local aPar	:= PARAMIXB[01]
	Local lRet	:= .T.
	
	Public __nFrete	:= aPar[13]				// Pega o valor digitado pelo usuário no campo Valor da rotina de NF de Conhecimento de Frete.
	Public __lNewFrete := .t.					// Para executar o calculo do valor do frete toda vez que for um novo frete
	If Empty(aPar[05])						// Testa se não informado o Fornecedor, para poder sair.
		lRet	:= .F.
	EndIf
Return(lRet)
