@isTest
public class KnownIssuesAdministrationControllerTest {
    static testMethod void testLoadKnownIssuesInController(){
        KnownIssuesAdministrationController controller = new KnownIssuesAdministrationController();
       
        System.assert(controller.selectedKeyword == 'All');
        System.assert(controller.selectedStatus == 'Pending Approval');
        List<SelectOption> keywords = controller.getKeywordSelectOptions();
        List<SelectOption> status = controller.getStatusSelectOptions();
        System.assert(keywords.size() > 0);
        System.assert(status.size() > 0);
    }
    
    static testMethod void testFilterUnknown(){
        KnownIssuesAdministrationController controller = new KnownIssuesAdministrationController();
        controller.selectedKeyword = 'Unknown';
       	controller.reloadKnowIssues();
        List<Known_Issue__c> filtered = controller.filteredKnownIssues;
        System.assert(filtered.size() == 0);
    }
    
    static testMethod void testFilterKeywordNull(){
        KnownIssuesAdministrationController controller = new KnownIssuesAdministrationController();
        controller.selectedKeyword = null;
        controller.selectedStatus = null;
        
       	controller.reloadKnowIssues();
        List<Known_Issue__c> filtered = controller.filteredKnownIssues;
        System.assert(filtered.size() == 0);
    }
    
    
}