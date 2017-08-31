package com.migrator.webservice;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.TreeMap;

import org.apache.http.HttpStatus;
import org.apache.http.ParseException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.json.JSONTokener;

public class RestCaller{
	
	final static Logger logger = Logger.getLogger(RestCaller.class);


	private static final String CONSUMER_KEY = "3MVG9zlTNB8o8BA3gG6ULH657ove3UkpU4dLffeAJmVGAtT_.nOYEI3E0DhysiMGrV5_KpARCyRL4upUTRoqU";
	private static final String CONSUMER_SECRET = "4329211162267730076";

	public static String getAccesToken(){
		logger.info("Entering getAccesToken() >>>");
		StringBuilder url = new StringBuilder();
		url.append("https://login.salesforce.com/services/oauth2/token?grant_type=password")
		.append("&client_id=")
		.append(CONSUMER_KEY)
		.append("&client_secret=")
		.append(CONSUMER_SECRET)
		.append("&username=")
		.append("fvecino@trial1enterprise.com")
		.append("&password=")
		.append("test1234")
		.append("eviweRTqoaysZLNQpfB2HPduh");
		JSONObject jsonObject = null;
		try{
			DefaultHttpClient httpClient = new DefaultHttpClient();
			HttpPost httpPost = new HttpPost(url.toString());
			CloseableHttpResponse response = httpClient.execute(httpPost);
			final int statusCode = response.getStatusLine().getStatusCode();
			if (statusCode != HttpStatus.SC_OK) {
				logger.error("Error getting access token: " + response.getStatusLine().getReasonPhrase());
				return null;
			}
			String responseString = EntityUtils.toString(response.getEntity());
			jsonObject = (JSONObject) new JSONTokener(responseString).nextValue();
			
		}catch (IOException e) {
			logger.error("Error at getAccesToken: "+e);
		}
		logger.info("Leaving getAccesToken <<<");
		return jsonObject.getString("access_token");
	}
	
	
	public static String callApiRest(String url, String accessToken, TreeMap<String,String> mapIdContentVAndFileOwner)  {
		logger.info("Entering callApiRest >>>");
		String responseReturn=null;
        try{
        	DefaultHttpClient httpclient = new DefaultHttpClient();
        	
            JSONObject json = new JSONObject(mapIdContentVAndFileOwner);
            String requestUrl = url+"/services/apexrest/contentMigrator/ContentMigrator/";
            HttpPost httpost = new HttpPost(requestUrl);
            httpost.addHeader("Authorization", "Bearer " + accessToken);
            httpost.addHeader("Content-type", "application/json");
            StringEntity messageEntity = new StringEntity(json.toString(), ContentType.create("application/json"));
            httpost.setEntity(messageEntity);
            CloseableHttpResponse response = null;
			try {
				response = httpclient.execute(httpost);
			} catch (IOException e) {
				logger.error("Error at callApiRest: "+e);
			}
            // verify response is HTTP OK
            final int statusCode = response.getStatusLine().getStatusCode();
            if (statusCode != HttpStatus.SC_OK) {
                if (statusCode == HttpStatus.SC_UNAUTHORIZED) {
                	logger.error("Seems the access token is not valid. Error from WS: " + response.getStatusLine().getReasonPhrase());
                }
            }
            logger.info("The REST API result code is: "+statusCode);
			try {
				responseReturn = EntityUtils.toString(response.getEntity());
			} catch (ParseException | IOException e) {
				logger.error("Error getting the response for the rest call: "+e);
			}
			logger.info("Leaving callApiRest <<<");
            System.out.println("Response message: "+ responseReturn);
        }catch(Exception e){
        	logger.error("Error at callApiRest: "+e);
        }
        return responseReturn;
    }
	
}
