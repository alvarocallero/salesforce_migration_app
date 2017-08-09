public class AttachmentController {
    
    public class AttachmentDetails{
        @AuraEnabled 
        public string contentDocumentId {get; set;}
        @AuraEnabled
        public string contentVersionId {get; set;}
    }
    
    @AuraEnabled
    public static AttachmentDetails attachmentDetails(Id messageId){
        AttachmentDetails result = null;
        //TBD: Field level security
        try{
            UserBotMessage__c message = [SELECT id, ContentDocumentId__c From UserBotMessage__c where Id = :messageId];
            if(!String.isBlank(message.ContentDocumentId__c)){
                result = new AttachmentDetails();
                ContentDocument document = [Select id, LatestPublishedVersionId From ContentDocument where Id = :message.ContentDocumentId__c];
                result.contentDocumentId = document.Id;
                result.contentVersionId = document.LatestPublishedVersionId;
            }
        }catch(Exception e){
            result = null;
        }
            
        return result;
    }
    
}