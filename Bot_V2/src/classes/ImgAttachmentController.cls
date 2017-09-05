public class ImgAttachmentController {
    
	public class AttachmentDetails{
        @AuraEnabled 
        public string contentDocumentId {get; set;}
        @AuraEnabled
        public string contentVersionId {get; set;}
    }
    
    @AuraEnabled
    public static AttachmentDetails attachmentDetails(Id knownIssueId){
        
        System.debug('IMG ATTACHMENT SUPPOSED TO BE HERE --> ' + knownIssueId);
        AttachmentDetails result = null;
        //TBD: Field level security
        try{
            Known_Issue__c ki = [SELECT id, Content_Document__c From Known_Issue__c where Id = :knownIssueId];
            if(!String.isBlank(ki.Content_Document__c)){
                result = new AttachmentDetails();
                ContentDocument document = [Select Id, LatestPublishedVersionId From ContentDocument where LatestPublishedVersionId = :ki.Content_Document__c];
                result.contentDocumentId = document.Id;
                result.contentVersionId = document.LatestPublishedVersionId;
               
            }
        }catch(Exception e){
            result = null;
        }
            
        return result;
    }
}