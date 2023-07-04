import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getBadgeData from '@salesforce/apex/ContactBadgesController.getBadgeData';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Contact.AccountId';
import FIRST_NAME_FIELD from '@salesforce/schema/Contact.FirstName';

export default class ContactBadges extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    errorMessage;

    @track showModal = false;
    @track showBadgeDetails = false;
    @track alertMessages = [];
    @track modalContent;
    @api modalHeader;

    @track badgeData = [];
    @track wiredBadgeDataResult;
    @track badgeObj;
    @track badge;
    @track objType;
    @track fieldSetArray = [];
    @track label;

    accountId;
    firstName;

    @wire(getRecord, { 
        recordId : '$recordId', 
        fields : [ACCOUNT_ID_FIELD, FIRST_NAME_FIELD]
    }) wireContact({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.accountId = data.fields.AccountId.value;
            this.firstName = data.fields.FirstName.value;
        }
    }

    @wire(getBadgeData, { 
        recordId : '$recordId',
        accountId : '$accountId'
    }) wiredBadgeData(result) {
        this.wiredBadgeDataResult = result;
        if (result.data) {
            const badgeResults = result.data;
            this.badgeData = badgeResults;
            for (let i = 0; i < badgeResults.length; i++) {
                if (badgeResults[i].hasAlert) {
                    if (this.alertMessages.includes(badgeResults[i].alertMessage) === false) {
                        this.alertMessages.push(badgeResults[i].alertMessage);
                    }
                }
            }
            if (this.alertMessages.length > 0) {
                this.modalContent = this.alertMessages.join("\n");
                this.showModal = true;
            }
            this.error = undefined;
        } else if (result.error) {
            console.error(result.error);
            this.error = result.error;
            if (Array.isArray(this.error.body)) {
                this.errorMessage = this.error.body.map(e => e.message).join(', ');
            } else if (typeof this.error.body.message === 'string') {
                this.errorMessage = this.error.body.message;
            }
            this.badgeData = undefined;
        }
    }

    get displayBadges() {
        return this.badgeData != null && this.badgeData.length > 0 ? true : false;
    }

    handleBadgeClick(event) {
        const selectedBadgeData = event.currentTarget.dataset;
        this.badge = selectedBadgeData.badgeid;
        this.objType = selectedBadgeData.objtype;
        this.fieldSetArray = selectedBadgeData.fieldset.split(',');
        this.label = selectedBadgeData.label;
        this.showBadgeDetails = true;
    }

    handleModalClose() {
        this.showModal = false;
        this.showBadgeDetails = false;
    }

}