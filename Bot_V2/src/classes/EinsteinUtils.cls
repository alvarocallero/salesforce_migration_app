public class EinsteinUtils {
	
    public static final String KEYWORD_UNDEFINED = 'UNDEFINED';
    private static Id KEYWORD_ID_UNDEFINED;
    // UPLOAD STATUS
    public static final String UPLOAD_STATUS_NOT_UPLOADED = 'Not Uploaded';
    public static final String UPLOAD_STATUS_UPLOADED = 'Uploaded';
    public static final String UPLOAD_STATUS_IN_PROCESS = 'In Process';
    public static final String UPLOAD_STATUS_ERROR = 'Error';
    
    //KNOWN ISSUES STATUS
    public static final String KNOWN_ISSUE_PENDING_APPROVAL = 'Pending Approval';
    public static final String KNOWN_ISSUE_NEW = 'New';
    public static final String KNOWN_ISSUE_FIXED = 'Fixed';
    public static final String KNOWN_ISSUE_DUPLICATED = 'Duplicated';
    public static final String KNOWN_ISSUE_INVALID = 'Invalid';
    
    // EINSTEIN TRAIN STATUS
    public static final String EINSTEIN_TRAIN_STATUS_SUCCEEDED = 'SUCCEEDED';
    public static final String EINSTEIN_TRAIN_STATUS_FAILED = 'FAILED';
    
    // EINSTEIN DATASET STATUS
    public static final String EINSTEIN_DS_STATUS_SUCCEEDED = 'SUCCEEDED';
    // This status begins with FAILURE and is composed with its reason like this: 'FAILURE: <failure_reason>—Data upload has failed.'
    public static final String EINSTEIN_DS_STATUS_FAILURE = 'FAILURE';
    public static final String EINSTEIN_DS_STATUS_UPLOADING = 'UPLOADING';
    
    // MANAGE CUSTOM SETTING VALUES RELATED TO EINSTEIN
    
    public static Boolean getEinsteinEnabled() {
        return GeneralUtils.getBotSettings().Einstein_Enabled__c;
    }
    
    public static void setEinsteinEnabled(Boolean enabled) {
        GeneralUtils.getBotSettings().Einstein_Enabled__c = enabled == true;
        update GeneralUtils.BOT_SETTINGS;
    }
    
    public static String getEinsteinToken() {
        return GeneralUtils.getBotSettings().Einstein_Token__c;
    }
    
    public static void setEinsteinToken(String token) {
        GeneralUtils.getBotSettings().Einstein_Token__c = token;
        update GeneralUtils.BOT_SETTINGS;
    }
    
   public static String getEinsteinDatasetId() {
        return GeneralUtils.getBotSettings().Einstein_DatasetId__c;
    }
    
    public static void setEinsteinDatasetId(String datasetId) {
        GeneralUtils.getBotSettings().Einstein_DatasetId__c = datasetId;
        update GeneralUtils.BOT_SETTINGS;
    }

    public static String getEinsteinModelId() {
        return GeneralUtils.getBotSettings().Einstein_ModelId__c;
    }
    
    public static void setEinsteinModelId(String modelId) {
        GeneralUtils.getBotSettings().Einstein_ModelId__c = modelId;
        update GeneralUtils.BOT_SETTINGS;
    }
    // MANAGE KEYWORDS AND MESSAGES
    
    public static Id getUndefinedKeywordId() {
        
        if (KEYWORD_ID_UNDEFINED == null){
            List<Einstein_Keyword__c> keywords = [ SELECT Id
                                                  FROM Einstein_Keyword__c
                                                  WHERE Name = :KEYWORD_UNDEFINED
                                                  LIMIT 1 ];
            if (keywords.isEmpty()){
                keywords.add(new Einstein_Keyword__c( Name = KEYWORD_UNDEFINED,
                                                      Einstein_Upload_Status__c = UPLOAD_STATUS_NOT_UPLOADED ));
                insert keywords;
            }
            KEYWORD_ID_UNDEFINED = keywords[0].Id;
        }
        return KEYWORD_ID_UNDEFINED;
    }
    
    
    // Creates new message and returns the Id.
    // If keywordId is null then it will be associated to an UNDEFINED keyword.
    public static Id createMessage(Id keywordId, String message) {
		        
        String keywordIdFinal = keywordId != null ? keywordId : getUndefinedKeywordId();
        Einstein_Data_Message__c msg = new Einstein_Data_Message__c( Einstein_Keyword__c = keywordIdFinal,
                                                                     Message__c = message,
                                                                     Einstein_Upload_Status__c = UPLOAD_STATUS_NOT_UPLOADED ); //CHANGE TO NOT UPLOADED
        
        insert msg;
        return msg.Id;
    }
    
    
    public static void associateMessageWithIssue(Id messageId, Id knownIssueId) {
        List<Einstein_Data_Message__c> messages = [ SELECT Id,
                                                    Einstein_Keyword__c,
                                                 	Known_Issue__c
                                                   	FROM Einstein_Data_Message__c
                                                    WHERE Id = :messageId ];
        if (!messages.isEmpty()) {
            messages[0].Known_Issue__c = knownIssueId;
            update messages[0];
        }
    }
    
    
    // Returns null if successfull or String if fails
    // JSON format:
    /*
     { "intents": { "keyword1": [ "message1","message2","message3","message4","message5"],
					"keyword2": [ "message1","message2","message3","message4","message5"], 
					"keywordN": [ "message1","message2","message3","message4","message5"] }
      }
	*/
    public static String uploadMessagesToEinstein(Set<Id> keywordIds) {
        
        // get all Keyword and Message records
        List<Einstein_Keyword__c> keywords = [ 
            SELECT Id,
            Name,
            Einstein_Upload_Status__c,
            (
                SELECT Id,
                Name,
                Message__c,
                Einstein_Upload_Status__c
                FROM Einstein_Data_Messages__r
                WHERE Einstein_Upload_Status__c =: UPLOAD_STATUS_NOT_UPLOADED
            )
            FROM Einstein_Keyword__c
            WHERE Id IN :keywordIds
        ];
        
        // initialize lists to store records to update
        List<Einstein_Keyword__c> keywordsToUpdate = new List<Einstein_Keyword__c>();
        List<Einstein_Data_Message__c> messagesToUpdate = new List<Einstein_Data_Message__c>();
        
        // initialize JSON
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
		gen.writeFieldName('intents');
        gen.writeStartObject();
        
        // write each Keyword into the JSON and add it to update list if needed
        for (Einstein_Keyword__c keyword: keywords) {
            
            gen.writeFieldName(keyword.Name);
            
            if (keyword.Einstein_Upload_Status__c == UPLOAD_STATUS_NOT_UPLOADED) {
                keyword.Einstein_Upload_Status__c = UPLOAD_STATUS_IN_PROCESS;
                keywordsToUpdate.add(keyword);
            }
            
            gen.writeStartArray();
            
            // write each Message into JSON if it was never uploaded
            for (Einstein_Data_Message__c message: keyword.Einstein_Data_Messages__r) {
                message.Einstein_Upload_Status__c = UPLOAD_STATUS_IN_PROCESS;
                messagesToUpdate.add(message);
                gen.writeString(message.Message__c);
            }
            gen.writeEndArray();
            
        }
        gen.writeEndObject();
        gen.writeEndObject();
        gen.close();
        
        String jsonString = gen.getAsString();
        
        try{
            // Upload JSON
            if (!Test.isRunningTest()) {
                String datasetId = getEinsteinDatasetId();
                if(datasetId == null){
                    Map<String, String> params = new Map<String, String>();
                    params.put('name', 'EinsteinDataset.json');
                    String result = LanguageController.createDataset(params, Blob.valueof(jsonString));
                }            	
        	}
            
            // Update uploaded records
            if (!keywordsToUpdate.isEmpty()) {
                update keywordsToUpdate;
            }
            if (!messagesToUpdate.isEmpty()) {
                update messagesToUpdate;
            }
            
        } catch (Exception e){
            return e.getMessage();
        }
        
        return null;
    }
    
    public static String uploadExamplesToEinstein(Set<Id> keywordIds) {
        String datasetId = getEinsteinDatasetId();
        if(datasetId != null && datasetId != ''){
            // get all Keyword and Message records
            List<Einstein_Keyword__c> keywords = [ 
                SELECT Id,
                Name,
                Einstein_Upload_Status__c,
                (
                    SELECT Id,
                    Name,
                    Message__c,
                    Einstein_Upload_Status__c
                    FROM Einstein_Data_Messages__r
                    WHERE Einstein_Upload_Status__c =: UPLOAD_STATUS_NOT_UPLOADED
                )
                FROM Einstein_Keyword__c
                WHERE Id IN :keywordIds ];
            
            List<Einstein_Data_Message__c> messagesToUpdate = new List<Einstein_Data_Message__c>();
            
            // initialize JSON
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('intents');
            gen.writeStartObject();
            
            // write each Keyword into the JSON and add it to update list if needed
            for (Einstein_Keyword__c keyword: keywords) {                
                gen.writeFieldName(keyword.Name);
                keyword.Einstein_Upload_Status__c = UPLOAD_STATUS_IN_PROCESS;                
                gen.writeStartArray();
                
                // write each Message into JSON if it was never uploaded
                for (Einstein_Data_Message__c message: keyword.Einstein_Data_Messages__r) {
                        message.Einstein_Upload_Status__c = UPLOAD_STATUS_IN_PROCESS;
                        messagesToUpdate.add(message);
                        gen.writeString(message.Message__c);
                }
                gen.writeEndArray();
                
            }
            gen.writeEndObject();
            gen.writeEndObject();
            gen.close();
            
            String jsonString = gen.getAsString();
            
            try{
                // Upload JSON
                if (!Test.isRunningTest()) {
                    String result = LanguageController.createExample(datasetId, Blob.valueof(jsonString));
                    //System.debug(result);
                }
                
                // Update uploaded records
                if (!keywords.isEmpty()) {
                    update keywords;
                }
                if (!messagesToUpdate.isEmpty()) {
                    update messagesToUpdate;
                }                
            } catch (Exception e){
                return e.getMessage();
            }
            
            return null;
        } else {
            return 'You have to upload a dataset first before you can add new examples.';
        }
    }
    
    public static String trainEinstein() {
    	String datasetId = EinsteinUtils.getEinsteinDatasetId();
        if(datasetId != null){
            Map<String, String> params = new Map<String, String>();
            params.put('name', 'LexCoeToolkitModel');
            //System.debug(datasetId);
            params.put('datasetId', datasetId);
            try{
                String result = LanguageController.train(params);
                Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);            
                if (jsonResult.containsKey('status')){
                    String status = (String)jsonResult.get('status');
                    if(status == EINSTEIN_TRAIN_STATUS_FAILED){
                        String datasetStatus = LanguageController.getDataset(datasetId);
                        Map<String, Object> jsondatasetStatus = (Map<String, Object>)JSON.deserializeUntyped(datasetStatus);            
                        return 'Training failed. Status: ' + status + '\nDataset status: ' + (String)jsondatasetStatus.get('statusMsg');
                    }                
                } else { 
                    return 'Training failed.';
                }
            } catch (Exception e){
                return e.getMessage();
            }
        } else {
            return 'You have to upload a dataset first before you can train it.';
        }
        return null;
    }
    
    public static String retrainEinstein() {
    	String modelId = EinsteinUtils.getEinsteinModelId();
        Map<String, Object> jsonTrainStatus = (Map<String, Object>)JSON.deserializeUntyped(LanguageController.getTrainStatus(modelId));
        if (jsonTrainStatus.containsKey('status') && modelId != null && modelId != ''){
            String trainStatus = (String)jsonTrainStatus.get('status');
            if( trainStatus == EINSTEIN_TRAIN_STATUS_SUCCEEDED || trainStatus == EINSTEIN_TRAIN_STATUS_FAILED){
                Map<String, String> params = new Map<String, String>();
                params.put('modelId', modelId);
                try{
                    String result = LanguageController.retrain(params);
                    Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
                    if (jsonResult.containsKey('status')){
                        String status = (String)jsonResult.get('status');
                        if(status == EINSTEIN_TRAIN_STATUS_FAILED){
                            return 'Training failed. Status: ' + status;
                        }                
                    } else { 
                        return 'Training failed.';
                    } 
                } catch (Exception e){
                    return e.getMessage();
                }
            } else {
                return 'You could not train because the model is being trained now. Wait until it has finished. Status: ' + trainStatus;
            }  
                
        } else {
            return 'You have to upload a dataset first before you can train it.';
        }           
        return null;
    }
    /********************************************************************************************************************************
    * @description Set keywords and messages uploadedToEinstein's field to false. 
    * This is necessary because if an upload fails the dataset remains unavailable and you have to delete it and create another one.
	* @return void
    * @example EinsteinUtils.resetEinstein();
    */
    public static void resetEinstein() {
        String status = UPLOAD_STATUS_NOT_UPLOADED;
        List<Einstein_Keyword__c> keywords = [ SELECT Id, Uploaded_to_Einstein__c
                                              FROM Einstein_Keyword__c ];
        List<Einstein_Data_Message__c> messages = [ SELECT Id, Uploaded_to_Einstein__c
                                                   	FROM Einstein_Data_Message__c];
        if(!keywords.isEmpty()){
            for (Einstein_Keyword__c keyword: keywords) {
            	keyword.Einstein_Upload_Status__c = status;
        	}
            update keywords;
        }
        if(!messages.isEmpty()){
            for (Einstein_Data_Message__c message: messages) {
                message.Einstein_Upload_Status__c = status;
            }
            update messages;
        }
        setEinsteinEnabled(false);
        setEinsteinDatasetId(null);
        setEinsteinModelId(null);
    }    
}