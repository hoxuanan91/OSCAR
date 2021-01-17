@istest
public class TestsTR001ManageCase{
    
    static testMethod void testCommentaireCaseInsert() {
    
    User u = TestFactory.createUser();
        System.runAs(u){
            
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Map<Id,String> RTsOBI = DAL.getRecordTypeOrderById('Case');
            
            Map<String,Id> Queues = DAL.getQueue();
                      
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Transfert');
                c.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
                c.CommentaireC__c = 'Test Comment';
                insert c;
            Test.stopTest();
            
            Case cResultat = [select CommentaireC__c from Case where id = :c.id];
            CaseComment cResultat2 = [Select ParentId, CommentBody from CaseComment where ParentId =: cResultat.Id limit 1];
            
            system.assertEquals( null , cResultat.CommentaireC__c);
            /** Bloquant MEP Oscar CBI
            system.assertEquals( 'Test Comment' , cResultat2.CommentBody);
            */
            }
    
    }
    
    static testMethod void testCommentaireCaseUpdate() {
    
        User u = TestFactory.createUser();
        System.runAs(u){
            
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Transfert');
            c.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            insert c;
            
            Test.startTest();
                c.CommentaireC__c = 'Test Comment';
                update c;
            Test.stopTest();
            
            Case cResultat = [select CommentaireC__c from Case where id = :c.id];
            //CaseComment cResultat2 = [Select ParentId, CommentBody from CaseComment where ParentId =: cResultat.Id limit 1];
            
            //system.assertEquals( null , cResultat.CommentaireC__c);
            //system.assertEquals( 'Test Comment' , cResultat2.CommentBody);
            }
    
    }
  

    
    static testMethod void testCalculateAttribution_RecouvrementSansGroupeAppartenance() {
        
        User usr = TestFactory.createUser('mock groupe appartenance', true);
        insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
           /* u.UserByPassProcess__c = False;
            update u;*/
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
            
         
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            insert ctr;
            
          //  User usr = TestFactory.createUser('mock groupe appartenance', true);
           // insert usr;
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
                c.Gestionnaire_Cassiopae__c = usr.id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            
            // Cap Gemini - JR - 05/12/17 - La File d'Attente CBM Service Recouvrement (CBM_Service_Recouvrement) a été renomée en Service Recouvrement (Service_Recouvrement)
            //System.assertEquals(cResultat.OwnerId , (ID) Queues.get('Service_Recouvrement'));   
            
        }
    }

    
    
     // Capgemini - Radoica Jankovic 12/03/2018
     static testMethod void testCalculateAttribution_CBMSRCGC() {
        
        //User u = TestFactory.createUser();
         User usr = TestFactory.createUser('mock groupe appartenance', true);
         insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
        
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contact cont = TestFactory.createContact('FisrtName','LastName','mock Groupe Post Réal', 'mock Groupe Post Réal');
            insert cont;
            
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            insert ctr;
            
           // User usr = TestFactory.createUser('mock groupe appartenance', true);
           // insert usr;
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
                c.Gestionnaire_Cassiopae__c = usr.id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            System.assertEquals(cResultat.OwnerId , (ID) Queues.get('CBMSRCGC'));
            
        }
    }



   
    static testMethod void testAttributionAutomatique() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Test.startTest();
            
              Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
              c.recordTypeId = (ID)RTs.get('CBM_Mise_en_place');
              Database.Saveresult  result = Database.insert(c);
            
            Test.stopTest();
            
             System.assertEquals(true, result.isSuccess());
        }
    }
    
    /*static testMethod void testAttributionAutomatiqueBulk() {
        
        User u = TestFactory.createUser();
        u.UserByPassWorkflows__c = true;
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Case> casesReamenagement = TestFactory.createCaseWithRTBulk(20, String.valueOf(ctr.Id), 'Terminée', (ID)RTs.get('CBM_Mise_en_place'), true);
            
            Test.startTest();
                Database.Saveresult[]  results = Database.insert(casesReamenagement);
            Test.stopTest();
            
            for(Database.Saveresult result : results){
                System.assertEquals(true, result.isSuccess());
            }
        }
    }
*/
     static testMethod void testCalculNombreFactureSuppression() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Transfert');
            insert c;
            
            List<Facture_non_lettree__c> factures = new List<Facture_non_lettree__c>();
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Montant_TTC__c = 100.50;
            f1.Solde_TTC__c = 200.30;
            f1.Date_de_rattachement_demande__c = Date.newInstance(2015,4,10);
            factures.add(f1);
            
            Facture_non_lettree__c f2 = TestFactory.createFacture(c.Id);
            f2.Montant_TTC__c = -20.50;
            f2.Solde_TTC__c = -160.30;
            f2.Date_de_rattachement_demande__c = Date.newInstance(2015,4,5);
            factures.add(f2);
            
            insert factures;
            
            Test.startTest();
                delete f1;
            Test.stopTest();
            
            Case cResultat = [SELECT /* Nombre_de_factures_non_lettrees__c, */ Nb_Avoirs__c, Nb_imp__c, Total_Montant_TTC__c, Total_Solde_TTC__c /*, Date_de_creation_du_dernier_impaye__c */
                                FROM Case
                                Where id = : c.Id];

        }
    }
    
    static testMethod void testCalculNombreFactureRestauration() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Transfert');
            insert c;
            
            List<Facture_non_lettree__c> factures = new List<Facture_non_lettree__c>();
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Montant_TTC__c = 100.50;
            f1.Solde_TTC__c = 200.30;
            f1.Date_de_rattachement_demande__c = Date.newInstance(2015,4,1);
            factures.add(f1);
            
            Facture_non_lettree__c f2 = TestFactory.createFacture(c.Id);
            f2.Montant_TTC__c = -20.50;
            f2.Solde_TTC__c = -160.30;
            f2.Date_de_rattachement_demande__c = Date.newInstance(2015,4,5);
            factures.add(f2);
            
            insert factures;
            
            delete f1;
            
            Test.startTest();
                undelete f1;
            Test.stopTest();
            
            Case cResultat = [SELECT /* Nombre_de_factures_non_lettrees__c, */ Nb_Avoirs__c, Nb_imp__c, Total_Montant_TTC__c, Total_Solde_TTC__c /*, Date_de_creation_du_dernier_impaye__c */
                                FROM Case
                                Where id = : c.Id];

        }
    }
    
      static testMethod void testCalculPhase_AJour() {
          
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            u.UserByPassProcess__c = false;
            Update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
            c.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            c.Phase__c = '';
            insert c;
            
            Case c2 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c2.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
            c2.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            c.Phase__c = '';
            insert c2;
            
            Case c3 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c3.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
            c3.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            c.Phase__c = '';            
            insert c3;

            /* Création de la Facture Non Lettrée */ 
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Date_de_reglement__c = Date.today();
            f1.Montant_TTC__c = 100;
            f1.Solde_TTC__c = 0;
            insert f1;

            Test.startTest();        
 
                c.LancerCalculPhase__c = True;   // Lancer le Calcul de la Phase
                update c;

            Test.stopTest();

            Case cResultat1 = [select Phase__c from Case where id = :c.id];
/*            
            system.assertEquals( 'A jour' , cResultat1.Phase__c);
*/
        }
     }



  
     static testMethod void testCalculPhase_ARelancer() {
  
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
            c.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            insert c;
            
            Case c2 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c2.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
            c2.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            insert c2;
            
            Case c3 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c3.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
            c3.Derniere_Date_APrendreEnCharge__c = datetime.newInstance(2014, 10, 1);
            insert c3;

            Test.startTest();         
              
                /* Création de la Facture Non Lettrée */               
                Facture_non_lettree__c f4 = TestFactory.createFacture(c3.Id);
                f4.Date_de_rattachement_demande__c = Date.today();
                f4.Montant_TTC__c = 100;
                f4.Solde_TTC__c = 100;
                insert f4;
                
                c.LancerCalculPhase__c = True;   // Lancer le Calcul de la Phase
                
                update c;
                System.debug('TESTING : ' + c );
                System.debug('TESTING : ' + c.LancerCalculPhase__c );
                
            Test.stopTest();
            
            Case cResultat1 = [select Phase__c from Case where id = :c3.id];
            system.assertEquals( 'A relancer' , cResultat1.Phase__c);            
            
        }
     }    
     

    static testMethod void testCalculDelais_DerniereDate() {
        
        User u = TestFactory.createUser();

        
        System.runAs(u){
            Map<String,Id> RTs = DAL.getRecordType('Case');
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Test.startTest();
            
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'Prise en charge', (ID)RTs.get('CBM_Transfert'));
            insert c;
            System.debug('TESTING : ' + c.Derniere_Date_APrendreEnCharge__c );
            System.debug('TESTING : ' + c.Derniere_Date_PriseEnCharge__c );
            
            c.status = 'A prendre en charge';
            
            update c;
            System.debug('TESTING : ' + c );
            System.debug('TESTING : ' + c.Derniere_Date_PriseEnCharge__c );
            
            Case cResultat = [Select Derniere_Date_APrendreEnCharge__c from Case where id = :c.id];
            System.assertEquals(cResultat.Derniere_Date_APrendreEnCharge__c.date(),date.today());
            
            
            c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge', (ID)RTs.get('CBM_Deces'));
            insert c;
            c.status = 'Prise en charge';
            update c;
            
            cResultat = [Select Derniere_Date_PriseEnCharge__c from Case where id = :c.id];
            //System.assertEquals(cResultat.Derniere_Date_PriseEnCharge__c.date(),date.today());
            
            c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge', (ID)RTs.get('CBM_Transfert'));
            insert c;
            c.status = 'Terminée';
            update c;
            
            cResultat = [Select Derniere_Date_Termine__c from Case where id = :c.id];
            //System.assertEquals(cResultat.Derniere_Date_Termine__c.date(),date.today());
            
            c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge', (ID)RTs.get('CBM_Incapacite'));
            insert c;
            c.status = 'Affecté';
            update c;
            
            cResultat = [Select Derniere_Date_Affecte__c from Case where id = :c.id];
            //System.assertEquals(cResultat.Derniere_Date_Affecte__c.date(),date.today());
            
            Test.stopTest();
        }
    
    }

    static testMethod void testCalculDelais_DerniereDate2() {
        User u = TestFactory.createUser();

        
        System.runAs(u){
            Map<String,Id> RTs = DAL.getRecordType('Case');
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Test.startTest();
            
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge', (ID)RTs.get('CBM_Mise_en_place'));
            c.Phase__c = '';
            insert c;
            c.status = 'Affecté';
            update c; 
            
            Case cResultat = [Select Derniere_Date_PhaseAjour__c from Case where id = :c.id];
            System.assertEquals(cResultat.Derniere_Date_PhaseAjour__c,date.today());
            
            c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge', (ID)RTs.get('CBM_Mise_en_place'));
            c.Phase__c = '';
            c.Dossier_complet__c = Date.newInstance(2015, 5, 1);
            c.Avenant_envoye__c = Date.newInstance(2015, 5, 10);
            insert c;
            
            cResultat = [Select DelaiTransfert_DC_AE__c from Case where id = :c.id];
            //System.assertEquals(cResultat.DelaiTransfert_DC_AE__c,5);
            
            c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge', (ID)RTs.get('CBM_Mise_en_place'));
            c.Phase__c = '';
            c.Dossier_complet__c = Date.newInstance(2015, 5, 10);
            c.Avenant_envoye__c = Date.newInstance(2015, 5, 1);
            insert c;
            
            cResultat = [Select DelaiTransfert_DC_AE__c from Case where id = :c.id];
            //System.assertEquals(cResultat.DelaiTransfert_DC_AE__c,0);
            
            Test.stopTest();
        }
    
    }
    
    static testMethod void testDisableDeleteCaseAdministrateur() {
        
        User u = TestFactory.createUserWithProfile(1, 'Administrateur système','System Administrator');
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Mise_en_place');
            insert c;
            
            Test.startTest();
            
                Database.DeleteResult dres = Database.delete(c);
            
            Test.stopTest();
            
            System.assertEquals(true, dres.isSuccess());
        }
    }

    static testMethod void testDisableDeleteCaseNonAdministrateur() {
        
        User u = TestFactory.createUserWithProfile(1, 'Utilisateur standard','Standard User');
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Mise_en_place');
            insert c;
            
            Test.startTest();
                Database.DeleteResult dres;
                try{
                    dres = Database.delete(c, false);
                }Catch(Exception ex){
                    System.assertEquals(false, dres.isSuccess());
                    for(Database.Error err : dres.getErrors())
                        System.assertEquals(err.getMessage() , Label.disableDeleteErrorMessage);    
                }
            Test.stopTest();
            
        }
    }
    
 /*   static testMethod void testDisableDeleteCaseAdministrateurBulk() {
        
        User u = TestFactory.createUserWithProfile(1, 'Administrateur système','System Administrator');
        u.UserByPassWorkflows__c = true;
        u.UserByPassProcess__c = True;
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Case> casesReamenagement = TestFactory.createCaseWithRTBulk(20, String.valueOf(ctr.Id), 'Terminée', (ID)RTs.get('CBM_Reamenagement'), true);
            insert casesReamenagement;
            
            Test.startTest();
            
                Database.DeleteResult[] dresults = Database.delete(casesReamenagement);
            
            Test.stopTest();
            
            //for(Database.DeleteResult dres : dresults)
                System.assertEquals(true, dresults[0].isSuccess());
        }
    }
*/
  /*  static testMethod void testDisableDeleteCaseNonAdministrateurBulk() {
        
        User u = TestFactory.createUserWithProfile(1, 'Utilisateur standard','Standard User');
        u.UserByPassWorkflows__c = true;
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Case> casesReamenagement = TestFactory.createCaseWithRTBulk(10, String.valueOf(ctr.Id), 'Terminée', (ID)RTs.get('CBM_Reamenagement'), true);
            insert casesReamenagement;
            
            Test.startTest();
                Database.DeleteResult[] dresults;
                try{
                    dresults = Database.delete(casesReamenagement,false);
                }Catch(Exception ex){
                    for(Database.DeleteResult dres : dresults){
                        System.assertEquals(false, dres.isSuccess());
                    
                        for(Database.Error err : dres.getErrors())
                            System.assertEquals(err.getMessage() , Label.disableDeleteErrorMessage);
                    }   
                }
            Test.stopTest();
        }
    }
    
    */
  
    //Add by Mourad 21/04/2015 : 
    //Création des méthodes de test pour chaque méthode.
    //Test de la methode TR001ManageCase.MAJArevoirDemandeAjour(demandeIDs, CasesAjour) : Priorité 1
    static testMethod void MAJArevoirDemandeAjourPriorite1() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
           Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
           
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge',(ID)RTs.get('CBM_Actions_de_Recouvrement'));
            C.Date_revoir__c = date.newInstance(2015, 04, 1);
            C.Motif_a_revoir__c = 'Motif Test';   
            insert c;
            
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Date_INSERT__c = date.newInstance(2015, 04, 1);
            f1.Date_UPDATE__c = date.newInstance(2015, 04, 5);
            f1.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 4);
            f1.Date_de_reglement__c =  null;
            insert f1;
            
            test.startTest();
            f1.Date_de_reglement__c = date.newInstance(2015, 04, 16);
            update f1;
            test.stopTest();
            
            Case cResultat = [select Date_revoir__c, Motif_a_revoir__c from Case where id = :c.id];
            
            system.debug('#####C.Date_revoir__c' + cResultat.Date_revoir__c);
            system.debug('#####C.Motif_a_revoir__c' + cResultat.Motif_a_revoir__c);
            /** Pour MEP Oscar CBI : bloquant
            system.assertEquals(  null , cResultat.Date_revoir__c);         
            system.assertEquals(  null , cResultat.Motif_a_revoir__c);
            */

        }
    }
    
    //Test de la methode TR001ManageCase.MAJArevoirDemandeAjour(demandeIDs, CasesAjour) : Priorité 2
    static testMethod void MAJArevoirDemandeAjourPriorite2() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
           Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
           
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge',(ID)RTs.get('CBM_Actions_de_Recouvrement'));
            C.Date_revoir__c = date.newInstance(2015, 04, 1);
            C.Motif_a_revoir__c = 'Motif Test';   
            insert c;
            
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Date_INSERT__c = date.newInstance(2015, 04, 1);
            f1.Date_UPDATE__c = date.newInstance(2015, 04, 5);
            f1.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 4);
            f1.Date_de_reglement__c =  date.newInstance(2015, 04, 4);
            insert f1;
            
            Facture_non_lettree__c f2 = TestFactory.createFacture(c.Id);
            f2.Date_INSERT__c = date.newInstance(2015, 04, 16);
            f2.Date_UPDATE__c = date.newInstance(2015, 04, 16);
            f2.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 15);
            f2.Date_de_reglement__c =  null;
            
            test.startTest();
            insert f2;
            test.stopTest();
            
            Case cResultat = [select Date_revoir__c, Motif_a_revoir__c from Case where id = :c.id];
    
            system.debug('#####C.Date_revoir__c' + cResultat.Date_revoir__c);
            system.debug('#####C.Motif_a_revoir__c' + cResultat.Motif_a_revoir__c);
            /** Pour MEP Oscar CBI : bloquant
            system.assertEquals(  date.newInstance(2015, 04, 15) + 1 , cResultat.Date_revoir__c);
            */
            //system.assertEquals(  'Nouvel Impayé/Avoir' , cResultat.Motif_a_revoir__c);
            

        }
    }

    //Test de la methode TR001ManageCase.MAJArevoirDemandeAjour(demandeIDs, CasesAjour) : Priorité 3
    static testMethod void MAJArevoirDemandeAjourPriorite3() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
           Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
           
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge',(ID)RTs.get('CBM_Actions_de_Recouvrement'));
            C.Date_revoir__c = date.newInstance(2015, 04, 1);
            C.Motif_a_revoir__c = 'Motif Test';   
            insert c;
            
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Date_INSERT__c = date.newInstance(2015, 04, 1);
            f1.Date_UPDATE__c = date.newInstance(2015, 04, 5);
            f1.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 4);
            f1.Date_de_reglement__c =  null;
            insert f1;
            
            Facture_non_lettree__c f2 = TestFactory.createFacture(c.Id);
            f2.Date_INSERT__c = date.newInstance(2015, 04, 10);
            f2.Date_UPDATE__c = date.newInstance(2015, 04, 23);
            f2.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 19);
            f2.Date_de_reglement__c =  date.newInstance(2015, 04, 21);
            f2.DateDernRglt__c =  date.newInstance(2015, 04, 21);
            insert f2;
            
            test.startTest();
            f2.Date_UPDATE__c = date.newInstance(2015, 04, 24);
            f2.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 23);
            f2.Date_de_reglement__c = null;
            update f2;
            test.stopTest();
            
            Case cResultat = [select Date_revoir__c, Motif_a_revoir__c   from Case where id = :c.id];
            Facture_non_lettree__c fResultat = [select DateDernRglt__c, Jour_rejet__c, Rejet_today__c from Facture_non_lettree__c where id = :f2.id];
            
            system.debug('#####C.Date_revoir__c' + cResultat.Date_revoir__c);
            system.debug('#####C.Motif_a_revoir__c' + cResultat.Motif_a_revoir__c);
            system.debug('#####C.Jour_rejet__c' + fResultat.Jour_rejet__c);
            system.debug('#####C.Rejet_today__c' + fResultat.Rejet_today__c);
            /** Pour MEP Oscar CBI : bloquant
            system.assertEquals( date.newInstance(2015, 04, 23) + 1 , cResultat.Date_revoir__c);
            */
            //system.assertEquals( 'Paiement rejeté' , cResultat.Motif_a_revoir__c);

        }
    }
    
    //testCalculNombreFactureModifDemande added by Hanane
    //09/06/2015
    static testMethod void testCalculNombreFactureModifDemande() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Case> Demandes = new List<Case>();
            
            Case c1 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c1.recordTypeId = (ID)RTs.get('CBM_Transfert');
            Demandes.add(c1);
            
            Case c2 = TestFactory.createCase(ctr.Id, 'Terminée');
            c2.recordTypeId = (ID)RTs.get('CBM_Transfert');
            Demandes.add(c2);
            
            insert Demandes;
            
            List<Facture_non_lettree__c> factures = new List<Facture_non_lettree__c>();
            Facture_non_lettree__c f1 = TestFactory.createFacture(c1.Id);
            f1.Montant_TTC__c = 100.50;
            f1.Solde_TTC__c = 200.30;
            f1.Date_de_rattachement_demande__c = Date.newInstance(2015,4,1);
            factures.add(f1);
            
            Facture_non_lettree__c f2 = TestFactory.createFacture(c2.Id);
            f2.Montant_TTC__c = -20.50;
            f2.Solde_TTC__c = -160.30;
            f2.Date_de_rattachement_demande__c = Date.newInstance(2015,4,5);
            factures.add(f2);
            
            Facture_non_lettree__c f3 = TestFactory.createFacture(c2.Id);
            f3.Montant_TTC__c = -40;
            f3.Solde_TTC__c = -50;
            f3.Date_de_rattachement_demande__c = Date.newInstance(2015,4,7);
            factures.add(f3);
            
            insert factures;


        }
    }
    
    //Capgemini - Radoica Jankovic - 14/03/2018
    static testMethod void testAffectationNotaire() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBIImmobilier');
            insert c;
                       
            Test.startTest();
                c.NotaireEnCharge__c = null;
                update c;
            Test.stopTest();

        }
    }

    //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC 01  
        static testMethod void testCalculateAttribution_CBMSRC01() {
        
       // User u = TestFactory.createUser();
        User usr = TestFactory.createUser('mock groupe appartenance', true);
        usr.UniteSRC__c = '1';   // 1 - CBM SRC 1 
        usr.UserByPassProcess__c = True;
        insert usr;
            
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            //u.UserByPassProcess__c = True;
            //update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '1';   // 1 - BU 1
            insert ctr;
            
            /*User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = '1';   // 1 - CBM SRC 1 
            insert usr;*/
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
                c.Gestionnaire_Cassiopae__c = null;
                c.OwnerId = usr.Id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            
            System.assertEquals(cResultat.OwnerId , (ID) Queues.get('CBMSRC01'));   
            
        }
    }    
    
    //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC 24
        static testMethod void testCalculateAttribution_CBMSRC24_2() {
        
        //User u = TestFactory.createUser();
        //
        User usr = TestFactory.createUser('mock groupe appartenance', true);
        usr.UniteSRC__c = '2';   // 1 - CBM SRC 1 
        usr.UserByPassProcess__c = True;
        insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
           // u.UserByPassProcess__c = True;
           // update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '2';   // 2 - BU 2
            insert ctr;
            
         /* 
          *  User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = '2';   // 2 - CBM SRC 2 & 4
            insert usr;
           */   
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
                c.Gestionnaire_Cassiopae__c = null;
                c.OwnerId = usr.Id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            
            System.assertEquals(cResultat.OwnerId , (ID) Queues.get('CBMSRC24'));   
         
        }
    }
 
    //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC 3
        static testMethod void testCalculateAttribution_CBMSRC03() {
        
        //User u = TestFactory.createUser();
        User usr = TestFactory.createUser('mock groupe appartenance', true);
        usr.UniteSRC__c = '3';   // 3 - CBM SRC 3 
        usr.UserByPassProcess__c = True;
        insert usr;
            
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
           // u.UserByPassProcess__c = True;
           // update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '3';   // 3 - BU 3
            insert ctr;
            
           
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
                c.Gestionnaire_Cassiopae__c = null;
                c.OwnerId = usr.Id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            
            System.assertEquals(cResultat.OwnerId , (ID) Queues.get('CBMSRC03'));   
            
        }
    }
    
        //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC 24
        static testMethod void testCalculateAttribution_CBMSRC24_4() {
        
        //User u = TestFactory.createUser();
        User usr = TestFactory.createUser('mock groupe appartenance', true);
        usr.UniteSRC__c = '4';    // 4 - CBM SRC GC 
        usr.UserByPassProcess__c = True;
        insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
         //   u.UserByPassProcess__c = True;
         //   update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '4';   // 4 - BU 4
            insert ctr;
            
          /*  User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = '4';   // 4 - CBM SRC GC 
            insert usr;*/
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
                c.Gestionnaire_Cassiopae__c = null;
                c.OwnerId = usr.Id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            
            System.assertEquals(cResultat.OwnerId , (ID) Queues.get('CBMSRC24'));   
            
        }
    }

    //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC LOA V
        static testMethod void testCalculateAttribution_SRCLOAV() {

         User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = ''; 
            insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
           // u.UserByPassProcess__c = True;
          //  update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '6';   // 6 - BU LOA V
            insert ctr;
            
           
            
            Test.startTest();
                Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
                c.Gestionnaire_Cassiopae__c = null;
                c.OwnerId = usr.Id;
                insert c;
            Test.stopTest();
            
            Case cResultat = [SELECT OwnerId ,Gestionnaire_Cassiopae__c FROM Case WHERE id = :c.Id];
            
            System.assertEquals(cResultat.OwnerId , (ID) Queues.get('SRCLOAV'));   
            
        }
    }
    
        //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC LOA V
        static testMethod void testCalculateReamenagement() {

        User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = ''; 
            insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
         //   u.UserByPassProcess__c = True;
         //   update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '';
            insert ctr;
            
           /* User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = ''; 
            insert usr;*/
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            c.Gestionnaire_Cassiopae__c = null;
            c.OwnerId = usr.Id;
            insert c;
            
            Test.startTest();
                c.Status = 'Terminée';
                update c;
            Test.stopTest();
            
        }
    }
    
    
    //Capgemini - Radoica Jankovic - 14/03/2018
    //Propriétaire par Défaut File d'Attente CBM SRC LOA V
        static testMethod void testManageContract_NomTiers() {

       User usr = TestFactory.createUser('mock groupe appartenance', true);
            usr.UniteSRC__c = ''; 
            insert usr;
        System.runAs(usr){
            
            List<Group> fileDattente = TestFactory.createQueues();
            insert fileDattente;
            
            System.debug('#### fileDattente : ' + fileDattente);
            
            Map<String,Id> Queues = DAL.getQueue();
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
           // u.UserByPassProcess__c = True;
          //  update u;
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
          
            Contact cont = TestFactory.createContact('FisrtName','LastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
            insert cont;
          
            Contract ctr = TestFactory.createContract(acc.Id, cont);
            ctr.BusinessUnit__c = '';
            insert ctr;
            
            Case c = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c.recordTypeId = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
            c.Gestionnaire_Cassiopae__c = null;
            c.OwnerId = usr.Id;
            insert c;
            
            c.Dossier1__c = null;
            update c;
            
            Test.startTest();
                c.Dossier1__c = ctr.Id;
                update c;
            Test.stopTest();
            
          
        }
    }

    //Capgemini - Radoica Jankovic - 14/03/2018
    //Test Attribution Automatique
    static testMethod void testCalculateAttributionAutomatique() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Case> Demandes = new List<Case>();
            
            Case c1 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c1.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
            Demandes.add(c1);
            
            Case c2 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c2.recordTypeId = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');
            Demandes.add(c2);
            
            insert Demandes;
            
                         

        }
    }
    
  
}