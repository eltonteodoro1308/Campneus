#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MT110QRY
Ponto de Entrada que aplica filtro personalizados ao browse.
@author Elton Teodoro Alves
@since 09/05/2018
@version 11.8
@return Caracter, Filtro a ser aplicado no Browse
/*/
user function MT110QRY()

	Local cRet := ''/*
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
			cCustos := "'" + Alltrim((cAliasQry)->ZAG_CCUSTO) + "'"
		Else
			cCustos += ",'" + Alltrim((cAliasQry)->ZAG_CCUSTO) + "'"
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
							cUserEq := "'" + Alltrim(ZAH->ZAH_USREQ) + "'"
						Else
							cUserEq += ",'" + Alltrim(ZAH->ZAH_USREQ) + "'"
						Endif
					Endif
					ZAH->(dbSkip())
				Enddo
			Endif

			cFiltro += " AND ( LTRIM(RTRIM(C1_CC)) IN(" + cCustos + ") "
			If !Empty(cUserEq)
				cFiltro += " OR LTRIM(RTRIM(C1_SOLICIT)) IN(" + cUserEq + ") "
			Endif
			cFiltro += " )"
		Else
			cFiltro := " C1_SOLICIT = '" + cUserName + "'"
		Endif
	Else
		cFiltro := " (C1_APROV = 'L' OR C1_APROV = 'B') AND C1_PEDIDO = ' ' "
	Endif

	cRet += cFiltro
	cRet += ' AND '*/
	cRet += MrkLegenda()

Return cRet

/*/{Protheus.doc} MrkLegenda
Exibe Tela para marca��o dos tipos de solicita��es a serem exibidas.
@author elton Teodoro Alves
@since 09/05/2018
@version 11.8
@return Caracter, Filtro a ser aplicado no Browse
/*/
Static Function MrkLegenda()

	Local oLbtik := LoadBitmap(GetResources(),"LBTIK")
	Local oLbno  := LoadBitmap(GetResources(),"LBNO")
	Local oDlg   := Nil
	Local cRet   := ''
	Local nX     := 0
	Local aAux   := {}

	Private aBrowse := {}
	Private oBrowse := {}

	DEFINE DIALOG oDlg TITLE "Selecione os Tipos de Solicita��es de Compras" FROM 180,180 TO 425,500 PIXEL

	oBrowse := TWBrowse():New( 01 , 01, 160,100,,{'','','Descri��o'},{20,30,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'ENABLE'     ) , 'Solicitacao Pendente'                                   , "C1_QUJE = 0 AND C1_COTACAO = SPACE(LEN(C1_COTACAO)) AND C1_APROV IN( ' ','L')" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'DISABLE'    ) , 'Solicitacao Totalmente Atendida'                        , "C1_QUJE = C1_QUANT" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_AMARELO' ) , 'Solicitacao Parcialmente Atendida'                      , "C1_QUJE > 0" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_AZUL'    ) , 'Solicitacao em Processo de Cotacao'                     , "C1_TPSC <> '2' AND C1_QUJE = 0 AND C1_COTACAO <> SPACE(LEN(C1_COTACAO)) AND C1_IMPORT <>'S'" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_PRETO'   ) , 'Elim. por Residuo'                                      , "NOT C1_RESIDUO = ''" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_CINZA'   ) , 'Solicitac�o Bloqueada'                                  , "C1_QUJE = 0 AND C1_COTACAO = SPACE(LEN(C1_COTACAO)) AND C1_APROV = 'B'" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_PINK'    ) , 'Solicita��o de produto Importado'                       , "C1_QUJE = 0 AND C1_COTACAO <> SPACE(LEN(C1_COTACAO)) AND C1_IMPORT = 'S'" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_LARANJA' ) , 'Solicitac�o Rejeitada'                                  , "C1_QUJE = 0 AND C1_COTACAO = SPACE(LEN(C1_COTACAO)) AND C1_APROV = 'R'" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_MARROM'  ) , 'Integra��o Modulo Gest�o de Contratos'                  , "C1_FLAGGCT = '1' AND C1_QUJE < C1_QUANT" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'PMSEDT4'    ) , 'Solicita��o em Processo de Edital'                      , "C1_TPSC = '2' AND C1_QUJE = 0 AND NOT C1_CODED = ''" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'PMSEDT1'    ) , 'Solicita��o Parcialmente Atendida Utilizada em Cota��o' , "C1_TPSC <> '2' AND C1_QUJE > 0 AND C1_COTACAO <> SPACE(LEN(C1_COTACAO)) AND C1_COTACAO <> REPLICATE('X',Len(C1_COTACAO)) AND C1_IMPORT <>'S'" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_VIOLETA' ) , 'Solicitacao em Compra Centralizada'                     , "C1_RESIDUO = 'S' AND C1_COMPRAC = '1'" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_BRANCO'  ) , 'Solicita��o de Importa��o'                              , 'C1_TIPO = 2' } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'PMSEDT3'    ) , 'Solicita��o Pendente (MKT)'                             , "C1_ACCPROC ='1' AND C1_PEDIDO = SPACE(LEN(C1_PEDIDO))" } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'PMSEDT2'    ) , 'Solicita��o em Processo de Cota��o (MKT)'               , "C1_ACCPROC ='1' AND C1_PEDIDO = SPACE(LEN(C1_PEDIDO)) AND C1_COTACAO <> SPACE(LEN(C1_COTACAO)) " } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'LIGHTBLU'   ) , 'Solicita��o para Licita��o'                             , "C1_QUJE = 0 AND C1_COTACAO = SPACE(LEN(C1_COTACAO)) AND C1_APROV IN( '','L') AND C1_TPSC = '2'" } )

	oBrowse:SetArray(aBrowse)

	oBrowse:bLine := {|| { ;
	If( aBrowse[ oBrowse:nAt, 01 ], oLbtik, oLbno ) ,;
	aBrowse[ oBrowse:nAt, 02 ] ,;
	aBrowse[ oBrowse:nAt, 03 ] ,;
	} }

	oBrowse:bLDblClick := { || aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1], oBrowse:DrawSelect()}

	oBrowse:bHeaderClick := { | X, Y | Inverte( X, Y ), oBrowse:DrawSelect() }

	SButton():New( 110,120,01,{||oDlg:End()},oDlg,.T.,,)

	ACTIVATE DIALOG oDlg CENTERED

	For nX := 1 To Len( aBrowse )

		If aBrowse[nX][1]

			aAdd( aAux, '( ' + aBrowse[nX][4] + ')' )

		End If

	Next nX


	For nX := 1 to Len( aAux )

		cRet += aAux[nX]

		If nX < Len( aAux )

			cRet += ' OR '

		End If

	Next nX

Return '(' + cRet + ')'

/*/{Protheus.doc} Inverte
Inverte Sele��o
@author elton Teodoro Alves
@since 09/05/2018
@version 11.8
@param oBrw, object, Objeto da tela de sele��o
@param nPos, numeric, Posi��o da coluna selecionada
/*/
Static Function Inverte( oBrw , nPos )

	Local nX := 0

	If nPos == 1

		For nX := 1 To Len( aBrowse )

			aBrowse[nX][1] := !aBrowse[nX][1]

		Next nX

	End If

	oBrowse:Refresh()

Return

