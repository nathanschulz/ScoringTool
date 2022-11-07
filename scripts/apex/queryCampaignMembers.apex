List<SObject> leads = [SELECT Id, (SELECT Id FROM CampaignMembers) FROM Lead WHERE Id IN (SELECT LeadId FROM CampaignMember)];
SObject sobj = leads[0];
for (CampaignMember cm : sobj.getSObjects('CampaignMembers')) {
	System.debug(cm);
}