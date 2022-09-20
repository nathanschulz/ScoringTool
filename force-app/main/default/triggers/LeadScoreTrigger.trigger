trigger LeadScoreTrigger on Lead (before update) {
	
	ScoringTriggerHelper sth = new ScoringTriggerHelper('Lead');
	sth.process();
}