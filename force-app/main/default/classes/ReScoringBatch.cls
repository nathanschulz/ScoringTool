public with sharing class ReScoringBatch implements Database.Batchable<SObject> {
    
    public static final Decimal DEGRADATION = 0.8;

    public ReScoringBatch() {

    }

    public String getQueryString() {
        String queryString = 'SELECT Id, LeadId, Lead.Engagement_Score__c, Engagement_Score__c, Score_Time__c';
        queryString += ' FROM CampaignMember ';
        queryString += ' WHERE Score_Time__c < LAST_N_DAYS:90';
        return queryString;
    }

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(getQueryString());
    }

    public void execute(Database.BatchableContext ctx, List<SObject> sobjectScope) {
        DateTime currentJobTime = DateTime.now();
        Map<Id,SObject> leadsToUpdate = new Map<Id,SObject>();
        for (SObject campaignMemberUncast : sobjectScope) {
            CampaignMember cm = (CampaignMember) campaignMemberUncast;
            Lead cmLead = leadsToUpdate.containsKey(cm.LeadId) 
                ? (Lead) leadsToUpdate.get(cm.LeadId) : new Lead(Id = cm.LeadId, Engagement_Score__c = cm.Lead.Engagement_Score__c);
            leadsToUpdate.put(cmLead.Id, cmLead);
            Decimal originalEngagementScore = cm.Engagement_Score__c;
            Decimal currentEngagementScore = cm.Engagement_Score__c * DEGRADATION;
            cmLead.Engagement_Score__c = cmLead.Engagement_Score__c - originalEngagementScore + currentEngagementScore;
            cm.Engagement_Score__c = currentEngagementScore;
            cm.Score_Time__c = currentJobTime;
        }
        if (!leadsToUpdate.isEmpty()) update leadsToUpdate.values();
        update sobjectScope;
    }


    public void finish(Database.BatchableContext ctx) {

    }
}
