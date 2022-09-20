import { LightningElement, api } from 'lwc';

export default class ScoringLineItem extends LightningElement {
	@api lineItem;
	@api objectType;

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
		this.fields = this.objectType === "Lead" ?
			[{value: "Segment__r.Name", label: "Segment Name"},{value: "Email", label: "Email"},{value: "Industry", label: "Industry"},{value: "Title", label: "Title"}] :
			[{value: "Status", label: "Status"},{value: "Type", label: "Campaign Type"}];
	}
}