
@isTest
private class ConditionSetTriggerTest {

    @testSetup
    static void seedData() {

    }

    @isTest
    static void testLogicConversion() {
        Action__c testAction = new Action__c();
        insert testAction;
        Condition_Set__c testConditionSet = new Condition_Set__c(
            Action__c = testAction.Id,   
            Logical_Statement__c = '1 AND (2 OR 3)'
        );
        insert testConditionSet;
        testConditionSet = [SELECT RPN_Logic__c FROM Condition_Set__c WHERE Id = :testConditionSet.Id];
        System.assert(testConditionSet.RPN_Logic__c != null,
            'Logic not converted.');
    }


}