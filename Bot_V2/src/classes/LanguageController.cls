public class LanguageController {    
	// Einstein API Version: 2.0
    public static String getAccessToken() {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = 'etorrano@altimetrik.com';
        jwt.aud = 'https://api.metamind.io/v1/oauth2/token';
        jwt.exp = '3600';
        String access_token = JWTBearerFlow.getAccessToken('https://api.metamind.io/v1/oauth2/token', jwt);
        return access_token;
    }

    /*******************************************************************************************************
    * @description Uploads a dataset to Einstein providing the file as parameter.
	* The upload is ascynchronous so it is needed to check if it was uploaded with the getDataset()    
	* @param params 
    * List of API parameters. The supported params are detailed below with 'params.' as prefix.
    * @param params.name OPTIONAL
    * Name of the dataset. Optional. If this parameter is omitted, the dataset name is derived from the file name.
    * @param file
    * A .csv, .tsv or .json file. You must include the appropriate file extension. The maximum file size from a local drive is 50 MB.
    * @param fileFormat
    * One of the supported formats defined in Language: .csv, .tsv or .json
	* @return a String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request        
        {
          "id": 1001408,
          "name": "weather",
          "createdAt": "2017-06-05T20:33:56.000+0000",
          "updatedAt": "2017-06-05T20:33:56.000+0000",
          "labelSummary": {
            "labels": []
          },
          "totalExamples": 0,
          "available": false,
          "statusMsg": "UPLOADING",
          "type": "text-intent",
          "object": "dataset"
        }
    * @example
    * Map<String, String> params = new Map<String, String>();
    * params.put('name', 'dbSampleName.json');
    * String result = LanguageController.createDataset(params, file);
    */
    public static String createDataset(Map<String, String> params, Blob file) {
        String access_token = getAccessToken();
        params.put('type', 'text-intent');
        String result = Language.apiCallUploadFile('/datasets/upload',access_token,params,'POST','data',file);
        Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        if (jsonResult.containsKey('id')){
            EinsteinUtils.setEinsteinDatasetId((Decimal)jsonResult.get('id'));
        } else {
        	throw new Language.LanguageException('Could not save the datasetId. The result json has not got the datasetId.');
        }
        return result;
	}
    
    /*******************************************************************************************************
    * @description Uploads a dataset to Einstein providing the file's location URL. 
    * The upload is ascynchronous so it is needed to check if it was uploaded with the getDataset()
	* @param params 
	* List of API parameters. The supported params are detailed below with 'params.' as prefix.
    * @param params.name OPTIONAL
    * Name of the dataset. Optional. If this parameter is omitted, the dataset name is derived from the file name.
    * @param params.path
    * URL of the .csv, .tsv, or .json file. The maximum file size is 1 GB.
	* @return Returns a String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request        
        {
          "id": 1001408,
          "name": "weather",
          "createdAt": "2017-06-05T20:33:56.000+0000",
          "updatedAt": "2017-06-05T20:33:56.000+0000",
          "labelSummary": {
            "labels": []
          },
          "totalExamples": 0,
          "available": false,
          "statusMsg": "UPLOADING",
          "type": "text-intent",
          "object": "dataset"
        }
    * @example
    * Map<String, String> params = new Map<String, String>();
    * params.put('name', 'dbSampleName');
    * params.put('path', 'http://example.com/example.csv');
    * String result = LanguageController.createDatasetURL(params);
    */
    public static String createDatasetURL(Map<String, String> params) {
        if(!params.isEmpty()){           
            String access_token = getAccessToken();
            params.put('type', 'text-intent');
            String result = Language.apiCall('/datasets/upload',access_token,params,'POST');
            Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            if (jsonResult.containsKey('id')){
                EinsteinUtils.setEinsteinDatasetId((Decimal)jsonResult.get('id'));
            } else { 
                throw new Language.LanguageException('Could not save the datasetId. The result json has not got the datasetId.');
            }
            return result;
        }        
        else throw new Language.LanguageException('Could not save the datasetId. The result json has not got the datasetId.');
    }
    
    /*******************************************************************************************************
    * @description Get dataset's description.
    * It is needed to check if it was successfully uploaded checking it status.
    * @param datasetId Dataset identifier
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
        {
          "id": 1001408,
          "name": "weather",
          "createdAt": "2017-06-05T20:33:56.000+0000",
          "updatedAt": "2017-06-05T20:33:58.000+0000",
          "labelSummary": {
            "labels": [
              {
                "id": 13298,
                "datasetId": 1001408,
                "name": "hourly-forecast",
                "numExamples": 23
              }
            ]
          },
          "totalExamples": 23,
          "totalLabels": 1,
          "available": true,
          "statusMsg": "SUCCEEDED",
          "type": "text-intent",
          "object": "dataset"
        }
    * @example
    * String result = LanguageController.getDataset(datasetId);
    */
    public static String getDataset(String datasetId) {
        String access_token = getAccessToken();
		return Language.apiCall('/datasets/'+datasetId,access_token,new Map<String, String>(),'GET');
    }
    
    /*******************************************************************************************************
    * @description Deletes a dataset.
    * @param datasetId Dataset's identifier.
	* @return This call doesn’t return a response body. Instead, it returns an HTTP status code 204 or 400.
    * @example
    * String result = LanguageController.deleteDataset('12345667');
    */
    public static String deleteDataset(String datasetId) {
		String access_token = getAccessToken();
		return Language.apiCall('/datasets/'+datasetId,access_token,new Map<String, String>(),'DELETE');
    }
    
    /*******************************************************************************************************
    * @description Creates a model from the provided dataset.
	* @param params 
	* List of API parameters. The supported params are detailed below with 'params.' as prefix.
    * @param params.name
    * Name for the new model. Maximum length: 180 characters.
    * @param params.datasetId 
    * Dataset's identifier.
    * @param params.epochs OPTIONAL
    * Number of training iterations for the neural network. 
    * If not specified, the default is calculated based on the dataset size. 
    * The larger the number, the longer the training takes to complete.
    * @param params.trainParams OPTIONAL
    * JSON to specify how the model is created. Valid values are detailed with 'params.trainParams' prefix.
    * @param params.trainParams.trainSplitRatio OPTIONAL
    * Double to specify the ratio of data used to train the dataset. Default 0.8
    * @param params.trainParams.withFeedback
    * Boolean to specify if feedback examples are included in the data to be trained to create the model.
    * @param params.trainParams.withGlobalDatasetId
    * String with a global dataset Id to use in addition to the specified dataset to create the model.
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
        {
          "datasetId": 1001411,
          "datasetVersionId": 0,
          "name": "Weather Intent Model",
          "status": "QUEUED",
          "progress": 0,
          "createdAt": "2017-06-08T22:16:16.000+0000",
          "updatedAt": "2017-06-08T22:16:16.000+0000",
          "learningRate": 0,
          "epochs": 0,
          "queuePosition": 1,
          "object": "training",
          "modelId": "UCW5CHIJ7MXLZ7UYE5MO44TPPU",
          "trainParams": null,
          "trainStats": null,
          "modelType": "text-intent"
        }
	* @example
    * Map<String, String> params = new Map<String, String>();
    * params.put('name', 'modelSampleName');
    * params.put('datasetId', '1234567');
    * String result = LanguageController.train(params);
    */
    public static String train(Map<String, String> params) {
		String access_token = getAccessToken();
        if(!params.isEmpty()){
            String result = Language.apiCall('/train',access_token,params,'POST');
            Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            if (jsonResult.containsKey('modelId')){
                EinsteinUtils.setEinsteinModelId((String)jsonResult.get('modelId'));
            } else { 
                throw new Language.LanguageException('Could not save the datasetId. The result json has not got the datasetId.');
            }
            return result;
            
        }
        else{
            throw new Language.LanguageException('Could not save the modelId. The result json has not got the modelId.');
        }
    }
    
    /*******************************************************************************************************
    * @description Trains a model from the provided dataset.
    * The data that uses to train are the last uploaded examples or reported feedback.
    * This API call is async, so it is needed to check the train status with getTrainStatus
	* @param params 
	* List of API parameters. The supported params are detailed below with 'params.' as prefix.
    * @param params.modelId 
    * Model's identifier.
    * @param params.epochs OPTIONAL
    * Number of training iterations for the neural network. 
    * If not specified, the default is calculated based on the dataset size. 
    * The larger the number, the longer the training takes to complete.
    * @param params.trainParams OPTIONAL
    * JSON to specify how the model is created. Valid values are detailed with 'params.trainParams' prefix.
    * @param params.trainParams.trainSplitRatio OPTIONAL
    * Double to specify the ratio of data used to train the dataset. Default 0.8
    * @param params.trainParams.withFeedback
    * Boolean to specify if feedback examples are included in the data to be trained to create the model.
    * @param params.trainParams.withGlobalDatasetId
    * String with a global dataset Id to use in addition to the specified dataset to create the model.
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
		{
            "datasetId": 1001511,
            "datasetVersionId": 1151,
            "name": "Weather Model",
            "status": "SUCCEEDED",
            "progress": 1,
            "createdAt": "2017-06-12T17:22:24.000+0000",
            "updatedAt": "2017-06-12T17:24:26.000+0000",
            "learningRate": 0,
            "epochs": 300,
            "object": "training",
            "modelId": "TUWBAIRLFB3KKEDZMEGIUR6COM",
            "trainParams": null,
            "trainStats": {
            "labels": 3,
            "examples": 73,
            "totalTime": "00:01:55:176",
            "trainingTime": "00:01:53:834",
            "earlyStopping": true,
            "lastEpochDone": 191,
            "modelSaveTime": "00:00:00:481",
            "testSplitSize": 11,
            "trainSplitSize": 62,
            "datasetLoadTime": "00:00:01:342"
            },
            "modelType": "text-intent"
    	}
    * @example
    * Map<String, String> params = new Map<String, String>();
    * params.put('modelId', '1234567');
    * String result = LanguageController.retrain(params);
    */
    public static String retrain(Map<String, String> params) {
		String access_token = getAccessToken();
        if(!params.isEmpty()){ 
            return Language.apiCall('/retrain',access_token,params,'POST');
        }
        else{
            return 'Error';
        }
    }
    
    /*******************************************************************************************************
    * @description Returns the status of a training job.
    * This API call is async, so it is needed to check the
    * Use the progress field to determine how far the training has progressed. 
    * When training completes successfully, the status is SUCCEEDED and the progress is 1.
	* @param modelId 
    * Model's identifier.
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
    {
      "datasetId": 1001511,
      "datasetVersionId": 1073,
      "name": "Weather Intent Model",
      "status": "SUCCEEDED",
      "progress": 1,
      "createdAt": "2017-06-09T19:05:37.000+0000",
      "updatedAt": "2017-06-09T19:07:31.000+0000",
      "learningRate": 0,
      "epochs": 300,
      "object": "training",
      "modelId": "TUWBAIRLFB3KKEDZMEGIUR6COM",
      "trainParams": null,
      "trainStats": {
        "labels": 3,
        "examples": 73,
        "totalTime": "00:01:51:120",
        "trainingTime": "00:01:49:959",
        "earlyStopping": true,
        "lastEpochDone": 186,
        "modelSaveTime": "00:00:00:618",
        "testSplitSize": 11,
        "trainSplitSize": 62,
        "datasetLoadTime": "00:00:01:161"
      },
      "modelType": "text-intent"
    }
    * @example
    * String result = LanguageController.getTrainStatus('1234556');
    */
    public static String getTrainStatus(String modelId) {
		String access_token = getAccessToken();
		return Language.apiCall('/train/'+modelId,access_token,new Map<String, String>(),'GET');
    }

    /*******************************************************************************************************
    * @description Adds examples to the specified dataset from a .csv, .tsv, or .json file.
    * This is an ascynchronous call so it is needed to check if it was uploaded with the getDataset()
	* @param file
    * A .csv, .tsv or .json file. You must include the appropriate file extension. The maximum file size from a local drive is 50 MB.
    * @param fileFormat
    * One of the supported formats defined in Language: .csv, .tsv or .json    
	* @return a String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request        
        {
          "id": 1001412,
          "name": "weather",
          "createdAt": "2017-06-05T21:55:53.000+0000",
          "updatedAt": "2017-06-06T21:57:10.000+0000",
          "labelSummary": {
            "labels": [
              {
                "id": 13313,
                "datasetId": 1001412,
                "name": "hourly-forecast",
                "numExamples": 46
              },
              {
                "id": 13314,
                "datasetId": 1001412,
                "name": "current-weather",
                "numExamples": 58
              },
              {
                "id": 13315,
                "datasetId": 1001412,
                "name": "five-day-forecast",
                "numExamples": 42
              }
            ]
          },
          "totalExamples": 146,
          "totalLabels": 3,
          "available": false,
          "statusMsg": "UPLOADING",
          "type": "text-intent",
          "object": "dataset"
        }
    * @example
    * String result = LanguageController.createExample('1234566', 'file.json');
    */
    public static String createExample(String datasetId, Blob file) {
        String access_token = getAccessToken();
        Map<String, String> params = new Map<String, String>();
        return Language.apiCallUploadFile('/datasets/' + datasetId + '/upload',access_token,params,'PUT','data',file);
	}
    
    /*******************************************************************************************************
    * @description Adds examples to the specified dataset providing a file's location URL.
    * The upload is ascynchronous so it is needed to check if it was uploaded with the getDataset()
	* @param url
    * URL of the .csv, .tsv, or .json file. The maximum file size is 1 GB.
    * @param datasetId
    * Dataset's identifier.
	* @return Returns a String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request        
        {
          "id": 1001412,
          "name": "weather",
          "createdAt": "2017-06-05T21:55:53.000+0000",
          "updatedAt": "2017-06-06T21:57:10.000+0000",
          "labelSummary": {
            "labels": [
              {
                "id": 13313,
                "datasetId": 1001412,
                "name": "hourly-forecast",
                "numExamples": 46
              },
              {
                "id": 13314,
                "datasetId": 1001412,
                "name": "current-weather",
                "numExamples": 58
              },
              {
                "id": 13315,
                "datasetId": 1001412,
                "name": "five-day-forecast",
                "numExamples": 42
              }
            ]
          },
          "totalExamples": 146,
          "totalLabels": 3,
          "available": false,
          "statusMsg": "UPLOADING",
          "type": "text-intent",
          "object": "dataset"
        }
    * @example
    * String result = LanguageController.createExampleURL('https:www.example.com/sample.csv', '123434565');
    */    
    public static String createExampleURL(String url, String datasetId) {
		String access_token = getAccessToken();
		Map<String, String> parameters = new Map<String, String>();
        parameters.put('path', url);
		return Language.apiCall('/datasets/' + datasetId + '/upload',access_token,parameters,'PUT');
    }
    
    /*******************************************************************************************************
    * @description Returns the status of a training job.
    * This API call is async, so it is needed to check the
    * Use the progress field to determine how far the training has progressed. 
    * When training completes successfully, the status is SUCCEEDED and the progress is 1.
	* @param modelId
    * Model's identifier.
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
        {
          "id": 1001412,
          "name": "weather",
          "createdAt": "2017-06-05T21:55:53.000+0000",
          "updatedAt": "2017-06-06T21:57:10.000+0000",
          "labelSummary": {
            "labels": [
              {
                "id": 13313,
                "datasetId": 1001412,
                "name": "hourly-forecast",
                "numExamples": 46
              },
              {
                "id": 13314,
                "datasetId": 1001412,
                "name": "current-weather",
                "numExamples": 58
              },
              {
                "id": 13315,
                "datasetId": 1001412,
                "name": "five-day-forecast",
                "numExamples": 42
              }
            ]
          },
          "totalExamples": 146,
          "totalLabels": 3,
          "available": false,
          "statusMsg": "UPLOADING",
          "type": "text-intent",
          "object": "dataset"
        }
    * @example
    * String result = LanguageController.getAllExamples('1234556');
    */    
    public static String getAllExamples(String modelId) {
        String access_token = getAccessToken();
		return Language.apiCall('/train/'+modelId,access_token,new Map<String, String>(),'GET');
    }
    
    /*******************************************************************************************************
    * @description Adds a feedback example to the dataset associated with the specified model.
	* @param params 
	* List of API parameters. The supported params are detailed below with 'params.' as prefix.
    * @param params.modelId 
    * Model's identifier.
    * @param params.document 
    * Intent or sentiment string to add to the dataset.
    * @param params.expectedLabel 
    * Correct label for the example. Must be a label that exists in the dataset.
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
		{
          "id": 1048038,
          "name": "text-intent",
          "location": "is it snowing in Denver",
          "createdAt": "2017-06-09T21:23:11.000+0000",
          "label": {
            "id": 16611,
            "datasetId": 1001511,
            "name": "current-weather",
            "numExamples": 32
          },
          "object": "example"
        }
    * @example
    * Map<String, String> params = new Map<String, String>();
    * params.put('modelId', '3CMCRC572BD3OZTQSTTUU4733Y');
    * params.put('document', 'Is it snowing in Denver');
    * params.put('expectedLabel', 'current-weather');
    * String result = LanguageController.createFeedback(params);
    */
    public static String createFeedback(Map<String, String> params) {
        String access_token = getAccessToken();
		return Language.apiCall('/feedback',access_token,params,'POST');
    }
    
    /*******************************************************************************************************
    * @description Returns the metrics for a model: f1 score, accuracy, and confusion matrix. 
	* @param modelId
    * Model's identifier.
	* @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
		{
            "metricsData": {
                "f1": [
                    1,
                    1,
                    1
                ],
                "labels": [
                    "hourly-forecast",
                    "current-weather",
                    "five-day-forecast"
                ],
                "testAccuracy": 1,
                "trainingLoss": 0.05498850766208864,
                "confusionMatrix": [
                    [
                        5,
                        0,
                        0
                    ],
                    [
                        0,
                        4,
                        0
                    ],
                    [
                        0,
                        0,
                        2
                    ]
                ],
                "trainingAccuracy": 1
            },
            "createdAt": "2017-06-09T18:55:25.000+0000",
            "id": "TUWBAIRLFB3KKEDZMEGIUR6COM",
            "object": "metrics"
    	}
    * @example
    * String result = LanguageController.getAllMetrics('1234556');
    */    
    public static String getModelMetrics(String modelId) {
        String access_token = getAccessToken();
		return Language.apiCall('/models/'+modelId,access_token,new Map<String, String>(),'GET');
    }
    
    /*******************************************************************************************************
    * @description Returns an intent prediction for the given string.
	* @param params 
	* List of API parameters. The supported params are detailed below with 'params.' as prefix.
    * @param params.modelId 
    * Model's identifier.
    * @param params.document 
    * Text for which you want to return an intent prediction.
    * @param params.numResults OPTIONAL
    * Number of probabilities to return.
    * @param params.sampleId OPTIONAL
    * String that you can pass in to tag the prediction.
	* The response is sorted by probability in descending order.
    * @return String with the response: HTTPResponse.getBody()
    * 200 OK || 400 Bad Request           
        {
            "probabilities": [
                {
                    "label": "current-weather",
                    "probability": 0.9904295
                },
                {
                    "label": "five-day-forecast",
                    "probability": 0.009345241
                },
                {
                    "label": "hourly-forecast",
                    "probability": 0.00022528473
                }
            ]
        }
    * @example
    * Map<String, String> params = new Map<String, String>();
    * params.put('modelId', '3CMCRC572BD3OZTQSTTUU4733Y');
    * params.put('document', 'what is the weather in los angeles');
    * String result = LanguageController.predict(params);
    */
    public static String predict(Map<String, String> params) {
        String access_token = getAccessToken();
		return Language.apiCall('/intent',access_token,params,'POST');
    }
}