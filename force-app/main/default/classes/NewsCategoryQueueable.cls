/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {
    private Id categoryId;
    private String categoryName;
    private Integer pages;
    private Integer currentPage;
    
    /**
     * Constructor
     * @param categoryId The Id of the News_Category__c record
     * @param categoryName The category name
     * @param pages Total pages to sync
     */
    public NewsCategoryQueueable(Id categoryId, String categoryName, Integer pages) {
         // TODO: Initialize first page
        this(categoryId, categoryName, pages, 1);
    }
    
    /**
     * Constructor with current page
     * @param categoryId The Id of the News_Category__c record
     * @param categoryName The category name
     * @param pages Total pages to sync
     * @param currentPage Current page being processed
     */
    public NewsCategoryQueueable(Id categoryId, String categoryName, Integer pages, Integer currentPage) {
        // TODO: Initialize with specific page
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.pages = pages;
        this.currentPage = currentPage;
    }
    
    /**
     * Execute method for the queueable job
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {

        NewsAPIResponse response = NewsApiService.getTopHeadlinesByCategory(categoryName, 20, currentPage);

        List<Article__c> articlesToInsert = new List<Article__c>();
        List<Article__c> existingArticles = [SELECT Name FROM Article__c];
        Set<String> existingArticleNames = new Set<String>();

        //Extract Names into a Set for fast lookup
        for(Article__c existingArticle : existingArticles){
            if (existingArticle.Name != null){
                existingArticleNames.add(existingArticle.Name.toLowerCase());
            }

        }
        for(NewsAPIResponse.Article article : response.articles) {
            Article__c articleRecord = article.toSObject();

            //Only insert if existing article does not already exist
            if(!existingArticleNames.contains(articleRecord.Name.toLowerCase())){
                articleRecord.News_Category__c = categoryId;
                articleRecord.Category__c = categoryName;
                articlesToInsert.add(articleRecord);
             }
        }

        if(!articlesToInsert.isEmpty()) {
            insert articlesToInsert;
        }

        if (currentPage < pages) {  // Only enqueue if there are more pages
            System.enqueueJob(new NewsCategoryQueueable(categoryId, categoryName, pages, currentPage + 1));
        } else {
            News_Category__c category = new News_Category__c(
                Id = categoryId,
                Last_Synced__c = System.now(),
                Sync__c = false
            );
            update category;
        }
        // TODO: Implement execute method
        // - Call NewsAPI for the current page
        // - Process and save articles
        // - Update category if last page
        // - Chain to next page if more pages exist
        
    }
} 