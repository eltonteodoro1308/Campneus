#include 'protheus.ch'
#include 'parmtype.ch'

/*
Valida a sequencia da nota fiscal de entrada formulario proprio.
Ariane Galindo
30/04/2018
*/
user function M103NUM()
	Local cNum := PARAMIXB[1]
	Local cTipoNf  := Alltrim(SuperGetMv("MV_TPNRNFS"))
	Local cQry := ""
	Local cXAlias := GetNextAlias()

	If cTipoNf == '3'

		cQry := " SELECT TOP 1 SD9.D9_DOC NUMDOC "
		cQry += " FROM " + RetSQLName('SD9') + " SD9 " 
		cQry += " WHERE SD9.D9_FILIAL = '" + xFilial('SD9') + "' "
		cQry += " AND SD9.D9_SERIE = '" + cSerie + "' "
		cQry += " AND SD9.D_E_L_E_T_ = ' ' "
		cQry += " AND SD9.D9_DTUSO = '" + Dtos(dDataBase) + "' "

		cQry += " ORDER BY SD9.D9_DTUSO DESC, SD9.D9_DOC DESC "

		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQry ), cXAlias, .F., .T. )

		If (cXAlias)->( Eof() )
		
			(cXAlias)->(DbCloseArea())
			cXAlias := GetNextAlias()
			
			cQry := " SELECT TOP 1 SD9.D9_DOC NUMDOC "
			cQry += " FROM " + RetSQLName('SD9') + " SD9 " 
			cQry += " WHERE SD9.D9_FILIAL = '" + xFilial('SD9') + "' "
			cQry += " AND SD9.D9_SERIE = '" + cSerie + "' "
			cQry += " AND SD9.D_E_L_E_T_ = ' ' "
			cQry += " AND SD9.D9_DTUSO < '" + Dtos(dDataBase) + "' "

			cQry += " ORDER BY SD9.D9_DTUSO DESC, SD9.D9_DOC DESC "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQry ), cXAlias, .F., .T. )

		EndIf


		If (cXAlias)->(! Eof() )
			If Alltrim( (cXAlias)->NUMDOC ) <> AllTrim(cNum)
				cNum := Alltrim( (cXAlias)->NUMDOC )
				cNum := Soma1(cNum)
			EndIf
		EndIf

	EndIf

	(cXAlias)->(DbCloseArea())
return cNum 