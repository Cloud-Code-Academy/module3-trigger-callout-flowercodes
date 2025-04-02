/**
 * Wrapper class for parsing the NewsAPI response
 */
public class NewsAPIResponse {
    // TODO: Define fields to match the NewsAPI response structure
    public String status { get; set; }
    public Integer totalResults { get; set; }
    public List<Article> articles { get; set; }
    
    /**
     * Inner class representing a news article
     */
    public class Article {
        // TODO: Define article fields
        public string author;
        public string title;
        public string description;
        public string url;
        public string urlToImage;   
        public string publishedAt;
        public string content;
        public Source source;
        
        /**
         * Converts the API article to a Salesforce Article__c record
         * @return Article__c The Salesforce record
         */
        public Article__c toSObject() {
            // TODO: Implement conversion from API article to Salesforce record
            // Consider:
            // - Handling date conversion
            // - Generating a unique record name
            // - Handling field length limits
        String safeAuthor = this.author != null ? this.author : 'Unknown Author';
        String safeTitle = this.title != null ? this.title : 'No Title';
        String safeDescription = this.description != null ? this.description : 'No Description';
        String safeUrl = this.url != null ? this.url : '';
        String safeUrlToImage = this.urlToImage != null ? this.urlToImage : '';
        String safeContent = this.content != null ? this.content : 'No Content';
        String safeSource = (this.source != null && this.source.name != null) ? this.source.name : 'Unknown Source';
        String safePublishedAt = this.publishedAt != null ? this.publishedAt : '1970-01-01T00:00:00Z';
        String authorTruncated = safeAuthor.length() > 80 ? safeAuthor.substring(0, 80) : safeAuthor;
        String titleTruncated = safeTitle.length() > 80 ? safeTitle.substring(0, 80) : safeTitle;
        String urlToImageTruncated = safeUrlToImage.length() > 80 ? safeUrlToImage.substring(0, 80) : safeUrlToImage;
            
        Article__c articleRecord = new Article__c();
        articleRecord.Name = titleTruncated;
        articleRecord.Author__c = authorTruncated;
        articleRecord.Title__c = titleTruncated;
        articleRecord.Description__c = safeDescription;
        articleRecord.URL__c = safeUrl;
        articleRecord.URLToImage__c = urlToImageTruncated;
        articleRecord.Content__c = safeContent;
        articleRecord.Published_At__c = DateTime.valueOfGMT(this.publishedAt.replace('T',' ').replace('Z',''));
        articleRecord.Source__c = safeSource;    
            
        return articleRecord;
        }
    }
    
    /**
     * Inner class representing a news source
     */
    public class Source {
        // TODO: Define source fields
        String id;
        String name;
    }
    
    /**
     * Helper method to convert all articles in this response to Salesforce records
     * @return List<Article__c> List of Salesforce records
     */
    public List<Article__c> toSObjects() {
        // TODO: Implement conversion of all articles to Salesforce records
        List<Article__c> articles = new List<Article__c>();
        for(Article article : this.articles) {
            article.toSObject();
            articles.add(article.toSObject());
        }

        return articles;
    }
} 