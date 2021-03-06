#include"protheus.ch"
#include"topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT100LOK �Autor: �Marcio Nascimento   �Data  � 24/06/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que preenche com zeros a esquerda o numero das Notas���
���          � Fiscais de Entrada para completar as posicoes de acordo    ���
���          � com o tamanho do campo SF1->F1_DOC                         ���
�������������������������������������������������������������������������͹��
���Uso       �  Campneus - Protheus 11                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT100LOK()
Local _lRet			:= .T.
Local _cFornP		:= AllTrim(GetMV("ZZ_PNCFOPC"))  //001002  - Pirelli
Local _cCNPJ		:= AllTrim(GetMV("ZZ_CNPJCAM")) //006318 - CNPJ de fornecedor
Local _cForn		:= AllTrim(CA100FOR)
Local _cFunName		:= AllTrim(FunName())
Local nTamDoc		:= Len(SF1->F1_DOC)
Local cNumNF  		:= CNFISCAL
Local aArea			:= GetArea()
Local nPosItem		:= GdFieldPos("D1_ITEM")
Local nPosOp		:= GdFieldPos("D1_OPER")
Local nPosCf		:= GdFieldPos("D1_CF")
Local nPosNfOri		:= GdFieldPos("D1_NFORI")
Local nPosSerOri	:= GdFieldPos("D1_SERIORI")
Local lLjCamp		:= .f.
Local cSerNfe       := Left(GetMv("ZZ_SERIEPD")+Space(3),3)
Local cEmpOrig      := Substr(cFilAnt,1,2) 
Local cCgc   		:= space(14)
Local nReg
Local nOpc   		:= 3
Local nI			:= 1

cNumNF				:= StrZero(Val(cNumNF), nTamDoc)
CNFISCAL	    	:= cNumNF

If  !cTipo $ "B|D"
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	If  !dbSeek(xFilial("SA2")+CA100FOR+cLoja) 
		MsgStop("Fornecedor "+CA100FOR+"/"+cLoja+" n�o existe. Favor verificar se o c�digo/loja do fornecedor foi digitado corretamente","Aten��o")
		_lRet := .F.
	Endif
    cCgc:=SA2->A2_CGC
else
    dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	If  !dbSeek(xFilial("SA1")+CA100FOR+cLoja)
		MsgStop("Cliente "+CA100FOR+"/"+cLoja+" n�o existe. Favor verificar se o c�digo/loja do cliente foi digitado corretamente","Aten��o")
		_lRet := .F.
	Endif
    cCgc:=SA1->A1_CGC
Endif

 dbSelectArea("ZZV")
ZZV-> ( dbSetOrder(2) )
If ZZV-> ( dbSeek(xFilial("ZZV")+"FIL"+cCgc) )
	lLjCamp := .t.
Endif

//If _cCNPJ == _cForn .And. !Empty(SF1->F1_ZZNFTS) .And. _cFunName != "FATA0049" .and. lLjCamp
If _cCNPJ == _cForn .And. _cFunName != "FATA0049" .and. lLjCamp .and. aCols[1][nPosOp] == '92'
	Alert('Para esta opera��o utilize a op��o Atualiza��es->Entradas Nota Fiscal->Entrada Transferencia.')	//FATA0049
	_lRet := .F.
Else
	If !_cFunName $ "COMA0008/MATA116"
		If _cForn $ _cFornP .And. GetNewPar("ZZ_VLNFPIR", .T.) .And. aCols[1][nPosOp] == '0A'
			Alert("Para inclus�o de nota Pirelli utilize a op��o Atualiza��es->Entradas Nota Fiscal->Nf Conhec.Frete Entrada")
			_lRet := .F.
		EndIf
		//Fun��o para verificar se o campo B1_TIPO � diferente de (PN, CM, PT, PC) o Centro de Custo (D1_CC) dever� ser obrigat�rio.
		If _lRet
			_lRet := U_ComA0013(.T.)
		EndIf
	EndIf
EndIf
If _lRet 
	If _cFunName == "ZZMT103"  .or. _cFunName == "MATA103" 
		If !l103Auto // Nao ExecAuto
			For nI := 1 to Len(aCols)
				If (!Empty(aCols[nI,nPosOp]) .and. !Substr(aCols[nI,nPosOp],1,1) $ "0,1,2,3,4") .or. aCols[nI,nPosOp] == '01' // nao entrada ou 01-venda
					Alert("Opera��o digitada no item "+ aCols[nI,nPosItem] +" n�o � de entrada. Favor reiniciar o processo de entrada.")
					_lRet := .F.
					Exit
				Endif
				If !Empty(aCols[nI,nPosOp]) .and. aCols[nI,nPosOp] <> aCols[1][nPosOp] // operacoes diferentes na mesma nota
					Alert("Opera��o digitada no item "+ aCols[nI,nPosItem] +" � diferente do primeiro item. Favor reiniciar o processo de entrada.")
					_lRet := .F.
					Exit
				Endif
			Next
		Endif
	Endif		
Endif
//�������������������������������Ŀ
//�Entrada de transfer�ncia manual�
//���������������������������������
IF _lRet .and. aCols[1][nPosOp] == '92'
	If _cCNPJ <> _cForn
		Alert("Opera��o de transfer�ncia inv�lida. O fornecedor n�o � uma filial da empresa!")
		_lRet := .f.
	Endif
	If cSerNfe <> cSerie
		Alert("S�rie inv�lida. Informe a serie corretamente!")
		_lRet := .f.
	Endif
Endif
//�����������������Ŀ
//�Entrada de compra�
//�������������������
IF _lRet .and. cEmpOrig == "02" .and. aCols[1][nPosOp] == '0A' .and. _cCNPJ == _cForn
	Alert("Opera��o de compra inv�lida. O fornecedor � uma filial da empresa!")
	_lRet := .f.
Endif  


//�����������Ŀ
//� Devolucao �
//�������������
If _lRet .and. cTipo == 'D' .and. (( _cForn == "0078799"  .and. cEmpOrig == "02") .or. (_cForn == "0078798"  .and. cEmpOrig <> "02") ) // Cliente Equity = 0078799 e cliente CPA = 0078798
	Alert("Opera��o de Devolu��o inv�lida. O fornecedor � uma filial da empresa!")
	_lRet := .f.
Endif

// Validar Cadastro de Fornecedor -- Evania - 19/01/2015

If _lRet .and. !cTipo $ "B|D"
	
//	nReg := SA2-> (Recno())
	
	If !Alltrim(SA2->A2_COD) $ Alltrim(_cFornP) .and. !Alltrim(SA2->A2_COD) $ Alltrim(_cCNPJ) .and. Alltrim(SA2->A2_COD) <> "9999999" // nao consistir Pirelli/Campneus/Fornecedor financeiro
		While .t.
			_lRet:=.t.
			_lRet := U_ZVldfor(SA2->A2_COD,SA2->A2_LOJA)   //-- 19/01/21 - Evania -- consistencia cadastro de fornecedor
			
			If !_lRet
				nOpcao:=AxAltera("SA2",nReg,nOpc,,,,,,,,,)
				If nOpcao == 3
					Alert("� necess�rio corrigir as informa��es.")
					_lRet:=.F.
				Endif
			Else
				Exit
			Endif
		End
	Endif
Endif

RestArea( aArea )

Return(_lRet)
