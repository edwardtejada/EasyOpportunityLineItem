@isTest
public with sharing class ProductLineItemControllerTest {
    @isTest
    public static void getOpportunityLineItemTest(){
        //Insert product
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = '1234';
        p.isActive = true;
        insert p;

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

        //Insert OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;

        //Insert other Opportunity
        Opportunity opp2 = new Opportunity();
        opp2.AccountId = acc.Id;
        opp2.Name = 'Test Opportunity 2';
        opp2.CloseDate= System.Today();
        opp2.StageName='Prospecting';
        opp2.Pricebook2Id = Test.getStandardPricebookId();
        insert opp2;

        List<OpportunityLineItem> responseOppLineItemList = ProductLineItemController.getOpportunityLineItems(opp.Id);
        System.assert(responseOppLineItemList.size() == 1);
        System.assert(responseOppLineItemList.size() != null);
    }

    @isTest
    public static void getCountOpportunityLineItemTest(){
        //Insert product
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = '1234';
        p.isActive = true;
        insert p;

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

        //Insert OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;


        //Insert OpportunityLineItem 
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
        oppLineItem2.OpportunityId = opp.Id;
        oppLineItem2.PricebookEntryId = standardPrice.Id;
        oppLineItem2.UnitPrice = 50;
        oppLineItem2.Quantity = 10;
        insert oppLineItem2;

        integer countRecord = ProductLineItemController.getCountOpportunityLineItem(opp.Id);
        System.assert(countRecord == 2);
        System.assert(countRecord != 0);
    }
}
