global class checkEinsteinAvailable implements Database.Batchable<sObject>,Schedulable{
        global void execute(SchedulableContext SC) {

        database.executeBatch(this);
    }


    global string resultjsonTraining = LanguageController.getTrainStatus(EinsteinUtils.getEinsteinModelId());
    global String data = EinsteinUtils.UPLOAD_STATUS_IN_PROCESS;
    global string resultjsonStatus = LanguageController.getDataset(EinsteinUtils.getEinsteinDatasetId());


    global list<Einstein_Keyword__c> start(Database.BatchableContext bc){
        //Getting the needed records with DataBase.getQueryLocator.

        return [Select e.Id, e.Einstein_Upload_Status__c From Einstein_Keyword__c e WHERE e.Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_IN_PROCESS];
    }

    global void execute(Database.BatchableContext bc,List<Einstein_Keyword__c> scope) {
        //Executing the method with the list


        if(!EinsteinUtils.getEinsteinEnabled()){

            checkAvailable(scope);
        }

    }

    global void checkAvailable(list<Einstein_Keyword__c> scope){

        Map<String, Object> jsonResultTrainingStatus = (Map<String, Object>)JSON.deserializeUntyped(resultjsonTraining);
        //Checking if Einstein is Enable or not and checking if the Training status is successful or not
        //In the case of fail of ether we set every keyword with the status error
        //if Einstein is disable and the training was successful and the status of message is success
        //we activate Einstein and set all the key words to Uploaded
        if((jsonResultTrainingStatus.get(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_TRAINDS_STATUS) == EinsteinUtils.EINSTEIN_TRAIN_STATUS_SUCCEEDED)){
            Map<String, Object> jsonResultStatusMsg = (Map<String, Object>)JSON.deserializeUntyped(resultjsonStatus);
            if(jsonResultStatusMsg.get(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETDS_STATUS) == EinsteinUtils.EINSTEIN_DS_STATUS_SUCCEEDED){
				EinsteinUtils.setEinsteinEnabled(true);
                setUploadStatus(scope,EinsteinUtils.UPLOAD_STATUS_UPLOADED);
            }
        }else{
            setUploadStatus(scope,EinsteinUtils.UPLOAD_STATUS_ERROR);
        }

    }
    //Method to set all the keywords to a given status
    private void setUploadStatus(List<Einstein_Keyword__c> EinsteinKeyword,String setStatus){
        for(Einstein_Keyword__c i: EinsteinKeyword){
            i.Einstein_Upload_Status__c = setStatus;
        }
        upsert EinsteinKeyword;
    }

    global void finish(Database.BatchableContext bc){

    }
}
