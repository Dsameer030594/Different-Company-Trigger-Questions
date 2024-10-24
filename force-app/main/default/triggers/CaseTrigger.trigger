trigger CaseTrigger on Case (before insert, after insert, after update) {

    if(Trigger.isInsert){
        if(Trigger.isafter){
            CaseTriggerHandler.updateLatestCaseNumber(Trigger.new);
             CaseTriggerHandler.createTaskonRelatedContact(Trigger.new, null);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            CaseTriggerHandler.createTaskonRelatedContact(Trigger.new, Trigger.oldMap);
        }
    }
}