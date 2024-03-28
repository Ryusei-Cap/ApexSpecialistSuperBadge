@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @isTest
    public static void Test(){
        Product2 product = new Product2(Name = 'Cooling Fan', Warehouse_SKU__c = '100004');
        insert(product);
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        WarehouseCalloutService w = new WarehouseCalloutService();
        Id d = System.enqueueJob(w);
        Test.stopTest();
        Product2 result = [SELECT Id, Name, Warehouse_SKU__c FROM Product2 WHERE Name = 'Cooling Fan' LIMIT 1];
        System.assertEquals(result.Warehouse_SKU__c, '100004');
    }
}