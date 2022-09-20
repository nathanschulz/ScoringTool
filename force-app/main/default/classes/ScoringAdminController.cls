public with sharing class ScoringAdminController {
    
    @AuraEnabled
    public static void deleteAction(Id actionId) {
        delete new Action__c(Id = actionId);
    }


    @AuraEnabled
    public static List<SObject> saveConditionSet(Map<String,Object> conditionSetMap) {
        System.debug(conditionSetMap);

        Action__c conditionSetAction = new Action__c();
        Condition_Set__c conditionSet = new Condition_Set__c();

        Id actionId = (Id) conditionSetMap.get('actionId');
        Id conditionSetId = (Id) conditionSetMap.get('id');

        //Existing Action/Condition Set
        if (actionId != null && conditionSetId != null) {
            conditionSetAction.Id = actionId;
            conditionSet.Id = conditionSetId;

            conditionSetAction.Action_Type__c = ScoringUtility.SCORING_ACTION;
            conditionSetAction.Description__c = (String) conditionSetMap.get('description');
            conditionSetAction.Positive__c = (Boolean) (conditionSetMap.get('conditionDirection') == 'Add');
            conditionSetAction.Score_Type__c = (String) conditionSetMap.get('scoreType');
            conditionSetAction.Value__c = Decimal.valueOf(String.valueOf(conditionSetMap.get('value')));
                        
            conditionSet.Description__c = (String) conditionSetMap.get('description');
            conditionSet.Active__c = (Boolean) conditionSetMap.get('active');
            conditionSet.Logical_Statement__c = (String) conditionSetMap.get('logicalStatement');
            conditionSet.Object_Type__c = (String) conditionSetMap.get('objectType');

            update conditionSetAction;
            update conditionSet;

        //New Action/Condition Set
        } else {
            conditionSetAction.Action_Type__c = ScoringUtility.SCORING_ACTION;
            conditionSetAction.Description__c = (String) conditionSetMap.get('description');
            conditionSetAction.Positive__c = (String) conditionSetMap.get('conditionDirection') == 'Add';
            conditionSetAction.Score_Type__c = (String) conditionSetMap.get('scoreType');
            conditionSetAction.Value__c = (Decimal) conditionSetMap.get('value');
            insert conditionSetAction;
            

            conditionSet.Action__c = conditionSetAction.Id;
            conditionSet.Description__c = (String) conditionSetMap.get('description');
            conditionSet.Active__c = (Boolean) conditionSetMap.get('active');
            conditionSet.Logical_Statement__c = (String) conditionSetMap.get('logicalStatement');
            conditionSet.Object_Type__c = (String) conditionSetMap.get('objectType');

            insert conditionSet;
        }

        List<Condition_Line_Item__c> lineItemsToUpdate = new List<Condition_Line_Item__c>();
        List<Condition_Line_Item__c> lineItemsToInsert = new List<Condition_Line_Item__c>();
        List<Object> lineItems = (List<Object>) conditionSetMap.get('lineItems');

        System.debug(lineItems);
        for (Object uncastLineItem : lineItems) {
            Map<Object,Object> lineItem = (Map<Object,Object>) uncastLineItem;
            Condition_Line_Item__c cli = new Condition_Line_Item__c(Condition_Set__c = conditionSet.Id);
            Id lineItemId = (Id) lineItem.get('id');
            cli.Field__c = (String) lineItem.get('field');
            cli.Operand__c = (String) lineItem.get('operand');
            cli.Operator__c = (String) lineItem.get('operator');
            cli.Rule_Number__c = (Decimal) lineItem.get('ruleNumber');


            if (lineItemId != null) {
                cli.Id = lineItemId;
                lineItemsToUpdate.add(cli);
            } else {
                lineItemsToInsert.add(cli);
            }

            // System.debug(lineItem.get('field'));
            // System.debug(lineItem.get('ruleNumber'));
            // System.debug(lineItem.get('operator'));
            // System.debug(lineItem.get('operand'));
            // System.debug('id: ' + lineItem.get('id'));
        }

        if (!lineItemsToUpdate.isEmpty()) update lineItemsToUpdate;
        if (!lineItemsToInsert.isEmpty()) insert lineItemsToInsert;

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAdminView(Long dTime) {
        Map<String,Object> adminView = new Map<String,Object>();
        adminView.put('conditionSets',getConditionSets());
        return adminView;
    }

    public static List<SObject> getConditionSets() {
        return [SELECT
            Id, Description__c, Logical_Statement__c, Object_Type__c, Action__c, Active__c,
            Action__r.Action_Type__c, Action__r.Description__c, Action__r.Positive__c, Action__r.Score_Type__c, Action__r.Value__c,
            (SELECT Id, Field__c, Field_Type__c, Operand__c, Operator__c, Rule_Number__c FROM Condition_Set_Line_Items__r ORDER BY Rule_Number__c ASC)
            FROM Condition_Set__c
            WHERE Action__r.Action_Type__c = :ScoringUtility.SCORING_ACTION
        ];
    }
}
