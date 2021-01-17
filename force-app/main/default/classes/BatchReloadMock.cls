@isTest
global class BatchReloadMock  implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if(request.getEndpoint().endswith('/services/data/v44.0/jobs/ingest')) {
            response.setBody('{"records": [{"id":"1","externalIdFieldName":"NEngagementV4__c", "systemModstamp":"2022-04-04T10:00:00.000+0000","createdDate":"2022-04-04T10:00:00.000+0000","state":"Closed","object":"Opportunity","operation":"upsert","createdById":"00520000003ucEcAAI"}]}');
        }
        if(request.getEndpoint().endswith('/batch')) {
            response.setBody('<?xml version="1.0" encoding="UTF-8"?><batchInfoList xmlns="http://www.force.com/2009/06/asyncapi/dataload"><batchInfo><id>2</id><state>Completed</state></batchInfo></batchInfoList>');
        }
        
        if(request.getEndpoint().endswith('/result')) {
             response.setBody('"Id","Success","Created","Error"\n"11","false","false","CANNOT_EXECUTE_FLOW_TRIGGER"');
        }
        
        if(request.getEndpoint().endswith('/request')) {
            response.setBody('"NEngagementV4__c"\n"123"');
        }
        return response;
    }
}