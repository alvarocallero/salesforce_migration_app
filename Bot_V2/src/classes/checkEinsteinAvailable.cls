global class checkEinsteinAvailable implements Database.Batchable<sObject>{
    
     string modelId =  EinsteinUtils.getEinsteinModelId();
     String data = 'In Process';
     String query = 'Select e.Id, e.Einstein_Upload_Status__c From Einstein_Keyword__c e WHERE e.Einstein_Upload_Status__c = :Data';
     string datasetId = String.valueOf(EinsteinUtils.getEinsteinDatasetId().intValue());
     
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Getting the needed records with DataBase.getQueryLocator.

          return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<Einstein_Keyword__c> EinsteinKeyword) {
        //Executing the method with the list
		
        checkAvailable(EinsteinKeyword,modelId,datasetId);
    }
    
    global void checkAvailable(List<Einstein_Keyword__c> EinsteinKeyword,String modelId,String datasetId){

        //Getting the string json with information weather the training was successfull or not
        string resultTrainingStatus = LanguageController.getTrainStatus(modelId);     
        string resultStatusMsg = '';
        
        //Desalinating the resultTrainging status

        Map<String, Object> jsonResultTrainingStatus = (Map<String, Object>)JSON.deserializeUntyped(resultTrainingStatus);
        //Checking if Einstein is Enable or not and checking if the Training status is successful or not 
        //In the case of fail of ether we set every keyword with the status error
        //if Einstein is disable and the training was successful and the status of message is success
        //we activate Einstein and set all the key words to Uploaded 
        if((!EinsteinUtils.getEinsteinEnabled()) && (jsonResultTrainingStatus.get('status') == 'SUCCEEDED')){
            system.debug('IM IN THE IF');
            resultStatusMsg = LanguageController.getDataset(datasetId);
            Map<String, Object> jsonResultStatusMsg = (Map<String, Object>)JSON.deserializeUntyped(resultStatusMsg);
            
            if(jsonResultStatusMsg.get('statusMsg') == 'SUCCEEDED'){
                
                EinsteinUtils.setEinsteinEnabled(true);
                setUploadStatus(EinsteinKeyword,'Uploaded');
            }
        }else{           
            setUploadStatus(EinsteinKeyword,'Error');
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