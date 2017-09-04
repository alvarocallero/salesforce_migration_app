@isTest
public class CaseRelatedListController_Test {
    @isTest
    static void testRelatedTeamMember(){
        String typeName = 'CaseTeamRole';
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if(targetType != null){
            Contact contactMember = new Contact(LastName='Contact');
            insert contactMember;
            
            Case c = new Case(Status='New');
            insert c;
            
            Integer limitOfSObjects = 10;
            RelatedList.Wrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'TeamMembers', limitOfSObjects);
            List<SObject> result = wrapper.relatedSObjects;
            
            System.assertEquals(0, result.size());
        }
    }
    
    @isTest
    static void testRelatedSolutions(){
        Case c = new Case(Status='New');
        insert c;
                
        Solution sol = new Solution(SolutionName='Sol name 1');
        insert sol;
        
        Solution solTwo = new Solution(SolutionName='Sol name 1');
        insert solTwo;
        
        CaseSolution caseSolution = new CaseSolution(CaseId=c.id, SolutionId=sol.id);
        insert caseSolution;
        
        CaseSolution caseSolutionTwo = new CaseSolution(CaseId=c.id, SolutionId=solTwo.id);
        insert caseSolutionTwo;
        
        Integer limitOfSObjects = 10;
        RelatedList.Wrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'CaseSolutions', limitOfSObjects);
        
        System.assert(wrapper.relatedSobjects.size() == 2);
        System.assert(wrapper.relatedSobjects[0].Id == sol.id || wrapper.relatedSobjects[0].Id == solTwo.id);
        System.assert(wrapper.relatedSobjects[1].Id == sol.id || wrapper.relatedSobjects[1].Id == solTwo.id);
        
    }
    
    @isTest
    static void testRelatedContactRoles(){
        
        Case c = new Case(Status='New');
        insert c;
                
        Contact contactForRoleOne = new Contact(LastName='Contact');
        insert contactForRoleOne;
        Contact contactForRoleTwo = new Contact(LastName='Contact');
        insert contactForRoleTwo;
        
        CaseContactRole contactRole = new CaseContactRole(CasesId=c.id, ContactId=contactForRoleOne.id);
        insert contactRole;
        CaseContactRole contactRoleTwo = new CaseContactRole(CasesId=c.id, ContactId=contactForRoleTwo.id);
        insert contactRoleTwo;
        
        Integer limitOfSObjects = 10;
        RelatedList.Wrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'CaseContactRoles', limitOfSObjects);
        
        System.assert(wrapper.relatedSobjects.size() == 2);
        System.assert(wrapper.relatedSobjects[0].Id == contactForRoleOne.id || wrapper.relatedSobjects[0].Id == contactForRoleTwo.id);
        System.assert(wrapper.relatedSobjects[1].Id == contactForRoleOne.id || wrapper.relatedSobjects[1].Id == contactForRoleTwo.id);
        
        
    }
    
    @isTest
    static void testEmptyRelatedContactRoles(){
        Case c = new Case(Status='New');
        insert c;
                
        Integer limitOfSObjects = 10;
        RelatedList.Wrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'CaseContactRoles', limitOfSObjects);
        
        System.assert(wrapper.relatedSobjects.size() == 0); 
    }

}