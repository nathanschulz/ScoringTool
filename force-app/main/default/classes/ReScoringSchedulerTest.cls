@isTest
private class ReScoringSchedulerTest {

    @isTest
    static void testInstantiation() {
        ReScoringScheduler rss = new RescoringScheduler();
        rss.execute(null);
        System.assert(rss != null);
    }
}