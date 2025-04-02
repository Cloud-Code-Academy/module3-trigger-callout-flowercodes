/**
 * Handler class for NewsCategoryTrigger
 */
public with sharing class NewsCategoryTriggerHandler {
    
    /**
     * Handles after insert events for News_Category__c
     * Uses Future method for callouts when Sync__c is true
     * @param newRecords List of newly inserted News_Category__c records
     */
    // TODO: Implement insert handler
        // - Filter categories that need to be synced
        // - Call future method for callouts
    public static void handleInsert(List<News_Category__c> newRecords) {
        List<String> categoryNames = new List<String>();
        List<News_Category__c> categoriesToUpdate = new List<News_Category__c>();

        for (News_Category__c category : newRecords) {
            if (category.Sync__c == true) {
                categoryNames.add(category.Name);
                categoriesToUpdate.add(new News_Category__c(
                    Id = category.Id,
                    Last_Synced__c = System.now(),
                    Sync__c = false
                ));
            }
        }
        if (!categoryNames.isEmpty()) {
            syncCategoriesWithFuture(categoryNames);
        }
        if (!categoriesToUpdate.isEmpty()) {
            update categoriesToUpdate;
        }
         }
    
    /**
     * Handles after update events for News_Category__c
     * Uses Queueable Apex for callouts when Sync__c is true
     * @param newRecords List of updated News_Category__c records
     * @param oldMap Map of old record states
     */
    public static void handleUpdate(List<News_Category__c> newRecords, Map<Id, News_Category__c> oldMap) {
        List<String> categoryNames = new List<String>(); 

        for(News_Category__c category : newRecords){
            if(category.Sync__c == true){
                categoryNames.add(category.Name);
            }
        }
        if(!categoryNames.isEmpty()) {
            syncCategoriesWithQueueable(newRecords);
        }
        // TODO: Implement update handler
        // - Filter categories that need to be synced
        // - Call queueable method for callouts
    }
    
    /**
     * Future method to sync categories using the NewsAPI
     * Used for insert operations
     * @param categoryNames List of category names to sync
     */
    @future(callout=true)
    public static void syncCategoriesWithFuture(List<String> categoryNames) {
        // TODO: Implement future method
        // - Get categories by name
        // - Make callouts to NewsAPI for each category
        // - Insert retrieved articles
        // - Update categories with last synced date
       
        List<News_Category__c> categoryRecords = [SELECT Id, Name FROM News_Category__c WHERE Name IN :categoryNames];
        List<News_Category__c> categoriesToUpdate = new List<News_Category__c>();
    
        Map<String, News_Category__c> categoryMap = new Map<String, News_Category__c>();
        for(News_Category__c category : categoryRecords){
            categoryMap.put(category.Name, category);
        }

        List<Article__c> articlesToInsert = new List<Article__c>();

        for(String categoryName : categoryNames){
            News_Category__c categoryRecord = categoryMap.get(categoryName);
            NewsApiResponse response = NewsAPIService.getTopHeadlinesByCategory(categoryName, 20, 1);
            for(NewsAPIResponse.Article article: response.articles){
                Article__c articleRecord = article.toSObject();
                articleRecord.News_Category__c = categoryRecord.Id;
                articleRecord.Category__c = categoryRecord.Name;
                
                articlesToInsert.add(articleRecord);
            }         
        }
        System.Debug('Articles to insert: ' + articlesToInsert);
        insert articlesToInsert;

        for(News_Category__c category : categoryRecords){
            category.Last_Synced__c = System.now();
            category.Sync__c = false;
        }
        update categoryRecords;
    }
    
    /**
     * Queueable method to sync categories using the NewsAPI
     * Used for update operations
     * @param categoriesToSync List of News_Category__c records to sync
     */
    private static void syncCategoriesWithQueueable(List<News_Category__c> categoriesToSync) {
        for (News_Category__c category : categoriesToSync) {
            Integer totalPages = (Integer)category.Pages__c;
            System.enqueueJob(new NewsCategoryQueueable(category.Id, category.Name, totalPages));
        }
        // TODO: Implement queueable job enqueuing
        // - Determine pages to sync for each category
        // - Create and enqueue NewsCategoryQueueable job for each category
    }
    
} 