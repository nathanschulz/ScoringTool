public with sharing class ReScoringBatch implements Database.Batchable<SObject> {
    
    public static final Decimal DEGRADATION = 0.2;

    public String batchMode {get; set;}
    public Boolean scoreEngagement {get; set;}
    public String objectType {get; set;}
    public String whereClause {get; set;}
    public String queryString {get; set;}
    public DateTime campaignMemberStartDate {get;set;}
    public DateTime campaignMemberCreatedDate {get;set;}

    public static void runReScoringBatch(ReScoringBatch rsb, Integer sliceSize) {
        Database.executeBatch(rsb, sliceSize);
    }

    public ReScoringBatch() {
        scoreEngagement = false;
        campaignMemberCreatedDate = Datetime.now().addDays(-90);
        campaignMemberStartDate = Datetime.now().addDays(-7);
    }

    public String getQueryString() {
        if (queryString != null) return queryString;
        String qString = 'SELECT Id, LeadId, Lead.Engagement_Score__c, Lead.Fit_Score__c, Contact.Engagement_Score__c, Contact.Fit_Score__c, Engagement_Score__c, Score_Time__c';
        qString += ' FROM CampaignMember ';
        if (batchMode == 'degradeScore' || batchMode == 'haircutEngagement') {
            qString += ' WHERE Score_Time__c != null AND Score_Time__c != LAST_N_DAYS:90 AND Engagement_Score__c != null AND Engagement_Score__c != 0';
        } else {
            qString += ' WHERE Score_Time__c < LAST_N_DAYS:90';
        }
        return qString;
    }

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(getQueryString());
    }

    public void degradeEngagementScores(List<SObject> oldCMs) {
        degradeEngagementScores(oldCMs, false);
    }

    public void degradeEngagementScores(List<SObject> oldCMs, Boolean haircut) {
        Map<Id,SObject> recordsToUpdate = new Map<Id,SObject>();
        for (SObject cmUncast : oldCMs) {
            CampaignMember cm = (CampaignMember) cmUncast;
            Integer oldEngagement = (Integer) cm.Engagement_Score__c;
            Integer newEngagement = haircut ? 0 : Integer.valueOf(oldEngagement * DEGRADATION);
            if (oldEngagement == 0 || oldEngagement == null) continue;

            //we might hit the same lead/contact with >1 cms in one batch slice
            //check if we've already updated the lead/contact and use that version,
            //else use the version queried from the CM
            Id scoreRecordId = cm.LeadId != null ? cm.LeadId : cm.ContactId;
            SObject scoreRecord = recordsToUpdate.containsKey(scoreRecordId) ? recordsToUpdate.get(scoreRecordId) : 
                (cm.LeadId != null ? (SObject) cm.Lead : (SObject) cm.Contact);

            Integer recordPreviousEngagement = Integer.valueOf((Decimal) scoreRecord.get('Engagement_Score__c'));
            cm.Engagement_Score__c = newEngagement;
            cm.Score_Time__c = DateTime.now();
            scoreRecord.put('Engagement_Score__c', recordPreviousEngagement - oldEngagement + newEngagement);
            ScoringUtility.setOverallScore(scoreRecord);

            recordsToUpdate.put(cm.Id, cm);
            recordsToUpdate.put(scoreRecordId, scoreRecord);

        }
        if (!recordsToUpdate.isEmpty()) {
            List<SObject> listToUpdate = recordsToUpdate.values();
            ScoringUtility.SKIP_CONTACT_TRIGGER = true;
            ScoringUtility.SKIP_LEAD_TRIGGER = true;
            ScoringUtility.SKIP_CAMPAIGN_MEMBER_TRIGGER = true;
            listToUpdate.sort();
            update listToUpdate;
            ScoringUtility.SKIP_CONTACT_TRIGGER = false;
            ScoringUtility.SKIP_LEAD_TRIGGER = false;
            ScoringUtility.SKIP_CAMPAIGN_MEMBER_TRIGGER = false;
        }
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
            update sobjectScope;
        } else if (batchMode == 'degradeScore') {
            degradeEngagementScores(sobjectScope);
        } else if (batchMode == 'haircutEngagement') {
            degradeEngagementScores(sobjectScope, true);
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
            update sobjectScope;
        }
    }


    public void finish(Database.BatchableContext ctx) {

    }
}
