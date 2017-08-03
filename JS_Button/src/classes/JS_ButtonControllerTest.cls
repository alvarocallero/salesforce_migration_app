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
}