public without sharing class AccController 
{
  transient public List<AccountWrapper> accSelectRec{get;set;}
  public List<Account> accData{get;set;}
  public List<AccountWrapper> accNewRec{get;set;}
  public String queryData{get;set;}
  public Boolean excessRowsError {get;set;}
  public String listSize {get;set;}
  public string previousSortField = '';
  public Boolean errMsge{get;set;}
  public string sortingOrder = '';
  public Boolean isAscending {get;set;}
  public string searchVal {get;set;}
  public string searchValTo {get;set;}
  public Boolean HideBlk {get;set;}
  public Boolean ShowBlk{get;set;} 
  public Boolean ShowNewBlk{get;set;} 
  public Boolean ShowErrorBlk{get;set;}
  public Boolean showCreateNew{get;set;}
  public List<User> conFuns= new List<User>();
  public List<User> conFunsTo= new List<User>();
  public string accId{get;set;}
  public string chkFrst{get;set;}
  public string chkFrstTwo{get;set;}
  public string chkFrstThree{get;set;}
  private String usrId;
  public String getUsrId() { return this.usrId; }
  public void setUsrId(String el) { this.usrId = el; }
  private String usrIdTo;
  public String ultAccId{get;set;}
  public String getUsrIdTo() { return this.usrIdTo; }
  public void setUsrIdTo(String el) { this.usrIdTo = el;}
  List<Account> accRecLst{get;set;}
  public List<OpportunityTeamMember> OpptTeamInsert{get;set;}
  public List<OpportunityTeamMember> oldTeamMem{get;set;}
  public List<AccountTeamMember> accoldTeamMem{get;set;}
  public List<AccountTeamMember> AccTeamInsert{get;set;}
  public List<Account> accRecIds{get;set;}
  public List<ID> accOldOwnIds{get;set;}
  public List<ID> oppRec{get;set;}
  public List<Opportunity> oppRecLst{get;set;}

 
  public List<Account> getAccRecLst()
  {
      System.Debug('accRecLst'+accRecLst);
      return accRecLst;

  }

  public PageReference Closepopup()
  {
      System.Debug('showBlk'+ShowBlk);
      ShowBlk=false;
      HideBlk = true;
      return null;

  }

  public List<AccountWrapper> getAccounts()
  {
        
            accId=ApexPages.currentPage().getParameters().get('id');
            Account acc=[Select Id,Ultimate_Parent_Account__c,Legal_Entity__c,parentId,tfcmCustomerStatus__c from Account Where Id=:accId AND tfcmCustomerStatus__c!='Inactive' limit 1];
            String currUsrId=UserInfo.getUserId();
            User usr=[Select Id,Name,Profile.Name, tfcrmTeamRole__c,Business_Channel__c from User Where Id=:currUsrId];
            String usrTmRol=usr.tfcrmTeamRole__c;
            String usrBsChl=usr.Business_Channel__c;
            System.Debug('usrTmRol'+usrTmRol);
            ultAccId=acc.Ultimate_Parent_Account__c;
            Boolean lglEnty=acc.Legal_Entity__c;
            System.Debug('lglEnty'+lglEnty);
            
            //Anshita: Added 'CDM User' profile for CR 26568
            //if(usr.Profile.Name == 'Global Business Opps'|| usr.Profile.Name == 'Global Business Ops + Edit'|| usr.Profile.Name == 'CDM User')
            //Added 'Media Support Users' profile for MTI-2889 by Chaithrashree
            if(usr.Profile.Name == 'Global Business Opps'|| usr.Profile.Name == 'Media Support Users'|| usr.Profile.Name == 'Global Business Ops + Edit'|| usr.Profile.Name == 'CDM User')
            {
                //modified code FIx CR 12624 : kirtesh
                if(lglEnty==true  || (lglEnty == false && acc.parentId == null) )
                {
                    /*
                    if(ultAccId!=null)
                    {
                        if(accSelectRec== null)
                        {
                            accSelectRec= new List<AccountWrapper>();
                            String qry='Select Id,Site,Name,Legal_Entity__c,OwnerId,tfCrmCountry__c,Owning_Pool__c,Owning_Pool__r.Id,BillingCity,BillingState,Type,ParentId,Ultimate_Parent_Account__c from Account where Ultimate_Parent_Account__c =\''+ultAccId+'\' or Id=\''+ultAccId+'\'';
                            system.Debug('query'+qry);
                            for( Account accRec : Database.query(qry)) 
                            {
                               accSelectRec.add(new AccountWrapper(accRec));  
                            }  
                        } 
                        System.Debug('accSelectRec##'+accSelectRec); 
                    }
                    else
                    {   if(accSelectRec== null)
                        {
                            accSelectRec= new List<AccountWrapper>();
                            String qry='Select Id,Site,Name,Legal_Entity__c,OwnerId,tfCrmCountry__c,Owning_Pool__c,Owning_Pool__r.Id,BillingCity,BillingState,Type,ParentId,Ultimate_Parent_Account__c from Account where Ultimate_Parent_Account__c =\''+accId+'\' or Id=\''+accId+'\'';
                            system.Debug('query'+qry);
                            for( Account accRec : Database.query(qry)) 
                            {
                               accSelectRec.add(new AccountWrapper(accRec));  
                            }   
                            System.Debug('accSelectRec##'+accSelectRec); 
                        }
                    }
                    */
                    
                   if(accSelectRec== null){
                    set<Id> setIds = new  set<Id>();
                    setIds.add(acc.Id);
                    boolean bln = getChildAccounts(setIds);
                    accSelectRec =  new List<AccountWrapper>();
                    majorAccountIds.add(acc.Id);
                    List<Account> lstAccount = [ Select Id,Site,Name,Legal_Entity__c,OwnerId,tfCrmCountry__c,Owning_Pool__c,
                                                       Owning_Pool__r.Id,BillingCity,BillingState,Type,ParentId,
                                                       Ultimate_Parent_Account__c,tocBusiness_channel__c ,tfcmCustomerStatus__c
                                                from Account where tfcmCustomerStatus__c!='Inactive' AND ID IN : majorAccountIds order by tfCrmCountry__c ];
                    
                    
                     for( Account account  : lstAccount  ){
                          //Modified if and else if condition for MTI-2889 by Chaithrashree
                       if(account.tocBusiness_channel__c == 'Media' && usr.Profile.Name == 'Media Support Users') 
                          accSelectRec.add(new AccountWrapper(account,false));  
                       else if(account.tocBusiness_channel__c == 'Media' && usr.Profile.Name != 'Media Support Users')
                          accSelectRec.add(new AccountWrapper(account,true));  
                         //End of MTI-2889
                        else
                        accSelectRec.add(new AccountWrapper(account,false));
                        
                     }
                  }
                }
                else
                {
                    ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Account Owner Transfer should be initiated from Legal Entity Level');
                    ApexPages.addMessage(ErrMsg);
                    errMsge=true;
                    return null;
                }
            }
            else
            {
            
                ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Contact your Business Operations & Planning team to initiate the Account owner transfer process');
                ApexPages.addMessage(ErrMsg);
                errMsge=true;
                return null;

            }
            return accSelectRec;
    }

    public List<Account> selectedAccounts=new List<Account>();
    public PageReference getSelected()
    {
        selectedAccounts.clear();
        for(accountwrapper accwrapper : accSelectRec)
        if(accwrapper.checked== true)
        selectedAccounts.add(accwrapper.acc);
        return null;
    }

    
    
    /*public List<User> getConFuns()
    {
      usrId=ApexPages.currentPage().getParameters().get('usrId');
      System.Debug('usrId##'+usrId);
      return conFuns;
    }*/

    public List<User> getConFunsTo()
    {
      usrIdTo=ApexPages.currentPage().getParameters().get('usrIdTo');
      System.Debug('usrIdTo##'+usrIdTo);
      return conFunsTo;
    }
 
    
    
    public PageReference DoSort()
    {
        queryCores();
        return null;    
    } 
    
    public PageReference DoSortTo()
    {
        queryCoresTo();
        return null;    
    }  
  
    private void queryCores()
    {
      conFuns= database.query(searchQuery());
      excessRowsError = conFuns.size() > 50 ? true:false;  
      listSize = excessRowsError ? '[50+]' : ('[' + String.valueOf(conFuns.size()) + ']');      
    }

     private void queryCoresTo()
    {
      conFunsTo= database.query(searchQueryTo());  
      excessRowsError = conFunsTo.size() > 50 ? true:false;  
      listSize = excessRowsError ? '[50+]' : ('[' + String.valueOf(conFunsTo.size()) + ']');   
    }
    
    private String searchQuery()
    {
     
      if(getSearchText(searchVal) == null)
      {
          return normalQuery();
      }
      string strSearchName = getSearchText(searchVal);
      String strWhere = '';
      if(strSearchName != '' && strSearchName != null)
      {
          strWhere = ' Where Name LIKE \'' + strSearchName + '\' IsActive=true AND ContactId = null AND (Name != \''+'Archived Records Owner'+'\')' ;
            
      }
        
      
      string strQuery = 'SELECT id, Name FROM User' ;
     
      if(strWhere != '' && strWhere != null)
      {
         strQuery = strQuery + strWhere;
         
      }
                
      strQuery = strQuery + ' ORDER BY ' + SortField;
      strQuery = strQuery + ' ' + sortingOrder;
      strQuery = strQuery + ' NULLS LAST Limit 1000';
      return strQuery;
      
   }

   private String searchQueryTo()
    {
     
      if(getSearchText(searchValTo) == null)
      {
          return normalQuery();
      }
      string strSearchName = getSearchText(searchValTo);
      String strWhere = '';
      strSearchName = strSearchName.replaceAll('\'', '\\\\\'');
      if(strSearchName != '' && strSearchName != null)
      {
          strWhere = ' Where Name LIKE \'' + strSearchName + '\' AND IsActive=true AND (Name != \''+'Archived Records Owner'+'\') AND ContactId = null AND profile.name NOT IN ('+System.Label.user_profile_limit+')' ;
            
      }
      else
      {
          strWhere = ' Where (Name != \''+'Archived Records Owner'+'\') AND IsActive=true AND ContactId = null AND profile.name NOT IN ('+System.Label.user_profile_limit+')' ;
      }
        
      
      string strQuery = 'SELECT id, Name FROM User ' ;
     
      if(strWhere != '' && strWhere != null)
      {
         strQuery = strQuery + strWhere;
         
      }
                
      strQuery = strQuery + ' ORDER BY ' + SortField;
      strQuery = strQuery + ' ' + sortingOrder;
      strQuery = strQuery + ' NULLS LAST Limit 1000';
      return strQuery;
      
   }

   private String getSearchText(String str)
  {
      if(str == null || str == '')
      {
          return null;        
      }   
      string input = str.replace('*','%');
      if(input.indexOf('%') == -1)
      {
          input = '%' + input + '%';
      }
      return input;
  }

    private String normalQuery()
    {
      string strQuery = 'SELECT id,IsActive,Name FROM User Where (Name != \''+'Archived Records Owner'+'\') AND IsActive=true AND ContactId = null AND profile.name NOT IN ('+System.Label.user_profile_limit+')';
      strQuery = strQuery + ' ORDER BY ' + SortField;
      strQuery = strQuery + ' ' + sortingOrder;
      strQuery = strQuery + ' NULLS LAST Limit 1000';
      return strQuery;
    }
    
    public PageReference fetch()
    {
      searchVal=ApexPages.currentPage().getParameters().get('srhVal');
      searchValTo=ApexPages.currentPage().getParameters().get('srhVal');
      isAscending = true;
      showCreateNew = false;
      SortField = 'Name';
      queryCores();
      queryCoresTo();
      return null;
    }
    public AccController ()
    {
      ShowErrorBlk=false;  
      HideBlk=true;
      ShowBlk=false;
      ShowNewBlk=false;
      accSelectRec=null;
      
    }
    
    public PageReference fetchTo()
    {
      
      searchValTo=ApexPages.currentPage().getParameters().get('srhVal');
      isAscending = true;
      showCreateNew = false;
      SortField = 'Name';
      queryCoresTo();
      return null;
    }
    
    public PageReference Search()
    {
    System.Debug('usrId'+usrId);
    isAscending = true;
    showCreateNew = false;
    SortField = 'Name';
    queryCores();
    return null;
    } 

    public PageReference SearchTo()
    {
    isAscending = true;
    showCreateNew = false;
    SortField = 'Name';
    queryCoresTo();
    return null;
    } 

    public string sortField
    {
       get;
       set
       {
           this.previousSortField = sortField;
           this.sortField = value;      
           if(previousSortField == sortField)
           {
               isAscending = !isAscending;
               this.sortingOrder = isAscending ? 'ASC' : 'DESC';
               return;
           }
           this.isAscending = true;  
           this.sortingOrder = 'ASC';
      }
   }

   public PageReference transferAccounts()
   {
      if(usrIdTo == null || usrIdTo == ''){
         ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select the user from Lookup');
         ApexPages.addMessage(ErrMsg);
         return null;
      }
      selectedAccounts = new List<Account>();
      system.Debug('accSelectRec'+accSelectRec);
      for(accountwrapper accwrapper :accSelectRec)
      {
          System.Debug('accwrapper.checked'+accwrapper.checked);
          String chkPool=accwrapper.acc.Owning_Pool__c;
          System.Debug('chkPool'+chkPool);
          if(accwrapper.checked == true)
          {
             selectedAccounts.add(accwrapper.acc);
          }
      }
        system.Debug('selectedAccounts'+selectedAccounts);
      //---------------------------------------------------------------------------
      accRecIds=new List<Account>();
      accOldOwnIds=new List<ID>();
      oppRec=new List<ID>();
      oppRecLst=new List<Opportunity>();
      accRecLst=new List<Account>();
      OpptTeamInsert=new List<OpportunityTeamMember>();
      oldTeamMem=new List<OpportunityTeamMember>();
      accoldTeamMem=new List<AccountTeamMember>();
      AccTeamInsert=new List<AccountTeamMember>();
      
      if( selectedAccounts.size() > 9  ){
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select less than 10 Accounts');
        ApexPages.addMessage(ErrMsg);
        return null;
      }
      
      for(Integer i=0;i<selectedAccounts.size();i++)
      {
         accRecIds.add(selectedAccounts[i]);
         accOldOwnIds.add(selectedAccounts[i].ownerId);
      }
      

      /*Kirtesh commented
      for(Opportunity opp :[Select Id,ownerId,AccountId from Opportunity where AccountId IN:accRecIds AND StageName NOT IN ('6. Order Placed','7. Order Complete','8. Closed / No Order' )])
      {
          oppRec.add(opp.Id);
      }

      for(OpportunityTeamMember oppTeamCollOwner:[Select o.Id, o.OpportunityId, o.UserId from OpportunityTeamMember o where o.OpportunityId IN:oppRec and o.UserId IN:accOldOwnIds])
      {
             oldTeamMem.add(oppTeamCollOwner);
      }
      System.Debug('oldTeamMem'+oldTeamMem);
      */
     
      
      User selectedUser = [SELECT Id, tfcrmTeamRole__c from User where id=:usrIdTo];
      
      for(Integer k=0;k<accRecIds.size();k++)
      {
          Account accsObject=new Account(Id=accRecIds[k].Id);
          System.Debug('usrIdTo'+usrIdTo);
          accsObject.Name=accRecIds[k].Name;
          accsObject.Site=accRecIds[k].Site;
          accsObject.Legal_Entity__c=accRecIds[k].Legal_Entity__c;
          accsObject.ownerId=ESAPI.encoder().SFDC_HTMLENCODE(usrIdTo); // Fixed as a part of TSV-82 to remove the XSS injection by Thippeswamy A on Nov-07-2018
          accsObject.Type=accRecIds[k].Type;
          accsObject.ParentId=accRecIds[k].ParentId;
          accsObject.BillingCity=accRecIds[k].BillingCity;
          accsObject.BillingState=accRecIds[k].BillingState;
          accsObject.Ultimate_Parent_Account__c=accRecIds[k].Ultimate_Parent_Account__c;
          accsObject.ShippingCountry=accRecIds[k].tfCrmCountry__c;
          accRecLst.add(accsObject);
          System.Debug('accRecLst'+accRecLst);
          
          /*Kirtesh Commented
          AccountTeamMember AccTeamMem = new AccountTeamMember();
          AccTeamMem.AccountId = accRecIds[k].Id;
          AccTeamMem.TeamMemberRole= selectedUser.tfcrmTeamRole__c;
          AccTeamMem.UserId=usrIdTo;
          AccTeamInsert.add(AccTeamMem);
          */
      }

     
      
      for(Integer j=0;j<oppRec.size();j++)
      {
          /*Opportunity oppsObject=new Opportunity(Id=oppRec[j]);
          System.Debug('usrIdTo'+usrIdTo);
          oppsObject.ownerId=usrIdTo;
          oppRecLst.add(oppsObject);
          System.Debug('oppRecLst'+oppRecLst);*/
          
          /* Kirtesh Commented 
          OpportunityTeamMember OpporTeamMem = new OpportunityTeamMember();
          OpporTeamMem.OpportunityId = oppRec[j];
          OpporTeamMem.UserId=usrIdTo;
          OpporTeamMem.TeamMemberRole = selectedUser.tfcrmTeamRole__c;
          OpptTeamInsert.add(OpporTeamMem);
          */
      }
      
      System.Debug('accRecIds'+accRecIds);
      System.Debug('oppRec'+oppRec);

      /*Kirtesh Commented 
      for(AccountTeamMember accTeamCollOwner:[Select o.Id, o.AccountId, o.UserId from AccountTeamMember o where o.AccountId IN:accRecIds and o.UserId IN:accOldOwnIds])
      {
             accoldTeamMem.add(accTeamCollOwner);
      }
      */

      HideBlk =false;
      ShowBlk=true;
      return null;
      
    
   }

   public PageReference transferFinally()
   {
       Boolean errorflag = false;
      /*
      try
      {
        Database.DeleteResult[] DeleteAccResults = Database.delete(oldTeamMem);  
        System.Debug('DeleteAccResults '+DeleteAccResults );
      }
      catch (Exception e)
      {
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Old Sales Team Delete Failed');
        ApexPages.addMessage(ErrMsg);
      }

      try
      {
        Database.SaveResult[] saveAccTeamResults = Database.insert(AccTeamInsert);  
        System.Debug('saveAccTeamResults '+saveAccTeamResults );
      }
      catch (Exception e)
      {
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Account Team Insert Failed');
        ApexPages.addMessage(ErrMsg);
      }
       */
       
      try
      {
        Database.SaveResult[] saveAccResults = Database.update(accRecLst);  
        System.Debug('saveAccResults '+saveAccResults );
      }
      catch (Exception e)
      { 
        errorflag = true;
        String ErrorMessage = e.getMessage();
        if(ErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,'))
        {
            ErrorMessage=ErrorMessage.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
            ErrorMessage=ErrorMessage.removeEnd(': []');
        }
        else
            ErrorMessage='';
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Account Owner Update Failed:'+ErrorMessage);
        ApexPages.addMessage(ErrMsg);
      }
   
     /* Kirtesh commented
      try
      {
        Database.SaveResult[] saveResults = Database.update(oppRecLst);  
        System.Debug('saveResults '+saveResults );
      }
      catch (Exception e)
      {
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Opportunity Owner Update Failed');
        ApexPages.addMessage(ErrMsg);
      }
     
     
      try
      {
        Database.SaveResult[] saveTeamResults = Database.insert(OpptTeamInsert);  
        System.Debug('saveTeamResults '+saveTeamResults );
      }
      catch (Exception e)
      {
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Opportunity Saleas Team Insert Failed');
        ApexPages.addMessage(ErrMsg);
      }
      
      try
      {
        Database.DeleteResult[] DeleteAccTeamResults = Database.delete(accoldTeamMem);  
        System.Debug('DeleteAccTeamResults '+DeleteAccTeamResults );
      }
      catch (Exception e)
      {
        ApexPages.Message ErrMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Account Team Delete Failed');
        ApexPages.addMessage(ErrMsg);
      }
      */
      
      ShowBlk=false;
      if(!errorflag)
          ShowNewBlk=true;
      else
          ShowErrorBlk=true;
      HideBlk = false;
      accSelectRec= null;
      //getAccounts();
      usrIdTo = null;
      return null;

   }
   
   
   set<id> majorAccountIds = new set<id>();
    
  public  boolean getChildAccounts(set<Id> accountIds ){
        
        List<Account> lstAccount = [Select Id , parentId,
                                    parent.parentId,parent.parent.parentId,
                                    parent.parent.parent.parentId,
                                    parent.parent.parent.parent.parentId,
                                    tocBusiness_channel__c
                                    from Account
                                    Where parentId IN : accountIds 
                                    OR parent.parentId IN :accountIds
                                    OR parent.parent.parentId IN : accountIds
                                    OR parent.parent.parent.parentId IN : accountIds
                                    OR parent.parent.parent.parent.parentId IN : accountIds ];
                                    
       set<Id> nextQueryIds = new set<Id>();
       for(Account account  : lstAccount){
          majorAccountIds.add(account.id);
          if(account.parent.parent.parent.parent.parentId != null){
            nextQueryIds.add(account.Id);
          } 
       }
       
       if(nextQueryIds.size() > 0 ) {
         return  getChildAccounts(nextQueryIds);
         
       }else 
          return true;
        
        
   }
   
  //-------------------------------------------------------------------------------------------

    
  public class accountwrapper
    {
        public Account acc{get; set;}
        public Boolean checked {get; set;}
        
        public accountwrapper(Account a)
        {
            acc = a;
            checked=true;

            
        }
        
        
        public accountwrapper(Account a , boolean isMediaOwner )
        {
            acc = a;
            if(isMediaOwner == false)
              checked = true;
            else 
             checked = false;
        }
    }

}