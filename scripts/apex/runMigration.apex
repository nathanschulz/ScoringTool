

ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'Lead';
rsb.scoreEngagement = false;
rsb.campaignMemberCreatedDate = Datetime.now().addDays(-25);
rsb.campaignMemberStartDate = Datetime.now().addDays(-14); //CreatedDate = LAST_N_DAYS:60
// rsb.queryString = 'SELECT Id,Matched_Account_Technologies__c,LeanData__Reporting_Matched_Account__r.Account_Tier__c,Country,Email FROM Lead WHERE CreatedDate = LAST_N_DAYS:60 ORDER BY CreatedDate ASC';
rsb.queryString = 'SELECT Id,Fit_Score__c,Engagement_Score__c,Matched_Account_Technologies__c,LeanData__Reporting_Matched_Account__r.Account_Tier__c,Country,Email FROM Lead WHERE Fit_Score__c = 0 AND (Engagement_Score__c = null OR Engagement_Score__c = 0) ORDER BY CreatedDate DESC';
Database.executeBatch(rsb, 20);

ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'Lead';
rsb.scoreEngagement = false;
rsb.campaignMemberCreatedDate = Datetime.now().addDays(-45);
rsb.campaignMemberStartDate = Datetime.now().addDays(-45); //CreatedDate = LAST_N_DAYS:60
// rsb.queryString = 'SELECT Id,Matched_Account_Technologies__c,LeanData__Reporting_Matched_Account__r.Account_Tier__c,Country,Email FROM Lead WHERE CreatedDate = LAST_N_DAYS:60 ORDER BY CreatedDate ASC';
rsb.queryString = 'SELECT Id,Fit_Score__c,Engagement_Score__c,Matched_Account_Technologies__c,LeanData__Reporting_Matched_Account__r.Account_Tier__c,Country,Email FROM Lead WHERE Id IN (SELECT LeadId FROM CampaignMember WHERE CreatedDate = LAST_N_DAYS:46 OR FirstRespondedDate = LAST_N_DAYS:46) ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);


//clearScore
ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'Lead';
rsb.batchMode = 'clearScore';
rsb.scoreEngagement = true;
// rsb.campaignMemberStartDate = Datetime.now().addDays(-14); //CreatedDate = LAST_N_DAYS:60
rsb.queryString = 'SELECT Id,Matched_Account_Technologies__c,LeanData__Reporting_Matched_Account__r.Account_Tier__c,Country,Email FROM Lead WHERE (Engagement_Score__c != null AND Engagement_Score__c != 0) OR ((Fit_Score__c != null AND Fit_Score__c != 0)) OR Overall_Score__c != null ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);

ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'Contact';
rsb.batchMode = 'clearScore';
rsb.queryString = 'SELECT Id FROM Contact WHERE (Engagement_Score__c != null AND Engagement_Score__c != 0) OR ((Fit_Score__c != null AND Fit_Score__c != 0)) OR Overall_Score__c != null ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);

ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'Lead';
rsb.batchMode = 'clearScore';
rsb.queryString = 'SELECT Id FROM Lead WHERE (Engagement_Score__c != null AND Engagement_Score__c != 0) OR ((Fit_Score__c != null AND Fit_Score__c != 0)) OR Overall_Score__c != null ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);


Member First Responded Date -

ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'CampaignMember';
rsb.batchMode = 'clearScore';
rsb.queryString = 'SELECT Id FROM CampaignMember WHERE Engagement_Score__c != null AND Engagement_Score__c != 0 ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);


ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'CampaignMember';
rsb.scoreEngagement = true;
rsb.campaignMemberStartDate = Datetime.now().addDays(-14); //00Q2I00001PqNPSUA3
rsb.queryString = 'SELECT Id,Status,Engagement_Score__c,Campaign.Type,LeadId,ContactId,CampaignId FROM CampaignMember WHERE CreatedDate = LAST_N_DAYS:45 OR FirstRespondedDate = LAST_N_DAYS:45 ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);


ReScoringBatch rsb = new ReScoringBatch();
rsb.objectType = 'Contact';
rsb.scoreEngagement = false;
rsb.campaignMemberStartDate = Datetime.now().addDays(-14); //Overall_Score__c = \'A4\'
rsb.queryString = 'SELECT Id,Fit_Score__c,Engagement_Score__c,Technologies__c,Account.Account_Tier__c,MailingCountry,Email FROM Contact WHERE Fit_Score__c = null ORDER BY CreatedDate DESC';
// rsb.queryString = 'SELECT Id,Technologies__c,Account.Account_Tier__c,MailingCountry,Email FROM Contact WHERE CreatedDate = LAST_N_DAYS:90 ORDER BY CreatedDate ASC';
Database.executeBatch(rsb, 20);


CampaignMember cm = [SELECT Id, Campaign.Type, Status FROM CampaignMember WHERE Id = '00v2I00002RQkzcQAD'];
for (Condition_Set__c c : ScoringUtility.campaignMemberConditions) {
    
    if (ConditionUtility.objectMeetsConditionSet(cm, c)) {
    	System.debug('met');
    }
}



Condition_Set__c c = ;


ConditionUtility.objectMeetsConditionSet(cm, c);





//WHERE Id IN (SELECT LeadId FROM CampaignMember) 

List<SObject> toUpdate = new List<SObject>();
for (Condition_Set__c cs : [SELECT Id, Object_Type__c FROM Condition_Set__c]) {
	cs.Object_Type__c = 'fake';
	toUpdate.add(cs);
}

update toUpdate;