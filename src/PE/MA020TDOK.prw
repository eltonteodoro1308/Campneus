#include "Protheus.ch"
#include  "Topconn.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA020TDOK ºAutor  ³Evania Victorio     º Data ³  17/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar campos na inclusão ou alteração do cadastro de     º±±
±±º          ³ Fornecedores.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MA020TDOK()				

	Local  lRet     := .t. 
	Local _lvalid   := .f.
	Local _lEnd	  := .t.
	Local _lEmail   := .t.
	Local _lCarac1  := .f. 
	Local  nRGx     := 1 
	Local  cCODFOR  := SuperGetMV("ZZ_FORINTG",.F. ,"61234985|59179838|22301988")                  
	Local nT 		:= 0
	Local lTelErro 	:= .f.
	Local _xTel		:= ""
	Local cSubjMail := ""
	Local cMensMail := ""


	If lRet .and. ((Len(alltrim(M->A2_CGC))==14 .and. M->A2_TIPO <> "J") .or. (Len(alltrim(M->A2_CGC))==11 .and. M->A2_TIPO <> "F"))
		Aviso("Fornecedor","Tipo não confere com o tamanho do CNPJ/CPF. Favor verificar",{"OK"})
		lRet := .f.
	Endif  
	If lRet .and. (Alltrim(M->A2_CGC) $ "00000000000/11111111111/22222222222/33333333333/44444444444/55555555555/66666666666/77777777777/88888888888/99999999999")
		MsgStop("CNPJ/CPF inventado. Favor corrigir.")
		lRet := .f.
	Endif

	If lRet .and. Substr(M->A2_NOME,1,1)== " "
		MsgStop("Nome não pode começar com espaço em branco. Favor corrigir.")
		lRet := .f.
	Endif
	//------------------ endereço do fornecedor ---
	_lEnd := If(At(",",M->A2_END)==0,.F.,.T.)

	If lRet .and.!_lEnd
		MsgStop("Endereço inválido: É necessário que exista uma vírgula(,) antes do número do endereço. Favor corrigir.")
		lRet := .f.
	Endif
	If lRet .and. Substr(M->A2_END,1,1)== " "
		MsgStop("Endereço não pode começar com espaço em branco. Favor corrigir.")
		lRet := .f.
	Endif
	If lRet .and. Empty(M->A2_BAIRRO)
		MsgStop("Campo Bairro não preenchido. Favor corrigir.")
		lRet := .f.
	Endif
	If lRet .and. Substr(M->A2_BAIRRO,1,1)== " "
		MsgStop("Bairro não pode começar com espaço em branco. Favor corrigir. ")
		lRet := .f.
	Endif 
	If lRet .and. Empty(M->A2_EST)
		MsgStop("Campo Estado não preenchido. Favor corrigir.")
		lRet := .f.
	Endif
	If lRet .and. Empty(M->A2_COD_MUN)
		MsgStop("Campo codigo de municipio não preenchido. Favor corrigir.")
		lRet := .f.
	Endif 
	If lRet .and. Empty(M->A2_MUN)
		MsgStop("Campo Municipio não preenchido. Favor corrigir.")
		lRet := .f.
	Endif 
	If lRet .and. (Len(Alltrim(M->A2_CEP))<> 8)
		MsgStop("Campo CEP está incompleto. Favor corrigir.")
		lRet := .f.
	Endif

	If lRet .and. M->A2_TIPO == "J" .and. Empty(M->A2_INSCR)
		MsgStop("Campo Inscrição estadual não preenchido. Favor corrigir.")
		lRet := .f.
	Endif

	If  M->A2_TIPO=="F"    // -- pessoa fisica 

		If lRet .and. Empty(M->A2_PFISICA)    
			MsgStop("Campo Nro RG/Ced.Estr. não preenchido. Favor corrigir.")
			lRet := .f. 
		Endif
		If lRet .and. (Len(Alltrim(M->A2_PFISICA)) < 6)
			MsgStop("Campo Nro RG/Ced.Estr. inválido. Favor corrigir.")
			lRet := .f.
		Endif                                                                                                       
		If lRet .and. (Alltrim(M->A2_PFISICA) $  "000000000000000000/111111111111111111/222222222222222222/333333333333333333/444444444444444444/555555555555555555/66666666666666666/777777777777777777/888888888888888888/999999999999999999/XXXXXXXXXXXXXXXXXX/xxxxxxxxxxxxxxxxxx") 
			MsgStop("Campo Nro RG/Ced.Estr. inválido. Favor corrigir.")
			lRet := .f.
		Endif  
		If lRet 
			_lvalid := .f. 
			For nRGx:= 1  to len(Alltrim(M->A2_PFISICA))
				If !IsAlpha(SubStr(M->A2_PFISICA,nRGx,1)) //-- encontrou num caracter numerico (função para impedir somente letras no RG)      
					_lvalid := .t.  
					exit  
				Endif  
			Next
			If !_lvalid  
				MsgStop("Campo Nro RG/Ced.Estr. inválido. Favor corrigir.")
				lRet := .f.
			Endif  
		Endif  

		If  lRet .and.  M->A2_ZZGRFOR <> "93"
			MsgStop("Grupo do fornecedor inválido. Pessoa física somente 93. Favor corrigir.")
			lRet := .f.
		Endif

	Endif

	If  Substr(M->A2_CGC,1,8) $ cCODFOR  //-- Codigo CNPJ raiz dos Fornecedores do grupo     
		if  lRet .and. M->A2_ZZGRFOR <> "90"
			MsgStop("Grupo do fornecedor inválido. Empresa do grupo. Favor corrigir.")
			lRet := .f.
		Endif   
	else 
		If lRet .and. M->A2_ZZGRFOR == "90"
			MsgStop("Grupo do fornecedor inválido. Empresa não é do grupo. Favor corrigir.")
			lRet := .f.
		Endif 
	Endif

	//---------------------- E-MAIL ----------
	_lEmail := If(At("@",M->A2_EMAIL)==0,.F.,.T.)

	_lCarac1 := If(Len(Alltrim(M->A2_EMAIL))==1,.t.,.f.)

	If lRet .and. (!_lEmail .or. _lCarac1)
		MsgStop("O campo EMAIL do Fornecedor é invalido. Favor corrigir.")
		lRet := .f.
	Endif  

	If lRet 
		lRet := U_ZVldMail(M->A2_EMAIL)
	Endif

	If  Substr(M->A2_CGC,1,8) $ cCODFOR  //-- Codigo CNPJ raiz dos Fornecedores do grupo

		If lRet .and. At("@PNEUAC",Upper(M->A2_EMAIL))==0  .and.;
		At("@CAMPNEUS",Upper(M->A2_EMAIL))==0 .and.;
		At("@ABOUCHAR",Upper(M->A2_EMAIL))==0 .and. ;
		At("@PIRELLI",Upper(M->A2_EMAIL))==0  .and. ;
		At("@EQUITY",Upper(M->A2_EMAIL))==0 

			MsgStop("O campo EMAIL do Fornecedor do Grupo é invalido. Favor corrigir.")
			lRet := .f. 
		Endif   
	else
		If  M->A2_TIPO == "J"
			If  lRet .and.;
			(At("@PNEUAC",Upper(M->A2_EMAIL))<>0  .or. ;
			At("@CAMPNEUS",Upper(M->A2_EMAIL))<>0 .or.;
			At("@ABOUCHAR",Upper(M->A2_EMAIL))<>0 .or.;
			At("@PIRELLI",Upper(M->A2_EMAIL))<>0  .or.;
			At("@EQUITY",Upper(M->A2_EMAIL))<>0)  

				MsgStop("O campo EMAIL do Fornecedor é invalido. Favor corrigir.")
				lRet := .f. 
			Endif    
		Endif     
	Endif
	//------------------------
	If lRet .and. Len(Alltrim(M->A2_DDD))< 2  
		MsgStop("Campo DDD não preenchido ou incompleto. Favor corrigir.")
		lRet := .f.
	Endif 
	If lRet .and. Len(Alltrim(M->A2_DDD))== 2 
		If  (left(Alltrim(M->A2_DDD),1) == "0") .or. (left(Alltrim(M->A2_DDD),2) == "10" ) 
			MsgStop("Campo DDD é inválido. Favor corrigir.")
			lRet := .f.
		Endif 
	Endif 
	If lRet .and. Len(Alltrim(M->A2_DDD))== 3  
		If  (left(Alltrim(M->A2_DDD),1) <> "0") .or. (left(Alltrim(M->A2_DDD),3) == "010") .or. (left(Alltrim(M->A2_DDD),2) == "00")
			MsgStop("Campo DDD é inválido. Favor corrigir.")
			lRet := .f.
		Endif 
	Endif 

	_xTel := Alltrim(M->A2_TEL)

	If lRet .and. (Len(_xTel) < 8)
		MsgStop("Campo Telefone não preenchido ou incompleto. Favor corrigir.")
		lRet := .f.
	Endif


	If lRet .and. (Len(_xTel) < 8 .or. Len(_xTel) > 9)
		MsgStop("Campo Telefone com número inválido. Favor corrigir.")
		lRet := .f.
	Endif

	For nT := 1 to Len(_xTel)
		If !IsDigit(Substr(_xTel,nT,1))
			lTelErro := .t.
		Endif   	
	Next
	If lTelErro
		MsgStop("Campo Telefone deve conter apenas números. Favor corrigir.")
		lRet := .f.
	Endif

	If lRet .and. Len(_xTel) == 9 .and. Substr(M->A2_TEL,1,1) <> "9"
		MsgStop("Primeiro digito do Telefone é inválido. Favor corrigir.")
		lRet := .f.
	Endif
	If lRet .and. Len(Alltrim(M->A2_TELEX)) == 9 .and. Substr(M->A2_TELEX,1,1) <> "9"
		MsgStop("Primeiro digito do Celular é inválido. Favor corrigir.")
		lRet := .f.
	Endif

	If lRet .and. M->A2_TIPO == "J" 
		if Empty(M->A2_ZZTPF)
			MsgStop("Campo tipo de fornecedor não preenchido. Favor corrigir.")
			lRet := .f.
		Endif  
		If lRet .and.  Empty(M->A2_ZZEMNFE) 
			MsgStop("Campo Emite NFE não preenchido. Favor informar se Fornecedor emite NFe eletrönica?") 
			lRet := .f.
		endif
	Endif

	If lRet
		If Inclui .and. !Altera
			cSubjMail := Right(cFilant,3)+"-Inclusão de novo cadastro de fornecedor"
			cMensMail := "Email enviado automaticamente pelo sistema Protheus em decorrência de inclusão de novo cadastro de fornecedor."
			cMensMail += "<BR>Codigo: " + Alltrim(M->A2_COD)+ "/" + Alltrim(M->A2_LOJA) 
			cMensMail += "<BR>Digitado em: " + Dtoc(dDatabase)   
			cMensMail += "<BR>Razão social :" + Alltrim(M->A2_NOME)
			cMensMail += "<BR>CNPJ/CPF:" + M->A2_CGC
			cMensMail += "<BR>Inscrição Estadual :" + M->A2_INSCR
			cMensMail += "<BR>Cidade :" + Alltrim(M->A2_MUN)
			cMensMail += "<BR>Estado :" + M->A2_EST

			U_ZZMAIL(nil,"FIS03",cSubjMail,cMensMail)
		Endif
	Endif

Return lRet
