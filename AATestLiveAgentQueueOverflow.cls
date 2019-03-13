@isTest
Private Class AATestLiveAgentQueueOverflow{

     static testmethod void AATestLiveAgentQueueOverflow(){        
    
        test.startTest();
        
        system.runas(new User(Id = UserInfo.getUserId())){
        Group grp;
       
         grp = new Group(Name='Test Queue',Type='Queue');
         insert grp;
        QueueSobject mappingObject2 = new QueueSobject(QueueId = grp.Id, SobjectType = 'Chat_Routing_Request__c');
        insert mappingObject2 ;
        
        //Group pg=[select name,id,Type from Group where Type='Queue' limit 1];
        Chat_Routing_Request__c cr = new Chat_Routing_Request__c();
        cr.isRouted__c=true;
        cr.ChatKey__c='2a2ac3d1-a8b1-4e2e-913f-8550e69ac16b';
        cr.Chat_Transcript_Status__c='New';
        cr.OwnerId=grp.Id;
        insert cr;
        LiveAgent_DataSetup ld = new LiveAgent_DataSetup();
        ld.SetupAll();
        ld.SetOwnerChatRoutingRequest(ld.crr.Id,ld.liveagentqueues[0].Id);
        
        LiveAgentQueueOverflow.ReassignChatRequests(); 
        }
        test.stopTest();
        
       }
}