@isTest
public class CaseRelatedListController_Test {
    @isTest
    static void testRelatedTeamMember(){
        InsertFutureObjects.createCaseTeamRole();

        Contact contactMember = new Contact(LastName='Contact');
        insert contactMember;
        
        Id userId = UserInfo.getUserId();

        Case c = new Case(Status='New');
        insert c;

        CaseTeamRole role = [Select id from CaseTeamRole Limit 1];

        CaseTeamMember teamContactMember = new CaseTeamMember(MemberId=contactMember.id, ParentId=c.id, TeamRoleId=role.id);
        CaseTeamMember teamUserMember = new CaseTeamMember(MemberId=userId, ParentId=c.id, TeamRoleId=role.id);
        
        insert teamContactMember;
 		insert teamUserMember;

        Integer limitOfSObjects = 10;
        Integer numberOfMembers = 2;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'TeamMembers', limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(numberOfMembers, result.size());

        Sobject memberOne = result[0];
        Sobject memberTwo = result[1];
        System.assert(memberOne.id == contactMember.id || memberOne.id == userId);
        System.assert(memberTwo.id == contactMember.id || memberTwo.id == userId);

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
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'CaseSolutions', limitOfSObjects);
        
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
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(c.id, 'CaseContactRoles', limitOfSObjects);
        
        System.assert(wrapper.relatedSobjects.size() == 2);
        System.assert(wrapper.relatedSobjects[0].Id == contactForRoleOne.id || wrapper.relatedSobjects[0].Id == contactForRoleTwo.id);
        System.assert(wrapper.relatedSobjects[1].Id == contactForRoleOne.id || wrapper.relatedSobjects[1].Id == contactForRoleTwo.id);
        
    }

}