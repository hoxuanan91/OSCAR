//>>CLICK2MAIL
var softphone_initialized = false;
//<<CLICK2MAIL
//
function networkError(message) {
    log.error(message);
}
function onIdentity(message) {console.log('onIdentity');
}
function onConnectedSession(message) {
    sfutil.updateConnectionLed("led-yellow", "Connection in standby ...");
}
function onDisconnectedSession(message) {
    $("#led").removeClass();
    $("#led").addClass("led-red");
    $(".led-msg p").text("Session disconnected");
}
function onActivateSession(message) {
    console.log("onActivateSession ", message);
    sfutil.updateConnectionLed("led-green", "Connection estabilished");
    //>>CLICK2MAIL
    if (softphone_initialized == true) {
        return;
    }
    //<<CLICK2MAIL
    sfutil.enableClickToDial();
    sfutil.addTabFocusListener();
    //>>CLICK2MAIL
    console.log('0**');
    onRegisterClickToEmail();
    console.log('1**');
    softphone_initialized = true;
    //<<CLICK2MAIL
    sfutil.addNavigationChangeListener();
}
function onPostActivateSession(message) {console.log('onPostActivateSession');
}
function onDeactivateSession(message) {console.log('onDeactivateSession');
}
function onChannelStatus(message) {
    console.log("onChannelStatus : ", message);
}
function onEventAgentNotReady(message) {
    console.log("onEventAgentNotReady : ", message);
}
function onEventAgentNotReadyAfterCallWork(message) {
}
function onEventAgentReady(message) {
    console.log("onEventAgentReady : ", message);
}
function onEventAgentLogout(message) {console.log('onEventAgentLogout');
}
function onEventAgentLogin(message) {console.log('onEventAgentLogin');
}
function onEventRingingInbound(message) {console.log('onEventRingingInbound');
    var callback = function (response) {
        if (response.success) {
            console.log('API method call executed successfully! returnValue:', response.returnValue);
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    if (iwscore.getLayoutParams().integrationType === 'wwe' || iwscore.getLayoutParams().integrationType === 'pure-embeddable') {
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
function onEventRingingInternal(message) {console.log('onEventRingingInternal');
}
function onEventRingingConsult(message) {console.log('onEventRingingConsult');
}
function onEventRingingOutbound(message) {console.log('onEventRingingOutbound');
}
function onEventEstablishedInbound(message) {
    console.log("onEventEstablishedInbound , message : ", message);
    sfutil.createTask(message, 'Phone', message.attachdata.UD_ANI, message.ConnectionID || message.callId);
}
function onEventPartyChangedInbound(message) {console.log('onEventPartyChangedInbound');
}
function onEventPartyChangedOutbound(message) {console.log('onEventPartyChangedOutbound');
}
function onEventEstablishedInternal(message) {console.log('onEventEstablishedInternal');
}
function onEventEstablishedConsult(message) {console.log('onEventEstablishedConsult');
}
function onEventEstablishedOutbound(message) {
    console.log("onEventEstablishedOutbound , message : ", message);
    sfutil.createTask(message, 'Phone', message.DNIS.replace("#*102", ""), message.ConnectionID || message.callId);

}
function onEventHeldInbound(message) {console.log('onEventHeldInbound');
}
function onEventHeldInternal(message) {console.log('onEventHeldInternal');
}
function onEventHeldConsult(message) {console.log('onEventHeldConsult');
}
function onEventHeldOutbound(message) {console.log('onEventHeldOutbound');
}
function onEventRetrievedInbound(message) {console.log('onEventRetrievedInbound');
}
function onEventRetrievedInternal(message) {console.log('onEventRetrievedInternal');
}
function onEventRetrievedConsult(message) {console.log('onEventRetrievedConsult');
}
function onEventRetrievedOutbound(message) {console.log('onEventRetrievedOutbound');
}
function onEventAttachedDataChangedInbound(message) {console.log('onEventAttachedDataChangedInbound');
}
function onEventAttachedDataChangedInternal(message) {console.log('onEventAttachedDataChangedInternal');
}
function onEventAttachedDataChangedConsult(message) {console.log('onEventAttachedDataChangedConsult');
}
function onEventAttachedDataChangedOutbound(message) {console.log('onEventAttachedDataChangedOutbound');
}
function onEventReleasedInbound(message) {
    console.log("onEventReleasedInbound , message : ", message);
    sfutil.updateTaskDuration(message);
}
function onEventReleasedInternal(message) {console.log('onEventReleasedInternal');
}
function onEventReleasedConsult(message) {console.log('onEventReleasedConsult');
}
function onEventReleasedOutbound(message) {
    console.log("onEventReleasedOutbound , message : ", message);
    sfutil.updateTaskDuration(message);
}
function onEventDialingInternal(message) {console.log('onEventDialingInternal');
}
function onEventDialingConsult(message) {console.log('onEventDialingConsult');
}
function onEventDialingOutbound(message) {console.log('onEventDialingOutbound');
}
function onChatEventRingingInbound(message) {console.log('onChatEventRingingInbound');
    var callback = function (response) {
        if (response.success) {
            console.log('API method call executed successfully! returnValue:', response.returnValue);
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    if (iwscore.getLayoutParams().integrationType === 'wwe' || iwscore.getLayoutParams().integrationType === 'pure-embeddable') {
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
function onChatEventRingingConsult(message) {console.log('onChatEventRingingConsult');
}
function onChatEventEstablishedInbound(message) {
    console.log("onChatEventEstablishedInbound , message : ", message);
    sfutil.createTask(message, 'Email', message.attachdata.EmailAddress, message.ConnectionID);
}
function onChatEventEstablishedConsult(message) {console.log('onChatEventEstablishedConsult');
}
function onChatEventReleasedInbound(message) {console.log('onChatEventReleasedInbound');
}
function onChatEventReleasedConsult(message) {console.log('onChatEventReleasedConsult');
}
function onChatEventMarkDoneInbound(message) {
    console.log("onChatEventMarkDoneInbound , message : ", message);
}
function onChatEventTranscriptLink(message) {console.log('onChatEventTranscriptLink');
}
function onChatEventPartyRemovedInbound(message) {console.log('onChatEventPartyRemovedInbound');
}
function onChatEventPartyAddedInbound(message) {console.log('onChatEventPartyAddedInbound');
}
function onChatEventPartyChangedInbound(message) {console.log('onChatEventPartyChangedInbound');
}
function onEmailEventRingingInbound(message) {console.log('onEmailEventRingingInbound');
}
function onEmailEventEstablishedInbound(message) {
    console.log("onEmailEventEstablishedInbound , message : ", message);
    sfutil.createTask(message, 'Email', message.attachdata.EmailAddress, message.ConnectionID);
}
function onEmailEventEstablishedOutbound(message) {console.log('onIdentity');
}
function onEmailEventOpenedInbound(message)
{
    console.log("onEmailEventOpenedInbound , message : ", message);
    sfutil.createTask(message, 'Email', message.attachdata.FromAddress, message.ConnectionID);
}
function onEmailEventOpenedOutbound(message)
{console.log('onEmailEventOpenedOutbound');
}
function onEmailEventReleasedOutbound(message)
{console.log('onEmailEventReleasedOutbound: ' + JSON.stringify(message));
}
function onEmailEventReleasedInbound(message) {console.log('onEmailEventReleasedInbound');
}
function onEmailEventReplyEstablishedOutbound(message) {console.log('onEmailEventReplyEstablishedOutbound');
}
function onEmailEventReplyReleased(message) {
        console.log("onEmailEventReplyReleased , message : ", message);    
	sfutil.createTask(message, 'Email', message.attachdata.To, message.ConnectionID);
}
function onEmailEventReplyCancelled(message) {console.log('onEmailEventReplyCancelled');
}
function onEmailEventSessionInfo(message) {console.log('onEmailEventSessionInfo');
}
function onDelegateCommand(message) {console.log('onDelegateCommand');
}
function onRegisterCommand(message) {console.log('onRegisterCommand');
}
function onInhibitCommand(message) {console.log('onInhibitCommand');
}
function onWdeSwitchInteraction(message) {
    console.log("Called onWdeSwitchInteraction: ", message);
    var user = sforce.connection.getUserInfo(undefined);
    var id = message.ConnectionID || message.InteractionID;
    if (!id) {
        console.log("interaction id null... returning");
        return;
    }
    var event = iwscore.mapInteractions[id.toLowerCase()];
    if (event && user) {
        sfutil.checkTask(event, user);
    }
}
function onSwitchInteractionInbound(message) {
    log.debug("Called onSwitchInteractionInbound ");
    onSwitchInteraction(message);
}
function onSwitchInteraction(message) {
    log.debug("Called onWdeSwitchInteraction: " + message);
    var user = sforce.connection.getUserInfo(undefined);
    sfutil.checkTask(message, user);
}
function onWorkitemEventEstablishedInbound(message) {
    log.debug("Called onWorkitemEventEstablishedInbound: ");
    console.log(message);
}
function onWorkitemEventMarkDoneInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventRingingInbound(message) {
    log.debug("Called onWorkitemEventRingingInbound: ");
}

//>>CLICK2MAIL
function onRegisterClickToEmail() {
    console.log("onRegisterClickToEmail");
    window.addEventListener("message", event => {
        console.log("event :! ", event);
        if (!event.data) {
            return;
        }
        console.log("data :! ", event.data);
        if (event.data.type == "clickToEmail") {
        var attachData = {'recordId':event.data.recordId};
            iwscommand.CreateNewOutboundEmail(event.data.email, "", "", "", "", attachData);
        }
    });

}

function onInteractionEmailSend(message) {
    console.log("onInteractionEmailSend , message : ", message);
	sfutil.createTask(message, 'Email', message.attachdata.To, message.ConnectionID);
}

//<<CLICK2MAIL