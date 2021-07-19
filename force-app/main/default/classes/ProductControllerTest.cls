@isTest
public with sharing class ProductControllerTest {
    @isTest
    public static void getProductTest(){
        List<Product2> ProductList = new List<Product2>();
        for(integer i = 1; i <= 5; i++)
        {
            Product2 p = new Product2();
            p.Name = 'Test Product ' + i;
            p.Description = 'Test Product Description';
            p.ProductCode = '0000' + i;
            ProductList.add(p);
        }
        insert ProductList;

        Product2 p = [select Id, Name from Product2 where Name = 'Test Product 1'];

        //Insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        insert standardPrice ;

        //Insert account
        Account acc = new Account();
        acc.Name = 'ChinolaCloud';
        acc.Rating = 'Hot';
        acc.Industry = 'Tecnology';
        acc.Phone = '8092345674';
        insert acc;

        //Insert Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        List<Product2> ResponseProductList = ProductController.getProducts(opp.Id, 'Test Product 1', 'Name', 'asc');
        System.assert(ResponseProductList.size() == 1);
        System.assert(ResponseProductList != null);
    }
}
