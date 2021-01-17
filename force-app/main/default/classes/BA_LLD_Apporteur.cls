/*************************************************************************************
* @date 22/05/2019
* @description Batch pour insérer le champ 'Réseau Apporteur' sur les tiers de type 'LLD_Tiers'. Ceci permet de gérer la visibilité des animateurs sur les tiers.
* Nom de la classe - BA_LLD_Apporteur
*************************************************************************************/
global class BA_LLD_Apporteur implements Database.Batchable<sObject>, Database.Stateful {
    /**
    * @date 22/05/2019
    * @description Début de la fonction batch, query sur les tiers de type 'LLD_Tiers'
    * *****/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Reseau_apporteur__c, Apporteur__r.Reseau__c FROM Account WHERE RecordType.DeveloperName = \'LLD_Tiers\''
        );
    }
    /**
    * @date 22/05/2019
    * @description Modification du champ 'Reseau Apporteur' du tiers 
    * *****/
    global void execute(Database.BatchableContext bc, List<Account> results){
        for(Account a : results){
            a.Reseau_apporteur__c = a.Apporteur__r.Reseau__c;
        }
        update results;
    }
    /**
    * @date 22/05/2019
    * @description Fin de la fonction batch
    * *****/
    global void finish(Database.BatchableContext bc){}
}