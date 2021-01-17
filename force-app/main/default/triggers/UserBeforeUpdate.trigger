trigger UserBeforeUpdate on User (before update) {
    /*if(PAD.scriptIsStarted('UserBeforeUpdate')) {
        if (!Test.isRunningTest()) {
            return;
        }
    }
    if(!PAD.canTrigger('UserBeforeUpdate')) {
        return;
    }*/
    
    Map<Id, User> userByIds = new Map<Id, User>();
    Map<Id, UserRole> userRoleByIds = new Map<Id, UserRole>([SELECT Id, Developername FROM UserRole]);
    
    for (User oldUser : Trigger.old) {
        User newUser = Trigger.newMap.get(oldUser.Id);
        system.debug('@@oldUser: ' + oldUser.UserRoleId);
        system.debug('@@newUser: ' + newUser.UserRoleId);
        if (oldUser.CodeDelegationRegionale__c == newUser.CodeDelegationRegionale__c &&
            oldUser.UserRoleId != newUser.UserRoleId &&
            newUser.UserRoleId != null) {
                String newUserRoleDeveloperName = userRoleByIds.get(newUser.UserRoleId).Developername;
                
                if (newUserRoleDeveloperName.contains('CBMSRC1')) {
                    newUser.UniteSRC__c = '1';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('CBMSRC24')) {
                    newUser.UniteSRC__c = '2';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('CBMSRC3')) {
                    newUser.UniteSRC__c = '3';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('CBMSRCGC')) {
                    newUser.UniteSRC__c = '4';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('CBISRC1')) {
                    newUser.UniteSRC__c = '6';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('CBISRC24')) {
                    newUser.UniteSRC__c = '7';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('CBISRC3GC')) {
                    newUser.UniteSRC__c = '8';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('EngagementsBUs')) {
                    newUser.UniteSRC__c = '11';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('EngagementsInternationalGCProjets')) {
                    newUser.UniteSRC__c = '12';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('Risques')) {
                    newUser.UniteSRC__c = '13';
                    userByIds.put(newUser.Id, newUser);
                } else if (newUserRoleDeveloperName.contains('SSRC')) {
                    newUser.UniteSRC__c = '17';
                    userByIds.put(newUser.Id, newUser);
                }
            } 
        else if (oldUser.UniteSRC__c != newUser.UniteSRC__c) {
            userByIds.put(newUser.Id, newUser);
        }
    }
    if (userByIds.size() > 0) {
        AP15User.updateUniteSrcFromCase(userByIds.keyset());
    }
}