public with sharing class RelatedListController {
    
    @AuraEnabled
    public static Map<String, String> returnAllRelationships(Id parentObjectId){
        Map<String, String> results = new Map<String, String>();
        Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();
        List<Schema.ChildRelationship> limitedChildRelationships = new List<Schema.ChildRelationship>();
        
        for(Schema.ChildRelationship cr : childRelationships){
            Schema.SObjectType crO = cr.getChildSObject();
            if(crO.getDescribe().isAccessible()){
                String name = crO.getDescribe().getName();
                if(!crO.getDescribe().isCustomSetting() &&
                   crO.getDescribe().isCreateable() &&
                   !name.containsignorecase('history') && 
                   !name.containsignorecase('tag') &&
                   !name.containsignorecase('share') && 
                   !name.containsignorecase('feed')){
                       limitedChildRelationships.add(cr);
                   }
            }
        }
        for(Schema.ChildRelationship thisChild : limitedChildRelationships){
            String apiName = string.valueOf(thisChild.getChildSObject());
            String pluralName = string.valueOf(thisChild.getChildSObject().getDescribe().getLabelPlural());
            results.put(apiName, pluralName);
        }
        
        return results;
    }
    
    @AuraEnabled
    public static RelatedListWrapper listOfRelatedObjects(Id parentObjectId, String childObjectName, Integer numberOfSObjects){
        Integer actualPage = 0;
        return listOfRelatedObjects(parentObjectId, childObjectName, actualPage, numberOfSObjects);
    }
    
    @AuraEnabled
    public static RelatedListWrapper listOfRelatedObjects(Id parentObjectId, String childObjectName, Integer actualPage, Integer numberOfSObjects){
        String pluralSObjectName = '';
        Integer sObjectCount = 0;
        List<SObject> relatedSObjects = new List<SObject>(); 
        if(parentObjectId != null){
            Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships(); //get the children relationships
            
            
            for(Schema.ChildRelationship thisChild : childRelationships)
            {
                Schema.SObjectField childFieldName = thisChild.getField();
                String relatedObjectName = thisChild.getChildSObject().getDescribe().getName();
                
                Schema.SObjectType childObjectType = thisChild.getChildSObject();
                Map<String, SObjectField> fieldsMap = childObjectType.getDescribe().fields.getMap();
                List<Schema.SObjectField> fieldList = fieldsMap.values();
                
                if(relatedObjectName == childObjectName && childObjectType.getDescribe().isAccessible()){
                    pluralSObjectName = thisChild.getChildSObject().getDescribe().getLabelPlural();
                    Integer sobjectLimit = Integer.valueOf(numberOfSObjects);
                    Integer offset = Integer.valueOf(actualPage) * sobjectLimit;
                    String countQuery = 'SELECT count() FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = :parentObjectId';
                    sObjectCount = Database.countQuery(countQuery);
                    
                    String queryString = 'SELECT Id FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = :parentObjectId LIMIT :sobjectLimit OFFSET :offset';
                    for(SObjectField field : fieldList){
                        if(String.valueOf(field) == 'Name'){
                            Boolean nameIsAccessible = fieldsMap.get('Name').getDescribe().isAccessible();
                            if(nameIsAccessible){
                                queryString = 'SELECT Id, Name FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = :parentObjectId LIMIT :sobjectLimit OFFSET :offset';
                            }
                        }
                    }
                    
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
        result.numberOfSObjects = sObjectCount;
        return result;
    }
    
    public class RelatedListWrapper{
        @AuraEnabled
        public String relatedPluralName {get; set;}
        @AuraEnabled
        public SObject[] relatedSObjects {get; set;}
        @AuraEnabled
        public Integer numberOfSObjects {get; set;}
    }
}