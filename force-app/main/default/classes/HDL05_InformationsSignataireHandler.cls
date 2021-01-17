public with sharing class HDL05_InformationsSignataireHandler implements iTrigger {
    Map<Id, List<DocumentSE__c>> documentsSEbyOppId = new Map<Id, List<DocumentSE__c>>();
    List<DocumentSE__c> documentsSEtoUpdate = new List<DocumentSE__c>(); 
    
    public HDL05_InformationsSignataireHandler() {}

    public void bulkBefore() {}

    public void bulkAfter(){
        for(InformationsSignataire__c iS : (List<InformationsSignataire__c>)Trigger.new){
            documentsSEbyOppId.put(iS.Opportunity__c, new List<DocumentSE__c>());
        }

        if(!documentsSEbyOppId.isEmpty()){
            for(DocumentSE__c dSE : [SELECT Id, 
                                            Opportunity__c, 
                                            Signataire__c, 
                                            RecordType.DeveloperName 
                                    FROM DocumentSE__c
                                    WHERE Opportunity__c IN :documentsSEbyOppId.keySet()]){
                documentsSEbyOppId.get(dSE.Opportunity__c).add(dSE);
            }
        }
    }

    public void beforeInsert(SObject so) {}

    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so) {}

    public void afterInsert(SObject so) {
        InformationsSignataire__c newIS = (InformationsSignataire__c) so;

        if(!documentsSEbyOppId.get(newIs.Opportunity__c).isEmpty()){
            for(DocumentSE__c dSE : documentsSEbyOppId.get(newIs.Opportunity__c)){
                if(newIS.Type_de_document__c != null && newIS.Type_de_document__c == dSE.RecordType.DeveloperName){
                    dSE.Signataire__c = newIS.Id;
                    documentsSEtoUpdate.add(dSE);
                }
            }
        }       
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        if(!documentsSEtoUpdate.isEmpty()){
            update documentsSEtoUpdate;
        }
    }
}