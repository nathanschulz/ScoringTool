import {refreshApex} from '@salesforce/apex';
import { LightningElement, api } from 'lwc';
import saveConditionSet from '@salesforce/apex/ScoringAdminController.saveConditionSet';
import { validateLi, validateConditionSet } from 'c/validationUtility';
import {ConditionLineItem} from 'c/conditionModels';
import LightningConfirm from "lightning/confirm";

export default class ScoringCondition extends LightningElement {
	@api conditionSet;
	@api lineItems;
	@api conditionReady = false;
	objectTypes = [{value: "Lead", label: "If Lead Meets Condition"},{value: "CampaignMember", label: "For Each Campaign Member Meeting Condition"}];
	directionChoices = [{value: "Add", label: "Add"},{value: "Subtract", label: "Subtract"}];
	scoreTypes = [{value: "fit", label: "fit"},{value:"engagement", label: "engagement"}];
	loading = false;

	saveCondition(e) {
		this.loading = true;
		let that = this;
		saveConditionSet({conditionSetMap: this.conditionSet})
			.then(result => {
				that.loading = false;
			})
			.catch(error => {
				that.loading = false;
			});
	}

	get disableSaveButton() {
		return !validateConditionSet(this.conditionSet);
	}

	get revertEnabled() {
		return true;
	}

	deleteCondition(e) {
		console.log('deleting condition');
		const loadParentContainer = new CustomEvent(
	      'deletecondition', 
	      {detail: this.conditionSet.key}
	    );
	    this.dispatchEvent(loadParentContainer);
	}

	async promptDeleteConfirmation(e) {
		const proceedWithDeletion = await LightningConfirm.open({
	      message: "Are you sure you'd like to delete this Condition Set?",
	      theme: "success",
	      label: "Confirm Delete"
	    });
	    if (proceedWithDeletion) {
	    	this.deleteCondition();
	    }
	}

	updateCondition() {

	}

	newLineItem(previousLength) {
		const newLi = new ConditionLineItem();
		newLi.ruleNumber = previousLength + 1;
		return newLi;
	}

	editCondition(e) {
		console.log('in');
		this.conditionSet.description = this.template.querySelector(`[data-id="description"]`).value;
		this.conditionSet.objectType = this.template.querySelector(`[data-id="objectType"]`).value;
		this.conditionSet.conditionDirection = this.template.querySelector(`[data-id="conditionDirection"]`).value;
		this.conditionSet.value = this.template.querySelector(`[data-id="value"]`).value;
		this.conditionSet.scoreType = this.template.querySelector(`[data-id="scoreType"]`).value;
		this.conditionSet.active = this.template.querySelector(`[data-id="active"]`).checked;
		this.conditionSet.objectType = this.template.querySelector(`[data-id="objectType"]`).value;
		this.conditionSet.logicalStatement = this.template.querySelector(`[data-id="logicalStatement"]`).value;
		console.log(JSON.stringify(this.conditionSet));
	}


	addLineItem(e) {
		const lineItemLength = this.lineItems.length;
		const newLi = this.newLineItem(lineItemLength);
		this.conditionSet.lineItems.push(newLi);
		this.lineItems = this.conditionSet.lineItems;
	}

	refreshForm() {
		this.template.querySelector(`[data-id="description"]`).value = this.conditionSet.description;
		this.template.querySelector(`[data-id="objectType"]`).value = this.conditionSet.objectType;
		this.template.querySelector(`[data-id="conditionDirection"]`).value = this.conditionSet.conditionDirection;
		this.template.querySelector(`[data-id="value"]`).value = this.conditionSet.value;
		this.template.querySelector(`[data-id="scoreType"]`).value = this.conditionSet.scoreType;
		this.template.querySelector(`[data-id="active"]`).checked = this.conditionSet.active;
		this.template.querySelector(`[data-id="objectType"]`).value = this.conditionSet.objectType;
		this.template.querySelector(`[data-id="logicalStatement"]`).value = this.conditionSet.logicalStatement;
	}

	revertCondition(e) {
		this.conditionSet = this.conditionSet.reverted();
		this.lineItems = this.conditionSet.lineItems;
		this.refreshForm();
	}


	deleteLi(e) {
		this.conditionReady = false;
		const spliceIndex = e.detail;
		let li = this.lineItems.splice(spliceIndex - 1,1);
		console.log(JSON.stringify(li));
		console.log(li[0].id);
		for (let i = 0; i < this.lineItems.length; i++) {
			this.lineItems[i].ruleNumber = i + 1;
		}

		this.conditionReady = true;
	}

	connectedCallback() {
		if (!!this.conditionSet) {
			this.lineItems = this.conditionSet.lineItems
			this.conditionReady = true;
		}
	}
}