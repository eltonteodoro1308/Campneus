#INCLUDE "PROTHEUS.CH"
#DEFINE STR0015  "Informe o Campo Abaixo"
#DEFINE STR0016  "Protocolo"
#DEFINE STR0017  "Retorno Consulta"
#DEFINE STR0018  "Produção"
#DEFINE STR0019  "Homologação"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100TOK  ºAutor  ³Jean Frizo			 º Data ³  23/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar os dados Chave NFe								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT100TOK()
	Local lRetOk := .t.

	If (  IsBlind() ) .And. !UPPER(aLLtRIM(FunName())) $ 'GFEA067/GFEA065' //se é job
		Return .t.
	ElseIf Alltrim(FunName()) == "MATA920" // NF Saida Manual - rotina tbm utilizada para inutilizar NFCE
		Return .t.
	Else
		lRetOk := ZZMT100TOK()	
	EndIf

Return lRetOk

Static Function ZZMT100TOK()

	Local aArea		:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())
	Local cCHAVENFE	:= IIF( AllTrim(FunName()) <> 'SPEDNFE', aNFEDanfe[13], "" )
	Local cESPEC	:= IIF( AllTrim(FunName()) <> 'SPEDNFE', cEspecie , "")
	Local lRET		:= .T.
	Local lFormPro	:= IIF( AllTrim(FunName()) <> 'SPEDNFE', CFORMUL == "S", .F. )
	Local lAMARRNF	:= IIF( AllTrim(FunName()) <> 'SPEDNFE', U_COM041AMRNF(), .F. )
	Local lIntGfe	:= SuperGetMV("MV_INTGFE",,.F.) //IIF(Empty(Posicione('ZZV',2, xFilial('ZZV') + 'GFE' + cFilAnt, 'ZZV_CAMPNE')), .F., .T. )
	Local cIntraGr	:= SuperGetMV("ZZ_FORINTG",.F. ,"61234985|59179838|22301988|24502351")
	Local lOldCod 		:= .f.
	Local nI 			:= 0
	Local nX			:= 0
	Local _lChkTss		:= .f.
	Local _cFam 		:= ""
	Local _cCgcSep		:= ""
	Local lDevVend		:= .F.
	Local _cDescSen1 	:= "Devolução de Venda Atacado"
	Local _cDescSen2 	:= "13"
	Local _cDescSen3 	:= "Dev.Vendas Atacado"
	Local lLibDev    	:= GetNewPar("ZZ_LIBDEV",.T.)
	Local aCNPJTra		:= {}
	Local cPFrete    	:= Alltrim(GetNewPar("MV_XMLPFCT"))	
	Local dDtCaixa 		:= U_FINA032B()
	Local lSemSep		:= .f.
	Local lBlqSep		:= .f.
	Local lTamSep		:= .f.
	Local lQtSep		:= .f.
	Local _nPosNfOri	:= GdFieldPos("D1_NFORI")
	Local _nPosSerOri	:= GdFieldPos("D1_SERIORI")
	Local _nPosCod  	:= GdFieldPos("D1_COD")
	Local _nPosCf 		:= GdFieldPos("D1_CF")
	Local _nPosTes		:= GdFieldPos("D1_TES")
	Local _nPosSep		:= GdFieldPos("D1_ZZSEPU")
	Local _nPosBoni		:= GdFieldPos("D1_ZZPBON")
	Local _nPosTec		:= GdFieldPos("D1_ZZVEND")
	Local _nPosQtd		:= GdFieldPos("D1_QUANT")
	Local _nPosOper		:= GdFieldPos("D1_ZZOPER")
	Local _nPosValSep	:= GdFieldPos("D1_ZZVSEPU")
	Local lFun1			:= .f.
	
	Private lLibEnt    := .f.

	dbSelectArea("SZX")
	dbSetOrder(1)
	If SZX->(dbSeek(xFilial("SZX") + "IDLOG")) // Users logistica
		If __cUserId $ SZX->ZX_COND
			lLibEnt := .t.
		Endif
	Endif
	If SZX->( dbSeek(xFilial("SZX") + "LFUN1") )
		lFun1 := SZX->ZX_FLAG
	Endif

	If Empty( dDtCaixa )
		MsgStop("Operação não permitida com o caixa fechado.","Atenção")
		lRet := .f.
	Else
		If dDataBase <> dDtCaixa
			MsgStop("Operação não permitida, pois o caixa ainda está aberto no dia: " + DtoC( dDtCaixa ),"Atenção")
			lRet := .f.
		Endif
	Endif

	If lRet .and. lFun1 .and. cFormul == "S"
		lRet := U_ZVldSeqNf() // Valida sequencia de notas fiscal de todas as series ativas
	Endif

	If lRet .and. !( AllTrim(FunName()) == 'SPEDNFE' ) 
		If lAMARRNF .And. !lIntGfe
			If Len(aRatAFN) > 0
				If Len(aCols) > 1
					Help(" ",1,"C041ITEM")
					Return .F.
				Else
					U_COM041RatCC()
				EndIf
			Else
				Help(" ",1,"C041OBRIG")
				Alert("Para frete despesa deve ser realizado amarracao com NF Venda.")
				Return .F.
			EndIf
		EndIf

		If(lFormPro .And. AllTrim(cEspecie) <> 'SPED' )
			cEspecie := "SPED"
		EndIf

		If(lFormPro .And. dDEmissao <> dDataBase )
			dDEmissao := dDataBase
		EndIf

		//Validacao Campneus Emissao NFe 
		If !lFormPro .And. ( Funname() == "MATA103" .or. Funname() == "ZZMT103" ) 
			If !cTipo $ "BD" 	
				If SA2->A2_ZZEMNFE == "S" .AND. !AllTrim(cESPEC) $ "SPED/CTE"
					Help(" ",1,"INFESPNFE")
					lRet := .F.
				ElseIf SA2->A2_ZZEMNFE == "A" .AND. !AllTrim(cESPEC) $ "SPED/CTE/NFPS/CTR/NFST"
					Help(" ",1,"INFESPNFE")
					lRet := .F.
				ElseIf SA2->A2_ZZEMNFE == "N" .AND. AllTrim(cESPEC) $ "SPED/CTE"
					Help(" ",1,"INFESPNFE")
					lRet := .F.
				ElseIf SA2->A2_ZZEMNFE $ "SA" .AND. AllTrim(cESPEC) $ "SPED/CTE" .AND. Empty(cCHAVENFE)
					Help(" ",1,"INFCHVNFE")
					lRet := .F.
				ElseIf SA2->A2_ZZEMNFE $ "SA" .AND. !Empty(cCHAVENFE) .AND. AllTrim(cESPEC) $ "SPED/CTE" 
					lRet := U_VLDCHVNFE(cCHAVENFE)
				EndIf
			Endif
		EndIf
	EndIf

	If lRet .and. Funname() == "ZZMT103" .and. !lLibEnt
		//aCNPJTra := StrTokArr( Alltrim(GetNewPar("ZZ_CNPJTRA")), ";")
		For nI := 1 to len(acols)
			If AllTrim(acols[nI,_nPosCod]) == cPFrete // .And. acols[nI,_nPosOper] == '07'
				lRet := .F.
				MsgStop('Todos os documentos de frete devem ser lançados pelo GFE.')
			EndIf
		Next nI
	EndIf
	
	If lRet .and. ( Funname() == "MATA103" .or. Funname() == "ZZMT103" ) // Chamada do Menu == ZZMT103
		For nI := 1 to len(acols)
			_cFam 		:= Posicione("SB1",1,xFilial("SB1")+Substr(aCols[nI,_nPosCod],1,7),"B1_FPCOD")

			If Substr( aCols[nI,_nPosCf] ,2,3 ) $ "403|102|652" // compras de merc.
				If _cFam <> "PX" .and. Substr( aCols[nI,_nPosCod] ,1,2 ) == "PC"
					If Val(Substr( aCols[nI,_nPosCod] ,3,5 )) < 6000 // codigos de pecas anteriores a ABouchar
						lOldCod := .t.
					Endif
				Endif
				//bloqueio de compra de pecas (p.ex. Valvulas) - Alfredo 26/09/2016
				dbSelectArea("ZZV")
				dbSetOrder(2) //tabela+campne
				If dbSeek(xFilial("ZZV") + "BPC" + Alltrim(aCols[nI,_nPosCod]) )
					MsgAlert("O código "+ Alltrim(aCols[nI,_nPosCod]) +" está bloqueado para compra de mercadoria. Em caso de dúvidas, favor contatar a Matriz-Compras.")
					lRet := .f.
					Exit
				Endif
			Endif
			If !( Left(aCols[nI,_nPosCf],1) $ '123' )
				MsgStop("Existe operação inválida para documento de entrada.") 
				lRet := .f.
				Exit
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Validacao SEPU      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCols[nI,_nPosTes] == '466' //Operação 25

				If Empty(aCols[nI,_nPosSep]) .or. Empty(aCols[nI,_nPosTec]) .or. aCols[nI,_nPosBoni] == 0 .or. aCols[nI,_nPosValSep] == 0
					lSemSep := .t.
				Endif
				If !Empty(aCols[nI,_nPosSep])
					If Len(Alltrim(aCols[nI,_nPosSep])) < 7
						lTamSep := .t.
					Else
						dbSelectArea("PA4")
						dbSetOrder(1)
						If dbSeek( xFilial("PA4") + Alltrim(aCols[nI,_nPosSep]) )
							MsgStop("Já existe o SEPU " + Alltrim(aCols[nI,_nPosSep]) + " lançado na Nota fiscal de Entrada: "+;
							Alltrim(PA4->PA4_NFE) + "/"+Alltrim(PA4->PA4_SRNFE) + " incluída em "+ dtoc(PA4->PA4_DTINC),PA4->PA4_FILLOJ)
							lRet := .f.
							Exit
						Endif
					Endif
				Endif

				If 	aCols[nI,_nPosQtd] > 1
					lQtSep := .t.
				Endif
				If cTipo <> 'B'
					MsgStop("Para entrada de Nota fiscal de SEPU, utilize o Tipo da Nota =  B-Beneficiamento") 
					lRet := .f.
					Exit
				Else
					_cCgcSep := Posicione("SA1",1,xFilial("SA1") + cA100For + cLoja,"A1_CGC")
					If Substr(_cCgcSep,1,8) $ cIntraGr
						MsgStop("Código de fornecedor inválido. Foi escolhido um fornecedor do grupo Pirelli.") 
						lRet := .f.
						Exit
					Endif
				Endif
			Else	
				If !Empty(aCols[nI,_nPosSep]) .or. !Empty(aCols[nI,_nPosTec]) .or. aCols[nI,_nPosBoni] > 0 
					lBlqSep := .t.
				Endif	
			Endif
		Next
	Endif

	If lRet
		If lOldCod 
			MsgAlert("Foi digitado código antigo em compra de mercadoria. Favor utilizar os novos códigos a partir do PC06000. ","Support Retail 0800 285 2230")
			lRet := .f.
		Endif
		If lSemSep
			MsgAlert("Favor verificar se todos os campos de Numero do SEPU, Percentual de bonificação, Codigo do avalista ou Valor de Crédito do SEPU foram preenchidos.")
			lRet := .f.
		Endif
		If lTamSep
			MsgAlert("Número do SEPU incorreto. Favor corrigir.")
			lRet := .f.
		Endif
		If lBlqSep
			MsgAlert("Campos de dados de SEPU somente devem ser preenchidos nas operações de SEPU. Favor corrigir.")
			lRet := .f.
		Endif
		If lQtSep
			MsgAlert("Existem itens com quantidade maior que 1. Cada SEPU deve contem apenas 1 produto. Favor corrigir.")
			lRet := .f.
		Endif
	Endif

	If lMT100TOK // Para nao rodar 2 vezes
		lMT100TOK := .f.
	Else
		lMT100TOK := .t.
	Endif

	If lRet .and. lLibDev .and. lMT100TOK .and. CFORMUL == "S" //Alfredo 28/10/16
		// rotina MT100TOK é chamada uma só vez

		For nX:= 1 to Len(aCols)			 
			If  nX == 1 .and. cTipo == "D" .and. Alltrim(aCols[1][_nPosCf]) $ '1411|2411|1202|2202' //Devolucoes de venda
				lDevVend := .T.
				
				dbSelectArea("SL1")
				SL1->( dbSetOrder(2) )
				If SL1->( dbSeek(xFilial("SL1")+aCols[1][_nPosSerOri]+aCols[1][_nPosNfOri]) )
					If !Empty(SL1->L1_NUMATEN) // Para devolucoes  de orcamentos emitidos pelo TMK
						dbSelectArea("SUA")
						SUA->(dbSetOrder(1))
						If SUA->( dbSeek(xFilial("SUA")+SL1->L1_NUMATEN) )
							If SUA->UA_ZZSEGMT == "1"
								_cDescSen1 := "Devolução de Venda Atacado"
								_cDescSen2 := "13"
								_cDescSen3 := "Dev.Vendas Atacado"
							Else
								_cDescSen1 := "Devolução de Venda Varejo"
								_cDescSen2 := "14"
								_cDescSen3 := "Dev.Vendas Varejo"
							Endif
						Endif
					Else	 		
						If SL1->L1_ZZSEGMT == "1" //Atacado
							_cDescSen1 := "Devolução de Venda Atacado"
							_cDescSen2 := "13"
							_cDescSen3 := "Dev.Vendas Atacado"
						Else
							_cDescSen1 := "Devolução de Venda Varejo"
							_cDescSen2 := "14"
							_cDescSen3 := "Dev.Vendas Varejo"
						Endif
					Endif	
				Else 
					_cDescSen1 := "Devolução de Venda Atacado"
					_cDescSen2 := "13"
					_cDescSen3 := "Dev.Vendas Atacado"
				Endif
				If !U_ZValPnsh(_cDescSen1,_cDescSen2,_cDescSen3)
					lRet := .f.
					Exit
				Endif
			Endif
		Next

	//Inclusao + Devolucao
	If lRet .and.  Inclui .And. !Altera .And. cTipo == 'D' .And. lMT100TOK

		DbSelectArea('SF2')
		SF2->(DbSetOrder(2))
		If SF2->( DbSeek(xFilial('SF2') + cA100For + cLoja + Padr( aCols[1][_nPosNfOri] , TamSX3('F2_DOC')[1] )+ Padr( aCols[1][_nPosSerOri], TamSX3('F2_SERIE')[1] ) ))
			If SF2->F2_TPFRETE == 'C'
				If !MsgYesNo('A Nota Fiscal de saida ' + SF2->F2_DOC +'/'+ SF2->F2_SERIE + ' possui frete, foi utilizado o serviço de transporte da mercadoria?','Cancelamento Frete GFE')				

					DbSelectArea('GW1')
					GW1->(DbSetOrder(11))

					If GW1->( DbSeek(xFilial('GW1') + Padr( aCols[1][_nPosSerOri], TamSX3('GW1_SERDC')[1] ) + Padr( aCols[1][_nPosNfOri] , TamSX3('GW1_NRDC')[1] ) )) .And. GW1->GW1_CDTPDC == 'NFS  ' .And. lRet
						If !Empty(GW1->GW1_NRROM)
							lRet := .F.
							MsgStop('Desvincule a nota de saída ' + SF2->F2_DOC +'/'+ SF2->F2_SERIE + ' do romaneio de carga ' + GW1->GW1_NRROM + '.')
						EndIf
					EndIf
					GW1->( DbCloseArea() )

				EndIf					
			EndIf
		EndIf
		
		//Colocar aqui a rotina de cancelamento de nota de funcionario 
		If lDevVend
			lDevVend := lDevVend
		EndIf
		
		SF2->( DbCloseArea() )

	EndIf


		If lRet .And. lDevVend
			//Verifica se a nota de entrada tem frete, caso devolucao parcial não retorna valor do frete
			If aAutoCab[aScan(aAutoCab, { |x| x[1] == "F1_FRETE" } ),2] > 0
				If MaFisRet(,"NF_TOTAL") <> SF2->F2_VALBRUT
					aAutoCab[aScan(aAutoCab, { |x| x[1] == "F1_FRETE" } ),2] := 0
					MaFisAlt("NF_FRETE",0,)
				EndIf
			EndIf
		EndIf

		lMT100TOK := .f.
	Endif		

	RestArea(aAreaSA2)
	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100TOK_PEºAutor  ³Microsiga           º Data ³  04/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VLDCHVNFE(cCHAVENFE, lMsg)

	Local cIdEnt	:= ""
	Local lCHVLD	:= .T.
	Local cQuery	:= ""
	Local cAliasQry2	:= GetNextAlias()
	Local lVLDCHV	:= SuperGetMv( "ZZ_VLDCHV" , .F. , .T. ,  )

	Local _cDescSen1 := "Cnpj da Chave diferente do Cnpj Origem"
	Local _cDescSen2 := "07"
	Local _cDescSen3 := "Fiscal"
	Local _cCgcFor   := Posicione("SA2",1,xFilial("SA2")+cA100For+cLoja,"A2_CGC")  // cA100for == Variavel do padrao do codigo do fornecedor
	Local cCodPirTp  := GETMV("ZZ_PNCFOPC") // 001002 ;0288343
	Default lMsg	 := .T.

	//Verifica se o numero da Chave Digita ja nao foi utilizada
	cQuery := " SELECT F1_CHVNFE " + CRLF
	cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
	cQuery += " WHERE "
	cQuery += " F1_CHVNFE = '" + AllTrim(cCHAVENFE) + "'" + CRLF
	cQuery += " AND F1_STATUS  <> '' " + CRLF
	cQuery += " AND D_E_L_E_T_ = '' " 					 + CRLF
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasQry2, .F., .T.)

	If !(cAliasQry2)->(Eof())
		If lMsg
			Aviso("CHVNFE","Ja existe lançamento com o mesmo número de chave digitado." + CRLF +;
			"Verifique o número da chave digitado na pasta Informacoes do DANFE." ,{"Ok"},1)
		EndIf
		lCHVLD := .F.
	ElseIf SUBSTR(cCHAVENFE,26,9) <> PADL(ALLTRIM(CNFISCAL),9,"0")   //Valida o Numero da NF com a Campo da Nf da Chave
		If lMsg
			Aviso("NUMNFE","O número da chave informado nao confere com o numero da Notas Fiscal digitado" + CRLF +;
			"Verifique se o número da Nota Fiscal ou a Chave da NFe estão corretos." ,{"Ok"},1)
		EndIf
		lCHVLD := .F.
	ElseIf SUBSTR(cCHAVENFE,23,3) <> PADL(ALLTRIM(CSERIE),3,"0") //Valida a serie da NF com a Campo da Nf da Chave
		If lMsg
			Aviso("NUMNFE","O número da chave informado nao confere com o número da série da Notas Fiscal digitado" + CRLF +;
			"Verifique se o número da série da Nota Fiscal ou a Chave da NFe estão corretos." ,{"Ok"},1)
		EndIf
		lCHVLD := .F.
	ElseIf SUBSTR(cCHAVENFE,7,14) <> _cCgcFor //Valida o CGC do fornecedor com a Campo CGC do Emitente.
		If lMsg
			Aviso("NUMCGC","O número da chave informado não confere com o número do Cnpj fornecedor informado." + CRLF +;
			"Verifique se o codigo do fornecedor foi informado corretamente ou a Chave da NFe estão corretos." ,{"Ok"},1)
		EndIf
		lCHVLD := .F.
		If MsgNoYes("Documento foi emitido por Prefeitura?")
			If MsgNoYes("Deseja obter autorização do Depto.Fiscal para incluir este documento?")
				lCHVLD := U_ZValPnsh(_cDescSen1,_cDescSen2,_cDescSen3)
			Endif
		Endif
	EndIf

	//Valida a Chave NFE no SEFAZ NACIONAL

	// O SISTEMA JA FAZ AO DIGITAR A CHAVE NO CAMPO
	If lCHVLD 
		If !cA100For $ cCodPirTp .and. Funname() <> "MATA116"
			//If Left(SA2->A2_CGC,8) <> "59179838"  .or. (Left(SA2->A2_CGC,8) == "59179838".and. Funname() <> "MATA116") 
			If lVLDCHV
				If CTIsReady() //Verifica se a conexao com a Totvs Sped Services pode ser estabelecida
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem o codigo da entidade                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cIdEnt := GetIdEnt()
					If !Empty(cIdEnt)

						lCHVLD := ConsNFeChave(cCHAVENFE,cIdEnt, lMsg )

						If !lCHVLD .and. lLibEnt
							If MsgNoYes("Ocorreu inconsistência na chave informada. Continua a entrada do documento mesmo assim?")
								lCHVLD := .t.
							Endif
						Endif
					Else
						Aviso("SPED","Entidade não encontrada na Totvs Sped Services. Execute o módulo de configuração do serviço",{"Ok"},3)
						lCHVLD := .F.
					EndIf
				Else
					Aviso("SPED","Não foi possível estabelecer conexão como a Totvs Sped Services",{"Ok"},3)
					lCHVLD := .F.
				EndIf
			Endif
		Endif
	EndIf

	(cAliasQry2)->(DbCloseArea())

Return lCHVLD
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100TOK_PEºAutor  ³Microsiga           º Data ³  04/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConsNFeChave(cChaveNFe,cIdEnt, lMsg )

	Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cMensagem	:= ""
	Local oWS
	Local lRetSfz	:= .f.

	oWs:= WsNFeSBra():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cID_ENT    	 := cIdEnt
	ows:cCHVNFE		 := cChaveNFe
	oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

	If oWs:ConsultaChaveNFE()
		cMensagem := ""
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
			cMensagem += "Versão da mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf
		cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0018,STR0019)+CRLF //"Produção"###"Homologação"
		cMensagem += "Cod.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
		cMensagem += STR0015+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
			cMensagem += STR0016+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
		EndIf
		If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE == "100" .AND. oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE == 1
			lRetSfz = .T.
		EndIf
		If lMsg 
			Aviso(STR0017,cMensagem,{"Ok"},3)
		EndIf
	Else
		If lMsg 
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
		EndIf

		lRetSfz = .F.
	EndIf

Return lRetSfz

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Jean Frizo			    ³ Data ³26.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetIdEnt()

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS:= WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf

	RestArea(aArea)

Return(cIdEnt)

