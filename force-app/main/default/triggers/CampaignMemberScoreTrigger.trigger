trigger CampaignMemberScoreTrigger on CampaignMember (before insert, before update) {
	ScoringUtility su = new ScoringUtility();
	List<Action_Log__c> logsToInsert = su.scoreCampaignMembers(Trigger.new);
	if (logsToInsert != null && !logsToInsert.isEmpty()) Database.insert(logsToInsert, false);
}