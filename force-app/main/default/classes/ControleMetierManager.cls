public class ControleMetierManager {
    public static void ControleMetierCreatedOrFindParent(List<ControleMetier__c> ControleMetierList) {
        Map<String, Set<String>> refMetierMap = new Map<String, Set<String>>();
        
        for(ControleMetier__c item : ControleMetierList) {
            
            Set<String> currentSet = refMetierMap.get(item.RefrenceMetier__c);
            if(currentSet == null && item.StatutFlux__c == '1') {
                currentSet = new Set<String>();
                 refMetierMap.put(item.RefrenceMetier__c, currentSet);
            }
            if( item.StatutFlux__c == '1') {
                currentSet.add(item.NatureEnvoi__c);
            }
        }
        List<Opportunity> listOpp = [select Id, NEngagementV4__c, DateRetour1DocapostOK__c, DateRetour2DocapostOK__c from Opportunity where NEngagementV4__c in :refMetierMap.KeySet()];
        
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        for(Opportunity opp : listOpp) {
            Set<String> currentSet = refMetierMap.get(opp.NEngagementV4__c);
            if(currentSet == null) {
                continue;
            }
            boolean isChanged = false;
            for(String item :  currentSet) {
                if(item == '2' && opp.DateRetour1DocapostOK__c == null) {
                    opp.DateRetour1DocapostOK__c = Datetime.now();
                    isChanged = true;
                } else if(item == '3' && opp.DateRetour2DocapostOK__c == null) {
                    opp.DateRetour2DocapostOK__c = Datetime.now();
                    isChanged = true;
                }
            }
            if(isChanged) {
                listOppToUpdate.add(opp);
            }
        }
        update listOppToUpdate;
        Map<String, List<ControleMetier__c>> MapControleM = new Map<String, List<ControleMetier__c>>();
        
        for(ControleMetier__c item : ControleMetierList) {
            System.debug('@@controleMetierInScope(item) ' + controleMetierInScope(item));
            if(controleMetierInScope(item)) {
                if(!MapControleM.containsKey(item.TechReferenceIntercalaire__c)) {
                     MapControleM.put(item.TechReferenceIntercalaire__c, new List<ControleMetier__c>());
                }
                MapControleM.get(item.TechReferenceIntercalaire__c).add(item);
            }
        }
        
        if(MapControleM.size() == 0) {
            return;
        }
        
        List<ControleFluxIntercalaire__c> controlFlux = [select Id, name, ProjetAssocie__c from ControleFluxIntercalaire__c where name in :MapControleM.KeySet()];
        Map<String, ControleFluxIntercalaire__c> mapCF = new Map<String, ControleFluxIntercalaire__c>();
        
        for(ControleFluxIntercalaire__c item : controlFlux) {
            mapCF.put(item.Name, item);
        }
        
        List<ControleFluxIntercalaire__c> controleItoInsered = new List<ControleFluxIntercalaire__c>();
        for(String item : MapControleM.KeySet()) {
            List<ControleMetier__c> currentList = MapControleM.get(item);
            
            if(currentList == null || currentList.size() == 0) {
                continue;
            }
            if(mapCF.containsKey(item)) {
                for(ControleMetier__c cm : currentList) {
                    if(cm.ProjetAssocie__c == null)
                    	cm.ProjetAssocie__c = mapCF.get(item).ProjetAssocie__c;
                    cm.ReferenceIntercalaire__c = mapCF.get(item).Id;
                }
                
            } else {
                ControleFluxIntercalaire__c ci = new ControleFluxIntercalaire__c();
                ci.Name = item;
                ci.RefrenceMetier__c = currentList.get(0).RefrenceMetier__c;
                ci.StatutControlesMetier__c = currentList.get(0).StatutFlux__c;
                ci.NatureEnvoi__c = currentList.get(0).NatureEnvoi__c;
                ci.ProjetAssocie__r = new Opportunity(NEngagementV4__c = currentList.get(0).RefrenceMetier__c);
                controleItoInsered.add(ci);
            }
        }
        if(controleItoInsered.size() == 0) {
            return;
        }
        insert controleItoInsered;

        controleItoInsered = [select Id, ProjetAssocie__c , Name from ControleFluxIntercalaire__c where Id in :controleItoInsered];
        for(ControleFluxIntercalaire__c item : controleItoInsered) {
            List<ControleMetier__c> currentList = MapControleM.get(item.Name);
            
            if(currentList == null || currentList.size() == 0) {
                continue;
            }
            for(ControleMetier__c cm : currentList) {
                if(cm.Bloquant__c == '1' && cm.Statut__c == '3') {
                   cm.ProjetAssocieVisuRejet__c = item.ProjetAssocie__c;
                }
               
                cm.ProjetAssocie__c = item.ProjetAssocie__c;
                cm.ReferenceIntercalaire__c = item.Id;
            }
        }
    }
    
    private static boolean controleMetierInScope(ControleMetier__c cm) {
        if(cm.TechReferenceIntercalaire__c == null || cm.ReferenceIntercalaire__c != null || cm.RefrenceMetier__c == null) {
            return false;
        }
        return true;
    }
}