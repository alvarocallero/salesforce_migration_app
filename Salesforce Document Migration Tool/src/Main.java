import com.sforce.soap.partner.Connector;
import com.sforce.soap.partner.PartnerConnection;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;
import com.sforce.ws.ConnectorConfig;
import com.sforce.ws.ConnectionException;

import java.io.FileOutputStream;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class Main {
	static String usernameContainer = null;
	static String passwordContainer = null;
	static String tokenContainer = null;

	static Scanner inputScan = new Scanner(System.in);

	static PartnerConnection connection;

	public static void main(String[] args) {

		System.out.println("Enter username:");
		if (inputScan.hasNext()) {
			usernameContainer = inputScan.next();
		}
		System.out.println("\nEnter password:");
		if (inputScan.hasNext()) {
			passwordContainer = inputScan.next();
		}
		System.out.println("\nEnter token:");
		if (inputScan.hasNext()) {
			tokenContainer = inputScan.next();
		}

		ConnectorConfig config = new ConnectorConfig();
		config.setUsername(usernameContainer);
		config.setPassword(passwordContainer + tokenContainer);

		try {
			connection = Connector.newConnection(config);

			// display some of the current settings
			System.out.println("\n------------------------------------------------------------------------------------------------");
			System.out.println("Connected !!!");
			System.out.println("------------------------------------------------------------------------------------------------");
			System.out.println("Service EndPoint:" + config.getServiceEndpoint());
			System.out.println("Username: " + config.getUsername());
			System.out.println("------------------------------------------------------------------------------------------------");

			// download the documents
			System.out.println("\n------------------------------------------------------------------------------------------------");
			System.out.println("Downloading Documents...");
			System.out.println("------------------------------------------------------------------------------------------------");
			SObject[] documents = getDocuments();

			// upload documents as files to salesforce
			if (documents.length > 0) {

				// create workspace and map folder to workspace
				Map<String, String> folderToContentWorkSpaceMap = new HashMap<String, String>();
				SObject[] folders = getAllFolders();

				System.out.println("\n------------------------------------------------------------------------------------------------");
				System.out.println("Creating Folders...");
				System.out.println("------------------------------------------------------------------------------------------------");
				for (SObject folder : folders) {
					String folderName = getFolderName(folder);
					if (folderName != "null" && folderName != null) {
						String folderId = getFolderId(folder);
						String contentWorkSpaceId = createContentWorkspace(folderName);
						// mapping folder and contentworkspace
						folderToContentWorkSpaceMap.put(folderId, contentWorkSpaceId);
					}
				}

				System.out.println("\n------------------------------------------------------------------------------------------------");
				System.out.println("Uploading Files...");
				System.out.println("------------------------------------------------------------------------------------------------");
				uploadFile(documents, folderToContentWorkSpaceMap);

				System.out.println("\n------------------------------------------------------------------------------------------------");
				System.out.println("Migration Finish ");
				System.out.println("------------------------------------------------------------------------------------------------");

			}

		} catch (ConnectionException e) {
			e.printStackTrace();
		}
	}

	private static SObject[] getDocuments() {

		try {

			// query all the files from salesforce
			QueryResult queryResults = getAllFiles();

			if (queryResults.getSize() > 0) {

				// create a list of SObject from the query files
				SObject[] files = queryResults.getRecords();

				// loop over the files and create files backups
				for (int i = 0; i < files.length; ++i) {

					String fileName = getFileFullName(files[i]);
					String fileId = getFileId(files[i]);
					String fileData = getFileData(fileId);

					createFile(fileName, fileData);
					System.out.println("\n--->The file " + fileName + " has been created");

				}
			}

			// return all documents
			return queryResults.getRecords();

		} catch (Exception e) {

			e.printStackTrace();
			return null;
		}
	}

	private static void uploadFile(SObject[] documents, Map<String, String> folderToContentWorkSpaceMap) {

		try {

			// creation of the ContentVersion SObject
			SObject ContentVersion = new SObject();
			ContentVersion.setType("ContentVersion");

			// add the ContentVersion SObject to the request SObject array
			SObject[] contentArray = {ContentVersion};

			// loop over each file to upload
			for (int a = 0; a < documents.length; a++) {

				// get all data from the file
				String fileId = getFileId(documents[a]);
				String fileData = getFileData(fileId);
				byte[] fileDataByteArray = fileDataAsByteArray(fileData);
				String fileName = getFileFullName(documents[a]);
				String fileOwner = getFileOwner(documents[a]);

				// set fields of the SObject and add the data
				ContentVersion.setField("VersionData", fileDataByteArray);
				ContentVersion.setField("Title", fileName);
				ContentVersion.setField("PathOnClient", fileName);

				// create the files and save the response to the request
				SaveResult[] saveResults = connection.create(contentArray);

				// check the result of the request
				if (saveResults[0].isSuccess()) {

					System.out.println("\n---> Successfully upload file: " + fileName);
					updateFileOwnerId(saveResults[0].getId(), fileOwner);

					String folderid = (String) documents[a].getField("FolderId");
					String workspaceId = folderToContentWorkSpaceMap.get(folderid);
					String contentDocumentId = getContDocIdFromVerId((String) saveResults[0].getId());

					createContentWorkspaceDoc(workspaceId, contentDocumentId);

				} else {

					System.out.println("\n---X The error reported was: " + saveResults[0].getErrors()[0].getMessage() + "\n");
				}
			}

		} catch (Exception e) {

			e.printStackTrace();

		}
	}

	// Files

	private static QueryResult getAllFiles() {
		try {

			QueryResult result = connection.query("SELECT Id, AuthorId, FolderId, Name, Type,  BodyLength, IsDeleted FROM Document");
			return result;

		} catch (Exception e) {

			e.printStackTrace();
			return null;

		}
	}

	private static String getFileData(String fileId) {
		try {

			QueryResult fileBodyQuery = connection.query("SELECT Body FROM Document where id = '" + fileId + "'");
			SObject[] fileBodyObject = fileBodyQuery.getRecords();
			String result = (String) fileBodyObject[0].getField("Body");
			return result;

		} catch (Exception e) {

			e.printStackTrace();
			return null;

		}
	}

	private static String getFileId(SObject file) {
		String result = (String) file.getField("Id");
		return result;
	}

	private static String getFileOwner(SObject file) {
		String result = (String) file.getField("AuthorId");
		return result;
	}

	private static String getFileFullName(SObject file) {
		String result = (String) file.getField("Name") + "." + file.getField("Type");
		return result;
	}

	private static boolean createFile(String name, String data) {
		try {

			FileOutputStream fos = new FileOutputStream(name);
			fos.write(Base64.getDecoder().decode(data));
			fos.close();
			return true;

		} catch (Exception e) {

			e.printStackTrace();

		}
		return false;
	}

	private static byte[] fileDataAsByteArray(String fileData) {
		return (byte[]) Base64.getDecoder().decode(fileData);
	}

	private static String updateFileOwnerId(String objectId, String newOwner) {

		try {
			// create the object to modify on salesforce
			SObject updateContentVersion = new SObject();
			updateContentVersion.setType("ContentVersion");
			updateContentVersion.setId(objectId);
			updateContentVersion.setField("OwnerId", newOwner);

			// update the object
			SaveResult[] saveResults = connection.update(new SObject[]{updateContentVersion});

			// check the result
			if (saveResults[0].isSuccess()) {
				System.out.println("File was updated.");
			} else {
				for (int i = 0; i < saveResults[0].getErrors().length; i++) {
					com.sforce.soap.partner.Error err = saveResults[0].getErrors()[i];
					System.out.println("Errors were found on item " + 0);
					System.out.println("Error code: " + err.getStatusCode().toString());
					System.out.println("Error message: " + err.getMessage());
				}
			}

			return saveResults[0].getId();

		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}

	}

	// Folder

	private static SObject[] getAllFolders() {
		try {

			QueryResult result = connection.query("SELECT Id,Name FROM Folder");
			SObject[] folders = result.getRecords();
			return folders;

		} catch (Exception e) {

			e.printStackTrace();

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

	private static Boolean checkIfContentWorkspaceExist(String contentFolderName) {
		try {
			QueryResult response = connection.query("select id, name from ContentWorkspace where Name = '" + contentFolderName + "'");
			// SObject[] rcrd = response.getRecords().length();
			if (response.getRecords().length > 0) {
				return false;
			}
		} catch (Exception e) {
			// TODO: handle exception
			e.getStackTrace();
		}
		return true;
	}

	private static String getContDocIdFromVerId(String folderId) {
		try {
			QueryResult result = connection.query("SELECT Id,LatestPublishedVersionId,Title FROM ContentDocument WHERE LatestPublishedVersionId = '" + folderId + "'");
			SObject[] contentDocument = result.getRecords();
			return contentDocument[0].getId();

		} catch (Exception e) {

			e.printStackTrace();

		}
		return null;
	}

	private static String createContentWorkspaceDoc(String contentWorkSpaceId, String contentDocumentId) {
		try {
			// creation of the ContentWorkspaceDoc SObject
			SObject contentWorkspaceDoc = new SObject();
			contentWorkspaceDoc.setType("ContentWorkspaceDoc");

			// add the ContentWorkspaceDoc SObject to the request SObject array
			SObject[] request = {contentWorkspaceDoc};

			// set fields of the SObject and add the data
			contentWorkspaceDoc.setField("ContentWorkspaceId", contentWorkSpaceId);
			contentWorkspaceDoc.setField("ContentDocumentId", contentDocumentId);

			// create the files and save the response to the request
			SaveResult[] saveResults = connection.create(request);

			// check the result of the request
			if (saveResults[0].isSuccess()) {
				System.out.println("---> Successfully create link: " + saveResults[0].getId());
				// return id of the Content Workspace
				return saveResults[0].getId();

			} else {

				System.out.println("---X The error reported was: " + saveResults[0].getErrors()[0].getMessage() + "\n");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	private static String createContentWorkspace(String contentFolderName) {

		try {

			// check if directory exist
			if (checkIfContentWorkspaceExist(contentFolderName)) {
				System.out.println("\n---> The library already exist: " + contentFolderName);
				contentFolderName += "_lex";
				System.out.println("\n---> The library wil be created as " + contentFolderName);
			}

			// creation of the ContentVersion SObject
			SObject contentWorkspace = new SObject();
			contentWorkspace.setType("ContentWorkspace");

			// add the ContentVersion SObject to the request SObject array
			SObject[] contentArray = {contentWorkspace};

			// set fields of the SObject and add the data
			contentWorkspace.setField("Name", contentFolderName);

			// create the files and save the response to the request
			SaveResult[] saveResults = connection.create(contentArray);

			// check the result of the request
			if (saveResults[0].isSuccess()) {

				System.out.println("\n---> Successfully create folder: " + contentFolderName + " " + saveResults[0].getId());

				// return id of the Content Workspace
				return saveResults[0].getId();

			} else {

				System.out.println("\n---X The error reported was: " + saveResults[0].getErrors()[0].getMessage() + "\n");
			}

		} catch (Exception e) {

			e.printStackTrace();

		}
		return null;
	}

}
