trigger EmployeeTrigger on Employee__c (after insert, after update, after delete, after undelete) {

    if(Trigger.isInsert && Trigger.isAfter){
        EmployeeTriggerHandler.showMinMaxSalaryOnParent(Trigger.new, null);
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter){
         EmployeeTriggerHandler.showMinMaxSalaryOnParent(Trigger.new, Trigger.oldMap);
    }
    
   else if(Trigger.isDelete && Trigger.isAfter){
         EmployeeTriggerHandler.showMinMaxSalaryOnParent(Trigger.old, null);
    }
    
    else if(Trigger.isUndelete && Trigger.isAfter){
         EmployeeTriggerHandler.showMinMaxSalaryOnParent(Trigger.new, null);
    }
}