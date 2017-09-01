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
    public string datasetColorStatus{get;set;}
    public string letterColor {get;set;}
    public string lettercolorTrain {get;set;}
    public string trainingColorStatus {get;set;}
    public DateTime lastUpdatedModel {get;set;}
    public DateTime lastUpdatedDataset {get;set;}

    public EinsteinSetupController() {

        if (GeneralUtils.botSettingsExist()) {
			einsteinEnabled = EinsteinUtils.getEinsteinEnabled();
        } else {
            einsteinEnabled = false;
        }
        datasetStatus = 'There was a problem checking the dataset\'s status. Please check it again later.';
        String datasetId = EinsteinUtils.getEinsteinDatasetId();
        if(!String.isBlank(datasetId)){
            Map<String, Object> jsonDatasetStatus = (Map<String, Object>)JSON.deserializeUntyped(LanguageController.getDataset(datasetId));
            if (jsonDatasetStatus.containsKey(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETDS_STATUS)){
                datasetStatus = (String)jsonDatasetStatus.get(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETDS_STATUS);
                if(datasetStatus == EinsteinUtils.EINSTEIN_DS_STATUS_SUCCEEDED){
                    datasetColorStatus = '#269900';
                    lettercolor ='#ffffff';
                }else if(datasetStatus == EinsteinUtils.EINSTEIN_DS_STATUS_UPLOADING){
					datasetColorStatus = '#1e968f';
					lettercolor ='#ffffff';
                }else if(datasetStatus == EinsteinUtils.EINSTEIN_DS_STATUS_FAILURE){
                    datasetColorStatus = 'Orange';
                    lettercolor ='#ffffff';
                }
            }
            if (jsonDatasetStatus.containsKey(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETDS_UPDATEDAT)){
                String lastUpdated = (String)jsonDatasetStatus.get(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETDS_UPDATEDAT);
                lastUpdated = lastUpdated.split('\\.')[0];
				lastUpdated = lastUpdated.replace('T', ' ');
                lastUpdatedDataset = DateTime.valueOf(lastUpdated);
            }
        } else{
            letterColor = 'Black';
            datasetStatus = 'The dataset was not uploaded yet';
        }

        trainStatus = 'There was a problem checking the train\'s status. Please check it again later.';
        String modelId = EinsteinUtils.getEinsteinModelId();
        if(!String.isBlank(modelId)){
            Map<String, Object> jsonTrainStatus = (Map<String, Object>)JSON.deserializeUntyped(LanguageController.getTrainStatus(modelId));
            if (jsonTrainStatus.containsKey(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETTRAIN_STATUS)){
                trainStatus = (String)jsonTrainStatus.get(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETTRAIN_STATUS);
                if(trainStatus == EinsteinUtils.EINSTEIN_TRAIN_STATUS_SUCCEEDED){
                    trainingColorStatus = '#269900';
                    lettercolorTrain ='#ffffff';

                }else if(trainStatus == EinsteinUtils.EINSTEIN_TRAIN_STATUS_FAILED){
					trainingColorStatus = 'Orange';
					lettercolorTrain ='#ffffff';
                }else if(trainStatus == EinsteinUtils.EINSTEIN_TRAIN_STATUS_QUEUED){
                    trainingColorStatus = '#22b5ac';
					lettercolorTrain ='Black';

                }else if(trainStatus == EinsteinUtils.EINSTEIN_TRAIN_STATUS_RUNNING){
                    trainingColorStatus = '#13635e';
					lettercolorTrain ='#ffffff';
                }
            }
            if (jsonTrainStatus.containsKey(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETTRAIN_UPDATEDAT)){
                String lastUpdated = (String)jsonTrainStatus.get(EinsteinUtils.EINSTEIN_PARAMS_RESPONSE_GETTRAIN_UPDATEDAT);
                lastUpdated = lastUpdated.split('\\.')[0];
				lastUpdated = lastUpdated.replace('T', ' ');
                lastUpdatedModel = DateTime.valueOf(lastUpdated);
            }
        } else {
			lettercolorTrain = 'Black';
            trainStatus = 'The dataset was not trained yet.';

        }
        datasetUploaded = !String.isBlank(datasetId) && datasetStatus == EinsteinUtils.EINSTEIN_DS_STATUS_SUCCEEDED;
        couldTrain =  datasetUploaded && (String.isBlank(modelId));
        couldRetrain = !String.isBlank(modelId) && trainStatus == EinsteinUtils.EINSTEIN_TRAIN_STATUS_SUCCEEDED;
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
            SELECT Name,
            	Einstein_Data_Messages_Count__c,
            	Einstein_Upload_Status__c,
            	(
                    SELECT Message__c,
                        Einstein_Upload_Status__c
                    FROM Einstein_Data_Messages__r
                    WHERE Einstein_Upload_Status__c =: EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED
            	)
            FROM Einstein_Keyword__c
            WHERE Id IN (
                SELECT Einstein_Keyword__c
                FROM Known_Issue__c
                WHERE Status__c =: EinsteinUtils.KNOWN_ISSUE_NEW
            )
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
                datasetStatus = EinsteinUtils.EINSTEIN_DS_STATUS_UPLOADING;
                datasetColorStatus = '#1e968f';
				lettercolor ='#ffffff';
                couldTrain = true;
                keywordsToUpload = null;
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
            trainStatus = EinsteinUtils.EINSTEIN_TRAIN_STATUS_QUEUED;
            trainingColorStatus = '#22b5ac';
			lettercolorTrain ='#ffffff';
            couldTrain = false;
            couldRetrain = true;
            EinsteinUtils.setEinsteinEnabled(false);
        }
        return null;
    }

    public PageReference retrain() {
        resetToastMessages();
        if (lastUpdatedModel>=lastUpdatedDataset){
            toastErrorMessage = 'There aren\'t any new messages to train.';
        } else {
            String response = EinsteinUtils.retrainEinstein();
            if (response != null) {
                    toastErrorMessage = response;
            } else{
                toastSuccessMessage = 'Training in process';
                einsteinEnabled = false;
                lettercolorTrain ='white';
                EinsteinUtils.setEinsteinEnabled(false);
            }
        }
        return null;
    }

    public PageReference uploadExamples() {
        resetToastMessages();
       	if(!keywordsToUpload.isEmpty()) {
            String response = EinsteinUtils.uploadExamplesToEinstein(keywordsToUpload);
            if (response != null) {
                toastErrorMessage = response;
            } else {
                toastSuccessMessage = 'The examples were uploaded.';
                datasetStatus = EinsteinUtils.EINSTEIN_DS_STATUS_UPLOADING;


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

    public void resetToastMessages() {
        toastErrorMessage = null;
        toastSuccessMessage = null;
    }

}
