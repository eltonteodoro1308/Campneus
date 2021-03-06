#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT116AGR  �Autor  �Carlos Hirose       � Data �  07/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada apos a gravacao da nf entrada              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Campneus                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT116AGR ()

Local aArea	:= GetArea()

DbSelectArea("SF8")
DbSetOrder(3)
If DbSeek(xFilial("SF8")+cNFiscal+cSerie+cA100for)
	While !Eof() .And. xFilial("SF8")+cNFiscal+cSerie+cA100for == F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP
		RecLock("SF8",.F.)
		Replace F8_ZZPAGO with MV_PAR41
		DbCommit()
		MsUnLock()
		SF8->(DbSkip())
	Enddo
Endif

RestArea(aArea)

Return