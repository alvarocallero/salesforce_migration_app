package com.migrator.service;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;
import javax.xml.namespace.QName;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;
import com.force.sdk.oauth.context.ForceSecurityContextHolder;
import com.force.sdk.oauth.context.SecurityContext;
import com.migrator.file.FileHelper;
import com.migrator.status.MigrationStatusService;
import com.migrator.webservice.RestCaller;
import com.migrator.workspace.WorkspaceHelper;
import com.sforce.soap.partner.Connector;
import com.sforce.soap.partner.PartnerConnection;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;
import com.sforce.ws.ConnectionException;
import com.sforce.ws.ConnectorConfig;
import com.sforce.ws.bind.XmlObject;

@Service
public class DocumentServiceImpl implements DocumentService {

	public static PartnerConnection connection;
	final static Logger logger = Logger.getLogger(DocumentServiceImpl.class);
	public static final String FILENAME = System.getProperty("user.dir")+"\\src\\main\\resources\\migrationStatus.properties";

	public void transformDocuments(String orgUserName, String orgPassword, String orgSecurityToken) {
		logger.info("Entering transformDocuments >>>");

		Properties properties = new Properties();
		try {
			InputStream in = new FileInputStream(FILENAME);
			properties.load(in);
			in.close();
		} catch (IOException e1) {
			logger.error("Error loading migrationStatus.properties: "+e1);
		}

		ConnectorConfig config = new ConnectorConfig();
		SecurityContext sc = ForceSecurityContextHolder.get();
		String url = sc.getEndPointHost();
		config.setSessionId(sc.getSessionId());

		//Set the API version to 40.0
		config.setServiceEndpoint(url+"/services/Soap/u/40.0");
		
		try {
			connection = Connector.newConnection(config);
			QName headerName = new QName("urn:enterprise.soap.sforce.com", "CallOptions"); 
			XmlObject header = new XmlObject(headerName, null); 
			header.addField("client", "Altimetrik/DocumentsToFilesMigrator/"); 
			connection.addExtraHeader(headerName, header);
			
			//When attempting to create a batch of objects, if some object creation fails then the action is rolledBack
			connection.setAllOrNoneHeader(true);
			
			logger.info("Connection successful");
			logger.info("Service endPoint is: "+url);
		} catch (Exception e) {
			logger.error("Error creating the connection: "+e);
		}

		int cantDocuments=cantDocuments=getDocumentsCount();
		if (cantDocuments > 0){
			int currentPage;
			String orgId=sc.getOrgId();;
			String lastDocumentId=null;
			Boolean firstTime;
			try {
				//if the org already exist, the migration continues, otherwise the status of the migration is recovered
				if (properties.getProperty("orgId") != null && !properties.getProperty("orgId").equals("") && orgId.equals(properties.getProperty("orgId"))){
					logger.info("The migration process will continue");
					cantDocuments=Integer.valueOf(properties.getProperty("cantDocs"));
					currentPage=Integer.valueOf(properties.getProperty("currentPage"));
					lastDocumentId=properties.getProperty("lastDocumentId");
					firstTime=false;
				}else{
					logger.info("There´s no previous migration process");
					currentPage=1;
					firstTime=true;
					MigrationStatusService.updatePropertiesStatus(orgId,currentPage,cantDocuments);
				}
				String accessToken = RestCaller.getAccesToken(orgUserName,orgPassword,orgSecurityToken);
				
				SObject[] arrayOfDocuments = null;
				Boolean migrationFinish = false;
				logger.info("The amount of documents found is: "+cantDocuments);
				TreeMap<String, String> mapOfCWSIdAndName = mapOfCWSIdAndName = WorkspaceHelper.getAllContentWorkSpace();
				//avoids reaching the 2000 documents migration
				while(getAmountOfMIgratedDocumentsToday() <= 1800 && !migrationFinish){
					logger.info("Processing page: "+currentPage);
					if(firstTime || currentPage == 1){
						arrayOfDocuments = FileHelper.getFirst200Documents();
						lastDocumentId = (String)arrayOfDocuments[arrayOfDocuments.length - 1].getField("Id");
						MigrationStatusService.updateDocumentLastId(lastDocumentId);
						firstTime=false;
					}else{
						arrayOfDocuments = FileHelper.getnext200Documents(lastDocumentId);
						if(arrayOfDocuments.length != 0){
							lastDocumentId = (String)arrayOfDocuments[arrayOfDocuments.length - 1].getField("Id");
							MigrationStatusService.updateDocumentLastId(lastDocumentId);
						}else{
							migrationFinish=true;
						}
					}
					if(arrayOfDocuments.length == 0){
						logger.info("No more documents to migrate");
					}else{
						TreeMap<String, String> mapOfFolderIdAndName = getAllFoldersFromDocuments(arrayOfDocuments);
						mapOfCWSIdAndName = WorkspaceHelper.createContentWorkspace(arrayOfDocuments, mapOfCWSIdAndName, mapOfFolderIdAndName); 
						createContentVersionBatch(arrayOfDocuments,mapOfCWSIdAndName,url,accessToken,mapOfFolderIdAndName);
						logger.info("Page "+currentPage+" processed");
						currentPage+=1;
						MigrationStatusService.updateCurrentPage(currentPage);
					}
				}
				MigrationStatusService.cleanProperties();
			} catch (Exception e) {
				logger.error("Error on the migration: "+e);
			}
		}else{
			logger.info("No documents to migrate in the org");
		}
	}

	public static void createContentVersionBatch(SObject[] arrayOfDocuments, TreeMap<String, String> mapOfCWSIdAndName, String url, String accessToken,TreeMap<String, String> mapOfFolderIdAndName){
		logger.info("Entering createContentVersionBatch >>>");
		
		//Map <ContentVersionId,FileOwner> to call updateFileOwnerId, map to update the file owner
		TreeMap<String,String> mapIdContentVAndFileOwner = new TreeMap<String,String>();

		//Map <ContentVersionId,DocumentId> to call createContentWorkspaceDoc, map to send to the Rest Api to create the body of the files
		TreeMap<String,String> mapOfContentVerIdAndDocumentId = new TreeMap<String,String>();

		//List<String[folderId,ContentDocId]> list to send to create the ContentWorkspaceDoc
		List<String[]> lstOfFolderIdAndContentDocId = new LinkedList<String[]>();

		List<String> lstOfContentVersionId = new LinkedList<String>();
		SObject[] contentVersionArrayToCreate = new SObject[arrayOfDocuments.length]; 

		//Creation of array of 200 ContentVersion
		for (int i=0;i<arrayOfDocuments.length;i++){
			SObject contentVersion = new SObject();
			contentVersion.setType("ContentVersion");
			String fileName = FileHelper.getFileFullName(arrayOfDocuments[i]);
			byte[] fileDataByteArray = FileHelper.fileDataAsByteArray("asdsaetretrertreterterttretretretretretterttretretretretretterttretretretretretterttretretretretretretertetretertretetdsaa");

			contentVersion.setField("VersionData", fileDataByteArray);
			contentVersion.setField("Title", fileName);
			contentVersion.setField("PathOnClient", fileName);
			contentVersion.setField("IsMajorVersion", false);
			contentVersionArrayToCreate[i]=contentVersion;
		}
		try {
			//Send to create a request of 200 ContentVersion
			SaveResult[] saveResults = DocumentServiceImpl.connection.create(contentVersionArrayToCreate);
			for (int i=0;i<saveResults.length;i++){
				if(!saveResults[i].getSuccess()){
					logger.info("Error at createContentVersionBatch: " + saveResults[i].getErrors()[i].getMessage());
					System.exit(0);
				}
				else if (saveResults[i].getId() != null){
					mapIdContentVAndFileOwner.put(saveResults[i].getId(), FileHelper.getFileOwner(arrayOfDocuments[i]));
					mapOfContentVerIdAndDocumentId.put((String)arrayOfDocuments[i].getField("Id"),saveResults[i].getId());
					lstOfContentVersionId.add(saveResults[i].getId());
				}
			}
			logger.info("Batch of ContentVersion created successfully");
			updatefileOwnerId(mapIdContentVAndFileOwner);

			List<String> lstOfContentDocsId = getContDocIdFromVerId(lstOfContentVersionId);
			String folderId;

			TreeMap<String,String> mapOfFolderIdAndCwsId = WorkspaceHelper.createMapOfcwsIdAndCwsId(mapOfCWSIdAndName,mapOfFolderIdAndName);
			for(int j=0;j<lstOfContentDocsId.size();j++){
				folderId = (String)arrayOfDocuments[j].getField("FolderId");
				String[] cwsIdAndContentDocIdstring = new String[2];
				//Its a personal folder
				if(!folderId.startsWith("005")){
					cwsIdAndContentDocIdstring[0]=(String)mapOfFolderIdAndCwsId.get(folderId);
					cwsIdAndContentDocIdstring[1]=lstOfContentDocsId.get(j);
					lstOfFolderIdAndContentDocId.add(cwsIdAndContentDocIdstring);
				}
			}
			createContentWorkspaceDoc(lstOfFolderIdAndContentDocId);

			//Call the Apex class to create the VersionData of the ContentVersion
			RestCaller.callApiRestToCreateContentVersionData(url, accessToken,mapOfContentVerIdAndDocumentId);
		} catch (ConnectionException e) {
			logger.error("Error on method createContentVersionBatch: "+ e);
			System.exit(0);
		}
	}

	private static void createContentWorkspaceDoc(List<String[]> lstOfFolderIdAndContentDocId ) {
		logger.info("Entering createContentWorkspaceDoc >>>");
		try {
			SObject[] request = new SObject[lstOfFolderIdAndContentDocId.size()];
			int i=0;
			for(String[] entry : lstOfFolderIdAndContentDocId){
				SObject contentWorkspaceDoc = new SObject();
				contentWorkspaceDoc.setType("ContentWorkspaceDoc");
				contentWorkspaceDoc.setField("ContentWorkspaceId", entry[0]);
				contentWorkspaceDoc.setField("ContentDocumentId", entry[1]);
				request[i]=contentWorkspaceDoc;
				i++;
			}
			SaveResult[] saveResults = connection.create(request);
			for(int j=0;j<saveResults.length;j++){
				if(!saveResults[j].getSuccess()){
					logger.info("Error at createContentWorkspaceDoc: " + saveResults[j].getErrors()[j].getMessage());
					System.exit(0);
				}
			}
			logger.info("Batch of ContentWorkspaceDoc created successfully");
		} catch (Exception e) {
			logger.error("Error on createContentWorkspaceDoc: "+e);
			System.exit(0);
		}
		logger.info("Leaving createContentWorkspaceDoc <<<");
	}

	public static void updatefileOwnerId(TreeMap<String,String> mapIdContentVAndFileOwner){
		logger.info("Entering updatefileOwnerId >>>");
		try {
			SObject[] updateContentVersionArray = new SObject[mapIdContentVAndFileOwner.size()];
			int i = 0;
			for(Map.Entry<String, String> entry : mapIdContentVAndFileOwner.entrySet()){
				SObject updateContentVersion = new SObject();
				updateContentVersion.setType("ContentVersion");
				updateContentVersion.setId(entry.getKey());
				updateContentVersion.setField("OwnerId", entry.getValue());
				updateContentVersionArray[i]=updateContentVersion;
				i++;
			}
			SaveResult[] saveResults =  DocumentServiceImpl.connection.update(updateContentVersionArray);
			for(int j=0;j<saveResults.length;j++){
				if(!saveResults[j].getSuccess()){
					logger.info("Error at updatefileOwnerId: " + saveResults[j].getErrors()[j].getMessage());
					System.exit(0);
				}
			}
			logger.info("FileOwnerId updated successfully");
			logger.info("Leaving updatefileOwnerId <<<");
		} catch (Exception e) {
			logger.error("Error on method updatefileOwnerId: " + e);
			System.exit(0);
		}
	}


	private int getDocumentsCount(){
		int resultQuery = -1;
		try {
			QueryResult result = connection.query("SELECT count() from Document");
			resultQuery= result.getSize();
			if(resultQuery == 0){
				logger.info("No documents found");
			}
		} catch (Exception e) {
			logger.error("Error on method getDocumentsCount(): " + e);
			System.exit(0);
		}
		return resultQuery;
	}

	public static List<String> filterFolderIdFromDocuments(SObject[] docsArray){
		List<String> resultLst = new LinkedList<String>();
		for (SObject doc : docsArray){
			resultLst.add((String)doc.getField("FolderId"));
		}
		return resultLst;
	}

	private static TreeMap <String,String> getAllFoldersFromDocuments(SObject[] arrayOfDocs) {
		logger.info("Entering getAllFoldersFromDocuments >>>");
		// Map <FolderId,FolderName>
		TreeMap <String,String> resultMap = new TreeMap<String,String>();
		try {
			List<String> lstOfFolderIds = new LinkedList<String>();
			for (SObject doc : arrayOfDocs){
				lstOfFolderIds.add((String)doc.getField("FolderId"));
			}
			String folderIdsStr = "(";
			for (String id : lstOfFolderIds){
				folderIdsStr+="'"+id+"',";
			}
			folderIdsStr=folderIdsStr.substring(0, folderIdsStr.length()-1);
			folderIdsStr+=")";
			QueryResult result = connection.query("SELECT Id,Name FROM Folder where id in "+folderIdsStr);
			SObject[] folders = result.getRecords();
			for(SObject obj : folders){
				resultMap.put((String)obj.getField("Id"),(String) obj.getField("Name"));
			}
			return resultMap;
		} catch (Exception e) {
			logger.error("Error on method getAllFoldersFromDocuments: " + e);
			System.exit(0);
		}
		logger.info("Leaving getAllFoldersFromDocuments <<<");
		return resultMap;
	}

	public static List<SObject> sobjectArrayToList(SObject[] sobjectArray){
		List<SObject> lst = new LinkedList<SObject>();
		for (int i =0; i<sobjectArray.length; i++){
			lst.add(sobjectArray[i]);
		}
		return lst;
	}

	private static List<String> getContDocIdFromVerId(List<String> lstOfContentVersionId) {
		logger.info("Entering getContDocIdFromVerId >>>");
		List<String> lstOfContentDocumentId = new LinkedList<String>();
		try {
			String contentVersionString = "(";
			for (String id : lstOfContentVersionId){
				contentVersionString+="'"+id+"',";
			}
			contentVersionString=contentVersionString.substring(0, contentVersionString.length()-1);
			contentVersionString+=")";

			QueryResult result = connection.query("SELECT contentdocumentid FROM Contentversion where id in "+contentVersionString);
			for(SObject contentVersion : result.getRecords()){
				lstOfContentDocumentId.add((String)contentVersion.getField("ContentDocumentId"));
			}
			logger.info("Leaving getContDocIdFromVerId <<<");
		} catch (Exception e) {
			logger.error("Error at getContDocIdFromVerId: "+e);
			System.exit(0);
		}
		return lstOfContentDocumentId;
	}
	
		private int getAmountOfMIgratedDocumentsToday(){
			int resultQuery = -1;
			try {
				QueryResult result = connection.query("select count() from ContentVersion where createdDate = TODAY");
				resultQuery= result.getSize();
				if(resultQuery == 0){
					logger.info("There are no migrated documents yet");
				}
			} catch (Exception e) {
				logger.error("Error on method getAmountOfMIgratedDocumentsToday: " + e);
				System.exit(0);
			}
			return resultQuery;
		}
}

