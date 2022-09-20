public with sharing class ScoringTriggerHelper {
    
    public static Map<String,List<String>> objectTypeToField;

    public static List<String> getFieldsForObject(String objectType) {
        List<String> fields = new List<String>();
        for (Condition_Field__c cf : [SELECT Field__c FROM Condition_Field__c WHERE Object_Type__c = :objectType]) {
            fields.add(cf.Field__c);
        }
        return fields;
    }

    public String objectType {get; private set;}

    public ScoringTriggerHelper(String oType) {
        objectType = oType;
    }

    public void process() {
        //Nathan TODO:  this is not general
        Action_Configuration__mdt setting = Action_Configuration__mdt.getInstance(objectType);
        if (setting != null && setting.Master_Disable__c == true) return;

        List<Lead> toEvaluate = recordsToReEvaluate(Trigger.new, Trigger.oldMap, Trigger.isInsert);
        System.debug('evalute length: ' + toEvaluate.size());
        if (!toEvaluate.isEmpty()) {
            System.debug('some evaluated');
            ScoringUtility su = new ScoringUtility();
            List<Action_Log__c> logsToInsert = su.scoreLeads(toEvaluate);
            if (logsToInsert != null && !logsToInsert.isEmpty()) Database.insert(logsToInsert, false);
        }
    }

    public List<String> getScoringFields() {
        if (ScoringTriggerHelper.objectTypeToField == null) ScoringTriggerHelper.objectTypeToField = new Map<String,List<String>>();
        if (!ScoringTriggerHelper.objectTypeToField.containsKey(objectType)) ScoringTriggerHelper.objectTypeToField.put(objectType, ScoringTriggerHelper.getFieldsForObject(objectType));
        return ScoringTriggerHelper.objectTypeToField.get(objectType);
    }

    public List<SObject> recordsToReEvaluate(List<SObject> newObjects, Map<Id,SObject> oldMap, Boolean isInsert) {
        if (isInsert == true) return newObjects;
        List<SObject> toScore = new List<SObject>();
        for (SObject newSObj : newObjects) {
            SObject oldSObj = oldMap.get(newSObj.Id);
            if (scoringFieldChanged(newSObj, oldSObj)) toScore.add(newSobj);
        }
        return toScore;
    }

    public Boolean scoringFieldChanged(SObject newSObject, SObject oldSObject) {
        for (String field : getScoringFields()) {
            if (newSObject.get(field) != oldSObject.get(field)) {
                return true;
            }
        }
        return false;
    }
}
