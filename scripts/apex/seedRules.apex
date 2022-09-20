//RULE 1//
Action__c a1 = new Action__c(
	Action_Type__c = 'Scoring',
	Description__c = 'Non-Industry Email Address',
	Positive__c = false,
	Score_Type__c = 'fit',
	Value__c = 20
	);
insert a1;

Condition_Set__c a1cs1 = new Condition_Set__c(
	Action__c = a1.Id,
	Description__c = 'Non-Industry Email Address',
	Logical_Statement__c = '1 OR 2 OR 3',
	RPN_Logic__c = '1,2,OR,3,OR',
	Object_Type__c = 'Lead'
	);
insert a1cs1;

Condition_Line_Item__c a1cli1 = new Condition_Line_Item__c(
	Condition_Set__c = a1cs1.Id,
	Field__c = 'Email',
	Field_Type__c = 'EMAIL',
	Operand__c = '.org',
	Operator__c = 'doesNotContain',
	Rule_Number__c = 1
	);
insert a1cli1;

Condition_Line_Item__c a1cli2 = new Condition_Line_Item__c(
	Condition_Set__c = a1cs1.Id,
	Field__c = 'Email',
	Field_Type__c = 'EMAIL',
	Operand__c = '.edu',
	Operator__c = 'doesNotContain',
	Rule_Number__c = 2
	);
insert a1cli2;

Condition_Line_Item__c a1cli3 = new Condition_Line_Item__c(
	Condition_Set__c = a1cs1.Id,
	Field__c = 'Email',
	Field_Type__c = 'EMAIL',
	Operand__c = '.gov',
	Operator__c = 'doesNotContain',
	Rule_Number__c = 3
	);
insert a1cli3;


// RULE 2 //

Action__c a2 = new Action__c(
	Action_Type__c = 'Scoring',
	Description__c = 'Valuable Title Segment',
	Positive__c = true,
	Score_Type__c = 'fit',
	Value__c = 10
	);
insert a2;

Condition_Set__c a2cs1 = new Condition_Set__c(
	Action__c = a2.Id,
	Description__c = 'Valuable Title Segment',
	Logical_Statement__c = '1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14 OR 15 OR 16',
	RPN_Logic__c = '1,2,OR,3,OR,4,OR,5,OR,6,OR,7,OR,8,OR,9,OR,10,OR,11,OR,12,OR,13,OR,14,OR,15,OR,16,OR',
	Object_Type__c = 'Lead'
	);
insert a2cs1;

Condition_Line_Item__c a2cli1 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Developer',
	Operator__c = '=',
	Rule_Number__c = 1
	);
insert a2cli1;

Condition_Line_Item__c a2cli2 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Information Technology',
	Operator__c = '=',
	Rule_Number__c = 2
	);
insert a2cli2;

Condition_Line_Item__c a2cli3 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Data Engineer',
	Operator__c = '=',
	Rule_Number__c = 3
	);
insert a2cli3;

Condition_Line_Item__c a2cli4 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Finance',
	Operator__c = '=',
	Rule_Number__c = 4
	);
insert a2cli4;

Condition_Line_Item__c a2cli5 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Architect',
	Operator__c = '=',
	Rule_Number__c = 5
	);
insert a2cli5;

Condition_Line_Item__c a2cli6 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Applications',
	Operator__c = '=',
	Rule_Number__c = 6
	);
insert a2cli6;

Condition_Line_Item__c a2cli7 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Line of Business-Dir/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 7
	);
insert a2cli7;

Condition_Line_Item__c a2cli8 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Analytics',
	Operator__c = '=',
	Rule_Number__c = 8
	);
insert a2cli8;

Condition_Line_Item__c a2cli9 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Data Engineer-Dir/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 9
	);
insert a2cli9;

Condition_Line_Item__c a2cli10 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Analytics-Director/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 10
	);
insert a2cli10;

Condition_Line_Item__c a2cli11 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Applications-Dir/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 11
	);
insert a2cli11;

Condition_Line_Item__c a2cli12 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Finance-Dir/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 12
	);
insert a2cli12;

Condition_Line_Item__c a2cli13 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Architect-Dir/VP',
	Operator__c = '=',
	Rule_Number__c = 13
	);
insert a2cli13;

Condition_Line_Item__c a2cli14 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'IT-Dir/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 14
	);
insert a2cli14;

Condition_Line_Item__c a2cli15 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Business Intelligence-Dir/VP/Chief',
	Operator__c = '=',
	Rule_Number__c = 15
	);
insert a2cli15;

Condition_Line_Item__c a2cli16 = new Condition_Line_Item__c(
	Condition_Set__c = a2cs1.Id,
	Field__c = 'Segment__r.Name',
	Field_Type__c = 'STRING',
	Operand__c = 'Business Intelligence',
	Operator__c = '=',
	Rule_Number__c = 16
	);
insert a2cli16;
