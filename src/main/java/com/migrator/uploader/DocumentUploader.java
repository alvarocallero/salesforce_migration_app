package com.migrator.uploader;

import org.apache.log4j.Logger;

import com.migrator.service.DocumentServiceImpl;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;

public class DocumentUploader {
	
	final static Logger logger = Logger.getLogger(DocumentUploader.class);

	public static void bulkDocumentUploading(){
		try {
			QueryResult result = DocumentServiceImpl.connection.query("SELECT Id, AuthorId, FolderId, Name, Type,  BodyLength, IsDeleted, Body FROM Document where name = 'Archivo de ejemplo para 5000' limit 1");
			SObject[] exampleDocument = result.getRecords();
			String docName = "FileName";
			String body = new String("This is the body of the documentttt 0_o");
			for (int j=0;j<25;j++){
				docName+=j;
				SObject[] docArray = new SObject[200];
				for (int i=0;i<200;i++){
					SObject newDocument = new SObject();
					docName+=i;
					newDocument.setType("Document");
					newDocument.setField("Name", docName);
					newDocument.setField("Type", "txt");
					newDocument.setField("Body", body.getBytes());
					newDocument.setField("FolderId", exampleDocument[0].getField("FolderId"));
					newDocument.setField("ContentType", exampleDocument[0].getField("ContentType"));
					newDocument.setField("Description", exampleDocument[0].getField("Description"));
					newDocument.setField("NamespacePrefix", exampleDocument[0].getField("NamespacePrefix"));
					docName=docName.substring(0, 8);
					docArray[i]=newDocument;
				}
				SaveResult[] saveResults = DocumentServiceImpl.connection.create(docArray);
				if (saveResults[0].isSuccess()) {
					logger.info("Successfully create document: " + saveResults[0]);
				} else {
					logger.info("Error creating the link: " + saveResults[0].getErrors()[0].getMessage());
				}
			}
			
		} catch (Exception e) {
			logger.error("Error on method bulkDocumentUploading: " + e);
		}
	}
}
