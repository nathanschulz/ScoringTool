public with sharing class ReScoringBatch implements Database.Batchable<SObject> {
    
    public static final Decimal DEGRADATION = 0.8;

    public String batchMode {get; set;}
    public Boolean scoreEngagement {get; set;}
    public String objectType {get; set;}
    public String whereClause {get; set;}
    public String queryString {get; set;}
    public DateTime campaignMemberStartDate {get;set;}
    public DateTime campaignMemberCreatedDate {get;set;}

    public ReScoringBatch() {
        scoreEngagement = false;
        campaignMemberCreatedDate = Datetime.now().addDays(-90);
        campaignMemberStartDate = Datetime.now().addDays(-7);
    }

    public String getQueryString() {
        if (queryString != null) return queryString;
        String qString = 'SELECT Id, LeadId, Lead.Engagement_Score__c, Engagement_Score__c, Score_Time__c';
        qString += ' FROM CampaignMember ';
        qString += ' WHERE Score_Time__c < LAST_N_DAYS:90';
        return qString;
    }

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(getQueryString());
    }

    public void execute(Database.BatchableContext ctx, List<SObject> sobjectScope) {
        if (batchMode == 'clearScore') {
            for (SObject sobj : sobjectScope) {
                sobj.put(ScoringUtility.ENGAGEMENT_SCORE_FIELD, 0);
                if (objectType != 'CampaignMember') {
                    sobj.put(ScoringUtility.FIT_SCORE_FIELD, 0);
                    sobj.put('Overall_Score__c', '');
                }
            }
        } else {
            List<Action_Log__c> actionLogs = new List<Action_Log__c>();
            ScoringUtility su = new ScoringUtility();
            su.campaignMemberStartDate = campaignMemberStartDate;
            su.campaignMemberCreatedDate = campaignMemberCreatedDate;
            su.buildCMMap(sobjectScope);
            if (objectType != 'CampaignMember') {
                for (SObject s : sobjectScope) {
                    Action_Log__c newLog = su.scoreSObject(s, objectType, scoreEngagement);
                    if (newLog != null) actionLogs.add(newLog);
                }
            } else if (objectType == 'CampaignMember') {
                actionLogs.addAll( su.scoreCampaignMembers((List<CampaignMember>)  sobjectScope) );
            }
            if (!actionLogs.isEmpty()) insert actionLogs;
        }
        update sobjectScope;
    }


    public void finish(Database.BatchableContext ctx) {

    }
}
