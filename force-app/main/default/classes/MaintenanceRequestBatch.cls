public class MaintenanceRequestBatch implements Database.Batchable<sObject>{
    public List<Case> targetCases;
    public MaintenanceRequestBatch(List<Case> input){
        targetCases = input;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<Id> key = new Set<Id>();
        for(Case caseObj : targetCases){
            key.add(caseObj.Id);
        }
        String query = 'SELECT Id,ContactId,AccountId,AssetId,ParentId,ProductId,SuppliedName, ';
        query += 'SuppliedEmail,SuppliedPhone,SuppliedCompany,Type,Status,Reason,Origin,Subject,';
        query += 'Priority,Description,IsClosed,ClosedDate,IsEscalated,ContactPhone,ContactMobile, Equipment__c, ';
        query += 'ContactEmail,ContactFax,Comments,LastViewedDate,LastReferencedDate,EngineeringReqNumber__c, ';
        query += 'SLAViolation__c,Product__c,PotentialLiability__c,Date_Due__c,Date_Reported__c,Vehicle__c, ';
        query += '(SELECT Id, Name, Equipment__c, Maintenance_Request__c,Quantity__c, Cycle__c  FROM Equipment_Maintenance_Items__r) ';
        query += 'FROM Case WHERE Id IN :key';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Case> scope){
        // START : Create New Routine Maintenance based on Origin
        system.debug(scope);
        List<Case> insertCases = new List<Case>();
        Map<Id, Case> oldNewCaseMap = new Map<Id, Case>();
        Map<Id, List<Equipment_Maintenance_Item__c>> idEqlistMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for(Case cas : scope){
            // START : Calculate minimum Cycle in Equipment
            Decimal minCycle = 0;
            for(Equipment_Maintenance_Item__c eq : cas.Equipment_Maintenance_Items__r){
                if(minCycle == 0){
                    if(eq.Cycle__c != null){
                        minCycle = eq.Cycle__c;
                    }
                }else if(eq.Cycle__c < minCycle){
                    minCycle = eq.Cycle__c;
                }
            }
            // END : Calculate minimum Cycle in Equipment
            Case newCas = new Case();
            newCas.Status = 'New';
            newCas.Type ='Routine Maintenance';
            newCas.Subject = 'New Routine Maintenance';
            newCas.Origin = 'Web';
            newCas.Date_Reported__c = Date.today();
            newCas.Date_Due__c = Date.today().addDays(Integer.valueof(minCycle));
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
            oldNewCaseMap.put(cas.Id, newCas);
            idEqlistMap.put(cas.Id, cas.Equipment_Maintenance_Items__r);
        }
        insert insertCases;
        // END : Create New Routine Maintenance based on Origin
        
        // START : Tie Equipment to Routine Maintenance
        List<Equipment_Maintenance_Item__c> insertEqs = new List<Equipment_Maintenance_Item__c>();
        for(Case cas : scope){
			Id newCasId = oldNewCaseMap.get(cas.Id).Id;
            List<Equipment_Maintenance_Item__c> eqList = idEqlistMap.get(cas.Id);
            for(Equipment_Maintenance_Item__c eq : eqList){
                Equipment_Maintenance_Item__c newEq = new Equipment_Maintenance_Item__c();
                newEq.Maintenance_Request__c = newCasId;
                insertEqs.add(newEq);
            }
        }
        insert insertEqs;
        // END : Tie Equipment to Routine Maintenance
    }
    public void finish(Database.BatchableContext bc){
        system.debug('Routine Maintenance are created');
    }
}