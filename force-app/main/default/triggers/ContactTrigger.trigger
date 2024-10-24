trigger ContactTrigger on Contact (before insert, before update, after insert,after update, after delete, after undelete) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
          //  ContactTriggerHandler.preventDuplicationbasedOnEmailandPhone(Trigger.new, null);
            ContactTriggerHandler.enforceSingleCon(Trigger.new, null);
        } else if(Trigger.isAfter){
          //  ContactTriggerHandler.updateTotalContactsOnAccount(Trigger.new, null);
        }
    }
    
    if(Trigger.isUpdate){
        
        if(Trigger.isBefore){
            // ContactTriggerHandler.preventDuplicationbasedOnEmailandPhone(Trigger.new, Trigger.oldMap);
            ContactTriggerHandler.enforceSingleCon(Trigger.new, Trigger.oldMap);
        }
       else if(Trigger.isAfter){
          //  ContactTriggerHandler.updateparentDescription(Trigger.new, Trigger.oldMap);
          // ContactTriggerHandler.updateTotalContactsOnAccount(Trigger.new, Trigger.oldMap);
         
        }
    }
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            
        }else if(Trigger.isAfter){
          //  ContactTriggerHandler.updateTotalContactsOnAccount(Trigger.old, null);
        }
    }
    
    if(Trigger.isunDelete){
         if(Trigger.isAfter){
           // ContactTriggerHandler.updateTotalContactsOnAccount(Trigger.new, null);
        }
    }
}