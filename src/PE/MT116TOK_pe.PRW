#INCLUDE "Protheus.ch"

/**
* Função		: MT116TOK
* Autor			: Guilherme Haddad Gouveia
* Data			: 14/12/2010
* Descrição		: Ponto de Entrada para filtrar os registros que serão apresentados no Browse.
*
*/
User Function MT116TOK()

	Local lRET			:= .T.
	Local aArea			:= GetArea()
	Local aAreaSA2		:= SA2->(GetArea())     
	Local aArAlias		:= Lj7GetArea({"SD1","SF1"})
	Local cTitle		:= "Chave Acesso CTE"
	Local cText			:= "Informe a chave de acesso do CTE: "
	Local cPict			:= "@!"
	Local cIdEnt		:= ""
	Local cESPEC		:= cESPECIE      
	Local bValidGet		:= {|| U_VLDCHVNFE(cCHAVENFE)}
	Local nOpc			:= 0
	Local lRET			:= .T.
	Local lVLDCHV		:= SuperGetMv( "ZZ_VLCHVF" , .F. , .T. ,  ) 
	Local cCHAVENFE		:= aNFEDanfe[13]
	Local lIntGfe		:= SuperGetMV("MV_INTGFE",,.F.) //IIF(Empty(Posicione('ZZV',2, xFilial('ZZV') + 'GFE' + cFilAnt, 'ZZV_CAMPNE')), .F., .T. )

	//Private cCHAVENFE	:= CriaVar("F1_CHVNFE")
	//Public  __cCHAVENFE	:= ""
	//Validacao Emissao NFe

	If !lIntGfe
		If lVLDCHV 
			If SA2->A2_ZZEMNFE == "S" .AND. !AllTrim(cESPEC) $ "SPED/CTE"
				Help(" ",1,"INFESPNFE")
				lRET := .F.    
				Return lRET
			ElseIf SA2->A2_ZZEMNFE == "A" .AND. !AllTrim(cESPEC) $ "SPED/CTE/NFPS/CTR/NFST"
				Help(" ",1,"INFESPNFE")
				lRET := .F.
				Return lRET
			ElseIf SA2->A2_ZZEMNFE == "N" .AND. AllTrim(cESPEC) $ "SPED/CTE"
				Help(" ",1,"INFESPNFE")
				lRET := .F.	
				Return lRET
			ElseIf SA2->A2_ZZEMNFE $ "SA" .AND. AllTrim(cESPEC) $ "CTE" .AND. Empty(cCHAVENFE)
				Help(" ",1,"INFCHVNFE")
				lRET := .F.
				Return lRET
			ElseIf SA2->A2_ZZEMNFE $ "SA" .AND. AllTrim(cESPEC) $ "CTE" .AND. !Empty(cCHAVENFE)
				lRet	:= U_VLDCHVNFE(cCHAVENFE)	 //MT100TOK()
			EndIf				
		EndIf
	EndIf

	If lRet .And. AllTrim(cESPEC) == 'CTE'
		aNFEDanfe[18] := "N - Normal"	
	EndIf
	
	If lRET
		Processa( {|| lRET := U_ComA0009()},"Processando notas fiscais do fornecedor....")			
	EndIf

	RestArea(aAreaSA2)
	RestArea(aArea)    
	Lj7RestArea(aArAlias)

Return lRET