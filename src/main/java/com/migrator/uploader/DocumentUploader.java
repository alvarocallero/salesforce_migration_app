package com.migrator.uploader;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import com.force.sdk.oauth.context.ForceSecurityContextHolder;
import com.force.sdk.oauth.context.SecurityContext;
import com.sforce.soap.partner.Connector;
import com.sforce.soap.partner.PartnerConnection;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;
import com.sforce.ws.ConnectorConfig;
@Service
public class DocumentUploader {

	final static Logger logger = Logger.getLogger(DocumentUploader.class);
	public static PartnerConnection connection;

	public static void bulkDocumentUploading(){
		try {

			ConnectorConfig config = new ConnectorConfig();
			SecurityContext sc = ForceSecurityContextHolder.get();
			String url = sc.getEndPointHost();
			config.setSessionId(sc.getSessionId());

			//Set the API version to 40.0
			config.setServiceEndpoint(url+"/services/Soap/u/40.0");

			connection = Connector.newConnection(config);
			logger.info("Connection successful");
			logger.info("Service endPoint is: "+url);

			String docName = "FileName";
			String body = new String("This is the body of the documentttt 0_o");
//			for (int j=0;j<25;j++){
//				docName+=j;
				SObject[] docArray = new SObject[200];
				for (int i=0;i<200;i++){
					SObject newDocument = new SObject();
					docName+=i;
					newDocument.setType("Document");
					newDocument.setField("Name", docName);
					newDocument.setField("Type", "txt");
					newDocument.setField("Body", body.getBytes());
					newDocument.setField("FolderId", "00lf4000000R6FPAA0");
					newDocument.setField("ContentType", "txt");
					newDocument.setField("Description", "La Descripcion");
					newDocument.setField("NamespacePrefix", "");
					docName=docName.substring(0, 8);
					docArray[i]=newDocument;
				}
				SaveResult[] saveResults = connection.create(docArray);
				if (saveResults[0].isSuccess()) {
					logger.info("Successfully create document: " + saveResults[0]);
				} else {
					logger.info("Error creating the link: " + saveResults[0].getErrors()[0].getMessage());
				}
//			}

		} catch (Exception e) {
			logger.error("Error on method bulkDocumentUploading: " + e);
		}
	}
}
