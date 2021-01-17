@isTest
public class BatchCalculeObjectifTest {
    @isTest
    public static void testBatch() {
         Account acc = new Account(Name = 'test');
        insert acc;
        Contract ct = new Contract(Name = 'test', accountId = acc.id);
        insert ct;
        Opportunity opp = new Opportunity(dossier__c = ct.Id, accountId = acc.id, Name='test', StageName = 'Validé',
                                          CloseDate = System.today(),NEngagementV4__c = '01010', ownerId = UserInfo.getUserId());
        Objectif__c obj = new Objectif__c(Utilisateur__c = UserInfo.getUserId(),
                                         AnneeFiscale__c = (System.today().Month() <=3 ? (System.today().year() - 1) : System.today().year()),
                                         ObjectifRenouvellements__c = 10);
        
        
        insert opp;
        insert obj;
        Database.executeBatch(new BatchCalculeObjectif());
        
        String sch = '0 30  * 1/1 * ? *';

system.schedule('testObjectf', sch, new ScheduleCalculeObjectif());

    }
}