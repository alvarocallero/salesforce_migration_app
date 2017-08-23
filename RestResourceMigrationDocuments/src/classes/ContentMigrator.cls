@RestResource(urlMapping='/ContentMigrator/*')
global with sharing class ContentMigrator {

  @HttpPost
    global static String doPost(String idsMap) {
        system.debug(idsMap);
        return 'SUCCESS';
    }
}