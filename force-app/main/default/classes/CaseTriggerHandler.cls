public class CaseTriggerHandler {
// Trigger 12: When a Case is inserted on Any Acount, Put the latest case number on the Account in Latest case number field

    public static void updateLatestCaseNumber(List<Case> csList){
        List<Account> accList = new List<Account>();
        Set<Id> accIds = new Set<Id>();
       
        for(Case cs : csList){
            if(cs.AccountId != null && cs.CaseNumber != null){
                accIds.add(cs.AccountId);
            }
        }
  
  for(Case cs: [SELECT CaseNumber, AccountId FROM Case where AccountId IN: accIds 
                ORDER BY CreatedDate DESC LIMIT 1]){
            Account acc = new Account();
            acc.Id = cs.AccountId;
            acc.Latest_case_number__c = cs.CaseNumber;
               accList.add(acc); 
        }

       if (!accList.isEmpty()) {
            update accList;
        }  
    }
    // 44: Whenevr Create Task Checkbox gets checked for case on An Account a Follow up Task Should automatically gets created on the Primary Contact of Account
    public static void createTaskonRelatedContact(List<Case> caseList, Map<Id, Case> caseOldMap){
        List<Task> taskList = new List<Task>();
        Set<Id> accIds = new Set<Id>();
       
        for(Case cs : caseList){
            if((cs.Create_Task__c == true && cs.AccountId != Null && caseOldMap == null) || 
               (cs.AccountId != Null && caseOldMap != null && cs.Create_Task__c == true && cs.Create_Task__c != caseOldMap.get(cs.AccountId).Create_Task__c)){
               accIds.add(cs.AccountId); 
            }
        }
        
        for(Contact con : [Select Id, AccountId, LastName, Primary_Contact__c from Contact where AccountId IN: accIds AND Primary_Contact__c = True]){
            Task tk = new Task();
            tk.Subject = 'Follow-up Task';
            tk.Status = 'Not Started';
            tk.WhoId = con.AccountId;
            tk.Priority = 'Normal';
            taskList.add(tk);
        }
        insert taskList;
    }
}