global class EinsteinPackageInstallerChecker implements InstallHandler{
    global void onInstall(InstallContext context) {
        system.debug('Executing onInstall method on EinsteinPackageInstallerChecker');
        
        if(context.previousVersion() == null) {
            String usrInstallerId = context.installerID();
            if(usrInstallerId == null || usrInstallerId.equals('')){
                system.debug('The installerId is null');
            }else{
                List<PermissionSet> lst = [select id from PermissionSet where name = 'Bot_Admin'];
                
                if (lst == null || lst.isEmpty()){
                    system.debug('There´s no PermissionSet with name Bot_Admin');
                }else{
                    String permSetId = lst[0].Id;
                    PermissionSetAssignment permSetAss = new PermissionSetAssignment(AssigneeId =usrInstallerId,PermissionSetId =permSetId);
                    insert permSetAss;
                    
                    checkEinsteinAvailable checkEinstAv = new checkEinsteinAvailable();
                    //run once per hour
                    String sch = '0 0 * * * * ?';
                    system.schedule('Adoption Bot Status', sch, checkEinstAv);
                }     
            }
            system.debug('Leaving EinsteinPackageInstallerChecker');   
        }
    }
}