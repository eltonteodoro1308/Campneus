#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103LCF  �Autor  �Carlos Hirose       � Data �  03/15/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para habilitar ou desabilitar os campos    ���
���          �de despesas na tela de entrada                              ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 10                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT103LCF()  

	Local cCampo := Alltrim(Upper(PARAMIXB[1]))
	Local lRet := .t.

	dbSelectArea("SZX")
	dbSetOrder(1)
	If SZX->(dbSeek(xFilial("SZX") + "CPENT")) 
		If SZX->ZX_FLAG = .F. 
			Do Case
				Case cCampo == "F1_DESCONT"
				lRet := .f.
				Case cCampo == "F1_FRETE"
				lRet := .f.
				Case cCampo == "F1_DESPESA"
				lRet := .f.
				Case cCampo == "F1_SEGURO"
				lRet := .f.
			EndCase
		EndIf
	EndIf
	
Return lRet