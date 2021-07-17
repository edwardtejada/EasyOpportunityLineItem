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

        List<Product2> ResponseProductList = ProductController.getProducts('Test Product 1', 'Name', 'asc');
        System.assert(ResponseProductList.size() == 1);
        System.assert(ResponseProductList != null);
    }
}
