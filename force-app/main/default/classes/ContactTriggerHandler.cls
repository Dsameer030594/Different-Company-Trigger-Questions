public class ContactTriggerHandler {
    
    //4th Whenever Contact's Description is Updated then its Account's Description should also
    //get updated by it.
    
    public static void updateparentDescription(List<Contact> conList, Map<Id, Contact> conOldMap){
        
        List<Account> accList = new List<Account>();
        // Set<Id> conIds = new Set<Id>();
        
        for(Contact con: conList){
            if(con.AccountId != null && con.Description != conOldMap.get(con.AccountId).Description){
                Account acc = new Account();
                acc.Description = con.Description;
                accList.add(acc);
            }
        }
        
        // Update the Account records
        if (!accList.isEmpty()) {
            update accList;
        }
    }
    //5th Trigger to count total no of contacts 
    //associated with an account and display the contacts count on Account Custom Field.
    public static void updateTotalContactsOnAccount(List<Contact> conList, Map<Id, Contact> conOldMap){
        List<Account> accList = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        
        for(Contact con : conList){
            if(con.AccountId != null){
                accIds.add(con.AccountId);
            }
        }
        
        for(Account acc: [Select Id, Total_Contact_count__c,
                          (Select Id, AccountId from Contacts) From Account Where Id IN: accIds]){
                              
                              acc.Total_Contact_count__c = acc.Contacts.size();
                              accList.add(acc);
                          }
        update accList; 
    }
    // Trigger 13 : Prevent Duplication of Contact Records Based on Email & Phone
    public static void preventDuplicationbasedOnEmailandPhone(List<Contact> conList, Map<Id, Contact> conOldMap){
        Map<Id, Contact> conNewMap = new Map<Id, Contact>();
        
        for(Contact con : conList){
            if((con.Phone != null && con.Email != null)
               || (con.Phone != conOldMap.get(con.Id).Phone && con.Email != conOldMap.get(con.Id).Email)){
                   con.addError('Your Contact already existes in the System.'); 
               }
        }
    }
    // Trigger 17: (Delloite Interview Question): Enforce Single Primary Contact on Account
    public static void enforceSingleCon(List<Contact> conList, Map<Id, Contact> conOldMap){
        Set<Id> accIds = new Set<Id>();
        Map<Id, Contact> conMap = new Map<Id, Contact>();
        
        if(!conList.isEmpty()){
            for(Contact con : conList){
                if((conOldMap == null && con.LastName != null) || (con.LastName != conOldMap.get(con.Id).LastName && conOldMap != null)){
                    accIds.add(con.AccountId);
                }
            }
        }
        
        if(!accIds.isEmpty()){
            for(Contact con : [SELECT Id, AccountId, LastName, Primary_Contact__c FROM Contact WHERE AccountId IN: accIds AND Primary_Contact__c = True]){
                conMap.put(con.AccountId, con);
            }
        }
        
        for(Contact con : conList){
            if(con.Primary_Contact__c == true && conMap.containsKey(con.AccountId)){
                con.addError('This Account cannot have more than one Primary Contact');
            }
        }
    }
}