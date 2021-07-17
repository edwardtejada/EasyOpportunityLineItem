public with sharing class ProductLineItemController {

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityLineItems(string opportunityId) {
        return [SELECT Id, Name, Quantity, UnitPrice, ServiceDate FROM OpportunityLineItem where OpportunityId =: opportunityId];
    }

    @AuraEnabled
    public static integer getCountOpportunityLineItem(string opportunityId) {
        integer counter = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId =: opportunityId];
        return counter;
    }
}
