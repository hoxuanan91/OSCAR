public with sharing class UTL_Log {
    
    public static List<Log__c> logsToInsert = new List<Log__c>();
    public static Log__c log;
    
    /******************************************************************
    * @description  : Instanciated log
    * @param        : 
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void startLog() {
        log = new Log__c();
    }

    /******************************************************************
    * @description  : Set context of log
    * @param        : String context
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setContext(String context){
        log.Context__c = context;
    }

    /******************************************************************
    * @description  : Set endpoint of log
    * @param        : String endpoint
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setEndpoint(String endpoint){
        log.Endpoint__c = endpoint;
    }

    /******************************************************************
    * @description  : Set line of log -> e.getLineNumber()
    * @param        : Integer line
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setLine(Integer line){
        log.Line__c = line;
    }

    /******************************************************************
    * @description  : Set message of log -> e.getMessage()
    * @param        : String message
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setMessage(String message){
        log.Message__c = message;
    }

    /******************************************************************
    * @description  : Set method of log
    * @param        : String method
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setMethod(String method){
        log.Method__c = method;
    }

    /******************************************************************
    * @description  : Set recordId of log
    * @param        : String recordId
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setRecordId(String recordId){
        log.RecordId__c = recordId;
    }

    /******************************************************************
    * @description  : Set recordSObjectType of log
    * @param        : String recordSObjectType
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setRecordSObjectType(String recordSObjectType){
        log.RecordSObjectType__c = recordSObjectType;
    }

    /******************************************************************
    * @description  : Set request of log
    * @param        : String request
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setRequest(String request){
        log.Request__c = request;
    }

    /******************************************************************
    * @description  : Set response of log
    * @param        : String response
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setResponse(String response){
        log.Response__c = response;
    }

    /******************************************************************
    * @description  : set severity of log
    * @param        : String severity
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setSeverity(String severity){
        log.Severity__c = severity;
    }

    /******************************************************************
    * @description  : Set stacktrace of log -> e.getStackTraceString()
    * @param        : String stacktrace
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setStacktrace(String stacktrace){
        log.Stacktrace__c = stacktrace;
    }

    /******************************************************************
    * @description  : Set type of log -> e.getTypeName()
    * @param        : String type
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setType(String type){
        log.Type__c = type;
    }

    /******************************************************************
    * @description  : Set userId of log
    * @param        : String userId
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setUserId(String userId){
        log.UserId__c = userId;
    }

    /******************************************************************
    * @description  : Set userName of log
    * @param        : String userName
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void setUserName(String userName){
        log.UserName__c = userName;
    }

    /******************************************************************
    * @description  : Add log to list
    * @param        : 
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void endLog(){
        logsToInsert.add(log);
    }

    /******************************************************************
    * @description  : Insert logs
    * @param        : 
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 07/07/2020
    ******************************************************************/
    public static void pushLogs(){
        if(!logsToInsert.isEmpty()){
            insert logsToInsert;
        }
    }
}