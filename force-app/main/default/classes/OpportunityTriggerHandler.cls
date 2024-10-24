public class OpportunityTriggerHandler {
    
    // 8th video and question
    // Trigger to find sum of all related Opportunities Amount of an Account
    public static void sumOfamountonAccount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
         Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        
        for(Opportunity opp : oppList){
            if((opp.Amount != null ) || (opp.Amount != oppOldMap.get(opp.Id).Amount && oppOldMap != null)){
                accIds.add(opp.AccountId);
            }
        }
         // Map to store opportunity amount per account
         Map<Id, Decimal> oppamountMap= new Map<Id, Decimal>();
        // Query for all closed opportunities related to the accounts
        for(Opportunity opp : [Select Id, AccountId, Name, Amount from Opportunity where AccountId IN: accIds]){
            if(!oppamountMap.containsKey(opp.AccountId)){
                oppamountMap.put(opp.AccountId, oppamountMap.get(opp.AccountId) + opp.Amount );

            }
        }
        // Update the Account records with the sum of opportunity amounts
        for(Id accId : accIds){
            
            Account acc = new Account();
            acc.Id = accId;
            acc.Total_Opportunity_Amount__c = oppamountMap.get(accId);
            accList.add(acc);
        }
        update accList;
    }
  
    // Trigger 16 (TCS Question): Update the Parent Account Field with The Opportunity Name that has Highest Amount
    public static void updateAccountFieldWithHighestAOppAmount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        
        Set<Id> accIds = new Set<Id>();
       List<Account> accList = new List<Account>();
        for(Opportunity opp: oppList){
            if((oppOldMap == null & opp.Amount != null) || (opp.Amount != oppOldMap.get(opp.Id).Amount &&  oppOldMap != null)){
                accIds.add(opp.AccountId);
            }
        }
        
        for(Account acc :[Select Id, Name, MaxOpp_Name__c,(Select Id, AccountId,Name, Amount from Opportunities where Amount != null Order by Amount desc limit 1) from Account where Id IN: accIds]){
            
            acc.MaxOpp_Name__c = acc.Opportunities[0].Name;
            accList.add(acc);
        }
        
        update accList;
    }
    
    
    // Trigger 41 : Write An Apex Trigger to show Max closed Opportunity Amount on Account without using Aggregate Function
    public static void showMaxCloseOppAmount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        List<Account> accList = new List<Account>();
       
        Set<Id> accIds = new Set<Id>();
         // Collect all account Ids related to the opportunities being inserted, updated, deleted, or undeleted
        for(Opportunity opp : oppList){
            if((opp.Name != null) || (oppOldMap != null && opp.Name != oppOldMap.get(opp.AccountId).Name)){
                accIds.add(opp.AccountId);
            }
        }
         // Map to store maximum closed opportunity amount per account
           Map<Id, Decimal> oppMazAmountMap = new  Map<Id, Decimal>();
        // Query for all closed opportunities related to the accounts
        for(Opportunity opp : [Select Id, AccountId, Amount, StageName from Opportunity where AccountId IN: accIds AND IsClosed = true AND StageName = 'Closed Won']){
          
            Decimal maxAmount = oppMazAmountMap.get(opp.AccountId);
           
            if(maxAmount == null && opp.Amount > maxAmount){
                oppMazAmountMap.put(opp.AccountId, opp.Amount);
            }          
        }
        
        // Update the Account records with the maximum closed opportunity amount
        for(Id accId : accIds){
            Decimal maxAmount = oppMazAmountMap.get(accId);
            Account acc = new Account();
            acc.Id = accId;
            acc.Max_Closed_Opp_Amount__c = maxAmount;
            accList.add(acc);
        }
        
        update accList;  
    }
    // 47: Accenture Question : Write an Apex Trigger to update the Accounts Description with Opportunity Name that has the Higest Amount
    public static void updateDescriptionwithOppName(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        
        for(Opportunity opp : oppList){
            if(opp.Amount != null && opp.Amount != oppOldMap.get(opp.AccountId).Amount){
                accIds.add(opp.AccountId);
            }
        }
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if(!accIds.isEmpty()){
            for(Opportunity opp : [Select Id, AccountId, Amount, Name from Opportunity where AccountId IN: accIds AND Amount != null]){
                oppMap.put(opp.AccountId, opp);
            }
        }
        
        for(Id accId : accIds){
            Account acc = new Account();
            acc.Id = accId;
            acc.Description = oppMap.get(accId).Name;
            accList.add(acc);
        }
        
        update accList;
    }
    // Trigger 52: IBM Interview Scenario : Whenever an Opportunity is created or updated with Amount Greater than 10000,
    // then send an Email to the record Owner
   
    public static void sendEmaiToOwner(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        
       // List to hold Opportunities with Amount greater than 10000
       Set<Id> ownerIds = new Set<Id>();
        
        for(Opportunity opp : oppList){
            if((oppOldMap == null && opp.Amount != null && opp.Amount >10000) || (oppOldMap != null && opp.Amount != oppOldMap.get(opp.Id).Amount && opp.Amount >10000)){
                ownerIds.add(opp.OwnerId);
            }
        }
        
        if(!ownerIds.isEmpty()){
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            for(Opportunity opp : [Select Id, OwnerId, Name, Amount from Opportunity where OwnerId IN: ownerIds]){
                
                 // Create an email message
               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               // Set email parameters
                email.SetToAddresses(new List<String>{opp.OwnerId});
                email.setSubject('Opportunity Amount exceeding 10000');
                email.setPlainTextBody('Dear ' + opp.Owner.Name + ',\n\n' +
                                   'An Opportunity with the name "' + opp.Name + '" has been ' +
                                   'created or updated with an Amount exceeding $10,000.\n\n' +
                                   'Thank you,\nYour Salesforce Administrator');
                
                emailsToSend.add(email);
                
            }
            // Send emails
        Messaging.sendEmail(emailsToSend);
        }
        
    }
}