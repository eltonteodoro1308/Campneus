#include "protheus.ch"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MT103INF �Autor  � Guilherme Haddad Gouveia � Data � 14/10/2010 ���
������������������������������������������������������������������������������͹��
���Desc.     � Apos a gravacao de todos os registros de uma nota fiscal,       ���
���          � executa este ponto de entrada para integracao com Celerina.     ���
������������������������������������������������������������������������������͹��
���Uso       � AP                                             	               ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
User Function MT103INF()
	
Local cZZComPers	:=	AllTrim(SuperGetMv("ZZ_COMPERS",,"N"))

Local nLinAcols 	:= PARAMIXB[1]
Local nPosCC		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})

If cZZComPers == "S"
	U_FatA0027()
EndIf

aCols[nLinAcols][nPosCC]	:= SD2->D2_CCUSTO //Preenche o Centro de Custo de Acordo com Saida

Return