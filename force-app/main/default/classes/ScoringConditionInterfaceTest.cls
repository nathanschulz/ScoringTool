
@isTest
private class ScoringConditionInterfaceTest {

    @testSetup
    static void seedData() {
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            Type = 'Scoring',//);//,
          //NATHAN TODO: REMOVE
            Campaign_Sourced_By__c = 'Marketing',
            Description = 'test',
            Campaign_Theme__c = 'UDAP',
            Campaign_Snippet__c = 'x');
        insert testCampaign;

        Account testAccount = new Account(Name = 'McTesterson');
        insert testAccount;

        Lead testLead = new Lead(LastName = 'Schulz', LeanData__Reporting_Matched_Account__c = testAccount.Id, Company = 'CampaignCompany', Email = 'test@testly.com');
        insert testLead;
    }

    @isTest
    static void testScoringConditionInterface() {
        SegmentTriggerHandler.SKIP_TRIGGER = true;

        ScoringConditionInterface ci = new ScoringConditionInterface();
        ci.postScoringCallback(null,null,null,null);
        System.assert(ci != null,
            'Scoring Condition Interface not instantiated.');

        Lead testLead = [SELECT Id FROM Lead LIMIT 1];

        //We should create a new CampaignMember if Last_Page_Seen__c value changes
        testLead.put('Last_Page_Seen__c','test.com/platform/');
        update testLead;
        List<CampaignMember> campMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :testLead.Id];
        System.assertEquals(campMembers.size(),1,
            'Correct number of campaign members not created for Last Page Seen');

        //A meaningless update should not create a new campaign member
        testLead.FirstName = 'Nathan';
        update testLead;
        campMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :testLead.Id];
        System.assertEquals(campMembers.size(),1,
            'Meaningless update created campaign member');

        //We should not create a new Campaign Member if there's a recent Campaign Member
        testLead.put('Last_Page_Seen__c','newsite.com/platform/');
        update testLead;
        campMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :testLead.Id];
        System.assertEquals(campMembers.size(),1,
            'Update within an hour incorrectly created campaign member');

        //After Deleting the Campaign Member, we should be able to create a new one.
        CampaignMember cm = campMembers[0];
        delete cm;
        campMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :testLead.Id];
        System.assertEquals(campMembers.size(),0,
            'Campaign Member not deleted.');

        testLead.put('Last_Page_Seen__c','testly.com/platform/');
        update testLead;
        campMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :testLead.Id];
        System.assertEquals(campMembers.size(),1,
            'New campaign member should be created');
    }
}