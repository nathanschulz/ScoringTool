// RULE 3 //

Action__c a3 = new Action__c(
	Action_Type__c = 'Scoring',
	Description__c = 'High-Value Form Submitted',
	Positive__c = true,
	Score_Type__c = 'engagement',
	Value__c = 100
	);
insert a3;

Condition_Set__c a3cs1 = new Condition_Set__c(
	Active__c = false,
	Action__c = a3.Id,
	Description__c = 'Website Form Submitted',
	Logical_Statement__c = '1 AND 2',
	RPN_Logic__c = '1,2,AND',
	Object_Type__c = 'CampaignMember'
	);
insert a3cs1;

Condition_Line_Item__c a3cli1 = new Condition_Line_Item__c(
	Condition_Set__c = a3cs1.Id,
	Field__c = 'Type',
	Field_Type__c = 'STRING',
	Operand__c = 'Website - Form',
	Operator__c = '=',
	Rule_Number__c = 1
	);
insert a3cli1;

Condition_Line_Item__c a3cli2 = new Condition_Line_Item__c(
	Condition_Set__c = a3cs1.Id,
	Field__c = 'Status',
	Field_Type__c = 'STRING',
	Operand__c = 'High Value Form Submitted',
	Operator__c = '=',
	Rule_Number__c = 2
	);
insert a3cli2;
