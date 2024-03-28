public with sharing class WarehouseSyncSchedule implements Schedulable{
    // implement scheduled code here
    public void execute(SchedulableContext ctx){
        WarehouseCalloutService w = new WarehouseCalloutService();
        Id d = System.enqueueJob(w);
    }
}