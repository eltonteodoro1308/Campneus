#INCLUDE 'PROTHEUS.CH'


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103COR  �Autor  �Jean Frizo          � Data �  01/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada criado para manipulacao das cores da      ���
���          � legenda do MATA103 quando chamada pelo funcao COMA0042     ���
�������������������������������������������������������������������������͹��
���Uso       � MATA103                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT103COR()

Local aCorUsr	 


If FunName() == "COMA0042"
	
	aCorUsr	:= StaticCall( COMA0042 , COM042Cor, Nil  ) 		

EndIf


Return aCorUsr