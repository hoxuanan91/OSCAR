@isTest
public  class BatchCalculDelaiCreaMEL_Test {
    
    @testSetup static void setup(){
        
        Date maDate = Date.newInstance(2020, 2, 26);
        Id idRecordTypeCaseMEP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CBM_Mise_en_place').getRecordTypeId();
        Id idRecordTypeContractCBM=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('CBMDossier').getRecordTypeId();
        Id idRecordTypeTiers= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tiers').getRecordTypeId();
        
        
        Account tAccount= new Account(Name='BPCE_LEASE_TEST', RecordTypeId=idRecordTypeTiers);
        insert tAccount;
        
         Contract tContract= new Contract(Name='Contract_Test' ,RecordTypeId=idRecordTypeContractCBM, AccountId=tAccount.Id, DateDe1ereMEL__c=maDate);
        insert tContract;
        Case tCase = new Case(Status='A prendre en charge',RecordTypeId=idRecordTypeCaseMEP, Rattrapage_CreaMEL_OK__c =false, Dossier1__c=tContract.Id);
        insert tCase;
       
    }
        
        public static testMethod void testBatchCalculDelaiCreaMEL(){
            Test.startTest();
            Database.executeBatch(new BatchCalculDelaiCreaMEL(),10); 
            Test.stopTest();
            List<Case> updatedDelaiMEL=[SELECT id , 
                                        DelaiMiseLoyer__c, 
                                        CreatedDate,
                                        Date_de_traitement_de_la_MEL__c,Dossier1__r.DateDe1ereMEL__c
                                        
                                        FROM case 
                                        WHERE Dossier1__r.DateDe1ereMEL__c  >=2020-01-01 
                                        and (DelaiMiseLoyer__c=0 OR DelaiMiseLoyer__c=null) 
                                        and status !='Annulée'
                                        and recordType.developerName='CBM_Mise_en_place'
                                        and Rattrapage_CreaMEL_OK__c =true ];
            system.assert(updatedDelaiMEL.size()>0);     
        }
        
        
        
        public static testMethod void testScheduleBatchCalculDelaiCreaMEL(){
            Test.startTest();
            String sch = '0 30  * 1/1 * ? *';
            system.schedule('BatchCalculDelaiCreaMEL', sch, new ScheduleBatchCalculDelaiCreaMEL());
  
            Test.stopTest();
        }
        
        
    }