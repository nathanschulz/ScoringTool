trigger ContactScoreTrigger on Contact (before update, before insert, after update, after insert) {
	if (Trigger.isBefore) {
		ScoringTriggerHelper sth = new ScoringTriggerHelper('Contact');
		sth.process();
	} else if (Trigger.isAfter) {
		ScoringTriggerHelper sth = new ScoringTriggerHelper('Contact');
		sth.postProcess();
	}
}