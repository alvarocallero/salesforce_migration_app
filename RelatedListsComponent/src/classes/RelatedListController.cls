public with sharing class RelatedListController {

    @AuraEnabled
    public static List<String> returnAllRelationships(Id parentObjectId){
        List<String> results = new List<String>();
        Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();
        List<Schema.ChildRelationship> limitedChildRelationships = new List<Schema.ChildRelationship>();

        for(Schema.ChildRelationship cr : childRelationships){

                Schema.SObjectType crO = cr.getChildSObject();
                String name = crO.getDescribe().getName();
                if(!crO.getDescribe().isCustomSetting() && crO.getDescribe().getRecordTypeInfos().size() > 0 && crO.getDescribe().isCreateable() &&
            	   !name.containsignorecase('history') && !name.containsignorecase('tag') &&
                   !name.containsignorecase('share') && !name.containsignorecase('feed')){

                       limitedChildRelationships.add(cr);
                }
        }


        for(Schema.ChildRelationship thisChild : limitedChildRelationships){
            results.add(string.valueOf(thisChild.getChildSObject()));
        }

        return results;
    }

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

                Schema.SObjectType childObjectType = thisChild.getChildSObject();
                List<Schema.SObjectField> fieldList = childObjectType.getDescribe().fields.getMap().values();



                if(relatedObjectName == childObjectName){

                    pluralSObjectName = thisChild.getChildSObject().getDescribe().getLabelPlural();
                    Integer sobjectLimit = Integer.valueOf(numberOfSObjects);
                    String queryString = 'SELECT Id FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = :parentObjectId LIMIT '+ sobjectLimit;

                    for(SObjectField field : fieldList){
                        if(String.valueOf(field) == 'Name'){
                            queryString = 'SELECT Id, Name FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = :parentObjectId LIMIT '+ sobjectLimit;
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
        return result;
    }

    public class RelatedListWrapper{
        @AuraEnabled
        public String relatedPluralName {get; set;}
        @AuraEnabled
        public SObject[] relatedSObjects {get; set;}
    }
}
