public with sharing class Js_ButtonController {
    @AuraEnabled
    public static Object getObject(String recordId, String objectName, String fieldList){
    	system.debug('recordId = '+ recordId);
    	system.debug('objectName = '+ objectName);
    	system.debug('fieldList = '+ fieldList);
    	
    	String query = 'SELECT '+ fieldList + ' from '+ objectName + ' where id = \''+ recordId + '\' limit 1';
    	system.debug('query = '+ query);
    	sObject s = Database.query(query);
    	return s;
    	//return null;
    }
}