public class EmployeeTriggerHandler {
    
    // Trigger 15 (Amazon Interview Question)  Show Min & Max Salary of Employees Records on Parent Company Record
    public static void showMinMaxSalaryOnParent(List<Employee__c> empList, Map<Id, Employee__c> empOldMap){
        // Step 1: Identify parent company IDs
        Set<Id> parentIds = new Set<Id>();
        for(Employee__c emp : empList){
            if((empOldMap == null && emp.Tech_Firm__c != null)   // for insert
               || (empOldMap != null && emp.Tech_Firm__c != empOldMap.get(emp.Id).Tech_Firm__c)){   // for update
                   parentIds.add(emp.Tech_Firm__c);
               }
        }
        
        // Step 2: Aggregate min and max salary for each parent company
        List<Tech_Firm__c> tfList = new List<Tech_Firm__c>();
        for(AggregateResult agr : [SELECT Tech_Firm__c tfId, MAX(Salary__c) maxSalary, MIN(Salary__c) minSalary 
                                   FROM Employee__c WHERE Tech_Firm__c IN :parentIds GROUP BY Tech_Firm__c]){
            Tech_Firm__c tf = new Tech_Firm__c(Id = (Id)agr.get('tfId'));
            tf.Max_Salary__c = (Decimal)agr.get('maxSalary');
            tf.Min_Salary__c = (Decimal)agr.get('minSalary');
            tfList.add(tf);
        }
        
        // Step 3: Update parent company records
        if(!tfList.isEmpty()){
            update tfList;
        }
    }
}