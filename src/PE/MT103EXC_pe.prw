#include 'protheus.ch'
#include 'parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103EXC  ºAutor  ³Carlos Hirose       ºData  ³ 24/03/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao na exclusao da NF ENTRADA                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³ Exclusao do SEPU associado feita na rotina COMA0050()      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11.8                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT103EXC()

	Local lRet 		:= .t.
	Local lUsado	:= .f.
	Local nx 		:= 0
	Local _nPosTes 	:= GdFieldPos("D1_TES")
	Local _nPosSep	:= GdFieldPos("D1_ZZSEPU") 
	Local dDtCaixa 		:= U_FINA032B()
	Local aArea		:= GetArea()
	Local cCancNF	:= Alltrim(Posicione("ZZV",2,xFilial("ZZV") + "CAN" + cFilAnt,"ZZV_PNEUAC"))
		
	If cCancNF == "N" .and. SF1->F1_FORMUL == "S" .and. __cUserID <> "000000" // administrador
		MsgStop("Não é permitido o cancelamento de Nota Fiscal com formulário próprio, enquanto Sefaz do estado em contingência.","Support Retail 0800 285 2230")
		lRet := .f.
	EndIF

	If Empty( dDtCaixa ) .And. lRet
		MsgStop("Operação não permitida com o caixa fechado.","MT103EXC")
		lRet := .f.
		/*Else
		If dDataBase <> dDtCaixa
		MsgStop("Operação não permitida, pois o caixa ainda está aberto no dia: " + DtoC( dDtCaixa ),"MT103EXC")
		lRet := .f. 
		Endif */
	Endif

	If lRet
		For nx:= 1 to Len(aCols)	
			If aCols[nx,_nPosTes] == '466' .and. !Empty(aCols[nx,_nPosSep])
				dbSelectArea("PA4")
				dbSetOrder(1)
				If dbSeek(xFilial("PA4")+aCols[nx,_nPosSep])
					If !Empty(PA4->PA4_DOCREP) .or. !Empty(PA4->PA4_DOCREM) 
						lUsado := .t.
						Exit
					Endif
				Endif
			Endif
		Next	

		If lUsado
			MsgStop("Exclusão de nota fiscal de entrada não permitida pois possui SEPU já utilizado.","MT103EXC")
			lRet := .f.
		Endif
	Endif

	//Caso seja NF de Entrada de carcaça, verifica se existe estoque para cancelamento.
	If !ZM103ECA()
		MsgStop("Não é permitida a exclusão de Nota Fiscal de Entrada sem estoque de Carcaça.","MT103EXC")
		lRet := .f.
	EndIf
	
Return lRet

/*
	Valida se é possivel excluir NF de carcaça.
	Ariane Galindo
	02/01/2017
*/
Static Function ZM103ECA()
	Local lRet := .T.
	Local cQry := ""
	Local cAliasQry := GetNextAlias()
	Local cOperIn	:= AllTrim(SuperGetMv('ZZ_OPINCAR',,'4I'))

	cQry := " SELECT SD1.D1_COD, SD1.D1_QUANT, ZZO.ZZO_QATUAL "
	cQry += " FROM " + RetSQLName('SD1') + " SD1 "
	cQry += " INNER JOIN " + RetSQLName('ZZO') + " ZZO ON ( ZZO.ZZO_FILIAL = '" + xFilial('ZZO') + "' AND ZZO.ZZO_PRODUT = SD1.D1_COD  AND ZZO.D_E_L_E_T_ = ' ' ) "
	cQry += " WHERE SD1.D1_ZZOPER = '" + cOperIn + "' "
	cQry += " AND SD1.D1_FILIAL = '" + SF1->F1_FILIAL + "' "
	cQry += " AND SD1.D1_DOC 	= '" + SF1->F1_DOC + "' "
	cQry += " AND SD1.D1_SERIE	= '" + SF1->F1_SERIE + "' "
	cQry += " AND SD1.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry),cAliasQry, .F., .T.)

	While !((cAliasQry)->( Eof() )) .And. lRet
		If (cAliasQry)->D1_QUANT > (cAliasQry)->ZZO_QATUAL
			lRet := .F.
		EndIf
		(cAliasQry)->(dbSkip())
	Enddo

	(cAliasQry)->(DbCloseArea())
Return lRet 