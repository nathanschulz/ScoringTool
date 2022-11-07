public with sharing class ScoringUtility {
    public static final String SCORING_ACTION = 'Scoring';
    public static final String FIT_SCORE_FIELD = 'Fit_Score__c';
    public static final String ENGAGEMENT_SCORE_FIELD = 'Engagement_Score__c';
    public static final String OVERALL_SCORE_FIELD = 'Overall_Score__c';
    public static final String FIT_SCORE_TYPE = 'fit';
    public static final String ENGAGEMENT_SCORE_TYPE = 'engagement';
    public static final Double QUERY_THRESHOLD = 0.8;
    
    //Action Frequencies
    public static final String ALWAYS = 'Always';
    public static final String DAILY = 'Daily';
    public static final String HOURLY = 'Hourly';

    public static Boolean SKIP_LEAD_TRIGGER = false;
    public static Boolean SKIP_CONTACT_TRIGGER = false;
    public static Boolean SKIP_CAMPAIGN_MEMBER_TRIGGER = false;

    public Map<Id,Lead> campaignMemberLeads = new Map<Id,Lead>();
    public Map<Id,Contact> campaignMemberContacts = new Map<Id,Contact>();
    public Map<Id,List<CampaignMember>> sobjToChildCMs = new Map<Id,List<CampaignMember>>();
    public DateTime campaignMemberStartDate {get; set;}
    public DateTime campaignMemberCreatedDate {get; set;}

    // Map<Id,Action_Log__c> leadIdToActionLog {get; private set;}

    public static List<Condition_Set__c> scoreConditionsForObject(String objectType) {
        return [SELECT
            Id, Logical_Statement__c, RPN_Logic__c, Object_Type__c, Description__c,
            (SELECT Field__c, Field_Type__c, Operand__c, Operator__c, Rule_Number__c FROM Condition_Set_Line_Items__r ORDER BY Rule_Number__c ASC),
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

    public static List<Condition_Set__c> contactConditions {
        get {
            if (contactConditions == null) {
                contactConditions = scoreConditionsForObject('Contact');
            }
            return contactConditions;
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
        campaignMemberStartDate = Datetime.now().addDays(-90);
        campaignMemberCreatedDate = Datetime.now().addDays(-90);
    }

    public List<Action_Log__c>scoreCampaignMembers(List<CampaignMember> campaignMembersToScore) {
        if (ScoringUtility.SKIP_CAMPAIGN_MEMBER_TRIGGER == true) return null;
        List<Action_Log__c> actionLogs = new List<Action_Log__c>();

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for (CampaignMember cm : campaignMembersToScore) {
            if (cm.LeadId != null) leadIds.add(cm.LeadId);
            if (cm.ContactId != null) contactIds.add(cm.ContactId);
        }
        if (leadIds.isEmpty() && contactIds.isEmpty()) return actionLogs;

        if (!leadIds.isEmpty()) campaignMemberLeads = new Map<Id,Lead>([SELECT Id, Fit_Score__c, Engagement_Score__c FROM Lead WHERE Id IN :leadIds]);
        if (!contactIds.isEmpty()) campaignMemberContacts = new Map<Id,Contact>([SELECT Id, Fit_Score__c, Engagement_Score__c FROM Contact WHERE Id IN :contactIds]);
        // Map<Id,Lead> leadsToUpdate = new Map<Id,Lead>();
        // Map<Id,Contact> contactsToUpdate = new Map<Id,Contact>();

        Map<Id,SObject> recordsToUpdate = new Map<Id,SObject>();

        System.debug('scoring members');
        for (CampaignMember cm : campaignMembersToScore) {

            Decimal beforeScore = cm.Engagement_Score__c;
            beforeScore = beforeScore == null ? 0 : beforeScore;
            System.debug('member score before = ' + beforeScore);
            Action_Log__c newLog = scoreCampaignMember(cm);
            if (newLog != null) {
                actionLogs.add(newLog);
            } else {
                continue;
            }
            Decimal afterScore = cm.Engagement_Score__c;
            System.debug('member score after = ' + afterScore);
            if (beforeScore != afterScore) {
                Id recordId = cm.LeadId != null ? cm.LeadId : cm.ContactId;
                if (!recordsToUpdate.containsKey(recordId)) recordsToUpdate.put(recordId, cm.LeadId != null ? (SObject) campaignMemberLeads.get(recordId) : (SObject) campaignMemberContacts.get(recordId));
                // if (cm.LeadId != null && !leadsToUpdate.containsKey(cm.LeadId)) leadsToUpdate.put(cm.LeadId, campaignMemberLeads.get(cm.LeadId));
                // if (cm.ContactId != null && !contactsToUpdate.containsKey(cm.ContactId)) leadsToUpdate.put(cm.ContactId, campaignMemberContacts.get(cm.ContactId));
                // Lead toUpdate = leadsToUpdate.get(cm.LeadId);
                SObject toUpdate = recordsToUpdate.get(recordId);
                Decimal newScore = (Decimal) toUpdate.get(ENGAGEMENT_SCORE_FIELD);
                newScore = newScore != null ? newScore : 0;
                newScore -= beforeScore;
                newScore += afterScore;
                toUpdate.put(ENGAGEMENT_SCORE_FIELD, newScore);
                // toUpdate.Engagement_Score__c = toUpdate.Engagement_Score__c == null ? 0 : toUpdate.Engagement_Score__c;
                // toUpdate.Engagement_Score__c -= beforeScore;
                // toUpdate.Engagement_Score__c += afterScore;
            }
        }

        if (!recordsToUpdate.isEmpty()) {
            List<SObject> updateList = recordsToUpdate.values();
            for (SObject sobj : updateList) {
                setOverallScore(sobj);
            }
            updateList.sort();
            ScoringUtility.SKIP_LEAD_TRIGGER = true;
            ScoringUtility.SKIP_CONTACT_TRIGGER = true;
            update updateList;
            ScoringUtility.SKIP_LEAD_TRIGGER = false;
            ScoringUtility.SKIP_CONTACT_TRIGGER = false;
        }


        // if (!leadsToUpdate.isEmpty()) {
        //     List<Lead> updateList = leadsToUpdate.values();
        //     for (Lead l : updateList) {
        //         setOverallScore(l);
        //     }
        //     ScoringUtility.SKIP_LEAD_TRIGGER = true;
        //     ScoringUtility.SKIP_CONTACT_TRIGGER = true;
        //     update updateList;
        //     ScoringUtility.SKIP_LEAD_TRIGGER = false;
        //     ScoringUtility.SKIP_CONTACT_TRIGGER = false;
        // }
        return actionLogs;
    }

    // public Map<Id,Action_Log__c> getLeadToMostRecentLog(List<Lead> leads) {
    //     Map<Id,Action_Log__c> leadToLog = new Map<Id,Action_Log__c>();
    //     Set<Id> leadIds = new Set<Id>();
    //     for (Lead l : leads) {
    //         if (l.Id == null) return leadToLog;
    //         leadIds.add(l.Id);
    //     }
    //     for (Action_Log__c al : [SELECT Id FROM Action_Log__c WHERE Lead__c IN :leadIds ORDER BY CreatedDate DESC]) {

    //     }

    //     return leadToLog;
    // }

    public void buildCMMap(List<SObject> sobjs) {
        Set<Id> recordIds = new Set<Id>();
        for (SObject sobj : sobjs) {
            if (sobj.Id != null) recordIds.add(sobj.Id);
        }
        if (recordIds.isEmpty()) return;
        Integer rowsReturned = Limits.getQueryRows();
        System.debug('$$ rows returned before cm query: ' + rowsReturned);
        if ( ((rowsReturned * 1.0) / Limits.getLimitQueryRows()) > QUERY_THRESHOLD) return;
        for (CampaignMember cm : [SELECT Id, Engagement_Score__c, Campaign.Type, Status, Type, LeadId, ContactId FROM CampaignMember WHERE (LeadId IN :recordIds OR ContactId IN :recordIds) AND Engagement_Score__c != null AND Engagement_Score__c != 0]) {
            Id recordId = cm.ContactId != null ? cm.ContactId : cm.LeadId;
            if (!sobjToChildCMs.containsKey(recordId)) sobjToChildCMs.put(recordId, new List<CampaignMember>());
            sobjToChildCMs.get(recordId).add(cm);
        }
        System.debug('$$ rows returned after cm query: ' + Limits.getQueryRows());
    }

    public List<Action_Log__c> scoreContacts(List<Contact> contactsToScore) {
        if (ScoringUtility.SKIP_CONTACT_TRIGGER == true) return null;
        List<Action_Log__c> actionLogs = new List<Action_Log__c>();
        buildCMMap(contactsToScore);
        for (Contact c : contactsToScore) {
            Action_Log__c newLog = scoreSObject(c, 'Contact', true);
            if (newLog != null) actionLogs.add(newLog);
        }
        return actionLogs;  
    }

    public List<Action_Log__c> scoreLeads(List<Lead> leadsToScore) {
        if (ScoringUtility.SKIP_LEAD_TRIGGER == true) return null;
        // leadIdToActionLog = getLeadToMostRecentLog(leadsToScore);
        buildCMMap(leadsToScore);
        List<Action_Log__c> actionLogs = new List<Action_Log__c>();
        for (Lead l : leadsToScore) {
            Action_Log__c newLog = scoreSObject(l, 'Lead', true);
            if (newLog != null) actionLogs.add(newLog);
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
        Decimal prevEngagementScore = cm.Engagement_Score__c;
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
        if (engagementScore == prevEngagementScore) {
            return null;
        }
        cm.put(ENGAGEMENT_SCORE_FIELD, engagementScore);
        cm.Score_Time__c = DateTime.now();
        newLog.Previous_Engagement_Score__c = prevEngagementScore;
        newLog.Rep_Summary__c = String.join(repStatements, '\n');
        newLog.Admin_Summary__c = String.join(adminStatements, '\n');
        newLog.Fit_Score__c = fitScore;
        newLog.Engagement_Score__c = engagementScore;
        newLog.Lead__c = cm.LeadId;
        newLog.Condition_Sets__c = JSON.serialize(conditionSets);
        return newLog;
    }

    public void setOverallScore(SObject sobj) {
        String fit;
        String engagementLevel;
        Decimal fitScore = (Decimal) sobj.get('Fit_Score__c');
        if (fitScore == null || fitScore <= 25) {
            fit = 'D';
        } else if (fitScore <= 50) {
            fit = 'C';
        } else if (fitScore <= 75) {
            fit = 'B';
        } else {
            fit = 'A';
        }

        Decimal engagementScore = (Decimal) sobj.get('Engagement_Score__c');
        if (engagementScore == null || engagementScore <= 10) {
            engagementLevel = '5';
        } else if (engagementScore > 10 && engagementScore <= 25) {
            engagementLevel = '4';
        } else if (engagementScore <= 50) {
            engagementLevel = '3';
        } else if (engagementScore <= 75) {
            engagementLevel = '2';
        } else {
            engagementLevel = '1';
        }

        sobj.put(OVERALL_SCORE_FIELD, fit + engagementLevel);
    }

    public Action_Log__c scoreSObject(SObject sobj, String objectType, Boolean scoreEngagement) {
        Action_Log__c newLog = new Action_Log__c();
        Decimal prevFitScore = (Decimal) sobj.get(FIT_SCORE_FIELD);
        Decimal prevEngagementScore = (Decimal) sobj.get(ENGAGEMENT_SCORE_FIELD);
        Decimal fitScore = 0;
        Decimal engagementScore = 0;
        List<String> adminStatements = new List<String>();
        List<String> repStatements = new List<String>();
        List<Id> conditionSets = new List<Id>();
        List<Condition_Set__c> conditions = objectType == 'Lead' ? ScoringUtility.leadConditions : ScoringUtility.contactConditions;
        for (Condition_Set__c c : conditions) {
            if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE && !scoreEngagement) continue;
            if (ConditionUtility.objectMeetsConditionSet(sobj, c)) {
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

        if (sobjToChildCMs.containsKey(sobj.Id)) {
            for (CampaignMember cm : sobjToChildCMs.get(sobj.Id)) {
                if (cm.Engagement_Score__c != null && cm.Engagement_Score__c != 0) {
                    engagementScore += cm.Engagement_Score__c;
                }
                // else {
                //     for (Condition_Set__c c : ScoringUtility.campaignMemberConditions) {
                //         if (ConditionUtility.objectMeetsConditionSet(cm, c)) {
                //             Decimal partialScore = c.Action__r.Positive__c == true ? c.Action__r.Value__c : (-1) * c.Action__r.Value__c;
                //             engagementScore += partialScore;
                //             // if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE) {
                //             //     engagementScore += partialScore;
                //             // } else {
                //             //     fitScore += partialScore;
                //             // }
                //             repStatements.add(getSalesLine(c.Action__r.Positive__c == true, c.Action__r.Score_Type__c, c.Description__c));
                //             adminStatements.add(getAdminLine(partialScore,c.Action__r.Score_Type__c, c.Description__c, c.Id));
                //             conditionSets.add(c.Id);
                //        }
                //     }  
                // }
            }
        }
        if (fitScore == prevFitScore && engagementScore == prevEngagementScore) {
            return null;
        }
        sobj.put(FIT_SCORE_FIELD, fitScore);
        sobj.put(ENGAGEMENT_SCORE_FIELD, engagementScore);
        setOverallScore(sobj);
        newLog.Rep_Summary__c = String.join(repStatements, '\n');
        newLog.Admin_Summary__c = String.join(adminStatements, '\n');
        newLog.Previous_Engagement_Score__c = prevEngagementScore;
        newLog.Previous_Fit_Score__c = prevFitScore;
        newLog.Fit_Score__c = fitScore;
        newLog.Engagement_Score__c = engagementScore;
        if (objectType == 'Lead') {
            newLog.Lead__c = sobj.Id;
        } else if (objectType == 'Contact') {
            newLog.Contact__c = sobj.Id;
        }
        
        newLog.Condition_Sets__c = JSON.serialize(conditionSets);
        return newLog;
    }

    // public Action_Log__c scoreLead(Lead l) {
    //     Action_Log__c newLog = new Action_Log__c();
    //     Decimal fitScore = 0;
    //     Decimal engagementScore = 0;
    //     List<String> adminStatements = new List<String>();
    //     List<String> repStatements = new List<String>();
    //     List<Id> conditionSets = new List<Id>();
    //     for (Condition_Set__c c : ScoringUtility.leadConditions) {
    //         if (ConditionUtility.objectMeetsConditionSet(l, c)) {
    //             Decimal partialScore = c.Action__r.Positive__c == true ? c.Action__r.Value__c : (-1) * c.Action__r.Value__c;
    //             if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE) {
    //                 engagementScore += partialScore;
    //             } else {
    //                 fitScore += partialScore;
    //             }
    //             repStatements.add(getSalesLine(c.Action__r.Positive__c == true, c.Action__r.Score_Type__c, c.Description__c));
    //             adminStatements.add(getAdminLine(partialScore,c.Action__r.Score_Type__c, c.Description__c, c.Id));
    //             conditionSets.add(c.Id);
    //         }
    //     }

    //     // for (Condition_Set__c c : ScoringUtility.campaignMemberConditions) {
    //     //     for (CampaignMember cm : l.CampaignMembers) {
                
    //     //         if (ConditionUtility.objectMeetsConditionSet(cm, c)) {
    //     //             Decimal partialScore = c.Action__r.Positive__c == true ? c.Action__r.Value__c : (-1) * c.Action__r.Value__c;
    //     //             if (c.Action__r.Score_Type__c == ENGAGEMENT_SCORE_TYPE) {
    //     //                 engagementScore += partialScore;
    //     //             } else {
    //     //                 fitScore += partialScore;
    //     //             }
    //     //             repStatements.add(getSalesLine(c.Action__r.Positive__c == true, c.Action__r.Score_Type__c, c.Description__c));
    //     //             adminStatements.add(getAdminLine(partialScore,c.Action__r.Score_Type__c, c.Description__c, c.Id));
    //     //             conditionSets.add(c.Id);
    //     //         }
    //     //     }
    //     // }

    //     l.put(FIT_SCORE_FIELD, fitScore);
    //     // l.put(ENGAGEMENT_SCORE_FIELD, engagementScore);
    //     setOverallScore(l);
    //     newLog.Rep_Summary__c = String.join(repStatements, '\n');
    //     newLog.Admin_Summary__c = String.join(adminStatements, '\n');
    //     newLog.Fit_Score__c = fitScore;
    //     newLog.Engagement_Score__c = engagementScore;
    //     newLog.Lead__c = l.Id;
    //     newLog.Condition_Sets__c = JSON.serialize(conditionSets);
    //     return newLog;
    // }

}
