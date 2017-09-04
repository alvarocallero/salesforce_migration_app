@RestResource(urlMapping='/ContentMigrator/*')
global with sharing class ContentMigrator {

    @HttpPost
    global static String doPost(String jsonIdsMap) {
        Integer successCount = 0;
        Integer errorCount = 0;
        String result = '';
        String message = '';
        try {
            String [] contentVersionFields = new String [] {'VersionData'};
                String [] documentFields = new String [] {'Body', 'BodyLength'};

                    Boolean isUpdateableContentVersion = true;
            Boolean isAccessibleDocument = true;

            Map<String,Schema.SObjectField> contentVersionSchemaFields = Schema.SObjectType.ContentVersion.fields.getMap();
            for (String contentVersionField : contentVersionFields) {
                // Check if the user has create access on the each field
                if (!contentVersionSchemaFields.get(contentVersionField).getDescribe().isUpdateable() ) {
                    isUpdateableContentVersion = false;
                    break;
                }
            }
            if(isUpdateableContentVersion){
                Map<String,Schema.SObjectField> documentSchemaFields = Schema.SObjectType.Document.fields.getMap();
                for (String documentField : documentFields) {
                    // Check if the user has create access on the each field
                    if (!documentSchemaFields.get(documentField).getDescribe().isAccessible() ) {
                        isAccessibleDocument = false;
                        break;
                    }
                }
                if (isAccessibleDocument){
                    Map<String, Object> idsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonIdsMap);
                    List<ContentVersion> versions = new List<ContentVersion>();
                    System.debug(idsMap);
                    Set<String> docsId = idsMap.keySet();
                    System.debug(docsId);
                    Map<Id, Document> docs = new Map<ID, Document>([
                        SELECT Body, BodyLength
                        FROM Document
                        WHERE Id IN :docsId AND BodyLength > 0
                    ]);
                    Set<Id> validsDocsId = docs.keySet();
                    System.debug(validsDocsId);
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
                } else {
                    message = 'Permission error, Documents are not accessible.';
                    System.debug(message);
                }
            }  else {
                message = 'Permission error, Documents are not accessible.';
                System.debug(message);
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
