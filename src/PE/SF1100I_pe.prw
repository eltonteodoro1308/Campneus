#Include "Protheus.ch"
#Define PASTA "\CALL\" //local onde sao gravados os arquivos de senhas a serem enviadas. \protheus_data\atual\

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF1100I   ºAutor  ³Microsiga           º Data ³  03/22/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada apos a gravacao das tabelas de entrada.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 10                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SF1100I()

	Local aArea		:= GetArea()
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local lCmpPne 	:= GetNewpar("ZZ_CMPPNE",.F.)
	Local dDtCaixa 	:= u_FINA032B()
	Local cArqFo	:= ""
	Local cBufferFo	:= ""
	Local cVendFo  	:= ""
	Local cSegmFo	:= "V"
	Local cCgcFo	:= ""
	Local cSerieFo 	:= ""
	Local cSerOriFo	:= ""
	Local cEmisFo	:= ""
	Local cSubSerFo	:= ""
	Local cSubOriFo	:= ""
	Local cCfopFo	:= ""
	Local nPrzMedFo	:= 0
	Local nBIcmFo	:= 0
	Local nVIcmFo  	:= 0 
	Local nVTotFo	:= 0
	Local nVunitFo	:= 0
	Local lBuscatmk	:= .f.
	Local cSubjMail	:= ""
	Local cMensMail	:= ""
	Local aGrupos	:= {}
	Local lTemSL1	:= .f.
	Local cOrcL1	:= ""
	Local cNfVenda	:= ""
	Local cSerVenda	:= ""
	Local dEmisL1	:= CriaVar("L1_EMISNF")
	Local nValDin	:= 0
	Local cZZNome	:= ""
	Local cFilSap 	:= ""
	Local cEmpSap	:= ""
	Local cDirCall := PASTA
	
	Private _cAmb 	:= GetEnvServer()
	Private nHandle:= 0

	dbSelectArea("ZZ0")
	dbSetOrder(1)
	If dbSeek(cFilAnt)
		cFilSap	:= ZZ0->ZZ0_FILSAP
		cEmpSap := ZZ0->ZZ0_EMPSAP
	Else
		If Substr(cFilant,1,2) == "03"
			cEmpSap := "2505"
			cFilSap := Right(cFilant,3)
			If cFilSap == "001"
				cFilSap := "0CP"
			Endif
		Else
			cEmpSap := "0512"
			cFilSap := Right(cFilant,3)
		Endif
	Endif

	If Empty(dDtCaixa) 
		cSubjMail := cFilSap + "-Entrada de documento com caixa fechado"

		cMensMail := "Email enviado automaticamente pelo sistema Protheus em decorrência de entrada de documento com caixa fechado."
		cMensMail += "<BR>Nota de Entrada: " + cNFiscal 
		cMensMail += "<BR>Série: " + cSerie 
		cMensMail += "<BR>Emissão: " + Dtoc(dDEmissao)   
		cMensMail += "<BR>Codigo Fornecedor: " + cA100For
		cMensMail += "<BR>Loja Fornecedor: " + cLoja   
		cMensMail += "<BR>Tipo de entrada: " + cTipo   
		
		U_ZZMAIL(nil,"INFO2",cSubjMail,cMensMail)

		cSubjMail	:= ""
		cMensMail	:= ""

	Elseif dDtCaixa <> dDatabase
		cSubjMail := cFilSap + "-Entrada de documento com caixa de dia diferente"

		cMensMail := "Email enviado automaticamente pelo sistema Protheus em decorrência de entrada de documento com caixa de dia diferente."
		cMensMail += "<BR>Nota de Entrada: " + cNFiscal 
		cMensMail += "<BR>Série: " + cSerie 
		cMensMail += "<BR>Emissão: " + Dtoc(dDEmissao)   
		cMensMail += "<BR>Codigo Fornecedor: " + cA100For
		cMensMail += "<BR>Loja Fornecedor: " + cLoja   
		cMensMail += "<BR>Data do caixa: " + Dtoc(dDtCaixa) 
		cMensMail += "<BR>Tipo de entrada: " + cTipo   
		
		U_ZZMAIL(nil,"INFO2",cSubjMail,cMensMail)

		cSubjMail	:= ""
		cMensMail	:= ""
		
	Endif
	
	If cTipo == "D"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+cA100for+cLoja)
			cZZNome := SA1->A1_NOME
			cCgcFo  := Alltrim(SA1->A1_CGC)
			If lCmpPne .and. Substr(cCgcFo,1,8) == "44622389"
				cCgcFo := U_PNEWFIL(cCgcFo,2)
			Endif
		Endif
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek(xFilial("SF1")+cNFiscal+cSerie+cA100for+cLoja)
			cEmisFo := Dtos(SF1->F1_DTDIGIT)
		Else
			cEmisFo := Dtos(dDataBase)
		Endif
		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek(xFilial("SD1")+cNFiscal+cSerie+cA100for+cLoja)
			While !Eof() .and. SD1->D1_DOC == cNFiscal .and. SD1->D1_SERIE == cSerie .and. SD1->D1_FORNECE == cA100for .and. SD1->D1_LOJA == cLoja
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Montagem do arquivo do faturamento On Line  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(SD1->D1_CF) $ "1202/1411/1661/1662/2202/2411/2661/2662" //Devolucao de venda

					dbSelectArea("SF2")
					dbSetOrder(1)
					If dbSeek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI+cA100for+cLoja)
						dbSelectArea("SA3")
						dbSetOrder(1)
						If dbSeek(xFilial("SA3")+SF2->F2_VEND1)                                                                          
							dbSelectArea("ZZV")
							dbSetOrder(2)
							If dbSeek( xFilial("ZZV") + "FUN" + SA3->A3_ZZMATR )
								cVendFo :=Alltrim(ZZV->ZZV_PNEUAC)
							Else
								cVendFo := RIGHT( AllTrim( SF2->F2_VEND1 ), 5 )
							Endif
						Endif
					Endif

					dbSelectArea("SL1") //Modelo Faturamento
					dbSetOrder(2) // L1_SERIE + L1_DOC
					If dbSeek(xFilial("SL1")+SD1->D1_SERIORI+SD1->D1_NFORI)
						If SL1->L1_DINHEIR > 0
							lTemSL1 	:= .T.
							cOrcL1		:= SL1->L1_NUM
							cNfVenda 	:= SL1->L1_DOC
							cSerVenda 	:= SL1->L1_SERIE
							dEmisL1		:= SL1->L1_EMISNF
							nValDin 	:= SL1->L1_DINHEIR
						Endif
						If !Empty(SL1->L1_ZZSEGMT)
							cSegmFo := Iif(SL1->L1_ZZSEGMT=="1","A","V")
						Else
							lBuscatmk := .t.	
						Endif	
					Else
						lBuscatmk := .t.		
					Endif

					If lBuscatmk
						dbSelectArea("SL1")
						dbSetOrder(18) // L1_ZZSER + L1_ZZDOC
						If dbSeek(xFilial("SL1")+SD1->D1_SERIORI+SD1->D1_NFORI) //Modelo com televendas
							If SL1->L1_DINHEIR > 0
								lTemSL1 	:= .T.
								cOrcL1		:= SL1->L1_NUM
								cNfVenda	:= SL1->L1_DOC
								cSerVenda 	:= SL1->L1_SERIE
								dEmisL1		:= SL1->L1_EMISNF
								nValDin 	:= SL1->L1_DINHEIR
							Endif
							If !Empty(SL1->L1_NUMATEN)
								dbSelectArea("SUA")
								dbSetOrder(1)
								If dbSeek(xFilial("SUA")+SL1->L1_NUMATEN)
									cSegmFo	  := Iif(SUA->UA_ZZSEGMT=="1","A","V")
									nPrzMedFo := SUA->UA_ZZPRZAL
								Endif
							Endif
						Endif
					Endif

					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial("SF4")+SD1->D1_TES) 

					If Substr(SF4->F4_ZZCPNAT,1,1) == "X"
						cCfopFO := Alltrim(SF4->F4_CF)+cSegmFo + Substr(SF4->F4_ZZCPNAT,2,2)
					Else
						cCfopFO := Alltrim(SF4->F4_CF)+Alltrim(SF4->F4_ZZCPNAT)
					Endif

					If Substr(SD1->D1_SERIE,1,1)== "C"
						cSerieFO:="ECF"
						cSubSerFO:=Substr(SD1->D1_SERIE,2,2)
					ElseIf Substr(SD1->D1_SERIE,1,1)== "U"
						cSerieFO:="1"
						cSubSerFO:=""
					Else
						cSerieFO:=Alltrim(SD1->D1_SERIE)
						cSubSerFO:=""
					Endif
					If Substr(SD1->D1_SERIORI,1,1)== "C"
						cSerOriFO:="ECF"
						cSubOriFO:=Substr(SD1->D1_SERIORI,2,2)
					ElseIf Substr(SD1->D1_SERIORI,1,1)== "U"
						cSerOriFO:="1"
						cSubOriFO:=""
					Else
						cSerOriFO:=Alltrim(SD1->D1_SERIORI)
						cSubOriFO:=""
					Endif
					If Substr(SD1->D1_COD,1,2) <> "PS"
						If SF4->F4_CREDICM == "S"
							nBIcmFo := SD1->D1_BASEICM
							nVIcmFo	:= SD1->D1_VALICM
						Endif	
					Else
						nBIcmFo := 0
						nVIcmFo	:= 0
					Endif

					nVTotFo:=SD1->D1_TOTAL - SD1->D1_VALDESC
					nVunitFo:=Round(nVTotFo / SD1->D1_QUANT,2)

					cBufferFO:=cBufferFO+"FO$"+;
					cEmpSap+"$"+;
					cFilSap+"$"+;
					cEmisFo+;
					"$ND$"+;
					Right(SD1->D1_DOC,6)+"$"+;
					cSerieFO+"$"+;
					cSubSerFO+"$"+;
					cCgcFo+"$"+;
					cVendFo+"$"+;
					Alltrim(SD1->D1_COD)+"$"+;
					Alltrim(STR(SD1->D1_QUANT))+"$"+;
					StrZero(nVunitFo*100,8)+"$"+;
					StrZero(nVTotFo*100,8)+"$"+;
					StrZero(nBIcmFo*100,8)+"$"+;
					StrZero(nVIcmFo*100,8)+"$"+;
					StrZero(SD1->D1_VALIPI*100,8)+"$"+;
					StrZero(SD1->D1_BRICMS*100,8)+"$"+;
					StrZero(SD1->D1_ICMSRET*100,8)+"$"+;
					StrZero(SD1->D1_VALISS*100,8)+"$"+;
					cCfopFO+"$"+;
					Right(SD1->D1_NFORI,6)+"$"+;
					cSerOriFo+"$"+;
					cSubOriFo+"$"+;
					cSegmFo+"$"+;
					StrZero(nPrzMedFO*100,8)+"$$$$$"+chr(13)+chr(10)
				Endif
				nBIcmFo := 0
				nVIcmFo	:= 0
				SD1->(dbSkip())
			End
		Endif
		//Envio de email para controle de estorno pagto dinheiro
		If lTemSL1

			dbSelectArea("ZZV")
			dbSetOrder(2) //FIL+TABELA+CAMPNE
			If dbSeek( xFilial("ZZV") + "GEF" + cFilAnt)
				While !Eof() .and. ZZV->ZZV_TABELA == "GEF" .and. Alltrim(ZZV->ZZV_CAMPNE) == cFilAnt
					aadd(aGrupos,Alltrim(ZZV->ZZV_CHAVE) )
					dbSkip()
				Enddo
			Endif

			cSubjMail := Right(cFilAnt,3)+"-Aviso de devolucao de venda com pagto em dinheiro"

			cMensMail := "Email enviado automaticamente pelo sistema Protheus em decorrência de devolucao de venda com pagto em dinheiro."
			cMensMail += "<BR>Nota de Devolução: " + cNFiscal 
			cMensMail += "<BR>Série de Devolução: " + cSerie 
			cMensMail += "<BR>Orçamento: " + cOrcL1 
			cMensMail += "<BR>Emissão: " + Dtoc(dEmisL1)   
			cMensMail += "<BR>Nota fiscal Venda: " + cNfVenda  
			cMensMail += "<BR>Serie Venda: " + cSerVenda   
			cMensMail += "<BR>Valor R$: " + Alltrim(Str(nValDin,15,2))
			cMensMail += "<BR>CNPJ/CPF do Cliente: " + cCgcFO
			cMensMail += "<BR>Nome do Cliente: " + cZZNome

			U_ZZMAIL(nil,"GCDIN",cSubjMail,cMensMail,aGrupos)
		Endif
	Endif

	If cTipo == "C" .and. !Empty(dDtCaixa) .and. dDtCaixa <> dDatabase// Frete lancado com caixa aberto em data anterior ao ddatabase
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek(xFilial("SF1") + cNFiscal + cSerie + cA100for + cLoja)
			If RecLock("SF1",.f.)
				SF1->F1_DTDIGIT := dDtCaixa
				SF1->( MsUnLock() )
				SF1->( dbCommit() )
			Endif
		Endif
		dbSelectArea("SF3")
		dbSetOrder(4)
		If dbSeek(xFilial("SF3") + cA100for + cLoja + cNFiscal + cSerie )
			While !SF3->( Eof() ) .and. SF3->F3_FILIAL == xFilial("SF3") .and. SF3->F3_CLIEFOR == cA100for .and.;
			SF3->F3_LOJA == cLoja .and. SF3->F3_NFISCAL == cNFiscal .and. SF3->F3_SERIE ==  cSerie
				If RecLock("SF3",.f.)
					SF3->F3_ENTRADA := dDtCaixa
					SF3->( MsUnLock() )
					SF3->( dbCommit() )
				Endif
				SF3->( dbSkip() )
			Enddo
		Endif	

		dbSelectArea("SFT")
		dbSetOrder(1)
		If dbSeek(xFilial("SFT") + "E" + cSerie + cNFiscal + cA100for + cLoja )
			While !SFT->( Eof() ) .and. SFT->FT_FILIAL == xFilial("SFT") .and. SFT->FT_CLIEFOR == cA100for .and. ;
			SFT->FT_LOJA == cLoja .and. SFT->FT_NFISCAL == cNFiscal .and. SFT->FT_SERIE ==  cSerie
				If RecLock("SFT",.f.)
					SFT->FT_ENTRADA := dDtCaixa
					SFT->( MsUnLock() )
					SFT->( dbCommit() )
				Endif
				SFT->( dbSkip() )
			Enddo
		Endif	

		dbSelectArea("SF8")
		dbSetOrder(3)
		If dbSeek(xFilial("SF8") + cNFiscal + cSerie + cA100for + cLoja)
			While SF8->(!Eof()) .and. SF8->F8_NFDIFRE == cNFiscal .and. SF8->F8_SEDIFRE == cSerie .and.;
			SF8->F8_TRANSP == cA100for .and. SF8->F8_LOJTRAN == cLoja
				If RecLock("SF8",.f.)
					SF8->F8_DTDIGIT := dDtCaixa
					SF8->( MsUnLock() )
					SF8->( dbCommit() )
				Endif
				SF8->( dbSkip() )
			Enddo
		Endif
	Endif


	If !Empty(cBufferFO)
		If Alltrim(Upper(_cAmb)) $ "PRODUCAO|ALTER|ALTER2|ALTER3|ALTER4|ECOMMERCE|JOBS|NEOGRID|GEOSALES|WEBSERVICE|LOJA|NFCE"
			cArqFo:="FOND"+cEmpSap+cFilSap+Right(cNfiscal,6)+Dtos(date()) + StrTran(Time(),":") + ".TXT"
		Else
			cArqFo:="DESENV_FOND"+cEmpSap+cFilSap+Right(cNfiscal,6)+Dtos(date()) + StrTran(Time(),":") + ".TXT"
		EndIf

		If File(cDirCall+cArqFo)
			FWrite(nHandle,cBufferFO)
			dbCommit()                                               
		Else
			nHandle:= FCreate(cDirCall+cArqFo,0)
			If (nHandle == -1)
				MsgInfo("O arquivo "+cArqFo+" nao pode ser criado. DOS Error : " + Str(FError(),3))
			EndIf
			FWrite(nHandle,cBufferFO)
			dbCommit()
		EndIf
		FClose(nHandle)
		cBufferFO:=""
		U_ZZINTCALL(cArqFo)
	Endif

	RestArea(aAreaSF1)
	RestArea(aAreaSD1)

	RestArea(aArea)

Return .t.