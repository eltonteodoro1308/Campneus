#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MTA097MNU
Adiciona ao menu da liberação de documentos a opção de vincular docuemntos da base de conhecimento.
@author Elton Teodoro Alves
@since 09/05/2018
@version 11.8
/*/
User Function MTA097MNU()

	Aadd( aRotina, { "Conhec. Ped. Compra", "U_PedDoc()", 0, 4, 0, NIL } )

Return

/*/{Protheus.doc} PedDoc
Exibe Browser com item do pedido correspondente a lçiberação posicionada.
@author Elton Teodoro Alves
@since 09/05/2018
@version 11.8
/*/
User Function PedDoc()

	Local oBrw

	If SCR->CR_TIPO == 'PC'

		oBrw :=  FWMBrowse():New()

		oBrw:SetAlias( "SC7" )
		oBrw:SetDescription( "Pedidos de Compras" )
		oBrw:SetIgnoreARotina(.T.)
		oBrw:AddFilter('Filtro de Programa', 'SC7->C7_FILIAL == SCR->CR_FILIAL .AND. SC7->C7_NUM == SCR->CR_NUM', .T., .T.,  )
		oBrw:SetMenuDef( 'MTA097MNU' )

		oBrw:Activate()

	Else

		Alert( 'Válido Somente para Pedidos de Compras' )

	End If

Return

/*/{Protheus.doc} MenuDef
Define o menu do browser com os itens do pedido de compras posicionado
@author Elton Teodoro Alves
@since 09/05/2018
@version 11.8
/*/
Static Function MenuDef()

	Local aMyRotina := {}

	aAdd( aMyRotina, { 'Conhecimento', 'MsDocument', 0, 4, 0, NIL } )

Return aMyRotina