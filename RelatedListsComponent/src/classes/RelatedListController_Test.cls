@isTest
public class RelatedListController_Test {
    @isTest
    static void testGetRelatedList(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Integer numberOfOpportunities = 5;
        Opportunity[] opportunities = new List<Opportunity>();
        for(Integer i = 0; i<numberOfOpportunities;i++){
        	Opportunity opp = new Opportunity(Name = 'Opp'+i, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
            opportunities.add(opp);
        }
        insert opportunities;
        
        Integer limitOfSObjects = 10;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(numberOfOpportunities, result.size());
    }
    
    @isTest
    static void testGetRelatedListInvalidId(){
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(null, 'Opportunity', 10);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(0, result.size());
    }
    
    @isTest
    static void testGetRelatedListInvalidRelatedObject(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Oportunity', 10);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(0, result.size());
    }
    
    @isTest
    static void testGetRelatedPluralName(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', 10);
        String pluralName = wrapper.relatedPluralName;

        System.assertEquals('Opportunities', pluralName);
    }
    
    @isTest
    static void testGetRelatedPluralNameBadName(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Oportunity', 10);
        String pluralName = wrapper.relatedPluralName;

        System.assertEquals('', pluralName);
    }
    
    @isTest
    static void testGetRelatedPluralNameBadId(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(null, 'Opportunity', 10);
        String pluralName = wrapper.relatedPluralName;

        System.assertEquals('', pluralName);
    }
    
    @isTest
    static void testRelatedListLimit(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Integer numberOfOpportunities = 15;
        Opportunity[] opportunities = new List<Opportunity>();
        for(Integer i = 0; i<numberOfOpportunities;i++){
        	Opportunity opp = new Opportunity(Name = 'Opp'+i, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
            opportunities.add(opp);
        }
        insert opportunities;
        
        Integer limitOfSObjects = 10;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(limitOfSObjects, result.size());
    }
    
    @isTest
    static void testRelatedListPaginationFirstPage(){
    	Account acc = new Account(Name = 'Account');
        insert acc;
        Integer numberOfOpportunities = 34;
        Opportunity[] opportunities = new List<Opportunity>();
        for(Integer i = 0; i<numberOfOpportunities;i++){
        	Opportunity opp = new Opportunity(Name = 'Opp'+i, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
            opportunities.add(opp);
        }
        insert opportunities;
        
        Integer limitOfSObjects = 10;
        Integer offset = 0;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', offset, limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(limitOfSObjects, result.size());
        Opportunity sobj = (Opportunity)result[0];
        System.assertEquals('Opp0', sobj.Name);
    }
    
    @isTest
    static void testRelatedListPaginationSecondPage(){
    	Account acc = new Account(Name = 'Account');
        insert acc;
        Integer numberOfOpportunities = 34;
        Opportunity[] opportunities = new List<Opportunity>();
        for(Integer i = 0; i<numberOfOpportunities;i++){
        	Opportunity opp = new Opportunity(Name = 'Opp'+i, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
            opportunities.add(opp);
        }
        insert opportunities;
        
        Integer limitOfSObjects = 10;
        Integer actualPage = 1;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', actualPage, limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(limitOfSObjects, result.size());
        Opportunity sobj = (Opportunity)result[0];
        System.assertEquals('Opp10', sobj.Name);
    }
    
    @isTest
    static void testRelatedListPaginationLastPage(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Integer numberOfOpportunities = 34;
        Opportunity[] opportunities = new List<Opportunity>();
        for(Integer i = 0; i<numberOfOpportunities;i++){
        	Opportunity opp = new Opportunity(Name = 'Opp'+i, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
            opportunities.add(opp);
        }
        insert opportunities;
        
        Integer limitOfSObjects = 10;
        Integer actualPage = 3;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', actualPage, limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(4, result.size());
        Opportunity sobj = (Opportunity)result[0];
        System.assertEquals('Opp30', sobj.Name);
    }
    
    @isTest
    static void testRelatedListPaginationOutOfBounds(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Integer numberOfOpportunities = 34;
        Opportunity[] opportunities = new List<Opportunity>();
        for(Integer i = 0; i<numberOfOpportunities;i++){
        	Opportunity opp = new Opportunity(Name = 'Opp'+i, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
            opportunities.add(opp);
        }
        insert opportunities;
        
        Integer limitOfSObjects = 10;
        Integer actualPage = 3;
        RelatedListController.RelatedListWrapper wrapper = RelatedListController.listOfRelatedObjects(acc.id, 'Opportunity', actualPage, limitOfSObjects);
        List<SObject> result = wrapper.relatedSObjects;
        
        System.assertEquals(4, result.size());
        Opportunity sobj = (Opportunity)result[0];
        System.assertEquals('Opp30', sobj.Name);
    }
    
    @isTest
    static void testGetAllRelationships(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        List<String> relationships = RelatedListController.returnAllRelationships(acc.id);
       	
        System.assert(relationships.size() > 0);
    }
}