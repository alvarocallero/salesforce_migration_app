package com.migrator.workspace;

import org.apache.log4j.Logger;

import com.migrator.service.DocumentServiceImpl;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;

public class WorkspaceHelper {
	
	final static Logger logger = Logger.getLogger(WorkspaceHelper.class);
	
	public static String createContentWorkspaceDoc(String contentWorkSpaceId, String contentDocumentId) {
		try {
			logger.info("Entering createContentWorkspaceDoc >>>");
			// creation of the ContentWorkspaceDoc SObject
			SObject contentWorkspaceDoc = new SObject();
			contentWorkspaceDoc.setType("ContentWorkspaceDoc");

			// add the ContentWorkspaceDoc SObject to the request SObject array
			SObject[] request = {contentWorkspaceDoc};

			// set fields of the SObject and add the data
			contentWorkspaceDoc.setField("ContentWorkspaceId", contentWorkSpaceId);
			contentWorkspaceDoc.setField("ContentDocumentId", contentDocumentId);

			// create the files and save the response to the request
			SaveResult[] saveResults = DocumentServiceImpl.connection.create(request);

			// check the result of the request
			if (saveResults[0].isSuccess()) {
				logger.info("Successfully create link: " + saveResults[0].getId());
				return saveResults[0].getId();
			} else {
				logger.info("Error creating the link: " + saveResults[0].getErrors()[0].getMessage());
			}

		} catch (Exception e) {
			logger.error("Error on method createContentWorkspaceDoc: " + e);
		}
		logger.info("Leaving createContentWorkspaceDoc <<<");
		return null;
	}
	
	public static String createContentWorkspace(String contentFolderName) {
		try {
			logger.info("Entering createContentWorkspace >>>");
			// check if directory exist
			if (checkIfContentWorkspaceExist(contentFolderName)) {
				logger.info("The library already exist: " + contentFolderName);
				contentFolderName += "_lex";
				String  idLib= checkIfContentWorkspaceExistWithLexWord(contentFolderName);
				if(null != idLib){
					return idLib;
				}
				logger.info("The library wil be created as " + contentFolderName);
			}

			// creation of the ContentVersion SObject
			SObject contentWorkspace = new SObject();
			contentWorkspace.setType("ContentWorkspace");

			// add the ContentVersion SObject to the request SObject array
			SObject[] contentArray = {contentWorkspace};

			// set fields of the SObject and add the data
			contentWorkspace.setField("Name", contentFolderName);

			// create the files and save the response to the request
			SaveResult[] saveResults = DocumentServiceImpl.connection.create(contentArray);

			// check the result of the request
			if (saveResults[0].isSuccess()) {
				logger.info("Successfully create folder: " + contentFolderName + " " + saveResults[0].getId());
				return saveResults[0].getId();
			} else {
				logger.error("Error on method createContentWorkspace: " + saveResults[0].getErrors()[0].getMessage());
				logger.error("Status code: "+saveResults[0].getErrors()[0].getStatusCode());
			}

		} catch (Exception e) {
			logger.error("Error at createContentWorkspace: " + e);
		}
		logger.info("Leaving createContentWorkspace <<<");
		return null;
	}
	
	private static Boolean checkIfContentWorkspaceExist(String contentFolderName) {
		try {
			QueryResult response = DocumentServiceImpl.connection.query("select id, name from ContentWorkspace where Name = '" + contentFolderName + "'");
			if (response.getRecords().length > 0) {
				return false;
			}
		} catch (Exception e) {
			logger.error("Error on method checkIfContentWorkspaceExist: " + e);
		}
		return true;
	}
	
	private static String checkIfContentWorkspaceExistWithLexWord(String contentFolderName) {
		try {
			QueryResult response = DocumentServiceImpl.connection.query("select id, name from ContentWorkspace where Name = '" + contentFolderName + "'");
			if (response.getRecords().length > 0) {
				SObject[] libraries = response.getRecords();
				return (String) libraries[0].getField("Id");
			}
		} catch (Exception e) {
			logger.error("Error on method checkIfContentWorkspaceExistWithLexWord: " + e);
		}
		return null;
	}

}
