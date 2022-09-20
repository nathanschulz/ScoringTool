List<Action__c> actions = new List<Action__c>();
Action__c action1 = new Action__c(
Action_Type__c = ScoringUtility.SCORING_ACTION,
Positive__c = true,
Score_Type__c = ScoringUtility.FIT_SCORE_TYPE,
Value__c = 10);
Action__c action2 = new Action__c(
Action_Type__c = ScoringUtility.SCORING_ACTION,
Positive__c = false,
Score_Type__c = ScoringUtility.ACTIVITY_SCORE_TYPE,
Value__c = 5);
actions.add(action1);
actions.add(action2);
insert actions;

List<Condition_Set__c> conditionSets = new List<Condition_Set__c>();
Condition_Set__c conditionSet1 = new Condition_Set__c(
Action__c = action1.Id,
Logical_Statement__c = '1',
RPN_Logic__c = '1',
Object_Type__c = 'Lead',
Skip_Validation__c = true);
Condition_Set__c conditionSet2 = new Condition_Set__c(
Action__c = action2.Id,
Logical_Statement__c = '1',
RPN_Logic__c = '1',
Object_Type__c = 'CampaignMember',
Skip_Validation__c = true);

conditionSets.add(conditionSet1);
conditionSets.add(conditionSet2);
insert conditionSets;

List<Condition_Line_Item__c> conditionLineItems = new List<Condition_Line_Item__c>();
Condition_Line_Item__c conditionLI1 = new Condition_Line_Item__c(
Condition_Set__c = conditionSet1.Id,
Field__c = 'Industry',
Field_Type__c = 'STRING',
Operand__c = 'Transportation',
Operator__c = '=',
Rule_Number__c = 1,
Skip_Validation__c = true);
Condition_Line_Item__c conditionLI2 = new Condition_Line_Item__c(
Condition_Set__c = conditionSet2.Id,
Field__c = 'Status',
Field_Type__c = 'STRING',
Operand__c = 'Sent',
Operator__c = '=',
Rule_Number__c = 1,
Skip_Validation__c = true);

conditionLineItems.add(conditionLI1);
conditionLineItems.add(conditionLI2);
insert conditionLineItems;

Campaign testCampaign = new Campaign(
Name = 'Test Campaign');
insert testCampaign;