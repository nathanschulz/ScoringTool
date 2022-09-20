public with sharing class ScoringUtility {
    public static final String SCORING_ACTION = 'Scoring';
    public static final String FIT_SCORE_FIELD = 'Fit_Score__c';
    public static final String ENGAGEMENT_SCORE_FIELD = 'Engagement_Score__c';
    public static final String FIT_SCORE_TYPE = 'fit';
    public static final String ENGAGEMENT_SCORE_TYPE = 'engagement';
    
    //Action Frequencies
    public static final String ALWAYS = 'Always';
    public static final String DAILY = 'Daily';
    public static final String HOURLY = 'Hourly';

    public static Boolean SKIP_LEAD_TRIGGER = false;
    public static Boolean SKIP_CAMPAIGN_MEMBER_TRIGGER = false;

    Map<Id,Lead> campaignMemberLeads = new Map<Id,Lead>();
    Map<Id,Action_Log__c> leadIdToActionLog {get; private set;}

    public static List<Condition_Set__c> scoreConditionsForObject(String objectType) {
        return [SELECT
            Id, Logical_Statement__c, RPN_Logic__c, Object_Type__c, Description__c,
            (SELECT Field__c, Field_Type__c, Operand__c, Operator__c, Rule_Number__c FROM Condition_Set_Line_Items__r),
            Action__c, Action__r.Positive__c, Action__r.Score_Type__c,
            Action__r.Value__c, Action__r.Action_Frequency__c
            FROM Condition_Set__c
            WHERE
            Object_Type__c = :objectType
            AND Action__r.Action_Type__c = :SCORING_ACTION
            AND Active__c = true
        ];
    }

    public static List<Condition_Set__c> leadConditions {
        get {
            if (leadConditions == null) {
                leadConditions = scoreConditionsForObject('Lead');
            }
            return leadConditions;
        }
        private set;
    }
    public static List<Condition_Set__c> campaignMemberConditions {
        get {
            if (campaignMemberConditions == null) {
                campaignMemberConditions = scoreConditionsForObject('CampaignMember');
            }
            return campaignMemberConditions;
        }
        private set;
    }

    public ScoringUtility() {

    }

    public List<Action_Log__c> scoreCampaignMembers(List<CampaignMember> campaignMembersToScore) {
        if (ScoringUtility.SKIP_CAMPAIGN_MEMBER_TRIGGER == true) return null;
        List<Action_Log__c> actionLogs = new List<Action_Log__c>();

        Set<Id> leadIds = new Set<Id>();
        for (CampaignMember cm : campaignMembersToScore) {
            if (cm.LeadId != null) leadIds.add(cm.LeadId);
        }
        if (leadIds.isEmpty()) return actionLogs;

        campaignMemberLeads = new Map<Id,Lead>([SELECT Id, Fit_Score__c, Engagement_Score__c FROM Lead WHERE Id IN :leadIds]);
        Map<Id,Lead> leadsToUpdate = new Map<Id,Lead>();

        System.debug('scoring members');
        for (CampaignMember cm : campaignMembersToScore) {

            Decimal beforeScore = cm.Engagement_Score__c;
            beforeScore = beforeScore == null ? 0 : beforeScore;
            System.debug('member score before = ' + beforeScore);
            actionLogs.add(scoreCampaignMember(cm));
            Decimal afterScore = cm.Engagement_Score__c;
            System.debug('member score after = ' + afterScore);
            if (beforeScore != afterScore) {
                if (!leadsToUpdate.containsKey(cm.LeadId)) leadsToUpdate.put(cm.LeadId, campaignMemberLeads.get(cm.LeadId));
                Lead toUpdate = leadsToUpdate.get(cm.LeadId);
                toUpdate.Engagement_Score__c = toUpdate.Engagement_Score__c == null ? 0 : toUpdate.Engagement_Score__c;
                toUpdate.Engagement_Score__c -= beforeScore;
                toUpdate.Engagement_Score__c += afterScore;
            }
        }

        if (!leadsToUpdate.isEmpty()) {
            List<Lead> updateList = leadsToUpdate.values();
            for (Lead l : updateList) {
                setOverallScore(l);
            }
            ScoringUtility.SKIP_LEAD_TRIGGER = true;
            update updateList;
            ScoringUtility.SKIP_LEAD_TRIGGER = false;
        }

        return actionLogs;
    }

    public Map<Id,Action_Log__c> getLeadToMostRecentLog(List<Lead> leads) {
        Map<Id,Action_Log__c> leadToLog = new Map<Id,Action_Log__c>();
        Set<Id> leadIds = new Set<Id>();
        for (Lead l : leads) {
            if (l.Id == null) return leadToLog;
            leadIds.add(l.Id);
        }
        for (Action_Log__c al : [SELECT Id FROM Action_Log__c WHERE Lead__c IN :leadIds ORDER BY CreatedDate DESC]) {

        }

        return leadToLog;
    }

    public List<Action_Log__c> scoreLeads(List<Lead> leadsToScore) {
        if (ScoringUtility.SKIP_LEAD_TRIGGER == true) return null;
        leadIdToActionLog = getLeadToMostRecentLog(leadsToScore);
        List<Action_Log__c> actionLogs = new List<Action_Log__c>();
        for (Lead l : leadsToScore) {
            actionLogs.add(scoreLead(l));
        }
        return actionLogs;
    }

    public String getSalesLine(Boolean positive, String scoreType, String description) {
        return scoreType + ' score' + ' ' + (positive ? 'increased: ' : 'reduced: ') + description;
    }

    public String getAdminLine(Decimal points, String scoreType, String description, Id conditionId) {
        return String.valueOf(points) + ' ' + scoreType + ' score: <a href="/' + conditionId +  '">' + description + '</a>';
    }

    //
    public Boolean scoredWithinFrequencyInterval(SObject sobj, Condition_Set__c c) {
        if (c.Action__r.Action_Frequency__c == null || c.Action__r.Action_Frequency__c == ALWAYS) return false;

        return false;
    }

    public Action_Log__c scoreCampaignMember(CampaignMember cm) {
        Action_Log__c newLog = new Action_Log__c();
        Decimal fitScore = 0;
        Decimal engagementScore = 0;
        List<String> adminStatements = new List<String>();
        List<String> repStatements = new List<String>();
        List<Id> conditionSets = new List<Id>();
        for (Condition_Set__c c : ScoringUtility.campaignMemberConditions) {

            if (scoredWithinFrequencyInterval(cm, c)) continue;
            
            if (ConditionUtility.objectMeetsConditionSet(cm, c)) {
                Decimal partialScore = c.Action__r.Positive__c == true ? c.Action__r.Value__c : (-1) * c.Action__r.Value__c;
                System.debug('partial score: ' + partialScore);
                if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE) {
                    engagementScore += partialScore;
                } else {
                    fitScore += partialScore;
                }
                repStatements.add(getSalesLine(c.Action__r.Positive__c == true, c.Action__r.Score_Type__c, c.Description__c));
                adminStatements.add(getAdminLine(partialScore,c.Action__r.Score_Type__c, c.Description__c, c.Id));
                conditionSets.add(c.Id);
            }
        }
        cm.put(ENGAGEMENT_SCORE_FIELD, engagementScore);
        cm.Score_Time__c = DateTime.now();
        newLog.Rep_Summary__c = String.join(repStatements, '\n');
        newLog.Admin_Summary__c = String.join(adminStatements, '\n');
        newLog.Fit_Score__c = fitScore;
        newLog.Engagement_Score__c = engagementScore;
        newLog.Lead__c = cm.LeadId;
        newLog.Condition_Sets__c = JSON.serialize(conditionSets);
        return newLog;
    }

    public void setOverallScore(Lead l) {
        String fit;
        String engagementLevel;
        if (l.Fit_Score__c == null || l.Fit_Score__c <= 25) {
            fit = 'D';
        } else if (l.Fit_Score__c <= 50) {
            fit = 'C';
        } else if (l.Fit_Score__c <= 75) {
            fit = 'B';
        } else {
            fit = 'A';
        }

        if (l.Engagement_Score__c == null || l.Engagement_Score__c <= 25) {
            engagementLevel = '1';
        } else if (l.Engagement_Score__c <= 50) {
            engagementLevel = '2';
        } else if (l.Engagement_Score__c <= 75) {
            engagementLevel = '3';
        } else {
            engagementLevel = '4';
        }

        l.Overall_Score__c = fit + engagementLevel;
    }

    public Action_Log__c scoreLead(Lead l) {
        Action_Log__c newLog = new Action_Log__c();
        Decimal fitScore = 0;
        Decimal engagementScore = 0;
        List<String> adminStatements = new List<String>();
        List<String> repStatements = new List<String>();
        List<Id> conditionSets = new List<Id>();
        for (Condition_Set__c c : ScoringUtility.leadConditions) {
            if (ConditionUtility.objectMeetsConditionSet(l, c)) {
                Decimal partialScore = c.Action__r.Positive__c == true ? c.Action__r.Value__c : (-1) * c.Action__r.Value__c;
                if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE) {
                    engagementScore += partialScore;
                } else {
                    fitScore += partialScore;
                }
                repStatements.add(getSalesLine(c.Action__r.Positive__c == true, c.Action__r.Score_Type__c, c.Description__c));
                adminStatements.add(getAdminLine(partialScore,c.Action__r.Score_Type__c, c.Description__c, c.Id));
                conditionSets.add(c.Id);
            }
        }

        for (Condition_Set__c c : ScoringUtility.campaignMemberConditions) {
            for (CampaignMember cm : l.CampaignMembers) {
                
                if (ConditionUtility.objectMeetsConditionSet(cm, c)) {
                    Decimal partialScore = c.Action__r.Positive__c == true ? c.Action__r.Value__c : (-1) * c.Action__r.Value__c;
                    if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE) {
                        engagementScore += partialScore;
                    } else {
                        fitScore += partialScore;
                    }
                    repStatements.add(getSalesLine(c.Action__r.Positive__c == true, c.Action__r.Score_Type__c, c.Description__c));
                    adminStatements.add(getAdminLine(partialScore,c.Action__r.Score_Type__c, c.Description__c, c.Id));
                    conditionSets.add(c.Id);
                }
            }
        }

        l.put(FIT_SCORE_FIELD, fitScore);
        // l.put(ENGAGEMENT_SCORE_FIELD, engagementScore);
        setOverallScore(l);
        newLog.Rep_Summary__c = String.join(repStatements, '\n');
        newLog.Admin_Summary__c = String.join(adminStatements, '\n');
        newLog.Fit_Score__c = fitScore;
        newLog.Engagement_Score__c = engagementScore;
        newLog.Lead__c = l.Id;
        newLog.Condition_Sets__c = JSON.serialize(conditionSets);
        return newLog;
    }

}
