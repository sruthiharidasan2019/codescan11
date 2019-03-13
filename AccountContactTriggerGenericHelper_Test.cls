/******************************************************************************** 
* This test class covers the below classes:
* 1. AccountContactTriggerGenericHelper  
*********************************************************************************/
@isTest(seeAllData=False)
public class AccountContactTriggerGenericHelper_Test {

    @testSetup
    public static void testData(){
        MasterCustomSetting_Test.customSettings();
        
        List<Account> accountLst = new List<Account>();
        List<Contact> contactLst = new List<Contact>();
        List<AccountContactRelation> accountContactLst = new list<AccountContactRelation>();
        
        //create account
        Account acc = optimisationTestUtility.getAccountdetails('TestingAccount11',True,'Customer');
        acc.AccountNumber = '123456978';
        accountLst.add(acc);
        
        Account acc1 = optimisationTestUtility.getAccountdetails('TestingAccount22',True,'Prospect');
        acc1.AccountNumber = '65564';
        accountLst.add(acc1);

        insert accountLst;
        
        
        //create contact
        Contact con = optimisationTestUtility.getContactDetails(acc.id,'TestNameAcccon1','TestContact','Mr','TestMail123Con@tcs.com');
        con.tocContact_ID__c = 'conID12';
        contactLst.add(con);
        
        insert contactLst;
        
        
    }
    /***
     * Trigger : CheckPrimaryAndDuplicate
     * Trigger : ConAccountAssociateDeassociate
     * Trigger : createAndUpdateAccountContactHistory  
     */
    
    public static testMethod void testMethod1(){
        
        list<AccountContactRelation> accountContactLst = new list<AccountContactRelation>();
        
        Account acc = [select id from account where name = 'TestingAccount11'];
        Account acc1 = [select id from account where name ='TestingAccount22'];
        Contact con = [select id from contact where email = 'TestMail123Con@tcs.com'];
        AccountContactRelation acRelation = [select contactid,IsDirect, accountid from AccountContactRelation where contactid =: con.id and accountid =: acc.id];
        List<Contact_Function__c> conFunList = [Select id,account_id__c,Contact_Id__c from Contact_Function__c where Account_Id__c = :acc.id and Contact_Id__c =:con.id];
        
        con.accountid = acc1.id;
        
        Test.startTest();
        
            update con;
            delete conFunList;
            update acRelation;
            delete acRelation;
        
        Test.stopTest();
        
        AccountContactRelation acRelation1 = [select contactid,accountid from AccountContactRelation where contactid =: con.id and accountid =: acc1.id];
        system.assertEquals(acc1.Id, con.accountid);
        system.assertEquals(acc1.Id, acRelation1.AccountId);
    }
}