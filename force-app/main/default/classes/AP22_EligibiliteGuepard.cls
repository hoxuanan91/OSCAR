public class AP22_EligibiliteGuepard {

    /******************************************************************
     * @description :appelé depuis les PB PJA04/05/06/07
     * au passage de l'opportunity à l'atpe G_422
     * @param : List<Id> id opportunite
     * @return: void
     * @createdBy: RWA
     * @createdDate : 06/12/2019
     ******************************************************************/
    @InvocableMethod(label = 'EligibiliteGuepard' description = 'Appel API Guepard')
    public static void checkEligibility(List < Id > Oppties) {
        List < Opportunity > opptiesList = [select id, NEngagementV4__c from opportunity where id in: Oppties];
        Map < Id, String > mapEngagementV4ById = new Map < Id, String > ();
        for (Opportunity opp: opptiesList) {
            mapEngagementV4ById.put(opp.Id, opp.NEngagementV4__c);
        }
        if(!System.isBatch()){
            checkEligibilityFuture(mapEngagementV4ById);
        }
        else{
            callEligibilityGuepard(mapEngagementV4ById);
        }
        
    }


    /*****************************************************************************************************
     * @description : Methode future pour eviter l'erreur You have uncommitted work pending.
     *  Please commit or rollback before calling out
     * Vu que les triggers se declenchent avant ce traitement, il y'a des DML faits dans ces triggers
     * Et on ne peut pas faire de DML avant un callout a moins de separer les transaction avec @future
     * @param : map Id opportunity et numero EngagementV4
     * @return: void
     * @createdBy: RWA
     * @createdDate : 06/12/2019
     ******************************************************************************************************/

    @future(Callout = true)
    public static void checkEligibilityFuture(Map < Id, String > Oppties) {
        callEligibilityGuepard(Oppties);
    }

    
    
    public static void callEligibilityGuepard(Map < Id, String > Oppties) {
        List < Opportunity > opptiesToUpdate = new List < Opportunity > ();
        String token = AP23_APIUtils.getToken();
        system.debug('@@ token ' + token);

        /* l'API ne supporte pas le bulk. On l'appelle pour chaque opportunite
        Dans le cas nominale ce sera un dossier à la fois*/
        for (Id oppId: Oppties.keyset()) {
            String NEngagementV4 = Oppties.get(oppId);
            
            if (NEngagementV4 != null) {
                HttpResponse response = callEligibity(token, NEngagementV4);
                if (response != null && response.getBody() != null) {
                    Opportunity currentOppty = handleResponse(response, oppId);
                    opptiesToUpdate.add(currentOppty);
                }
            }
        }
        system.debug('@@ opptiesToUpdate ' + opptiesToUpdate);
        if (opptiesToUpdate.size() > 0) {
            try {
                Database.update(opptiesToUpdate, false);
               /// update opptiesToUpdate;
            } catch (Exception e) {
                system.debug('@@ exception ' + e);
            }
        }

    }
    /******************************************************************
     * @description :permet de faire l'appel à l'API
     * @param : token, numero EngagementV4
     * @return: HttpResponse
     * @createdBy: RWA
     * @createdDate : 06/12/2019
     ******************************************************************/
    public static HttpResponse callEligibity(String token, String param) {
        APISettings__mdt requestSetting = [select id, Method__c, 
                                           		Named_Credential__c, Path__c,
                                           		StaticRessourceMock__c
                                                from APISettings__mdt
                                                where masterLabel = 'EligibilityGuepard'
                                                limit 1
                                            ];
        Map < String, String > reqHeader = new Map < String, String > ();
        reqHeader.put('Authorization', 'Bearer ' + token);
        reqHeader.put('Content-Type', 'application/json');
        //Map < String, String > reqBody = new Map < String, String > ();
        HttpResponse response = AP23_APIUtils.makeGenericCallout(requestSetting, reqHeader,'application/json', null, param);
            //AP23_APIUtils.makeGenericCallout(requestSetting, reqHeader, reqBody, param);
        return response;
    }

    /******************************************************************
     * @description :permet de traiter la reponse de l'API
     *  et d'enregister les infos dans l'opportunity
     * @param : token, numero EngagementV4
     * @return: l'Opportunity à mettre à jour
     * @createdBy: RWA
     * @createdDate : 06/12/2019
     ******************************************************************/
    public static Opportunity handleResponse(HttpResponse response, Id oppId) {
        system.debug('@@ response ' + response.getBody());
        Opportunity currentOppty = new Opportunity(Id = oppId);
        Map < String, Object > resultAsMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
        Boolean isEligible = (Boolean) resultAsMap.get('eligibility');
        currentOppty.Eligibilite_Guepard__c = isEligible ? 'Oui' : 'Non';
        system.debug('@@ isEligible ' + isEligible);
        List < Object > eligibilityCriteria = (List < Object > ) resultAsMap.get('eligibilityCriteria');
        String nonEligibilityReasons = '';
        if(!isEligible){          
            for (Object obj: eligibilityCriteria) {
                Map < String, Object > currentCriteria = (Map < String, Object > ) obj;
                Boolean result = (Boolean) currentCriteria.get('result');
                if (!result) {
                    nonEligibilityReasons = nonEligibilityReasons + ';' + (String) currentCriteria.get('criteria');
                }
            }
        }
        currentOppty.Audit_eligibilite__c = nonEligibilityReasons;
        return currentOppty;

    }

}