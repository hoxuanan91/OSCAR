function networkError(message) {
    log.error(message);
}
function onIdentity(message) {
}
function onConnectedSession(message) {
    sfutil.updateConnectionLed("led-yellow", "Connection in standby ...");
}
function onDisconnectedSession(message) {
    sforce.console.presence.logout(function (res) { console.log(res); });
    $("#led").removeClass();
    $("#led").addClass("led-red");
    $(".led-msg p").text("Session disconnected");
}
function onActivateSession(message) {
    console.log("onActivateSession ", message);
    omniUtils.addListenTabs();
    if (iwscore.getLayoutParams().integrationType == "wde" || !iwscore.getLayoutParams().integrationType) {
        sfutil.updateConnectionLed("led-green", "Connection estabilished");
        sfutil.enableClickToDial();
        sfutil.addTabFocusListener();
    }
    iwscommand.NotReady(undefined);
}
function onPostActivateSession(message) {
}
function onDeactivateSession(message) {
}
function onChannelStatus(message) {
    console.log("onChannelStatus : ", message);
    if (message.Service == "PureCloud") {
        var status = message.attachdata ? message.attachdata.presence_status : undefined;
        if (status == "ON_QUEUE") {
            sforce.console.presence.login(LIVE_AGENT_AVAILABLE_ID, function (res) { console.log(res); });
        }
        else {
            sforce.console.presence.logout(function (res) { console.log(res); });
        }
    }
    if (message && message.state && message.state.state && message.name && message.name == 'workitem') {
        var state = message.state.state;
        if (state === 'READY') {
            sforce.console.presence.login(LIVE_AGENT_AVAILABLE_ID, function (res) { console.log(res); });
        }
        else {
            sforce.console.presence.logout(function (res) { console.log(res); });
        }
    }
}
function onEventAgentNotReady(message) {
    console.log("onEventAgentNotReady : ", message);
    sforce.console.presence.logout(function (res) { console.log(res); });
}
function onEventAgentNotReadyAfterCallWork(message) {
}
function onEventAgentReady(message) {
    console.log("onEventAgentReady : ", message);
    sforce.console.presence.login(LIVE_AGENT_AVAILABLE_ID, function (res) { console.log(res); });
}
function onEventAgentLogout(message) {
}
function onEventAgentLogin(message) {
}
function onEventRingingInbound(message) {
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
function onEventRingingInternal(message) {
}
function onEventRingingConsult(message) {
}
function onEventRingingOutbound(message) {
}
function onEventEstablishedInbound(message) {
    console.log("onEventEstablishedInbound , message : ", message);
    if (message.Service == "PureCloud") {
        sfutil.createTask(message, 'Phone', message.attachdata['context.phoneNumber'], message.ConnectionID);
    }
    else {
        sfutil.createTask(message, 'Phone', message.ANI, message.ConnectionID || message.callId);
    }
}
function onEventPartyChangedInbound(message) {
}
function onEventPartyChangedOutbound(message) {
}
function onEventEstablishedInternal(message) {
}
function onEventEstablishedConsult(message) {
}
function onEventEstablishedOutbound(message) {
}
function onEventHeldInbound(message) {
}
function onEventHeldInternal(message) {
}
function onEventHeldConsult(message) {
}
function onEventHeldOutbound(message) {
}
function onEventRetrievedInbound(message) {
}
function onEventRetrievedInternal(message) {
}
function onEventRetrievedConsult(message) {
}
function onEventRetrievedOutbound(message) {
}
function onEventAttachedDataChangedInbound(message) {
}
function onEventAttachedDataChangedInternal(message) {
}
function onEventAttachedDataChangedConsult(message) {
}
function onEventAttachedDataChangedOutbound(message) {
}
function onEventReleasedInbound(message) {
}
function onEventReleasedInternal(message) {
}
function onEventReleasedConsult(message) {
}
function onEventReleasedOutbound(message) {
}
function onEventDialingInternal(message) {
}
function onEventDialingConsult(message) {
}
function onEventDialingOutbound(message) {
}
function onChatEventRingingInbound(message) {
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
function onChatEventRingingConsult(message) {
}
function onChatEventEstablishedInbound(message) {
    console.log("onChatEventEstablishedInbound , message : ", message);
    if (message.Service == "PureCloud" || message.Service == "Wwe") {
        if (message.attachdata['context.WorkItemId']) {
            message.attachdata.WorkItemId = message.attachdata['context.WorkItemId'];
            message.attachdata.ServiceChannelId = message.attachdata['context.ServiceChannelId'];
            message.attachdata.QueueId = message.attachdata['context.QueueId'];
            message.attachdata.Id = message.attachdata['context.Id'];
            omniUtils.createAgentWork(message);
        }
        else {
            sfutil.createTask(message, 'Phone', message.attachdata['context.phoneNumber'], message.ConnectionID);
        }
    }
    else {
        sfutil.createTask(message, 'Email', message.attachdata.EmailAddress, message.ConnectionID);
    }
}
function onChatEventEstablishedConsult(message) {
}
function onChatEventReleasedInbound(message) {
}
function onChatEventReleasedConsult(message) {
}
function onChatEventMarkDoneInbound(message) {
    console.log("onChatEventMarkDoneInbound , message : ", message);
    if (message.attachdata['context.WorkItemId']) {
        omniUtils.closeTab(message.attachdata['context.WorkItemId'], undefined);
    }
}
function onEmailEventRingingInbound(message) {
}
function onEmailEventEstablishedInbound(message) {
}
function onEmailEventReleasedInbound(message) {
}
function onEmailEventReplyEstablishedOutbound(message) {
}
function onEmailEventReplyReleased(message) {
}
function onEmailEventReplyCancelled(message) {
}
function onEmailEventSessionInfo(message) {
}
function onDelegateCommand(message) {
    console.log("onDelegateCommand : ", message);
    if (iwscore.getLayoutParams().integrationType == "wde" || !iwscore.getLayoutParams().integrationType) {
        var interaction = iwscore.mapInteractions[message.ConnectionID.toLowerCase()];
        console.log("interaction :", interaction);
        var workItemId = interaction ? interaction.attachdata ? interaction.attachdata.WorkItemId : null : null;
        if (workItemId) {
            omniUtils.closeTab(workItemId, message.ID);
        }
        else {
            iwscommand.ExecuteDelegatedCommand(message.ID);
        }
    }
    else if (iwscore.getLayoutParams().integrationType == "wwe") {
        if (!message || !message.ChainName || !message.ID) {
            console.log("invalid message, returning ...");
            return;
        }
        switch (message.ChainName) {
            case 'InteractionBundleClose':
                var workItemId = message ? message.Parameters ? message.Parameters.mainInteraction ? message.Parameters.mainInteraction.userData ? message.Parameters.mainInteraction.userData.WorkItemId : null : null : null : null;
                if (workItemId) {
                    omniUtils.closeTab(workItemId, message.ID);
                }
                else {
                    iwscommand.ExecuteDelegatedCommand(message.ID);
                }
                break;
        }
    }
}
function onRegisterCommand(message) {
    console.log("onRegisterCommand : ", message);
    if (!message || !message.ChainName) {
        console.log("invalid message, returning ...");
        return;
    }
    switch (message.ChainName) {
        case 'AgentLogout':
            sforce.console.presence.logout(function (res) { console.log(res); });
            break;
    }
}
function onInhibitCommand(message) {
    log.debug("======= onInhibitCommand ==========");
    if (message.Parameters.Device) {
        log.debugFormat("Device Name: {0}", message.Parameters.Device.Name);
    }
}
function onWdeSwitchInteraction(message) {
    log.debug("Called onWdeSwitchInteraction: " + message);
    var user = sforce.connection.getUserInfo(undefined);
    var id = message.ConnectionID || message.InteractionID;
    var event = iwscore.getInteraction(id);
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
    omniUtils.createAgentWork(message);
}
function onWorkitemEventMarkDoneInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventReleasedInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventRingingInbound(message) {
    log.debug("Called onWorkitemEventRingingInbound: ");
    if (iwscore.getLayoutParams().integrationType == "wwe" || iwscore.getLayoutParams().integrationType == "pure-embeddable") {
        var callback = function (response) {
            if (response.success) {
                console.log('API method call executed successfully! returnValue:', response.returnValue);
            }
            else {
                console.error('Something went wrong! Errors:', response.errors);
            }
        };
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
