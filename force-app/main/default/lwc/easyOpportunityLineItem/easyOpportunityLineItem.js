import { LightningElement, wire, api, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';
import getOpportunityLineItems from '@salesforce/apex/ProductLineItemController.getOpportunityLineItems';
import getCountOpportunityLineItem from '@salesforce/apex/ProductLineItemController.getCountOpportunityLineItem';
import { updateRecord, deleteRecord, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import OpportunityLineItem_OBJECT from "@salesforce/schema/OpportunityLineItem";

const COLUMNS_FOR_PRODUCT = [
    {label: 'Product Name', fieldName:'Name', sortable: true},
    {label: 'Product Code', fieldName:'ProductCode', sortable: true},
    {label: 'Product Family', fieldName:'Family', sortable: true},
    {
        label: 'Action',
        type: "button", 
        typeAttributes: {  
            label: 'Add',  
            name: 'Add',  
            title: 'Add',  
            disabled: false,  
            value: 'Add',  
            iconPosition: 'left'
        }
    }, 
];

const COLUMNS_FOR_PRODUCT_LINE_ITEM = [
    {
        label: 'Name',
        fieldName: 'Name',
        sortable: true
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'Currency',
        editable: true,
        sortable: true
    },
    {
        label: 'UnitPrice',
        fieldName: 'UnitPrice',
        type: 'Currency',
        editable: true,
        sortable: true
    },
    {
        label: 'ServiceDate',
        fieldName: 'ServiceDate',
        type: 'Date',
        sortable: true,
        editable: true
    },
    {
        label: 'Action',
        type: "button", 
        typeAttributes: {  
            label: 'Delete',  
            name: 'Delete',  
            title: 'Delete',  
            disabled: false,  
            value: 'delete',  
            iconPosition: 'left'
        }
    }  
];

export default class EasyOpportunityLineItem extends LightningElement {
    @api recordId;
    @track tableProductData = [];
    tableProductColumn = COLUMNS_FOR_PRODUCT;
    @track tableProductLineItemData;
    tableProductLineItemColumn = COLUMNS_FOR_PRODUCT_LINE_ITEM;
    saveDraftValues = [];

    @track tableProductDataShow = []; 
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    @track page = 1; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0;
    @track totalPage = 0;

    //get product data
    @wire(getProducts,  {opportunityId: '$recordId', searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'})
    ResponseFromGetProduct({error, data}){
        if(data){
            this.tableProductData = data;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.tableProductDataShow = this.tableProductData.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
        }
        else if(error){
            console.log(error);
        }
    }

    //previous button
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; 
            this.displayRecordPerPage(this.page);
        }
    }

    //next button
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; 
            this.displayRecordPerPage(this.page);            
        }             
    }

    //method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.tableProductDataShow = this.tableProductData.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    } 

    sortColumns(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return this.refresh();
    }

    handleKeyChange(event) {
        this.searchKey = event.target.value;
        return this.refresh();
    }

    //get product line item data
    @wire(getOpportunityLineItems, {opportunityId: '$recordId'})
    ResponseToGetOpportunityLineItemList(data) {
        this.tableProductLineItemData = data;
        if (data.error) {
            this.tableProductLineItemData = undefined;
        }
    }

    //save producto line item record
    handleSave(event) {
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'
                })
            );
            this.saveDraftValues = [];
            return this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An Error Occured!!',
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }

    //delete product line item record
    handleDelete(event) {
        const recordId = event.detail.row.Id; 
        const actionName = event.detail.action.name;
        if (actionName === 'Delete') 
        {  
            deleteRecord(recordId)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Opportunity Line Item deleted',
                            variant: 'success'
                        })
                    );
                    return refreshApex(this.tableProductLineItemData);
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An Error Occured!!',
                            variant: 'error'
                        })
                    );
                });  
        } 
    }

    //refresh product line item lightning-datatable
    async refresh() {
        await refreshApex(this.tableProductLineItemData);
    }


    //add product from product table to product line item
    rowMethod( event ) {     
        const productId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;  
        if (actionName === 'Add') 
        {  

            console.log('countOfRecord');
            getCountOpportunityLineItem({opportunityId: this.recordId})
                .then(countOfRecord => {
                    console.log(countOfRecord);
                    if((parseInt(countOfRecord) +  1) > 5)
                    {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error adding product line item",
                                message: 'You can\'t add more than 5 product',
                                variant: "error"
                            })
                        );

                        return;
                    }
                    else
                    {
                        this.SaveProductLineItem(productId);
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }
    } 
    

    SaveProductLineItem(productId)
    {
        const fields = {
            OpportunityId: this.recordId,
            Product2Id: productId,
            Quantity: 1,
            TotalPrice: 0
        };

        const recordInput = { apiName: OpportunityLineItem_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then((OpportunityLineItem) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record Created Successfully!!",
                        variant: "success"
                    })
                );

                this.fields = {};
                return this.refresh();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'An Error Occured!!',
                        variant: "error"
                    })
                );
            })
    }


}