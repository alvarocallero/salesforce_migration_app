({
    setRedirectUrl : function(component, event) {
        //You can use component.get("v.loadedRecord"); if you set needsData to true
        //Do not forget to set the redirectURL using component.set("v.redirectURL", url);

        var url = '';
        if (component.get('v.loadedRecord').Probability > 50){
            url = 'https://www.google.com.uy/search?q=win' + component.get('v.loadedRecord').Id;
        }else{
            url = 'https://www.google.com.uy/search?q=probability' + component.get('v.loadedRecord').Probability;
        }
		component.set("v.redirectURL", url);
        
    }
})