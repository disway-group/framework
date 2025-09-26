global class AsyncRetryScheduler implements Schedulable {
    global Object jobRef;
    global AsyncRetryScheduler() {}
    global AsyncRetryScheduler(Object jobRef) { this.jobRef = jobRef; }
    global void execute(SchedulableContext ctx) {
        if (jobRef instanceof System.Queueable) {
            System.enqueueJob((System.Queueable) jobRef);
        }
    }
    public static void scheduleOnce(Integer secondsFromNow, Object jobRef) {
        Datetime fire = System.now().addSeconds(Math.max(1, secondsFromNow));
        String cron = String.format('{0} {1} {2} {3} {4} ? {5}',
            new List<String>{
                String.valueOf(fire.second()),
                String.valueOf(fire.minute()),
                String.valueOf(fire.hour()),
                String.valueOf(fire.day()),
                String.valueOf(fire.month()),
                String.valueOf(fire.year())
            });
        System.schedule('AsyncRetry-' + Datetime.now().getTime(), cron, new AsyncRetryScheduler(jobRef));
    }
}
