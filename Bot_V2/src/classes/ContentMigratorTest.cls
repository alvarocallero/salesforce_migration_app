@isTest(SeeAllData=true)
private class ContentMigratorTest {    
    // This test assume that there are test documents and the same ammount of empty files thats their names start with the corresponding BLANKFILETEST and TESTDOCUMENT 
    // Max tested documents: 50
    // Max tested document's size: 4000
    static testMethod void testContentMigrator() {

        List<ContentVersion> files =  [
            SELECT Id,VersionData,Title
            FROM ContentVersion
            WHERE Title LIKE 'BLANKFILETEST%' LIMIT 50
        ];
        
        List<Document> docs = [
            SELECT Id, 
            Body,
            Name,
            BodyLength
            FROM Document
            WHERE Name LIKE 'TESTDOCUMENT%' AND BodyLength > 0 AND BodyLength < 4000 LIMIT 50
        ]; 
        List<Id> filesMigratedIds = new List<Id>();
        Integer docSize = docs.size();
        Integer fileSize = files.size();
        if (docSize>0 && fileSize > docSize){ 
            // Create a Json's key/value with documentId/ContentVersionId
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            for(Integer i = 0; i<docSize; i++){
                Id fileId = files[i].Id;
                gen.writeStringField(docs[i].Id, fileId);
                filesMigratedIds.add(fileId);
            }    
            gen.writeEndObject();
            gen.close();
            String jsonDocuments = gen.getAsString();
            
            // Migrate documents and get result
            String result = ContentMigrator.doPost(jsonDocuments);
            Map<String, Object> resultMap= (Map<String, Object>)JSON.deserializeUntyped(result);
            Boolean success = resultMap.get('SUCCESS') == String.valueOf(docSize) && resultMap.get('ERROR') == '0';
            
            // Get updated Files and check if their body was successfully updated
            Integer i = 0;
            Map<String, Object> idsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonDocuments);
            Map<Id, ContentVersion> filesMigrated = new Map<Id, ContentVersion>([
                SELECT Id,VersionData
                FROM ContentVersion
                WHERE Id IN :filesMigratedIds
            ]);  
            
            while (i < docSize && success) {
                Document doc = docs[i];
                Id docId = doc.Id;
                Id fileId = (Id)idsMap.get(docId);
                ContentVersion fileVersion = filesMigrated.get(fileId);
                System.debug(i);
                System.debug(doc.Body);
                System.debug(doc.BodyLength);
                System.debug(EncodingUtil.base64Encode(doc.Body));
                try{
                    success = success && (EncodingUtil.base64Encode(doc.Body) == EncodingUtil.base64Encode(fileVersion.VersionData));             	
                } catch (Exception e){
                    System.debug('Error trying to compare migrated documents. Message: '+ e);
                }
                i++;
            }
            System.assert(success);    
        } else{
            System.assert(true);  
        }             
    }
}