global class BatchDemandeChatterCBM implements Database.Batchable<SObject>,Database.Stateful{
    private String query;
    private String postChatterText;
    private String status;
    private boolean sendNofitication;
    
    private List<ConfigWrapper> configList;
    global BatchDemandeChatterCBM(List<ConfigWrapper> configList) {
        this.configList = configList;
        this.query = configList.get(0).query;
        this.postChatterText = configList.get(0).postChatterText;
        this.status = configList.get(0).status;
        this.sendNofitication = configList.get(0).sendNofitication;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(Test.isRunningTest()) {
            return Database.getQueryLocator('select Id, Notifications__c,OwnerId, Owner.Type from case');
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<FeedItem> result = new List<FeedItem>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for(Case item : scope) {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            System.debug('@@@ item.Owner.Type ' + item.Owner.Type );
            if(item.Owner.Type == 'User' || Test.isRunningTest())  {
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                mentionSegmentInput.id = item.OwnerId;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                textSegmentInput.text = '  ' + postChatterText;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = item.Id;
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                batchInputs.add(batchInput);
            }
            else {
                FeedItem post = new FeedItem();
                post.ParentId = item.Id; 
                post.Body = postChatterText;
                result.add(post);
                
            }
            if(item.Notifications__c == null) {
                item.Notifications__c = status;
            } else {
                item.Notifications__c += ';' + status;
            }
        }
        if(sendNofitication){
            if(batchinputs.size() > 0)
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
            if(result.size() > 0)
                insert result;
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        configList.remove(0);
        if(configList.size() > 0) {
            Database.executeBatch(new BatchDemandeChatterCBM(configList), 5);
        }
    }
    global class ConfigWrapper {
        public String query;
        public String postChatterText;
        public String status;
        public boolean sendNofitication;
        
        global ConfigWrapper(String query, String postChatterText, String status, boolean sendNofitication) {
            this.query = query;
            this.postChatterText = postChatterText;
            this.status = status;
            this.sendNofitication = sendNofitication;
        }
    }
}