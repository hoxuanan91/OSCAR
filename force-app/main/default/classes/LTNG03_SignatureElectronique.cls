public class LTNG03_SignatureElectronique {
    
    /******************************************************************************************
    * @description : Permet de récupérer les informations nécessaires pour le composant
    * @param : String oppId
    * @return: OpportunityWrapper 
    * @createdBy: ACL
    * @createdDate : 29/09/2020
    * @example :
    ******************************************************************************************/
    
    @AuraEnabled
    public static OpportunityWrapper doInit_APEX(String oppId){
        System.debug('coucou');
        return new OpportunityWrapper([SELECT Id,
                                      		StageName,
                                      		Amount,
                                       		Dossier__r.ID_Ext_Dossier__c,
                                       		NEngagementV4__c,
                                       		EtatDocumentSE__c,
                                       		DateDeSignature__c,
                                       		CodeDocument_SE__c,
                                       		NbFournisseurs__c,
                                       		(SELECT Id,
                                             		Email__c,
                                            		Nom__c,
                                             		Prenom__c,
                                                    Telephone__c,
                                                    Type_de_document__c 
                                            FROM InformationsSignataire__r)
                                      FROM Opportunity
                                      WHERE Id =: oppId]);
    }
    
    /******************************************************************************************
    * @description : Permet de lancer le process de signature electronique depuis le bouton
    * @param : String dosIdExt=contract.ID_Ext_Dossier__c, 
               String numEngagementV4=Opportunity.NEngagementV4__c
    * @return: Void 
    * @createdBy: RWA
    * @createdDate : 24/02/2020
    * @example :
    ******************************************************************************************/
    @AuraEnabled 
    public static ResponseWrapper requestESignature(String dosIdExt, String numEngagementV4,String recordId,String oppWrapperJSON, Boolean hasToBeCreated){
        System.debug('coucou 2');
        if(String.isNotBlank(numEngagementV4)){
            if(dosIdExt==null){
                dosIdExt='';
            }          
          	System.debug('request');
            
            ResponseWrapper response = postSignatureElectronique(dosIdExt,numEngagementV4,recordId,oppWrapperJSON,hasToBeCreated);    
            
         	return response;
        }
        return new ResponseWrapper(500, 'Vérifier le numéro d\'engagement V4, puis réessayez. Si le problème persiste veuillez contacter votre administrateur');
        
    }
    
    /******************************************************************
    * @description : permet de generer le body sous format json
    * @param : String dosIdExt=contract.ID_Ext_Dossier__c, 
               String numEngagementV4=Opportunity.NEngagementV4__c
    * @return: String 
    * @createdBy: RWA
    * @createdDate :24/02/2020
    * @example :
    ******************************************************************/
    public static String generateSEBody(String idDOSExt, String numbEngagementV4,List<SignerWrapper> signataireList){        
     	JSONGenerator gen = JSON.createGenerator(true);
        
        //code PV=tkcd4pve
        List<String> codes = new List<String>();
        codes.add('tkcd4pve');
                 
        // init Json
        gen.writeStartObject();
        gen.writeStringField('callerId', 'DHM');
        gen.writeObjectField('documentsCodes', codes);
		gen.writeStringField('leaseDealId', idDOSExt);
		gen.writeStringField('leaseDealNumber', numbEngagementV4);
        gen.writeObjectField('signers', signataireList);
        gen.writeEndObject();
         
        // Get the JSON string.
        String jsonS = gen.getAsString();
        return jsonS;
    }  
      
  	/*****************************************************************************
    * @description : permet de faire le callout à Spider
    * @param : String dosIdExt=contract.ID_Ext_Dossier__c, 
               String numEngagementV4=Opportunity.NEngagementV4__c         
    * @return: void
    * @createdBy: RWA
    * @createdDate :24/02/2020
    * @example :
    *****************************************************************************/
    public static ResponseWrapper postSignatureElectronique(String idDOSExt, String numbEngagementV4,String recordId, String oppWrapperJSON, Boolean hasToBeCreated){
        OpportunityWrapper oW = (OpportunityWrapper)JSON.deserialize(oppWrapperJSON, OpportunityWrapper.class);
        Set<Integer> successStatusCode = new Set<Integer>{200, 201, 206, 409};
        Id infoSignataireSE = UTL_Utils.getRecordTypeID(String.valueOf(InformationsSignataire__c.getSObjectType()), 'SignatureElectronique');
        
        List<SignerWrapper> signataireList = new List<SignerWrapper>();
        signataireList.add(oW.signataire);

        System.debug(oW.signataire);

        HttpRequest request = new HttpRequest();
        APISettings__mdt requestSetting=[SELECT id,Method__c,Named_Credential__c,Path__c ,StaticRessourceMock__c
                                        FROM APISettings__mdt 
                                        WHERE masterLabel='SignatureElectronique' 
                                        LIMIT 1];

        /*Constituer Headers*/
        Map<String,String> reqHeader = new Map<String,String>();
        String token = AP23_APIUtils.getToken();
        reqHeader.put('Authorization', 'Bearer ' + token);
        String contentype = 'application/json';
        reqHeader.put('Content-Type', contentype);
        System.debug('postSignature');
     
        /*constituer Body*/  
        String reqBody=generateSEBody(idDOSExt,numbEngagementV4, signataireList);
        HttpResponse response = AP23_APIUtils.makeGenericCallout(requestSetting, reqHeader,contentype, reqBody, null);

        if(response != null){
            System.debug('@@ response SE getStatusCode '+response.getStatusCode());
            System.debug('@@ response SE getBody '+response.getBody()); 
            Map < String, Object > resultAsMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
            String transactionCode = '';
            if(successStatusCode.contains(response.getStatusCode())) {
                if(response.getStatusCode() == 409){
                    transactionCode = response.getBody().substringAfter('[');
                    transactionCode = transactionCode.substringBefore(']');
                    transactionCode = transactionCode.substringAfter('=');
                }
                else{
					transactionCode = (String) resultAsMap.get('transactionCode');
                }
                if(String.isNotBlank(transactionCode)){
                    try{

                        InformationsSignataire__c newInfoSignataire = new InformationsSignataire__c();
                        Opportunity opptyToUpdate=new Opportunity(Id 										= recordId,
                                                                  EtatDocumentSE__c 						= '4902 - SE - PV Liv. à e-Signer',
                                                                  Date_demande_signature_electronique__c 	= System.today(),
                                                                  Code_transaction_SE__c 					= transactionCode,
                                                                  CodeDocument_SE__c 						= 'PV');
                        update opptyToUpdate;

                        if(hasToBeCreated){
                            newInfoSignataire.Email__c 		        = oW.signataire.email;
                            newInfoSignataire.Nom__c 			    = oW.signataire.lastName;
                            newInfoSignataire.Prenom__c 		    = oW.signataire.firstName;
                            newInfoSignataire.Opportunity__c 	    = recordId;
                            newInfoSignataire.Telephone__c 	        = oW.signataire.phoneNumber;
                            newInfoSignataire.RecordTypeId 	        = infoSignataireSE;
                            newInfoSignataire.type_de_document__c   = oW.signataire.typeDocument;
                        }
                        else{
                            for(InformationsSignataire__c iS : oW.infosSignataires){
                                if(iS.Email__c == oW.signataire.email){
                                    newInfoSignataire.Id                    = iS.Id;
                                    newInfoSignataire.Email__c 		        = oW.signataire.email;
                                    newInfoSignataire.Nom__c 			    = oW.signataire.lastName;
                                    newInfoSignataire.Prenom__c 		    = oW.signataire.firstName;
                                    newInfoSignataire.Telephone__c 	        = oW.signataire.phoneNumber;
                                    newInfoSignataire.type_de_document__c 	= oW.signataire.typeDocument;
                                }
                            }
                        }
                        
                        
                        
                        System.debug(newInfoSignataire);
                        
                        upsert newInfoSignataire;
                    }
                    catch(Exception e){
                        return new ResponseWrapper(500, e.getMessage());
                    }
                    
                }
            }
        }
        return new ResponseWrapper(response.getStatusCode(), response.getBody());
    }
    
    /*****************************************************************************
    * @description : wrapper signataire
    * @param : String email,String firstName,String lastName,String phoneNumber         
    * @return: Object SignerWrapper 
    * @createdBy: RWA
    * @createdDate :24/02/2020
    * @example :
    *****************************************************************************/
    public class SignerWrapper{
        @AuraEnabled public String email;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String typeDocument;

        public SignerWrapper(String email, String firstName, String lastName, String phoneNumber, String typeDocument){
            this.email = email;
            this.firstName = firstName;
            this.lastName = lastName;
            this.phoneNumber = phoneNumber;
            this.typeDocument = typeDocument;
        }
    }
    
    /*****************************************************************************
    * @description : Wrapper réponse
    * @param : Integer statusCode, String responseBody         
    * @return : Object ResponseWrapper 
    * @createdBy : ACL
    * @createdDate : 19/05/2020
    * @example :
    *****************************************************************************/
    
    public class ResponseWrapper{
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String responseBody;
        
        public ResponseWrapper(Integer statusCode, String responseBody){
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
    }
    
    /*****************************************************************************
    * @description : Wrapper opportunity
    * @param : Opportunity opp     
    * @return : Object OpportunityWrapper 
    * @createdBy : ACL
    * @createdDate : 29/09/2020
    * @example :
    *****************************************************************************/
    
    public class OpportunityWrapper{
        //@AuraEnabled public Opportunity opp;
        @AuraEnabled public String dosIdExt;
        @AuraEnabled public String numEngagementV4;
        @AuraEnabled public List<PicklistWrapper> picklistSignataires;
        @AuraEnabled public List<PicklistWrapper> picklistTypesDoc;
        @AuraEnabled public List<InformationsSignataire__c> infosSignataires;
        @AuraEnabled public SignerWrapper signataire;
        @AuraEnabled public Boolean buttonDisabled;
        
        public OpportunityWrapper(Opportunity opp){
            this.dosIdExt = opp.Dossier__r.ID_Ext_Dossier__c;
            this.numEngagementV4 = opp.NEngagementV4__c;
            System.debug((opp.NbFournisseurs__c == 1 && opp.Amount < 150000 && (opp.StageName == 'G_422' || opp.StageName == 'AT_LIV' || opp.StageName == 'G_423') && (opp.EtatDocumentSE__c == null || opp.EtatDocumentSE__c == '4900 - SE - Contrat à e-Signer' || opp.EtatDocumentSE__c == 'SE - PV Liv. expiré' || opp.EtatDocumentSE__c == '4910 - SE - Contrat e-Signé' || opp.EtatDocumentSE__c == '4920 - SE - Contrat à Signer Man')));
            this.buttonDisabled = (opp.NbFournisseurs__c == 1 && opp.Amount < 150000 && (opp.StageName == 'G_422' || opp.StageName == 'AT_LIV' || opp.StageName == 'G_423') && (opp.EtatDocumentSE__c == null || opp.EtatDocumentSE__c == '4900 - SE - Contrat à e-Signer' || opp.EtatDocumentSE__c == 'SE - PV Liv. expiré' || opp.EtatDocumentSE__c == '4910 - SE - Contrat e-Signé' || opp.EtatDocumentSE__c == '4920 - SE - Contrat à Signer Man') ? false : true);
            this.picklistSignataires = new List<PicklistWrapper>();
            this.picklistSignataires.add(new PicklistWrapper('aucun', '-- Aucun --'));
            this.picklistTypesDoc = new List<PicklistWrapper>();
            this.picklistTypesDoc.add(new PicklistWrapper('aucun', '-- Aucun --'));
            this.infosSignataires = opp.InformationsSignataire__r;
            this.signataire = new SignerWrapper('', '', '', '', 'aucun');

            for(InformationsSignataire__c iS : opp.InformationsSignataire__r){
                this.picklistSignataires.add(new PicklistWrapper(iS.Id, iS.prenom__c + ' ' + iS.Nom__c));
            }

            Schema.DescribeFieldResult fieldResult = InformationsSignataire__c.Type_de_document__c.getDescribe();
            for(Schema.PicklistEntry sP : fieldResult.getPicklistValues()){
                this.picklistTypesDoc.add(new PicklistWrapper(sP.getValue(), sP.getLabel()));
            }
        }
    }
    
    public class PicklistWrapper{
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public PicklistWrapper(String value, String label){
            this.value = value;
            this.label = label;
        }
    }
    
    @InvocableMethod(label='PostFeedOnOwnerChatterGroup' description='Post a chatter feed on owner user group')
    public static void postChatterSE(List<ID> ids) {
   		List<Opportunity> oppties = [SELECT Name,EtatDocumentSE__c,NEngagementV4__c FROM Opportunity WHERE Id in :ids]; 
        Opportunity oppty= oppties[0];
        List<CollaborationGroupMember> groupsOWnersBelongs=[SELECT CollaborationGroup.groupEmail, 
                                                            CollaborationGroupId, 
                                                            Id FROM CollaborationGroupMember 
                                                            where memberId=:UserInfo.getUserId()];
        
        String postBody = '';
       
        if('4912 - SE - PV Liv. e-Signé'.equalsIgnoreCase(oppty.EtatDocumentSE__c)) {
             postBody = 'PV e-signé pour le projet associé ' + oppty.name + '/' + oppty.NEngagementV4__c;
        }
        else if('SE - PV Liv. expiré'.equalsIgnoreCase(oppty.EtatDocumentSE__c)){
             postBody = 'Attention la signature du PV est expirée pour le projet associé ' + oppty.name + '/' + oppty.NEngagementV4__c;
        }
        else if('4922 - SE - PV Liv. à Signer Man'.equalsIgnoreCase(oppty.EtatDocumentSE__c)){
            postBody = 'PV de livraison du dossier ' + oppty.Name + '/' + oppty.NEngagementV4__c + ' à faire signer manuellement par le client. Transfert Gestion 2 à envoyer à Docapost pour numérisation des documents papiers.';
        }
        else{
             postBody='La signature électronique du PV du projet associé ' + oppty.name + '/' + oppty.NEngagementV4__c + 'n\'a pas pu aboutir : Échec technique';
        }
        
        if(groupsOWnersBelongs != null && groupsOWnersBelongs.size() > 0){
            for(CollaborationGroupMember cGm : groupsOWnersBelongs){
                createPostChatter(cGm.CollaborationGroupId, postBody, oppty.Id);
            }
        }
        else{
             createPostChatter(UserInfo.getUserId(), postBody, oppty.Id);
        }
   		
  	}
    
    public static void createPostChatter(Id chatterParentId, String postBody, Id oppId){
        /*creation du post chatter avec le mention au groupe */
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
          
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
        mentionSegmentInput.id = chatterParentId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput.text = postBody;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    
        feedItemInput.subjectId = oppId;
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null,feedItemInput );
    }
}