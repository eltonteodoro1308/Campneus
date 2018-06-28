#Include 'Protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103LEG  �Autor  �Microsiga           � Data �  01/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada criado para manipulacao das legendas      ���
���          � do MATA103 quando chamada pelo funcao COMA0042.            ���
�������������������������������������������������������������������������͹��
���Uso       � MATA103                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT103LEG()

Local aLegUsr	

If FunName() == "COMA0042"
	
	aLegUsr	:= StaticCall( COMA0042 , COM042Leg, Nil  ) 		

EndIf

Return aLegUsr
