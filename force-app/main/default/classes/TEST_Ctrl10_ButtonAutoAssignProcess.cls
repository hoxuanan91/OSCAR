@isTest
public  class TEST_Ctrl10_ButtonAutoAssignProcess {
     
    @testSetup static void setup() {
          
      Map<String,Id> RTs = DAL.getRecordType('Case');                     
		Group approvers = new Group( Type='Queue',Name = 'Approb CBM SRC');
		insert approvers;        
		User u = TestFactory.createUser();
      
		Account acc = TestFactory.createAccount('testAcc');
		insert acc;

		Contract ctr = TestFactory.createContract(acc.Id);
		insert ctr;            

		Case caseWithApproval = TestFactory.createCase(ctr.Id, 'A prendre en charge');
		caseWithApproval.recordTypeId = (ID)RTs.get('CBM_Mise_en_place');
		caseWithApproval.TypeApprobation__c = '1';
        
        Case caseWithoutApproval = TestFactory.createCase(ctr.Id, 'A prendre en charge');
		caseWithoutApproval.recordTypeId = (ID)RTs.get('CBM_Mise_en_place');
		//caseWithApproval.TypeApprobation__c ;
		List<Case> caseList= new List<Case>();
        caseList.add(caseWithApproval);
        caseList.add(caseWithoutApproval);
		insert caseList;
              
    }
     
    static testMethod void testApproveurDejaDesigne(){
		
		Case caseWithApproval = [select id,TypeApprobation__c from case where TypeApprobation__c!=null ];
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(caseWithApproval.id);
		//app.setSubmitterId(approversGroup.id);
		Approval.ProcessResult result = Approval.process(app);
        System.assert(result.isSuccess());		     
		  
		List<ProcessInstanceWorkitem> pendingProcessList=[SELECT Id,  
									 ActorId, 
									 Actor.type,
									 CreatedDate 
									 FROM ProcessInstanceWorkitem 
									 where ProcessInstance.TargetObjectId=:caseWithApproval.id];

        Group approversGroup = [select id,type from group where name='Approb CBM SRC' limit 1] ;
        ProcessInstanceWorkitem currentPendingProcess=pendingProcessList[0];            
        currentPendingProcess.ActorId=  approversGroup.id; 
        update currentPendingProcess;
        Test.StartTest();    
		PageReference aPage = Page.VFP10_ButtonAutoAssignProcess;
		aPage.getParameters().put('Id',caseWithApproval.id);
		test.setCurrentPage(aPage);
        
		ApexPages.StandardController controller = new ApexPages.StandardController(caseWithApproval);
		Ctrl10_ButtonAutoAssignProcess btnController = new Ctrl10_ButtonAutoAssignProcess(controller);
		btnController.assignPendingProcessToCurrentUser();
		//ApexPages.Message[] pageMessages = ApexPages.getMessages();
		//System.assertEquals(1, pageMessages.size());		//
		//ApexPages.Message currentMsg=pageMessages[0];
		//System.assertEquals(currentMsg.getSummary(), Label.CL04_ApprobateurDejaDesigne);
		//btnController.revenirEnArriere();
		Test.StopTest();

	}
  static testMethod void testApproveurDejaDonnee(){
		
         Case caseWithoutApproval = [select id,TypeApprobation__c from case where TypeApprobation__c!=null ];
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(caseWithoutApproval.id);
		//app.setSubmitterId(approversGroup.id);
		Approval.ProcessResult result = Approval.process(app);
         List<Id> newWorkItemIds = result.getNewWorkitemIds();

		// Instantiate the new ProcessWorkitemRequest object and populate it
		Approval.ProcessWorkitemRequest req2 = 
		new Approval.ProcessWorkitemRequest();
		req2.setComments('Approving request.');
		req2.setAction('Approve');
		//req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

		// Use the ID from the newly created item to specify the item to be worked
		req2.setWorkitemId(newWorkItemIds.get(0));

		// Submit the request for approval
		Approval.ProcessResult result2 =  Approval.process(req2);
		Test.StartTest();
		
        PageReference aPage = Page.VFP10_ButtonAutoAssignProcess;
		aPage.getParameters().put('Id',caseWithoutApproval.id);
		test.setCurrentPage(aPage);
        
		ApexPages.StandardController controller = new ApexPages.StandardController(caseWithoutApproval);
		Ctrl10_ButtonAutoAssignProcess btnController = new Ctrl10_ButtonAutoAssignProcess(controller);
		btnController.assignPendingProcessToCurrentUser();
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(1, pageMessages.size());

		ApexPages.Message currentMsg=pageMessages[0];
		System.assertEquals(currentMsg.getSummary(), Label.CL03_ApprobationDejaDonnee);		
        btnController.revenirEnArriere();
		Test.StopTest();

	}
    
 
     static testMethod void testApprobationNonDemander(){
		
        Case caseWithoutApproval = [select id,TypeApprobation__c from case where TypeApprobation__c!=null ];
       
		Test.StartTest();
		
        PageReference aPage = Page.VFP10_ButtonAutoAssignProcess;
		aPage.getParameters().put('Id',caseWithoutApproval.id);
		test.setCurrentPage(aPage);
        
		ApexPages.StandardController controller = new ApexPages.StandardController(caseWithoutApproval);
		Ctrl10_ButtonAutoAssignProcess btnController = new Ctrl10_ButtonAutoAssignProcess(controller);
		btnController.assignPendingProcessToCurrentUser();
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(1, pageMessages.size());

		ApexPages.Message currentMsg=pageMessages[0];
		System.assertEquals(currentMsg.getSummary(), Label.CL02_ApprobationNonDemandee);		
        btnController.revenirEnArriere();
		Test.StopTest();

 
     } 
    
}