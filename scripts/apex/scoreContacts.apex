public List<Action_Log__c> scoreContacts(List<Contact> contactsToScore) {
        if (ScoringUtility.SKIP_CONTACT_TRIGGER == true) return null;
        List<Action_Log__c> actionLogs = new List<Action_Log__c>();
        return actionLogs;  
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