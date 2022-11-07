import { LightningElement, api } from 'lwc';

export default class ScoringLineItem extends LightningElement {
	@api lineItem;
	@api objectType;
	OBJECT_TYPE_TO_FIELDS = {
		"Lead" : [{value: "Matched_Account_Technologies__c", label: "Technologies"},{value: "LeanData__Reporting_Matched_Account__r.Account_Tier__c", label: "Account Tier"},{value: "Country", label: "Country"},{value: "Normalized_Country__c", label: "Normalized Country"},{value: "Segment__r.Name", label: "Segment Name"},{value: "Email", label: "Email"},{value: "Industry", label: "Industry"},{value: "Title", label: "Title"}],
		"Contact" : [{value: "Technologies__c", label: "Technologies"},{value: "Account.Account_Tier__c", label: "Account Tier"},{value: "MailingCountry", label: "Country"},{value: "Email", label: "Email"},{value: "Industry", label: "Industry"},{value: "Title", label: "Title"}],
		"CampaignMember" : [{value: "Status", label: "Status"},{value: "Campaign.Type", label: "Campaign Type"}]
	};

	options = [{value: "=", label: "="},{value: "!=", label: "!="},{value: ">", label: ">"},{value: "<", label: "<"},{value: ">=", label: ">="},{value: "<=", label: "<="},{value: "startsWith", label: "startsWith"},{value: "doesNotStartWith", label: "doesNotStartWith"},{value: "contains", label: "contains"},{value: "doesNotContain", label: "doesNotContain"},{value: "IN", label: "IN"},{value: "isNull", label: "isNull"},{value: "isNotNull", label: "isNotNull"}];
	

	editLi(e) {
		console.log(JSON.stringify(this.lineItem));
		this.lineItem.field = this.template.querySelector(`[data-id="field"]`).value;
		this.lineItem.operator = this.template.querySelector(`[data-id="operator"]`).value;
		this.lineItem.operand = this.template.querySelector(`[data-id="operand"]`).value;
	}


	deleteLi(e) {
		const dataLiNum = e.currentTarget.dataset.id;
		const loadParentContainer = new CustomEvent(
	      'deleteli', 
	      {detail: dataLiNum}
	    );
	    this.dispatchEvent(loadParentContainer);
	}

	connectedCallback() {
		this.fields = this.OBJECT_TYPE_TO_FIELDS[this.objectType]; 
		// this.objectType === "Lead" ?
		// 	[{value: "Segment__r.Name", label: "Segment Name"},{value: "Email", label: "Email"},{value: "Industry", label: "Industry"},{value: "Title", label: "Title"}] :
		// 	[{value: "Status", label: "Status"},{value: "Type", label: "Campaign Type"}];
	}
}