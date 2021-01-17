/*************************************************************************************
* @date 23/05/2019
* @description Classe de test pour le controller SearchComponentController
* Class Name - SearchComponentController_Test
*************************************************************************************/
@isTest
public class SearchComponentController_Test {
    /**
    * Variables du test
    * *****/
    static List<SearchComponentObject> filtersList = new List<SearchComponentObject> ();
    static List<Account> accounts = new List<Account> ();
    static Map<String, String> accountPickListMap = new  Map<String, String>();
    
    /**
    * @date  23/05/2019
    * @description Création des données utilisées dans la classe de test
    * *****/
    static void initTestData(){
        List<SearchComponentOptionsWrapper> optionsOne = new List<SearchComponentOptionsWrapper> ();
        SearchComponentOptionsWrapper wrapperOne = new SearchComponentOptionsWrapper();
        wrapperOne.label = '93';
        wrapperOne.value = '93';
        optionsOne.add(wrapperOne);
        optionsOne.add(new SearchComponentOptionsWrapper('94', '94'));
        optionsOne.add(new SearchComponentOptionsWrapper('95', '95'));
        
        SearchComponentObject filterOne = new SearchComponentObject();
        filterOne.field = 'Perim_liv_Sans_Frais_Conces__c';
        filterOne.value = '93';
        filterOne.placeholder = 'Département livraison sans frais';
        filterOne.fieldType = 'multipicklist';
        filterOne.options = optionsOne;
        filtersList.add(filterOne);
        
        List<SearchComponentOptionsWrapper> optionsTwo = new List<SearchComponentOptionsWrapper> ();
        optionsOne.add(new SearchComponentOptionsWrapper('Audi', 'Audi'));
        optionsOne.add(new SearchComponentOptionsWrapper('BMW', 'BMW'));
        optionsOne.add(new SearchComponentOptionsWrapper('Peugeot', 'Peugeot'));
        
        SearchComponentObject filterTwo = new SearchComponentObject();
        filterTwo.field = 'Marque_Concess__c';
        filterTwo.value = 'Audi';
        filterTwo.placeholder = 'Marque';
        filterTwo.fieldType = 'picklist';
        filterTwo.options = optionsTwo;
        filtersList.add(filterTwo);
        
        RecordType RecordTypeLLDTiers   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'LLD_Tiers' and SobjectType = 'Account'];
        accounts.add(new Account(Name = 'Name1', RecordTypeId = RecordTypeLLDTiers.Id, Perim_liv_Sans_Frais_Conces__c='93;15', Marque_Concess__c='Audi'));
        accounts.add(new Account(Name = 'Name2', RecordTypeId = RecordTypeLLDTiers.Id, Perim_liv_Sans_Frais_Conces__c='94;17', Marque_Concess__c='BMW'));
        accounts.add(new Account(Name = 'Name3', RecordTypeId = RecordTypeLLDTiers.Id, Perim_liv_Sans_Frais_Conces__c='95;15', Marque_Concess__c='Peugeot'));
        accounts.add(new Account(Name = 'Name4', RecordTypeId = RecordTypeLLDTiers.Id, Perim_liv_Sans_Frais_Conces__c='92;15', Marque_Concess__c='Audi'));
        
        insert accounts;
        
        Schema.DescribeFieldResult fieldResult = Account.Marque_Concess__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            accountPickListMap.put(pickListVal.getLabel(), pickListVal.getLabel());
        }     
    }
    
    /**
    * @date  23/05/2019
    * @description Vérifie l'éxecution de la fonction getObjects
    * *****/
    static testMethod void getObjectsTest(){
        initTestData();
        
        //Recherche le premier tiers
        List<Account> results = SearchComponentController.getObjects('Account', 'Id, Perim_liv_Sans_Frais_Conces__c, Marque_Concess__c', JSON.serialize(filtersList));
        system.assertEquals(1, results.size());
        system.assertEquals(accounts.get(0).Id, results.get(0).Id);
        
        //Recherche le tiers 1 & 4
        filtersList.get(0).value = '15';
        
        results = SearchComponentController.getObjects('Account', 'Id, Perim_liv_Sans_Frais_Conces__c, Marque_Concess__c', JSON.serialize(filtersList));
        system.assertEquals(2, results.size());
        
        for(Account anAccount : results){
            system.assertNotEquals(accounts.get(1).Id, anAccount.Id);
            system.assertNotEquals(accounts.get(2).Id, anAccount.Id);
        }
        
        //Recherche pour aucun résultat
        filtersList.get(0).value = '28';
        
        results = SearchComponentController.getObjects('Account', 'Id, Perim_liv_Sans_Frais_Conces__c, Marque_Concess__c', JSON.serialize(filtersList));
        system.assertEquals(0, results.size());
    }
    
    /**
    * @date  23/05/2019
    * @description Vérifie l'éxecution de la fonction getPickValues
    * *****/
    static testMethod void getPickValuesTest(){
        initTestData();
        
        Map<String, String> searchComponentPickListMap = new  Map<String, String>();
        
        List<SearchComponentOptionsWrapper> options = SearchComponentController.getPickValues('Account', 'Marque_Concess__c', 'firstVal');
        for(SearchComponentOptionsWrapper anOption : options){
            searchComponentPickListMap.put(anOption.label, anOption.label);            
        }

        system.assertEquals(true, searchComponentPickListMap.keySet().containsAll(accountPickListMap.keySet()));
        system.assertEquals(true, searchComponentPickListMap.keySet().contains('firstVal'));
    }
}