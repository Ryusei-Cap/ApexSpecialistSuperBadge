public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context) {
        HttpResponse response = makeCallout();
        processResponse(response);
    }
    private static HttpResponse makeCallout(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        return http.send(request);
    }
    private static void processResponse(HttpResponse response){
        Map<String, Object> skuEquimpentMap = new Map<String, Object>();
        if(response.getStatusCode() == 200) {
        	List<Object> equipments = (List<Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Map<String,Object>> skuToinventory = new Map<String, Map<String,Object>>();
            Set<String> skuSet = new Set<String>();
            List<Product2> productList = new List<Product2>();
            for(Object eq : equipments){
                Map<String,Object> obj = (Map<String, Object>)eq;
                Product2 pr = new Product2();
                pr.Replacement_Part__c = (Boolean)obj.get('replacement');
                pr.Name = (String)obj.get('name');
                pr.Maintenance_Cycle__c = (Integer)obj.get('maintenanceperiod');
                pr.Lifespan_Months__c = (Integer)obj.get('lifespan');
                pr.Cost__c = (Decimal) obj.get('lifespan');
                pr.Warehouse_SKU__c = (String)obj.get('sku');
                pr.Current_Inventory__c = (Double) obj.get('quantity');
                productList.add(pr);
            }
            upsert productList;
        }
    }
}