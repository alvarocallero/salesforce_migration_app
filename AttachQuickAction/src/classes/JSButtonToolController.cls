public class JSButtonToolController {
    
    public JSButtonToolController(){
    	fillObject();
        fillComponents();
    	if (String.isBlank(selectOptionObject)){
        	selectOptionObject = options[0].getValue();
        	fillLayouts();   
        }
        
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
    
    public void setSelectOptionLayout(String[] options) {
        this.selectOptionLayout = options;
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

    // get specific layout object -- ok
    private static MetadataService.FileProperties fileMetadataLayout(String objectName) {
        String regex = 'layouts[/]'+objectName+'[.]layout';
        String metadataType = 'Layout';
        List<MetadataService.FileProperties> result = listMetadataByType(regex, metadataType);
        return result[0];
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
            if(m.matches()) {
                result.add(fileProperty);
            }
        }
        return result;
    }
    
    // create quickaction -- ok
    private static String createQuickAction(string component, string name, string obj){
        try{
            MetadataService.MetadataPort service  = createService();
            MetadataService.QuickAction quickAction = new MetadataService.QuickAction();
            quickAction.fullName = obj+'.' + name.replace(' ', '_');
            quickAction.label = name;
            quickAction.lightningComponent = component;
            quickAction.type_x = 'LightningComponent';
            quickAction.height = 250;
            quickAction.width = 100; 
            quickAction.optionsCreateFeedItem = false;
            List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { quickAction });    
            if(results[0].success == true){
                return name;
            }   
            errorManager('Cannot create Quick Action');
        }
        catch(Exception e){
            errorManager(e.getMessage());
        }
        return null;
    }
    
    // update layout -- ok
    private static String readAndUpdateLayout( String layoutPrefix, MetadataService.FileProperties targetLayoutFile, String quickActionName, String objectPrefix, String obj ){
        try{
            MetadataService.MetadataPort service = createService();
           
            //create name according to the type of object
            if (!String.isBlank(layoutPrefix)){
                layoutPrefix = layoutPrefix + '__';
            }
             if (!String.isBlank(objectPrefix)){
                objectPrefix = objectPrefix + '__';
            }
            
            
            String objectLayout = targetLayoutFile.fullName;
            List<String> possibleNames = new List<String>{ objectPrefix+objectLayout.split('-')[0]+'-'+layoutPrefix+objectLayout.split('-')[1]};
            // Read the Layout
            List<MetadataService.Metadata> layouts = service.readMetadata('Layout', possibleNames).getRecords();
            
            MetadataService.Layout foundLayout = null;
            for (MetadataService.Metadata layout: layouts){
            	MetadataService.Layout sl = (MetadataService.Layout) layout;
			    if (!String.isBlank(sl.fullName)){
			    	foundLayout = sl;
			     }
            }

            if (foundLayout.platformActionList == null){
            	foundLayout.platformActionList = new MetadataService.PlatformActionList();
            	foundLayout.platformActionList.actionListContext = 'Record';
            }
            
            // create the quickAction to attach
            MetadataService.PlatformActionListItem newPlatformActionListItem = new MetadataService.PlatformActionListItem();
            newPlatformActionListItem.actionName = obj+'.'+quickActionName.replace(' ', '_');
            newPlatformActionListItem.actionType = 'QuickAction';
            
            newPlatformActionListItem.sortOrder = foundLayout.platformActionList.platformActionListItems.size();

            // Add the Custom Button to the Layout
            foundLayout.platformActionList.platformActionListItems.add(newPlatformActionListItem);
            
			for (Integer i=0; i<foundLayout.platformActionList.platformActionListItems.size(); i++){
					String str = objectPrefix +obj+'-'+layoutPrefix;
					foundLayout.platformActionList.platformActionListItems[i].actionName = foundLayout.platformActionList.platformActionListItems[i].actionName.replace(str, '');
			}
			
            // Update the Layout
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { foundLayout });
            	if(results[0].success == true){
					return 'The quickAction was added to '+objectLayout.replace('%28', '').replace('%29', '');
            	}else{
            		errorManager('The quickAction could not be added to '+objectLayout.replace('%28', '').replace('%29', ''));
            		return null;
            	}
            
            
        }
        catch(Exception e){
            errorManager(e.getMessage() );
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
            if(!String.isBlank(selectOptionObject)){
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
                if (listOfLayouts != null && listOfLayouts.size()>0){
                	hasLayout = true;
                }else{
                	hasLayout = false;
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
    public void hideToastAction(){
    	hasSuccess = false;
    	hasError = false;
    }
    public void attachToLayout(){
        
        if(String.isBlank(quickActionName)){
            errorManager('The name cannot be empty');
        }else{
            if(selectOptionLayout.size()>0){
            	String msg = '';
                String newQuickAction = createQuickAction(this.selectOptionComponent, quickActionName, this.selectOptionObject);
                if(newQuickAction != null){
                	MetadataService.FileProperties targetObject = listMetadataObject(this.selectOptionObject)[0]; 
                	String targetObjectPrefixName = targetObject.namespacePrefix;
                    for(String targetLayout:selectOptionLayout){
                        
                        MetadataService.FileProperties targetLayoutFile = fileMetadataLayout(targetLayout);
                        String targetLayoutPrefixName = targetLayoutFile.namespacePrefix;
                        msg = msg + readAndUpdateLayout(targetLayoutPrefixName, targetLayoutFile, quickActionName, targetObjectPrefixName, this.selectOptionObject )+ '<br/>';
                    }
                }
                if(hasError==false){
                    successManager(msg);
                }
            }
            else{
                errorManager('Select at least one layout');
            }
        }
    }
    
    
}