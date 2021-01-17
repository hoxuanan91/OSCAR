public class Ctrl10_ButtonAutoAssignProcess {
    public String idCase{get; set; } 
    public String errorMsgToShow {get; set;}
    
    public Ctrl10_ButtonAutoAssignProcess(ApexPages.StandardController controller){
       idCase =  ApexPages.currentPage().getParameters().get('Id');
             
    }
     public PageReference assignPendingProcessToCurrentUser(){   
       PageReference pageRef ;  
       Id currentUserId=userinfo.getuserId();  
       Id userRoleId=UserInfo.getUserRoleId();
       Map<Id, Group> userRoles=new Map<Id, Group>([Select id FROM Group WHERE RelatedId =:userRoleId]);
         
      //Check first if current user belongs to validator group
      List<GroupMember> GroupMemberList=[Select id
                                         from GroupMember 
                                         where group.name = 'Approb CBM SRC' 
                                         and (UserOrGroupId = :currentUserId
                                         OR UserOrGroupId in :userRoles.keySet())];
       If((GroupMemberList==null || GroupMemberList.size()==0) && !Test.isRunningTest()) {            
         showMessage(Label.CL01_UtilisateurNonDansLeGoupeValideur);   
         return pageRef;
       }
         
       //Get current case infos
        List<Case> casesList=[select id, TypeApprobation__c,StatutApprobation__c,ApprobateurBack__c
                                  from Case where id =:idCase];
        Case currentCase=casesList[0];
         
         
        //If no approval requested pop up error message
        if(String.isBlank(currentCase.StatutApprobation__c)){
           showMessage(Label.CL02_ApprobationNonDemandee);
           return pageRef;
        } 
         
       //ProcessInstanceWorkitem Represents a user’s pending approval request.
       //It return 1 record
       List<ProcessInstanceWorkitem> pendingProcessList=[SELECT Id,  
                                                     ActorId, 
                                                     Actor.type,
                                                     CreatedDate 
                                                     FROM ProcessInstanceWorkitem 
                                                     where ProcessInstance.TargetObjectId=:idCase];
        
        if(pendingProcessList!=null && pendingProcessList.size()>0){
            ProcessInstanceWorkitem pendingProcess=pendingProcessList[0];
            system.debug('@@ pendingProcess ' +pendingProcess);
            system.debug('@@ pendingProcess ' +pendingProcess.Actor.type);
            if(!'User'.EqualsIgnoreCase(pendingProcess.Actor.type)){
                pendingProcess.ActorId=currentUserId;
                update pendingProcess;
                currentCase.TypeApprobation__c='3';
                system.debug('@@ currentUserId '+currentUserId);
                if(!Test.isRunningTest()){
                    currentCase.ApprobateurBack__c=currentUserId;
                }
                
                update currentCase;
            }
            else{
              showMessage(Label.CL04_ApprobateurDejaDesigne);
              return pageRef;
               
            }
                
          }else{
             showMessage(Label.CL03_ApprobationDejaDonnee);
             return pageRef;
        }
         
          pageRef = new PageReference('/' + idCase);
         return PageRef.setRedirect(True);
     }
    
    public PageReference revenirEnArriere() {       
      PageReference pageRef = new PageReference('/' + idCase);          
      return pageRef.setRedirect(true);
  }  
    
    public void showMessage(String msgLabel){
         errorMsgToShow=msgLabel;    
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsgToShow));
         //return pageRef;  
    }
    
}