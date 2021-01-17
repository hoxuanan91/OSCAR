public with sharing class TR002_InfoSignatairesHandler{
	private static final String CLASS_NAME = TR002_InfoSignatairesHandler.class.getName();
	private static final String TYPE_DOCUMENT_ASSURANCE_AON = 'Assurance';
	public static Set<Id> recordTypesIdOpportunityAON;
	public static void onAfterInsert(List<InformationsSignataire__c> newInfoSignataires){
		String methodName = 'onAfterInsert';
		PAD.debugLogInfo(CLASS_NAME, methodName, 'BEGIN');
		AP20_TriggerFactory.createHandler(InformationsSignataire__c.getSobjectType());
		updateGlobalSignedStatusAON(newInfoSignataires);
		PAD.debugLogInfo(CLASS_NAME, methodName, 'END');
	}

	public static void onAfterUpdate(map<Id, InformationsSignataire__c> mapNewInfoSignataires, map<Id, InformationsSignataire__c> mapOldInfoSignataires){
		String methodName = 'onAfterUpdate';
		PAD.debugLogInfo(CLASS_NAME, methodName, 'BEGIN');
		updateGlobalSignedStatusAON(mapNewInfoSignataires.values());
		PAD.debugLogInfo(CLASS_NAME, methodName, 'END');
	}

	private static List<Opportunity> updateGlobalSignedStatusAON(List<InformationsSignataire__c> newInfoSignataires){
		String methodName = 'updateGlobalSignedStatusAON';
		PAD.debugLogInfo(CLASS_NAME, methodName, 'BEGIN');
		List<Opportunity> opptsToUpdate;
		try{
			/**
			 * Initalize recordType opportunity in AON case
			 */
			if (recordTypesIdOpportunityAON == null){
				recordTypesIdOpportunityAON = new Set<Id>();
				List<RecordType> recordTypesOpportunityAON = [SELECT ID, IsActive, DeveloperName, SobjectType
				                                              FROM RecordType
				                                              WHERE SobjectType = 'Opportunity' AND IsActive = true AND (DeveloperName = 'CBMEnDelegation' OR DeveloperName = 'CBMHorsDelegationDCR' OR DeveloperName = 'CBMHorsDelegationDEN' OR DeveloperName = 'CBMHorsDelegationDR')];
				PAD.debugLogInfo(CLASS_NAME, methodName, 'recordTypesOpportunityAON ==> ' + recordTypesOpportunityAON);

				if (recordTypesIdOpportunityAON == null){
					return null;
				}
				for (RecordType rT : recordTypesOpportunityAON){
					recordTypesIdOpportunityAON.add(rT.ID);
				}
			}
			PAD.debugLogInfo(CLASS_NAME, methodName, 'newInfoSignataires ==> ' + newInfoSignataires);

			if (newInfoSignataires == null || newInfoSignataires.isEmpty()){
				return null;
			}

			Set<ID> opportunityIds = new Set<ID>();
			for (InformationsSignataire__c infoSign : newInfoSignataires){
				if (infoSign.Type_de_document__c == TYPE_DOCUMENT_ASSURANCE_AON && infoSign.Opportunity__c != null){
					opportunityIds.add(infoSign.Opportunity__c);
				}
			}

			PAD.debugLogInfo(CLASS_NAME, methodName, 'opportunityIds ==> ' + opportunityIds);

			if (opportunityIds.isEmpty()){
				return null;
			}

			List<Opportunity> parentOppts = [SELECT RecordTypeId, ID, StatutGlobalAON__c, (SELECT ID, Type_de_document__c, Statut_Adhesion__c
			                                                                               FROM InformationsSignataire__r
			                                                                               WHERE Type_de_document__c = :TYPE_DOCUMENT_ASSURANCE_AON)
			                                 FROM Opportunity
			                                 WHERE ID IN :opportunityIds AND RecordTypeId IN :recordTypesIdOpportunityAON];
			if (parentOppts == null){
				return null;
			}

			opptsToUpdate = new List<Opportunity>();

			for (Opportunity oppt : parentOppts){
				if (oppt.InformationsSignataire__r == null){
					continue;
				}
				Integer nbRefuse = 0;
				Integer nbAceptation = 0;

				for (InformationsSignataire__c childInfoSignataires : oppt.InformationsSignataire__r){
					if (childInfoSignataires.Statut_adhesion__c == 'Accepté'){
						nbAceptation += 1;
					}
					if (childInfoSignataires.Statut_adhesion__c == 'Refusé'){
						nbRefuse += 1;
					}
				}
				/**
				 * CASE( Statut_parcours__c ,


				 "0001,0002,0003,0005,0006,0009,0011,0012", "En cours",
				 "0004,0010,0014", "Sans Suite",
				 "0007,0013", "Accepté",
				 "0008", "Refusé",


				 "")
				 */
				String oldGlobalStatus = oppt.StatutGlobalAON__c;
				if (nbAceptation == oppt.InformationsSignataire__r.size()){
					oppt.StatutGlobalAON__c = 'Accepte';
				} else if (nbRefuse > 0){
					oppt.StatutGlobalAON__c = 'Refuse';
				} else{
					oppt.StatutGlobalAON__c = null;
				}

				PAD.debugLogInfo(CLASS_NAME, methodName, 'old status ==> ' + oldGlobalStatus);

				PAD.debugLogInfo(CLASS_NAME, methodName, 'new status ==> ' + oppt.StatutGlobalAON__c);

				if (oppt.StatutGlobalAON__c != oldGlobalStatus){
					opptsToUpdate.add(oppt);
				}
			}
			PAD.debugLogInfo(CLASS_NAME, methodName, 'opptsToUpdate ==> ' + opptsToUpdate);

			if (opptsToUpdate.isEmpty()){
				return null;
			}
			Savepoint sp = Database.setSavepoint();
			try{
				update opptsToUpdate;
				PAD.debugLogInfo(CLASS_NAME, methodName, 'Oppt has been update with succes');
			} catch (DmlException e){
				PAD.debugLogError(CLASS_NAME, methodName, 'DmlException Update Opportunities ==> ' + e.getMessage());
			}
		} catch (Exception e){
			PAD.debugLogError(CLASS_NAME, methodName, 'Exception ==> ' + e.getMessage());
		}
		PAD.debugLogInfo(CLASS_NAME, methodName, 'END');
		return opptsToUpdate;
	}
}