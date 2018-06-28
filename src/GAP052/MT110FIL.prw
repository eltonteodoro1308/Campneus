#include 'protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110FIL  �Autor  �Carlos Hirose       � Data �  07/01/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Compoe uma string para ser passada para MBrowse			  ���
���          �															  ���
�������������������������������������������������������������������������͹��
���          �Antes da apresenta�ao da interface da Mbrowse no inicio da  ���
���Localiz.  �rotina, possibilita compor um string contendo uma expressao ���
���          �de Filtro da tabela SC1 para ser passada para MBrowse.      ���
�������������������������������������������������������������������������͹��
���Uso       �Campneus                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT110FIL()

Local cFiltro 	:= ""
Local cQueryZAG	:= ""
Local cAliasQry	:= GetNextAlias()
Local cCustos 	:= "" 
Local cUserEq	:= ""
Local lUsrAprov	:= .f.
Local lUsrCo2 	:= .f.

dbSelectArea("SZX")
SZX->(dbSetOrder(1))
If SZX->(dbSeek(xFilial("SZX") + "IDCO2")) // Users compradores 2
	If __cUserId $ SZX->ZX_COND
		lUsrCo2 := .t.
	Endif
EndIf	

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
Endif

cQueryZAG := " SELECT * FROM ZAG020 ZAG"
cQueryZAG += " WHERE ( ZAG_APROV1 = '"+cUserName+"' " 
cQueryZAG += " OR ZAG_APROV2 = '"+cUserName+"' " 
cQueryZAG += " OR ZAG_APROV3 = '"+cUserName+"' ) " 
cQueryZAG += " AND ZAG.D_E_L_E_T_ = ' ' "

cQueryZAG := ChangeQuery(cQueryZAG)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQueryZAG),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
	If Empty(cCustos)
		cCustos := Alltrim((cAliasQry)->ZAG_CCUSTO)
	Else
		cCustos += "," + Alltrim((cAliasQry)->ZAG_CCUSTO)
	Endif	
	(cAliasQry)->(dbSkip())
	lUsrAprov := .t.
Enddo

cFiltro :=  " C1_APROV  <> 'L'  "

If !lUsrCo2
	If lUsrAprov
		dbSelectArea("ZAH") // Tabela Aprovador x Users da Equipe
		dbSetOrder(1)
		If dbSeek(xFilial("ZAH") + cUserName )
			While !ZAH->(Eof()) .and. Alltrim(ZAH->ZAH_APROV) == cUserName 
				If ZAH->ZAH_ATIVO 
					If Empty(cUserEq) 
						cUserEq := Alltrim(ZAH->ZAH_USREQ)
					Else
						cUserEq += "," + Alltrim(ZAH->ZAH_USREQ)
					Endif
				Endif
				ZAH->(dbSkip())
			Enddo		
		Endif
		
		cFiltro += "  .and. ( Alltrim(C1_CC)  $ '" + cCustos + "' "
		If !Empty(cUserEq)
			cFiltro += " .or. Alltrim(C1_SOLICIT)  $ '" + cUserEq + "' " 
		Endif
		cFiltro += " ) "
	Else
		cFiltro := " C1_SOLICIT == '" + cUserName + "'"
	Endif
Else
	cFiltro := " (C1_APROV == 'L' .OR. C1_APROV == 'B') .AND. C1_PEDIDO = ' '  "
Endif

Return (cFiltro) 	
