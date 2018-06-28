#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Msobjects.ch"
#Include "Topconn.ch"

/*
Autor		:	Gustavo A. Afonso
Data		:	29 setembro 2011
Rotina		:	SD1100E
Parametros	:	Nenhum
Retorno		:	Nenhum
Obs			:	Ponto de Entrada para exclus�o do registro de SEPU apos validacao.                        

LOCALIZA��O 	: 	Function A100Deleta() - Respons�vel pela exclusao de notas fiscai de entrada.
EM QUE PONTO 	: 	Antes de deletar o registro no SD1 na exclusao da Nota de Entrada.
					� voltado � rotatividade pois roda uma vez para cada item da nota.

*/
User Function SD1100E()

Private l103Exclui := .T.

// Exclus�o registro de SEPU

If !Empty(SD1->D1_ZZSEPU)
	U_Coma0050(SD1->D1_ZZSEPU)
Endif

If !l103Auto .AND. FUNNAME() $ "MATA103|ZZMT103" 
			
	Begin Transaction 
		U_COM041GRV()
	End Transaction
EndIf

Return
