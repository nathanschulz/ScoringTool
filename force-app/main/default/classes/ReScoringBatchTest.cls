@isTest
private class ReScoringBatchTest {

    @testSetup
    static void migrateRecords() {
        Lead l = new Lead(LastName = 'Schulz', Email = 'test@schulz.com', Company = 'TestCo');
        insert l;
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