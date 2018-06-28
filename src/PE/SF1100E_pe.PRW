#Include "Protheus.ch"

/**
* P. de Entrada	: SF1100E
* Autor			: Guilherme Haddad Gouveia
* Data			: 14/10/2010
* Descrição		: Executado antes de deletar o registro no SF1, na exclusao da Nota de Entrada. 
*				  O registro ja se encontra travado (Lock).
*
* Parametros	: na
*
* Retorno		: True/False
*
* Observações:
*
*/

User Function SF1100E() 

	Local lRet   := .T.
	Local oTMsg  := FswTemplMsg():TemplMsg("E",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
	Local dDtCaixa 		:= U_FINA032B()
	Local cSubjMail := ""
	Local cMensMail := ""
	Local _cCgcFor  := ""
	Private _cAmb 	:= GetEnvServer()
	//exclui mensagens da NF
	oTMsg:excMsg()  

	RecLock("SF1",.F.,.T.)		
	SF1->F1_ZZLIBER := " "
	SF1->F1_MENNOTA := Left("EXC " + RetCodUsr() + " - " + AllTrim(FunName()) + " - " + Dtoc(dDataBase) + " - " + Time(), 60) 
	SF1->(MsUnLock())	

	If Alltrim(Upper(_cAmb)) $ "PRODUCAO|ALTER|ALTER2|ALTER3|ALTER4|ECOMMERCE|JOBS|NEOGRID|GEOSALES|WEBSERVICE|LOJA|NFCE"
		If SF1->F1_DTDIGIT <> dDtCaixa 
			
			_cCgcFor := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_CGC" ) 
	
			If Month(SF1->F1_DTDIGIT) <> Month(dDtCaixa)
				cSubjMail := Right(cFilant,3)+"-Exclusão NF Entrada meses anteriores"
				cMensMail := "Email enviado automaticamente pelo sistema Protheus em decorrência de exclusão de nota fiscal de entrada de meses anteriores."
				cMensMail += "<BR>Documento: " + Alltrim(SF1->F1_DOC) + "/" + Alltrim(SF1->F1_SERIE) 
				cMensMail += "<BR>Digitado em: " + Dtoc(SF1->F1_DTDIGIT)   
				cMensMail += "<BR>CNPJ/CPF do fornecedor :" + _cCgcFor
				U_ZZMAIL(nil,"CTB01",cSubjMail,cMensMail)
			Else	
				cSubjMail := Right(cFilant,3)+"-Exclusão NF Entrada dias anteriores"
				cMensMail := "Email enviado automaticamente pelo sistema Protheus em decorrência de exclusão de nota fiscal de entrada de dias anteriores."
				cMensMail += "<BR>Documento: " + Alltrim(SF1->F1_DOC) + "/" + Alltrim(SF1->F1_SERIE) 
				cMensMail += "<BR>Digitado em: " + Dtoc(SF1->F1_DTDIGIT)   
				cMensMail += "<BR>CNPJ/CPF do fornecedor :" + _cCgcFor
				U_ZZMAIL(nil,"FIS01",cSubjMail,cMensMail)
			Endif
		Endif
	Endif

Return(lRet)