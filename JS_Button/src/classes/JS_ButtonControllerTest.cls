@isTest
public class JS_ButtonControllerTest {
	@isTest
    static void testGetObject(){	
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
        insert opp;
        Id recordId = opp.Id;
        String objectName = 'Opportunity';
        String fieldList = 'Name,StageName';
    	Opportunity result = (Opportunity)Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals('Prospecting', result.StageName);
        System.assertEquals('Opp', result.Name);
    }
    
    @isTest
    static void testGetObjectReturnNull(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
        insert opp;
        Id recordId = acc.Id;
        String objectName = 'Opportunity';
        String fieldList = 'Name,StageName';
    	
        Object nullObject = Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals(nullObject, null);
    }
    
    @isTest
    static void testBadFieldApiName(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
        insert opp;
        Id recordId = opp.Id;
        String objectName = 'Opportunity';
        String fieldList = 'Name,Stage';
    	
        Opportunity result = (Opportunity)Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals('Opp', result.Name);
        System.SObjectException ex = null;
        try{
        	System.assertEquals('', result.StageName);    
        }catch(System.SObjectException sobjexception){
    		ex = sobjexception;
    	}
        System.assert(ex != null);
                
    }
    
    @isTest
    static void testBadEmptyFieldApiNames(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
        insert opp;
        Id recordId = opp.Id;
        String objectName = 'Opportunity';
        String fieldList = '';
    	
        Opportunity result = (Opportunity)Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals(null, result);
    }
    
    @isTest
    static void testOnlyOneBadAttribute(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
        insert opp;
        Id recordId = opp.Id;
        String objectName = 'Opportunity';
        String fieldList = '';
    	
        Opportunity result = (Opportunity)Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals(null, result);
    }
    
    @isTest
    static void testIncorrectObjectApiName(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id); 
        insert opp;
        Id recordId = opp.Id;
        String objectName = 'Oportunity';
        String fieldList = 'Name, Probability';
    	
        Opportunity result = (Opportunity)Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals(null, result);
    }
    
    @isTest
    static void testSpacesBetweenFields(){
        Account acc = new Account(Name = 'Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.id, Probability = 43); 
        insert opp;
        Id recordId = opp.Id;
        String objectName = 'Opportunity';
        String fieldList = 'Name, Probability';
    	
        Opportunity result = (Opportunity)Js_ButtonController.getObject(recordId, objectName, fieldList);
        System.assertEquals(43, result.Probability);
    }
}