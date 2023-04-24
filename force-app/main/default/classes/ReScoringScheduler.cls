public with sharing class ReScoringScheduler implements Schedulable {
    public String campaignMemberScope;
    public Integer sliceSize;
    public ReScoringBatch rsb;

    public ReScoringScheduler() {
        this(new Map<String,Object>());
    }

    public ReScoringScheduler(Map<String,Object> params) {
        this.rsb = new ReScoringBatch();
        this.rsb.batchMode = 'degradeScore';
        this.sliceSize = params.containsKey('sliceSize') ? (Integer) params.get('sliceSize') : 50;
    }

    public void execute(SchedulableContext SC) {
        ReScoringBatch.runReScoringBatch(rsb, sliceSize);
    }
}
