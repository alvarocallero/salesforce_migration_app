trigger DuplicatedOrNewKnownIssueTrigger on Known_Issue__c (before update) {
	if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            KnownIssuesUtils.setDuplicatedOrNewKeyword(Trigger.new, Trigger.oldMap);
        }
    }
}