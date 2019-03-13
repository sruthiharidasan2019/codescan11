@isTest(SeeAlldata=true)
Private Class AATestSCQueueMembersStatusController{

Static testmethod void AATestSCQueueMembersStatusController(){
    Group grp = new Group(Name='Queue',Type='Queue');
     insert grp;
     Profile Prof = [SELECT Id FROM profile WHERE name='Helpdesk Agent']; 
     User Us =  New User(FirstName = 'James' , LastName= 'ThomasTest',Alias = 'jttest',Email='james.thomastest@thomsonreuters.com', emailencodingkey='UTF-8', 
     UserName='james.thomastest@thomsonreuters.com',languagelocalekey='en_US', localesidkey='en_US', 
     profileid = Prof.Id,timezonesidkey='America/Los_Angeles',CommunityNickname='James.ThomasTest',UserPermissionsLiveAgentUser=true,Last_Portal_Activity__c=system.now()+1);
     insert Us;
            
     UserData__c ud = new UserData__c();
     ud.QueueID__c = grp.Id;
     ud.Status__c = 'Active';    
     ud.Queue_Type1__c= 'Spec D&A';
     ud.Live_Chat_Queue__c = true;
     insert ud;
    
     Profile Prof1 = [SELECT Id FROM profile WHERE name='System Administrator']; 
     User Us1 =  New User(FirstName = 'James1' , LastName= 'ThomasTest1',Alias = 'jttest1',Email='james.thomastest1@thomsonreuters.com', emailencodingkey='UTF-8', 
     UserName='james.thomastest1@thomsonreuters.com',languagelocalekey='en_US', localesidkey='en_US', 
     profileid = Prof1.Id,timezonesidkey='America/Los_Angeles',CommunityNickname='James.ThomasTest1');
     insert Us1;
         
     System.runAs(Us1){     
     QueueSobject mappingObject2 = new QueueSobject(QueueId = grp.Id, SobjectType = 'Chat_Routing_Request__c ');
     insert mappingObject2;
     
     GroupMember oGroupMember = new GroupMember (GroupId = grp.ID ,  UserOrGroupId= Us.Id);
     insert oGroupMember;
     
    String QueueCursor =ApexPages.currentPage().getParameters().put('QueueCursor',grp.id);
    SCQueue_QueueMembers_StatusController  c = new SCQueue_QueueMembers_StatusController();
    SCQueue_QueueMembers_StatusController.UserData uu = new SCQueue_QueueMembers_StatusController.UserData();
    SCQueue_QueueMembers_StatusController.QueueData qd = new SCQueue_QueueMembers_StatusController.QueueData();
    c.temp ='All Queues';
    c.RefreshQueueData();
    c.DummyMethod();
     
    }
   }
}