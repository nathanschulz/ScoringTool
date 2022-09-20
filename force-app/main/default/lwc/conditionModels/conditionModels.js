
// const buildConditionSets = (conditionSetObjects) => {
// 	console.log('building condition sets');
// 	let conditionSets = [];
// 	for (let i = 0; i < conditionSetObjects.length; i++) {
// 		conditionSetObjects.push(new ConditionSet(conditionSetObjects[i]));
// 	}
// 	return conditionSets;
// }

class ConditionLineItem {
	constructor(lineItem) {
		if (lineItem) {
			this.ruleNumber = lineItem.Rule_Number__c;
			this.field = lineItem.Field__c;
			this.operator = lineItem.Operator__c;
			this.operand = lineItem.Operand__c;
			this.id = lineItem.Id;
		} else {
			this.ruleNumber = null;
			this.field = null;
			this.operator = null;
			this.operand = null;
		}
		this.key = this.generateKey();
	}



	generateKey() {
		return this.ruleNumber + "_" + Date.now();
	}
}

class ConditionSet {
	reverted() {
		return new ConditionSet(this.originalConditionSet);
	}

	constructor(conditionSet) {
		if (conditionSet) {
			this.originalConditionSet = conditionSet;
			this.description = conditionSet.Description__c;
			this.value = conditionSet.Action__r.Value__c;
			this.scoreType = conditionSet.Action__r.Score_Type__c;
			this.conditionDirection = conditionSet.Action__r.Positive__c ? 'Add' : 'Subtract';
			this.objectType = conditionSet.Object_Type__c;
			this.logicalStatement = conditionSet.Logical_Statement__c;
			this.active = conditionSet.Active__c;
			this.id = conditionSet.Id;
			this.actionId = conditionSet.Action__c;
			this.lineItems = [];
			this.key = this.generateKey();

			if (conditionSet.Condition_Set_Line_Items__r && conditionSet.Condition_Set_Line_Items__r.length) {
				for (let i = 0; i < conditionSet.Condition_Set_Line_Items__r.length; i++) {
					this.lineItems.push(new ConditionLineItem(conditionSet.Condition_Set_Line_Items__r[i]));
				}
			}
		} else {
			console.log('building');
			this.originalConditionSet = null;
			this.description = 'New Condition Set';
			this.value = 0;
			this.scoreType = 'fit';
			this.conditionDirection = 'Add';
			this.objectType = 'Lead';
			this.logicalStatement = '';
			this.active = false;
			this.id = null;
			this.actionId = null;
			this.lineItems = [];
			console.log('line items built');
			this.key = this.generateKey();
			console.log('key: ' + this.key);
		}
		console.log('condition set constructed');
	}

	generateKey() {
		// return this.id;
		return this.id + "_" + Date.now();
	}
}

// export{ buildConditionSets, ConditionLineItem, ConditionSet };
export{ ConditionLineItem, ConditionSet };