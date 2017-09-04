public class CaseRelatedLists {
	
    public static RelatedList.Wrapper getRelatedListWrapper(String relationshipName, ID parentObjectId, Integer sobjectLimit, Integer offset){
        RelatedList.Wrapper result = null;
        if(relationshipName == 'TeamMembers'){
            result = getTeamMembers(parentObjectId, sobjectLimit, offset);
        }else if(relationshipName == 'CaseSolutions'){
            result = getSolutions(parentObjectId, sobjectLimit, offset);
        }else if(relationshipName == 'CaseContactRoles'){
            result = getContactRoles(parentObjectId, sobjectLimit, offset);
        }
        return result;
    }
    
    private static RelatedList.Wrapper getContactRoles(ID parentObjectId, Integer sobjectLimit, Integer offset){      
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
        
        RelatedList.Wrapper result = new RelatedList.Wrapper();
        result.relatedSObjects = contacts;
        result.numberOfSObjects = contactsCount;
        return result;
    }
    
    private static RelatedList.Wrapper getSolutions(ID parentObjectId, Integer sobjectLimit, Integer offset){      
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
                
        RelatedList.Wrapper result = new RelatedList.Wrapper();
        result.relatedSObjects = solutions;
        result.numberOfSObjects = solutionsCount;
        return result;
    }
    
    private static RelatedList.Wrapper getTeamMembers(ID parentObjectId, Integer sobjectLimit, Integer offset){
        List<Contact> contactMembers = new List<Contact>();
        List<User> userMembers = new List<User>();
        Integer contactsCount = 0;
        Integer usersCount = 0;
        
        String membersQuery = 'SELECT MemberId From CaseTeamMember WHERE ParentId = \'' + parentObjectId + '\' LIMIT ' + sobjectLimit + ' OFFSET ' + offset;
        List<CaseTeamMember> members = Database.query(membersQuery);
        
        Set<Id> memberIds = new Set<Id>();
        for(CaseTeamMember member : members){
            memberIds.add(member.MemberId);
        }
        
        Map<String, SObjectField> contactfieldsMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        if(contactfieldsMap.get('Id').getDescribe().isAccessible()){
            String contactsQuery = 'SELECT Id FROM Contact WHERE Id IN :memberIds';
            if(contactfieldsMap.get('Name').getDescribe().isAccessible()){         
                contactsQuery = 'SELECT Id, Name FROM Contact WHERE Id IN :memberIds';
            }
            String contactsCountQuery = 'SELECT count() FROM Contact WHERE Id IN :memberIds';
            System.debug(contactsQuery);
            contactMembers = Database.query(contactsQuery);
            contactsCount = Database.countQuery(contactsCountQuery);
        }
        
        Map<String, SObjectField> userfieldsMap = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
        if(userfieldsMap.get('Id').getDescribe().isAccessible()){
            String usersQuery = 'SELECT Id FROM User WHERE Id IN :memberIds';
            if(userfieldsMap.get('Name').getDescribe().isAccessible()){        
                usersQuery = 'SELECT Id, Name FROM User WHERE Id IN :memberIds';
            }
            String usersCountQuery = 'SELECT count() FROM User WHERE Id IN :memberIds';
            userMembers = Database.query(usersQuery);
            usersCount = Database.countQuery(usersCountQuery);
        }
        
        List<Sobject> membersResult = new List<Sobject>();
        membersResult.addAll((List<Sobject>)contactMembers);
        membersResult.addAll((List<Sobject>)userMembers);
        
        RelatedList.Wrapper result = new RelatedList.Wrapper();
        result.relatedSObjects = membersResult;
        result.numberOfSObjects = contactsCount + usersCount;
        return result;   
    }
}