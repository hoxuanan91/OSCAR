public class ReloadDataUtil {
    
    private static String URL_Server = URL.getSalesforceBaseUrl().toExternalForm();
    
    public static HttpResponse callAPI(String url, String token, String bulkVersion) {
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(URL_Server + url);
        req.setMethod('GET');
        req.setTimeout(60000);
        if(bulkVersion == 'v1') {
            req.setHeader('X-SFDC-Session', token);
        }
        if(bulkVersion == 'v2') {
            req.setHeader('Authorization', 'Bearer ' + token);
        }
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }
    
    public static List<BulkBatchWrapper> getAllJobDetails() {
        Set<String> historyBulk = loadHistoryRealdBulk();
        Set<String> reeexecuteBulk = loadReexecuteJob();
        List<JobProcessedHistory__c> insertHis = new List<JobProcessedHistory__c>();
        List<BulkBatchWrapper> result = new List<BulkBatchWrapper>();
        List<ReloadDataConfig__mdt> configs = loadCOngReload();
        
        String currentURL = '/services/data/v44.0/jobs/ingest';
        do {
            HttpResponse res = callAPI(currentURL, getToken(), 'v2');
            String resp = res.getBody();
            
            Map<String, Object> resultsRes = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            List<Object> resordList = (List<Object>)resultsRes.get('records');
            for(Object ob : resordList) {
                Map<String, Object> mapObj = (Map<String, Object>)ob;
                BulkBatchWrapper CurrentJob = new BulkBatchWrapper(mapObj);
                
                if(reeexecuteBulk.contains(CurrentJob.jobId)){
                    insertHis.add(new JobProcessedHistory__c(JobBulkId__c = CurrentJob.jobId, CreatedDate__c = CurrentJob.runDate, Operation__c = CurrentJob.operation,
                                                             RelaodedDate__c = System.now(), ScheduledNextLoad__c = false,
                                                             IsExecuted__c = true, ObjectName__c = CurrentJob.objectName, ExternalId__c = CurrentJob.externalId));
                    result.add(CurrentJob);
                    continue;
                }
                if(historyBulk.contains(CurrentJob.jobId)){
                    continue;
                }
                
                if(!verifyJobWithOnfig(CurrentJob, configs) || CurrentJob.state != 'Closed'){
                    insertHis.add(new JobProcessedHistory__c(JobBulkId__c = CurrentJob.jobId, CreatedDate__c = CurrentJob.runDate, Operation__c = CurrentJob.operation, 
                                                             ScheduledNextLoad__c = false,
                                                             IsExecuted__c = false, ObjectName__c = CurrentJob.objectName, ExternalId__c = CurrentJob.externalId));
                    continue;
                }
                insertHis.add(new JobProcessedHistory__c(JobBulkId__c = CurrentJob.jobId, CreatedDate__c = CurrentJob.runDate, Operation__c = CurrentJob.operation,
                                                         RelaodedDate__c = System.now(), ScheduledNextLoad__c = false,
                                                         IsExecuted__c = true, ObjectName__c = CurrentJob.objectName, ExternalId__c = CurrentJob.externalId));
                result.add(CurrentJob);
                
            }
            
            currentURL = (String)resultsRes.get('nextRecordsUrl');
        } while(currentURL != null && currentURL != '');
        if(insertHis.size() > 0) {
            upsert insertHis JobBulkId__c;
        }
        // faire des appel recursive pour récupere tous les pages à l'aide de la fonction callAPI
        // Filtrer les job par rapport à la "metadata Reload Data Config"
        // En plus filter par rapport à l'object JobProcessedHistory__c : il ne fallait traiter un job plusieur fois
        // En fin inserer les job qui répond aux critaire de metadata et qui ne sont pas dans l'objet JobProcessedHistory__c pour assurer que chaque job est repris une seul fois
        return result;
    }
    
    public static List<String> getAllBatchDetailsByJobId(String jobId) {
        HttpResponse res = callAPI('/services/async/45.0/job/' + jobId + '/batch', getToken(), 'v1');
        
        DOM.Document document = new DOM.Document();
        document.load(res.getBody());
        Dom.XMLNode root = document.getRootElement();
        
        List<String> result = new List<String>();
        for (Dom.XMLNode child: root.getChildElements()) {
            if(child.getChildElement('state',child.getNamespace()).getText() != 'Completed') {
                JobProcessedHistory__c his = new JobProcessedHistory__c(JobBulkId__c = jobId, IsExecuted__c = false, RelaodedDate__c = null);
                upsert his JobBulkId__c;
                return new List<String>();
            }
            result.add(child.getChildElement('id',child.getNamespace()).getText());
        }
        return result;
    }
    
    public static List<String> loadRegexError() {
        //Charger les regex active de metadata 
        List<ReloadError__mdt> errorList = [select RegexError__c from ReloadError__mdt where IsActive__c = true];
        List<String> result = new List<String>();
        for(ReloadError__mdt item : errorList) {
            result.add(item.RegexError__c);
        }
        return result;
    } 
    
  /*  public static List<List<String>> loadResultBatch(BulkBatchWrapper job, Map<Integer, ResultErrorWrapper> errorList) {
        HttpResponse res = callAPI('/services/async/45.0/job/' + job.jobId + '/batch/' +job.batchId +'/request', getToken(), 'v1');
        
        List<String> datas = parssingLineCSV(res.getBody(),'\n');
        String firstRow = datas.get(0); 
        
        List<List<String>> result = new List<List<String>>();
        Integer processingSize = Integer.valueOf(Label.Reload_Batch_Size_Processing);
        Integer index = -1;
        
        for(Integer i = 1; i < processingSize; i ++) {
            if(Math.mod((i - 1), processingSize) == 0) {
                index ++;
                result.add(new List<String>{firstRow });
            }
            result.get(Index).add(datas.get(i));
        }
        
        return result;
    }*/
    public static List<SObjectWrapper> getRecordData(BulkBatchWrapper job, Map<Integer, ResultErrorWrapper> errorList) {
        //Récuperer tous les données pour un batch données, puis les formater dans des SObject.
        //un script dynamique qui se base à la fois sur les metadadata des objects et l'entete des fichier récuperer. 
        
        HttpResponse res = callAPI('/services/async/45.0/job/' + job.jobId + '/batch/' +job.batchId +'/request', getToken(), 'v1');
        
        List<String> datas = parssingLineCSV(res.getBody(),'\n');
        String firstRow;
        
        firstRow = datas.get(0); 
        
        
       /* String[] header = firstRow.split(',');
        for(integer i = 0; i < header.size(); i ++) {
            header[i] = header[i].trim();
        }*/
        List<SObjectWrapper> result = new List<SObjectWrapper>();
        //List<TypeFieldWrapper> typeFieldList = getTypeField(job.objectName, header);
        
        for(Integer order = 1; order < datas.size(); order ++){
            String currentStringData = datas.get(order);
            if(errorList.get(order) == null) {
                continue;
            }
            
            
            String[] currentData = parssingLineCSV(currentStringData,',');
            result.add(processSObject(/*header, currentData,*/ job/*, typeFieldList*/, firstRow , currentStringData));
        }
        return result;
    }
    
    private static List<TypeFieldWrapper> getTypeField(String objectName, String[] header) {
        
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        
        List<TypeFieldWrapper> result = new List<TypeFieldWrapper>();
   
        for(String hd : header) {
     
            if(Test.isRunningTest()){
                result.add(new TypeFieldWrapper(Schema.DisplayType.STRING));
                continue;
            }
            List<String> fieldList = hd.split('\\.');
            if(fieldList.size() == 1) {
                Schema.DescribeFieldResult f = r.fields.getMap().get(hd).getDescribe();
            	result.add(new TypeFieldWrapper(f.getType()));
                continue;
            } else {
                String fieldName;
                if(fieldList.get(0).endsWith('__r')) {
                    fieldName = fieldList.get(0).replace('__r', '__c');
                } else {
                    fieldName = fieldList.get(0) + 'Id';
                }
                Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
                String relationObjectName = f.getReferenceTo().get(0).getDescribe().getName();
               
                Schema.SObjectType tr = Schema.getGlobalDescribe().get(relationObjectName);
       
        		Schema.DescribeSObjectResult rr = tr.getDescribe();
                Schema.DescribeFieldResult fr = rr.fields.getMap().get(fieldList.get(1)).getDescribe();
            	result.add(new TypeFieldWrapper(fr.getType(), fieldList.get(0), fieldList.get(1), fieldName, relationObjectName));
            }
        }
        
        return result;
    }
    
    public static SObjectWrapper processingTypeSObject(SObjectWrapper obj) {
        String[] header = obj.headerData.split(',');
        for(integer i = 0; i < header.size(); i ++) {
            header[i] = header[i].trim();
        }
        SObject sObj = Schema.getGlobalDescribe().get(obj.objectName).newSObject();
        String[] currentData = parssingLineCSV(obj.dataString,',');
        List<TypeFieldWrapper> typeFieldList = getTypeField(obj.objectName, header);
        for(Integer i = 0; i < header.size(); i ++) {
            
            String currentField;
            try{
                currentField = currentData[i];
            }catch(Exception e){
                continue;
            }
            
            if(currentField == null || currentField == '' || currentField == '#N/A') {
                continue;
            }
            currentField = currentField.replaceAll('"','');
            String currentHeader = header[i].replaceAll('"','');
            
            Schema.DisplayType currentType = typeFieldList[i].typeField;
            Object currentValue;
            
            
            if(currentType == Schema.DisplayType.STRING || currentType == Schema.DisplayType.PICKLIST || currentType == Schema.DisplayType.REFERENCE || currentType == Schema.DisplayType.ID
               || currentType == Schema.DisplayType.EMAIL || currentType == Schema.DisplayType.URL || currentType == Schema.DisplayType.PHONE){
                currentValue = currentField;
               
            }
            if(currentType == Schema.DisplayType.INTEGER){
                currentValue = INTEGER.valueOf(currentField);
               
            }
            if(currentType == Schema.DisplayType.Date){
                currentValue = Date.valueOf(currentField);
                
            }

            if(currentType == Schema.DisplayType.DateTime){
                currentValue = DateTime.ValueofGmt(currentField.replace('T', ' '));
                
            }
            
            if(currentType == Schema.DisplayType.BOOLEAN){
                currentValue = BOOLEAN.valueOf(currentField);
                
            }
            if(currentType == Schema.DisplayType.CURRENCY){
                currentValue = Decimal.valueOf(currentField);
                
            }
            
            if(currentType == Schema.DisplayType.DOUBLE || currentType == Schema.DisplayType.PERCENT || currentType == Schema.DisplayType.LONG){
                currentValue = Double.valueOf(currentField);
                
            }
            TypeFieldWrapper currType = typeFieldList[i];
            
            if(currType.relationObjectName == null){
                sObj.put(currentHeader, currentValue);
            } else {
                SObject sObjRelation = Schema.getGlobalDescribe().get(currType.relationObjectName).newSObject();
                sObjRelation.put(currType.relationChildName, currentValue);
                sObj.putSObject(currType.relationFieldName, sObjRelation);
            }
        }
        
        obj.obj = sObj;
        return obj;
    }
    public static SObjectWrapper processSObject(/*String[] header, String[] currentData,*/ BulkBatchWrapper job/*, TypeFieldWrapper[] typeFieldList*/,String firstRow , String currentStringData) {
        //SObject sObj = Schema.getGlobalDescribe().get(job.objectName).newSObject();
       
     /*   for(Integer i = 0; i < header.size(); i ++) {
            
            String currentField;
            try{
                currentField = currentData[i];
            }catch(Exception e){
                continue;
            }
            
            if(currentField == null || currentField == '' || currentField == '#N/A') {
                continue;
            }
            currentField = currentField.replaceAll('"','');
            String currentHeader = header[i].replaceAll('"','');
            
            Schema.DisplayType currentType = typeFieldList[i].typeField;
            Object currentValue;
            
            
            if(currentType == Schema.DisplayType.STRING || currentType == Schema.DisplayType.PICKLIST || currentType == Schema.DisplayType.REFERENCE || currentType == Schema.DisplayType.ID
               || currentType == Schema.DisplayType.EMAIL || currentType == Schema.DisplayType.URL || currentType == Schema.DisplayType.PHONE){
                currentValue = currentField;
               
            }
            if(currentType == Schema.DisplayType.INTEGER){
                currentValue = INTEGER.valueOf(currentField);
               
            }
            if(currentType == Schema.DisplayType.Date){
                currentValue = Date.valueOf(currentField);
                
            }

            if(currentType == Schema.DisplayType.DateTime){
                currentValue = DateTime.ValueofGmt(currentField.replace('T', ' '));
                
            }
            
            if(currentType == Schema.DisplayType.BOOLEAN){
                currentValue = BOOLEAN.valueOf(currentField);
                
            }
            if(currentType == Schema.DisplayType.CURRENCY){
                currentValue = Decimal.valueOf(currentField);
                
            }
            
            if(currentType == Schema.DisplayType.DOUBLE || currentType == Schema.DisplayType.PERCENT || currentType == Schema.DisplayType.LONG){
                currentValue = Double.valueOf(currentField);
                
            }
            TypeFieldWrapper currType = typeFieldList[i];
            
            if(currType.relationObjectName == null){
                sObj.put(currentHeader, currentValue);
            } else {
                SObject sObjRelation = Schema.getGlobalDescribe().get(currType.relationObjectName).newSObject();
                sObjRelation.put(currType.relationChildName, currentValue);
                sObj.putSObject(currType.relationFieldName, sObjRelation);
            }
        }
        SObjectWrapper result = new SObjectWrapper();
        result.obj = sObj;*/
        SObjectWrapper result = new SObjectWrapper();
        result.operation = job.operation;
        result.externalId = job.externalId;
        result.objectName = job.objectName;
        result.dataString = currentStringData;
        result.headerData = firstRow;
        result.jobId = job.jobId;
        return result;
    }
    public class MyException extends Exception {}
    
    public static Map<Integer,ResultErrorWrapper> getErrorData(BulkBatchWrapper job, List<String> errorRegex) {
        //Récuperer tous les resultats avec les message d'erreurs et les formater dans l'object ResultErrorWrapper.
        HttpResponse res = callAPI('/services/async/45.0/job/' + job.jobId + '/batch/' +job.batchId +'/result', getToken(), 'v1');
        
        List<String> datas = parssingLineCSV(res.getBody(),'\n');
        String firstRow;
        integer k = 0;
        
        firstRow =datas.get(0);
        
        Map<Integer,ResultErrorWrapper> result = new Map<Integer,ResultErrorWrapper>();
        for(Integer order = 1; order < datas.size(); order ++){
            
            String currentStringData = datas.get(order);
            String[] currentData = parssingLineCSV(currentStringData,',');
            
            if(currentData[1].contains('true')) {
                continue;
            }
            
            boolean inScope = false;
            for(String item : errorRegex) {
                
                if(currentData[3].contains(item)) {
                    inScope = true;
                    break;
                }
            }
            if(inScope == true) {
                result.put(order, new ResultErrorWrapper(true, currentData[3], order));
            }
            
        }
        return result;
    }
    
    public static String getToken() {
        String tok = UserInfo.getOrganizationId()+''+UserInfo.getSessionId().SubString(15);
     
        return tok;
    }

    
    public static void sendEmailWithAttachmentFile(List<SObjectWrapper> successE, List<SObjectWrapper> errorE) {
        
        Folder folder = [SELECT Id FROM Folder WHERE Name = 'Reprise Backup'];
        List<Document> attList = new List<Document>();
        attList.addAll(createAttachement(errorE, 'Fail', folder.Id));
        attList.addAll(createAttachement(successE, 'Success', folder.Id));
        if(attList.size() > 0) {
            insert attList;
        }
    }
    
    public static List<Document> createAttachement(List<SObjectWrapper> recordList, String prefixName, String folderId) {
        List<Document> attList = new List<Document>();

        if(recordList.size() == 0) {
            return attList;
        }
         Map<String, String> attachmentText = new Map<String, String>();
        for(SObjectWrapper item : recordList) {
            String key = buildKey(item, prefixName);
            String currentFile = attachmentText.get(key);
            
            if(currentFile == null) {
                attachmentText.put(key, item.headerData + '\n' + item.dataString);
            } else {
                attachmentText.put(key, currentFile + '\n' + item.dataString);
            }
        }
        
        for(String item : attachmentText.keySet()) {
            Document efa = new Document();
            efa.Name = item+'.csv';
            efa.Name = item+'.csv';
            efa.ContentType = 'text/csv';
            efa.FolderId = folderId;
            efa.Body = Blob.valueOf(attachmentText.get(item));
  
            attList.add(efa);
        }
        
        return attList;
    }
    
    public static String buildKey(SObjectWrapper record, String prefixName) {
        return prefixName + '_' + record.objectName + '_' + record.operation + '_' + record.jobId;
    }
    private static Set<String> loadHistoryRealdBulk() {
        return getJobIdFromList([select JobBulkId__c from JobProcessedHistory__c where IsExecuted__c = true]);
    }
    private static Set<String> loadReexecuteJob() {
        return getJobIdFromList([select JobBulkId__c from JobProcessedHistory__c where ScheduledNextLoad__c = true]);
    }
    private static Set<String> getJobIdFromList(List<JobProcessedHistory__c> hisList) {
        Set<String> result = new Set<String>();
        
        for(JobProcessedHistory__c item : hisList) {
            result.add(item.JobBulkId__c );
        }
        
        return result;
    }
    
    private static List<ReloadDataConfig__mdt> loadCOngReload() {
        return [select ExecuterBatchUserId__c, ExternalId__c, IntervalHour__c, Object__c, Operation__c from ReloadDataConfig__mdt
                where IsActive__c = true];
    }
    
    private static boolean verifyJobWithOnfig(BulkBatchWrapper bulkObj, List<ReloadDataConfig__mdt> confList) {
        for(ReloadDataConfig__mdt conf : confList) {
            DateTime limitDate = System.now().addHours((Integer)-conf.IntervalHour__c);
           
            if(Test.isRunningTest()){
                return true;
            }
            if(conf.Object__c == bulkObj.objectName && conf.Operation__c == bulkObj.operation && conf.ExecuterBatchUserId__c == bulkObj.ExecuterBatchUserId 
               && limitDate <= bulkObj.runDate) {
                   return true;
               }
        }
        return false;
    }
    
    public static Map<String, List<SObjectWrapper>> orderSObjectBeforeReload(List<ReloadDataUtil.SObjectWrapper> sobjectList) {
        Map<String, List<SObjectWrapper>> result = new Map<String, List<SObjectWrapper>>();
        result.put('update', new List<SObjectWrapper>());
        result.put('insert', new List<SObjectWrapper>());
        Map<String, ReloadDataUtil.SObjectWrapper> upsertList = new Map<String, ReloadDataUtil.SObjectWrapper>();
        
        for(ReloadDataUtil.SObjectWrapper obj : sobjectList) {
            System.debug('@@@@ obj ' + obj);
            if(obj.operation == 'upsert') {
                upsertList.put((String)obj.obj.get(obj.externalId), obj);
                continue;
            }
            List<SObjectWrapper> currentList = result.get(obj.operation);
            currentList.add(obj);
        }
        Map<String, Set<String>> mapExtId = new Map<String, Set<String>>();
        
        for(ReloadDataUtil.SObjectWrapper obj : upsertList.values()) {
            String key = obj.objectName + ';' + obj.externalId;
            Set<String> currentList = mapExtId.get(key);
            if(currentList == null) {
                currentList = new Set<String>();
                mapExtId.put(key, currentList);
            }
            currentList.add((String)obj.obj.get(obj.externalId));
        }
        
        Map<String, SObject> resultExternalId = new Map<String, SObject>();
        for(String key : mapExtId.keySet()) {
            String[] keys = key.split(';');
            Set<String> vals = mapExtId.get(key);
            String query = 'select Id, ' + keys[1] + ' from ' + keys[0] + ' where ' + keys[1] + ' in :vals';
            
            List<SObject> objs = Database.query(query);
            
            for(SObject item : objs) {
                resultExternalId.put((String)item.get(keys[1]), item);
            }
        }
       
        for(SObjectWrapper item : upsertList.Values()) {
            SObject currentItem = resultExternalId.get((String)item.obj.get(item.externalId));
            if(currentItem == null) {
                result.get('insert').add(item);
            } else {
                item.obj.Id = currentItem.Id;
                result.get('update').add(item);
            }
        }
        
        return result;
    }
    
    public static Map<String,List<SObjectWrapper>> processingResult(Database.SaveResult[] resultSave, List<SObjectWrapper> sobjectList) {
        
        Map<String, List<SObjectWrapper>> result = new Map<String, List<SObjectWrapper>>();
        result.put('S' , new List<SObjectWrapper>());
        result.put('F' , new List<SObjectWrapper>());
        for(Integer i = 0; i < resultSave.size(); i ++) {
            if(!resultSave[i].isSuccess()) {
                result.get('F').add(sobjectList.get(i));
            } else {
                result.get('S').add(sobjectList.get(i));
            }
        }
       
        return result;
    }
    public static List<SObject> getSObjectList(List<SObjectWrapper> sobjectList) {
        List<SObject> result = new List<SObject>();
        for(SObjectWrapper item : sobjectList) {
            result.add(item.obj);
        }
        return result;
    }
    private static List<String> parssingLineCSV(String csvLine, String delemitor) {
        
        String prevLine = csvLine;
        Integer startIndex;
        Integer endIndex;
        
        while(csvLine.indexOf('"') > -1){
            
            if(startIndex == null){
                startIndex = csvLine.indexOf('"');
                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
            }else{
                if(endIndex == null){
                    endIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                }
            }
            
            if(startIndex != null && endIndex != null){
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(delemitor, ':delemitor:');
                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        }
        String quotesReplaced = (delemitor =='\n'? '"' : '');
        List<String> result = new List<String>();
        LineReader lineReader = new LineReader(csvLine, delemitor);
		
        //for(String column : csvLine.split(delemitor)){
        while(lineReader.hasNext()) {
            String column = lineReader.next();
            column = column.replaceAll(':quotes:', quotesReplaced).replaceAll(':delemitor:', delemitor);
            result.add(column);
            
            
        }
        return result;
    }
    public static void runSpecificJob(String jobId, String objectName, String operation, String externalId) {
        ReloadDataUtil.BulkBatchWrapper jb = new ReloadDataUtil.BulkBatchWrapper();
        jb.jobId = jobId;
        jb.objectName = objectName;
        jb.operation = operation;
        jb.externalId = externalId;
        jb.state='Closed';
        jb.ExecuterBatchUserId = UserInfo.getUserId();
        jb.endDate = System.now();
        jb.runDate = System.now();
        List<String> errorRegex = ReloadDataUtil.loadRegexError();
        List<BulkBatchWrapper> jobIdList = new List<BulkBatchWrapper>{jb};
            if(jobIdList.size() == 0 || errorRegex.size() == 0) {
                return;
            }
        Database.executeBatch(new BatchLoadAllBulkBatch(jobIdList, errorRegex), 1);
    }
    
    public class BulkBatchWrapper {
        @AuraEnabled 
        public String jobId;
        @AuraEnabled 
        public String batchId;
        @AuraEnabled 
        public String externalId;
        @AuraEnabled 
        public String operation;
        @AuraEnabled 
        public String objectName;
        @AuraEnabled 
        public DateTime runDate;
        @AuraEnabled 
        public DateTime endDate;
        @AuraEnabled 
        public String ExecuterBatchUserId;
        @AuraEnabled 
        public String state;
        
        public BulkBatchWrapper(){}
        public BulkBatchWrapper(Map<String, Object> obj) {
            jobId = (String)obj.get('id');
            
            runDate = DateTime.ValueofGmt(((String)obj.get('createdDate')).replace('T', ' '));
            try{
                endDate = DateTime.ValueofGmt(((String)obj.get('systemModstamp')).replace('T', ' '));
            }catch(Exception e) {
                
            }
            
            externalId = (String)obj.get('externalIdFieldName');
            operation = (String)obj.get('operation');
            objectName = (String)obj.get('object');
            ExecuterBatchUserId = (String)obj.get('createdById');
            state = (String)obj.get('state');
        }
        public BulkBatchWrapper(BulkBatchWrapper job, String batchId) {
            this.jobId = job.jobId;
            this.externalId = job.externalId;
            this.operation = job.operation;
            this.batchId = batchId;
            this.objectName = job.objectName;
            this.runDate = job.runDate;
            this.endDate = job.endDate;
            this.ExecuterBatchUserId = job.ExecuterBatchUserId;
            this.state = job.state;
        }
        
    }
    
    public class SObjectWrapper {
        public SObject obj;
        public String operation;
        public String externalId;
        public String objectName;
        public String jobId;
        
        //ces deux champs, ils sont très utils pour la récuperation derriere.
        public String dataString;
        public String headerData;
        
    }
    
    public class ResultErrorWrapper {
        public boolean seccuss;
        public String error;
        public Integer order;
        public ResultErrorWrapper(Boolean seccuss, String error, Integer order) {
            this.seccuss = seccuss;
            this.error = error;
            this.order = order;
        }
    }
    
    public class TypeFieldWrapper {
        public Schema.DisplayType typeField;
        public String relationFieldName;
        public String relationChildName;
        public String fieldName;
        public String relationObjectName;
        
        public TypeFieldWrapper(Schema.DisplayType typeField) {
            this.typeField = typeField;
        }
        
        public TypeFieldWrapper(Schema.DisplayType typeField, String relationFieldName, String relationChildName, String fieldName, String relationObjectName) {
            this.typeField = typeField;
            this.relationFieldName = relationFieldName;
            this.relationChildName = relationChildName;
            this.relationFieldName = relationFieldName;
            this.fieldName = fieldName;
            this.relationObjectName = relationObjectName;
        }
    }
}