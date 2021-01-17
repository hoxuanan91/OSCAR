public class AP04Projet {
	public static void AutoCompletudeDossierFront(Projet__c[] Projets){
        //Appelé par ProjetAfterInsert
        
        Id RTId = [SELECT id  FROM RecordType where DeveloperName =: 'DocumentAssocieProjet' ][0].Id;
        DocumentAssocie__c[] DAs=new List<DocumentAssocie__c>();
        List<CategorieDocumentAssocie__c>  CDAList = [Select Id, Label__c, DemandeChefDeFile__c, DemandeClient__c,DemandeReseau__c,  DemandeNotaire__c, Section__c, Categorie__c
                                                      from CategorieDocumentAssocie__c 
                                                      where CompletudeFront__c = true 
                                                      and RecordType.DeveloperName ='CDAProjetAssocieCBI'];
        for (Projet__c Projet:Projets){ // Création Complétude initiale des document Associés 
            			for(CategorieDocumentAssocie__c CDA: CDAList){  
                            DocumentAssocie__c DA = new DocumentAssocie__c(); 
                            DA.Projet__c = Projet.ID; 
                            DA.DocCharge__c = false;
                            DA.CompletudeDossier__c = true;
                            DA.TypeDuDocument__c = CDA.Label__c;  
                            DA.CategorieDocumentAssocie__c = CDA.ID ;   
                            DA.RecordTypeId = RTId ;
                            DA.CompletudeEntete__c = true;
                            DA.DemandeChefDeFile__c = CDA.DemandeChefDeFile__c;
                            DA.DemandeClient__c = CDA.DemandeClient__c;
                            DA.DemandeNotaire__c = CDA.DemandeNotaire__c;
                            DA.DemandeDistributeur__c = CDA.DemandeReseau__c;
                            DA.Section__c = CDA.Section__c;
                            DA.categorie__c = CDA.Categorie__c; 
                            DAs.add(DA);
                     	}//for  
               }//for
        insert DAs;
    }//AutoCompletudeDossierFront
}