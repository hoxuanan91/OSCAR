public class AP15User {
    @Future
    public static void updateUniteSrcFromCase(Set<Id> usersIds) {
        Map<Id, User> userByIds = new Map<Id, User>();
        List<Case> casesListToUpdate = new List<Case>();
        
        for (User newUser : [SELECT Id, UniteSrc__c FROM User WHERE Id IN: usersIds]) {
            userByIds.put(newUser.Id, newUser);
        }
        for (Case c : [SELECT Id, UniteSRC__c, OwnerId FROM Case WHERE OwnerId IN: usersIds AND IsClosed=false]) {
            String newUniteSrc = userByIds.get(c.OwnerId).UniteSRC__c;
            system.debug('@@newUniteSrc: ' + newUniteSrc);
            system.debug('@@c.UniteSRC__c: ' + c.UniteSRC__c);
            if (c.UniteSRC__c != newUniteSrc) {
                c.UniteSRC__c = newUniteSrc;
                casesListToUpdate.add(c);   
            }
        }
        
        if (casesListToUpdate.size() > 0) {
            update casesListToUpdate;
        }
    }
}