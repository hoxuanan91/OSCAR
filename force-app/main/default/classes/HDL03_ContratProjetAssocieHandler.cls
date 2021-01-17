public with sharing class HDL03_ContratProjetAssocieHandler implements iTrigger {
    Set<Id> oppsId = new Set<Id>();
    Set<Id> contractsId = new Set<Id>();
    Map<Id, Contract> contractByContractId = new Map<Id, Contract>();
    Map<Id, Opportunity> oppByOppId = new Map<Id, Opportunity>();
    List<Contract> contractsToUpdate = new List<Contract>();

    String lldCommandeRecordType = UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'LLD_Commande');
    
    public HDL03_ContratProjetAssocieHandler() {}

    public void bulkBefore() {}

    public void bulkAfter(){
        if(Trigger.isDelete || Trigger.isUpdate){
            for(Contrat_ProjetAssocie__c cPAS : (List<Contrat_ProjetAssocie__c>)Trigger.old){
                oppsId.add(cPAS.ProjetAssocie__c);
                contractsId.add(cPAS.Contrat__c);
            }
        }
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Contrat_ProjetAssocie__c cPAS : (List<Contrat_ProjetAssocie__c>)Trigger.new){
                System.debug(cPAS.Contrat__c);
                oppsId.add(cPAS.ProjetAssocie__c);
                contractsId.add(cPAS.Contrat__c);
            }
        }

        if(!oppsId.isEmpty()){
            for(Opportunity opp : [SELECT Id, RecordTypeId, Typologie_de_commande__c FROM Opportunity WHERE Typologie_de_commande__c = 'Renouvellement' AND RecordTypeId = :lldCommandeRecordType AND Id IN :oppsId]){
                oppByOppId.put(opp.Id, opp);
            }
        }

        if(!contractsId.isEmpty()){
            for(Contract con : [SELECT Id, Statut_renouvellement__c FROM Contract WHERE Id IN :contractsId]){
                contractByContractId.put(con.Id, con);
            }
        }
    }

    public void beforeInsert(SObject so) {}

    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so) {}

    public void afterInsert(SObject so) {
        Contrat_ProjetAssocie__c newCon = (Contrat_ProjetAssocie__c) so;

        System.debug('Contrat <-> PAS : After Insert');

        if(oppByOppId.get(newCon.ProjetAssocie__c) != null && contractByContractId.get(newCon.Contrat__c) != null){
            contractByContractId.get(newCon.Contrat__c).Statut_renouvellement__c = 'En cours de renouvellement';
            contractsToUpdate.add(contractByContractId.get(newCon.Contrat__c));
        }
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        Contrat_ProjetAssocie__c newCon = (Contrat_ProjetAssocie__c) so;
        Contrat_ProjetAssocie__c oldCon = (Contrat_ProjetAssocie__c) oldSo;

        System.debug(contractByContractId);
        System.debug(oldCon.Contrat__c);
        System.debug(newCon.Contrat__c);

        System.debug('Contrat <-> PAS : After Update');

        if(oldCon.Contrat__c != newCon.Contrat__c){
            contractByContractId.get(oldCon.Contrat__c).Statut_renouvellement__c = '';
            contractByContractId.get(newCon.Contrat__c).Statut_renouvellement__c = 'En cours de renouvellement';
            contractsToUpdate.add(contractByContractId.get(oldCon.Contrat__c));
            contractsToUpdate.add(contractByContractId.get(newCon.Contrat__c));
        }
    }

    public void afterDelete(SObject so) {
        Contrat_ProjetAssocie__c delCon = (Contrat_ProjetAssocie__c) so;

        System.debug('Contrat <-> PAS : Before Delete');

        if(contractByContractId.get(delCon.Contrat__c) != null){
            System.debug('Before delete condition');
            contractByContractId.get(delCon.Contrat__c).Statut_renouvellement__c = '';
            contractsToUpdate.add(contractByContractId.get(delCon.Contrat__c));
        }
    }

    public void andFinally() {
        if(!contractsToUpdate.isEmpty()){
            update contractsToUpdate;
        }
    }
}