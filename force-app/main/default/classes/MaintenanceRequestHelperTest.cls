@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @isTest
    public static void Test(){
        Product2 prodObj = new Product2(Name = 'Test', 	Maintenance_Cycle__c = 10, IsActive = true, Replacement_Part__c = true);
        insert prodObj;
        Vehicle__c vehObj = new Vehicle__c(Name = 'Test');
        insert vehObj;
        List<Case> cases = new List<Case>();
        for(Integer i=0;i<1000;i++){
            Case caseObj = new Case(
                Status = 'New',
                Type = 'Repair',
                Subject = 'Test'+ i,
                Vehicle__c = vehObj.Id,
                Equipment__c = prodObj.Id,
                ProductId = prodObj.Id,
                Date_Due__c = Date.today(),
                Date_Reported__c = Date.today(),
                Origin = 'Web');
            cases.add(caseObj);
        }        
        insert cases;
        List<Equipment_Maintenance_Item__c> eqMaintItems = new List<Equipment_Maintenance_Item__c>();
        for(Case caseObj : cases){
            Equipment_Maintenance_Item__c eqMaintItemObj = new Equipment_Maintenance_Item__c(
        	Maintenance_Request__c = caseObj.Id,
            Equipment__c = prodObj.Id,
            Quantity__c = 10
            );
            Equipment_Maintenance_Item__c eqMaintItemObj2 = new Equipment_Maintenance_Item__c(
        	Maintenance_Request__c = caseObj.Id,
            Equipment__c = prodObj.Id,
            Quantity__c = 10
            );
            eqMaintItems.add(eqMaintItemObj);
            eqMaintItems.add(eqMaintItemObj2);
        }
        insert eqMaintItems;
        List<Case> closedcases = new List<Case>();
        for(Case caseObj : cases){
            caseObj.Status = 'Closed';
            closedcases.add(caseObj);
        }
        update closedcases;
        System.assertEquals(closedcases.size(), 1000);
    }
    
}