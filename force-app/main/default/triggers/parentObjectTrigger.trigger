trigger parentObjectTrigger on ParentObject__c (before insert, after update) {

    if(trigger.isupdate && trigger.isAfter){
        
        //Call helper to put amount on child object
        parentObjectTriggerHelper.calculateAmountOnChild(trigger.new, trigger.oldMap);
        
    }

}