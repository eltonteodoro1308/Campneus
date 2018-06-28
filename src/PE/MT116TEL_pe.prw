#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT116TEL  ºAutor  ³Microsiga           º Data ³  04/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³aParametros[1]  Define a Rotina : 2-Inclusao / 1-Exclusao   º±±
±±º          ³aParametros[2]  Considerar Notas : 1-Compra,2 Devolucao     º±±
±±º          ³aParametros[3]  Data Inicial para Filtro das NFs Originais  º±±
±±º          ³aParametros[4]  Data Final para Filtro das NFs originais    º±±
±±º          ³aParametros[5]  Cod. Fornecedor para Filtro das NFs Orig	  º±±
±±º          ³aParametros[6]  Loja Fornecedor para Fltro das NFs Originaisº±±
±±º          ³aParametros[7]  Utiliza Formulario proprio ? 1-Sim,2-Nao    º±±
±±º          ³aParametros[8]  Num. da NF de Conhecimento de Frete         º±±
±±º          ³aParametros[9]  Serie da NF de COnhecimento de Frete        º±±
±±º          ³aParametros[10] Codigo do Fornecedor da NF de FRETE         º±±
±±º          ³aParametros[11] Loja do Fornecedor da NF de Frete           º±±
±±º          ³aParametros[12] TES utilizada na Classificacao da NF        º±±
±±º          ³aParametros[13] Valor total do Frete sem Impostos           º±±
±±º          ³aParametros[14] Estado de Origem do Frete                   º±±
±±º          ³aParametros[15] Aglutina Produtos : .T. , .F.               º±±
±±º          ³aParametros[16] Base do Icms Retido                         º±±
±±º          ³aParametros[17] Valor do Icms Retido                        º±±
±±º          ³aParametros[18] Filtra notas com conh frete .F.= Não,.T.=Simº±±
±±º          ³aParametros[19] Especie da Nota Fiscal					  º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT116TEL()

Local oDlg
Local oCombo1
Local aCombo1	    := {'Excluir NF de Conhec. Frete','Incluir NF de Conhec. Frete'} // Quanto a nota?
Local nCombo1	    := 2
Local oCombo2
Local aCombo2	    := {'NF Normal','NF Devol.'} // Considerar?
Local nCombo2	    := 1
Local oCombo3
Local aCombo3	    := {'Nao','Sim'} //Formulario Proprio
Local nCombo3	    := 1
Local oCombo4
Local aCombo4		:= {'Nao','Sim'} //Aglutina Produtos ?
Local nCombo4		:= 1
//Local oCombo5
//Local aCombo5	    := {'A PAGAR','PAGO',''} //Frete Pago?
//Local nCombo5       := 1
Local oCombo6
Local aCombo6	    := {'030-Conhec.Frete','033-Serviço de Frete',''} //Tipo de frete
Local nCombo6       := 1

Local c116Combo1	:= aCombo1[nCombo1]
Local c116Combo2	:= aCombo2[1]
Local c116Combo3	:= aCombo3[1]
Local c116Combo4	:= aCombo4[1]
//Local c116Combo5   	:= aCombo5[3]
Local c116Tes		:= aCombo6[3]
Local d116DataDe	:= dDataBase-60
Local d116DataAte	:= dDataBase
Local c116FornOri	:= CriaVar("F1_FORNECE")
Local c116LojaOri	:= CriaVar("F1_LOJA")
Local c116NumNF		:= CriaVar("F1_DOC")
Local c116SerNF		:= CriaVar("F1_SERIE")
Local c116Fornece	:= CriaVar("F1_FORNECE")
Local c116Loja		:= CriaVar("F1_LOJA")
Local n116Valor		:= 0
Local c116UFOri		:= CriaVar("A2_EST")
Local n116BsIcmret	:= 0
Local n116VlrIcmRet	:= 0
Local lAglutina		:= .F.
Local lAux			:= .F.
Local lRet			:= .F.
Local aCliFor		:= {{'Fornecedor','FOR'},{'Cliente','SA1'}}
Local oCliFor
Local oFornOri
Local cEspNcf		:= ""
Local cTpNf 		:= "A"

Private cNomeFor	:=""
//Private lFretePir := SuperGetMV("ZZ_INCFRET",.F. ,.T.) // .T. Obriga lançamento frete Pirelli a pagar

If !( l116Auto )
	DEFINE MSDIALOG oDlg FROM 87 ,52  TO 450,601 TITLE 'Parametros Nota Fiscal de Conhecimento de Frete' Of oMainWnd PIXEL
	
	// 'Parametros do Fornecedor'
	@ 22 ,3   TO 68 ,274 LABEL "Parametros do Fornecedor" OF oDlg PIXEL
	@ 7  ,6   SAY 'Quanto a Nota' Of oDlg PIXEL SIZE 43 ,9 //Quanto a Nota-STR0093
	@ 6  ,52  MSCOMBOBOX oCombo1 VAR c116Combo1 ITEMS aCombo1 SIZE 83 ,50 OF oDlg PIXEL VALID (nCombo1:=aScan(aCombo1,c116Combo1))
	@ 7  ,145 SAY 'Considerar' Of oDlg PIXEL SIZE 54 ,9  //Considerar-STR0096
	@ 6  ,184 MSCOMBOBOX oCombo2 VAR c116Combo2 ITEMS aCombo2 SIZE 60 ,50 OF oDlg PIXEL When (nCombo1==2) VALID ((nCombo2:=aScan(aCombo2,c116Combo2)),oCliFor:Refresh(),oFornOri:cF3:=aCliFor[nCombo2][2],c116FornOri:=SPACE(Len(c116FornOri)),c116LojaOri:=SPACE(Len(c116LojaOri)))
	@ 34 ,12  SAY 'Data Inicial' Of oDlg PIXEL SIZE 60 ,9 //Data Inicial-STR0094
	@ 34 ,145 SAY 'Data Final' Of oDlg PIXEL SIZE 59 ,9 //Data Final-STR0095
	@ 33 ,48  MSGET d116DataDe  Valid !Empty(d116DataDe) OF oDlg PIXEL SIZE 60 ,9
	@ 33 ,185 MSGET d116DataAte Valid !Empty(d116DataAte) OF oDlg PIXEL SIZE 60 ,9
	@ 52 ,12  SAY oCliFor VAR aCliFor[nCombo2][1] Of oDlg PIXEL SIZE 28 ,9
	@ 51 ,48  MSGET oFornOri VAR c116FornOri Picture PesqPict('SA2','A2_COD') F3 aCliFor[nCombo2][2] OF oDlg PIXEL SIZE 35 ,9 When (nCombo1==2) valid Forn116(nCombo2,c116FornOri,c116LojaOri,.T.)
	@ 51 ,88  MSGET c116LojaOri Picture PesqPict('SA2','A2_LOJA') F3 CpoRetF3('A2_LOJA')OF oDlg PIXEL SIZE 17 ,9 When (nCombo1==2) //.Or.U_A116StpVld(nCombo2,c116FornOri,c116LojaOri,.F.)
	@ 52 ,110 SAY Substr(cNomeFor,1,30) of oDlg PIXEL SIZE 100,9
	
	// 'Dados da NF de Frete'
	@ 74,3 TO 145,274 LABEL 'Dados da NF de Frete' OF oDlg PIXEL //STR0097
	//	@ 86, 10  SAY STR0098 Of oDlg PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //'Form. Proprio'
	//	@ 85, 47  MSCOMBOBOX oCombo3 VAR c116Combo3 ITEMS aCombo3 SIZE 35 ,50 OF oDlg PIXEL When (nCombo1==2) VALID ((nCombo3:=aScan(aCombo3,c116Combo3)),c116NumNF:=SPACE(Len(c116NumNF)),c116SerNF:=SPACE(Len(c116SerNF)))
	
	@ 86,10 SAY 'Cod. TES' Of oDlg PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //STR0101
	@ 85,47 MSCOMBOBOX oCombo6 VAR c116TES ITEMS aCombo6 SIZE 70 ,50 OF oDlg PIXEL when (nCombo1==2) VALID !Empty(c116TES)
	
	@ 86, 145 SAY 'Num. Conhec.' Of oDlg PIXEL SIZE 39 ,9  //STR0099
	@ 85, 185 MSGET c116NumNF Picture PesqPict('SF1','F1_DOC') OF oDlg PIXEL SIZE 31 ,9 When (nCombo1==2.And.nCombo3==1) //VALID U_A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)
	
	@ 86, 225 SAY 'Serie' Of oDlg PIXEL SIZE 15 ,9  //STR0100
	@ 85, 242 MSGET c116SerNF Picture PesqPict('SF1','F1_SERIE') OF oDlg PIXEL SIZE 19 ,9  When (nCombo1==2.And.nCombo3==1) //VALID U_A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)
	
	@ 105, 10  SAY 'Fornecedor' Of oDlg PIXEL SIZE 47 ,9  //STR0089
	@ 104, 48  MSGET c116Fornece  Picture PesqPict('SF1','F1_FORNECE') F3 "FOR" OF oDlg PIXEL SIZE 37 ,9 VALID !Empty(c116Fornece)//VALID U_A116StpVld(1,c116Fornece,c116Loja,.F.)
	@ 104, 88  MSGET c116Loja Picture PesqPict('SF1','F1_LOJA') F3 CpoRetF3('F1_LOJA')OF oDlg PIXEL SIZE 17 ,9 VALID !Empty(c116Loja) //VALID U_A116StpVld(1,c116Fornece,c116Loja,,.F.)
	
	@ 105,185  SAY 'UF Origem' Of oDlg PIXEL SIZE 36 ,9  //STR0103
	@ 104,242  MSGET c116UfOri Picture PesqPict('SA2','A2_EST') F3 CpoRetF3('A2_EST') OF oDlg PIXEL SIZE 25 ,9 When (nCombo1==2) VALID ExistCPO("SX5","12"+c116UFOri)
//	@ 124,10  SAY "Frete " Of oDlg PIXEL SIZE 37 ,9
//	@ 123,50  MSCOMBOBOX oCombo5 VAR c116Combo5 ITEMS aCombo5 SIZE 40,50 OF oDlg PIXEL When (nCombo1==2) VALID !Empty(c116Combo5) .AND. (nCombo5:=aScan(aCombo5,c116Combo5))
	@ 124,144 SAY 'Valor do Frete' Of oDlg PIXEL SIZE 42 ,9  //STR0040
	@ 123,203 MSGET n116Valor Picture PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL SIZE 61 ,9 When (nCombo1==2)
	//	@ 125,120 SAY STR0104 Of oDlg PIXEL SIZE 48 ,9 //'Aglutina Produtos ?'
	//	@ 125,180 MSCOMBOBOX oCombo4 VAR c116Combo4 ITEMS aCombo4 SIZE 30 ,50 OF oDlg PIXEL When (nCombo1==2) VALID (nCombo4:=aScan(aCombo4,c116Combo4))
	//	@ 146,10  SAY STR0105 Of oDlg PIXEL SIZE 49 ,9 //'Bs Icms Ret.'
	//	@ 144,47  MSGET oGetBs VAR n116BsIcmRet  Picture PesqPict('SD1','D1_BRICMS') F3 CpoRetF3('D1_BRICMS');
	//	          OF oDlg PIXEL SIZE 70 ,9 When (nCombo1==2) VALID Positivo(n116BsIcmRet)
	//	@ 144,140 SAY STR0106 Of oDlg PIXEL SIZE 41 ,9 //'Vlr. Icms Ret.'
	//	@ 143,180 MSGET n116VlrIcmRet Picture PesqPict('SD1','D1_ICMSRET') F3 CpoRetF3('D1_ICMSRET');
  	//	          OF oDlg PIXEL SIZE 70 ,9 When (nCombo1==2) VALID Positivo(n116VlrIcmRet)
	@157,220 BUTTON 'Confirma' SIZE 35 ,10  FONT oDlg:oFont ACTION If(Test116(nCombo1,c116FornOri,c116LojaOri,c116NumNf,c116SerNf,c116Fornece,c116Loja,c116UfOri,n116Valor),(lRet:=.T.,oDlg:End()),Nil)  OF oDlg PIXEL  //'Confirma >>'
	@157,180 BUTTON 'Cancelar' SIZE 35 ,10  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'<< Cancelar'
	
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

If nCombo1==1 //Excluir
	c116FornOri:=c116Fornece
	c116LojaOri:=c116Loja
Else
	cTpNf := Posicione("SA2",1,xFilial("SA2")+c116Fornece+c116Loja,"A2_ZZEMNFE")
	If cTpNf == "S"
		cEspNcf := "CTE"
	Endif
	If Substr(c116Tes,1,3) == "033"
		cEspNcf := "NFST"
	Endif
Endif

//If nCombo5 == 2 // Frete pago = sim
//	MV_PAR41 := "S"
//Else
	MV_PAR41 := "N"
//Endif

//nCombo1:= If(nCombo1==1,2,1) //Excluir e' 1 no padrao

aParametros:= {	nCombo1,;					// 1 Define a Rotina : 1-Exclusao , 2-Inclusao
nCombo2,;    				// 2 Considerar Notas : 1 - Compra , 2 - Devolucao
d116DataDe,; 				// 3 Data Inicial para Filtro das NF Originais
d116DataAte,;				// 4 Data Final para Filtro das NF originais
c116FornOri,;				// 5 Cod. Fornecedor para Filtro das NF Originais
c116LojaOri,;				// 6 Loja Fornecedor para Fltro das NF Originais
nCombo3,; 	 				// 7 Utiliza Formulario proprio ? 1-Sim,2-Nao
c116NumNF,;  				// 8 Num. da NF de Conhecimento de Frete
c116SerNF,;  				// 9 Serie da NF de COnhecimento de Frete
c116Fornece,;				// 10 Codigo do Fornecedor da NF de FRETE
c116Loja,;   				// 11 Loja do Fornecedor da NF de Frete
Substr(c116Tes,1,3),;    	// 12 Tes utilizada na Classificacao da NF
n116Valor,;  				// 13 Valor total do Frete sem Impostos
c116UFOri,;  				// 14 Estado de Origem do Frete
.F.,;						// 15 Aglutina Produtos : .T. , .F.
n116BsIcmRet,; 				// 16 Base do Icms Retido
n116VlrIcmRet,; 			// 17 Icms Retido
.f.,;						// 18 Filtro NF - se F1_ORIGLAN == .f.
cEspNcf } 					// 19 Especie do conhecimento

If lRet .and. ExistBlock("MT116VTP")
	lMT116VTP:= ExecBlock("MT116VTP",.F.,.F.,{aParametros} )
	If ValType(lMT116VTP) = "L"
		lRet := lMT116VTP
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Test116   ºAutor  ³Microsiga           º Data ³  04/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Test116(nCombo1,cFornOri,cLojOri,cNotaFre,cSerFre,cFornFre,cLojFre,cUfFre,nValorFre)

Local dDtCaixa 	:= u_FINA032B()
Local lTestRet  := .t.
Local cCodPne	:= AllTrim(GetMV("ZZ_CNPJCAM")) //006318 - Codigo do fornecedor Pneuac
Local cCodPir 	:= SuperGetMV("ZZ_CDFORPR",.F. ,"001002")

If __cUserID <> "000000" //!( Upper(Alltrim(cUserName)) $ GetMv('ZZ_USRFREE') ) - Shiro 02/05/16
	If Empty( dDtCaixa )
		MsgStop("Não é permitido incluir/excluir frete com o caixa fechado.","Support Retail 0800 285 2230")
		lTestRet := .f.
	Endif
Endif                                                  

If lTestRet
	If nCombo1 == 2 // Inclusao
		If Empty(cFornOri) .or. Empty(cLojOri) .or. Empty(cNotaFre) .or. Empty(cSerFre) .or. Empty(cFornFre) .or. Empty(cLojFre) .or. Empty(cUfFre)
			MsgStop("Existem Dados Não Preenchidos")
			lTestRet := .f.
		Endif
		If nValorFre <= 0
			MsgStop("Favor digitar um valor válido")
			lTestRet := .f.
		Endif
		If lTestRet
			dbSelectArea("SA2")
			dbSetOrder(1)
			If !dbSeek(xFilial("SA2")+cFornFre+cLojFre)
				MsgStop("Fornecedor do Frete não existe. Favor verificar se o código/loja do fornecedor foi digitado corretamente","Atenção")
				lTestRet := .f.
//			Else
//				If cCodPir == Alltrim(cFornOri) .and. !lFretePir
//					MsgStop("Para lançamento de notas fiscais de compra Pirelli utiliza a opção Entrada Compra Pirelli. Não é mais necessário lançar o frete pago.","Atenção")
//					lTestRet := .f.
//				Endif
			Endif
		Endif
		If lTestRet
			dbSelectArea("SF1")
			dbSetOrder(1)
		    If dbSeek(xFilial("SF1")+Right("000000000"+Alltrim(cNotaFre),9)+cSerFre+cFornFre+cLojFre)
		     	cStatusFre := Iif(Posicione("SF8",3,xFilial("SF8")+Right("000000000"+Alltrim(cNotaFre),9)+cSerFre+cFornFre+cLojFre,"F8_ZZPAGO")=="S","PAGO","A PAGAR")
		     	MsgStop("Documento: "+Right("000000000"+Alltrim(cNotaFre),9)+" Série: "+cSerFre+" - Lançado em "+dtoc(SF1->F1_DTDIGIT)+" na condição: "+cStatusFre+;
		     	" Transportador: "+SA2->A2_NOME,"Atenção")  
		    	lTestRet := .f.
		    Endif
		Endif
	Else // Exclusao
		If Empty(cFornFre) .or. Empty(cLojFre)
			MsgStop("Existem Dados do Frete Não Preenchidos")
			lTestRet := .f.
		Endif
	Endif
//	If lTestRet .and. nCombo1 == 2 // Inclusao
//		If nCombo5 == 2 // Frete pago = sim
//			If Alltrim(cFornOri)  == Alltrim(cCodPne) // Fornecedor eh uma Pneuac
//			   	MsgStop("A origem do conhecimento de frete é outra filial da empresa. O frete deve ser lançado como A PAGAR. Favor corrigir")
//			   	lTestRet := .f.
//			Else
//				If !MsgNoYes("Foi escolhido opção de frete PAGO. Neste caso NÃO efetuaremos o pagamento deste CONHECIMENTO DE FRETE. Confirma ??","Atenção" )
//					lTestRet := .f.
//				Endif
//			Endif	
//		Elseif nCombo5 == 1
//			If !MsgNoYes("Foi escolhido opção de frete A PAGAR. Será gerado registro de pagamento no contas a pagar. Confirma ??","Atenção" )
//				lTestRet := .f.
//			Endif
//		Else
//			MsgStop("Não foi preenchido o campo FRETE")
//			lTestRet := .f.
//		Endif
//	Endif
Endif

Return lTestRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Forn116   ºAutor  ³Microsiga           º Data ³  04/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Forn116(nTipo,cFornece,cCodLoja,lNome)

Local lFornRet	:= .F.
Local aArea		:= GetArea()

If Empty(cFornece)
	MsgAlert("Favor preencher os campos do fornecedor","Support Retail 0800 285 2230")
Else
	If nTipo == 2  // Devolucao
		If !Empty(cFornece)
			If cCodLoja == Nil .Or. Empty(cCodLoja)
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+cFornece))
				If SA1->(Found())
					lFornRet := .T.
					If lNome
						cNomeFor:=SA1->A1_NOME
					Endif
				Else
					HELP("  ",1,"REGNOIS")
				EndIf
			Else
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+cFornece+cCodLoja))
				If SA1->(Found())
					lFornRet := .T.
					If lNome
						cNomeFor:=SA1->A1_NOME
					Endif
				Else
					HELP("  ",1,"REGNOIS")
				EndIf
			EndIf
		EndIf
	Else   //Normal
		If !Empty(cFornece)
			If cCodLoja == Nil .Or. Empty(cCodLoja)
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+cFornece))
				If SA2->(Found())
					lFornRet := .T.
					If lNome
						cNomeFor:=SA2->A2_NOME
					Endif
				Else
					HELP("  ",1,"REGNOIS")
				EndIf
			Else
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+cFornece+cCodLoja))
				If SA2->(Found())
					lFornRet := .T.
					If lNome
						cNomeFor:=SA2->A2_NOME
					Endif
				Else
					HELP("  ",1,"REGNOIS")
				EndIf
			EndIf
		EndIf
	EndIf
Endif
RestArea(aArea)

Return lFornRet
