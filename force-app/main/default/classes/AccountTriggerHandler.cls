public class AccountTriggerHandler {
    
    // Infosis Interview Question: Whenever You undelete Record, update field to check that record is undelete
    public static void undeleteRecordChecked(List<Account> accList){
        List<Account> accountsToUpdateList = new List<Account>();
       
        for(Account acc : accList){
            if(!accList.isEmpty()){
               Account updateAcc = new Account();
                updateAcc.Id = acc.Id;
                updateAcc.undeleted_Record__c = True;
                accountsToUpdateList.add(updateAcc);
            }  
        }
        update accountsToUpdateList;
    }
    //1st:  Before Insert: If Account billing Address inserted then copy Billing to Shipping
    public static void copyShippingToBillingAddress(List<Account> accList){
        
        for(Account acc: accList){
            if(acc.BillingStreet != null){
                acc.ShippingStreet = acc.BillingStreet;
            }
            if(acc.BillingCity != null){
                acc.ShippingCity = ACC.BillingCity;
            }   
            if(acc.BillingCountry != null){
                acc.ShippingCountry = acc.BillingCountry;
            }   
            if(acc.BillingPostalCode != null){
                acc.ShippingPostalCode = acc.BillingPostalCode;
            } 
            if(acc.BillingState != null){
                acc.ShippingState = acc.BillingState; 
            }
        }
    }
    
    //2nd:  Whenever Accounts Phone Field is Updated 
    //then all related Contacts Phone field should also 
    //get updated with Parent Accounts Phone
    
    public static void updatedRelatedContactPhone(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for(Account acc: accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone){
                accMap.put(acc.Id, acc);
            }
        }
        
        for(Contact con : [Select Id, AccountId, HomePhone from Contact where AccountId IN: accMap.keySet()]){
            
            if(accMap.containsKey(con.AccountId)){
                con.HomePhone = accMap.get(con.AccountId).Phone;
                conList.add(con);
            }
        }
        if(!conList.isEmpty()){
            update conList;
        }
    }
    
    // 6th Prevent Duplication of records based on Name whenever record is inserted or updated
    public static void preventDuplicationOfRecord(List<Account> accList, Map<Id, Account> accOldMap){
        Set<String> accOldName = new Set<String>();
        Set<String> accnewName = new Set<String>();
        
        for(Account acc: accList){
            if(acc.Name != null){
                accOldName.add(acc.Name);
            }
        }  
        
        for(Account acc: [Select Id, Name from Account where Name IN : accOldName]){
            accnewName.add(acc.Name);
        }
        
        for(Account acc : accList){
            if(accnewName.contains(acc.Name)){
                acc.addError('Account Name already Exists');
            }
        }
    }
    //7th  Trigger to Create a related Contact of Account with same Phone as Accounts Phoone if Custom CheckBox field on Account check
    public static void createRelatedCon(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for(Account acc : accList){
            if(acc.CreateContact_with_same_Phone__c == true || acc.CreateContact_with_same_Phone__c != accOldMap.get(acc.Id).CreateContact_with_same_Phone__c){
                accMap.put(acc.Id, acc);
            }
        }
        for(Account acc : [Select Id, Name, Phone, CreateContact_with_same_Phone__c from Account where Id IN: accMap.keySet()]){
            if(accMap.containsKey(acc.Id)){
                Contact con = new Contact();
                con.FirstName = 'Test';
                con.LastName = acc.Name;
                con.Phone = acc.Phone;
                con.AccountId = acc.Id;
                conList.add(con);
            }      
        }
        if(!conList.isEmpty()){
            insert conList;
        }
        
    }
    // 9th Write a trigger on the Account When the Account is updated check all Opportunities related to Account.
    //  Update all Opportunities Stage to close Lost if opportunity created date is grater than 30 days from today and Stage is not equal to close Won
    
    public static void updateRelatedOppStage(List<Account> accList, Map<Id, Account> accOldMap){
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for(Account acc: accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone){
                accMap.put(acc.Id, acc);
            }
        }
        
        for(Account acc :[Select Id, Phone,(Select Id, AccountId, StageName, Test_Created_Date__c from Opportunities) from Account where Id IN:accMap.keySet()]){
            Date day30 = System.Today() - 30;  // date which is 30 days less than today.
            
            for(Opportunity opp : acc.Opportunities){
                if(opp.Test_Created_Date__c < day30 && opp.StageName != 'Closed Won'){
                    opp.StageName = 'Closed Lost';
                    opp.CloseDate = System.Today();
                    oppList.add(opp);
                }
            }
        }
        
        update oppList;
    }
    
    // 1oth Trigger, Prevent a User from deleting Active Account
    public static void preventActiveAccDeletion(List<Account> accList){
        
        for(Account acc : accList){
            if(acc.Active_Account__c == true){
                acc.addError('You cannot delete Active Account');
                
            }
        }
    }
    
    // Very Importnant Trigger 14 : Send Email to Contact on Account Type Update
    
    public static void sendEmailtoContact(List<Account> accList, Map<Id, Account> accOldMap){
        
        Set<Id> accIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Account acc : accList){
            if(acc.Type != accOldMap.get(acc.Id).Type && accOldMap != null){
                accIds.add(acc.Id);
            }
        }
        for (Contact con : [Select Id, AccountId, Email, LastName from Contact where AccountId IN:accIds]) {
            if (con.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{con.Email});
                email.setSubject('Account Update Info');
                email.setPlainTextBody('Dear ' + con.LastName + ',\n\nYour Account type has been updated successfully.\n\nBest regards,\nYour Salesforce Administrator');
                emailList.add(email);
            }
        }
        
        Messaging.sendEmail(emailList);
    }
    
    // Trigger 18(Accenture Interview Question) : Automatically Close Opportunities With Probability Grater than 70% when checkbox is checked on Account
    
    public static void automaticallyCloseOpp(List<Account> accList, Map<Id, Account> accOldMap){
        
        Set<Id> accIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Account acc : accList){
            if(acc.Close_All_Opps__c == true && accOldMap.get(acc.Id).Close_All_Opps__c == false){
                accIds.add(acc.Id);
            }
        }
        
        for(Opportunity opp : [Select Id, AccountId, StageName, Probability from Opportunity where AccountId IN: accIds AND StageName != 'Closed Won' AND Probability >= 70]){
            if(accIds.contains(opp.AccountId)){
                opp.StageName = 'Closed Won';
                opp.CloseDate = System.Today();
                oppList.add(opp);
            }
        }
        update oppList;
    }
    
    // Trigger 19 : Automatically Create related Contact on insertion of Account and update Contact Lookup Field.
    
    public static void insertRelatedContact(List<Account> accList){
        
        List<Contact> conList = new List<Contact>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<Account> updatedaccList = new List<Account>();
        for(Account acc: accList){
            if(acc.Name != null){
                Contact con = new Contact();
                con.LastName = 'Test con' + acc.Name;
                con.AccountId = acc.Id;
                conList.add(con);
                accIds.add(acc.Id);
            }
        }
        insert conList;
        
        if(!accIds.isEmpty()){
            For(Account acc: [Select Id, Client_Contact__c FROM Account where ID IN: accIds]){
                accMap.put(acc.Id, acc);
            }
        }
        
        for(Contact con : conList){
            if (accMap.containsKey(con.AccountId)){
                for(Account acc : accList){
                    acc.Client_Contact__c = con.Id;
                    updatedaccList.add(acc);
                }
            }
        }
        update updatedaccList;
    }
    
    
    
    
    
    // 42. Write an Apex Trigger to Prevent Deactivation of Account with Active Contacts on It
    public static void PreventAccountDeactivation(List<Account> accList, Map<Id, Account> accOldMap){
        
        // Set to hold Account Ids with active Contacts
        Set<Id> accIds = new Set<Id>();
        
        for(Account acc : accList){
            if(accOldMap.get(acc.Id).Status__c == 'Active' && accOldMap.get(acc.Id).Active__c == 'Yes'){
                accIds.add(acc.Id);
            }
        }
        
        // If there are Accounts with active Contacts, prevent their deactivation
        for(Contact con : [Select Id, AccountId from Contact Where AccountId IN: accIds AND Active__c = 'Yes']){
            
            for(Account acc : accList){
                acc.addError('Cannot deactivate an Account with active Contacts.');
            }
        }
    }
    // 43. Write an Apex Trigger to create a related Contact Whenevr the Create Contact Checkbox is Checked on Account
    // Updation or insertion
    public static void createRelatedConWhenCheckboxisChecked(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        Set<Id> accIds = new Set<Id>();
        
        for(Account acc : accList){
            if((accOldMap == null && acc.Create_Contact__c == true) || (accOldMap != null && acc.Create_Contact__c != accOldMap.get(acc.Id).Create_Contact__c && acc.Create_Contact__c == true )){
                accIds.add(acc.Id);
            }
        }
        for(Account acc : [Select Id, Name, Phone from Account where Id IN:accIds]){
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            conList.add(con);
        }
        insert conList;
    }
    
    // 46 : Deloitte Question : Write an Apex Trigger to update the related Contacts 
    // with the Latest Country Fiels value whenever it Changes on the Parent Account record
    
    public static void changeCountryOnrelatedCon(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        
        Map<Id, Account> accountCountryMap = new Map<Id, Account>();
        for(Account acc : accList){
            if((acc.Country__c != NULL && accOldMap == null && acc.Country__c != accOldMap.get(acc.Id).Country__c)){
                accountCountryMap.put(acc.Id, acc);   
            }
        }
        
        for(Contact con :[Select Id, AccountId, Account_Country__c from Contact where AccountId IN:accountCountryMap.keySet()]){
            if(accountCountryMap.containsKey(con.AccountId)){
                con.Account_Country__c = accountCountryMap.get(con.AccountId).Country__c;
                conList.add(con);
            } 
        }
        update conList;
    }
    
    // Trigger 50 (NTT Data Interview Question): Write an Apex Trigger to create Contacts 
    // based on the Number entered by the user in Number of Contacts Create Field while creating an Account
    // Max no of Contact create allowed is 10 only.
    
    public static void createRelatedConBasedOnNoField(List<Account> accList){
        
        List<Contact> conList = new List<Contact>();
        
        for(Account acc: accList){
            if(!accList.isEmpty() && acc.Name != null && acc.No_of_Contacts_Create__c != null && acc.No_of_Contacts_Create__c <= 10){
                
                for(Integer i = 1; i<= acc.No_of_Contacts_Create__c; i++){
                    Contact con = new Contact();
                    con.FirstName = 'Test';
                    con.LastName = 'Contact' + i;
                    con.AccountId = acc.Id;
                    conList.add(con);
                }
                
            } else{
                acc.addError('Maximum Number of Contacts Allowed for this Account is 10');
            }
            
        }
        insert conList;
    }
}