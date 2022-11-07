trigger LeadScoreTrigger on Lead (before update, before insert, after update, after insert) {
	if (Trigger.isBefore) {
		ScoringTriggerHelper sth = new ScoringTriggerHelper('Lead');
		sth.process();
	} else if (Trigger.isAfter) {
		ScoringTriggerHelper sth = new ScoringTriggerHelper('Lead');
		sth.postProcess();
	}
}