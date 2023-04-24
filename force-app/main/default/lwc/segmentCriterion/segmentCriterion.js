import { LightningElement, api } from 'lwc';

export default class SegmentCriterion extends LightningElement {
	@api criterion;
	@api activeSections = [];

	toggleSection(e) {
        let currentsection = this.template.querySelector('.slds-section');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section slds-is-close';
        }
	}

}