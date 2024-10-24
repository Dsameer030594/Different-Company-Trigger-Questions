trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {

    if(Trigger.isInsert){
        if(Trigger.isAfter){
            OpportunityTriggerHandler.sumOfamountonAccount(Trigger.new, null);
           OpportunityTriggerHandler.showMaxCloseOppAmount(Trigger.new, null);
            OpportunityTriggerHandler.updateDescriptionwithOppName(Trigger.new, null);
            OpportunityTriggerHandler.updateAccountFieldWithHighestAOppAmount(Trigger.new, null);
            OpportunityTriggerHandler.sendEmaiToOwner(Trigger.new, null);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            OpportunityTriggerHandler.sumOfamountonAccount(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.showMaxCloseOppAmount(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.updateDescriptionwithOppName(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.updateAccountFieldWithHighestAOppAmount(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.sendEmaiToOwner(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isAfter){
            OpportunityTriggerHandler.sumOfamountonAccount(Trigger.old, null);
             OpportunityTriggerHandler.showMaxCloseOppAmount(Trigger.old, null);
            OpportunityTriggerHandler.updateDescriptionwithOppName(Trigger.old, null);
            OpportunityTriggerHandler.updateAccountFieldWithHighestAOppAmount(Trigger.old, null);
        }
    }
    if(Trigger.isUndelete){
        if(Trigger.isAfter){
            OpportunityTriggerHandler.sumOfamountonAccount(Trigger.new, null);
             OpportunityTriggerHandler.showMaxCloseOppAmount(Trigger.new, null);
            OpportunityTriggerHandler.updateDescriptionwithOppName(Trigger.new, null);
            OpportunityTriggerHandler.updateAccountFieldWithHighestAOppAmount(Trigger.new, null);
        }
    }
}