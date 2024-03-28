@isTest
public with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    public static void test(){
        WarehouseSyncSchedule w = new WarehouseSyncSchedule();
        String sch = '0 0 1 * * ? *';
        String jobId = System.schedule('WarehouseSyncScheduleJob', sch, w);
        System.assertNotEquals(jobId, null);
    }
}