public with sharing class Js_ButtonController {
    @AuraEnabled
    public static Object getObject(String recordId, String objectName, String fieldList){
        if(Schema.getGlobalDescribe().get(objectName) != null){
            String filteredFields = filterFieldsList(objectName, fieldList); 
            try{
                String query = 'SELECT '+ filteredFields + ' from '+ objectName + ' where id = \''+ String.escapeSingleQuotes(recordId) + '\' limit 1';
                sObject queryResult = Database.query(query);
                return queryResult;
            }catch(Exception ex){
                return null;
            }    
        }else{
            return null;
        }
        
    }
    
    private static String filterFieldsList(String objectName, String fieldList){
        List<String> fields = fieldList.deleteWhitespace().split(',');
        List<String> availableFields = new List<String>();
        Map<String, SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(String field : fields){
            if(fieldsMap.containsKey(field)){
                if(fieldsMap.get(field).getDescribe().isAccessible()){
                    availableFields.add(field); 
                }
            }
        }
        return String.join(availableFields, ',');
    }
    
}