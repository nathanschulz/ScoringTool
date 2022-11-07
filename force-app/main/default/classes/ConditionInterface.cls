global virtual class ConditionInterface {
    global virtual void preScoringCallback(List<SObject> newObjects, Map<Id,SObject> oldMap, Boolean isInsert, String objectType) {

    }

    global virtual void postScoringCallback(List<SObject> newObjects, Map<Id,SObject> oldMap, Boolean isInsert, String objectType) {
        
    }
}
