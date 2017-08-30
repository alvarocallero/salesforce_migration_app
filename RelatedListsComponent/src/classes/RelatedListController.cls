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
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();
        
        Schema.ChildRelationship[] filteredChilds = filterFromBlackList(childRelationships);
            
        for(Schema.ChildRelationship thisChild : filteredChilds){
            String apiName = string.valueOf(thisChild.getChildSObject());
            String pluralName = string.valueOf(thisChild.getChildSObject().getDescribe().getLabelPlural());
            String relationshipName = string.valueOf(thisChild.getRelationshipName());
            if(relationshipName != null){
                results.put(relationshipName, pluralName);
                //results.put(relationshipName, String.join(relationshipName.split('(?=[A-Z])'),' '));    
            }else{
                System.debug('Null relationship name of: ' + apiName);
            }
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
        RelatedListWrapper result = new RelatedListWrapper();
        if(parentObjectId != null){
            Schema.SObjectType objectType = parentObjectId.getSobjectType();//get the type of object of the parent
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships(); //get the children relationships
            
            Integer attempt = 0; 
            for(Schema.ChildRelationship thisChild : childRelationships)
            {
                
                
                
                String relationshipName = thisChild.getRelationshipName();
                if(relationshipName == childObjectName){
                    Schema.SObjectType childObjectType = thisChild.getChildSObject();
                    Schema.SObjectField childFieldName = thisChild.getField();
                    Map<String, SObjectField> fieldsMap = childObjectType.getDescribe().fields.getMap();
                    List<Schema.SObjectField> fieldList = fieldsMap.values();
                    String relatedObjectName = thisChild.getChildSObject().getDescribe().getName();
                    Integer sobjectLimit = Integer.valueOf(numberOfSObjects);
                    Integer offset = Integer.valueOf(actualPage) * sobjectLimit;
                    if(childObjectType.getDescribe().isAccessible()){
                        pluralSObjectName = thisChild.getChildSObject().getDescribe().getLabelPlural();
                        //TODO: Change for relationship name and store relationship names in constant
                        String parentApiName = parentObjectId.getSobjectType().getDescribe().getName();
                        
                        if(parentApiName == 'Account' && childObjectName == 'PartnersTo'){  
                            result = getRelatedPartners(parentObjectId, sobjectLimit, offset);
                        }else if(parentApiName == 'Case' && childObjectName == 'TeamMembers'){
                            result = getRelatedCaseTeamMembers(parentObjectId, sobjectLimit, offset);
                        }else if(parentApiName == 'Case' && childObjectName == 'CaseSolutions'){
                            result = getRelatedCaseSolutions(parentObjectId, sobjectLimit, offset);
                        }else if(parentApiName == 'Case' && childObjectName == 'CaseContactRoles'){
                            result = getRelatedCaseContactRoles(parentObjectId, sobjectLimit, offset);
                        }else{
                            result = getDefaultRelatedObjects(thisChild, parentObjectId, sobjectLimit, offset);
                        }
                    }
                    attempt ++;
                }
            }
        }
        
        result.relatedPluralName = pluralSObjectName;
        return result;
    }
    
    
    private static Schema.ChildRelationship[] filterFromBlackList(Schema.ChildRelationship[] childRelationships){
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
                    if(notContainsIgnored){
                        filtered.add(cr);
                    }
                }
            }
        }
        
        return filtered;
    }
    
    private static RelatedListWrapper getRelatedPartners(ID parentObjectId, Integer sobjectLimit, Integer offset){
        List<Account> accounts = new List<Account>();
        Integer accountCount = 0;
        Map<String, SObjectField> accountfieldsMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        if(accountfieldsMap.get('Id').getDescribe().isAccessible()){
            if(accountfieldsMap.get('Name').getDescribe().isAccessible()){        
                accounts = [SELECT ID, Name FROM Account 
                            WHERE Id IN (SELECT AccountToId FROM AccountPartner WHERE AccountFromId = :parentObjectId) 
                            LIMIT :sobjectLimit OFFSET :offset];
            }else{
                accounts = [SELECT ID FROM Account 
                            WHERE Id IN (SELECT AccountToId FROM AccountPartner WHERE AccountFromId = :parentObjectId) 
                            LIMIT :sobjectLimit OFFSET :offset];
            }
            accountCount = [SELECT count() FROM Account 
                            WHERE Id IN (SELECT AccountToId FROM AccountPartner WHERE AccountFromId = :parentObjectId)];
        }
         
        RelatedListWrapper result = new RelatedListWrapper();
        result.relatedSObjects = accounts;
        result.numberOfSObjects = accountCount;
        return result;
    }
    
    private static RelatedListWrapper getRelatedCaseTeamMembers(ID parentObjectId, Integer sobjectLimit, Integer offset){
        List<Contact> contactMembers = new List<Contact>();
        List<User> userMembers = new List<User>();
        Integer contactsCount = 0;
        Integer usersCount = 0;
        
        List<CaseTeamMember> members = [SELECT MemberId From CaseTeamMember WHERE ParentId = :parentObjectId LIMIT :sobjectLimit OFFSET :offset];
        
        Set<Id> memberIds = new Set<Id>();
        for(CaseTeamMember member : members){
            memberIds.add(member.MemberId);
        }
        
        Map<String, SObjectField> contactfieldsMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        if(contactfieldsMap.get('Id').getDescribe().isAccessible()){
            if(contactfieldsMap.get('Name').getDescribe().isAccessible()){        
                contactMembers = [SELECT ID, Name FROM Contact where id IN :memberIds];
            }else{
                contactMembers = [SELECT ID FROM Contact where id IN :memberIds];
            }
            contactsCount = [SELECT count() From Contact WHERE Id IN (SELECT MemberId From CaseTeamMember WHERE ParentId = :parentObjectId)];
        }
        
        Map<String, SObjectField> userfieldsMap = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
        if(userfieldsMap.get('Id').getDescribe().isAccessible()){
            if(userfieldsMap.get('Name').getDescribe().isAccessible()){        
                userMembers = [SELECT ID, Name FROM User where id IN :memberIds];
            }else{
                userMembers = [SELECT ID FROM User where id IN :memberIds];
            }
            usersCount = [SELECT count() From User WHERE Id IN (SELECT MemberId From CaseTeamMember WHERE ParentId = :parentObjectId)];
        }
        
        List<Sobject> membersResult = new List<Sobject>();
        membersResult.addAll((List<Sobject>)contactMembers);
        membersResult.addAll((List<Sobject>)userMembers);
        
        RelatedListWrapper result = new RelatedListWrapper();
        result.relatedSObjects = membersResult;
        result.numberOfSObjects = contactsCount + usersCount;
        return result;   
    }
    
    private static RelatedListWrapper getRelatedCaseSolutions(ID parentObjectId, Integer sobjectLimit, Integer offset){      
        List<Solution> solutions = new List<Solution>();
        Integer solutionsCount = 0;
        //Check field name accessibility:
        Map<String, SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Solution').getDescribe().fields.getMap();
        
        if(fieldsMap.get('Id').getDescribe().isAccessible()){
            solutions = [SELECT ID FROM Solution 
                         WHERE Id IN (SELECT SolutionId FROM CaseSolution WHERE CaseId = :parentObjectId) 
                         LIMIT :sobjectLimit OFFSET :offset];
            
            solutionsCount = [SELECT count() FROM Contact 
                              WHERE Id IN (SELECT ContactId FROM CaseContactRole WHERE CasesId = :parentObjectId)];
        }
                
        RelatedListWrapper result = new RelatedListWrapper();
        result.relatedSObjects = solutions;
        result.numberOfSObjects = solutionsCount;
        return result;
    }
    
	private static RelatedListWrapper getRelatedCaseContactRoles(ID parentObjectId, Integer sobjectLimit, Integer offset){      
        List<Contact> contacts = new List<Contact>();
        Integer contactsCount = 0;
        //Check field and name accessibility:
        Map<String, SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        
        if(fieldsMap.get('Id').getDescribe().isAccessible()){
            if(fieldsMap.get('Name').getDescribe().isAccessible()){
                contacts = [SELECT ID, Name FROM Contact 
                            WHERE Id IN (SELECT ContactId FROM CaseContactRole WHERE CasesId = :parentObjectId) 
                            LIMIT :sobjectLimit OFFSET :offset];
            }else{
                contacts = [SELECT ID FROM Contact 
                            WHERE Id IN (SELECT ContactId FROM CaseContactRole WHERE CasesId = :parentObjectId) 
                            LIMIT :sobjectLimit OFFSET :offset];
            }
        
           contactsCount = [SELECT count() FROM Contact 
                                     WHERE Id IN (SELECT ContactId FROM CaseContactRole WHERE CasesId = :parentObjectId)];
        }
        
        RelatedListWrapper result = new RelatedListWrapper();
        result.relatedSObjects = contacts;
        result.numberOfSObjects = contactsCount;
        return result;
    }
    
    private static RelatedListWrapper getDefaultRelatedObjects(Schema.ChildRelationship child, ID parentObjectId, Integer sobjectLimit, Integer offset){
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
        
        RelatedListWrapper result = new RelatedListWrapper();
		result.relatedSObjects = sobjectList;
        result.numberOfSObjects = sObjectCount;
        return result;
    }
    
    public class RelatedListWrapper{
        public RelatedListWrapper(){
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
    
}