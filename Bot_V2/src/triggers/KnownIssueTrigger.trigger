trigger KnownIssueTrigger on Known_Issue__c (after insert, after update) {

    if (Trigger.isAfter) {
       
        if ( Trigger.isInsert || Trigger.isUpdate ) {
            KnownIssuesUtils.reparentSubscribersOfDuplicatedIssues(Trigger.new);
        }
        
    }
    
}