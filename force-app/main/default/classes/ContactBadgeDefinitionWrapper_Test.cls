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

    @IsTest
    static void testNullComparison() {
        List<Contact_Badge_Definition__mdt> lstUnsortedDefinitions =  new List<Contact_Badge_Definition__mdt>();
        Contact_Badge_Definition__mdt cbd1 = new Contact_Badge_Definition__mdt();
        cbd1.MasterLabel = 'Sort Order 1';
        cbd1.Active__c = true;
        cbd1.Sort_Order__c = 1;
        lstUnsortedDefinitions.add(cbd1);
        Contact_Badge_Definition__mdt cbd2 = new Contact_Badge_Definition__mdt();
        cbd2.MasterLabel = 'Sort Order Null';
        cbd2.Active__c = true;
        cbd2.Sort_Order__c = null;
        lstUnsortedDefinitions.add(cbd2);
        Contact_Badge_Definition__mdt cbd3 = new Contact_Badge_Definition__mdt();
        cbd3.MasterLabel = 'Sort Order 3';
        cbd3.Active__c = true;
        cbd3.Sort_Order__c = 3;
        lstUnsortedDefinitions.add(cbd3);

        List<Contact_Badge_Definition__mdt> lstSortedDefinitions;
        Test.startTest();
        lstSortedDefinitions = ContactBadgesHelper.sortContactBadgeDefinitions(
            lstUnsortedDefinitions
        );
        Test.stopTest();

        System.assertEquals('Sort Order 1', lstSortedDefinitions[0].MasterLabel, 'Should have received the first item');
        
    }

    @IsTest
    static void testFullReordering() {
        List<Contact_Badge_Definition__mdt> lstUnsortedDefinitions =  new List<Contact_Badge_Definition__mdt>();
        Contact_Badge_Definition__mdt cbd1 = new Contact_Badge_Definition__mdt();
        cbd1.MasterLabel = 'Sort Order 3';
        cbd1.Active__c = true;
        cbd1.Sort_Order__c = 3;
        lstUnsortedDefinitions.add(cbd1);
        Contact_Badge_Definition__mdt cbd2 = new Contact_Badge_Definition__mdt();
        cbd2.MasterLabel = 'Sort Order 1';
        cbd2.Active__c = true;
        cbd2.Sort_Order__c = 1;
        lstUnsortedDefinitions.add(cbd2);
        Contact_Badge_Definition__mdt cbd3 = new Contact_Badge_Definition__mdt();
        cbd3.MasterLabel = 'Sort Order 2';
        cbd3.Active__c = true;
        cbd3.Sort_Order__c = 2;
        lstUnsortedDefinitions.add(cbd3);

        List<Contact_Badge_Definition__mdt> lstSortedDefinitions;
        Test.startTest();
        lstSortedDefinitions = ContactBadgesHelper.sortContactBadgeDefinitions(
            lstUnsortedDefinitions
        );
        Test.stopTest();

        Decimal previousSortOrder = 0.00;
        for (Contact_Badge_Definition__mdt cbd : lstSortedDefinitions) {
            System.assert(cbd.Sort_Order__c >= previousSortOrder, 'Badge is incorrectly sorted');
            previousSortOrder = cbd.Sort_Order__c;
        }
        
    }

}