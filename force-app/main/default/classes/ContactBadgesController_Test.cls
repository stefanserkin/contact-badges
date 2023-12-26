/************************************************************************
 * @author SerkinSolutions
 * @date 2023
 ************************************************************************/
@IsTest
private class ContactBadgesController_Test {

    private static final String CONTACT_TITLE = 'Third Baseman';
    private static final String CONTACT_EMAIL = 'capn@mets.com';

    private static List<Contact_Badge_Definition__mdt> lstDefinitions = Contact_Badge_Definition__mdt.getAll().values();

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name='Wright Household');
        insert acc;

        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email=CONTACT_EMAIL, Birthdate=Date.today().addYears(-30), Title=CONTACT_TITLE);
        insert ct;
    }

    @IsTest
    static void testBadgesFromController() {
        ContactBadgesService.isTestScenario = true;

        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];
        
        Test.startTest();
        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = ContactBadgesController.getBadgeData(ct.Id, ct.AccountId);
        Test.stopTest();

        Boolean foundMetsBadge = false;
        Boolean foundBirthdayBadge = false;
        for (ContactBadgesService.BadgeDataWrapper badge : wrapperResult) {
            if (badge.label.contains(CONTACT_TITLE)) {
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

    @IsTest
    static void testBadInput() {
        ContactBadgesService.isTestScenario = true;
        ContactBadgesService.hasTransactionError = true;

        Contact ct = [SELECT Id, AccountId FROM Contact LIMIT 1];

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult;
        Boolean hasException = false;
        String exceptionMessage = '';
        Test.startTest();
        try {
            wrapperResult = ContactBadgesController.getBadgeData(ct.Id, ct.AccountId);
        } catch (Exception e) {
            System.debug(':::::: exception msg --> ' + e.getMessage());
            hasException = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(hasException, 'Should have received an exception');
        // System.assert(exceptionMessage.contains(ContactBadgesService.DEFAULT_EXCEPTION), 'Should have received the default exception');
    }
    
}