trigger MaintenanceRequest on Case (after insert, after update) {
    // ToDo: Call MaintenanceRequestHelper.updateWorkOrders
    if(Trigger.isInsert || Trigger.isUpdate){
        List<Case> filteredCases = new List<Case>();
        for(Case cas : Trigger.new){
            if(cas.Status == 'Closed' && (cas.Type == 'Repair' || cas.Type == 'Routine Maintenance')){
                filteredCases.add(cas);
            }
        }
        if(filteredCases.size()>0){
            MaintenanceRequestHelper.updateWorkOrders(filteredCases);
        }
    }
}