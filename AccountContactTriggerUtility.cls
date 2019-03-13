/***************************************************************************************************
Class Name : AccountContactTriggerUtility
Description : This is a utility class to hold all the utility methods across all triggers
-----------------------------------------------------------------------------------------------------
Date             Author            Version            Comments
7/12/2017        Ashwin M         1.0                Initial Development
*****************************************************************************************************/
public class AccountContactTriggerUtility {

    /*********************************************************************************************************************
    Purpose     : To retrieve list Contact_Function__c records
    Return type : list of Contact_Function__c records
    Call from   : AccountContactTriggerGenericHelper.genericBeforeDelete()
    **********************************************************************************************************************/
    public static list<Contact_Function__c> getContactFunctionList(set<id> setOfAccountId, set<id> setOfContactId) {
        list<Contact_Function__c> lstOfContactFunction = new list<Contact_Function__c>();
        lstOfContactFunction = [
                                   SELECT
                                   ID,   
                                   ACCOUNT_ID__C,   
                                   CONTACT_ID__C
                                   FROM
                                   CONTACT_FUNCTION__C
                                   WHERE
                                   ACCOUNT_ID__C   IN  :setOfAccountId
                                   AND CONTACT_ID__C   IN  :setOfContactId
                               ];
        return lstOfContactFunction;
    }

    /*******************************************************************


    Purpose     : Creating a contact function logic depending on Roles added on Account Contact Record Roles field for insert scenario
        Parameters  : Aclist
        Returns     : Void
    ********************************************************************/

    public Static Void CreateFunction(List<AccountContactRelation> Aclist ) {
        System.debug('@@@ in AccountContactRelation after insert and  limit is ' + limits.getQueries());

        try {
            //Declared a list to store contact functions to be added
            List<Contact_Function__c> CFlist = new List<Contact_Function__c>();
            //Declared a set to store custom labels of Roles
            set<string> contactOnBoardingRoles = new SET<String>();
            //Adding values stored in custom label
            contactOnBoardingRoles.addAll(Label.AccountContactRoles.split(';'));
            //Iterating over Account Contact trigger.new records
            for (AccountContactRelation ac : Aclist) {
                //Declared a set to store Roles from current trigger.new record
                SET<string> regions = new SET<string>();
                //Adding values of roles to set
                regions.AddAll(ac.Roles.split(';'));
                //Iterating to check whether the role stored in set is contained in custom label for the current record
                for (string s : contactOnBoardingRoles) {
                    if (regions.contains(s)) {
                        //If it contains the roles in custom label then preparing the contact function and adding it to list
                        CFlist.add(createNewCFRed(ac, s));
                    }
                }
            }
            Database.insert(CFlist, false);
        }

        Catch(Exception ex) {
            GenesisErrorHandlingFrameWork.LogError(null, 'contact Function', null, 'ex', null, null);
        }

    }


    /*******************************************************************
     Purpose     : //Deleting or Creating a contact function logic depending on Roles added or removed on Account Contact Record Roles field for update scenario
            Parameters  : Aclist
            Returns     : Void
        ********************************************************************/

    public Static Void UpdateCreateFunction(List<AccountContactRelation> Aclist) {
        System.debug('@@@ in AccountContactRelation after update and  limit is ' + limits.getQueries());
        try {
            //Declared a set to store custom labels of Roles
            set<string> contactOnBoardingRoles = new SET<String>();
            //Adding values stored in custom label
            contactOnBoardingRoles.addAll(Label.AccountContactRoles.split(';'));

            //Declared a map to store Roles and Account Contact
            MAP<String, LIST<AccountContactRelation >> goingtoDeleteContactFunMAP = new MAP<string, LIST<AccountContactRelation >>();
            //Declared a list to store to contact functions to be inserted
            List<Contact_Function__c> CFlist = new List<Contact_Function__c>();
            //Iterating over Account Contact trigger.new records
            for (AccountContactRelation ac : Aclist) {
                // functionality to delete & create new CF
                AccountContactRelation oldacmap = new AccountContactRelation();
                if (trigger.oldMap.containsKey(ac.id)) {
                    //Fetching the old version of the record to obtain old Account Contact Roles
                    oldacmap = (AccountContactRelation)trigger.oldMap.get(ac.id);
                    //Declared a string to store old Account Contact Roles
                    SET<string> oldCFRoles = new SET<string>();
                    //Declared a string to store new Account Contact Roles
                    SET<string> newCFRoles = new SET<string>();
                    if (oldacmap.Roles != null) {
                        //Adding old roles to a set
                        oldCFRoles.addAll(oldacmap.Roles.split(';'));
                    }
                    if (ac.Roles != null) {
                        //Adding new roles to a set
                        newCFRoles.addAll(ac.Roles.split(';'));
                    }
                    //Below logic is used to filter and add the role and Account Contact Object which needs to deleted
                    for (string s : contactOnBoardingRoles) {
                        if (oldCFRoles.contains(s) && !newCFRoles.contains(s)) {
                            if (goingtoDeleteContactFunMAP.containsKey(s)) {
                                LIST<AccountContactRelation> allCids = goingtoDeleteContactFunMAP.get(s);
                                allCids.add(ac);

                                goingtoDeleteContactFunMAP.put(s, allCids);
                            } else {


                                LIST<AccountContactRelation> allCids = new  LIST<AccountContactRelation>();
                                allCids.add(ac);
                                goingtoDeleteContactFunMAP.put(s, allCids);
                            }
                        } else  if (!oldCFRoles.contains(s) && newCFRoles.contains(s)) {
                            CFlist.add(createNewCFRed(ac, s));
                        }
                    }


                }
            }

//Query for deleting and inserting the records in update scenario

            if (!goingtoDeleteContactFunMAP.isEmpty()) {
                //Preparing a query by iterating over map prepared in previous filtering code above
                string deleteQuery = 'select id, Function__c from Contact_Function__c where ';
                for (string acrDstr : goingtoDeleteContactFunMAP.keySet() ) {
                    for (AccountContactRelation acrDelete : goingtoDeleteContactFunMAP.get(acrDstr)) {
                        deleteQuery += '( Contact_Id__c = \'' + acrDelete.contactId + '\' AND Account_id__c = \'' + acrDelete.accountId + '\' AND Function__c  =\'' + acrDstr + '\' ) OR ';
                    }
                }

                system.debug('Delete Query........   ' + deleteQuery.subString(0, deleteQuery.lastIndexOf('OR')));

                LIST<Contact_Function__c> deleteCFRec = Database.query(deleteQuery.subString(0, deleteQuery.lastIndexOf('OR')));
                database.delete(deleteCFRec , FALSE);

            }
            // Insert new CF Record in update scenario
            Database.insert(CFlist, false);

        }
        Catch(Exception ex) {
            GenesisErrorHandlingFrameWork.LogError(null, 'contact Function', null, 'ex', null, null);
        }

    }

//Common code to insert a record in insert and update scenario

    public static Contact_Function__c createNewCFRed(AccountContactRelation acr, string roleFun) {
        Contact_Function__c cf = new Contact_Function__c();
        cf.Account_Id__c = acr.Accountid;
        System.debug('acr.Accountid' + acr.Accountid);
        cf.Contact_Id__c = acr.Contactid;
        System.debug('acr.Contactid' + acr.Contactid);
        cf.Function__c = roleFun;
        return cf;
    }

    /*******************************************************************
    Purpose     : //This method is used to check UUid on Contact while creating contact function
        Parameters  : Aclist
        Returns     : Void
    ********************************************************************/

    Public Static void CheckUiidonContact(List<AccountContactRelation> aclist) {
        System.debug('$$$$ in CheckUiidonContact after insert and  update and  limit is ' + limits.getQueries());
        //Set<Contact_Function__c> myset = new Set<Contact_Function__c>();//
        Set<Contact_Function__c>conlist = new Set<Contact_Function__c>(); // define to remove duplicate record
        List<Contact_Function__c> result = new List<Contact_Function__c>();//define to add set to list
        String objectid;
        try {
            Set<id> cid = new Set<id>(); //to get all contactid
            Set<id> acid = new Set<id>(); //to get all accountid
            for (AccountContactRelation ac : aclist) {

                System.debug('before if bolock ac.Contact_UUID__c' + ac.Contact_UUID__c);
                if (ac.Contact_UUID__c == null || ac.Contact_UUID__c == '') {

                    System.debug('inside if block ac.Contact_UUID__c' + ac.Contact_UUID__c);
                    cid.add(ac.contactid);
                    acid.add(ac.Accountid);

                }

            }

            List<Contact_Function__c> assocaiteConFunRec = [
                                                                SELECT
                                                                id, 
                                                                function__c, 
                                                                Contact_Id__r.Account.Id, 
                                                                Contact_Id__r.Account.Name, 
                                                                Contact_Id__r.Account.AccountNumber, 
                                                                Contact_Id__r.id, 
                                                                Contact_Id__c
                                                                FROM
                                                                Contact_Function__c
                                                                WHERE
                                                                Account_Id__c in: acid AND Contact_Id__c in: cid AND (function__c = 'Solution Fulfiller' OR function__c = 'Content Approver')
                                                            ];
//List<Contact_Function__c>conlist =new List<Contact_Function__c>();
            Map<Id, List<Contact_Function__c>> conFunMap = new Map<Id, List<Contact_Function__c>>();
            for (Contact_Function__c cf : assocaiteConFunRec) {
                if (!conFunMap.containsKey(cf.Contact_Id__c)) {
                    conFunMap.put(cf.Contact_Id__c, new List<Contact_Function__c>());
                }
                conFunMap.get(cf.Contact_Id__c).add(cf);

            }
            System.debug('conFaunMap++++' + conFunMap);
            for (Contact_Function__c cf : assocaiteConFunRec) {
                List<Contact_Function__c> conflist = conFunMap.get(cf.Contact_Id__r.id);
                System.debug('conflist++++' + conflist);

                for (Integer i = 0; i < conflist.size(); i++) {
                    conlist.add(conflist[0]);
                    System.debug('conflist[0]' + conflist[0]);
                    objectid = conflist[0].id;
                }
            }

            result.addAll(conlist);
            System.debug('result' + result);

            ContactFunctionTriggerHelper.createTriggerObjectRec('Trigger Function Associate:>', 'New Contact Function ID:>', 'Contact Function', result);
            System.debug('list of contact function send' + result);
        }
        Catch(Exception ex) {
            GenesisErrorHandlingFrameWork.LogError(objectid, 'contact Function', 'AAA', 'ex', null, null);
        }


    }
    
    
    /*******************************************************************
        Purpose     : Creating a portal user on creation of account contact relation record after adding roles
        Parameters  : aclist
        Returns     : Void
    ********************************************************************/
    
    /*   public Static Void AccountContactPortalUser(List<AccountContactRelation> Aclst ) {
       

        try {
            
            List<User> usrList=new List<User>();
            set<id> conIdSet=new set<id>(); //To store contact id
            List<User> lstportalUsers = new List<User>(); //To store users
            MAP<id,String> mapForConAccRegion = new MAP<id,String>();
            String Region;
            
            List<AccountContactRelation> acList = new List<AccountContactRelation>();
            List<String> addressDetails;
            
            set<string> contactOnBoardingRoles = new set<String>();
            contactOnBoardingRoles.addAll(Label.AccountContactRoles.split(';'));
           
            for (AccountContactRelation ac : Aclst) {
                
                SET<string> acRoles = new SET<string>();
                acRoles.AddAll(ac.Roles.split(';'));
                
                 system.debug('@@@@@regions'+acRoles);
                 
                 if (acRoles != null && (acRoles.contains((new list<string>(contactOnBoardingRoles) )[0] ) || acRoles.contains((new list<string>(contactOnBoardingRoles) )[1] ))) 
                {
                       
                       acList.add(ac);
                }
             
            }
 
            String tppProfile = Label.tppProfileName;
            Profile tppProfDetails = [Select Id, Name From Profile where name =:tppProfile ];
            system.debug('Profile'+tppProfDetails);
             
            for(AccountContactRelation acc : acList ){
            
            conIdSet.add(acc.Contactid);
            
            }
            
            System.debug('@@@@Contactid Set'+conIdSet);
            
            if (conIdSet.size() > 0) {
            lstportalUsers = [select id
                              ,IsPortalEnabled
                              ,Contactid
                              from
                              user
                              where
                              Contactid = :conIdSet];
        }
        
         
         System.debug('@@@@lstportalUsers@@size'+ lstportalUsers.size());
             List<contact> conRoles= new   List<contact>();
        if (conIdSet.size() > 0) {
            conRoles = [select
                              id,
                              tocAccountRegion__c                              
                              
                              from
                              contact
                              where
                              id = :conIdSet];

        }
        
        if (conRoles.size() > 0) {
            for (contact con : conRoles ) {
                if (con != null) {
                    mapForConAccRegion.put(con.Id, con.tocAccountRegion__c);
                }
            }

        }
        

        if(lstportalUsers.size()==0){
        
        for(AccountContactRelation ac : acList )
            {
            
                User usr = new User();
                String firstName = ac.Contact_First_Name__c;
                String lastName = ac.Contact_Last_Name__c;
                String email = ac.Contact_Email__c;
                String uniqueUserName = 'user' + DateTime.now().getTime() + ac.Contact_Email__c;
                Integer intFName = 1, intLName = 1,index ;
                String userAlias = '';
                index = email.indexOf('@');
                
                IF (ac.Contact_First_Name__c!= null && ac.Contact_Last_Name__c!= null)
                    userAlias = ac.Contact_First_Name__c.substring(0, intFName)+ ac.Contact_Last_Name__c.substring(0, intLName);
                ELSE 
                    userAlias = lastName.substring(0, intLName);
                    
                Database.DMLOptions dlo = new Database.DMLOptions(); 
                dlo.EmailHeader.triggerUserEmail= false; 

                
                usr.Alias = userAlias;
                system.debug('here3'+firstName+lastName);
                usr.Username = email.substring(0,index) + '_TRP'+email.substring(index);
                usr.email = email;
                usr.emailencodingkey = 'ISO-8859-1';
                usr.ContactId = ac.Contactid;
                usr.localesidkey = 'en_US';
                usr.languagelocalekey = 'en_US';
                usr.timezonesidkey = 'America/Los_Angeles';
                usr.firstname = firstName;
                usr.lastname = lastName;
                usr.isActive = true;
                usr.profileId = tppProfDetails.Id;
                usr.last_portal_activity__c = system.now();
                
                system.debug('here ac.ContactShippingAddress__c'+ac.ContactShippingAddress__c);
             
                if(ac.ContactShippingAddress__c != null ){

                addressDetails = ac.ContactShippingAddress__c.split(',');
                
                system.debug('here addressDetails '+addressDetails );


                 }
             
            
           if(addressDetails.size() > 0 &&  addressDetails.size() == 5 ){

                usr.Street= addressDetails.get(0);
                usr.City = addressDetails.get(1);
                usr.State = addressDetails.get(2);
                usr.PostalCode = addressDetails.get(3);
                
                usr.Country = addressDetails.get(4);
                usr.Country__c = addressDetails.get(4);



            }
            
              
               
           if (mapForConAccRegion.containsKey(ac.Contactid)) {
           
            Region= mapForConAccRegion.get(ac.Contactid);
            system.debug('here Region'+Region);
            usr.Role_Group__c =Region;
            
            } 

            usr.setOptions(dlo);
               
           
            usrList.add(usr);
            
            
            }
        }

     if(!usrList.isEmpty()){
     
     insert usrList;
     
    }
    
}Catch(Exception ex) {
           GenesisErrorHandlingFrameWork.LogError(null, 'Portal User Creation', null, 'ex', null, null);
        }

} */
}