@isTest
private class ContentMigratorTest {
    static testMethod void testContentMigrator() {

        System.assertEquals('SUCCESS', ContentMigrator.doPost('test'));
    }
}