public class TR002ManageContract{
    
    
    /*
    Cette fonction permet de calculer le nombre de demandes de type réaménagement associé à un dossier
    */
    public static void CalculateNombreReamenagement(List<Id> dossierIds){
    
        System.debug('#### : CalculateNombreReamenagement');
        
        //La méthode utilisée permet de compter le nombre de demandes associées au dossier.
        Map<Id, Integer> mamap = DAL.getDossierCount(dossierIds);
        List<Contract> dossiersToUpdate = new List<Contract>();
        Set<Id> dossiersTraites = new Set<Id>();
        
        for(Id dossierId : dossierIds){
            if(!dossiersTraites.contains(dossierId)){
	            Contract c = new Contract(Id = dossierId, Nombre_de_Reamenagements__c = (Integer)mamap.get(dossierId) != null ? (Integer)mamap.get(dossierId) : 0);
	            dossiersToUpdate.add(c);
	            dossiersTraites.add(dossierId);
            }
        }
        
        update dossiersToUpdate ;
    }
    
    /*
    Au niveau de la Demande, dans la section « Rattachement au client Preneur ou au dossier »,  
    le champ lookup « Dossier » permet de lier un dossier à une demande. 
    Le dossier comporte 2 informations : le  nom du Tiers et le nom du Tiers avisé.
    Cette fonction (lancé à la création et à la modification) permettra de renseigner automatiquement le « Nom du Tiers »  lié au dossier
    */
    public static void RecupererNomTiers(Map<Id, List<Case>> demandeDossierIds){
        
        System.debug('#### : RecupererNomTiers');
        
        List<Case> caseToUpdate = new List<Case>();
        
        //Méthode permettant d'alimenter une map d'Id de dossier et de son dossier associé
        Map<Id,Contract> dossierByDossierId = DAL.getContractAccountByIDs(demandeDossierIds.keySet());
        
        for(Id idDossier : demandeDossierIds.keySet()){
            for(Case c : (List<Case>)demandeDossierIds.get(idDossier)){
	            Case cUpdate = new Case(Id = c.Id, AccountId = ((Contract)dossierByDossierId.get(idDossier)).AccountId) ;
	            caseToUpdate.add(cUpdate);
            }
        }
        
        update caseToUpdate;
    }
    
    /*
    Cette fonction permet de MAJ la date de Mise En Loyer d'un case avec la date de MEL de son dossier associé
    */
    public static void MiseAjourDateMEL(Set<ID> dossierIDs){
        
        System.debug('#### : MiseAjourDateMEL');

        Map<ID,List<Case>> mamap = DAL.getCasesByDossiersIDs(dossierIDs);
        Map<ID,Date> mapDate = DAL.getDateMiseEnLoyerByDossiersIDs(dossierIDs);
        
        List<Case> demandesAMettreAjour = new List<Case>();
        
        for(ID idDossier : mamap.keySet()){
            
            List<Case> newlist = (List<Case>)mamap.get(idDossier);
            for(Case cc : newList){
                cc.Date_de_traitement_de_la_MEL__c = (Date) mapDate.get(idDossier);
                demandesAMettreAjour.add(cc);
            }
        }
        
        update demandesAMettreAjour;
    }
}