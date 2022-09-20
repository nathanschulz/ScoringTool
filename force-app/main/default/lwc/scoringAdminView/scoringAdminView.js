import { LightningElement, api, wire } from 'lwc';
import getAdminView from '@salesforce/apex/ScoringAdminController.getAdminView';
import deleteAction from '@salesforce/apex/ScoringAdminController.deleteAction';
import {ConditionSet} from 'c/conditionModels';

export default class ScoringAdminView extends LightningElement {
	@api conditionSets;
	@api loaded = false;


	newConditionSet(e) {
		this.loaded = false;
		this.conditionSets.unshift( new ConditionSet() );
		this.loaded = true;
	}

	scrollToConditionSet(e) {
		e.preventDefault();
		const conditionKey = e.currentTarget.dataset.conditionkey;
		const target = this.template.querySelector(`[data-id="${conditionKey}"]`);
    	target.scrollIntoView({behavior: "smooth", block: "start", inline: "start"});
	}

	buildConditionSets(conditionSetObjects) {
		let conditionSets = [];
		for (let i = 0; i < conditionSetObjects.length; i++) {
			conditionSets.push(new ConditionSet(conditionSetObjects[i]));
		}
		return conditionSets;
	}

	deleteCondition(e) {
		this.loaded = false;
		const spliceKey = e.detail;
		let conditionSet;
		for (let i = 0; i < this.conditionSets.length; i++) {
			if (this.conditionSets[i].key === spliceKey) {
				conditionSet = this.conditionSets.splice(i, 1)[0];
				break;
			}
		}
		if (!!conditionSet.actionId) {
			deleteAction({actionId: conditionSet.actionId});
		}
		this.loaded = true;
	}

	@wire(getAdminView, {dTime: Date.now()})
	  initialize({error, data}) {
	  	if (data) {
			this.loaded = true;
			this.conditionSets = this.buildConditionSets(data.conditionSets);
	  	}  	
	  }

 	connectedCallback() {}

	//example records used for testing purposes
	sampleLineItem = {
		conditionNumber: 1, //used in scoringCondition.logicalStatement
		field: "Source", //legal fields determined by object type, which lives on condition
		operator: "=",
		operand: "Website",
		fieldType: "STRING",
		key: "Y"
	};

	sampleLineItem2 = {
		conditionNumber: 2, //used in scoringCondition.logicalStatement
		field: "Source", //legal fields determined by object type, which lives on condition
		operator: "=",
		operand: "Form Fill",
		fieldType: "STRING",
		key: "Z"
	};

	sampleCondition = {
		description: "Website Leads are Valuable",
		objectType: "Lead",
		positiveScore: true, //otherwise, subtract the value
		scoreValue: 20,
		scoreType: "fit", // fit or signal
		logicalStatement: "1 OR 2", //ties together conditions
		rpnLogic: "1", //computer-readable version of logicalStatement
		lineItems: [this.sampleLineItem, this.sampleLineItem2], //conjunction of
		key: "X" 
	};

	sampleCondition2 = {
		description: "Website Leads are Valuable",
		objectType: "Lead",
		positiveScore: true, //otherwise, subtract the value
		scoreValue: 20,
		scoreType: "fit", // fit or signal
		logicalStatement: "1 OR 2", //ties together conditions
		rpnLogic: "1", //computer-readable version of logicalStatement
		lineItems: [this.sampleLineItem, this.sampleLineItem2], //conjunction of
		key: "X" 
	};

	sampleCondition3 = {
		description: "Website Leads are Valuable",
		objectType: "Lead",
		positiveScore: true, //otherwise, subtract the value
		scoreValue: 20,
		scoreType: "fit", // fit or signal
		logicalStatement: "1", //ties together conditions
		rpnLogic: "1", //computer-readable version of logicalStatement
		lineItems: [this.sampleLineItem2], //conjunction of
		key: "X" 
	};

}