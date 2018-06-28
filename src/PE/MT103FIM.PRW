#include "Protheus.ch"
#INCLUDE "Topconn.Ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103FIM  ºAutor  ³Evania Victorio     ºData  ³ 13/12/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Operação após gravação da NFE ( )                          º±±
±±º          ³    PARAMIXB[1]                                             º±±
±±º          ³    2 = Visualiza;                                          º±±
±±º          ³    3 = Inclusao;                                           º±±
±±º          ³    4 = ClassIficacao;                                      º±±
±±º          ³    5 = Exclusao                                            º±± 
±±º          ³    PARAMIXB[2]                                             º±±
±±º          ³    1 = Operação confirmada                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT103FIM() 

	Local aArea   	  := GetArea()  
	Local cCODFOR     := SuperGetMV("ZZ_CDFORPR",.F. ,"001002")
	Local _cFunName	  := AllTrim(FunName())
	Local nOpcao      := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
	Local nConfirma   := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
	Local cOperIn	:= AllTrim(SuperGetMv('ZZ_OPINCAR',,'4I')) 

	Local _nPosCod  	:= GdFieldPos("D1_COD")
	Local _nPosTes		:= GdFieldPos("D1_TES")
	Local _nPosCF		:= GdFieldPos("D1_CF")

	Local _nPosVuni		:= GdFieldPos("D1_VUNIT")
	Local _nPosQtd		:= GdFieldPos("D1_QUANT")

	Local _nPosSep		:= GdFieldPos("D1_ZZSEPU")
	Local _nPosPbon		:= GdFieldPos("D1_ZZPBON")
	Local _nPosTec		:= GdFieldPos("D1_ZZVEND")
	Local _nPosOper		:= GdFieldPos("D1_ZZOPER")
	Local _nPosCred		:= GdFieldPos("D1_ZZVSEPU")
	Local _nPosNfOri	:= GdFieldPos("D1_NFORI")
	Local _nPosSerOr	:= GdFieldPos("D1_SERIORI")

	Local nX			:= 0

	If nConfirma == 1  // Operação realizada com sucesso  

		If  nOpcao == 3  .or. nOpcao == 4 //Inclusao ou classificacao

			For nX := 1 To Len(aCols)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Gravacao do SEPU    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aCols[nX,_nPosTes] == '466' //Operação 25
					dbSelectArea("PA4")
					If RecLock("PA4",.T.)
						Replace PA4_FILIAL 	with xFilial("PA4") 
						Replace PA4_SEPU 	with aCols[nX,_nPosSep]
						Replace PA4_DTINC 	with dDatabase
						Replace PA4_CODPRO 	with aCols[nX,_nPosCod]
						Replace PA4_PRCPRO 	with Round(aCols[nX,_nPosCred]/aCols[nX,_nPosPbon] * 100 ,2)
						Replace PA4_CODCLI 	with cA100for
						Replace PA4_LOJA 	with cLoja   
						Replace PA4_NOMCLI 	with Posicione("SA1",1,xFilial("SA1")+cA100For+cLoja,"A1_NOME") 
						Replace PA4_FILLOJ 	with cFilAnt
						Replace PA4_DSCLOJ 	with Alltrim(SM0->M0_FILIAL)
						Replace PA4_SRNFE 	with cSerie
						Replace PA4_NFE 	with cNFiscal
						Replace PA4_PCRED 	with aCols[nX,_nPosPbon] 
						Replace PA4_VCRED 	with aCols[nX,_nPosCred]
						Replace PA4_CTECCP 	with aCols[nX,_nPosTec]
						Replace PA4_NTECCP 	with Posicione("SA3",1,xFilial("SA3")+aCols[nX,_nPosTec],"A3_NOME") 
						Replace PA4_MSFIL 	with cFilAnt
						Replace PA4_REPOS 	with "N"
						Replace PA4_STATUS 	with "1"	
						Replace PA4_DTALT 	with dDatabase					
						PA4->(MsUnLock())
						PA4->(dbCommit())
					Endif	
				Endif

				//CARCAÇA
				If aCols[nX,_nPosOper] == cOperIn
					M103ZZJE(aCols[nX,_nPosCod],aCols[nX,_nPosQtd])
					M103APCA(aCols[nX,_nPosCod])
				Endif
				
				If Substr(aCols[nX,_nPosCF],2,3) $ "102|403|652||409|152" //Compra ou transferencia de mercadoria
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek(xFilial("SB2") + aCols[nX,_nPosCod] )
						If SB2->B2_QATU == aCols[nX,_nPosQtd] .and. SB2->B2_ZZCMSAP > 0 //qtd iguais => nao tinha estoque (exceto se nf tem codigo duplicado) 
							If RecLock("SB2",.f.)
								Replace B2_ZZCMSAP with 0
								dbCommit()
								MsUnLock()
							Endif
						Endif
					Endif
				Endif
			Next
			dbSelectArea("SF1")
			If RecLock("SF1",.F.)
				Replace F1_HORA with Time()
				MsUnLock()
				dbCommit()
			Endif	

			If SF1->F1_FORMUL  == "S" // Inclusao --- Mensagem ao final da gravação NFe para transmitir a SEFAZ --    
				Msginfo("Nota Fiscal Entrada Registrada. Nro/série: " +Alltrim(SF1->F1_DOC)+"/"+Alltrim(SF1->F1_SERIE) +" Favor transmitir para a SEFAZ.")  
			EndIf	

		EndIf 
		If  nOpcao == 5 
			If Alltrim(SF1->F1_FORNECE) $ cCODFOR   // Exclusão Nota Fiscal de entrada Pirelli - limpar campo para rodar recebimento SAP   
				dbSelectArea("ZZ6")
				dbSetOrder(1)   // ZZ6_FILIAL+ZZ6_DOC+ZZ6_SERIE+ZZ6_FORNEC+ZZ6_LOJA
				If  dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) 
					If  RecLock("ZZ6",.F.)      // .F. = alteração ZZ6 para permitir loja fazer recebimento SAP
						Replace ZZ6_OK with Space(02)
						ZZ6->(dbCommit())
						ZZ6->(MsUnLock())
					EndIf
				EndIf
				ZZ6->( DbCloseArea() )
			Endif

			//ATUALIZAR EXCLUSAO DE CARCAÇA
			M103ZZJS()

		EndIf     
	Endif
	If nOpcao <>  5
		U_F0100201()
	Endif

	//Inclusao + Efetiva + Devolucao
	If nOpcao == 3 .And. nConfirma == 1 .And. cTipo == 'D'

		DbSelectArea('GW1')
		GW1->(DbSetOrder(11))

		If GW1->( DbSeek(xFilial('GW1') + Padr( aCols[1][_nPosSerOr], TamSX3('GW1_SERDC')[1] ) + Padr( aCols[1][_nPosNfOri] , TamSX3('GW1_NRDC')[1] ) )) .And. GW1->GW1_CDTPDC == 'NFS  '

			RecLock('GW1',.F.)
			GW1->GW1_SIT := '6'
			If !Empty(GW1->GW1_NRROM)
				GW1->GW1_MOTFT := "NF Devolvida com Romaneio: " + GW1->GW1_NRROM  + ". " + GW1->GW1_MOTFT
			EndIf
			GW1->( MsUnlock() )
		EndIf
		GW1->( DbCloseArea() )

	EndIf
Return 

/*
Grava a tabela de entradas de carcaças
Ariane Galindo	
28/12/16
*/
Static Function M103ZZJE(cCodPro, nQtProd)
	Local lRet	:= .T.
	Local nQuant := nQtProd
	Local nInd	 := 0 
	Local nAuxQuant	:=	0
	Local aNFCli := {} // {'','','','','',Stod('        '),0} //Filial, Tipo, Nota, Serie, Produto, Data emissao, Qtdd

	DbSelectArea('ZZJ')
	ZZJ->( DbSetOrder(2) )

	If ZZJ->( DbSeek( xFilial('ZZJ') + 'E  ' + Dtos( CriaVar('ZZJ_BAIXA') ) + cCodPro ) )

		While( ZZJ->ZZJ_FILIAL == xFilial('ZZJ') .And. ZZJ->ZZJ_TIPO == 'E  ' .And. AllTrim(ZZJ->ZZJ_PRODUT) == AllTrim(cCodPro) .And.;
		nQuant > 0 .And. Empty(ZZJ->ZZJ_BAIXA) .And. ZZJ->(!Eof()) )

			If nQuant >= ZZJ->ZZJ_QTDCAR
				nQuant := ( nQuant - ZZJ->ZZJ_QTDCAR ) 

				RecLock('ZZJ',.F.)
				ZZJ->ZZJ_NFENT  := SF1->F1_DOC
				ZZJ->ZZJ_SERENT := SF1->F1_SERIE
				ZZJ->ZZJ_BAIXA	:= SF1->F1_EMISSAO 
				ZZJ->( MsUnlock() )

				ZZJ->( DbSeek( xFilial('ZZJ') + 'E  ' + Dtos( CriaVar('ZZJ_BAIXA') ) + cCodPro ) )

			ElseIf nQuant < ZZJ->ZZJ_QTDCAR
				ZZJ->( DbSkip() )
			EndIf

		EndDo

		If nQuant > 0

			If ZZJ->( DbSeek( xFilial('ZZJ') + 'E  ' + Dtos( CriaVar('ZZJ_BAIXA') ) + cCodPro ) )

				If( ZZJ->ZZJ_FILIAL == xFilial('ZZJ') .And. ZZJ->ZZJ_TIPO == 'E  ' .And. AllTrim(ZZJ->ZZJ_PRODUT) == AllTrim(cCodPro) .And.;
				nQuant > 0 .And. Empty(ZZJ->ZZJ_BAIXA) .And. ZZJ->(!Eof()) )

					If nQuant < ZZJ->ZZJ_QTDCAR

						nAuxQuant := ZZJ->ZZJ_QTDCAR

						RecLock('ZZJ',.F.)
						ZZJ->ZZJ_NFENT  := SF1->F1_DOC
						ZZJ->ZZJ_SERENT := SF1->F1_SERIE
						ZZJ->ZZJ_BAIXA	:= SF1->F1_EMISSAO 
						ZZJ->ZZJ_QTDCAR	:= nQuant
						ZZJ->( MsUnlock() )

						nQuant := ( nAuxQuant - nQuant )

						aNFCli := {ZZJ->ZZJ_FILIAL,ZZJ->ZZJ_TIPO,ZZJ->ZZJ_NUMNF,ZZJ->ZZJ_SERIE,ZZJ->ZZJ_PRODUT,ZZJ->ZZJ_DTEMIS,nQuant}

						RecLock('ZZJ',.T.)
						ZZJ->ZZJ_FILIAL	:= aNFCli[1]
						ZZJ->ZZJ_TIPO	:= aNFCli[2]
						ZZJ->ZZJ_NUMNF	:= aNFCli[3]
						ZZJ->ZZJ_SERIE	:= aNFCli[4]
						ZZJ->ZZJ_PRODUT	:= aNFCli[5]
						ZZJ->ZZJ_DTEMIS	:= aNFCli[6]
						ZZJ->ZZJ_QTDCAR	:= aNFCli[7]
						ZZJ->ZZJ_RETIRA	:= 'N'
						ZZJ->( MsUnlock() )

						nQuant := 0 
					EndIf
				EndIf
			Else
				If nQuant > 0 
					RecLock('ZZJ',.T.)
					ZZJ->ZZJ_FILIAL	:= xFilial('ZZJ')
					ZZJ->ZZJ_TIPO	:= 'E'
					ZZJ->ZZJ_NUMNF	:= SF1->F1_DOC
					ZZJ->ZZJ_SERIE	:= 'AJU'
					ZZJ->ZZJ_NFENT  := SF1->F1_DOC
					ZZJ->ZZJ_SERENT := SF1->F1_SERIE
					ZZJ->ZZJ_BAIXA	:= SF1->F1_EMISSAO 
					ZZJ->ZZJ_PRODUT	:= cCodPro
					ZZJ->ZZJ_DTEMIS	:= dDataBase
					ZZJ->ZZJ_QTDCAR	:= nQuant
					ZZJ->ZZJ_RETIRA	:= 'N'
					ZZJ->( MsUnlock() )
				EndIf
			EndIf
		EndIf
	Else

		RecLock('ZZJ',.T.)
		ZZJ->ZZJ_FILIAL	:= xFilial('ZZJ')
		ZZJ->ZZJ_TIPO	:= 'E'
		ZZJ->ZZJ_NUMNF	:= SF1->F1_DOC
		ZZJ->ZZJ_SERIE	:= 'AJU'
		ZZJ->ZZJ_NFENT  := SF1->F1_DOC
		ZZJ->ZZJ_SERENT := SF1->F1_SERIE
		ZZJ->ZZJ_BAIXA	:= SF1->F1_EMISSAO 
		ZZJ->ZZJ_QTDCAR	:= nQtProd
		ZZJ->ZZJ_PRODUT	:= cCodPro
		ZZJ->ZZJ_RETIRA	:= 'N'
		ZZJ->( MsUnlock() )

	EndIf
	//Next nInd

	U_ZLJ17GRE( cCodPro, nQtProd, 'E', 2 )


Return lRet 

/*
apaga a entrada de carcaças
Ariane Galindo	
28/12/16
*/
Static Function M103ZZJS()
	Local aArea  := GetArea()
	Local aQtdd  := U_ZRetQtIt(SF1->F1_DOC, SF1->F1_SERIE, 'E')
	Local cQuery := ""
	Local nInd 	 := 0 

	If Len(aQtdd) > 0 

		For nInd := 1 To Len(aQtdd)

			//Cancelamento de Entrada com ajuste a MAIOR
			cQuery := " UPDATE " + RetSQLName('ZZJ') + " "
			cQuery += " SET D_E_L_E_T_ = '*' " 

			cQuery += " WHERE ZZJ_FILIAL = '" + SF1->F1_FILIAL + "' "
			cQuery += " AND ZZJ_NUMNF = '" + SF1->F1_DOC + "' "
			cQuery += " AND ZZJ_SERIE = 'AJU' "
			cQuery += " AND ZZJ_NFENT = '" + SF1->F1_DOC + "' "
			cQuery += " AND ZZJ_SERENT = '" + SF1->F1_SERIE + "' "
			cQuery += " AND ZZJ_PRODUT = '" + aQtdd[nInd][1] + "' "
			cQuery += " AND ZZJ_TIPO = 'E' "
			cQuery += " AND D_E_L_E_T_ = ' ' "

			If TcSQLExec( cQuery ) == 0
				TcSQLExec( 'COMMIT' )
				TcRefresh( RetSQLName( "ZZJ" ) )
			EndIf
			
			//Cancelamento de Entrada com ajuste a MENOR
			cQuery := " UPDATE " + RetSQLName('ZZJ') + " "
			cQuery += " SET D_E_L_E_T_ = ' ', "
			cQuery += " ZZJ_BAIXA = '', "
			cQuery += " ZZJ_SERENT = '', "
			cQuery += " ZZJ_NFENT = '' " 

			cQuery += " WHERE ZZJ_FILIAL = '" + SF1->F1_FILIAL + "' "
			cQuery += " AND ZZJ_NUMNF <> '" + SF1->F1_DOC + "' "
			cQuery += " AND ZZJ_SERIE <> 'AJU' "
			cQuery += " AND ZZJ_NFENT = '" + SF1->F1_DOC + "' "
			cQuery += " AND ZZJ_SERENT = 'AJU' "
			cQuery += " AND ZZJ_PRODUT = '" + aQtdd[nInd][1] + "' "
			cQuery += " AND ZZJ_BAIXA = '" + DTOS(SF1->F1_EMISSAO) + "' "
			cQuery += " AND ZZJ_TIPO = 'E' "
			cQuery += " AND D_E_L_E_T_ = '*' "

			If TcSQLExec( cQuery ) == 0
				TcSQLExec( 'COMMIT' )
				TcRefresh( RetSQLName( "ZZJ" ) )
			EndIf

			//Cancelamento de Demais Entradas de Carcacas
			cQuery := " UPDATE " + RetSQLName('ZZJ') + " "
			cQuery += " SET ZZJ_NFENT = ' ',  "
			cQuery += " ZZJ_SERENT = ' ',  " 
			cQuery += " ZZJ_BAIXA = ' '  " 

			cQuery += " WHERE ZZJ_FILIAL = '" + SF1->F1_FILIAL + "' "
			cQuery += " AND ZZJ_NFENT = '" + SF1->F1_DOC + "' "
			cQuery += " AND ZZJ_SERENT = '" + SF1->F1_SERIE + "' "
			cQuery += " AND ZZJ_PRODUT = '" + aQtdd[nInd][1] + "' "
			cQuery += " AND ZZJ_TIPO = 'E' "
			cQuery += " AND D_E_L_E_T_ = ' ' "

			If TcSQLExec( cQuery ) == 0
				TcSQLExec( 'COMMIT' )
				TcRefresh( RetSQLName( "ZZJ" ) )

				//Para tirar a quantidade de estoque chama-se a rotina de saida.
				U_ZLJ17GRE( aQtdd[nInd][1], aQtdd[nInd][2], 'S', 2 )		

			EndIf
		Next nInd
	EndIf

	RestArea(aArea)
Return 



/*

ROTINA DE TESTE

User Function TSTM103()

DbSelectArea('SF1')
SF1->( DbSetOrder(1) )

DbSelectArea('SD1')
SD1->( DbSetOrder(1) )

SF1->( DbSeek('02020097'+'000032670'+'5  '+ '0078799' + '21' + 'B' ) )
SD1->( DbSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )

While SD1->D1_FILIAL == SF1->F1_FILIAL .And. SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And.;
SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA

M103ZZJE( SD1->D1_COD , SD1->D1_QUANT )

SD1->( DbSkip() )
EndDo

SD1->( DbCloseArea() )
SF1->( DbCloseArea() )

Return 
*/

/*
Apaga carcaças restantes de acordo com aprovação de ajuste.
Ariane Galindo	
28/07/2017
*/
Static Function M103APCA(_CodProd)
	Local aArea  := GetArea()
	Local nQuant := MT103QPd( _CodProd )
	Local cQuery := ""
	Local nInd 	 := 0 

	If nQuant > 0 

		cQuery := " UPDATE " + RetSQLName('ZZJ') + " "
		cQuery += " SET D_E_L_E_T_ = '*', "
		cQuery += " ZZJ_SERENT = 'AJU', "
		cQuery += " ZZJ_NFENT = '" + SF1->F1_DOC + "', "
		cQuery += " ZZJ_BAIXA = '" + Dtos(SF1->F1_EMISSAO) + "' " 

		cQuery += " WHERE ZZJ_FILIAL = '" + SF1->F1_FILIAL + "' "
		cQuery += " AND ZZJ_QTDCAR > 0 "
		cQuery += " AND ZZJ_BAIXA = '' "
		cQuery += " AND ZZJ_PRODUT = '" + _CodProd + "' "
		cQuery += " AND ZZJ_TIPO = 'E' "
		cQuery += " AND D_E_L_E_T_ = ' ' "

		If TcSQLExec( cQuery ) == 0
			TcSQLExec( 'COMMIT' )
			TcRefresh( RetSQLName( "ZZJ" ) )

			//Para tirar a quantidade de estoque chama-se a rotina de saida.
			//Não sera necessario retirar quantidade em estoque pois ainda nao foi realizada entrada
			//U_ZLJ17GRE( _CodProd, nQuant, 'S', 2 )		

		EndIf
	EndIf

	RestArea(aArea)
Return 

/*

*/

Static Function MT103QPd( _CodProd )
	Local nQtd 		:= 0
	Local cQry 		:= ""
	Local cAliasQry := GetNextAlias()

	cQry := " SELECT SUM(ZZJ.ZZJ_QTDCAR) QUANT "
	cQry += " FROM " + RetSQLName('ZZJ') + " ZZJ "
	cQry += " WHERE ZZJ_FILIAL = '" + SF1->F1_FILIAL + "' "
	cQry += " AND ZZJ_QTDCAR > 0 "
	cQry += " AND ZZJ_BAIXA = '' "
	cQry += " AND ZZJ_PRODUT = '" + _CodProd + "' "
	cQry += " AND ZZJ_TIPO = 'E' "
	cQry += " AND D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry),cAliasQry, .F., .T.)

	If !((cAliasQry)->( Eof() ))
		nQtd := (cAliasQry)->(QUANT)
	EndIf

	(cAliasQry)->(DbCloseArea())	
Return nQtd

