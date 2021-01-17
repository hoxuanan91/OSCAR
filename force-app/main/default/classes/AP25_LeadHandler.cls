public class AP25_LeadHandler {
    public static void transferLLDSimulation(List<Lead> convertedLLDLead){
        system.debug('@@ convertedLLDLead '+convertedLLDLead.size());
        Map<Id, WrapLeadInfos> mapLeadInfos=new Map<Id, WrapLeadInfos>();
        for(Lead cl :convertedLLDLead){
            mapLeadInfos.put(cl.Id, new WrapLeadInfos(cl));
        }
        Map<Id, String> mapURLSimulByOppty=new Map<Id, String>();
        List<Opportunity> opptiesToUpdate=new List<Opportunity>();
        List<simulation__c> simulationToUpdate=new List<simulation__c>();
        for(simulation__c simul : [select id, Lead__c, Tiers__c ,Retenue__c,URL_de_la_simulation__c
                                   from simulation__c
                                   where Lead__c in :mapLeadInfos.keyset()]){
            WrapLeadInfos leadInfos=mapLeadInfos.get(simul.Lead__c);
            simul.Tiers__c=leadInfos.accountId;
            simulationToUpdate.add(simul);
       		if(simul.Retenue__c){
                Opportunity oppty =new Opportunity(id=leadInfos.opptyId,URL_Simulation_Mycarlease__c=simul.URL_de_la_simulation__c); 
                opptiesToUpdate.add(oppty);
             }                                           
                                       
         }
        if(simulationToUpdate.size()>0){
            update simulationToUpdate;
        }
         if(opptiesToUpdate.size()>0){
            update opptiesToUpdate;
        }
    }
    
    private class WrapLeadInfos{
        private Id accountId;
        public Id opptyId;
        private WrapLeadInfos(Lead convertedLead){
            this.accountId=convertedLead.ConvertedAccountId;
            this.opptyId=convertedLead.ConvertedOpportunityId;
        }
    }
   
}