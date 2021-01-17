var Util = (function () {
    function Util() {
        this.mapDelegated = {};
        this.mapInteractions = {};
        this.arrayHistory = [];
        this.opportunityid = "";
		this.dateclick = Date.now();
    }
    Util.prototype.addTabFocusListener = function () {
        sforce.console.onFocusedPrimaryTab(function (listened) {
            console.log("change!", listened);
            sforce.console.getFocusedPrimaryTabId(function (focused) {
                console.log("change!", focused);
                if (focused && listened && focused.id == listened.id) {
                    for (var key in iwscore.mapInteractions) {
                        var ixn = iwscore.mapInteractions[key];
                        var id = (ixn && ixn.attachdata) ? ixn.attachdata.TASK_ID || ixn.attachdata.WorkItemId || ixn.attachdata['context.WorkItemId'] : undefined;
                        if (id && id == listened.objectId) {
                            iwscommand.InteractionSwitch(ixn.InteractionID || ixn.ConnectionID);
                        }
                    }
                }
            });
        });
    };
    Util.prototype.addNavigationChangeListener = function () {
        sforce.opencti.onNavigationChange({
            listener: function(payload) {
		var last = sfutil.arrayHistory[sfutil.arrayHistory.length - 1];
		if(last!=payload.objectType){
		    sfutil.arrayHistory.push(payload.objectType);
                    if(sfutil.arrayHistory.length>3){
			var shifted = sfutil.arrayHistory.shift();
                        if(shifted=="Opportunity"){
                            sfutil.opportunityid = "";
                            log.info('Objet ' + shifted + ' cleared');
                        }
                    }
	            if(payload.objectType=="Opportunity"){
                        sfutil.opportunityid = payload.recordId;
                        log.info('Objet ' + payload.objectType + '. Identifiant:'+payload.recordId);  
                    }
                }              
            }
        });
    };
    Util.prototype.enableClickToDial = function () {
        var callback = function (res) {
            log.info("click to dial response=" + JSON.stringify(res));
        };
        log.info("enabling click to dial");
        if (isLightning) {
            sforce.opencti.onClickToDial({
                listener: function (payload) {
                    log.info('Clicked phone number: ' + JSON.stringify(payload));
                    if (!payload || !payload.number) {
                        log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
                        return;
                    }
					
					var diff = Date.now() - sfutil.dateclick;
					if(diff<2000) {
					    log.warn("Cannot clic2call twice");
                        return;	
					}
					sfutil.dateclick = Date.now();
					
					var udata = iwscore.createUserData();
					udata.put("SOURCEAPP","Salesforce");
                    if(sfutil.opportunityid!="")
						udata.put("OPPORTUNITYID",sfutil.opportunityid);
                    iwscommand.MakeCall(payload.number, udata);
                }
            });
            sforce.opencti.enableClickToDial({ callback: callback });
        }
        else {
            log.info("setting onClickToDial");
            sforce.interaction.cti.onClickToDial(function (payload) {
                log.info('Clicked phone number: ' + JSON.stringify(payload));
                var result = JSON.parse(payload.result);
                if (!result || !result.number) {
                    log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
                    return;
                }
                log.info("Dialing phone number : " + result.number);
		var udata = iwscore.createUserData();
		udata.put("SOURCEAPP","Salesforce");
                if(sfutil.opportunityid!="")
		    udata.put("OPPORTUNITYID",sfutil.opportunityid);
                iwscommand.MakeCall(result.number, undefined);
            });
            sforce.interaction.cti.enableClickToDial(undefined);
        }
    };
    Util.prototype.createMyObject = function (event, field, id, subject) {
        var user = sforce.connection.getUserInfo(undefined);
        var obj = new sforce.SObject("MyObject__c");
        obj.OwnerId = user.userId;
        obj.name = subject;
        obj.MyObject_Interaction_ID__c = event.ConnectionID;
        obj.MyObject_MediaName__c = event.MediaType;
        console.log("obj:", obj);
        var q = "Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where {0} = \'{1}\'";
        var query = q.format(field, id);
        console.log("Executing query : ", query);
        var result = sforce.connection.query(query, undefined);
        var records = result.getArray("records");
        if (records && records.length == 1) {
        }
        sforce.connection.create([obj], function (res) {
            console.log("obj insert:");
            console.log(res);
            if (res && res.length > 0 && res[0].getBoolean("success")) {
                var params = iwscore.createUserData();
                params.put("TASK_ID", res[0].id);
                params.put("interactionId", event.ConnectionID);
                iwscommand.SetAttachdataById(event.InteractionID, params);
                console.log("isLightning=" + isLightning);
                console.log(typeof isLightning);
                if (isLightning) {
                    console.log("calling opencti");
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + res[0].id } });
                }
                else {
                    console.log("calling interaction");
                    sforce.interaction.screenPop('/' + res[0].id, true, function (res) {
                        console.log("screenpop result=", res);
                    });
                }
            }
        });
    };
    Util.prototype.checkTask = function (event, user) {
        console.log("checkTask, event:", event);
        if (!event.attachdata) {
            console.log("the event has no attachdata, returning");
            return;
        }
        var id = event.attachdata.TASK_ID || event.attachdata.WorkItemId || event.attachdata['context.WorkItemId'];
        if (id) {
			if (event.EVENT !== "EmailEventReplyReleased")
            {
                log.infoFormat("There is already an item associated to this interaction : {0}, opening it", id);
                if (isLightning) {
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id } });
                }
                else {
                    sforce.interaction.screenPop('/' + id, true, undefined);
                }     
            }  
            else
            {
                return false;
            }

            return true;
        }
        return false;
    };
    Util.prototype.createTask = function (event, field, id, subject) {
        var user = sforce.connection.getUserInfo(undefined);
        if (this.checkTask(event, user)) {
            return;
        }
        var task = new sforce.SObject("task");
        task.OwnerId = user.userId;
		
		if(event.MediaType=="email")
		{
			task.Subject = "Email";
		}
		else
		{
			task.Subject = "Appel";
		}		
       
        if(typeof event.EntrepriseInteractionCurrent !== 'undefined' && event.EntrepriseInteractionCurrent.InteractionType=="Outbound")
        {
            task.Subject = task.Subject+" sortant";
        }
        else if(typeof event.EntrepriseInteractionCurrent !== 'undefined' && event.EntrepriseInteractionCurrent.InteractionType=="Inbound")
        {
            task.Subject = task.Subject+" entrant";
        }        
		else
		{
			if(event.CallType=="Outbound")
			{
				task.Subject = task.Subject+" sortant";
			}
			else
			{
				task.Subject = task.Subject+" entrant";
			}
        }
        
        var d = new Date, dformat = [d.getFullYear(), d.getMonth(), d.getDate()].join('/') + '_' + [d.getHours(), d.getMinutes()].join(':');
		
		task.Subject = task.Subject+" - " + id + " - " + dformat;

        task.CallType = event.CallType;
		var q2 = "Select Id, Name From RecordType Where SobjectType = \'Task\' AND DeveloperName = \'LLD_Tache\'";
        console.log("Executing query : ", q2);
		var result2 = sforce.connection.query(q2);
		var records2 = result2.getArray("records");
		task.RecordTypeId = records2[0].Id;
        task.IWS_Interaction_ID__c = event.ConnectionID;
        task.IWS_Media_Name__c = event.MediaType;
        console.log("task:", task);

        var q3 = "Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND ( DeveloperName = \'LLD_Correspondant\' OR DeveloperName = \'LLD_Correspondant_Concessionnaire\' OR DeveloperName = \'CBIReseau\' )";
        console.log("Executing query : ", q3);
        var result3 = sforce.connection.query(q3);
		var records3 = result3.getArray("records");
		var contacttype1 = records3[0].Id;
		var contacttype2 = records3[1].Id;
		var contacttype3 = records3[2].Id;

        var q = "Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where {0} = \'{1}\' AND ( RecordTypeId = \'{2}\' OR RecordTypeId = \'{3}\' OR RecordTypeId = \'{4}\' )";
        var query = q.format(field, id, contacttype1, contacttype2, contacttype3);
        console.log("Executing query : ", query);
        var result = sforce.connection.query(query, undefined);
        var records = result.getArray("records");
        if (records && records.length == 1) {
            /* 
             * WORKAROUND
             * Attache la Task a l'objet courant ou le mail est envoye (voir wdeSendMailController.js) dans BccAdresses
             */
            if (event.attachdata.recordId === undefined) {
                console.log('@@EVENT PASSAGE1: ', records[0].Id);
                task.WhatId = records[0].Id;
            } else {
                console.log('@@EVENT PASSAGE2: ', event.attachdata.recordId);
             	task.WhatId = event.attachdata.recordId;
            }
        }
		else
		{
			if(field=="Phone")
			{
				console.log("Phone cannot be found. Try on MobilePhone");
				field = "MobilePhone";
				q = "Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where {0} = \'{1}\' AND ( RecordTypeId = \'{2}\' OR RecordTypeId = \'{3}\' OR RecordTypeId = \'{4}\' )";
				query = q.format(field, id, contacttype1, contacttype2, contacttype3);
				console.log("Executing query : ", query);
				result = sforce.connection.query(query, undefined);
				records = result.getArray("records");
				if (records && records.length == 1) {
					console.log("Task linked to contact ", records[0].Id);
					task.WhoId = records[0].Id;
				}
				else
				{
					console.log("Contact cannot be found. Try on Lead");
					q = "Select id from Lead where Phone = \'{1}\' OR MobilePhone = \'{1}\'";
					query = q.format(field, id);
					console.log("Executing query : ", query);
					result = sforce.connection.query(query, undefined);
					records = result.getArray("records");
					if (records && records.length == 1) {
						console.log("Task linked to contact ", records[0].Id);
						task.WhoId = records[0].Id;
					}
					else
					{
						console.log("token cannot be found ", field);
					}
				}
			}
			else
			{
				console.log("Contact cannot be found. Try on Lead");
				q = "Select id from Lead where Email = \'{1}\'";
				query = q.format(field, id);
				console.log("Executing query : ", query);
				result = sforce.connection.query(query, undefined);
				records = result.getArray("records");
				if (records && records.length == 1) {
					console.log("Task linked to contact ", records[0].Id);
					task.WhoId = records[0].Id;
				}
				else
				{
					console.log("token cannot be found ", field);
				}
			}
		}

        if (typeof event.attachdata.OPPORTUNITYID !== 'undefined')
	        task.WhatId = event.attachdata.OPPORTUNITYID;
	
	    if (typeof event.attachdata.Subject !== 'undefined')
	        task.Subject = task.Subject + " - " + event.attachdata.Subject;
		
		if (typeof event.EntrepriseInteractionCurrent !== 'undefined' && typeof event.EntrepriseInteractionCurrent.MessageText !== 'undefined')
        {
            task.Description = event.EntrepriseInteractionCurrent.MessageText
        }
		    //task.Email_Body__c = event.EntrepriseInteractionCurrent.MessageText;

		task.Status = "Ferm\u00e9e";

        sforce.connection.create([task], function (res) {
            console.log("task insert:");
            console.log(res);
            if (res && res.length > 0 && res[0].getBoolean("success")) {
                var params = iwscore.createUserData();
                params.put("TASK_ID", res[0].id);
                params.put("interactionId", event.ConnectionID);
                iwscommand.SetAttachdataByIdAndCustomerId(event.InteractionID, event.CustomerID, params);
                console.log("isLightning=" + isLightning);
                console.log(typeof isLightning);
                if (isLightning) {
                    console.log("calling opencti");
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + res[0].id } });
                }
                else {
                    console.log("calling interaction");
                    sforce.interaction.screenPop('/' + res[0].id, true, function (res) {
                        console.log("screenpop result=", res);
                    });
                }
            }
        });
    };
    Util.prototype.updateTaskDuration = function (event) {
        console.log("updateTaskDuration Event:");
        console.log(event);
        if (!event.Duration) {
            log.warn("The event has no duration, no update performed!");
            return;
        }
        var taskId = event.attachdata.TASK_ID;
        var task = new sforce.SObject("task");
        task.id = taskId;
        task.CallDurationInSeconds = parseInt(event.Duration);
        var result = sforce.connection.update([task], undefined);
        if (result[0].getBoolean("success")) {
            log.info("account with id " + result[0].id + " updated");
        }
        else {
            log.error("failed to update account " + result[0]);
        }
    };
    Util.prototype.listenPrimaryTabListener = function () {
        sforce.console.onFocusedPrimaryTab(function (res) {
            console.log(res);
        });
    };
    Util.prototype.updateConnectionLed = function (clazz, msg) {
        $("#led").removeClass();
        $("#led").addClass(clazz);
        $(".led-msg p").text(msg);
    };
    return Util;
}());
var sfutil = new Util();