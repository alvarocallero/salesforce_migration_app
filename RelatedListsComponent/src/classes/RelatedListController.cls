public with sharing class RelatedListController {
    
    @AuraEnabled
    public static RelatedListWrapper listOfRelatedObjects(Id parentObjectId, String childObjectName, Integer numberOfSObjects){
        String pluralSObjectName = '';
        List<SObject> relatedSObjects = new List<SObject>(); 
        if(parentObjectId != null){
            Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships(); //get the children relationships
            
            
            for(Schema.ChildRelationship thisChild : childRelationships)
            {
                Schema.SObjectField childFieldName = thisChild.getField();
                String relatedObjectName = thisChild.getChildSObject().getDescribe().getName();
                
                if(relatedObjectName == childObjectName){
                    pluralSObjectName = thisChild.getChildSObject().getDescribe().getLabelPlural();
                    Integer sobjectLimit = Integer.valueOf(numberOfSObjects);
                    String queryString = 'SELECT Id, Name FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = :parentObjectId LIMIT '+ sobjectLimit;
                    List<SObject> tmpList = Database.query(queryString);
                    for(SObject o : tmpList){
                        relatedSObjects.add(o);
                    }
                }
            }
        }
        RelatedListWrapper result = new RelatedListWrapper();
        result.relatedPluralName = pluralSObjectName;
        result.relatedSObjects = relatedSObjects;
        return result;
    }
    
    public class RelatedListWrapper{
        @AuraEnabled
        public String relatedPluralName {get; set;}
        @AuraEnabled
        public SObject[] relatedSObjects {get; set;}
    }
}