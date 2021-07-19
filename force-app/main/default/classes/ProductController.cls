public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(string opportunityId, String searchKey, String sortBy, String sortDirection) 
    {
        Opportunity opp = [select Id, Pricebook2Id from Opportunity where Id =: opportunityId Limit 1];
        List<PricebookEntry> pricebookEntryList = [select Id, Product2Id from PricebookEntry where Pricebook2Id =: opp.Pricebook2Id];
        Set<String> productIds = new Set<String>();														
        for (PricebookEntry  pricebookEntry : pricebookEntryList) {
            productIds.add(pricebookEntry.Product2Id); 
        }	
        String query = 'select Id, Name, ProductCode, Family from Product2 where Id IN : productIds ';
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' AND (Name LIKE :key or ProductCode LIKE :key)';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        query += ' Limit 200 ';

        return Database.query(query);
    }
}
