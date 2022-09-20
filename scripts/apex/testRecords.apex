Action__c a1 = new Action__c(
	Action_Type__c = 'Scoring',
	Description__c = 'Responded CampaignMember',
	Positive__c = true,
	Score_Type__c = 'engagement',
	Value__c = 30
	);
insert a1;

Condition_Set__c a1cs1 = new Condition_Set__c(
	Action__c = a1.Id,
	Description__c = 'Responded CampaignMember',
	Logical_Statement__c = '1',
	RPN_Logic__c = '1',
	Object_Type__c = 'CampaignMember'
	);
insert a1cs1;