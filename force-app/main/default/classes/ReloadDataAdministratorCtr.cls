public class ReloadDataAdministratorCtr {
    
    @AuraEnabled 
    public static List<JobProcessedHistory__c> getAllBulkJob() {
        return [select Id, Name, CreatedDate__c, ExternalId__c, IsExecuted__c, ObjectName__c, Operation__c, RelaodedDate__c, JobBulkId__c, ScheduledNextLoad__c
                from JobProcessedHistory__c order by CreatedDate__c desc limit 500];
    }
    
     @AuraEnabled 
    public static List<JobProcessedHistory__c> searchAllBulkJob(String objectName, String operation, Date currentDate) {
        System.debug('@@ ' + objectName + ' ' + operation + ' ' + currentDate);
        String query = 'select Id, Name, CreatedDate__c, ExternalId__c, IsExecuted__c, ObjectName__c, Operation__c, RelaodedDate__c, JobBulkId__c, ScheduledNextLoad__c from JobProcessedHistory__c ';
        
        boolean firstCondition = true;
        if(objectName != null) {
            query += ' where ObjectName__c like \'%'+objectName+'%\'';
            firstCondition = false;
        }
        if(operation != null) {
            if(firstCondition) {
                 query += ' where Operation__c like \'%'+operation+'%\'';
                 firstCondition = false;
            } else {
                 query += ' and Operation__c like \'%'+operation+'%\'';
            }
        }
        if(currentDate != null) {
            if(firstCondition) {
                 query += ' where DAY_ONLY(CreatedDate__c) = :currentDate';
                 firstCondition = false;
            } else {
                 query += ' and DAY_ONLY(CreatedDate__c) = :currentDate';
            }
        }
        query += ' order by CreatedDate__c desc limit 500';
        System.debug('@@ ' + query);
        return database.query(query);
    }
    
    @AuraEnabled
    public static void setReexecuteJob(List<JobProcessedHistory__c> jobList) {
        upsert jobList JobBulkId__c;
    }
}