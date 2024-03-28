public with sharing class MaintenanceRequestHelper {
    public static Boolean flg = false;
    public static void updateWorkOrders(List<Case> newCases) {
        // TODO: Complete the method to update workorders
        // Start: Retrive Equimpent Maintenance Item related to concerned Case
        List<Id> newCaseIds = new List<Id>();
        for(Case cas : newCases){
            newCaseIds.add(cas.Id);
        }
        Map<Id, List<Equipment_Maintenance_Item__c>> caseIdToEquipItems = retrivecaseIdToEquipItems(newCaseIds);
        // End: Retrive Equimpent Maintenance Item related to concerned Case

        // Start: Calculate Mincycle for each Case
        Map<Id, Integer> caseIdToMincycle = retrivecaseIdToMincycle(caseIdToEquipItems);
        // End: Calculate Mincycle for each Case

        // Start: Create Case related to concerned Case
        List<Case> insertCases = new List<Case>();
        Map<Id, Case> oldToNewCase =  new Map<Id, Case>();
        for(Case cas : newCases){
            Case newCas = new Case();
            newCas.Status = 'New';
            newCas.Type ='Routine Maintenance';
            newCas.Subject = 'New Routine Maintenance';
            newCas.Origin = cas.Origin;
            newCas.AccountId = cas.AccountId;
            newCas.ContactId  = cas.ContactId;
			newCas.AssetId    = cas.AssetId;
            newCas.Date_Reported__c = Date.today();
            newCas.Date_Due__c = Date.today().addDays(caseIdToMincycle.get(cas.Id));
            if(cas.ProductId != null){
                newCas.ProductId = cas.ProductId;
            }
            if(cas.Vehicle__c != null){
                newCas.Vehicle__c = cas.Vehicle__c;
            }
            if(cas.Equipment__c != null) {
                newCas.Equipment__c = cas.Equipment__c;
            }
            insertCases.add(newCas);
            oldToNewCase.put(cas.Id, newCas);
        }
        insert insertCases;
        // Enb: Create Case related to concerned Case

        // Start: Create Equipment Maintenanc Item to tie Case
        List<Equipment_Maintenance_Item__c> insertEqs = new List<Equipment_Maintenance_Item__c>();
        for(Case cas : newCases){
            for(Equipment_Maintenance_Item__c eq : caseIdToEquipItems.get(cas.Id)){
                Equipment_Maintenance_Item__c newEq = new Equipment_Maintenance_Item__c();
                newEq.Maintenance_Request__c = oldToNewCase.get(cas.Id).Id;
                newEq.Equipment__c = eq.Equipment__c;
                newEq.Quantity__c = eq.Quantity__c;
                insertEqs.add(newEq);
            }
        }
        insert insertEqs;
        // End: Create Equipment Maintenanc Item to tie Case
    }
    public static Map<Id, List<Equipment_Maintenance_Item__c>> retrivecaseIdToEquipItems(List<Id> newCaseIds){
        Map<Id, List<Equipment_Maintenance_Item__c>> caseIdToEquipItems = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        List<Equipment_Maintenance_Item__c> equipItems = [SELECT Id, Equipment__c, Maintenance_Request__c, Quantity__c, Equipment__r.Maintenance_Cycle__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :newCaseIds];
        for(Equipment_Maintenance_Item__c equipItem : equipItems){
            if(caseIdToEquipItems.get(equipItem.Maintenance_Request__c) == null){
                List<Equipment_Maintenance_Item__c> equipItemsByCase = new List<Equipment_Maintenance_Item__c>{equipItem};
                caseIdToEquipItems.put(equipItem.Maintenance_Request__c, equipItemsByCase);
            }else{
                caseIdToEquipItems.get(equipItem.Maintenance_Request__c).add(equipItem);
            }
        }
        return caseIdToEquipItems;
    }
    public static Map<Id,Integer> retrivecaseIdToMincycle(Map<Id, List<Equipment_Maintenance_Item__c>> caseIdToEquipItems){
        Map<Id,Integer> caseIdToMincycle = new Map<Id,Integer>();
        for(Id caseId : caseIdToEquipItems.keyset()){
            Integer minCycle = null;

            for(Equipment_Maintenance_Item__c equipItem : caseIdToEquipItems.get(caseId)){
                if(equipItem.Equipment__r.Maintenance_Cycle__c == null){
                    
                }
                else if(minCycle == null || minCycle > equipItem.Equipment__r.Maintenance_Cycle__c){
                    minCycle = Integer.valueOf(equipItem.Equipment__r.Maintenance_Cycle__c);
                }
            }
            caseIdToMincycle.put(caseId, minCycle);
        }
        return caseIdToMincycle;
    }
}