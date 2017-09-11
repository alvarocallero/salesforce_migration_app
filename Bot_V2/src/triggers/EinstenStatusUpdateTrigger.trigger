trigger EinstenStatusUpdateTrigger on Einstein_Keyword__c (after update) {
    
    //Build up a list of Einstein_Keyword__c before and after update
	List<Einstein_Keyword__c> allkeyWordLstNEWlst = Trigger.new;
    List<Einstein_Keyword__c> allkeyWordLstOLDlst = Trigger.old;
    
    //sets to keep the ids of the Einstein_Keyword__c to update
    Set<String> idOfKeyWordsInProgessSet = new Set<String>();
    Set<String> idOfKeyWordsWithErrorSet = new Set<String>();
   
    for(Integer i=0;i<allkeyWordLstOLDlst.size();i++){
        if (allkeyWordLstOLDlst[i].Einstein_Upload_Status__c.equals(EinsteinUtils.UPLOAD_STATUS_IN_PROCESS) && 
            allkeyWordLstNEWlst[i].Einstein_Upload_Status__c.equals(EinsteinUtils.UPLOAD_STATUS_UPLOADED)){
            idOfKeyWordsInProgessSet.add(allkeyWordLstOLDlst[i].id);
        }
        
        if (allkeyWordLstOLDlst[i].Einstein_Upload_Status__c.equals(EinsteinUtils.UPLOAD_STATUS_IN_PROCESS) &&
            allkeyWordLstNEWlst[i].Einstein_Upload_Status__c.equals(EinsteinUtils.UPLOAD_STATUS_ERROR)){
            idOfKeyWordsWithErrorSet.add(allkeyWordLstOLDlst[i].id);
        }
    }
   
    List<Einstein_Data_Message__c> dataMsgLstInProcess = [select id from Einstein_Data_Message__c 
                                                          where Einstein_Keyword__c in :idOfKeyWordsInProgessSet];
    List<Einstein_Data_Message__c> dataMsgLstWithError = [select id from Einstein_Data_Message__c 
                                                          where Einstein_Keyword__c in :idOfKeyWordsWithErrorSet];
    
    //Set the update status to 'In_process' of Einstein_Data_Message__c lst
    for(Einstein_Data_Message__c obj : dataMsgLstInProcess){
        obj.Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_UPLOADED;
    }
    
    //Set the update status to 'Error' of Einstein_Data_Message__c lst
    for(Einstein_Data_Message__c obj : dataMsgLstWithError){
        obj.Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_ERROR;
    }
    
    //Send the update of both lists
    upsert(dataMsgLstInProcess);
    upsert(dataMsgLstWithError);
     
}