public class DAL{
    
    public static Map<String,Id> RTs = new Map<String,Id>();
    public static Map<Id,String> RTsOrderByIds = new Map<Id,String>();
    public static list<Holiday> Holidays= new list<Holiday>();

    public static Map<String,Id> getRecordType(String objectName) {
        System.debug('##### : getRecordType');
            
        if(RTs == null || RTs.size() == 0){
            List<RecordType> malist = [Select Id, DeveloperName from RecordType Where SobjectType=:objectName];
            Map<String,Id> mamap = new Map<String,Id>();
            
            for(RecordType rt : malist)
                mamap.put(rt.DeveloperName, rt.Id);
            
            RTs = mamap;
        }
        
        return RTs;
    }
    
    /**
     * Retourne la Map inversée de 'getRecordType'
     */
    public static Map<Id,String> getRecordTypeOrderById(String objectName) {
        System.debug('##### : getRecordType');
            
        if(RTsOrderByIds == null || RTsOrderByIds.size() == 0){
            List<RecordType> malist = [Select Id, DeveloperName from RecordType Where SobjectType=:objectName];
            Map<Id,String> mamap = new Map<Id,String>();
              
            for(RecordType rt : malist)
                mamap.put(rt.Id,rt.DeveloperName);
            
            RTsOrderByIds = mamap;
        }
        
        return RTsOrderByIds;
    }
    
    public static list<Holiday> getHolidaysExceptWeekend(){
        
        if(Holidays == null || Holidays.size() == 0){
            return [select ActivityDate , Name , IsAllDay, RecurrenceStartDate from Holiday where Name != 'Weekend'];
        }
        
        return Holidays;
    }
   
    public static Map<String,Id> getQueue() {
        System.debug('##### : getQueue');
            
        List<Group> malist = [SELECT DeveloperName,Id FROM Group where Type = 'Queue'];
        Map<String,Id> mamap = new Map<String,Id>();
        
        for(Group g : malist)
            mamap.put(g.DeveloperName, g.Id);

    return mamap;
    }
    
    public static List<Case> getCaseByIDs(Set<ID> ids){
        
        RTs = DAL.getRecordType('Case');
        ID rtAR = (ID)RTs.get('CBM_Actions_de_Recouvrement');
        ID rtAFR = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
        ID rtIAPR = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
        
        List<ID> RTsList = new List<ID>();
        RTsList.add(rtAR);
        RTsList.add(rtAFR);
        RTsList.add(rtIAPR);
    
        return [Select ID 
                from Case 
                where ID IN :ids 
                AND status not in ('Terminée','Terminée Transférée juridique','Terminée Transférée contentieux','Annulée')
                AND recordTypeId not IN :RTsList];
    }
    
    public static Map<ID,Case> getCaseByIDs_ForPhase(Set<ID> ids){
        
        RTs = DAL.getRecordType('Case');
        ID rtAR = (ID)RTs.get('CBM_Actions_de_Recouvrement');
        ID rtAFR = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
        ID rtIAPR = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
        
        List<ID> RTsList = new List<ID>();
        RTsList.add(rtAR);
        RTsList.add(rtAFR);
        RTsList.add(rtIAPR);
    
        return new Map<ID,Case>([Select ID, Phase__c
                from Case 
                where ID IN :ids 
                AND status not in ('Terminée','Terminée Transférée juridique','Terminée Transférée contentieux','Annulée')
                AND recordTypeId IN :RTsList]);
    }
    
    public static Map<ID,List<Facture_non_lettree__c>> getFacturesByDemandeIDs(Set<ID> ids){
        
        Map<ID,List<Facture_non_lettree__c>> mamap = new Map<ID,List<Facture_non_lettree__c>>();
        List<Facture_non_lettree__c > maList = [Select Secteur_de_gestion__c, Id, Demande_rattachee__c, Date_de_reglement__c, 
                                                        Date_de_rattachement_demande__c, Code_Fonction_SG__c 
                                                        From Facture_non_lettree__c
                                                        Where Demande_rattachee__c IN :ids];
                                        
        for(Facture_non_lettree__c f : maList){
            List<Facture_non_lettree__c> temp = (List<Facture_non_lettree__c>)mamap.get(f.Demande_rattachee__c);
            if(temp == null) temp = new List<Facture_non_lettree__c>();
            
            temp.add(f);
            
            mamap.put(f.Demande_rattachee__c,temp);
        }
        
        return mamap;
    }
    
    public static List<Case> getCaseByIDs(List<ID> ids){
    
        return [Select ID, Nombre_de_factures_non_lettrees__c  from Case where ID IN :ids];
    }
    
    //Add By Mourad SAIR 02/04/2015 
    
    public static List<Case> getCaseByIDsForComment(set<Id> CasesComment){
    
        return [Select Id,CommentaireC__c  from Case where ID IN :CasesComment];
    }
    //End Mourad 
    
    //Add By Mourad SAIR 24/04/2015 
    
    public static List<Case> getCaseByIDsForMotif(list<Id> DemandesIDs){
        
          RTs = DAL.getRecordType('Case');
        ID rtAR = (ID)RTs.get('CBM_Actions_de_Recouvrement');
        ID rtAFR = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
        ID rtIAPR = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
        
        List<ID> RTsList = new List<ID>();
        RTsList.add(rtAR);
        RTsList.add(rtAFR);
        RTsList.add(rtIAPR);
    
        return [Select Id,Motif_a_revoir__c,Date_revoir__c  from Case where ID IN :DemandesIDs and recordtypeId IN:  RTsList];
    }
    //End Mourad 
    
    public static List<Case> getCaseByIDs_ForOwner(List<ID> ids){
    
        return [Select ID, Nombre_de_factures_non_lettrees__c, owner.type, ownerid  from Case where ID IN :ids];
    }
    
    public static Map<Id,Contract> getContractAccountByIDs(Set<Id> ids){
    
        return new Map<Id,Contract>([SELECT Id, AccountId FROM Contract WHERE Id IN: ids]);
    
    }
    
    public static Map<Id,Integer> getDossierCount(List<ID> ids){
        Map<Id, Integer> mamap = new Map<Id, Integer>();
        
        AggregateResult[] groupedResults = [SELECT Dossier1__c , 
                                                    Count(Id)
                                            FROM Case
                                            WHERE Dossier1__c IN: ids
                                            AND Status IN ('Terminée','Terminée Transférée juridique','Terminée Transférée contentieux')
                                            AND RecordType.DeveloperName = 'CBM_Reamenagement'
                                            GROUP BY Dossier1__c];
        
        for (AggregateResult ar : groupedResults){
            System.debug('$$$$ aggregation : ' + ar.get('Dossier1__c') + ' / ' + ar.get('expr0'));
            mamap.put((Id)ar.get('Dossier1__c'), (Integer)ar.get('expr0') != null ? (Integer)ar.get('expr0') : 0);
        }
        
        return mamap;
    }

    public static Map<Id,String> getNotairesByCaseIDs(Set<ID> ids){
        
        
        Map<Id,String> mamap = new Map<Id,String>();
        
        List<Autre_Tiers__c> groupedResults = [SELECT Nom_du_Tiers__r.Name , Numero_du_dossier__c
                                     From Autre_Tiers__c
                                     Where Numero_du_dossier__c In :ids
                                     and Role__c = 'Notaire'];
        
        for (Autre_Tiers__c ar : groupedResults)  {
            mamap.put((ID)ar.Numero_du_dossier__c, ar.Nom_du_Tiers__r.Name != null ? ar.Nom_du_Tiers__r.Name : '');
        }
        System.debug('Notaires > '+ mamap);

        return mamap;
    }
    
    public static Map<Id,Integer> getFactureCount(List<ID> ids){
        
        Map<Id,Integer> mamap = new Map<Id,Integer>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c, Count(Id)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and Date_de_reglement__c = null
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            mamap.put((ID)ar.get('Demande_rattachee__c'), (Integer)ar.get('expr0') != null ? (Integer)ar.get('expr0') : 0);
        }
        
        return mamap;
    }
     ////Begin : Mourad 14/04/2015: 
    // Methode qui calcule le nombre des nouvelles factures dans une demande
    
     public static Map<Id,Integer> getNewFactureCount(List<ID> ids){
        
        Map<Id,Integer> mamap = new Map<Id,Integer>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c,Count(Id)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and Nouvel_fact__c =: true
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            mamap.put((ID)ar.get('Demande_rattachee__c'), (Integer)ar.get('expr0') != null ? (Integer)ar.get('expr0') : 0);
        }
        
        return mamap;
    }
    
    // Methode qui calcule le nombre des anciennes factures dans une demande
    
     public static Map<Id,Integer> getOldFactureCount(List<ID> ids){
        
        Map<Id,Integer> mamap = new Map<Id,Integer>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c,Count(Id)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and Nouvel_fact__c =: false
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            mamap.put((ID)ar.get('Demande_rattachee__c'), (Integer)ar.get('expr0') != null ? (Integer)ar.get('expr0') : 0);
        }
        
        return mamap;
    }
    
     // Methode qui récupére la date Kasiop la plus récente des factures d'une demande
    
     public static Map<Id,Date> getNewDateKasiopFacture(List<ID> ids){
        
        Map<Id,Date> mamap = new Map<Id,Date>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c,MAX(Date_MAJ_ksiop__c)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            mamap.put((ID)ar.get('Demande_rattachee__c'), (Date)ar.get('expr0') != null ? (Date)ar.get('expr0') : null);
        }
        
        return mamap;
    }
    
    ////Begin : Mourad 17/04/2015: 
    // Methode qui get les MAX date KSIOP des factures réglées qui deviennent non réglées sur une demande
      public static Map<Id,Date> getFactureChangeRegCount(List<ID> ids){
        
        Map<Id,Date> mamap = new Map<Id,Date>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c,MAX(Date_MAJ_ksiop__c)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and DateDernRglt__c != null and Date_de_reglement__c = null and Rejet_today__c = true
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            mamap.put((ID)ar.get('Demande_rattachee__c'), (Date)ar.get('expr0') != null ? (Date)ar.get('expr0') : null);
        }
        
        return mamap;
    }
    
    ////Begin : Mourad 31/03/2015: 
    // Methode qui calcule le nombre des factures impayees pour une demande
     public static Map<Id,Integer> getFactureCountImpaye(List<ID> ids){
        
        Map<Id,Integer> FactImp = new Map<Id,Integer>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c, Count(Id)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and Date_de_reglement__c = null and Solde_TTC__c>0
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            FactImp.put((ID)ar.get('Demande_rattachee__c'), (Integer)ar.get('expr0') != null ? (Integer)ar.get('expr0') : 0);
        }
        
        return FactImp;
    }
    //
    
     //Methode qui calcule le nombre des factures Avoir pour une demande
     public static Map<Id,Integer> getFactureCountAvoir(List<ID> ids){
        
        Map<Id,Integer> FactAv = new Map<Id,Integer>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c, Count(Id)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and Date_de_reglement__c = null and Solde_TTC__c<0
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            FactAv.put((ID)ar.get('Demande_rattachee__c'), (Integer)ar.get('expr0') != null ? (Integer)ar.get('expr0') : 0);
        }
        
        return FactAv;
    }
    //
    
    
    //Methode qui calcule la somme des montants TTC des factures sur une demande
     public static Map<Id,Double> getFactureCountsommeMontant(List<ID> ids){
        
        Map<Id,Double> FactMantant = new Map<Id,Double>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c, SUM(Montant_TTC__c)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            FactMantant.put((ID)ar.get('Demande_rattachee__c'), (Double)ar.get('expr0') != null ? (Double)ar.get('expr0') : 0);
        }
        
        return FactMantant;
    }
    //
    
    //Methode qui calcule la somme des solde  TTC des factures sur une demande
     public static Map<Id,Double> getFactureCountsommeSolde(List<ID> ids){
        
        Map<Id,Double> FactSolde = new Map<Id,Double>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c, SUM(Solde_TTC__c)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            FactSolde.put((ID)ar.get('Demande_rattachee__c'), (Double)ar.get('expr0') != null ? (Double)ar.get('expr0') : 0);
        }
        
        return FactSolde;
    }
    ///End Mourad 31/03/2015
    
    public static Map<Id,Date> getFactureRecentAttachement(List<ID> ids){
        
        Map<Id,Date> mamap = new Map<Id,Date>();
        
        AggregateResult[] groupedResults = [SELECT Demande_rattachee__c, Max(Date_de_rattachement_demande__c)
                                     From Facture_non_lettree__c
                                     Where Demande_rattachee__c In :ids
                                     and Date_de_reglement__c = null
                                     Group By Demande_rattachee__c];
        
        for (AggregateResult ar : groupedResults)  {
            System.debug('$$$$ aggregation : ' + ar.get('Demande_rattachee__c') + ' / ' + ar.get('expr0'));
            mamap.put((ID)ar.get('Demande_rattachee__c'), (Date)ar.get('expr0') != null ? (Date)ar.get('expr0') : null);
        }
        
        return mamap;
    }

    public static Map<ID,List<Case>> getCasesByDossiersIDs(Set<ID> ids){
        
        //Déclaration des ID des recordType
        RTs = DAL.getRecordType('Case');
        ID rtMiseEnPlace = (ID)RTs.get('CBM_Mise_en_place');
    
        System.debug('#### : rtMiseEnPlace :' + rtMiseEnPlace );
        
        Map<ID,List<Case>> mamap = new Map<ID,List<Case>>();
        List<Case> maList = [Select Id, Dossier1__c,Date_de_traitement_de_la_MEL__c 
                                From Case
                                Where 
                                recordTypeId = :rtMiseEnPlace
                                AND Dossier1__c IN :ids];
                                        
        for(Case c : maList){
            List<Case> temp = (List<Case>)mamap.get(c.Dossier1__c);
            if(temp == null) temp = new List<Case>();
            
            temp.add(c);
            
            mamap.put(c.Dossier1__c,temp);
        }
        
        return mamap;
    }
    
    public static Map<ID,Date> getDateMiseEnLoyerByDossiersIDs(Set<ID> ids){
        
        Map<ID,Date> mamap = new Map<ID,Date>();
        List<Contract> maList = [Select Id,Date_de_traitement_MEL__c 
                                From Contract
                                Where Id IN :ids];
                                        
        for(Contract c : maList){
            mamap.put(c.ID,c.Date_de_traitement_MEL__c);
        }
        
        return mamap;
    }
    
}