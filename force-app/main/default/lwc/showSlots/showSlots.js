import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import USER_TIMEZONE from '@salesforce/i18n/timeZone';

//import { createRecord } from 'lightning/uiRecordApi';

const ITEM_CLASS = 'slds-item';
const DAY_SPACING_CLASS = 'slds-p-top_small';
const SELECTED_CLASS = 'selected';
const DOT = '.';
const VALIDATION_MESSAGE = 'Please select a slot.'

export default class ShowSlots extends LightningElement {

    @api error;

    @api startTime;
    @api endTime;

    @api slots = [];
    @track selectedSlot;

    showInGroupsOf = 5;
    numberToDisplay = this.showInGroupsOf;
    
    get selectedSlotIndex() {
        return this._selectedSlotIndex;
    }
    set selectedSlotIndex(value) {
        this._selectedSlotIndex = value;
        this.selectedSlot = value ? this.slots[value] : null;
    }
    _selectedSlotIndex;

    get displayedSlots() {
        return this.slots.slice(0, this.numberToDisplay);
    }

    get showAddSlots() {
        return this.displayedSlots.length < this.slots.length;
    }

    get userTimezone() {
        return USER_TIMEZONE;
    }

    @api
    validate() {
        if (this.selectedSlot) {
            return { isValid: true };
        } else {
            return { 
                isValid: false ,
                errorMessage: VALIDATION_MESSAGE
            };
        }
    }

    connectedCallback() {
        let tempSlots = [];
        for (let i=0; i<this.slots.length; i++) {
            let tempSlot = {
                index: i,
                firstInDay: i===0 || new Date(this.slots[i].start).getDate() !== new Date(this.slots[i-1].start).getDate(),
                get spaceClass() {
                     return this.firstInDay && i ? DAY_SPACING_CLASS : null
                }
            }
            tempSlots.push(Object.assign(tempSlot, this.slots[i]));
        }
        this.slots = tempSlots;
    }

    handleItemClick(event) {
        let index = event.currentTarget.dataset.index;
        if (this.selectedSlotIndex === index)
            this.selectedSlotIndex = null;
        else
            this.selectedSlotIndex = index;

        for (let item of this.template.querySelectorAll(DOT + ITEM_CLASS)) {
            if (item.dataset.index === this.selectedSlotIndex)
                item.classList.add(SELECTED_CLASS);
            else
                item.classList.remove(SELECTED_CLASS);
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('startTime', this.selectedSlot.start));
        this.dispatchEvent(new FlowAttributeChangeEvent('endTime', this.selectedSlot.finish));
    }

    showMoreSlots() {
        this.numberToDisplay += this.showInGroupsOf;
    }
}