public with sharing class HDL02_OpportunityHandler implements ITrigger {

    private Map<Id, List<Case>> casesOctroiDENByOppIds = new Map<Id, List<Case>>();
    private Set<Case> casesOctroiDENToUpdate = new Set<Case>();

    public HDL02_OpportunityHandler() {}

    public void bulkBefore() {}

    public void bulkAfter() {

        /**
         *  FO - DEN
         *  Passage des demandes(=CBMOctroiCreditDEN) au status=Refusée
         *  Rapatrier MotifdecisionDEN__c
         *  Annuler les demandes d'octroi DEN si PAS 'sans-suite"
        */
        for (Opportunity opp : [
                SELECT Id, MotifdecisionDEN__c, (SELECT Id, Status FROM Demandes_ProjetAssocie__r WHERE RecordType.DeveloperName = 'CBMOctroiCreditDEN')
                    FROM Opportunity
                    WHERE Id IN:Trigger.newMap.keySet()
        ]) {
            this.casesOctroiDENByOppIds.put(opp.Id, opp.Demandes_ProjetAssocie__r);
        }
    }

    public void beforeInsert(SObject so) {}

    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so) {}

    public void afterInsert(SObject so) {
        Opportunity newOpp = (Opportunity)so;
        
        /**
         *  Annuler les demandes d'octroi DEN si PAS 'sans-suite'
        */
        //this.casesOctroiDENToUpdate.addAll(AP03Opportunity.cancelCasesIfPASEqualSansSuite(newOpp, this.casesOctroiDENByOppIds.get(newOpp.Id)));
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        Opportunity oldOpp = (Opportunity)oldSo;
        Opportunity newOpp = (Opportunity)so;
        /**
         *  FO - DEN
         *  Passage des demandes(=CBMOctroiCreditDEN) au status=Refusée
         *  Rapatrier MotifdecisionDEN__c
        */
        //this.casesOctroiDENToUpdate.addAll(AP03Opportunity.handleCaseCBMOctroiCreditDEN(oldOpp, newOpp, this.casesOctroiDENByOppIds.get(newOpp.Id)));

        /**
         *  Annuler les demandes d'octroi DEN si PAS 'sans-suite'
        */
        //this.casesOctroiDENToUpdate.addAll(AP03Opportunity.cancelCasesIfPASEqualSansSuite(oldOpp, newOpp, this.casesOctroiDENByOppIds.get(newOpp.Id)));

    }

    public void afterDelete(SObject so) {}

    public void andFinally() {
        List<Case> casesOctroiDENToUpdate = new List<Case>();

        if (this.casesOctroiDENToUpdate.size() > 0) {
            casesOctroiDENToUpdate.addAll(this.casesOctroiDENToUpdate);

            update casesOctroiDENToUpdate;
        }
    }
}