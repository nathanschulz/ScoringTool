SELECT
Id, LeadId, Campaign.Type, Engagement_Score__c, Status,
Lead.Engagement_Score__c
FROM
CampaignMember
WHERE
LeadId = '00Q2I00001PnwGOUAZ'