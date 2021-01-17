public with sharing class QuickCaseController {
    
    @AuraEnabled
    public static Case getCaseCustom(Id caseId){
        return [SELECT Id, URLGED__c, N_du_Dossier__c, NomClient__c, CodeSocieteGestion__c, CaseNumber, CodeTiers__c, NEngagementV4__c, CodeTiersTXT__c, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
    }
    
    @AuraEnabled
    public static Opportunity getOptyCustom(Id opportunityId){
        return [SELECT Id,URLGED__c,NEngagementV4__c,NDuDossierCassiopae__c, RecordType.DeveloperName,NomClient__c,CodeTiers__c FROM Opportunity WHERE Id = :opportunityId];
    }
    
    @AuraEnabled
    public static Projet__c getProjet(Id projetId){
        return [SELECT Id,URLGED__c, NomClient__c, NEnveloppe__c,CodeTiers2__c, RecordType.DeveloperName FROM Projet__c WHERE Id = :projetId];
    }
    
    @AuraEnabled
    public static Contract getContract(Id contractId){
        return [SELECT Id,Name,URLGED__c, NomClient__c, NEngagementV4__c, Account.Code_Tiers__c, RecordType.DeveloperName FROM Contract WHERE Id = :contractId];
    }
    
    @AuraEnabled
    public static Account getAccount(Id accountId){
        return [SELECT Id,Code_Tiers__c, NomClient__c, RecordType.DeveloperName FROM Account WHERE Id = :accountId];
    }
    
    @AuraEnabled
    public static Reference_GED__mdt getCustomRefs(String recordType){
        List<Reference_GED__mdt> logoutUrl = [Select RefMetierPrincipale__c, RefMetierSup__c, RefOscar__c FROM Reference_GED__mdt where MasterLabel =:recordType LIMIT 1]; 
        return logoutUrl[0];
    }
    

}