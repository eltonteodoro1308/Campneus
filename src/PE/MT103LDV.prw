#Include 'Protheus.ch'

User Function MT103LDV()

Local aLinha	:= PARAMIXB[1]
Local cAliasSD2	:= PARAMIXB[2]
//Local nPosCC	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})

aADD(aLinha, { "D1_CC", (cAliasSD2)->D2_CCUSTO, Nil } )

Return aLinha