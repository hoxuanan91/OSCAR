public class AP23_APIUtils {

    /******************************************************************
    * @description : permet de recuperer le token depuis l'API Spider
    * @param : aucun
    * @return: String token
    * @createdBy: RWA
    * @createdDate : 06/12/2019
    ******************************************************************/
    public static String getToken(){
        String token=null;
        
        APISettings__mdt requestSetting=[select id,Method__c,Named_Credential__c,Path__c ,StaticRessourceMock__c
                                         from APISettings__mdt 
                                         where masterLabel='GetToken' 
                                         limit 1];
        
        Map<String,String> reqHeader = new Map<String,String>();
        String typeOfBody='application/x-www-form-urlencoded';
        reqHeader.put('Content-Type', typeOfBody);
        Map<String,String> reqBody=new Map<String,String>();        
        reqBody.put('grant_type', 'client_credentials'); 
        HttpResponse response = makeGenericCallout(requestSetting,reqHeader,typeOfBody, reqBody,null);
        if(response!=null && response.getStatusCode() == 200){
            system.debug('@@ response.getBody() '+response.getBody());
            Map< String, Object > resultAsMap = (Map< String, Object> ) JSON.deserializeUntyped(response.getBody());
            token =(String) resultAsMap.get('access_token');
        }
        else{
            system.debug('@@ unable to get token');
        }
        return token;
    }
    
    
     /********************************************************************************
    * @description : methode generique pour appeler une API REST
    * @param : custom metadata type, request header, request body and URL parameters
    * @return: HttpResponse
    * @createdBy: RWA
    * @createdDate : 06/12/2019
    ******************************************************************************/
    public static HttpResponse makeGenericCallout(APISettings__mdt requestSetting,
                                                  Map<String,String> reqHeader,
                                                  String contentType,
                                                  Object reqBody,
                                                  String requestParams){
        
        /*Generate request*/
		HttpRequest request = new HttpRequest();
        request.setMethod(requestSetting.Method__c);    
        String endpointURL = 'callout:'+requestSetting.Named_Credential__c +requestSetting.Path__c;		
        if(!String.isBlank(requestParams)){
            endpointURL=endpointURL+requestParams;
        }
        request.setEndpoint(endpointURL);
        System.debug('@@ request URL is ' + request.getEndpoint());
        for(String param :reqHeader.keySet()){
            request.setHeader(param, reqHeader.get(param));
        }
        if(reqBody!=null){
            if('application/json'.equalsIgnoreCase(contentType)){
                String jsonString=(String) reqBody;
                request.setBody(jsonString);
            }   
            else{
                Map<String,String>  reqBodyEncoded=  (Map<String,String>)  reqBody; 
                request.setBody(encodeFormData(reqBodyEncoded));                                             
             }                                                 
        }

       request.setTimeout(100000); 
       System.debug('@@ request SE getBody==> '+request.getBody());
     /*  System.debug('@@ request SE getHeader==> '+request.getHeader('Authorization'));
       System.debug('@@ request SE getHeader==> '+request.getHeader('Content-Type'));
       System.debug('@@ request SE endpoint==> '+request.getEndpoint());
       System.debug('@@ request SE method==> '+request.getMethod());*/
        /*Send Request*/        
        Http http = new Http();
		HttpResponse response = new HttpResponse();
		try{
            if(Test.isRunningTest()){               
            	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
                mock.setStaticResource(requestSetting.StaticRessourceMock__c);
                mock.setStatusCode(200);
                mock.setHeader('Content-Type', 'application/json');
                Test.setMock(HttpCalloutMock.class, mock);    
            }	
		     response = http.send(request);
             System.debug('@@ response '  +response);
		}catch (Exception e) {
 			system.debug('@@ Failed to get response' + e.getMessage());
             return null;
		}
        If(response == null || (response.getStatusCode() != 201 && response.getStatusCode() != 200 && response.getStatusCode() != 206)){
           system.debug('@@ Failed : response.getStatusCode is ' +response==null?null:response.getStatusCode());
           system.debug('@@ Failed : response.getBody is ' +response==null?null:response.getBody());
           return null; 
        }
		return response;
	}
    
    /******************************************************************
    * @description : permet de concaterner les parametres du body
    * @param : Map <String, String >map attribut et valeur
    * @return: String 
    * @createdBy: RWA
    * @createdDate : 06/12/2019
    * @example :grant_type=client_credentials&param2=value2
    ******************************************************************/
      private static String encodeFormData(Map <String, String > bodyParams) {
        String result = '';
            for (String thisKey : bodyParams.keySet()) {
                result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(bodyParams.get(thisKey), 'UTF-8') + '&';
            }
            return result.removeEnd('&');
        }
       
    
    public static String generateSEBody(String idDOSExt, String numbEngagementV4){        
     JSONGenerator gen = JSON.createGenerator(true);
        
        // Create a list of integers to write to the JSON string.
        List<String> codes = new List<String>();
        codes.add('tkcd4pve');
        
        // Create an object to write to the JSON string.
        Signers contact = new Signers('ramata.Wath-ext@natixis.com','User','OScar','0604234561');
        List<Signers> signersList=new List<Signers>();
        signersList.add(contact);
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeStringField('callerId', 'DHM');
        gen.writeObjectField('documentsCodes', codes);
		gen.writeStringField('leaseDealId', idDOSExt);
		gen.writeStringField('leaseDealNumber', numbEngagementV4);
        gen.writeObjectField('signers', signersList);
        gen.writeEndObject();        
        // Get the JSON string.
        String jsonS = gen.getAsString();
        //system.debug('@@ pretty jsonS '+jsonS);
        return jsonS;
    }   
    public class Signers{
        String email;
        String firstName;
        String lastName;
        String phoneNumber;
        public Signers(String email,String firstName,String lastName,String phoneNumber){
            this.email=email;
            this.firstName=firstName;
            this.lastName=lastName;
            this.phoneNumber=phoneNumber;
        }
    }  
    public  static void postSignatureElectronique(String idDOSExt, String numbEngagementV4 ){
        HttpRequest request = new HttpRequest();
        APISettings__mdt requestSetting=[select id,Method__c,Named_Credential__c,Path__c ,StaticRessourceMock__c
                                         from APISettings__mdt 
                                         where masterLabel='SignatureElectronique' 
                                         limit 1];
        /*Constituer Headers*/
        Map<String,String> reqHeader = new Map<String,String>();
        String token = AP23_APIUtils.getToken();
        reqHeader.put('Authorization', 'Bearer ' + token);
        String contentype = 'application/json';
        reqHeader.put('Content-Type', contentype);
     
        /*constituer Body*/  
       String reqBody=generateSEBody(idDOSExt,numbEngagementV4 );
        HttpResponse response = AP23_APIUtils.makeGenericCallout(requestSetting, reqHeader,contentype, reqBody, null);
        if(response!=null){
            System.debug('@@ response SE '+response.getBody());
            System.debug('@@ response SE '+response.getBody()); 
        }
        /* request.setbody(generateSEBody(idDOSExt,numbEngagementV4 ));            	
        request.setMethod(requestSetting.Method__c);    
        String endpointURL = 'callout:'+requestSetting.Named_Credential__c +requestSetting.Path__c;		
   
        request.setEndpoint(endpointURL);
        
        for(String param :reqHeader.keySet()){
            request.setHeader(param, reqHeader.get(param));
        }	
       System.debug('@@ request SE getBody==> '+request.getBody());
       System.debug('@@ request SE getHeader==> '+request.getHeader('Authorization'));
       System.debug('@@ request SE getHeader==> '+request.getHeader('Content-Type'));
       System.debug('@@ request SE endpoint==> '+request.getEndpoint());
       System.debug('@@ request SE method==> '+request.getMethod());
       
        Http http = new Http();
		HttpResponse response = new HttpResponse();
        response = http.send(request);
		System.debug('@@ response SE '+response);
        System.debug('@@ response SE '+response.getBody());  */
    }
}