
@isTest
private class ConditionUtilityTest {

    @testSetup
    static void seedData() {
        Action__c newAction = new Action__c();
        insert newAction;
        Condition_Set__c cs = new Condition_Set__c(
            Action__c = newAction.Id,
            Logical_Statement__c = '1 OR (2 AND 3) OR 4 OR 5 OR 6 OR 7 OR 8 OR 9',
            Object_Type__c = 'Lead'
        );
        insert cs;
        Condition_Line_Item__c cli1 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = 'isNull',
            Operand__c = 'true',
            Rule_Number__c = 1
        );
        Condition_Line_Item__c cli2 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = 'isNotNull',
            Operand__c = 'true',
            Rule_Number__c = 2
        );
        Condition_Line_Item__c cli3 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = '=',
            Operand__c = 'XYZ',
            Rule_Number__c = 3
        );
        Condition_Line_Item__c cli4 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = 'contains',
            Operand__c = 'a',
            Rule_Number__c = 4
        );
        Condition_Line_Item__c cli5 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = 'IN',
            Operand__c = 'a,b,c',
            Rule_Number__c = 5
        );
        Condition_Line_Item__c cli6 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = 'doesNotContain',
            Operand__c = 'x',
            Rule_Number__c = 6
        );
        Condition_Line_Item__c cli7 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'Name',
            Operator__c = 'startsWith',
            Operand__c = 'x',
            Rule_Number__c = 7
        );
        Condition_Line_Item__c cli8 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'NumberOfEmployees',
            Operator__c = '<=',
            Operand__c = '50',
            Rule_Number__c = 8
        );
        Condition_Line_Item__c cli9 = new Condition_Line_Item__c(
            Condition_Set__c = cs.Id,
            Field__c = 'IsConverted',
            Operator__c = '!=',
            Operand__c = 'true',
            Rule_Number__c = 9
        );
        insert cli1;
        insert cli2;
        insert cli3;
        insert cli4;
        insert cli5;
        insert cli6;
        insert cli7;
        insert cli8;
        insert cli9;
    }

    @isTest
    static void testObjectMeetsConditionSet() {
        Lead newLead = new Lead(LastName = 'Testly', Company = 'Test Co.', Email = 'xyz@test.com');
        insert newLead;
        List<Condition_Set__c> css = [SELECT
            Id, Logical_Statement__c, RPN_Logic__c, Object_Type__c, Description__c,
            (SELECT Field__c, Field_Type__c, Operand__c, Operator__c, Rule_Number__c FROM Condition_Set_Line_Items__r),
            Action__c, Action__r.Positive__c, Action__r.Score_Type__c,
            Action__r.Value__c, Action__r.Action_Frequency__c
            FROM Condition_Set__c];
        Boolean outcome = ConditionUtility.objectMeetsConditionSet(newLead, css[0]);
        System.assert(outcome != null,
            'Condition not evaluated successfully');
    }

}