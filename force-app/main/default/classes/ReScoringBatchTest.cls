@isTest
private class ReScoringBatchTest {

    @testSetup
    static void migrateRecords() {
        ScoringUtility.SKIP_LEAD_TRIGGER = true;
        ScoringUtility.SKIP_CAMPAIGN_MEMBER_TRIGGER = true;
        Lead l = new Lead(LastName = 'Schulz', Email = 'test@schulz.com', Company = 'TestCo', Fit_Score__c = 60, Engagement_Score__c = 50);
        insert l;
        Campaign c = new Campaign(Name = 'test');
        insert c;
        CampaignMember cm = new CampaignMember(LeadId = l.Id, CampaignId = c.Id, Engagement_Score__c = 20);
        insert cm;
        ScoringUtility.SKIP_CAMPAIGN_MEMBER_TRIGGER = false;
        ScoringUtility.SKIP_LEAD_TRIGGER = false;
    }

    @isTest
    static void testScoreDegradation() {
        ReScoringBatch rsb = new ReScoringBatch();
        List<CampaignMember> cms = [SELECT Id, LeadId, Lead.Engagement_Score__c, Lead.Fit_Score__c, Contact.Engagement_Score__c, Contact.Fit_Score__c, Engagement_Score__c, Score_Time__c
            FROM CampaignMember];
        rsb.degradeEngagementScores(cms);
        Lead l = [SELECT Id, Engagement_Score__c FROM Lead];
        cms = [SELECT Id, LeadId, Lead.Engagement_Score__c, Lead.Fit_Score__c, Contact.Engagement_Score__c, Contact.Fit_Score__c, Engagement_Score__c, Score_Time__c
            FROM CampaignMember];
        CampaignMember cm = cms[0];
        System.assertEquals(cm.Engagement_Score__c, 4,
            'Score Not Degraded for CM');
        System.assertEquals(l.Engagement_Score__c, 34,
            'Score Not Degraded for Lead');

    }

    @isTest
    static void testRescoringBatch() {
        RescoringBatch rb = new ReScoringBatch();
        rb.getQueryString();
        // rb.queryString = 'SELECT Id FROM Lead';
        rb.queryString = rb.getQueryString();
        rb.getQueryString();
        rb.objectType = 'CampaignMember';
        rb.start(null);
        rb.execute(null, Database.query(rb.getQueryString()));
        rb.finish(null);
        System.assert(rb != null);
    }
}