trigger AccountTrigger on Account (before insert, after insert, before Update, after update, before delete, after undelete) {
    
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            // AccountTriggerHandler.copyShippingToBillingAddress(Trigger.new); 
            // AccountTriggerHandler.preventDuplicationOfRecord(Trigger.new, null);
        }else if(Trigger.isafter){
            // AccountTriggerHandler.createRelatedCon(Trigger.new, null);
            AccountTriggerHandler.createRelatedConWhenCheckboxisChecked(Trigger.new, null);
            AccountTriggerHandler.changeCountryOnrelatedCon(Trigger.new, null);
            AccountTriggerHandler.automaticallyCloseOpp(Trigger.new, null); 
            AccountTriggerHandler.insertRelatedContact(Trigger.new);
            AccountTriggerHandler.createRelatedConBasedOnNoField(Trigger.new);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            //  AccountTriggerHandler.preventDuplicationOfRecord(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.PreventAccountDeactivation(Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isafter){
            //  AccountTriggerHandler.updatedRelatedContactPhone(Trigger.new, Trigger.oldMap); 
            // AccountTriggerHandler.createRelatedCon(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateRelatedOppStage(Trigger.new, Trigger.oldMap); 
            AccountTriggerHandler.createRelatedConWhenCheckboxisChecked(Trigger.new, Trigger.oldMap); 
            AccountTriggerHandler.changeCountryOnrelatedCon(Trigger.new, Trigger.oldMap); 
            AccountTriggerHandler.sendEmailtoContact(Trigger.new, Trigger.oldMap); 
            AccountTriggerHandler.automaticallyCloseOpp(Trigger.new, Trigger.oldMap); 
        } 
    }
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            AccountTriggerHandler.preventActiveAccDeletion(Trigger.old);
        }
    }
    
    if(Trigger.isUndelete && Trigger.isAfter){
        AccountTriggerHandler.undeleteRecordChecked(Trigger.new);
    }
}