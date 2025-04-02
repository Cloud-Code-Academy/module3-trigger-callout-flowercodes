public with sharing class newsCategoryController {
    @AuraEnabled (cacheable = true)
    public static List<Article__c> getArticles() {
        return[SELECT Id, Name, Author__c, Category__c, Content__c, Country__c, Description__c, News_Category__c, Published_At__c, Source__c, Title__c, url__c, urlToImage__c FROM Article__c];
    }
}