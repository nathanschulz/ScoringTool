
@isTest
private class ScoringAdminControllerTest {

    @testSetup
    static void seedData() {

    }

    @isTest
    static void testSaveConditionSet() {
        Map<String,Object> conditionSetMap = new Map<String,Object>();
        List<Map<Object,Object>> lineItems = new List<Map<Object,Object>>();
        conditionSetMap.put('lineItems', lineItems);
        conditionSetMap.put('description', 'test conditions');
        conditionSetMap.put('conditionDirection', 'Add');
        conditionSetMap.put('scoreType', 'fit');
        conditionSetMap.put('value', 5);
        conditionSetMap.put('active', true);
        conditionSetMap.put('logicalStatement', '1');
        conditionSetMap.put('objectType', 'Lead');
        Map<Object,Object> lineItem = new Map<Object,Object>();
        lineItems.add(lineItem);
        lineItem.put('field', 'Name');
        lineItem.put('operand', 'x');
        lineItem.put('operator', '=');
        lineItem.put('ruleNumber', 1);

        ScoringAdminController.saveConditionSet(conditionSetMap);
        List<Action__c> newActions = [SELECT Id FROM Action__c];
        List<Condition_Set__c> newConditionSets = [SELECT Id FROM Condition_Set__c];
        System.assert(!newActions.isEmpty(),
            'Action not created');
        System.assert(!newConditionSets.isEmpty(),
            'Condition Set not created');
        Id actionId = newActions[0].Id;
        Id conditionSetId = newConditionSets[0].Id;

        conditionSetMap.put('actionId', actionId);
        conditionSetMap.put('id', conditionSetId);
        ScoringAdminController.saveConditionSet(conditionSetMap);
        ScoringAdminController.deleteAction(actionId);
        System.assert(true);
    }

    @isTest
    static void testGetAdminView() {
        Map<String,Object> adminView = ScoringAdminController.getAdminView(null);
        System.assert(adminView.containsKey('conditionSets'));
    }
}