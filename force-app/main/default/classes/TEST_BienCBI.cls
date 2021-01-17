@isTest
public class TEST_BienCBI{

    @testSetup 
    static void MethodPrepare() {
    
        Test.startTest();
        
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;

        Account lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;      
        
        Projet__c lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
        Test.stopTest();
        
    }
    
    static testmethod void creerBienCBI(){
        
        // On récupère le Projet
        Projet__c lProjet = [SELECT Id, Name FROM Projet__c WHERE Name = 'Test'];    
                
        Bien_CBI__c lBienCBI = new Bien_CBI__c(Name = 'Test Bien', UsageROE__c = 'Entrepôts', IDProjet__c = lProjet.Id);
        insert lBienCBI;
        
        // On récupère le lien Liste-Bien 
        ListeDeBien__c lb = [SELECT Id FROM ListeDeBien__c WHERE Projet__c = :lProjet.Id AND Biens__c = :lBienCBI.Id LIMIT 1];
        system.assertNotEquals(null, lb);
        
    }
    
}