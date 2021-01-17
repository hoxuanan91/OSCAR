@IsTest
public class PAD_TEST {
    
    @testSetup
    static void initData() {
        User u = TestFactory.createUser();

        
        System.runAs(u){
            Map<String,Id> RTs = DAL.getRecordType('Case');
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id, 'Non', 'CBMDossier');
            insert ctr;
            
            Test.startTest();
            
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Reamenagement'));
            insert c;
        }
    }

    static List<Case> getCases() {
        return [SELECT Id, RecordTypeId FROM CASE];    
    }
    
    @IsTest
    static void quickPADTestMethod(){
        PAD.log('','');PAD.log('',1);PAD.log(1,'');PAD.log(1,1);PAD.log(1);PAD.log('');PAD.startTimer();PAD.stopTimer();
        PAD.limits();
        PAD.canTrigger('AP123');
    }
}