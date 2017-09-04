public class RelatedList {
    public class Wrapper{
        public Wrapper(){
            relatedPluralName = '';
            numberOfSObjects = 0;
            relatedSObjects = new List<SObject>();
        }
        @AuraEnabled
        public String relatedPluralName {get; set;}
        @AuraEnabled
        public SObject[] relatedSObjects {get; set;}
        @AuraEnabled
        public Integer numberOfSObjects {get; set;}
    }
    
    public static Wrapper getRelatedListWrapper(Schema.ChildRelationship child, ID parentObjectId, Integer sobjectLimit, Integer offset){
        Wrapper result = null; 
        String relationshipName = child.getRelationshipName();
        String parentApiName = parentObjectId.getSobjectType().getDescribe().getName();
        if(parentApiName == 'Account'){  
            result = AccountRelatedLists.getRelatedListWrapper(relationshipName, parentObjectId, sobjectLimit, offset);
        }else if(parentApiName == 'Case'){
            result = CaseRelatedLists.getRelatedListWrapper(relationshipName, parentObjectId, sobjectLimit, offset);
        }
        if(result == null){
            result = getDefaultRelatedObjects(child, parentObjectId, sobjectLimit, offset);
        }
        return result;
    }
    
    
    public static Wrapper getDefaultRelatedObjects(Schema.ChildRelationship child, ID parentObjectId, Integer sobjectLimit, Integer offset){
		Schema.SObjectType childObjectType = child.getChildSObject();
        Schema.SObjectField childFieldName = child.getField();
        Map<String, SObjectField> fieldsMap = childObjectType.getDescribe().fields.getMap();
        List<Schema.SObjectField> fieldList = fieldsMap.values();        
        String relatedObjectName = child.getChildSObject().getDescribe().getName();
        
        String queryString = 'SELECT Id FROM ';
        for(SObjectField field : fieldList){
            if(String.valueOf(field) == 'Name'){
                Boolean nameIsAccessible = fieldsMap.get('Name').getDescribe().isAccessible();
                if(nameIsAccessible){
                    queryString = 'SELECT Id, Name FROM ';
                }
            }
        }
        queryString += relatedObjectName + ' WHERE ' + childFieldName + ' = \'' + parentObjectId 
            		+ '\' LIMIT ' + sobjectLimit + ' OFFSET ' + offset;
        List<SObject> sobjectList = Database.query(queryString);
        
        String countQuery = 'SELECT count() FROM ' + relatedObjectName + ' WHERE ' + childFieldName + ' = \'' + parentObjectId + '\'';
		Integer sObjectCount = Database.countQuery(countQuery);
        
        Wrapper result = new Wrapper();
		result.relatedSObjects = sobjectList;
        result.numberOfSObjects = sObjectCount;
        return result;
    }
    
}