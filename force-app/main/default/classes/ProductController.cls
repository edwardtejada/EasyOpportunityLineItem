public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts( String searchKey, String sortBy, String sortDirection) 
    {
        String query = 'select Id, Name, ProductCode, Family from Product2';
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' WHERE Name LIKE :key or ProductCode LIKE :key';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        query += ' Limit 200 ';

        return Database.query(query);
    }
}
