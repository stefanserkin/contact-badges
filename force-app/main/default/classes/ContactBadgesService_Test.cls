@isTest
private class ContactBadgesService_Test {

    private static List<Contact_Badge_Definition__mdt> lstDefinitions = Contact_Badge_Definition__mdt.getAll().values();
    private static final String CONTACT_TITLE = 'Third Baseman';

    @isTest
    static void testBadgeWithDynamicLabel() {
        ContactBadgesService.isTestScenario = true;

        Account acc = new Account(Name='Wright Household');
        insert acc;

        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email='capn@mets.com', Birthdate=Date.today(), Title=CONTACT_TITLE);
        insert ct;

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        
        Test.startTest();
        wrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, acc.Id);
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
        
        System.assert(wrapperResult.size() > 0, 'Did not find matching badge for contact');
        System.assert(foundMetsBadge, 'Did not find Mets badge');
        System.assert(foundBirthdayBadge, 'Did not find birthday badge');
        
    }

    @isTest
    static void testDuplicateBadgeLabels() {
        ContactBadgesService.isTestScenario = true;

        Account acc = new Account(Name='Wright Household');
        insert acc;

        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email='capn@mets.com', Birthdate=Date.today(), Title=CONTACT_TITLE);
        insert ct;

        List<Opportunity> lstOppys = new List<Opportunity>();
        Opportunity oppy  = new Opportunity(Name='Test Oppy', ContactId=ct.Id, AccountId=acc.Id, Amount=100000, StageName='Closed Won', CloseDate=Date.today().addDays(-1));
        Opportunity oppy2 = new Opportunity(Name='Test Oppy 2', ContactId=ct.Id, AccountId=acc.Id, Amount=100001, StageName='Closed Won', CloseDate=Date.today().addDays(-2));
        lstOppys.add(oppy);
        lstOppys.add(oppy2);
        insert lstOppys;

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        
        Test.startTest();
        wrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, acc.Id);
        Test.stopTest();

        System.assert(wrapperResult.size() > 0, 'Did not find matching badge for contact');

        for (ContactBadgesService.BadgeDataWrapper badge : wrapperResult) {
            if (badge.label == 'Major gift in last 30 days') {
                System.assertEquals(oppy.Id, badge.id, 'Received badge for incorrect opportunity');
            }
        }
                
    }
    
    @isTest
    static void testBadgeWithNoDefinedFieldSet() {
        ContactBadgesService.isTestScenario = true;

        Account acc = new Account(Name='Wright Household');
        insert acc;

        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email='capn@mets.com', Birthdate=Date.today(), Title=CONTACT_TITLE);
        insert ct;

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        
        Test.startTest();
        wrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, acc.Id);
        Test.stopTest();

        Boolean foundMetsBadge = false;
        Boolean foundBirthdayBadge = false;
        for (ContactBadgesService.BadgeDataWrapper badge : wrapperResult) {
            if (badge.label.contains(CONTACT_TITLE)) {
                foundMetsBadge = true;
            }
        }
        System.assert(foundMetsBadge, 'Did not find Mets badge');
        
    }

    
}