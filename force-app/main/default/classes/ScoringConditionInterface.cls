global class ScoringConditionInterface extends ConditionInterface {

    public static final Set<String> HIGH_VALUE_PAGE_NAMES = new Set<String>{'https://www.incorta.com/virtual-hands-on-lab-series','https://www.incorta.com/demo','https://www.incorta.com/q4-ms-synapse','https://www.incorta.com/contact','https://go.incorta.com/architecture-guide','https://go.incorta.com/whitepaper-data-engineering-best-practices','https://cloud.incorta.com/signup'};
    public static final List<String> HIGH_VALUE_PAGE_PARTICLES = new List<String>{'/solutions/','/platform/','/customers/','/product-demo/','/data-apps','docs.incorta'};

    global override void preScoringCallback(List<SObject> newObjects, Map<Id,SObject> oldMap, Boolean isInsert, String objectType) {
        //Add account values
        if (objectType == 'Lead' || objectType == 'Contact') {
            String accountField = objectType == 'Lead' ? 'LeanData__Reporting_Matched_Account__c' : 'AccountId';
            Set<Id> accountIds = new Set<Id>();
            //NEW! Set<Id> recordIds = new Set<Id>();
            for (SObject sobj : newObjects) {
                if (sobj.get(accountField) != null) accountIds.add((Id) sobj.get(accountField));
            }
            if (!accountIds.isEmpty()) {
                Map<Id,Account> idToAccount = new Map<Id,Account>([SELECT Id, Account_Tier__c FROM Account WHERE Id IN :accountIds]);
                for (SObject sobj : newObjects) {
                    if (sobj.get(accountField) != null) {
                        if (objectType == 'Lead') {
                            Lead l = (Lead) sobj;
                            l.LeanData__Reporting_Matched_Account__r = idToAccount.get(l.LeanData__Reporting_Matched_Account__c);
                        } else if (objectType == 'Contact') {
                            Contact c = (Contact) sobj;
                            c.Account = idToAccount.get(c.AccountId);
                        }
                    }
                }
            }
        // add campaign values
        } else if (objectType == 'CampaignMember') {
            Set<Id> campaignIds = new Set<Id>();
            for (SObject sobj : newObjects) {
                CampaignMember cm = (CampaignMember) sobj;
                campaignIds.add(cm.CampaignId);
            }
            Map<Id,Campaign> idToCampaignMap = new Map<Id,Campaign>([SELECT Id, Type FROM Campaign WHERE Id IN :campaignIds]);
            for (SObject sobj : newObjects) {
                CampaignMember cm = (CampaignMember) sobj;
                cm.Campaign = idToCampaignMap.get(cm.CampaignId);
            }
        }

    }


    public static final String SCORING_CAMPAIGN_TYPE = 'Scoring';

    global override void postScoringCallback(List<SObject> newObjects, Map<Id,SObject> oldMap, Boolean isInsert, String objectType) {
        if (objectType == 'Lead') {
            System.debug('post callback for lead');
            Set<Id> leadsToEvaluate = new Set<Id>();
            for (SObject uncastLead : newObjects) {
                String lastPageSeen = (String) uncastLead.get('Last_Page_Seen__c');
                if (lastPageSeen != null && (isInsert || lastPageSeen != oldMap.get(uncastLead.Id).get('Last_Page_Seen__c'))) {
                    if (HIGH_VALUE_PAGE_NAMES.contains(lastPageSeen)) {
                        leadsToEvaluate.add(uncastLead.Id);
                    } else {
                        for (String particle : HIGH_VALUE_PAGE_PARTICLES) {
                            if (lastPageSeen.contains(particle)) leadsToEvaluate.add(uncastLead.Id);
                        }
                    }
                }
            }

            if (!leadsToEvaluate.isEmpty()) {
                //We should always have one scoring campaign - for now
                List<Campaign> scoringCampaigns = [SELECT Id FROM Campaign WHERE Type = :SCORING_CAMPAIGN_TYPE];
                
                //a null check - but really there's a problem if we're here
                if (!scoringCampaigns.isEmpty()) {
                    Id scoringCampaignId = scoringCampaigns[0].Id;
                    List<CampaignMember> toInsert = new List<CampaignMember>();
                    Datetime d = DateTime.now().addhours(-1);
                    for (Lead l : [SELECT Id, (SELECT Id FROM CampaignMembers WHERE CreatedDate > :d AND CampaignId = :scoringCampaignId) FROM Lead WHERE Id IN :leadsToEvaluate]) {
                        System.debug('evaluating leads');
                        if (l.CampaignMembers.isEmpty()) {
                            toInsert.add(new CampaignMember(LeadId = l.Id, CampaignId = scoringCampaignId));
                            System.debug('CM to insert');
                        }
                    }
                    // if (!toInsert.isEmpty()) Database.insert(toInsert, false);
                    if (!toInsert.isEmpty()) Database.insert(toInsert, false);
                } else {
                    System.debug('Why is there no Scoring Campaign?');
                }
            }
        }
    }

     
}
