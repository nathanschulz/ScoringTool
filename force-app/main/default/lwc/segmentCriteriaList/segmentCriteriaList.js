import { LightningElement, api, track } from 'lwc';

export default class SegmentCriteriaList extends LightningElement {
	@track segmentCriteria = [{key: "a"},{key: "b"},{key: "c"},{key: "d"}];
	@api startingPosition;

	drop(e) {
		console.log('dropping begins');
		e.stopPropagation();
		const dragVal = this.startingPosition;
		const dropVal = e.target.title;
		console.log('start index: ' + dragVal);
		console.log('stop index: ' + dropVal);
		if (dragVal === dropVal) {
			console.log('position unchanged');
			return false;
		}
		this.segmentCriteria.splice(dropVal, 0, this.segmentCriteria.splice(dragVal, 1)[0]);
	}

	dragStart(e) {
		console.log('drag started!');
		this.startingPosition = e.target.title;
	}

	dragOver(e) {
		e.preventDefault();
		return false;
	}

}