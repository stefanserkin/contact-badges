@IsTest
private class ContactBadgesController_Test {

    private static List<Contact_Badge_Definition__mdt> lstDefinitions = Contact_Badge_Definition__mdt.getAll().values();

    @IsTest
    static void testBadgesFromController() {
        ContactBadgesService.isTestScenario = true;
        String strContactTitle = 'Third Basemen';

        Account acc = new Account(Name='Wright Household');
        insert acc;

        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email='capn@mets.com', Birthdate=Date.today(), Title=strContactTitle);
        insert ct;
        
        Test.startTest();
        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = ContactBadgesController.getBadgeData(ct.Id, acc.Id);
        Test.stopTest();

        Boolean foundMetsBadge = false;
        Boolean foundBirthdayBadge = false;
        for (ContactBadgesService.BadgeDataWrapper badge : wrapperResult) {
            if (badge.label.contains(strContactTitle)) {
                foundMetsBadge = true;
            }
            if (badge.label.toLowerCase().contains('birthday')) {
                foundBirthdayBadge = true;
            }
        }

        System.assert(!wrapperResult.isEmpty(), 'Did not find any badges for contact');
        System.assert(foundMetsBadge, 'Did not find Mets badge');
        System.assert(foundBirthdayBadge, 'Did not find birthday badge');
    }
    
}