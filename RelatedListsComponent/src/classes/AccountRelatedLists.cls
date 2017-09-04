public class AccountRelatedLists {
    
    public static RelatedList.Wrapper getRelatedListWrapper(String relationshipName, ID parentObjectId, Integer sobjectLimit, Integer offset){
        RelatedList.Wrapper result = null;
        if(relationshipName == 'PartnersTo'){
            result = getRelatedPartners(parentObjectId, sobjectLimit, offset);
        }
        return result;
    }
    

    private static RelatedList.Wrapper getRelatedPartners(ID parentObjectId, Integer sobjectLimit, Integer offset){
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
         
        RelatedList.Wrapper result = new RelatedList.Wrapper();
        result.relatedSObjects = accounts;
        result.numberOfSObjects = accountCount;
        return result;
    }
}