#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110TEL  �Autor  �Carlos Hirose       � Data �  07/01/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Se encontra dentro das rotinas que montam a dialog da 	  ���
���          �solicitacao de compras antes  da chamada da getdados.		  ���
�������������������������������������������������������������������������͹��
���          �Function A110INCLUI, A110ALTERA , A110EXCLUI e A110DELETA - ���
���Localiz.  �Funcoes da Solicitacao de Compras responsaveis pela inclusao���
���          �alteracao,exclusao e copia das SCs. 						  ���
�������������������������������������������������������������������������͹��
���Uso       �Campneus                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User function MT110TEL()

Local oNewDialog 	:= PARAMIXB[1]
Local aPosGet    	:= PARAMIXB[2]
Local nOpcx      	:= PARAMIXB[3]
Local nReg       	:= PARAMIXB[4]
Local nPosQtd		:= GdFieldPos("C1_QUANT")
Local nPosVlRef		:= GdFieldPos("C1_XVAREUN")
Local nLinha1	  	:= 33
Local nLinha2	  	:= 32
Local nColuna1	  	:= 30
Local nColuna2	  	:= 105
Local nS			:= 0
Public nValSol	    := 0

aadd(aPosGet[1],0) 
aadd(aPosGet[1],0)
aPosGet[1,7]:= nColuna1
aPosGet[1,8]:= nColuna2

For nS := 1 to Len(aCols)
	If !aCols[nS][Len(aCols[nS])] //Se nao deletado
		nValSol += aCols[nS,nPosQtd] * aCols[nS,nPosVlRef]
	Endif
Next

@ nLinha1,aPosGet[1,7] SAY 'Total Solic. R$' PIXEL SIZE 50,9 Of oNewDialog
@ nLinha2,aPosGet[1,8] SAY Transform(nValSol,"@E 999,999.99") PIXEL SIZE 90,10 COLOR CLR_HBLUE Of oNewDialog    

Return
