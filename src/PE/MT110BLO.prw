#include 'protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA110BLO �Autor  �Carlos Hirose       � Data �  23/02/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o da Solicita��o de Compras responsavel pela aprova��o ���
���          �das SCs. 													  ���
�������������������������������������������������������������������������͹��
���          �Apos a montagem da dialog de aprovacao da Solicitacao de 	  ���
���Localiz.  �compras. E acionado quando o usuario clica nos botoes       ���
���          �Solicitacao Aprovada, Rejeita ou Bloqueada, deve ser        ���
���          �utilizado para continuar estas acoes  retorno .T.' ou       ���
���          �interromper  'retorno .F.' , apos clicar os botoes.         ���
�������������������������������������������������������������������������͹��
���Parametro �Paramixb[1] = 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear       ���
�������������������������������������������������������������������������͹��
���Uso       �Campneus                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT110BLO()

	Local lContinua := .T.
	Local cTipo := PARAMIXB[1]
	Local aAreaC1 := SC1->(GetArea())
	Local cFilSol := SC1->C1_FILIAL
	Local cNumSol := SC1->C1_NUM
	Local nTotVRef:= 0
	Local lUsrCo2	:= .f.
	Local nLimAprov := 0
	
	If cTipo == 0 // botao SAIR
		Return .t.
	Endif
	
	dbSelectArea("SZX")
	SZX->(dbSetOrder(1))
	If SZX->(dbSeek(xFilial("SZX") + "IDCO2")) // Users compradores 2
		If __cUserId $ SZX->ZX_COND
			lUsrCo2 := .t.
		Endif
	EndIf	

	If SC1->C1_FILIAL == "02010001"
		If lUsrCo2 .and. cTipo <> 2 
			MsgStop("Usu�rio sem permiss�o para aprovar ou bloquear solicita��o na Matriz.")
			lContinua := .f.
		Endif
		If lContinua
			dbSelectArea("ZAG")
			dbSetOrder(1)
			If dbSeek(xFilial("ZAG") + SC1->C1_CC )
				If Alltrim(cUsername) <> Alltrim(ZAG->ZAG_APROV1)
					MsgStop("Usu�rio sem autoriza��o para aprovar esta solicita��o.")
					lContinua := .f.
				Endif	
			Else
				MsgStop("Centro de custo n�o cadastrado para aprova��o de solicita��o.")
				lContinua := .f.
			Endif
		Endif
	Else
		If lUsrCo2 .and. cTipo <> 2 
			MsgStop("Usuario sem permiss�o para aprovar ou bloquear solicita��es de filiais.")
			lContinua := .f.
		Endif
		If lContinua 
			dbSelectArea("SC1")
			dbSetOrder(1)
			If dbSeek(cFilSol + cNumSol) 
				While !Eof() .and. SC1->C1_FILIAL == cFilSol .and. SC1->C1_NUM == cNumSol 
					nTotVRef += SC1->C1_QUANT * SC1->C1_XVAREUN
					SC1->(dbSkip())
				Enddo
			Endif

			dbSelectArea("ZAG")
			dbSetOrder(1)
			If dbSeek(xFilial("ZAG") + SC1->C1_CC )
				While !ZAG->(Eof()) .and. ZAG->ZAG_CCUSTO == SC1->C1_CC
					If Alltrim(cUsername) == Alltrim(ZAG->ZAG_APROV1)
						nLimAprov := ZAG->ZAG_VLAPR1
					ElseIf Alltrim(cUsername) == Alltrim(ZAG->ZAG_APROV2)
						nLimAprov := ZAG->ZAG_VLAPR2
					ElseIf Alltrim(cUsername) == Alltrim(ZAG->ZAG_APROV3)
						nLimAprov := ZAG->ZAG_VLAPR3
					Endif	
					ZAG->(dbSkip())	
				Enddo
				If nLimAprov == 0
					MsgStop("Aprovador sem limite para aprovar/bloquear solicita��o deste centro de custo.")
					lContinua := .f.
				Endif
				If nTotVRef > nLimAprov .and. lContinua
					MsgStop("Valor de refer�ncia da solicita��o est� acima do permitido para este aprovador.","Aten��o")
					lContinua := .f.
				Endif 
			Else
				MsgStop("Centro de custo n�o cadastrado para aprova��o de solicita��o.")
				lContinua := .f.
			Endif
		Endif
	Endif

	RestArea(aAreaC1)

Return ( lContinua ) 