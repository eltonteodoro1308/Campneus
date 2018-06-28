#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT116FTR  บAutor  ณGuilherme H.Gouveia บ Data ณ  14/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada para filtrar os registros que serao        บฑฑ
ฑฑบ          ณapresentados no Browse                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT116QRY()

Local cRetorno	:=	""
Local cCodPir 	:= SuperGetMV("ZZ_CDFORPR",.F. ,"001002")
Local cCodCamp := AllTrim(GetMV("ZZ_CNPJCAM")) //006318 codigo de fornecedor Campneus

If nRotina == 2
	cRetorno := " And ( F1_STATUS = ' ' OR (F1_STATUS = 'A' And ( F1_ORIGLAN = 'F ' OR F1_ORIGLAN = '  '  ) ) ) "
	cRetorno += " And ( F1_ZZICAE <> 'S' Or (F1_ZZICAE = 'S' And F1_ZZPNBLQ <> 'S')) " 
	If Alltrim(aParametros[5]) $ cCodPir .or. Alltrim(aParametros[5]) $  cCodCamp
		cRetorno += " And F1_TPFRETE = 'F' " 
		dbSelectArea("SA2")
		dbSetOrder(1)	
	    If dbSeek(xFilial("SA2")+aParametros[10]+aParametros[11]) // codigo e loja da transportadora
	    	dbSelectArea("SA4")
	    	dbSetOrder(3)
	    	If dbSeek(xFilial("SA4")+SA2->A2_CGC)
	        	cRetorno += " And F1_TRANSP = '" + Alltrim(SA4->A4_COD)+ "'"
	        Endif
	    Endif    
	Endif


EndIf

Return(cRetorno)