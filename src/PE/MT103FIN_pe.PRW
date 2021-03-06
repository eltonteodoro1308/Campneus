#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103FIN  �Autor  �Carlos Hirose       � Data �  08/27/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada de validacao das linhas de pagamento nas   ���
���          �notas fiscais de entrada                                    ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11.5                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Mt103Fin()

	Local aHeadPag 	:= ParamIxb[1]
	Local aColsPag	:= ParamIxb[2]                                                     
	//Local nPosCF 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CF"} )
	Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"} )
	Local lRetPag  	:= .T.
	Local xPg := 0

	//If Substr(Acols[1,nPosCF],2,3) $  "403|102|556|126|407|353|253|303|933|551|556" //Compras 
	dbSelectArea("SF4")
	dbSetOrder(1)
	If dbSeek(xFilial("SF4") + aCols[1,nPosTes] )
		If SF4->F4_DUPLIC == "S"
			// Quando alterada data de vencimento este ponto de entrada roda duas vezes.
			If Len(aHeadPag[1]) < 14 // O sistema cria mais vetores (> 14) quando o campo data de vencimento � alterado. Para nao verificar 2 vezes.
				If Len(aColsPag) < 1
					MsgStop("Os dados de pagamento da duplicata n�o foram informados. Favor incluir o pagamento.","Aten��o")
					lRetPag:=.f.
				Else	
					For xPg:=1 To Len(aColsPag)
						If aColsPag[xPg,2] <= dDatabase
							MsgStop("A data de pagamento informada est� vencida. Favor renegociar a nova data de pagamento com o fornecedor ou contatar o Contas a Pagar - Matriz")
							lRetPag:=.f.
						Elseif aColsPag[xPg,2] > ddEmissao + 365
							MsgStop("A data de pagamento informada est� acima do permitido","Aten��o")
							lRetPag:=.f.
						Elseif aColsPag[xPg,2] < ddEmissao 
							MsgStop("Data de pagamento inv�lida","Aten��o")
							lRetPag:=.f.
						Endif
					Next
				Endif
			Endif
		Endif
	Else
		MsgStop("Tipo de entrada/sa�da n�o existe. Favor verificar o tipo de opera��o.")
		lRetPag := .f.
	Endif
	
Return lRetPag