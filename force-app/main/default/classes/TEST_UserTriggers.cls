@isTest
public class TEST_UserTriggers {
    
    @testSetup
    static void init() {
        Map<String,Id> RTs = DAL.getRecordType('Case');
        
        User u;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole r = [SELECT Id FROM UserRole LIMIT 1];
            u = new User(alias = 'tut', email='testUserTrigger@bpce.fr', 
                         emailencodingkey='UTF-8', lastname='testUserTrigger', 
                         languagelocalekey='en_US', 
                         localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                         timezonesidkey='America/Los_Angeles', 
                         username='testUserTrigger@acme.com');
            insert u;
            
            Account acc = TestFactory.createAccount('testAccountName');
            insert acc;
            
            Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
            RecordType rt = [SELECT Id FROM RecordType WHERE developername = 'CBMEnDelegation'];
            opp.RecordTypeId = rt.Id;
            insert opp;
            
            Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
            insert ctr;
            
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'Demande de MEP', (ID)RTs.get('CBM_Mise_en_place'));
            c.UniteSRC__c = '1';
            insert c;
        }
    }
    
    @isTest
    static void whenUpdateUserRoleFromCBMSSRC() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBMSSRC');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        
        System.runAs (usr) {
            List<Case> casesList = [SELECT Id, UniteSRC__c, OwnerId, Owner.email, Owner.lastname FROM Case WHERE IsClosed=false];
            //ACT
            casesList[0].OwnerId = usr.Id;
            update casesList;
            
            usr.UserRoleId = ur1.Id;
            update usr;
        }
    }
    @isTest
    static void whenUpdateUserRoleFromRisques() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='Risques');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    @isTest
    static void whenUpdateUserRoleFromEngagementsInternationalGCProjets() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='EngagementsInternationalGCProjets');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    @isTest
    static void whenUpdateUserRoleFromEngagementsBUs() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='EngagementsBUs');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    @isTest
    static void whenUpdateUserRoleFromCBISRC3GC() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBISRC3GC');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    
    @isTest
    static void whenUpdateUserRoleFromCBISRC24() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBISRC24');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    
    
    @isTest
    static void whenUpdateUserRoleFromCBISRC1() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBISRC1');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    
    
    
    @isTest
    static void whenUpdateUserRoleFromCBMSRCGC() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBMSRCGC');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    
    @isTest
    static void whenUpdateUserRoleFromCBMSRC3() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBMSRC3');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    @isTest
    static void whenUpdateUserRoleFromCBMSRC24() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBMSRC24');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
    @isTest
    static void whenUpdateUserRoleFromCBMSRC1() {
        //ARR        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBMSRC1');
        insert ur1;
        User usr = [SELECT Id, username FROM User WHERE username='testUserTrigger@acme.com'];
        //ACT
        usr.UserRoleId = ur1.Id;
        update usr;
    }
}