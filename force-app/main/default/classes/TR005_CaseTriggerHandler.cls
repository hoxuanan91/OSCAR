public class TR005_CaseTriggerHandler{
	private static final String CLASS_NAME = TR005_CaseTriggerHandler.class.getName();
	public static void onAfterInsert(List<Case> newCases){
		String methodName = 'onAfterInsert';
		PAD.debugLogInfo(CLASS_NAME, methodName, 'BEGIN');
		doActionCaseAON(newCases);
		PAD.debugLogInfo(CLASS_NAME, methodName, 'END');
	}

	private static Set<Id> recordTypesIdOpportunityAON;
	private static Set<Id> recordTypesIdCaseAON;

	/**
	 * DHMOSCAR-1585
	 * Author : AN
	 * Created date : 14/01/2021
	 * Do action when a new AON case create
	 */
	private static List<Case> doActionCaseAON(List<Case> iCases){
		String methodName = 'doActionCaseAON';
		PAD.debugLogInfo(CLASS_NAME, methodName, 'BEGIN');
		PAD.debugLogInfo(CLASS_NAME, methodName, 'iCases : ' + iCases);
		List<Case> oCasesToUpdate = null;

		if (iCases == null){
			return null;
		}

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

		if (recordTypesIdCaseAON == null){
			recordTypesIdCaseAON = new Set<Id>();
			List<RecordType> recordTypesCaseAON = [SELECT ID, IsActive, DeveloperName, SobjectType
			                                              FROM RecordType
			                                              WHERE SobjectType = 'Case' AND IsActive = true AND DeveloperName = 'CBM_Mise_en_place' ];
			PAD.debugLogInfo(CLASS_NAME, methodName, 'recordTypesIdCaseAON ==> ' + recordTypesIdCaseAON);

			if (recordTypesCaseAON == null){
				return null;
			}
			for (RecordType rT : recordTypesCaseAON){
				recordTypesIdCaseAON.add(rT.ID);
			}
		}

		/**
		 * get opportunity Id from Case
		 */
		Map<ID, Case> opptIdsByCase = new Map<ID, Case>();
		Set<ID> opptIdsInCase = new Set<ID>();
		for (Case newCase : iCases){
			PAD.debugLogInfo(CLASS_NAME, methodName, 'newCase.ProjetAssocie__c : ' + newCase.ProjetAssocie__c);
			PAD.debugLogInfo(CLASS_NAME, methodName, 'newCase.RecordTypeId : ' + newCase.RecordTypeId);

			if (newCase.ProjetAssocie__c != null && recordTypesIdCaseAON.contains(newCase.RecordTypeId) ){
				opptIdsInCase.add(newCase.ProjetAssocie__c);
				opptIdsByCase.put(newCase.ProjetAssocie__c, newCase);
			}
		}
		PAD.debugLogInfo(CLASS_NAME, methodName, 'opptIdsInCase : ' + opptIdsInCase);

		if (opptIdsInCase.isEmpty()){
			return null;
		}

		List<Opportunity> opptsAON = [SELECT ID, StatutGlobalAON__c
		                              FROM Opportunity
		                              WHERE ID IN :opptIdsInCase AND RecordTypeId IN :recordTypesIdOpportunityAON  AND (StatutGlobalAON__c = 'Accepte' OR StatutGlobalAON__c = 'Refuse')];

		PAD.debugLogInfo(CLASS_NAME, methodName, 'opptsAON : ' + opptsAON);

		if (opptsAON == null){
			return null;
		}

		Map<ID, String> opptIdsByStatus = new Map<ID, String>();

		for (Opportunity o : opptsAON){
			opptIdsByStatus.put(o.ID, o.StatutGlobalAON__c);
		}

		Map<ID, String> caseIdByStatus = new Map<ID, String>();

		for (Case c : iCases){
			if (opptIdsByStatus.containsKey(c.ProjetAssocie__c)){
				caseIdByStatus.put(c.ID, opptIdsByStatus.get(c.ProjetAssocie__c));
			}
		}

		PAD.debugLogInfo(CLASS_NAME, methodName, 'caseIdByStatus : ' + caseIdByStatus);

		if (caseIdByStatus.isEmpty()){
			return null;
		}

		oCasesToUpdate = [SELECT ID, OWNER.ID, OWNER.EMAIL
		                  FROM CASE
		                  WHERE ID IN :caseIdByStatus.keySet()];

		for (Case c : oCasesToUpdate){
			if (caseIdByStatus.get(c.ID) == 'Accepte'){
				c.PresenceAssuranceAON__c = true;
				c.ControleAssuranceAONFaitLe__c = System.Today();
			}
			if (caseIdByStatus.get(c.ID) == 'Refuse'){
				c.PresenceAssuranceAON__c = false;
				c.ControleAssuranceAONFaitLe__c = null;
			}
		}

		PAD.debugLogInfo(CLASS_NAME, methodName, 'oCasesToUpdate : ' + oCasesToUpdate);

		update oCasesToUpdate;
		return oCasesToUpdate;
	}
}