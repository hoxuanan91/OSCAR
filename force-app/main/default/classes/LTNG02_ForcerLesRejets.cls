public class LTNG02_ForcerLesRejets {
    
    @AuraEnabled public static RecordForm getRejetsEnCours(Id opportunityId) {
        RecordForm result;
        
        List<ControleMetierWrapper> ctrlMetierWrapperList = new List<ControleMetierWrapper>();
        Opportunity opp = [SELECT Id, DateStatut423PVFactRecuesVerif__c, DateEnvoi2Docapost__c, DateRetour2DocapostOK__c, ForcageControlesMetiers__c,
                                   (SELECT Id, toLabel(NatureEnvoi__c), toLabel(TypeControle__c), toLabel(TypeDocument__c), CodeControle__c, IntituleControle__c
                                    FROM CtrlMetierProjetAssVRejet_ProjetAssocie__r
                                   	WHERE ProjetAssocieVisuRejet__c != null)
                           FROM Opportunity
                           WHERE Id =:opportunityId LIMIT 1][0];

        for (ControleMetier__c ctrlMetier : opp.CtrlMetierProjetAssVRejet_ProjetAssocie__r) {
            ctrlMetierWrapperList.add(new ControleMetierWrapper(ctrlMetier));
        }
		result = new RecordForm(ctrlMetierWrapperList, opp);
        
        if (result.opp.DateStatut423PVFactRecuesVerif__c == null &&
            result.opp.DateEnvoi2Docapost__c != null &&
            result.opp.DateRetour2DocapostOK__c == null &&
           	result.natureDeLenvoiForce.size() == 1 &&
            result.natureDeLenvoiForce[0].value == '3') {
                result.errorMessage = 'Impossible de forcer l\'envoi docapost 2 si la décision 423 n\'est pas remontée dans OSCAR.';
                result.ctrlMetierWrapperList.clear();
        }
        
        return result;
    }
    
    @AuraEnabled public static void forcerLesRejets(Id opportunityId, String resultFormJSON) {
        ResultForm resultForm = (ResultForm) JSON.deserialize(resultFormJSON, ResultForm.class);
        Opportunity oppToUpdate = new Opportunity(Id=opportunityId,
                                                  MotifForcageControlesMetiers__c=resultForm.motifForcage,
                                                  NaturesEnvoiAForcer__c=resultForm.natureEnvoiForce,
                                                  ForcageControlesMetiers__c=true);
        update oppToUpdate;
    }
    
    public class ResultForm {
        @AuraEnabled public String motifForcage;
        @AuraEnabled public String natureEnvoiForce;
        
        public ResultForm(String motifForcage, String natureEnvoiForce) {
            this.motifForcage = motifForcage;
            this.natureEnvoiForce = natureEnvoiForce;
        }
    }
    
    public class RecordForm {
        @AuraEnabled public String		errorMessage = 'Pas de rejets en cours.';
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public List<ControleMetierWrapper> ctrlMetierWrapperList;
        @AuraEnabled public List<NatureEnvoiForceWrapper> natureDeLenvoiForce = new List<NatureEnvoiForceWrapper>();
        
        public RecordForm(List<ControleMetierWrapper> ctrlMetierWrapperList, Opportunity opp) {
            this.opp = opp;
            this.ctrlMetierWrapperList = ctrlMetierWrapperList;
            this.preFillNatureEnvoiForce();
        }
        
         /*
          * Pré-remplir dynamiquement le champ "Nature de l'envoi forcé" avec Envoi Docapost 1
          * s'il n'y a que des rejets sur l'envoi 1 et Envoi Docapost 2 s'il n'y en a que sur l'envoi 2.
          */
        private void preFillNatureEnvoiForce() {
            Integer nbEnvoiDocapost1 = 0;
            Integer nbEnvoiDocapost2 = 0;
            
            for (ControleMetierWrapper ctrlMetierWrapper : this.ctrlMetierWrapperList) {
                if (ctrlMetierWrapper.natureDeLenvoi == 'Envoi DocaPost 1 (Transfert Gestion 1)') {
                    nbEnvoiDocapost1++;
                }
                else if (ctrlMetierWrapper.natureDeLenvoi == 'Envoi DocaPost 2 (Transfert Gestion 2)') {
                    nbEnvoiDocapost2++;
                }
            }
            
            if (nbEnvoiDocapost1 > 0 && nbEnvoiDocapost2 > 0) {
                this.natureDeLenvoiForce.add(new NatureEnvoiForceWrapper('Envoi DocaPost 1', '2'));
                this.natureDeLenvoiForce.add(new NatureEnvoiForceWrapper('Envoi DocaPost 2', '3'));
            } else if (nbEnvoiDocapost1 > 0) {
                this.natureDeLenvoiForce.add(new NatureEnvoiForceWrapper('Envoi DocaPost 1', '2'));
            } else if (nbEnvoiDocapost2 > 0) {
                this.natureDeLenvoiForce.add(new NatureEnvoiForceWrapper('Envoi DocaPost 2', '3'));
            }
        }
    }
        
    public class NatureEnvoiForceWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public NatureEnvoiForceWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    public class ControleMetierWrapper {
        @AuraEnabled public String natureDeLenvoi;
        @AuraEnabled public String typeDeControle;
        @AuraEnabled public String typeDeDocument;
        @AuraEnabled public String codeDuControle;
        @AuraEnabled public String intituleDuControle;
        
        public ControleMetierWrapper(ControleMetier__c ctrlMetier) {
            this.natureDeLenvoi = ctrlMetier.NatureEnvoi__c;
            this.typeDeControle = ctrlMetier.TypeControle__c;
            this.typeDeDocument = ctrlMetier.TypeDocument__c;
            this.codeDuControle = ctrlMetier.CodeControle__c;
            this.intituleDuControle = ctrlMetier.IntituleControle__c;
        }
    }
}