public class EncoursAON {
	
    /******************************************************************
    * @description  : Prepare data to send to Spider
    * @param        : List<Id> sObjectIds
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 12/12/2020
    ******************************************************************/
    @future(callout=true)
    public static void prepareEncoursAON(String oppId) {

        //Retreive custom metadata for MonExpertFeedback
        APISettings__mdt requestSetting = [SELECT Id, 
                                                Method__c, 
                                                Named_Credential__c, 
                                                Path__c, 
                                                StaticRessourceMock__c
                                        FROM APISettings__mdt 
                                        WHERE MasterLabel = 'EncoursAON' 
                                        LIMIT 1];
        
        Opportunity opp = [SELECT Id,
                           		Name,
                           		Account.Unite_de_gestion__c,
                          		(SELECT Id,
                                		Name,
                                 		RecordType.DeveloperName,
                                 		Date_de_naissance__c,
                                 		Email__c,
                                 		IDAssure__c,
                                 		Montant_de_la_prime__c,
                                 		Montant_des_encours__c,
                                 		Nom__c,
                                 		Prenom__c,
                                 		Opportunity__c,
                                 		Statut_parcours__c,
                                 		Statut_parcours_TXT__c,
                                 		Type_de_document__c,
                                 		Telephone__c,
                                 		valid__c
                                FROM InformationsSignataire__r
                                WHERE Type_de_document__c = 'Assurance'
                                AND IDAssure__c != null)
                          FROM Opportunity
                          WHERE Id =: oppId];

        if(!opp.InformationsSignataire__r.isEmpty()){
            //GET Token from Spider
            String token = getToken();
            
            String body = JSON.serialize(new EncoursRequest(opp));
            
            HttpResponse response = sendEncoursAON(token, body, requestSetting.Method__c, requestSetting.Named_Credential__c, requestSetting.Path__c);
            
            GlobalResponse gResp = (GlobalResponse) JSON.deserialize(response.getBody(), GlobalResponse.class);
            
            for(TiersResponse tR : gResp.tiersInsuranceOutstandingAggregateList){
                for(InformationsSignataire__c iS : opp.InformationsSignataire__r){
                    if(tR.tiersId == iS.IDAssure__c){
                        for(EncoursResponse eR : tR.tiersInsuranceOutstandingList){
                            if((eR.insuranceNumber == '1508' || eR.insuranceNumber == '1501') && eR.outstandingCustomerAmount != null){
                                iS.Montant_des_encours__c += eR.outstandingCustomerAmount;
                            }
                        }
                    }
                }
            }
            
            update opp.InformationsSignataire__r;
        }
    }

    /******************************************************************
    * @description  : Get token from Spider
    * @param        : List<Id> sObjectIds
    * @return       : void
    * @createdBy    : ACL
    * @createdDate  : 12/12/2020
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
    * @createdDate  : 12/12/2020
    ******************************************************************/
    public static HttpResponse sendEncoursAON(String token, String requestBody, String method, String namedCredential, String path){
        System.debug('#### sendFeedback Method : START');
        System.debug('#### sendFeedback Method : TOKEN -> ' + token);
        System.debug('#### sendFeedback Method : BODY -> ' + requestBody);
        System.debug('#### sendFeedback Method : METHOD -> ' + method);
        System.debug('#### sendFeedback Method : NAMEDCREDENTIAL -> ' + namedCredential);
        System.debug('#### sendFeedback Method : PATH -> ' + path);

        HttpRequest request = new HttpRequest();

        requestBody = requestBody;

        String endPointParams = '/api/v1/tiers/insuranceOutstanding';

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
        System.debug('#### sendFeedback Method : END');
        
        return response;
       
    }
    
    public class EncoursRequest{
      	
        public String excludeLeaseDealId;
        public List<TiersRequest> tiersIdList;
        
        public EncoursRequest(Opportunity opp){
            this.excludeLeaseDealId = 'NUMERO';
            this.tiersIdList = new List<TiersRequest>();
            
            for(InformationsSignataire__c iS : opp.InformationsSignataire__r){
                this.tiersIdList.add(new TiersRequest(iS, opp.Account.Unite_de_gestion__c));
            }            
        }
    }
    
    public class TiersRequest{
        
        public String tiersId;
        public String uniteGestionCode;
        
        public TiersRequest(InformationsSignataire__c iS, String uniteGC){
            this.tiersId = iS.IDAssure__c;
            this.uniteGestionCode = uniteGC;
        }
    }
    
    public class GlobalResponse{
        public List<TiersResponse> tiersInsuranceOutstandingAggregateList;
    }
    
    public class TiersResponse{
        public String tiersId;
        public String uniteGestionCode;
        public List<EncoursResponse> tiersInsuranceOutstandingList;
    }
    
    public class EncoursResponse{
        public String insuranceNumber;
        public String insuranceCode;
        public String insuranceLabel;
        public Decimal outstandingCustomerAmount;        
    }
}