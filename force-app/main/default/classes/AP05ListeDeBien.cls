public class AP05ListeDeBien {
	public static void AutoCompletudeDossierFront(Map<Id,ListeDeBien__c> ListeDeBiens){
        Id RTId = [SELECT id  FROM RecordType where DeveloperName =: 'DocumentAssocieBien' ][0].Id;
        DocumentAssocie__c[] DAs=new List<DocumentAssocie__c>();
        List<CategorieDocumentAssocie__c>  CDAList = [Select Id, Label__c,Section__c, Categorie__c, DemandeChefDeFile__c, DemandeClient__c,DemandeReseau__c,  DemandeNotaire__c 
        		from CategorieDocumentAssocie__c 
        		where CompletudeFront__c = true and RecordType.DeveloperName='CDABienCBI' ];
        
        set<Id> allCBI=new Set<Id>();//Tous les biens dans le contexte du trigger
        for(ListeDeBien__c LB:ListeDeBiens.values()){
            allCBI.add(LB.Biens__c);
        }
        set<Id> existinCBI=new Set<Id>();//Les biens du contexte du trigger qui existent en base
        for(DocumentAssocie__c d:[Select BienCBI__c from DocumentAssocie__c where BienCBI__c in: allCBI]){
            existinCBI.add(d.BienCBI__c);
        }
        
        for (Id theId:ListeDeBiens.keySet()){  // Création Complétude initial des document Associés 
            ListeDeBien__c LaListeBien=ListeDeBiens.get(theId);

            if(!existinCBI.contains(LaListeBien.Biens__c)){//Si la complétude automatique n'a pas encore créé les documents associés au bien
            	for(CategorieDocumentAssocie__c CDA: CDAList){  
                    DocumentAssocie__c DA = new DocumentAssocie__c(); 
                    DA.BienCBI__c = LaListeBien.Biens__c; 
                    DA.DocCharge__c = false;
                    DA.CompletudeDossier__c = true;
                    DA.TypeDuDocument__c = CDA.Label__c;  
                    DA.CategorieDocumentAssocie__c = CDA.ID ;
                    DA.RecordTypeId = RTId ;
                    DA.CompletudeEntete__c = true;
                    DA.Section__c = CDA.Section__c;
                    DA.categorie__c = CDA.Categorie__c; 
                    DA.DemandeChefDeFile__c = CDA.DemandeChefDeFile__c;
                    DA.DemandeClient__c = CDA.DemandeClient__c;
                    DA.DemandeNotaire__c = CDA.DemandeNotaire__c;
                    DA.DemandeDistributeur__c = CDA.DemandeReseau__c;
                    
                    DAs.add(DA);
				}//for
			}//if
		}//for
        insert DAs;
    }//AutoCompletudeDossierFront
}