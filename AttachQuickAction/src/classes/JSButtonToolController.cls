public class JSButtonToolController {
    
    public JSButtonToolController(){
        fillObject();
        fillComponents();
        fillLayouts();     
    }
    public List<SelectOption> objectList = getAllObjects();
    
    private static Boolean hasError = false;
    public Boolean getHasError(){
        return hasError;
    } 
    
    private static Boolean hasSuccess = false;
    public Boolean getHasSuccess(){
        return hasSuccess;
    } 
    
    private Boolean hasLayout = false; 
    public Boolean getHasLayout(){
        return hasLayout;
    }
    
    private static String errorMessage;
    public String getErrorMessage(){
        return errorMessage;    
    }
    private static String successMessage;
    public String getSuccessMessage(){
        return successMessage;    
    }
    
    public String selectOptionObject {get;  set;}
    public string quickActionName { get; set; }
    public String selectOptionComponent {get; set;}
    
    String[] selectOptionLayout = new String[]{};
        public String[] getSelectOptionLayout() {
            return selectOptionLayout;
        }
    
    public void setSelectOptionLayout(String[] countries) {
        this.selectOptionLayout = countries;
    }
    
    private Map<String,String> mappedObjects = new Map<String, String>();
    private List<SelectOption> options = new List<SelectOption>();
    private List<SelectOption> componentsOptions = new List<SelectOption>();
    private List<SelectOption> layoutsOptions = new List<SelectOption>();
    
    // get specific object -- ok
    private static List<MetadataService.FileProperties> listMetadataObject(String objectName) {
        
        String regex = 'objects[/]'+objectName+'[.]object';
        String metadataType = 'CustomObject';
        return listMetadataByType(regex, metadataType);
    }
    
    // get all custom objects -- ok
    private static List<MetadataService.FileProperties> listMetadataObjectAll() {    
        String regex = '.*[.]object';
        String metadataType = 'CustomObject';
        return listMetadataByType(regex, metadataType);
    }
    
    // get all the layouts from the object -- ok
    private static List<MetadataService.FileProperties> listMetadataLayout(String objectName) {
        String regex = 'layouts[/]'+objectName+'-.*[.]layout';
        String metadataType = 'Layout';
        return listMetadataByType(regex, metadataType);
        
    }
    
    // get all the quickActions -- ok
    private static List<MetadataService.FileProperties> listMetadataQuickActions() {
        String regex = 'quickActions/.*[.]quickAction';
        String metadataType = 'QuickAction';
        return listMetadataByType(regex, metadataType);
    }
    
    // get all the components -- ok
    private static List<MetadataService.FileProperties> listMetadataComponents() {
        
        String regex = 'aura/.*';
        String metadataType = 'AuraDefinitionBundle';
        
        return listMetadataByType(regex, metadataType);
    }
    
    // list all Metadata of the specific type -- ok    
    private static List<MetadataService.FileProperties> listMetadataByType(String regex, String metadataType){
        
        MetadataService.MetadataPort service = createService();
        
        List<MetadataService.FileProperties> result = new List<MetadataService.FileProperties>();
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryMetaData = new MetadataService.ListMetadataQuery();
        // type of metadata
        queryMetaData.type_x = metadataType;
        queries.add(queryMetaData);
        
        // !important: listMetadata(query, apiVersion)
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 40);
        
        for(MetadataService.FileProperties fileProperty : fileProperties){
            
            String text = fileProperty.fileName;
            Matcher m = Pattern.compile(regex).matcher(text);
            
            // if regEx match add it to results
            if(m.matches()) {
                result.add(fileProperty);
                System.debug('---Object---> '+ fileProperty.fileName);
            }
        }
        return result;
    }
    
    // create quickaction -- ok
    private static String createQuickAction(string component, string name, string obj){
        try{
            MetadataService.MetadataPort service  = createService();
            MetadataService.QuickAction quickAction = new MetadataService.QuickAction();
            quickAction.fullName = obj+'.'+name;
            quickAction.label = name;
            quickAction.lightningComponent = component;
            quickAction.type_x = 'LightningComponent';
            quickAction.height = 250;
            quickAction.width = 100; 
            quickAction.optionsCreateFeedItem = false;
            List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { quickAction });    
            System.debug('---------------------------'+ results);
            
            if(results[0].success == true){
                return name;
            }   
            errorManager('Cannot create Quick Action');
        }
        catch(Exception e){
            System.debug(e); 
            errorManager(e.getMessage());
        }
        return null;
    }
    
    // update layout -- ok
    private static String readAndUpdateLayout(  String selectLayout, String quickActionName, String obj ){
        try{
            MetadataService.MetadataPort service = createService();
            // Read the Layout
            MetadataService.Layout layout =
                (MetadataService.Layout) service.readMetadata('Layout', new String[] { selectLayout }).getRecords()[0];
            
            MetadataService.PlatformActionListItem newPlatformActionListItem = new MetadataService.PlatformActionListItem();
            newPlatformActionListItem.actionName = obj+'.'+quickActionName;
            newPlatformActionListItem.actionType = 'QuickAction';
            newPlatformActionListItem.sortOrder = layout.platformActionList.platformActionListItems.size();
            
            // Add the Custom Button to the Layout
            layout.platformActionList.platformActionListItems.add(newPlatformActionListItem);
            
            // Update the Layout
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { layout });
            return 'The quickAction was added to '+selectLayout;
        }
        catch(Exception e){
            System.debug(e);
            errorManager(e.getMessage());
            return null;
        }  
    }
    
    // create a new service -- ok
    private static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort(); 
        service.SessionHeader = new MetadataService.SessionHeader_element(); 
        service.SessionHeader.sessionId = UserInfo.getSessionId(); 
        return service; 
    } 
    
    // return all objects --ok 
    private void fillObject(){
        try{
            List<MetadataService.FileProperties> listOfObjects = listMetadataObjectAll();
            
            
            for(MetadataService.FileProperties selectedObject : listOfObjects ){
                string objectName = selectedObject.fullname;
                string objectId = selectedObject.fullname;
                this.mappedObjects.put(objectId, objectName);
                List<MetadataService.FileProperties>temp = listMetadataLayout(objectName);
                if(temp.size()>0){
                    this.options.add(new SelectOption(objectName, objectName));
                }   
            }
            this.options.sort(); 
        }
        catch(Exception e){
            errorManager(e.getMessage());
        }
    }
    
    public List<SelectOption> getAllObjects() {
        return this.options;
    }
    
    // return all components
    private void fillComponents(){
        try{
            List<MetadataService.FileProperties> listOfComponents = listMetadataComponents();
            
            for(MetadataService.FileProperties selectedComponent : listOfComponents ){
                string componentName = selectedComponent.fullname;
                string componentId = selectedComponent.Id;
                this.componentsOptions.add(new SelectOption(componentName,componentName));
                this.componentsOptions.sort();
            }
        }
        catch(Exception e){
            errorManager(e.getMessage());
        }
    }
    
    public List<SelectOption> getAllComponents() {
        return this.componentsOptions;
    }
    
    //return layouts of the object
    private void fillLayouts(){
        try{
            if(selectOptionObject != null){
                List<MetadataService.FileProperties> listOfLayouts = listMetadataLayout(selectOptionObject);  
                layoutsOptions.clear();
                for(MetadataService.FileProperties selectedLayout : listOfLayouts ){
                    string layoutName = selectedLayout.fullname;
                    layoutName=layoutName.replace('%28', '');
                    layoutName=layoutName.replace('%29', '');
                    layoutName=layoutName.replace(selectOptionObject+'-', '');
                    string layoutId = selectedLayout.fullname;
                    this.layoutsOptions.add(new SelectOption(layoutId,layoutName));
                    this.layoutsOptions.sort();
                }
                
            }
        }
        catch(Exception e){
            errorManager(e.getMessage());
        }
    }
    
    public List<SelectOption> getAllLayouts() {     
        return this.layoutsOptions;
    }
    
    // refresh layout
    public void reloadLayoutGrid(){
        System.debug('este es el reload '+ this.selectOptionObject);
        hasLayout = true;
        hasError = false;
        hasSuccess = false;
        fillLayouts();     
    }
    
    private static void errorManager(string msg){
        errorMessage = msg;
        hasError = true;
    }
    
    private static void successManager(string msg){
        successMessage = msg;
        hasSuccess = true;
    }
    
    public void attachToLayout(){
        
        if(quickActionName == '' || quickActionName == null){
            errorManager('The name cannot be empty');
        }else{
            if(selectOptionLayout.size()>0){
                String newQuickAction = createQuickAction(this.selectOptionComponent, this.quickActionName, this.selectOptionObject);
                if(newQuickAction != null){
                    
                    for(String targetLayout:selectOptionLayout){
                        readAndUpdateLayout( targetLayout, newQuickAction, this.selectOptionObject );
                    }
                }
                if(hasError==false){
                    successManager('The quickactions were created');
                }
            }
            else{
                errorManager('Select at least one layout');
            }
        }
    }
    
    
}