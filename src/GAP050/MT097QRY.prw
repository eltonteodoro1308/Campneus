#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MT097QRY
Ponto de Entrada que aplica filtro personalizados ao browse.
@author Elton Teodoro Alves
@since 09/05/2018
@version 11.8
@return Caracter, Filtro a ser aplicado no Browse
/*/
User Function MT097QRY()

	Local cRet := ''

	If MV_PAR01 == 3

		cRet := MrkLegenda()

	End IF

Return cRet

/*/{Protheus.doc} MrkLegenda
Exibe Tela para marcação dos tipos de solicitações a serem exibidas.
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

	Private aBrowse := {}
	Private oBrowse := {}

	DEFINE DIALOG oDlg TITLE "Selecione os Tipos de Solicitações de Compras" FROM 180,180 TO 425,500 PIXEL

	oBrowse := TWBrowse():New( 01 , 01, 160,100,,{'','','Descrição'},{20,30,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_AZUL'  ) , "Bloqueado (aguardando outros niveis)" , "CR_STATUS = '01'"} )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'DISABLE'  ) , "Aguardando Liberacao do usuario"      , "CR_STATUS = '02'"} )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'ENABLE'   ) , "Documento Liberado pelo usuario"      , "CR_STATUS = '03'"} )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_PRETO' ) , "Documento Bloqueado pelo usuario"     , "CR_STATUS = '04'"} )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), 'BR_CINZA' ) , "Documento Liberado por outro usuario" , "CR_STATUS = '05'"} )

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

		If ! aBrowse[nX][1]

			cRet += " AND NOT ( " + aBrowse[nX][4] + ")"

		End If

	Next nX

Return cRet

/*/{Protheus.doc} Inverte
Inverte Seleção
@author elton Teodoro Alves
@since 09/05/2018
@version 11.8
@param oBrw, object, Objeto da tela de seleção
@param nPos, numeric, Posição da coluna selecionada
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