({
	showToast: function(title, type, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title: title,
			type: type,
			message: message
		});
		toastEvent.fire();
	},

	checkHierarchy: function(component) {
		var action = component.get("c.getAccounts");
		action.setParams({
			accId: component.get("v.recordId")
		});
		action.setCallback(this, function(data) {
			var state = data.getState();
			if (state === "SUCCESS") {
				var childAccounts = data.getReturnValue();
				if (childAccounts == null || childAccounts == undefined) {
					$A.get("e.force:closeQuickAction").fire();
					this.showToast(
						"Erreur !",
						"error",
						"Ce tiers n'est pas en haut de la hiérarchie !"
					);
				}
			} else if (state === "INCOMPLETE" || state === "ERROR") {
				var errors = data.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
						$A.get("e.force:closeQuickAction").fire();
						this.showToast("Erreur !", "error", errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},

	parseError: function(errors, helper) {
		if (errors) {
			if (errors && Array.isArray(errors) && errors.length > 0) {
				console.log("Error message: " + errors[0].message);
				helper.showToast("Erreur !", "error", errors[0].message);
			} else {
				helper.showToast(
					"Erreur !",
					"error",
					"Une erreur est survenue, vos enregistrements n'ont pas été créés."
				);
			}
		} else {
			helper.showToast("Error!", "error", "Unknown error");
			console.log("Unknown error");
		}
	},

	getMultiPickField: function(component, field, id) {
		var action = component.get("c.getMultiPicklistValues");

		action.setParams({
			field: field
		});

		action.setCallback(this, function(result) {
			var state = result.getState();
			if (state === "SUCCESS") {
				component.set(id, JSON.parse(result.getReturnValue()));
			}
		});
		$A.enqueueAction(action);
	},

	initValues: function(component) {
		var actions = [{ label: "Delete", name: "delete" }];
		var recordId = component.get("v.recordId");
		var recType = component.get("v.recType");

		var commandesTypes = [
			{ label: "Nouveau Client", value: "Nouveau Client" },
			{ label: "Extension de parc", value: "Extension de parc" },
			{ label: "Renouvellement", value: "Renouvellement" }
		];
		component.set("v.commandesTypes", commandesTypes);

		var avenantTypes = [
			{
				label: "Modification durée et/ou km",
				value: "Modification durée et/ou km"
			},
			{ label: "Prestation", value: "Prestation" },
			{ label: "Prolongation", value: "Prolongation" }
		];
		component.set("v.avenantTypes", avenantTypes);

		var typologieFleet = [
			{ label: "Assurance", value: "Assurance" },
			{ label: "Télépéage", value: "Télépéage" },
			{ label: "Carburant Shell", value: "Carburant Shell" },
			{ label: "Carburant Total", value: "Carburant Total" }
		];
		component.set("v.typologieFleet", typologieFleet);

		var columns = [
			{
				label: "Projet associé",
				fieldName: "name",
				type: "text",
				iconName: "standard:opportunity"
			},
			{
				label: "Tiers",
				fieldName: "accountName",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "N° Commande",
				fieldName: "comNumber",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "N° Avenant",
				fieldName: "aveNumber",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "Nb véhicules",
				fieldName: "vehNumber",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "N° commandes multi",
				fieldName: "numCommandes",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "N° avenants multi",
				fieldName: "numAve",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "Type commande",
				fieldName: "comType",
				type: "text",
				iconName: "standard:account"
			},
			{
				label: "Type avenant",
				fieldName: "aveType",
				type: "text",
				iconName: "standard:account"
			},
			{ type: "action", typeAttributes: { rowActions: actions } }
		];
		component.set("v.columns", columns);

		if (recType != "fleet") {
			component.find("veh").set("v.value", "1");
		}

		var action = component.get("c.getAccounts");
		action.setParams({
			accId: recordId
		});
		action.setCallback(this, function(data) {
			var state = data.getState();
			if (state === "SUCCESS") {
				var childAccounts = data.getReturnValue();
				if (childAccounts == null || childAccounts == undefined) {
					$A.get("e.force:closeQuickAction").fire();
					this.showToast(
						"Erreur !",
						"error",
						"Ce tiers n'est pas en haut de la hiérarchie !"
					);
				} else {
					component.set("v.childAccounts", childAccounts);

					window.setTimeout(
						$A.getCallback(function() {
							// Now set our preferred value
							component
								.find("selectAccount")
								.set("v.value", childAccounts[0].Id); //was childAccounts[0].id
						})
					);
				}
			} else if (state === "INCOMPLETE") {
			} else if (state === "ERROR") {
				var errors = data.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	}
});