#INCLUDE "PROTHEUS.CH"

User Function SD1100I()

Private l103Exclui := PARAMIXB[3] <> 1

If !l103Auto .AND. Len(aRatAFN) > 0 .AND. FUNNAME() $ "MATA103|ZZMT103"  
	
	Begin Transaction 
		U_COM041GRV()
	End Transaction
EndIf
	
Return
