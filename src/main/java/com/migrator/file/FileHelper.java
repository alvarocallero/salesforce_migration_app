package com.migrator.file;

import java.io.FileOutputStream;
import java.util.Base64;

import org.apache.log4j.Logger;

import com.migrator.service.DocumentServiceImpl;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;

public class FileHelper {

	final static Logger logger = Logger.getLogger(FileHelper.class);


	public static QueryResult getAllFiles() {
		try {
			QueryResult result = DocumentServiceImpl.connection.query("SELECT Id, AuthorId, FolderId, Name, Type,  BodyLength, IsDeleted FROM Document");
			return result;

		} catch (Exception e) {
			logger.error("Error on method getAllFiles: " + e.getMessage() + " - " + e.getStackTrace());
			return null;

		}
	}

	public static String getFileData(String fileId) {
		try {
			QueryResult fileBodyQuery =  DocumentServiceImpl.connection.query("SELECT Body FROM Document where id = '" + fileId + "'");
			SObject[] fileBodyObject = fileBodyQuery.getRecords();
			String result = (String) fileBodyObject[0].getField("Body");
			return result;

		} catch (Exception e) {
			logger.error("Error on method getFileData: " + e.getMessage() + " - " + e.getStackTrace());
			return null;
		}
	}

	public static String getFileId(SObject file) {
		String result = (String) file.getField("Id");
		return result;
	}

	public static String getFileOwner(SObject file) {
		String result = (String) file.getField("AuthorId");
		return result;
	}

	public static String getFileFullName(SObject file) {
		String result = (String) file.getField("Name") + "." + file.getField("Type");
		return result;
	}

	public static boolean createFile(String name, String data) {
		try {
			FileOutputStream fos = new FileOutputStream(System.getProperty("user.dir")+"\\backUp\\"+name);
			fos.write(Base64.getDecoder().decode(data));
			fos.close();
			return true;

		} catch (Exception e) {
			logger.error("Error on method createFile, file name "+name+" : " + e.getMessage() + " - " + e.getStackTrace().toString());
		}
		return false;
	}

	public static byte[] fileDataAsByteArray(String fileData) {
		return (byte[]) Base64.getDecoder().decode(fileData);
	}

	public static String updateFileOwnerId(String objectId, String newOwner) {
		try {
			// create the object to modify on salesforce
			SObject updateContentVersion = new SObject();
			updateContentVersion.setType("ContentVersion");
			updateContentVersion.setId(objectId);
			updateContentVersion.setField("OwnerId", newOwner);

			// update the object
			SaveResult[] saveResults =  DocumentServiceImpl.connection.update(new SObject[]{updateContentVersion});

			// check the result
			if (saveResults[0].isSuccess()) {
				logger.info("File was updated");
			} else {
				for (int i = 0; i < saveResults[0].getErrors().length; i++) {
					com.sforce.soap.partner.Error err = saveResults[0].getErrors()[i];
					logger.error("Error code: " + err.getStatusCode().toString());
					logger.error("Error message: " + err.getMessage());
				}
			}

			return saveResults[0].getId();

		} catch (Exception e) {
			logger.error("Error on method updateFileOwnerId: " + e.getMessage() + " - " + e.getStackTrace());
			return null;
		}

	}

}
