trigger ConditionLineItemTrigger on Condition_Line_Item__c (before insert, before update, after insert, after update) {
	
	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

	void setFieldType(Condition_Line_Item__c cli, String objectType) {
        String fieldType = String.valueOf(schemaMap.get(objectType).getDescribe().fields.getMap().get(cli.Field__c.toLowercase()).getDescribe().getType());
        cli.Field_Type__c = fieldType;
    }


	if (Trigger.isBefore) {
		Set<Id> conditionSetIds = new Set<Id>();
		for (Condition_Line_Item__c cli : Trigger.new) {
			conditionSetIds.add(cli.Condition_Set__c);
		}
		Map<Id,Condition_Set__c> conditionSetMap = new Map<Id,Condition_Set__c>([SELECT Id, Object_Type__c, Action__r.Action_Type__c FROM Condition_Set__c WHERE Id IN :conditionSetIds]);
		for (Condition_Line_Item__c cli : Trigger.new) {
			setFieldType(cli, conditionSetMap.get(cli.Condition_Set__c).Object_Type__c);
		}
	} else if (Trigger.isAfter) {
		//memoize this, DRY stuff
		List<Condition_Line_Item__c> conditionLineItems = [SELECT Id, Field__c, Condition_Set__r.Object_Type__c, Condition_Set__r.Action__r.Action_Type__c FROM Condition_Line_Item__c WHERE Condition_Set__r.Active__c = true];
		Map<String,Condition_Field__c> currentConditionFields = Condition_Field__c.getAll(); 
    	Map<String,Condition_Field__c> conditionFieldsToInsert = new Map<String,Condition_Field__c>();
    	Set<String> touchedNames = new Set<String>();
    	for (Condition_Line_Item__c cli : conditionLineItems) {
    		String name = cli.Condition_Set__r.Object_Type__c + '.' + cli.Field__c + '.' + cli.Condition_Set__r.Action__r.Action_Type__c;
    		name = name.toLowercase();
    		if (!touchedNames.add(name)) continue;
    		if (!currentConditionFields.containsKey(name)) conditionFieldsToInsert.put(name, new Condition_Field__c(
    			Name = name,
    			Action_Type__c = cli.Condition_Set__r.Action__r.Action_Type__c,
    			Field__c = cli.Field__c,
    			Object_Type__c = cli.Condition_Set__r.Object_Type__c
    			));
    	}
    	List<Condition_Field__c> toDelete = new List<Condition_Field__c>();
    	for (String currentField : currentConditionFields.keySet()) {
    		if (!touchedNames.contains(currentField)) toDelete.add(currentConditionFields.get(currentField));
    	}
    	if (!toDelete.isEmpty()) delete toDelete;
    	if (!conditionFieldsToInsert.isEmpty()) insert conditionFieldsToInsert.values();
	}

}