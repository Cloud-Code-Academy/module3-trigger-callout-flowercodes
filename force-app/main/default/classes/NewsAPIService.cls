/**
 * Service class to interact with the NewsAPI for fetching top headlines
 */
public with sharing class NewsAPIService {
    // TODO: Define API endpoint constants
    private static final String API_NAMED_CREDENTIAL = 'callout:NewsAPI'; //https://newsapi.org
    private static final String API_ENDPOINT = '/v2/top-headlines';
    
    // TODO: Define default parameters
    private static final Integer DEFAULT_PAGE_SIZE = 20; 
    
    /**
     * Fetches top headlines for a specified category with pagination support
     * @param category The news category (business, entertainment, general, health, science, sports, technology)
     * @param pageSize Number of results per page (default: 20, max: 100)
     * @param page Page number for pagination
     * @return NewsAPIResponse The wrapper object containing the API response
     */
    public static NewsAPIResponse getTopHeadlinesByCategory(String category, Integer pageSize, Integer page) {
        // TODO: Implement method to fetch headlines by category
        // - Validate and set defaults for parameters
        // - Build the request URL
        // - Make the callout
        // - Parse and return the response
        Http h = new Http();
        String endpoint = (API_NAMED_CREDENTIAL + API_ENDPOINT + '?category=' + category 
        + '&pageSize=' + pageSize +
         '&page=' + page);

        HttpResponse res = NewsAPIService.makeCallout(endpoint);
        NewsAPIResponse parsedResponse = NewsAPIService.parseResponse(res.getBody());
        return parsedResponse;
    }
    
    /**
     * Helper method to make the HTTP callout
     * @param endpoint The full URL with parameters
     * @return HttpResponse The HTTP response
     */
    public static HttpResponse makeCallout(String endpoint) {
        // TODO: Implement HTTP callout
        // - Create and configure HTTP request
        // - Make the callout
        // - Handle exceptions
        Http h = new Http();

        HttpRequest req = new HTTPRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        if (res.getStatusCode() == 200) {
            System.debug(res.getBody());
            return res;
        } else {
            throw new NewsAPIException('Error fetching headlines: ' + res.getStatus());
        }
    }
    
    /**
     * Helper method to parse the JSON response
     * @param jsonResponse The JSON response string
     * @return NewsAPIResponse The parsed response object
     */
    private static NewsAPIResponse parseResponse(String jsonResponse) {
        // TODO: Implement JSON parsing
        // - Deserialize JSON to NewsAPIResponse
        // - Handle exceptions
        NewsAPIResponse response = (NewsAPIResponse) JSON.deserialize(jsonResponse, NewsAPIResponse.class);
        if (response != null) {
            return response;
        } else {
            throw new NewsAPIException('Error parsing response');
        }
    }
    
    /**
     * Custom exception class for NewsAPI errors
     */
    public class NewsAPIException extends Exception {}
} 