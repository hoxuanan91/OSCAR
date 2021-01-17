global class BA001Scheduler implements Schedulable{
    
    global void execute(SchedulableContext sc){
    
        List<ID> RecordTypeId = new List<ID>(); 
        
        ID RT_ActionRecourvrement = (ID)(DAL.getRecordType('Case')).get('CBM_Actions_de_Recouvrement');
        ID RT_ImpayevoirPostReal = (ID)(DAL.getRecordType('Case')).get('CBM_Impaye_et_avoir_Post_Real');
        ID RT_AppelFondsRecouvrer = (ID)(DAL.getRecordType('Case')).get('CBM_Appel_de_fonds_recouvrer');
        
        RecordTypeId.add(RT_ActionRecourvrement);
        RecordTypeId.add(RT_ImpayevoirPostReal);
        RecordTypeId.add(RT_ActionRecourvrement);
        
        String query = 'Select Id from Case where RecordTypeId = \'' + RT_ActionRecourvrement + '\' or RecordTypeId = \'' + RT_ImpayevoirPostReal + '\' or RecordTypeId = \'' + RT_AppelFondsRecouvrer + '\'';
        
        Database.executeBatch(new BA001CalculateReamenagementEnCours(query));

    }
}