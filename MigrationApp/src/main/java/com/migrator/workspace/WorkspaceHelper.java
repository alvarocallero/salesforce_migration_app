package com.migrator.workspace;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.log4j.Logger;
import com.migrator.service.DocumentServiceImpl;
import com.sforce.soap.partner.QueryResult;
import com.sforce.soap.partner.SaveResult;
import com.sforce.soap.partner.sobject.SObject;

public class WorkspaceHelper {

	final static Logger logger = Logger.getLogger(WorkspaceHelper.class);

	public static TreeMap <String,String> getAllContentWorkSpace(){
		logger.info("Entering getAllContentWorkSpace >>>");
		QueryResult qResult = null;
		try {
			List<SObject> arrayResult = new LinkedList<SObject>();
			qResult = DocumentServiceImpl.connection.query("select id, name from ContentWorkspace");
			boolean done = false;
			if (qResult.getSize() > 0) {
				while (!done) {
					for (SObject obj : qResult.getRecords()){
						arrayResult.add(obj);						
					}
					if (qResult.isDone()) {
						done = true;
					} else {
						qResult = DocumentServiceImpl.connection.queryMore(qResult.getQueryLocator());
					}
				}
			} else {
				logger.info("No ContentWorkspaces found");
			}

			//Map <ContentWSiD,CWSname>, we map this because we can check CWSname with the folder name
			TreeMap <String,String> resultMap = new TreeMap<String,String>();
			for (SObject obj : arrayResult){
				if ((String)obj.getField("Id") != null){
					resultMap.put((String)obj.getField("Id"), (String)obj.getField("Name"));
				}
			}
			logger.info("Leaving getAllContentWorkSpace <<<");
			return resultMap;
		} catch (Exception e) {
			logger.error("Error on method getAllContentWorkSpace: " + e);
		}
		logger.info("Leaving getAllContentWorkSpace <<<");
		return null;
	}


	public static TreeMap<String, String> createContentWorkspace( SObject[] docsArray , TreeMap<String, String> mapOfCWSIdAndName, TreeMap<String,String> mapOfFolderIdAndName) {
		logger.info("Entering createContentWorkspace >>>");
		String response = null;
		List<String> contentWorkspaceToCreate = new LinkedList<String>();
		
		//Map <ContetWorkSpaceId,ContentWorkspaceName>
		TreeMap<String, String> mapToReturn = mapOfCWSIdAndName;

		try {
			//check if exists in the ContentWorkspaces one that is called the same
			for (SObject document : docsArray){
				String folderId = (String)document.getField("FolderId");
				String folderName = mapOfFolderIdAndName.get(folderId);
				if(folderName != null){
					for (Map.Entry<String, String> entry : mapOfCWSIdAndName.entrySet()){
						if(folderName.equals(entry.getValue())){
							response=entry.getKey();
						}
					}
					
				}
				//if not exists it is added to a temporary list
				if(response==null){
					if((folderName != null) && (!contentWorkspaceToCreate.contains(folderName))){
						contentWorkspaceToCreate.add(folderName);
					}
				}else{
					mapToReturn.put(response, folderName);
				}

			}
			TreeMap <String,String>	mapOfCreatedCWS = createContentWorkspaceBatch(contentWorkspaceToCreate);
			for(Map.Entry<String,String> entry : mapOfCreatedCWS.entrySet()){
				mapToReturn.put(entry.getKey(), entry.getValue());
			}
		} catch (Exception e) {
			logger.error("Error on method createContentWorkspace: " + e);
			System.exit(0);
		}
		logger.info("Leaving createContentWorkspace <<<");
		return  mapToReturn;
	}

	public static TreeMap <String,String> createContentWorkspaceBatch(List<String> contentFolderName) {
		logger.info("Entering createContentWorkspaceBatch >>>");

		//Map <CWSids,CWSname>
		TreeMap <String,String> mapResult = new TreeMap<String,String>();
		try {
			// creation of the ContentVersion SObject
			int cantFoldersToCreate = 0;
			SObject[] contentArrayToCreate = new SObject[contentFolderName.size()]; 
			for (int i=0;i<contentFolderName.size();i++){
				if(!String.valueOf(contentFolderName.get(i)).equals("null")) {
					SObject contentWorkspace = new SObject();
					contentWorkspace.setType("ContentWorkspace");
					contentWorkspace.setField("Name", contentFolderName.get(i));
					contentArrayToCreate[i] = contentWorkspace;
					cantFoldersToCreate++;
				}
			}
			
			if(cantFoldersToCreate == contentFolderName.size()) {
				SaveResult[] saveResults = DocumentServiceImpl.connection.create(contentArrayToCreate);
				for (int i=0;i<saveResults.length;i++){
					if(!saveResults[i].getSuccess()){
						logger.info("Error at creating ContentWorkspaceBatch: " + saveResults[i].getErrors()[i].getMessage());
						System.exit(0);
					}
					else if (saveResults[i].getId() != null){
						mapResult.put(saveResults[i].getId(), contentFolderName.get(i));
					}
				}
				logger.info("Batch of ContentWorkspace created successfully");
			}
			
		} catch (Exception e) {
			logger.error("Error at createContentWorkspaceBatch: " + e);
			System.exit(0);
		}
		logger.info("Leaving createContentWorkspaceBatch <<<");
		return mapResult;
	}

	public static TreeMap<String,String> createMapOfcwsIdAndCwsId(TreeMap<String,String> mapOfcwsIdAndName, TreeMap<String,String> mapOfFolderIdAndName){
		logger.info("Entering createMapOfcwsIdAndCwsId >>>");
		//Map<FolderId,cwsId>
		TreeMap<String,String> mapToReturn = new TreeMap<String,String>();
		try {
			for (Map.Entry<String, String> cws : mapOfcwsIdAndName.entrySet()){
				for (Map.Entry<String, String> folder : mapOfFolderIdAndName.entrySet()){
					if (!folder.getValue().equals("null") && !folder.getValue().equals(null)) {
						if(folder.getValue().equals(cws.getValue())){
							mapToReturn.put(folder.getKey(), cws.getKey());
							break;
						}	
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error at createMapOfcwsIdAndCwsId: "+e);
			System.exit(0);
		}
		
		logger.info("Leaving createMapOfcwsIdAndCwsId <<<");
		return mapToReturn;
	}

}