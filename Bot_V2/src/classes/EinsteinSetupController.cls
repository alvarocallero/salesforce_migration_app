public class EinsteinSetupController {
	
    public Boolean einsteinEnabled {get; set;}
    public Boolean datasetUploaded {get; set;}
    public Boolean couldTrain {get; set;}
    public Boolean couldRetrain {get; set;}
    public Boolean couldResetEinstein {get; set;}
    public String datasetStatus {get; set;}
    public String trainStatus {get; set;}
    private static Map<Id, Einstein_Keyword__c> keywordsById;
    
    public String toastSuccessMessage {get; set;}
    public String toastErrorMessage {get; set;}
    public List<Einstein_Keyword__c> keywordsMissingMessages {get; set;}
    public List<Einstein_Keyword__c> keywordsToUpload {get; set;}
    public List<Einstein_Data_Message__c> messagesWithError {get; set;}
    
    public EinsteinSetupController() {
        
        if (GeneralUtils.botSettingsExist()) {
			einsteinEnabled = EinsteinUtils.getEinsteinEnabled();
        } else {
            einsteinEnabled = false;
        }
        
        datasetStatus = 'There was a problem checking the dataset\'s status. Please check it again later.';
        String datasetId = EinsteinUtils.getEinsteinDatasetId();
        if(datasetId != null && datasetId !=''){            
            Map<String, Object> jsonDatasetStatus = (Map<String, Object>)JSON.deserializeUntyped(LanguageController.getDataset(datasetId));
            if (jsonDatasetStatus.containsKey('statusMsg') && datasetId != null && datasetId != ''){
                datasetStatus = (String)jsonDatasetStatus.get('statusMsg');
            }
        } else{
            datasetStatus = 'The dataset was not uploaded yet';
        }
        
        trainStatus = 'There was a problem checking the train\'s status. Please check it again later.';
        String modelId = EinsteinUtils.getEinsteinModelId();
        if(modelId != null && modelId !=''){    
            Map<String, Object> jsonTrainStatus = (Map<String, Object>)JSON.deserializeUntyped(LanguageController.getTrainStatus(modelId));
            if (jsonTrainStatus.containsKey('status') && modelId != null && modelId != ''){
                trainStatus = (String)jsonTrainStatus.get('status');
            }
        } else {
            trainStatus = 'The dataset was not trained yet.';
        }
        datasetUploaded = EinsteinUtils.getEinsteinDatasetId() != null && EinsteinUtils.getEinsteinDatasetId() != '' && datasetStatus == EinsteinUtils.EINSTEIN_DS_STATUS_SUCCEEDED;
        couldTrain =  datasetUploaded && (modelId == null || modelId == '');
        couldRetrain = EinsteinUtils.getEinsteinModelId() != null && EinsteinUtils.getEinsteinModelId() != '' && trainStatus == EinsteinUtils.EINSTEIN_TRAIN_STATUS_SUCCEEDED;
	    couldResetEinstein = datasetStatus.startsWith(EinsteinUtils.EINSTEIN_DS_STATUS_FAILURE);
        
        keywordsMissingMessages = new List<Einstein_Keyword__c>();
        keywordsToUpload = new List<Einstein_Keyword__c>();
        messagesWithError = new List<Einstein_Data_Message__c>(); 
        
        messagesWithError = [
            SELECT Id,
            	Message__c,
            	Einstein_Keyword__r.Name,
            	Einstein_Upload_Status__c            
            FROM Einstein_Data_Message__c
            WHERE Einstein_Upload_Status__c =: EinsteinUtils.UPLOAD_STATUS_ERROR
        ];
        
        List<Einstein_Keyword__c> keywords = [
            SELECT Id,
            	Name,
            	Einstein_Data_Messages_Count__c,
            	Einstein_Upload_Status__c,
            (
                SELECT Id,
                	Message__c,
                    Known_Issue__r.Status__c,
                    Einstein_Keyword__r.Einstein_Upload_Status__c,
                    Einstein_Keyword__r.Einstein_Data_Messages_Count__c,
                    Einstein_Upload_Status__c
                FROM Einstein_Data_Messages__r
                WHERE Known_Issue__r.Status__c !=: EinsteinUtils.KNOWN_ISSUE_PENDING_APPROVAL AND
                    Known_Issue__r.Status__c !=: EinsteinUtils.KNOWN_ISSUE_INVALID AND 
                	(Einstein_Upload_Status__c =: EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED)
            )
            FROM Einstein_Keyword__c
        ];
        Integer index = 0;
        for (Einstein_Keyword__c keyword: keywords){
            index = 0;
            for(Einstein_Data_Message__c message: keyword.Einstein_Data_Messages__r){
                if (message.Einstein_Upload_Status__c == EinsteinUtils.UPLOAD_STATUS_ERROR){
                    messagesWithError.add(message);
                    keyword.Einstein_Data_Messages__r.remove(index);
                }  
                index ++;
            }
            if (keyword.Einstein_Data_Messages__r.size()>0){
                if(keyword.Einstein_Data_Messages_Count__c < 5){  
                keywordsMissingMessages.add(keyword);
                } 
                else {
                    keywordsToUpload.add(keyword);
                }
            }            
        }      
    }
    
    public PageReference enableEinstein() {
        resetToastMessages();
        if (trainStatus != EinsteinUtils.EINSTEIN_TRAIN_STATUS_SUCCEEDED || datasetStatus != EinsteinUtils.EINSTEIN_DS_STATUS_SUCCEEDED) {
            toastErrorMessage = 'Einstein cannot be enabled, the dataset and train status must be SUCCEEDED';
        } else {
            EinsteinUtils.setEinsteinEnabled(true);
        	einsteinEnabled = true;
        }
        return null;
    }
    
    public PageReference disableEinstein() {
        resetToastMessages();
        
        EinsteinUtils.setEinsteinEnabled(false);
        einsteinEnabled = false;
        return null;
    }
    
    public PageReference uploadMessages() {
        resetToastMessages();            
       	if(keywordsToUpload.isEmpty()) {
        	toastErrorMessage = 'There are no messages to upload at the moment.';
        } else if (keywordsToUpload.size() < 3) {
            toastErrorMessage = 'You have to upload at least 3 keywords with 5 Messages for each one.';
        } else {
            String response = EinsteinUtils.uploadMessagesToEinstein(keywordsToUpload);
            if (response != null) {
                toastErrorMessage = response;
                
            } else {
                toastSuccessMessage = 'The dataset was uploaded.';
            }            
        }        
        // Value is lost on rerender for some reason
        einsteinEnabled = EinsteinUtils.getEinsteinEnabled();		
     	return null;
    }
    
    public PageReference train() {
        resetToastMessages();
        String response = EinsteinUtils.trainEinstein();
        if (response != null) {
                toastErrorMessage = response;
        } else{
        	toastSuccessMessage = 'Training in process';
            einsteinEnabled = false;
            EinsteinUtils.setEinsteinEnabled(false);
        }
        return null;
    }
    
    public PageReference retrain() {
        resetToastMessages();
        String response = EinsteinUtils.retrainEinstein();
        if (response != null) {
                toastErrorMessage = response;
        } else{
        	toastSuccessMessage = 'Training in process';
            einsteinEnabled = false;
            EinsteinUtils.setEinsteinEnabled(false);
        }
        return null;
    }
    
    public PageReference uploadExamples() {        
        resetToastMessages();
       	if(!keywordsToUpload.isEmpty()) {
            String response = EinsteinUtils.uploadExamplesToEinstein(keywordsToUpload);
            //System.debug('response '+ response);
            if (response != null) {
                toastErrorMessage = response;                
            } else {
                toastSuccessMessage = 'The examples were uploaded.';
            }            
        } else {            
        	toastErrorMessage = 'There are no keywords to upload at the moment.';
        }
        // Value is lost on rerender for some reason
        einsteinEnabled = EinsteinUtils.getEinsteinEnabled();		
     	return null;
    }
    
    public PageReference resetEinstein() {
        resetToastMessages();
        EinsteinUtils.resetEinstein();
        toastSuccessMessage = 'The dataset was reset.';
        return null;
    }
    
    private void resetToastMessages() {
        toastErrorMessage = null;
        toastSuccessMessage = null;
    }
    
}