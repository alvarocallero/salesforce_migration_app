@RestResource(urlMapping='/ContentMigrator/*')
global with sharing class ContentMigrator {
    
    @HttpPost
    global static String doPost(String jsonIdsMap) {
        Integer successCount = 0;
        Integer errorCount = 0;
        String result = '';
        String message = '';
        try {
            Map<String, Object> headerIdsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonIdsMap);
            Map<Id, Id> idsMap = (Map<Id, Id>) headerIdsMap.get('jsonIdsMap');            
            List<ContentVersion> versions = new List<ContentVersion>();
            Set<Id> docsId = idsMap.keySet();     	
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
            Database.SaveResult[] srList = Database.update(versions, false);
            // Iterate through each returned result
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    String info = 'Successfully updated the file with the following Id: ' + sr.getId();
                    message += info + '\n';                        
                    successCount += 1;  
                    System.debug(info);                   
                }
                else {                    
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String info = 'There was an error with a document migration. Detailed information: \n';
                        info += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        info += 'ContentVersion fields that affected this error: ' + err.getFields();
                        message += info + '\n';                        
                        errorCount += 1;
                        System.debug(info);
                    }
                }
            }
        } catch (Exception e){
            message = 'Error trying to migrate documents. Message: '+ e.getStackTraceString();
            System.debug(message);
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();			
        gen.writeStringField('SUCCESS', String.valueOf(successCount));
        gen.writeStringField('ERROR', String.valueOf(errorCount));
        gen.writeStringField('MESSAGE', String.valueOf(message));
        gen.writeEndObject();
        gen.close();
        result = gen.getAsString();
        return result;
    }
}