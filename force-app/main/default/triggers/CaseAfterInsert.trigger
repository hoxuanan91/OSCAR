trigger CaseAfterInsert on Case(after insert ){
    private static final String CLASS_NAME = 'CaseAfterInsert';
    private static final String METHOD_NAME = 'INIT TRIGGER';
    
	if (PAD.scriptIsStarted('CaseAfterInsert')){
		return;
    }

    PAD.debugLogInfo(CLASS_NAME, METHOD_NAME, 'BEGIN');
    TR005_CaseTriggerHandler.onAfterInsert(Trigger.new);


	if (PAD.canTrigger('TR002ManageContract')){
        PAD.debugLogInfo(CLASS_NAME, METHOD_NAME, 'Can trigger TR002ManageContract');

		//Déclaration de la liste des Ids des dossiers
		List<Id> dossierIds = new List<Id>();

		for (Case c : [SELECT Id, Status, Dossier1__c
		               FROM Case
		               WHERE RecordType.DeveloperName = 'CBM_Reamenagement' AND Id IN :Trigger.newMap.keySet()]){

			if (c.Status != null && c.Status.contains('Terminée')){
				System.debug('#### : bouble :' + c.Id + ' / ' + c.Dossier1__c);
				dossierIds.add(c.Dossier1__c);
			}
		}

		// Vérifier que la liste des cases n'est pas vide,
		// puis lancer le traitement sur la liste des cases
		if (!dossierIds.isEmpty())
			TR002ManageContract.CalculateNombreReamenagement(dossierIds);
	}

	if (PAD.canTrigger('TR002ManageContract_NomTiers')){

		System.debug('#### : CaseAfterInsert - TR002ManageContract_NomTiers');

		//Déclaration de la liste des Ids des dossiers
		Map<Id, List<Case>> demandeDossierIds = new Map<Id, List<Case>>();

		for (Case c : [SELECT Id, Status, Dossier1__c
		               FROM Case
		               WHERE RecordType.DeveloperName != 'CBM_Appel_de_fonds_recouvrer' AND RecordType.DeveloperName != 'CBM_Impaye_et_avoir_Post_Real' AND Dossier1__c != null AND Id IN :Trigger.newMap.keySet()]){

			if (demandeDossierIds.get(c.Dossier1__c) == null){
				demandeDossierIds.put(c.Dossier1__c, new List<Case>());
				demandeDossierIds.get(c.Dossier1__c).add(c);
			} else{
				demandeDossierIds.get(c.Dossier1__c).add(c);
			}
		}

		// Vérifier que la liste des cases n'est pas vide,
		// puis lancer le traitement sur la liste des cases
		if (!demandeDossierIds.isEmpty())
			TR002ManageContract.RecupererNomTiers(demandeDossierIds);
	}

	/*if(PAD.canTrigger('TR002ManageCase_Attribution')){

	 System.debug('#### : CaseAfterInsert - TR002ManageCase_Attribution');

	//Déclaration de la liste des Ids des dossiers
	 List<Id> caseIds= new List<Id>();

	 for(Case c : [SELECT Id,
	 Status,
	 Dossier1__c
	 FROM Case
	 WHERE (RecordType.DeveloperName = 'CBM_Appel_de_fonds_recouvrer'
	 OR RecordType.DeveloperName = 'CBM_Impaye_et_avoir_Post_Real')
	 AND Dossier1__c != null
	 AND Id IN: Trigger.newMap.keySet()]){

	 caseIds.add(Trigger.new[i].Id);

	 }

	// Vérifier que la liste des cases n'est pas vide,
	// puis lancer le traitement sur la liste des cases
	 if(!caseIds.isEmpty())
	 TR001ManageCase.CalculateAttribution(caseIds);

	 }*/

	/*if(PAD.canTrigger('TR002ManageCase_Attribution_Automatique'))
	 {

	 System.debug('#### : CaseAfterInsert - TR002ManageCase_Attribution_Automatique');

	//Déclaration de la liste des Ids des dossiers
	 List<Case> cases = new List<Case>();

	//Déclaration des ID des recordType
	// Cap Gemini - JR - 05/12/17 - Le Type d'Enregistrement CBI - Actions de Recouvrement (CBIActionsRecouvrement) a été ajouté
	 Map<String,Id> RTs = DAL.getRecordType('Case');
	 Map<Id,String> RTsOrderByIds = DAL.getRecordTypeOrderById('Case');

	//        ID rtActionRecouvrement = (ID)RTs.get('CBM_Actions_de_Recouvrement');
	//        ID rtActionRecouvrementCBI = (ID)RTs.get('CBIActionsRecouvrement');
	 ID rtAppelFondARecouvrer = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
	 ID rtImpayesAvoirPostReal = (ID)RTs.get('CBM_Impaye_et_avoir_Post_Real');

	//        System.debug('#### : rtActionRecouvrement :' + rtActionRecouvrement);
	//        System.debug('#### : rtActionRecouvrementCBI :' + rtActionRecouvrementCBI);
	 System.debug('#### : rtAppelFondARecouvrer :' + rtAppelFondARecouvrer);
	 System.debug('#### : rtImpayesAvoirPostReal :' + rtImpayesAvoirPostReal);

	 for(integer i = 0; i < Trigger.new.size() ; i++){

	//Mise à jour 17/12/15 : on vérifie que le RT n'est pas CBI
	 if( rtAppelFondARecouvrer != null && rtImpayesAvoirPostReal != null
	 &&  !rtAppelFondARecouvrer.equals(Trigger.new[i].RecordTypeId) && !rtImpayesAvoirPostReal.equals(Trigger.new[i].RecordTypeId)
	 && !RTsOrderByIds.get(Trigger.new[i].RecordTypeId).startsWith('CBI'))){

	 cases.add(Trigger.new[i]);
	 }

	 }

	// Vérifier que la liste des cases n'est pas vide,
	// puis lancer le traitement sur la liste des cases
	 if(cases.size() > 0)
	 TR001ManageCase.CalculateAttributionAutomatique(cases);

	 }*/
	//Add by Mourad SAIR 02/04/2015
	/*if(PAD.canTrigger('CreateCommentCase'))
	 {

	 System.debug('#### : CaseAfterInsert - CreateCommentCase');

	 System.debug('#### : CreateCommentCase ');
	 Set<Id> CasesComment = new Set<ID>();
	 for(Case Ca : Trigger.new)
	//Récupérer les Ids des Demandes avec le champ 'Commentaire en cours renseigné afin de créer un commentaire sur la demande en cours
	 if (Ca.CommentaireC__c != null && Ca.CommentaireC__c!= '')CasesComment.add(Ca.Id);

	// Vérifier que la liste des casesComment n'est pas vide,
	// puis lancer le traitement sur la liste des cases
	 if(CasesComment.size() > 0) TR001ManageCase.CreateCommentCaseAfterInsert(CasesComment);
	 }*/
	//End Mourad

	PAD.debugLogInfo(CLASS_NAME, METHOD_NAME, 'END');
}