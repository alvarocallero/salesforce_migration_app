public class Language {
    
    public static String LANGUAGE_API = 'https://api.einstein.ai/v2/language';
    public static String SENTIMENT = LANGUAGE_API + '/sentiment';
    public static String INTENT = LANGUAGE_API + '/intent';    
   	public class LanguageException extends Exception {}
    
    public static String apiCall(String endpoint, String access_token, Map<String, String> params, String method) {
        string contentType = HttpFormBuilder.GetContentType();//'multipart/form-data';
        String result = '{}';
        Integer paramSize = params.size();
        Integer cont = 0;
        
        HttpRequest httpRequest = new HttpRequest();
        if(!params.isEmpty()){
            //  Compose the form
            string form64 = '';
            String body = '';
            String value = '';
            for (String parameter : params.keySet()) {
                cont +=1;
                value = params.get(parameter);
                body += parameter + '=' + value;
                if(cont!=paramSize){
                    body += '&';
                }
                form64 += HttpFormBuilder.WriteBoundary();
                form64 += HttpFormBuilder.WriteBodyParameter(parameter,value);
            }
            form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
            System.debug(form64);
            blob formBlob = EncodingUtil.base64Decode(form64);
            System.debug(formBlob);
            string contentLength = string.valueOf(formBlob.size());
            
            //  Compose the http request
            
            httpRequest.setBodyAsBlob(formBlob);
            
            httpRequest.setHeader('Content-Length', contentLength);
            httpRequest.setHeader('Content-Type', contentType);            
        }
        //httpRequest.setBody(body);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Cache-Control', 'no-cache');
        httpRequest.setMethod(method);
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + access_token);
        httpRequest.setEndpoint(LANGUAGE_API+endpoint);
        
        Http http = new Http();
        try {
            System.Debug(httpRequest);
            System.Debug(httpRequest.toString());
            System.Debug(httpRequest.getHeader('Content-Type'));
            System.Debug(httpRequest.getHeader('Authorization'));
            System.Debug(httpRequest.getBody());
            HTTPResponse res = http.send(httpRequest);
            System.Debug('statuscode: '+res.getStatusCode());            
            result = res.getBody();
            if (res.getStatusCode() != 200) {
                Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
                String message = '.';
                if (jsonResult.containsKey('message')){
                    message =  message + ' ' + jsonResult.get('message') + '.';
                }
                throw new LanguageException('404 Bad Request' + message);
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
            throw new LanguageException(e);            
        }        
        return result;
    }
    
    
    public static String apiCallUploadFile(String endpoint, String access_token, Map<String, String> params, String method, String fileKey, Blob file) {
        string contentType = HttpFormBuilder.GetContentType();//'multipart/form-data';
        String result = 'Error';
        Integer paramSize = params.size();
        Integer cont = 0;
        string form64 = '';
        String body = '';
        String value = '';
        String mimeType = 'application/octet-stream';
        String name = 'data';      
        HttpRequest httpRequest = new HttpRequest();
        if(!params.isEmpty()){
            if (params.containsKey('name')){
                name = params.get('name');
            }
            //  Compose the form
            for (String parameter : params.keySet()) {
                cont +=1;
                value = params.get(parameter);
                body += parameter + '=' + value;
                if(cont!=paramSize){
                    body += '&';
                }
                form64 += HttpFormBuilder.WriteBoundary();
                form64 += HttpFormBuilder.WriteBodyParameter(parameter,value);
            }
        }
        
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBlobBodyParameter(fileKey, EncodingUtil.base64Encode(file), name, mimeType);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());        
        //  Compose the http request        
        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);  
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Cache-Control', 'no-cache');
        httpRequest.setMethod(method);
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + access_token);
        httpRequest.setEndpoint(LANGUAGE_API+endpoint);        
        Http http = new Http();
        try {
            System.Debug(httpRequest);
            System.Debug(httpRequest.toString());
            System.Debug(httpRequest.getHeader('Content-Type'));
            System.Debug(httpRequest.getHeader('Authorization'));
            System.Debug(httpRequest.getBody());
            HTTPResponse res = http.send(httpRequest);
            System.Debug('statuscode: '+res.getStatusCode());            
            result = res.getBody();
            if (res.getStatusCode() != 200) {
                Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
                String message = '.';
                if (jsonResult.containsKey('message')){
                    message =  message + ' ' + jsonResult.get('message') + '.';
                }
                throw new LanguageException('404 Bad Request' + message);
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
            throw new LanguageException(e); 
        }        
        return result;
    }
}