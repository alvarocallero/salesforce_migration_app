public with sharing class RelatedListController {
    private static Set<String> RELATIONSHIPS_BLACK_LIST = new Set<String>{'history', 'tag', 'share', 'feed', 
        																	'contentdocumentlink', 
        																	'contentversion', 'group', 
        																	'caseteamtemplaterecord',
        																	'entitysubscription',
               																'feedcomment',
        																	'processinstance', 'topicassignment'};
                                                                                
    @AuraEnabled
    public static Map<String, String> returnAllRelationships(Id parentObjectId){
        Map<String, String> results = new Map<String, String>();
        Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
        
        Schema.ChildRelationship[] filteredChilds = filterFromBlackList(objectType);
            
        for(Schema.ChildRelationship thisChild : filteredChilds){
            String apiName = string.valueOf(thisChild.getChildSObject());
            String pluralName = string.valueOf(thisChild.getChildSObject().getDescribe().getLabelPlural());
            String relationshipName = string.valueOf(thisChild.getRelationshipName());
            if(relationshipName != null){
                results.put(relationshipName, pluralName);  
            }
        }
        
        return results;
    }
    
    @AuraEnabled
    public static RelatedList.Wrapper listOfRelatedObjects(Id parentObjectId, String childRelationshipName, Integer numberOfSObjects){
        Integer actualPage = 0;
        return listOfRelatedObjects(parentObjectId, childRelationshipName, actualPage, numberOfSObjects);
    }
    
    @AuraEnabled
    public static RelatedList.Wrapper listOfRelatedObjects(Id parentObjectId, String childRelationshipName, Integer actualPage, Integer numberOfSObjects){
        String pluralSObjectName = '';
        Integer sObjectCount = 0;
        List<SObject> relatedSObjects = new List<SObject>(); 
        RelatedList.Wrapper result = new RelatedList.Wrapper();
        if(parentObjectId != null){
            Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships(); //get the children relationships
            
            Integer attempt = 0; 
            for(Schema.ChildRelationship thisChild : childRelationships)
            {
                String relationshipName = thisChild.getRelationshipName();
                if(childRelationshipName != null && relationshipName == childRelationshipName){
                    Schema.SObjectType childObjectType = thisChild.getChildSObject();
                    Schema.SObjectField childFieldName = thisChild.getField();
                    Map<String, SObjectField> fieldsMap = childObjectType.getDescribe().fields.getMap();
                    List<Schema.SObjectField> fieldList = fieldsMap.values();
                    String relatedObjectName = thisChild.getChildSObject().getDescribe().getName();
                    Integer sobjectLimit = Integer.valueOf(numberOfSObjects);
                    Integer offset = Integer.valueOf(actualPage) * sobjectLimit;
                    if(childObjectType.getDescribe().isAccessible()){
                        pluralSObjectName = thisChild.getChildSObject().getDescribe().getLabelPlural();
                        result = RelatedList.getRelatedListWrapper(thisChild, parentObjectId, sobjectLimit, offset);
                    }
                }
            }
        }
        
        result.relatedPluralName = pluralSObjectName;
        return result;
    }
    
    
    private static Schema.ChildRelationship[] filterFromBlackList(Schema.SObjectType objectType){
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();
        Schema.ChildRelationship[] filtered = new List<Schema.ChildRelationship>();
        
        for(Schema.ChildRelationship cr : childRelationships){
            Schema.SObjectType crO = cr.getChildSObject();
            if(crO.getDescribe().isAccessible()){
                String name = crO.getDescribe().getName();
                
                if(!crO.getDescribe().isCustomSetting() && crO.getDescribe().isCreateable()){ 
                    Boolean notContainsIgnored = true;
                    for(String ignored : RELATIONSHIPS_BLACK_LIST){
                        if(name.containsIgnoreCase(ignored)){
                            notContainsIgnored = false;
                        }
                    } 
                    Set<String> unsupportedRelNames = getRelationshipNamesBlackList().get(objectType.getDescribe().getName());
                    if(unsupportedRelNames != null){
                        if(unsupportedRelNames.contains(cr.getRelationshipName())){
                            notContainsIgnored = false;
                        }
                    }
                    if(notContainsIgnored){
                        filtered.add(cr);
                    }
                }
            }
        }
        
        return filtered;
    }
        
    private static Map<String, Set<String>> getRelationshipNamesBlackList(){
    	Map<String, Set<String>> blackList = new Map<String, Set<String>>();
        blackList.put('Case', new Set<String>{'Emails'});
        blackList.put('Account', new Set<String>{'PartnersFrom', 'ProvidedAssets', 'ServicedAssets'});
     	return blackList;
    }
}