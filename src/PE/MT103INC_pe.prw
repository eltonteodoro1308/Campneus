#Include "Protheus.ch"

/*
* Rotina		: MT103INC
* Autor			: Waldir Baldin - Totvs Ip Campinas
* Data			: 29/12/2010
* Descrição		: Ponto de Entrada disparado para validar se pode ou não incluir/excluir a nota no conhecimento de frete.
* Parâmetros	: 
* Retorno		: .T. ou .F.
*/   
User Function MT103INC()

Local lComA0015 := .T.
	
	If AllTrim(FunName()) == "MATA116"
		lComA0015	:= u_ComA0015()
	EndIf 
	
Return(lComA0015)
