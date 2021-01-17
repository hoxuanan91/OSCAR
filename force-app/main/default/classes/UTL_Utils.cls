public class UTL_Utils {
    /** 
     * @author Aurélien Clerc
     * @date 18/03/2020
     * @param : String sObjectType, String devName
     * @Description : Get recordtype Id
     * @return Id
     */
    public static Id getRecordTypeID(String sObjectType, String devName){
        RecordType rT = Database.query('SELECT Id, DeveloperName FROM RecordType WHERE SObjectType =:sObjectType AND DeveloperName =:devName');
        return rT.Id;
    }
    
    /** 
     * @author Aurélien Clerc
     * @date 06/04/2020
     * @param : String sObjectType, String recordTypeId
     * @Description : Get recordtype Id
     * @return Id
     */
    public static String getRecordTypeDevName(String sObjectType, String recordTypeId){
        RecordType rT = Database.query('SELECT Id, DeveloperName FROM RecordType WHERE SObjectType =:sObjectType AND Id =:recordTypeId');
        return rT.DeveloperName;
    }
}