public class AP02Garantie {

    /**
     * Met à jours divers champs techniques de l'opportunité avec les valeurs
     * récupérées sur les garanties
     */
    public static void updateOpportunity(Garantie__c[] garanties){
        
        // Objets à mettre à jour
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        // Champ garantiesWaiver
        String garantieWaiver = null;
        
        // Ids des objets à traiter
        Set<Id> oppIds = new Set<Id>();
        
        for(Garantie__c lGarantie : garanties){
            oppIds.add(lGarantie.NomdelaProjetAssocie__c);
        }
        
        // Projets Associés liés aux garanties triggered
        List<Opportunity> oppList = [SELECT Id, GarantiesWaiver__c, TopDepotGarantie__c, MontantDepotGarantie__c,MontantTotalGaranties__c,  TypeDepotGarantie__c FROM Opportunity WHERE Id IN : oppIds];
        
        // Garanties liées au même projet associé que celle triggered
		List<Garantie__c> garantieList = [SELECT Id, Description_PCOM__c, NomdelaProjetAssocie__c, Montant__c, Type__c FROM Garantie__c WHERE NomdelaProjetAssocie__c IN :oppIds];		
        
        for(Opportunity opp : oppList){
            garantieWaiver = null;
            
            Boolean lTopDepotGarantie = false;
            Integer lNbGaranties = 0;
            Double SommeMontantGarantie = 0;
            Double  SommeDepotGarantie = 0;
            Boolean isCessionOrReconnaissance = false;
            Boolean isCautionSolidaireEtrangere = false;
            
            for(Garantie__c garantie : garantieList){
                
                if(garantie.NomdelaProjetAssocie__c == opp.Id && garantie.Description_PCOM__c != null){                    
                    if(garantieWaiver == null){
                        garantieWaiver = garantie.Description_PCOM__c;
                    }
                    else{
                        garantieWaiver = garantieWaiver + '   /   ' + garantie.Description_PCOM__c;
                    }
                    
                    // On incrémente le nombre de garanties trouvées
                    lNbGaranties++;
                    if(garantie.Montant__c != null){
                        SommeMontantGarantie = garantie.Montant__c + SommeMontantGarantie ;
                    }
                    // Si Type de la garantie = 'Dépôt de garantie', mettre le flag à true
                    if(garantie.Type__c == 'Dépôt de garantie'){
                        lTopDepotGarantie = true;
                        opp.MontantDepotGarantie__c = garantie.Montant__c;
                        opp.TypeDepotGarantie__c = garantie.Type__c;
                        SommeDepotGarantie = garantie.Montant__c + SommeDepotGarantie ;
                    }
                    // Si il existe au niveau des Garanties une garantie de type [Cession Dailly..] ou [Reconnaissance de bail…]
                    if(garantie.Type__c == 'Cession Dailly des loyers de sous-location' 
                       || garantie.Type__c == 'Reconnaissance Bail Commercial/Mandat'
                       || garantie.Type__c == 'Cession Dailly sur bail commercial' ){
                           isCessionOrReconnaissance = true;
                       }
                    if(garantie.Type__c == 'Caution solidaire Personne Morale Etrangère'){
                        isCautionSolidaireEtrangere = true;
                    }
                    
                }
            }
            
            opp.GarantiesWaiver__c = garantieWaiver;
            
            opp.MontantTotalGaranties__c = SommeMontantGarantie;
            opp.DepotDeGarantie__c = SommeDepotGarantie;
            opp.TopDepotGarantie__c = lTopDepotGarantie;
            opp.NBGaranties__c = lNbGaranties;
            opp.IsGarantieCessionOuReconnaissance__c = isCessionOrReconnaissance;
            opp.IsGarantieCautionSolidaire__c = isCautionSolidaireEtrangere;
            
            oppToUpdate.add(opp);
        }
        
        update oppToUpdate;
        
        
    }
    
}