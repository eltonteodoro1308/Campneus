#include 'protheus.ch'
#include 'parmtype.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103EXC  �Autor  �Carlos Hirose       �Data  � 24/03/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao na exclusao da NF ENTRADA                        ���
�������������������������������������������������������������������������͹��
���Obs.      � Exclusao do SEPU associado feita na rotina COMA0050()      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11.8                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		MsgStop("N�o � permitido o cancelamento de Nota Fiscal com formul�rio pr�prio, enquanto Sefaz do estado em conting�ncia.","Support Retail 0800 285 2230")
		lRet := .f.
	EndIF

	If Empty( dDtCaixa ) .And. lRet
		MsgStop("Opera��o n�o permitida com o caixa fechado.","MT103EXC")
		lRet := .f.
		/*Else
		If dDataBase <> dDtCaixa
		MsgStop("Opera��o n�o permitida, pois o caixa ainda est� aberto no dia: " + DtoC( dDtCaixa ),"MT103EXC")
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
			MsgStop("Exclus�o de nota fiscal de entrada n�o permitida pois possui SEPU j� utilizado.","MT103EXC")
			lRet := .f.
		Endif
	Endif

	//Caso seja NF de Entrada de carca�a, verifica se existe estoque para cancelamento.
	If !ZM103ECA()
		MsgStop("N�o � permitida a exclus�o de Nota Fiscal de Entrada sem estoque de Carca�a.","MT103EXC")
		lRet := .f.
	EndIf
	
Return lRet

/*
	Valida se � possivel excluir NF de carca�a.
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