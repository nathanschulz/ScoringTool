trigger CampaignMemberScoreTrigger on CampaignMember (before update, before insert, after update, after insert) {

	if (Trigger.isBefore) {
		ScoringTriggerHelper sth = new ScoringTriggerHelper('CampaignMember');
		sth.process();
	} else if (Trigger.isAfter) {
		ScoringTriggerHelper sth = new ScoringTriggerHelper('CampaignMember');
		sth.postProcess();
	}
}