public class MonExpertFeedback {

    public static List<MonExpertDependantValues__c> monExpertDependantValue = [SELECT Id, 
                                                                                    Name, 
                                                                                    OpportunityStage__c, 
                                                                                    OpportunityMotifSansSuite__c, 
                                                                                    OpportunityEnAttente__c 
                                                                                FROM MonExpertDependantValues__c];

    /******************************************************************
    * @description  : Prepare data to send to Spider
    * @param        : List<Id> sObjectIds
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 25/06/2020
    ******************************************************************/
    @future(callout=true)
    public static void prepareFeedback(List<Id> sObjectIds) {

        //Retreive custom metadata for MonExpertFeedback
        APISettings__mdt requestSetting = [SELECT Id, 
                                                Method__c, 
                                                Named_Credential__c, 
                                                Path__c, 
                                                StaticRessourceMock__c
                                        FROM APISettings__mdt 
                                        WHERE MasterLabel = 'MonExpertFeedback' 
                                        LIMIT 1];

        //GET Token from Spider
        String token = getToken();

        System.debug('#### prepareFeedback Method : TOKEN -> ' + token);

        //Ids from Lead -> build JSON and send to Spider
        if(sObjectIds[0].getSobjectType().getDescribe().getName() == 'Lead'){
            for(Lead l : [SELECT Id, Name, Owner.Name, Owner.Email, N_de_lead_MonExpert__c, Status FROM Lead WHERE Id IN :sObjectIds]){
                String body = '';
                body = JSON.serialize(new RequestWrapper(null, l.Owner.Email, l.Owner.Name, null, 'Changement de statut', l.Status, l.Status));
                System.debug('#### prepareFeedback Method : LEADBODY -> ' + body);
                sendFeedback(token, body, String.valueOf(l.N_de_lead_MonExpert__c), requestSetting.Method__c, requestSetting.Named_Credential__c, requestSetting.Path__c, l.Id, 'Lead');
            }
        }
        //Ids from Opportunity -> build JSON and send to Spider
        else if(sObjectIds[0].getSobjectType().getDescribe().getName() == 'Opportunity'){
            for(Opportunity opp : [SELECT Id, Name, Owner.Name, Owner.Email, N_de_lead_MonExpert__c, StageName, Motif__c, En_Attente__c FROM Opportunity WHERE Id IN :sObjectIds]){
                String body = '';
                String code = '';

                for(MonExpertDependantValues__c medv : monExpertDependantValue){
                    if(opp.StageName == medv.OpportunityStage__c && medv.OpportunityMotifSansSuite__c == null && medv.OpportunityEnAttente__c == null){
                        code = opp.StageName;
                        break;
                    }
                    if(opp.Motif__c != null && opp.Motif__c == medv.OpportunityMotifSansSuite__c){
                        code = opp.Motif__c;
                        break;
                    }
                    else if(opp.En_Attente__c != null && opp.Motif__c == medv.OpportunityEnAttente__c){
                        code = opp.En_Attente__c;
                        break;
                    }
                }

                body = JSON.serialize(new RequestWrapper(null, opp.Owner.Email, opp.Owner.Name, null, 'Changement de statut', code, code));
                System.debug('#### prepareFeedback Method : OPPORTUNITYBODY -> ' + body);
                sendFeedback(token, body, String.valueOf(opp.N_de_lead_MonExpert__c), requestSetting.Method__c, requestSetting.Named_Credential__c, requestSetting.Path__c, opp.Id, 'Opportunity');
            }
        }
        //Ids from Contract -> build JSON and send to Spider
        else if(sObjectIds[0].getSobjectType().getDescribe().getName() == 'Contract'){
            for(Contract c : [SELECT Id, Name, Owner.Name, Owner.Email, N_de_lead_MonExpert__c, Status FROM Contract WHERE Id IN :sObjectIds]){
                String body = '';
                body = JSON.serialize(new RequestWrapper(null, c.Owner.Email, c.Owner.Name, null, 'Changement de statut', c.Status, c.Status));
                System.debug('#### prepareFeedback Method : CONTRACTBODY -> ' + body);
                sendFeedback(token, body, String.valueOf(c.N_de_lead_MonExpert__c), requestSetting.Method__c, requestSetting.Named_Credential__c, requestSetting.Path__c, c.Id, 'Contract');
            }
        }

        System.debug('#### prepareFeedback Method : END');
    }

    /******************************************************************
    * @description  : Get token from Spider
    * @param        : List<Id> sObjectIds
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 25/06/2020
    ******************************************************************/
    public static String getToken(){
        String token = '';
        
        APISettings__mdt requestSetting = [SELECT Id,
                                                Method__c,
                                                Named_Credential__c,
                                                Path__c,
                                                StaticRessourceMock__c
                                        FROM APISettings__mdt 
                                        WHERE MasterLabel = 'GetToken' 
                                        LIMIT 1];

        HttpRequest request = new HttpRequest();

        //Set header
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        System.debug('#### getToken Method : ENDPOINT -> ' + 'callout:' + requestSetting.Named_Credential__c + requestSetting.Path__c);
        //Set endPoint
        request.setEndpoint('callout:' + requestSetting.Named_Credential__c + requestSetting.Path__c);

        System.debug('#### getToken Method : METHOD -> ' + requestSetting.Method__c);
        //Set method
        request.setMethod(requestSetting.Method__c);

        String reqBody = '';
        reqBody = EncodingUtil.urlEncode('grant_type', 'UTF-8') + '=' + EncodingUtil.urlEncode('client_credentials', 'UTF-8');

        System.debug('#### getToken Method : BODY -> ' + reqBody);
        //Set body
        request.setBody(reqBody);

        //Response
        Http http = new Http();
        HttpResponse response = new HttpResponse();

        System.debug('#### getToken Method : REQUEST -> ' + request);
        
        response = http.send(request);

        System.debug('#### getToken Method : RESPONSE -> ' + response);

        if(response.getStatusCode() == 200){
            Map< String, Object > resultAsMap = (Map< String, Object> ) JSON.deserializeUntyped(response.getBody());
            token = (String)resultAsMap.get('access_token');
        }
        else{
            UTL_Log.startLog();
            UTL_Log.setContext('MonExpertFeedback.getToken');
            UTL_Log.setEndpoint(request.getEndpoint());
            UTL_Log.setMethod(request.getMethod());
            UTL_Log.setMessage(request.getBody());
            UTL_Log.setRequest(String.valueOf(request));
            UTL_Log.setResponse(String.valueOf(response));
            UTL_Log.setSeverity('ERROR');
            UTL_Log.setType('WebService - Spider Token');
            UTL_Log.setUserId(UserInfo.getUserId());
            UTL_Log.setUserName(UserInfo.getUserName());
            UTL_Log.endLog();
            //UTL_Log.pushLogs();
        }

        return token;
    }
    

    /******************************************************************
    * @description  : Send data to Spider
    * @param        : String token, String requestBody, String nbMonExpert, String method, String namedCredential, String path
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 25/06/2020
    ******************************************************************/
    public static void sendFeedback(String token, String requestBody, String nbMonExpert, String method, String namedCredential, String path, String recordId, String sObjectType){
        System.debug('#### sendFeedback Method : START');
        System.debug('#### sendFeedback Method : TOKEN -> ' + token);
        System.debug('#### sendFeedback Method : BODY -> ' + requestBody);
        System.debug('#### sendFeedback Method : NBMONEXPERT -> ' + nbMonExpert);
        System.debug('#### sendFeedback Method : METHOD -> ' + method);
        System.debug('#### sendFeedback Method : NAMEDCREDENTIAL -> ' + namedCredential);
        System.debug('#### sendFeedback Method : PATH -> ' + path);

        HttpRequest request = new HttpRequest();

        requestBody = requestBody;

        String endPointParams = '/leadFeedback/v1/lead/distributor/' + nbMonExpert + '/feedback';

        System.debug('#### sendFeedback Method : ENDPOINT PARAMS -> ' + endPointParams);

        //Set header
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');

        //Set method
        request.setMethod(method);

        //Set endPoint
        request.setEndpoint('callout:' + namedCredential + path + endPointParams);

        //Set body
        request.setBody(requestBody);

        //Response
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        
        response = http.send(request);

        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        
        if(response.getStatusCode() != 200){
            UTL_Log.startLog();
            UTL_Log.setContext('MonExpertFeedback.sendFeedback');
            UTL_Log.setEndpoint(request.getEndpoint());
            UTL_Log.setMethod(request.getMethod());
            UTL_Log.setMessage(request.getBody());
            UTL_Log.setRecordId(recordId);
            UTL_Log.setRecordSObjectType(sObjectType);
            UTL_Log.setRequest(String.valueOf(request));
            UTL_Log.setResponse(String.valueOf(response));
            UTL_Log.setSeverity('ERROR');
            UTL_Log.setType('WebService - Spider');
            UTL_Log.setUserId(UserInfo.getUserId());
            UTL_Log.setUserName(UserInfo.getUserName());
            UTL_Log.endLog();
            //UTL_Log.pushLogs();
        }

        System.debug('#### sendFeedback Method : END');
    }

    /******************************************************************/
    /******************************************************************/
    /************************** WRAPPER CLASS *************************/
    /******************************************************************/
    /******************************************************************/


    /******************************************************************
    * @description  : Wrapper Class - Allows to form the JSON
    * @param        : String comment, String crmBusinessExpertEmail, String crmBusinessExpertName, String internalComment, String motive, String status
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 25/06/2020
    ******************************************************************/
    public class RequestWrapper{

        public String comment;
        public String crmBusinessExpertEmail;
        public String crmBusinessExpertName;
        public String internalComment;
        public String motive;
        public StatusWrapper status;

        public RequestWrapper(String comment, String crmBusinessExpertEmail, String crmBusinessExpertName, String internalComment, String motive, String status, String enAttente){
            this.comment                = comment;
            this.crmBusinessExpertEmail = crmBusinessExpertEmail;
            this.crmBusinessExpertName  = crmBusinessExpertName;
            this.internalComment        = internalComment;
            this.motive                 = motive;
            this.status                 = new StatusWrapper(status, enAttente);

        }
    }

    /******************************************************************
    * @description  : Wrapper Class - Allows to form the JSON
    * @param        : String status
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 25/06/2020
    ******************************************************************/
    public class StatusWrapper{

        public String code;
        public String label;

        public StatusWrapper(String code, String label){
            this.code   = code;
            this.label  = label;
        }
    }
}