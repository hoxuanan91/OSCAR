public class AP07Dossier {

    /**
     * Met à jour les valeurs des objets reliés au dossier lorsque celui ci
     * est créé ou modifié
     * 
     * Appelé par DossierAfterInsert et DossierAfterUpdate
     * 
     */
    public static void mettreAJourDonnees(Contract[] aListeContrats){
        
        ///////Objets à mettre à jour
        
        // Demandes (Case)
        List<Case> lCasesToUpdate = new List<Case>();
        
        // On boucle sur tous les dossiers triggerés
        for(Contract lDossier : aListeContrats){
            // On boucle sur les demandes
            for(Case lCase : lDossier.Demandes__r){
                // Mise à jours des données
                if(lCase.Commissionnaire__c != lDossier.Commissionnaire__c){
                    lCase.Commissionnaire__c = lDossier.Commissionnaire__c;
                    lCasesToUpdate.add(lCase);
                }
            }
        }

        if(!lCasesToUpdate.isEmpty()){
            update lCasesToUpdate;
        }      
    }
    
    /**
     * Vide toutes les valeurs du dossier avant de le supprimer pour que tous les objets
     * liés puissent récupérer ces valeurs null
     * 
     * Appelé par DossierBeforeDelete
     * 
     */
    public static void nettoyageDesDonnees(Contract[] aListeContrats){
        
        ///////Objets à mettre à jour
        
        // Demandes (Case)
        List<Case> lCasesToUpdate = new List<Case>();
        // Ids des Dossiers
        Set<Id> lDossiersIds = new Set<Id>();
        
        for(Contract lDossier : aListeContrats){
            lDossiersIds.add(lDossier.Id);
        }
             
        // Demandes reliées aux dossiers supprimés
        lCasesToUpdate = [SELECT Id, Dossier1Txt__c, Commissionnaire__c FROM Case WHERE Dossier1Txt__c IN :lDossiersIds];

        
        
        // Pour les demandes, nous n'avons qu'à appeler le trigger update car il rapatrie les données du dossier
        // sur la demande.
        update lCasesToUpdate;
      
    }
    
    
    
    
}