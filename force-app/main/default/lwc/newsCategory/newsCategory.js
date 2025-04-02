import { LightningElement, wire, track } from 'lwc';
import getArticles from '@salesforce/apex/newsCategoryController.getArticles';

const columns = [
    { label: 'Author', fieldName:'Author__c'},
    { label: 'Description', fieldName:'Description__c'},
    { label: 'Category', fieldName:'Category__c'},
    { 
        label: 'URL', 
        fieldName: 'url__c', 
        type: 'url', 
        typeAttributes: { 
            label: { fieldName: 'url__c' }, // This makes the URL text clickable
            target: '_blank' // Opens in a new tab
        }}
];

export default class NewsCategory extends LightningElement {
    columns = columns;
    data = [];

    columns = columns;
    @track data = [];
    @track filteredData = [];
    @track categoryOptions = [];
    selectedCategory = '';

    @wire(getArticles)
    wiredArticles({ error, data }) {
        if (data) {
            this.data = data;
            this.filteredData = data;

            // Get unique categories for the dropdown
            const categories = [...new Set(data.map(article => article.Category__c))];
            this.categoryOptions = [{ label: 'All', value: '' }, ...categories.map(cat => ({ label: cat, value: cat }))];
        } else if (error) {
            console.error('Error fetching articles:', error);
        }
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.target.value;
        this.filteredData = this.selectedCategory
            ? this.data.filter(article => article.Category__c === this.selectedCategory)
            : this.data;
    }
    
}