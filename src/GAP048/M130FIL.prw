#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} M130FIL
Ponto de Entrada que aplica filtro personalizados ao browse.
@author Elton Teodoro Alves
@since 09/05/2018
@version 11.8
@return Caracter, Filtro a ser aplicado no Browse
/*/
User Function M130FIL()

	Local cRet := MrkLegenda()

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
	Local cRet   := '.T.'
	Local nX     := 0

	Private aBrowse := {}
	Private oBrowse := {}

	DEFINE DIALOG oDlg TITLE "Selecione os Tipos de Solicitações de Compras" FROM 180,180 TO 425,500 PIXEL

	oBrowse := TWBrowse():New( 01 , 01, 160,100,,{'','','Descrição'},{20,30,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "ENABLE"     ) , "Solicitacao Pendente"     , 'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"'   } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "DISABLE"    ) , "Solicitacao Totalmente"   , 'C1_QUJE==C1_QUANT'                                                      } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "BR_AMARELO" ) , "Solicitacao Parcialmente" , 'C1_QUJE>0'                                                              } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "BR_AZUL"    ) , "Solicitacao em Processo"  , 'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S"' } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "BR_PRETO"   ) , "Elim. por Residuo"        , '!Empty(C1_RESIDUO)'                                                     } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "BR_CINZA"   ) , "Solicitacäo Bloqueada"    , 'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="B"'     } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "BR_PINK"    ) , "Solicitação de produto"   , 'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S"' } )
	aAdd(aBrowse,{ .T.,  LoadBitmap(GetResources(), "BR_LARANJA" ) , "Solicitacäo Rejeitada"    , 'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="R"'     } )

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

			cRet += '.AND. !( ' + aBrowse[nX][4] + ')'

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