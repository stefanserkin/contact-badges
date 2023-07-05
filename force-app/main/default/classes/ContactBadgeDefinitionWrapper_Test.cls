@IsTest
private class ContactBadgeDefinitionWrapper_Test {
    
    @IsTest
    static void testWrapperSorting() {
        ContactBadgesService.isTestScenario = true;
        
        List<Contact_Badge_Definition__mdt> lstDefinitions = Contact_Badge_Definition__mdt.getAll().values();
        List<Contact_Badge_Definition__mdt> lstSortedDefinitions = new List<Contact_Badge_Definition__mdt>();
        Test.startTest();
        ContactBadgeDefinitionWrapper[] lstCBDWrapper = new List<ContactBadgeDefinitionWrapper>();
        for (Contact_Badge_Definition__mdt definition : lstDefinitions) {
            lstCBDWrapper.add( new ContactBadgeDefinitionWrapper(definition) );
        }
        lstCBDWrapper.sort();
        for (ContactBadgeDefinitionWrapper cbdWrapper : lstCBDWrapper) {
            lstSortedDefinitions.add( cbdWrapper.cbd );
        }
        Test.stopTest();
        // Verify re-ordering by sort order
        Decimal lastSortOrder = 0;
        for (Contact_Badge_Definition__mdt sortedDefinition : lstSortedDefinitions) {
            System.assert(sortedDefinition.Sort_Order__c == null || sortedDefinition.Sort_Order__c >= lastSortOrder, 'Incorrect sort order');
            lastSortOrder = sortedDefinition.Sort_Order__c == null ? lastSortOrder : sortedDefinition.Sort_Order__c;
        }
    }

}