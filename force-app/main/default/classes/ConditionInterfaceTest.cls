
@isTest
private class ConditionInterfaceTest {

    @isTest
    static void testConditionInterface() {
        ConditionInterface ci = new ConditionInterface();
        ci.preScoringCallback(null,null,null,null);
        ci.postScoringCallback(null,null,null,null);
        System.assert(ci != null,
            'Condition Interface not instantiated.');
    }
}