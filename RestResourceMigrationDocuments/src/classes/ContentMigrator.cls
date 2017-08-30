@RestResource(urlMapping='/ContentMigrator/*')
global with sharing class ContentMigrator {

  @HttpPost
    global static String doPost(String jsonIdsMap) {
        Integer successCount = 0;
        Integer errorCount = 0;
        String result = '';
        Map<String, Object> idsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonIdsMap);
        List<ContentVersion> versions = new List<ContentVersion>();
        Set<String> docsId = idsMap.keySet();     	
       	Map<Id, Document> docs = new Map<ID, Document>([
            SELECT Body, BodyLength
            FROM Document
            WHERE Id IN :docsId AND BodyLength > 0
        ]);
        Set<Id> validsDocsId = docs.keySet();
        for (Id docId : validsDocsId)
        {
            Id versionId = (Id)idsMap.get(docId);
            Document doc = docs.get(docId);
            ContentVersion version = new ContentVersion();
            version.Id = versionId;
            version.VersionData = doc.Body;
            versions.add(version);
        }
        try{
            Database.SaveResult[] srList = Database.update(versions, false);
            // Iterate through each returned result
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated the file with the following Id: ' + sr.getId());
                    successCount += 1;
                }
                else {
                    
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('ContentVersion fields that affected this error: ' + err.getFields());
                        errorCount += 1;
                    }
                }
            }
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();			
            gen.writeStringField('SUCCESS', String.valueOf(successCount));
            gen.writeStringField('ERROR', String.valueOf(errorCount));
            gen.writeEndObject();
            gen.close();
            result = gen.getAsString();
        } catch (Exception e){
            System.debug('Error trying to migrate documents. Message: '+ e);
        }
        return result;
    }
}