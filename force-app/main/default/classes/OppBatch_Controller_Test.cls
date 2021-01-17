@isTest
public class OppBatch_Controller_Test {

    @testSetup
    static void setup() {
        Account parentAccount = new Account(Name = 'TestAccountParent');
        insert parentAccount;

        Account parentAccountEmpty = new Account(Name = 'TestAccountParentEmpty');
        insert parentAccountEmpty;

        List<Account> childrenAccounts = new List<Account>();
        childrenAccounts.add(new Account(Name = 'Children1',ParentId = parentAccount.id));
        childrenAccounts.add(new Account(Name = 'Children2',ParentId = parentAccount.id));
        insert childrenAccounts;
    }
    
    @isTest
    static void testGetAccounts() {
        String accParent = [SELECT Id FROM Account WHERE Name = 'TestAccountParent'].id;
    	List<Account> childrenAccounts = new List<Account>();
  
        Test.startTest();
		childrenAccounts = OppBatch_Controller.getAccounts(accParent);
        Test.stopTest();
        
        System.assertEquals(2,childrenAccounts.size() , 'Was expecting 2 acc');
    }
    
    @isTest
    static void testGetAccountsEmpty() {
        String accParentEmpty = [SELECT Id FROM Account WHERE Name = 'TestAccountParentEmpty'].id;
        List<Account> childrenAccountsEmpty = new List<Account>();
        
        Test.startTest();
        childrenAccountsEmpty = OppBatch_Controller.getAccounts(accParentEmpty);
        Test.stopTest();
        
        System.assertEquals(null,childrenAccountsEmpty, 'Wasn t expecting any children account');
    }
    
    @isTest
    static void testCreateOpportunitiesAvenant() {
        String accParent = [SELECT Id FROM Account WHERE Name = 'TestAccountParent'].id;
        List<OppBatch_Controller.jsonOpp> listOpp = new List<OppBatch_Controller.jsonOpp>();
        OppBatch_Controller.jsonOpp jsonOpp = new OppBatch_Controller.jsonOpp();

        jsonOpp.accountName = 'TestAccountParent';
        jsonOpp.accountId = accParent;
        jsonOpp.name = 'Test';
        jsonOpp.comNumber = '12';
        jsonOpp.aveNumber = '3';
        jsonOpp.vehNumber = '1';
        jsonOpp.numCommandes = '';
        jsonOpp.numAve = '2';
        jsonOpp.comType = '';
        jsonOpp.aveType = 'Prestation';
        jsonOpp.recType = 'avenant';
        jsonOpp.recordId = '';
        jsonOpp.conPCD = '';
        jsonOpp.conPCR = '';
        jsonOpp.conPP = '';
        jsonOpp.conPC = '';
        jsonOpp.conPFC = '';
        jsonOpp.statMarge = '[{"Id": 1,"Name": "Avenant prestation"}]';
        jsonOpp.nombreFleet = '';
        jsonOpp.typologieFleet = '';

        listOpp.add(jsonOpp);
        String serializedOpp = JSON.serializePretty(listOpp);
 
        Test.startTest();
        OppBatch_Controller.createOpportunities(serializedOpp,'avenant');
        Test.stopTest();
    }

    @isTest
    static void testCreateOpportunitiesCommande() {
        String accParent = [SELECT Id FROM Account WHERE Name = 'TestAccountParent'].id;
        List<OppBatch_Controller.jsonOpp> listOpp = new List<OppBatch_Controller.jsonOpp>();
        OppBatch_Controller.jsonOpp jsonOpp = new OppBatch_Controller.jsonOpp();

        jsonOpp.accountName = 'TestAccountParent';
        jsonOpp.accountId = accParent;
        jsonOpp.name = 'Test';
        jsonOpp.comNumber = '12';
        jsonOpp.aveNumber = '3';
        jsonOpp.vehNumber = '1';
        jsonOpp.numCommandes = '';
        jsonOpp.numAve = '2';
        jsonOpp.comType = 'Renouvellement';
        jsonOpp.aveType = 'Prestation';
        jsonOpp.recType = 'commande';
        jsonOpp.recordId = '';
        jsonOpp.conPCD = '[{"Id": 1,"Name": "Avenant RGPD"}]';
        jsonOpp.conPCR = '[{"Id": 1,"Name": "Avenant RGPD"}]';
        jsonOpp.conPP = '[{"Id": 1,"Name": "Carburant - Commande de carte Shell"}]';
        jsonOpp.conPC = '[{"Id": 1,"Name": "Dérogation Direction Générale"}]';
        jsonOpp.conPFC = '';
        jsonOpp.statMarge = '';
        jsonOpp.nombreFleet = '';
        jsonOpp.typologieFleet = '';

        listOpp.add(jsonOpp);
        String serializedOpp = JSON.serializePretty(listOpp);
 
        Test.startTest();
        OppBatch_Controller.createOpportunities(serializedOpp,'commande');
        Test.stopTest();
    }

    @isTest
    static void testCreateOpportunitiesFleet() {
        String accParent = [SELECT Id FROM Account WHERE Name = 'TestAccountParent'].id;
        List<OppBatch_Controller.jsonOpp> listOpp = new List<OppBatch_Controller.jsonOpp>();
        OppBatch_Controller.jsonOpp jsonOpp = new OppBatch_Controller.jsonOpp();

        jsonOpp.accountName = 'TestAccountParent';
        jsonOpp.accountId = accParent;
        jsonOpp.name = 'Test';
        jsonOpp.comNumber = '12';
        jsonOpp.aveNumber = '3';
        jsonOpp.vehNumber = '1';
        jsonOpp.numCommandes = '';
        jsonOpp.numAve = '2';
        jsonOpp.comType = '';
        jsonOpp.aveType = '';
        jsonOpp.recType = 'fleet';
        jsonOpp.recordId = '';
        jsonOpp.conPCD = '';
        jsonOpp.conPCR = '';
        jsonOpp.conPP = '[{"Id": 1,"Name": "Carburant - Commande de carte Shell"}]';
        jsonOpp.conPC = '';
        jsonOpp.conPFC = '[{"Id": 1,"Name": "Copie Carte Grise"}]';
        jsonOpp.statMarge = '';
        jsonOpp.nombreFleet = '1';
        jsonOpp.typologieFleet = 'Assurance';

        listOpp.add(jsonOpp);
        String serializedOpp = JSON.serializePretty(listOpp);
 
        Test.startTest();
        OppBatch_Controller.createOpportunities(serializedOpp,'fleet');
        Test.stopTest();
    }

    @isTest
    static void testgetMultiPicklistValues() {       
        String jsonField;
        
        Test.startTest();
        jsonField = OppBatch_Controller.getMultiPicklistValues('Controle_pieces_client_COM__c');
        Test.stopTest();
        
        System.assertNotEquals(null,jsonField, 'Field should not be null');
    }

    @isTest
    static void testgetInsertableValues() {       
        String jsonField = '[{"Id": "1","Name": "value"},{"Id": "2","Name": "value2"}]';
        String values;
        
        Test.startTest();
        values = OppBatch_Controller.getInsertableValues(jsonField);
        Test.stopTest();
        
        System.assertNotEquals(null,values, 'Values should not be null');
    }
}