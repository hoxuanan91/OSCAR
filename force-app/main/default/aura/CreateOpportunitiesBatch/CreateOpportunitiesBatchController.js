({
	doInit: function(component, event, helper) {
		helper.checkHierarchy(component);

		var recordTypes = [
			{ label: "LLD – Avenant", value: "avenant" },
			{ label: "LLD – Commande", value: "commande" },
			{ label: "LLD - Fleet", value: "fleet" }
		];
		component.set("v.recordTypes", recordTypes);
	},

	saveOpportunities: function(component, event, helper) {
		var data = component.get("v.data");
		var list = JSON.stringify(data);
		var recType = component.get("v.recType");
		var action = component.get("c.createOpportunities");

		component.set("v.HideSpinner", true);
		action.setParams({
			JsonOpps: list,
			recordType: recType
		});
		action.setCallback(this, function(data) {
			var state = data.getState();
			if (state === "SUCCESS") {
				helper.showToast(
					"Success!",
					"success",
					"Les enregistrements ont bien été créés."
				);
				$A.get("e.force:closeQuickAction").fire();
			} else if (state === "INCOMPLETE") {
				component.set("v.HideSpinner", false);
			} else if (state === "ERROR") {
				component.set("v.HideSpinner", false);
				var errors = data.getError();
				helper.parseError(errors, helper);
			}
		});
		$A.enqueueAction(action);
	},

	handleComponent: function(component, event, helper) {
		var recordId = component.get("v.recordId");
		var recType = component.get("v.recType");
		var accountName = component.get("v.accountName");
		var accountId = component.find("selectAccount").get("v.value");
		var accountList = component.get("v.childAccounts");
		var aveNumber = "";
		var aveType = "";
		var numAve = "";
		var comNumber = "";
		var comType = "";
		var numCommandes = "";
		var conPCD = "";
		var conPCR = "";
		var conPP = "";
		var conPC = "";
		var conPFC = "";
		var statMarge = "";
		var nombreFleet = "";
		var typologieFleet = "";

		for (var i = 0; i < accountList.length; i++) {
			if (accountList[i].Id == accountId) {
				accountName = accountList[i].Name;
			}
		}

		var oppName = component.find("opp").get("v.value");
		component.find("opp").set("v.value", "");

		if (recType != "fleet") {
			var vehNumber = component.find("veh").get("v.value");
			component.find("veh").set("v.value", "1");

			if (
				vehNumber == null ||
				vehNumber == undefined ||
				vehNumber == ""
			) {
				vehNumber = "1";
			}
		}

		if (recType === "avenant") {
			aveNumber = component.find("ave").get("v.value");
			component.find("ave").set("v.value", "");
			aveType = component.find("avenantType").get("v.value");
			component.find("avenantType").set("v.value", "");
			numAve = component.find("avenant").get("v.value");
			component.find("avenant").set("v.value", "");
			statMarge = JSON.stringify(
				component.find("statMarge").get("v.selectedOptions")
			);
		} else if (recType === "commande") {
			comNumber = component.find("com").get("v.value");
			component.find("com").set("v.value", "");
			comType = component.find("commandesType").get("v.value");
			component.find("commandesType").set("v.value", "");
			numCommandes = component.find("commandes").get("v.value");
			component.find("commandes").set("v.value", "");

			conPCD = JSON.stringify(
				component.find("conPCD").get("v.selectedOptions")
			);
			conPCR = JSON.stringify(
				component.find("conPCR").get("v.selectedOptions")
			);
			conPP = JSON.stringify(
				component.find("conPP").get("v.selectedOptions")
			);
			conPC = JSON.stringify(
				component.find("conPC").get("v.selectedOptions")
			);
		} else if (recType === "fleet") {
			nombreFleet = component.find("nombreFleet").get("v.value");
			typologieFleet = component.find("typologieFleet").get("v.value");

			conPFC = JSON.stringify(
				component.find("conPFC").get("v.selectedOptions")
			);
			conPP = JSON.stringify(
				component.find("conPP").get("v.selectedOptions")
			);
		}

		var item = {
			accountName: accountName,
			accountId: accountId,
			name: oppName,
			comNumber: comNumber,
			aveNumber: aveNumber,
			vehNumber: vehNumber,
			numCommandes: numCommandes,
			numAve: numAve,
			comType: comType,
			aveType: aveType,
			recType: recType,
			recordId: recordId,
			conPCD: conPCD,
			conPCR: conPCR,
			conPP: conPP,
			conPC: conPC,
			conPFC: conPFC,
			statMarge: statMarge,
			nombreFleet: nombreFleet,
			typologieFleet: typologieFleet
		};

		var data = component.get("v.data");
		data.push(item);
		component.set("v.data", data);
		component.set("v.canSave", true);
	},

	changeAccount: function(component, event, helper) {
		var acc = component.get("v.childAccounts")[component.get("v.Name")];
		var x = component.find("selectAccount").get("v.value");
	},

	handleRecordTypeChange: function(component, event, helper) {
		var recordType = event.getParam("value");
		if (recordType == "avenant") {
			component.set("v.recType", recordType);

			helper.getMultiPickField(
				component,
				"Statut_retour_marge__c",
				"v.statMarge"
			);
		} else if (recordType == "commande") {
			component.set("v.recType", recordType);

			// Get COM fields values
			helper.getMultiPickField(
				component,
				"Controle_pieces_client_COM__c",
				"v.conPCD"
			);
			helper.getMultiPickField(
				component,
				"Controle_des_pieces_client_reseau_COM__c",
				"v.conPCR"
			);
			helper.getMultiPickField(
				component,
				"Controle_pieces_prestations_COM__c",
				"v.conPP"
			);
			helper.getMultiPickField(
				component,
				"Controle_pieces_commande_COM__c",
				"v.conPC"
			);
		} else if (recordType == "fleet") {
			component.set("v.recType", recordType);

			// Get COM fields values
			helper.getMultiPickField(
				component,
				"ControlePiecesFleetCOM__c",
				"v.conPFC"
			);
			helper.getMultiPickField(
				component,
				"Controle_pieces_prestations_COM__c",
				"v.conPP"
			);
		}

		helper.initValues(component);
	},

	closeWindow: function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	removeElement: function(cmp, event) {
		var row = event.getParam("row");
		var rows = cmp.get("v.data");
		var rowIndex = rows.indexOf(row);

		rows.splice(rowIndex, 1);
		cmp.set("v.data", rows);
	}
});