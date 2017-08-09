trigger KnownIssueTrigger on Known_Issue__c (after update) {

    if (Trigger.isAfter) {
       
        if (Trigger.isUpdate) {
            
            KnownIssuesUtils.reparentSubscribersOfDuplicatedIssues(Trigger.new);
            KnownIssuesUtils.notifyFixedIssuesSubscribers(Trigger.new, Trigger.oldMap);
            
        }
        
    }
    
}