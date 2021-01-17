public class AP26_CalculDelai {
    
    /*************************************************************************************************************************
    * @description : appelé dans le process Builder PJA_PR02_CBM_Création/Modification de Projet Associé
    * Permet de calculer le délai de dérogation. Le caclcul se déclenche lorsque la date DateFinDerogationV4__c est rempli
    * @param : List des Ids des opportunités ou la date de fin a changé
    * @return: void
    * @createdBy: RWA
    * @createdDate : 09/01/2020
    *************************************************************************************************************************/
  @invocableMethod(label = 'calculDelaiProjetAssocie' description = 'Calcul de delai')
    public static void calculDelaiProjetAssocie(List<Id> oppties){
        List<Opportunity> opptiesList=[select id, DateDerogationV4__c,DateFinDerogationV4__c 
                                       from Opportunity where id in :oppties ];
        for(Opportunity PAS  :opptiesList){
            PAS.Delai_derogation__c=DateUtils.getHoursBetweenWorkingDays(PAS.DateDerogationV4__c,PAS.DateFinDerogationV4__c);
        }
        update opptiesList;
    }
}