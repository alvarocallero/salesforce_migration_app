package com.migrator.service;

import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import com.force.sdk.oauth.context.ForceSecurityContextHolder;
import com.force.sdk.oauth.context.SecurityContext;
import com.migrator.file.FileHelper;
import com.migrator.uploader.DocumentUploader;
import com.migrator.workspace.WorkspaceHelper;
import com.sforce.soap.partner.Connector;
import com.sforce.soap.partner.PartnerConnection;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;
import com.sforce.ws.ConnectionException;
import com.sforce.ws.ConnectorConfig;

@Service
public class DocumentServiceImpl implements DocumentService {

	public static PartnerConnection connection;
	final static Logger logger = Logger.getLogger(DocumentServiceImpl.class);

	public void transformDocuments() {
		logger.info("Executing transformDocuments");

		ConnectorConfig config = new ConnectorConfig();
		SecurityContext sc = ForceSecurityContextHolder.get();
		String url = sc.getEndPointHost()+"/services/Soap/u/40.0";
		config.setSessionId(sc.getSessionId());
		config.setServiceEndpoint(url);

		logger.info("Service endPoint is: "+url);
		try {
			connection = Connector.newConnection(config);
			logger.info("Connection successful");
//			DocumentUploader.bulkDocumentUploading();
			// download the documents
			logger.info("Downloading Documents");
			SObject[] documents = getDocuments();

			// upload documents as files to salesforce
			if (documents.length > 0) {

				// create workspace and map folder to workspace
				Map<String, String> folderToContentWorkSpaceMap = new HashMap<String, String>();
				SObject[] folders = getAllFolders();

				logger.info("Creating Folders");
				for (SObject folder : folders) {
					String folderName = getFolderName(folder);
					if (folderName != "null" && folderName != null) {
						String folderId = getFolderId(folder);
						String contentWorkSpaceId = WorkspaceHelper.createContentWorkspace(folderName);
						// mapping folder and contentworkspace
						folderToContentWorkSpaceMap.put(folderId, contentWorkSpaceId);
					}
				}

				logger.info("Uploading Files");
				uploadFile(documents, folderToContentWorkSpaceMap);
			}else{
				logger.info("No documents to migrate");
			}
		} catch (ConnectionException e) {
			logger.error("Error at transformDocuments: " + e);
		}
	}

	private static SObject[] getDocuments() {
		logger.info("Entering getDocuments >>>");
		try {
			// query all the files from salesforce
			QueryResult queryResults = FileHelper.getAllFiles();

			if (queryResults.getSize() > 0) {

				// create a list of SObject from the query files
				SObject[] files = queryResults.getRecords();

				// loop over the files and create files backups
				for (int i = 0; i < files.length; ++i) {
					String fileName = FileHelper.getFileFullName(files[i]);
					String fileId = FileHelper.getFileId(files[i]);
					String fileData = FileHelper.getFileData(fileId);
					FileHelper.createFile(fileName, fileData);
					logger.info("The file " + fileName + " has been created");
				}
			}
			logger.info("Leaving getDocuments <<<");
			return queryResults.getRecords();

		} catch (Exception e) {
			logger.error("Error at getDocuments: " + e);
			return null;
		}
	}

	private static void uploadFile(SObject[] documents, Map<String, String> folderToContentWorkSpaceMap) {
		try {
			String fileName = null;
			logger.info("Entering uploadFile >>>");
			// creation of the ContentVersion SObject
			SObject ContentVersion = new SObject();
			ContentVersion.setType("ContentVersion");

			// add the ContentVersion SObject to the request SObject array
			SObject[] contentArray = {ContentVersion};

			// loop over each file to upload
			for (int a = 0; a < documents.length; a++) {
				fileName = FileHelper.getFileFullName(documents[a]);
				logger.info("Trying to upload the file "+fileName);
				// get all data from the file
				String fileId = FileHelper.getFileId(documents[a]);
				String fileData = FileHelper.getFileData(fileId);
				byte[] fileDataByteArray = FileHelper.fileDataAsByteArray(fileData);
				String fileOwner = FileHelper.getFileOwner(documents[a]);

				// set fields of the SObject and add the data
				ContentVersion.setField("VersionData", fileDataByteArray);
				ContentVersion.setField("Title", fileName);
				ContentVersion.setField("PathOnClient", fileName);

				// create the files and save the response to the request
				SaveResult[] saveResults = connection.create(contentArray);

				// check the result of the request
				if (saveResults[0].isSuccess()) {
					logger.info("Successfully upload file: " + fileName+" ");
					FileHelper.updateFileOwnerId(saveResults[0].getId(), fileOwner);

					String folderid = (String) documents[a].getField("FolderId");
					String workspaceId = folderToContentWorkSpaceMap.get(folderid);
					String contentDocumentId = getContDocIdFromVerId((String) saveResults[0].getId());

					if (workspaceId != null){
						WorkspaceHelper.createContentWorkspaceDoc(workspaceId, contentDocumentId);
					}
				} else {
					logger.error("Error at uploadingFile, file name is "+fileName+" : " + saveResults[0].getErrors()[0].getMessage());
				}
			}

		} catch (Exception e) {
			logger.error("Error on method uploadFile: "+ e);
		}
	}

	// Folder
	private static SObject[] getAllFolders() {
		try {
			QueryResult result = connection.query("SELECT Id,Name FROM Folder");
			SObject[] folders = result.getRecords();
			return folders;
		} catch (Exception e) {
			logger.error("Error on method getAllFolders: " + e);
		}
		return null;
	}

	private static String getFolderId(SObject folder) {
		if (folder.getField("Id") != "") {
			return (String) folder.getField("Id");
		}
		return null;
	}

	private static String getFolderName(SObject folder) {
		if (folder.getField("Name") != "") {
			return (String) folder.getField("Name");
		}
		return null;
	}

	private static String getContDocIdFromVerId(String contentVersionId) {
		try {
			QueryResult result = connection.query("SELECT Id,Title,contentdocumentid FROM Contentversion where id = '" + contentVersionId + "'");
			SObject[] contentDocument = result.getRecords();
			return (String) contentDocument[0].getField("ContentDocumentId");
		} catch (Exception e) {
			logger.error("Error on method getContDocIdFromVerId: " + e);
		}
		return null;
	}

}
