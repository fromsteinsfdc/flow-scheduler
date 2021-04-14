/*
Copyright 2021 David Fromstein
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
//import { createRecord } from 'lightning/uiRecordApi';

const ITEM_CLASS = 'slds-item';
const SELECTED_CLASS = 'selected';
const DOT = '.';

export default class ShowSlots extends LightningElement {

    @api startTime;
    @api endTime;

    @api slots = [];
    @track selectedSlot;
    showInGroupsOf = 10;
    
    get selectedSlotIndex() {
        return this._selectedSlotIndex;
    }
    set selectedSlotIndex(value) {
        this._selectedSlotIndex = value;
        this.selectedSlot = value ? this.slots[value] : null;
    }
    _selectedSlotIndex;

    @api
    validate() {
        if (this.selectedSlot) {
            return { isValid: true };
        } else {
            return { 
                isValid: false ,
                errorMessage: 'Please select a slot.'
            };
        }
    }

    connectedCallback() {
        console.log('slots = ' + JSON.stringify(this.slots));
        let tempSlots = [];
        for (let i=0; i<this.slots.length; i++) {
            tempSlots.push(Object.assign({index: i}, this.slots[i]));
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
        //this.dispatchEvent(new FlowAttributeChangeEvent('selectedSlot', this.selectedSlot));
        this.dispatchEvent(new FlowAttributeChangeEvent('startTime', this.selectedSlot.start));
        this.dispatchEvent(new FlowAttributeChangeEvent('endTime', this.selectedSlot.finish));
    }


}