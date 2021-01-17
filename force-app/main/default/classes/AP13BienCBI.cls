public class AP13BienCBI {
    
	 public static void AddPoolDeBien(Bien_CBI__c[] BiensCBI) { 
       
         // Ids des projets associés aux biens
         Set<Id> projetsIds = new Set<Id>();
         
         for(Bien_CBI__c BienCBI:BiensCBI) {
             
				 projetsIds.add(BienCBI.IDProjet__c);          
         }
         
         Map<Id, Projet__c> projetsMap = new Map<Id, Projet__c>([SELECT ID FROM Projet__c WHERE ID IN :projetsIds]);
         
         for(Bien_CBI__c BienCBI:BiensCBI) {

             String idProj = BienCBI.IDProjet__c; 
             if(idProj != NULL) {
                        Projet__c Proj = projetsMap.get(idProj);
                 		ListeDeBien__c LB = new ListeDeBien__c(); 
                 	  //  LB.RecordTypeid = RT.ID;
                 		LB.Projet__c = Proj.id;
                 		LB.Biens__c = BienCBI.id;
                 
      					insert LB;
             }
         }
     }
    
    public static void supprimerLienNCBien(ListeDeBien__c[] BiensCBI) {
        Set<Id> setId = new Set<Id>();
        for(ListeDeBien__c listeDeBien : BiensCBI){
            setId.add(listeDeBien.Biens__c);
        }
        List<NoteComiteBien__c> lBiensToDelete = [SELECT Id FROM NoteComiteBien__c WHERE BienCBI__c IN :setId];

        delete lBiensToDelete;
        
    }
}