/*************************************************************************************
* @date 23/05/2019
* @description Classe de test de la classe BA_LLD_Apporteur
* Nom de la classe - TEST_BA_LLD_Apporteur
*************************************************************************************/
@isTest
public class TEST_BA_LLD_Apporteur {
    /**
    * Variables du test
    * *****/
    static Account accountReseau;
    static Account accountTiers;
    /**
    * @date  23/05/2019
    * @description Création des données utilisées dans la classe de test
    * *****/
    static void setup(){
        
        RecordType RecordTypeLLDTiers   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'LLD_Tiers' and SobjectType = 'Account'];
        RecordType RecordTypeCBIBanque   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIReseauBanqueCaisse' and SobjectType = 'Account'];
        
        accountReseau = new Account(Name = 'TEST CBI-Réseau', RecordTypeId = RecordTypeCBIBanque.Id, Reseau__c = 'Banque Populaire');
        insert accountReseau;
        
        accountTiers = new Account(Name = 'TEST LLD-Tiers', RecordTypeId = RecordTypeLLDTiers.Id, Apporteur__c = accountReseau.Id);
        insert accountTiers;
    }
    /**
    * @date  23/05/2019
    * @description Vérifie l'éxecution du batch BA_LLD_Apporteur.
    * *****/
    static testmethod void batchReseauApporteur(){
        setup();
        List<Account> listOfAccounts = [SELECT Reseau_apporteur__c FROM Account WHERE RecordType.DeveloperName = 'LLD_Tiers'];
        for(Account a : listOfAccounts){
            System.assertEquals(null, a.Reseau_apporteur__c);
        }        
        Test.startTest();
        
        database.executebatch(new BA_LLD_Apporteur());
        Test.stopTest();
        
        listOfAccounts = [SELECT Reseau_apporteur__c FROM Account WHERE RecordType.DeveloperName = 'LLD_Tiers'];
        for(Account a : listOfAccounts){
            System.assertEquals(accountReseau.Reseau__c, a.Reseau_apporteur__c);
        }
    }
    
}