public with sharing class InsertFutureObjects {
    @future
    public static void createCaseTeamRole(){
        
        CaseTeamRole role = new CaseTeamRole(Name='Admin', AccessLevel='Read');
        insert role;
        
    }
}