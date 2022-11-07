//25 engagement points
Type = Free Trial
Status = Medium

DONE 
DONE




//50 engagement points
Free Trial + High
Webinar - Paid + No Show, Watched On-Demand
CPL + Downloaded Asset

//75 engagement points


//100 engagement points
Live Chat + Meeting Booked


Action__c a3 = new Action__c(
	Action_Type__c = 'Scoring',
	Description__c = 'Meeting Booked via Chat',
	Positive__c = true,
	Score_Type__c = 'engagement',
	Value__c = 100
	);
insert a3;

Condition_Set__c a3cs1 = new Condition_Set__c(
	Action__c = a3.Id,
	Active__c = false,
	Description__c = 'Meeting Booked via Chat',
	Logical_Statement__c = '1 AND 2',
	RPN_Logic__c = '1,2,AND',
	Object_Type__c = 'CampaignMember'
	);
insert a3cs1;

Condition_Line_Item__c a3cli1 = new Condition_Line_Item__c(
	Condition_Set__c = a3cs1.Id,
	Field__c = 'Type',
	Field_Type__c = 'STRING',
	Operand__c = 'Live Chat',
	Operator__c = '=',
	Rule_Number__c = 1
	);
insert a3cli1;

Condition_Line_Item__c a3cli2 = new Condition_Line_Item__c(
	Condition_Set__c = a3cs1.Id,
	Field__c = 'Status',
	Field_Type__c = 'STRING',
	Operand__c = 'Meeting Booked',
	Operator__c = '=',
	Rule_Number__c = 2
	);
insert a3cli2;