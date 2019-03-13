/***************************************************************************************************
Class Name : AccountContactTriggerGenericHelper
Description : This class will handle the logic for all the AccountContact trigger which are common across projects
-----------------------------------------------------------------------------------------------------
Date             Author            Version            Comments
07/July/2017     Prateek Rawat         1.0                Initial Development
*****************************************************************************************************/
public class AccountContactTriggerGenericHelper {
    //initialise class variables
    public static map<String, trConstants__c> trConstantMap = new map<String, trConstants__c>();
    public static Set<String> trConstantset = new Set<String>();


    //static block
    static {
        trConstantMap = trConstants__c.getAll();

        //filter custom account team user (Trigger :ConAccountAssociateDeassociate)
        for (trConstants__c objConstant : trConstantMap.values()) {
            if (objConstant.name.contains('Custom_Account_Team_User')) {
                trConstantset.add(objConstant.Value__c);
            }
        }//end of for loop
    }

    /****************************************************************************************
    Functionalities Implemented:
    *******************************************************************************************/
    public static void genericBeforeInsert(List <SObject> newItems) {
        System.debug('$$$$$$$$$$$$$$$$$$ in AccountContactRelation genericBeforeInsert and  limit is ' + limits.getQueries());

    }//end of genericBeforeInsert

    /*****************************************************************************************************
    Functionalities Implemented:
    Trigger : ConAccountAssociateDeassociate : This is used to intimate a mail on Account Association
                                                with respect to Contact
    ******************************************************************************************************/
    public static void genericAfterInsert(Map<Id, SObject> newItems) {
        System.debug('$$$$ in AccountContactRelation after insert and  limit is ' + limits.getQueries());

        //initialise values
        String interfaceswitch = Label.CONTACT_INTERFACE;
        list<AccountContactRelation> accConRelLst = new list<AccountContactRelation>();

        list<AccountContactRelation> accConRelF = new list<AccountContactRelation>();// use to store  AccountContactRelation instance
        List<New_Contact_History__c> lstInsertAccContactInsert = new List<New_Contact_History__c>();
        //Traverse through each record
        for (AccountContactRelation accConRelRec : (list<AccountContactRelation>)newItems.values()) {

            //Add records to the list meeting the condition (Trigger: ConAccountAssociateDeassociate)
            if (interfaceswitch == 'ON' && !trConstantset.contains(accConRelRec.LastModifiedById)
                    && ((accConRelRec.ConPrimaryAccountANumber__c != null && accConRelRec.ConPrimaryAccountANumber__c != '')
                        || (accConRelRec.ContactCNumber__c != null && accConRelRec.ContactCNumber__c != '' ))) {

                accConRelLst.add(accConRelRec);
            }
            // Create New_Contact_History__c record when the relationship between Account and Contact
            //is removed trigger (createAndUpdateAccountContactHistory)
            if ( accConRelRec.Contactid != Null && accConRelRec.Accountid != Null ) {
                New_Contact_History__c insertNewContHistObj = new New_Contact_History__c();
                insertNewContHistObj.Name = accConRelRec.Account.Name;
                insertNewContHistObj.Account__c = accConRelRec.Accountid;
                insertNewContHistObj.Contact__c = accConRelRec.Contactid;
                insertNewContHistObj.Object__c = 'Contact Account';
                insertNewContHistObj.Primary_Account__c = accConRelRec.IsDirect;
                insertNewContHistObj.Type__c = 'Added';
                lstInsertAccContactInsert.add(insertNewContHistObj);
            }

            //adding individual value to list
            accConRelF.add(accConRelRec);

        }//end of for loop

        // trigger (createAndUpdateAccountContactHistory)
        if (lstInsertAccContactInsert != null && lstInsertAccContactInsert.size() > 0) {
            Database.insert(lstInsertAccContactInsert);
        }

        //Create Triggeer Object record ( Trigger : ConAccountAssociateDeassociate)
        if (accConRelLst != null && accConRelLst.size() > 0  ) {
            createTriggerObject(accConRelLst, 'Trigger Account Associate:>', 'New Account Id:>');
        }
        system.debug('We are here'+accConRelF);
        //AccountContactTriggerUtility.AccountContactPortalUser(accConRelF);
        // calling AccountContactTriggerUtility   class to create contact function while  insert operation
        AccountContactTriggerUtility.CreateFunction(accConRelF);
        // calling AccountContactTriggerUtility class to check uuid on contact
        AccountContactTriggerUtility.CheckUiidonContact(accConRelF);
    }//end of genericAfterInsert


    public static void genericBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('$$$$$$$$$$$ In AccountContactRelation generic Before Update and  limit is ' + limits.getQueries());

    }
    //End of Before Update

    /****************************************************************************************
    Functionalities Implemented:
    *******************************************************************************************/

    public static void genericAfterUpdate(Map<Id, SObject> newItems, Map<Id, Sobject> oldItems) {
        System.debug('$$$$ in AccountContactRelation after update and  limit is ' + limits.getQueries());
        //AccountContactTriggerUtility.AccountContactPortalUser((list<AccountContactRelation>)newItems.values());
        // calling AccountContactTriggerUtility class to create and delete contact function while  update  operation
        AccountContactTriggerUtility.UpdateCreateFunction((list<AccountContactRelation>)newItems.values());

        // calling AccountContactTriggerUtility class to check uuid during update operation
        AccountContactTriggerUtility.CheckUiidonContact((list<AccountContactRelation>)newItems.values());
        
        
        /**** Added by Project Revelation************/
        
        //initialise values
        String interfaceswitch = Label.CONTACT_INTERFACE;
        list<AccountContactRelation> accConRelLst = new list<AccountContactRelation>();
        
        //Traverse through each record 
        for(AccountContactRelation accConRelRec :(list<AccountContactRelation>)newItems.values()){
            
            //Add records to the list meeting the condition (Trigger: ConAccountAssociateDeassociate)
            if(interfaceswitch=='ON' && !trConstantset.contains(accConRelRec.LastModifiedById) 
               &&((accConRelRec.ConPrimaryAccountANumber__c != null && accConRelRec.ConPrimaryAccountANumber__c != '') 
               ||(accConRelRec.ContactCNumber__c != null && accConRelRec.ContactCNumber__c != '' ))){
                    
               accConRelLst.add(accConRelRec);
            }
            //ended by project revelation
         
        }//end of for loop
        
       
     //Create Triggeer Object record ( Trigger : ConAccountAssociateDeassociate)
        if(accConRelLst!=null && accConRelLst.size()>0  ){
            createTriggerObject(accConRelLst,'Trigger Account Associate:>','New Account Id:>');
        }
        
    }
    //END  of genericAfterUpdate
    /****************************************************************************************************************
    Functionalities Implemented:
    1. (Trigger : createAndUpdateAccountContactHistory) : insert records on ‘New_Contact_History__c ’
                                                          object on creation of data on AccountContactRelation
    2. (Trigger : ConAccountAssociateDeassociate)       : This is used to intimate a mail on Account Desaccociation
                                                          with respect to Contact
    *****************************************************************************************************************/

    public static void genericAfterDelete(Map<Id, SObject> oldItems) {

        System.debug('$$$$ in AccountContactRelation after delete and  limit is ' + limits.getQueries());

        //Initializing variables
        List<New_Contact_History__c> lstDeleteAccContactInsert = new List<New_Contact_History__c>();
        list<AccountContactRelation> accConRelLst = new list<AccountContactRelation>();
        String interfaceswitch = Label.CONTACT_INTERFACE;

        //traverse throug each loop
        for (AccountContactRelation accConRelRec : (List<AccountContactRelation>)oldItems.values()) {

            // Create New_Contact_History__c record when the relationship between Account and Contact
            //is removed trigger (createAndUpdateAccountContactHistory)
            if ( accConRelRec.Contactid != Null && accConRelRec.Accountid != Null ) {
                New_Contact_History__c delNewContHistObj = new New_Contact_History__c();
                delNewContHistObj.Name = accConRelRec.Account.Name;
                delNewContHistObj.Account__c = accConRelRec.Accountid;
                delNewContHistObj.Contact__c = accConRelRec.Contactid;
                delNewContHistObj.Object__c = 'Contact Account';
                delNewContHistObj.Primary_Account__c = accConRelRec.IsDirect;
                delNewContHistObj.Type__c = 'Deleted';
                lstDeleteAccContactInsert.add(delNewContHistObj);
            }

            //Filter the records meeting the conditions Trigger : ConAccountAssociateDeassociate
            if (interfaceswitch == 'ON' && !trConstantset.contains(TriggerUtility.getUserRecord().id) &&
                    ((accConRelRec.ConPrimaryAccountANumber__c != null && accConRelRec.ConPrimaryAccountANumber__c != '') ||
                     (accConRelRec.ContactCNumber__c != null && accConRelRec.ContactCNumber__c != ''))) {
                accConRelLst.add(accConRelRec);
            }
        }//end of for loop

        // trigger (createAndUpdateAccountContactHistory)
        if (lstDeleteAccContactInsert != null && lstDeleteAccContactInsert.size() > 0) {
            Database.insert(lstDeleteAccContactInsert);
        }

        //Trigger : ConAccountAssociateDeassociate
        if (accConRelLst != null && accConRelLst.size() > 0) {
            createTriggerObject(accConRelLst, 'Trigger Account DeAssociate:>', 'Deleted Account Id:>');
        }


    }//END  of genericAfterDelete
    /************************************************************************************************************
    Functionalities Implemented:
    (Trigger : CheckPrimaryAndDuplicate): primary flag and checks on delete operationIf the record has associated Contact Function , then prevent deletion of the relationship
                                         between Account and Contact
    ***************************************************************************************************************/

    public static void genericBeforeDelete(Map<Id, SObject> oldItems) {

        System.debug('$$$$ in AccountContactRelation before delete and  limit is ' + limits.getQueries());

        //Initializing variables
        List<Contact_Function__c> lstOfContactFunction = new List<Contact_Function__c>();
        Set<id> setOfAccountId = new Set<id>();
        Set<id> setOfContactId =  new Set<id>();
        Set<String> setOfConAcc = new Set<String>();

        //traverse through each loop
        for (AccountContactRelation accConToIterate : (List<AccountContactRelation>)oldItems.values()) {

            //trigger : CheckPrimaryAndDuplicate
            setOfAccountId.add(accConToIterate.accountid);
            setOfContactId.add(accConToIterate.contactid);

            //Check on Primary Flag trigger : CheckPrimaryAndDuplicate
            if (accConToIterate.IsDirect) {
                accConToIterate.addError(label.Account_Contact_Relation_Cannot_Delete);
            }

        }//end of for loop

        //If the record has associated Contact Function , then prevent deletion of the relationship
        //between Account and Contact (Trigger : CheckPrimaryAndDuplicate)
        if (!setOfAccountId.isEmpty() && !setOfContactId.isEmpty()) {
            lstOfContactFunction = AccountContactTriggerUtility.getContactFunctionList(setOfAccountId, setOfContactId);

            if (!lstOfContactFunction.isEmpty()) {
                for (Contact_Function__c conFuncToItrate : lstOfContactFunction) {
                    setOfConAcc.add(conFuncToItrate.account_id__c + '#' + conFuncToItrate.contact_id__c);
                }
            }
        }

        //traverse through each record
        for (AccountContactRelation accConToIterate : (List<AccountContactRelation>)oldItems.values()) {

            //Prevent deletion of Record (Trigger : CheckPrimaryAndDuplicate)
            if (!setOfConAcc.isEmpty()) {
                if (setOfConAcc.contains(accConToIterate.accountid + '#' + accConToIterate.contactid)) {
                    accConToIterate.addError(label.Account_Contact_Relation_Cannot_Removed);
                }
            }
        }


    }//END  of genericBeforeDelete

    /*******************************************************************************************************************************
    Purpose     : To create Trigger_Object__c records after insert/delete of AccountContactRelation records
    Parameters  : subject ,body, list of AccountContactRelation records
    Returns     : void
    Call from   : genericAfterInsert and genericAfterDelete
    *********************************************************************************************************************************/
    public static void createTriggerObject(list<AccountContactRelation> accConRelLst, String subject, String body) {

        System.debug('In Create Trigger Objects');
        //initialise values
        list<Trigger_Object__c> triggerObjectLst = new list<Trigger_Object__c>();

        //Traverse through each record
        for (AccountContactRelation accConRelRec : accConRelLst) {

            //create Trigger_Object__c record
            Trigger_Object__c triggerObj = new Trigger_Object__c();
            triggerObj.Subject__c = subject + accConRelRec.contactId;
            triggerObj.Body_Text__c = body + accConRelRec.id;
            triggerObj.Object_Name__c = 'Contact Account';
            triggerObj.Object_Id__c = accConRelRec.contactId;
            triggerObjectLst.add(triggerObj);

        }//end of for loop

        if (triggerObjectLst != null && triggerObjectLst.size() > 0) {
            System.debug('In Create Trigger Objeect' + triggerObjectLst);
            insert triggerObjectLst;
        }
    }//end of createTriggerObject method

}