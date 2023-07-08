@IsTest
private class ContactBadgesHelper_Test {

    private static final String CONTACT_TITLE = 'Third Baseman';
    private static final String CONTACT_EMAIL = 'capn@mets.com';

    private static Contact_Badge_Definition__mdt birthdayBadgeDefinition = Contact_Badge_Definition__mdt.getInstance('Sample_Birthday_Badge');
    private static Contact_Badge_Definition__mdt metsBadgeDefinition     = Contact_Badge_Definition__mdt.getInstance('Sample_Mets_Badge');

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name='Wright Household');
        insert acc;

        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email=CONTACT_EMAIL, Birthdate=Date.today().addYears(-30), Title=CONTACT_TITLE);
        insert ct;
    }
    
    @IsTest
    static void testGetBadgeLabel() {
        Contact ct = [SELECT Id, Birthdate FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];
        
        Test.startTest();
        String badgeLabel = ContactBadgesHelper.getBadgeLabel(birthdayBadgeDefinition, ct);
        Test.stopTest();

        String expectedLabel = 'It\'s my birthday!';

        System.assert(badgeLabel.contains(expectedLabel), 'Unexpected label for birthday badge');
    }
    
    @IsTest
    static void testGetBadgeAlertMessage() {
        Contact ct = [SELECT Id, Birthdate FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];
        
        Test.startTest();
        String badgeAlertMessage = ContactBadgesHelper.getBadgeAlertMessage(birthdayBadgeDefinition, ct);
        Test.stopTest();

        String expectedMessage = 'It\'s my birthday!';

        System.assert(badgeAlertMessage.contains(expectedMessage), 'Unexpected alert message for birthday badge');
    }

    @IsTest
    static void testGetBadgeColorStyle() {
        Test.startTest();
        String badgeColorStyle = ContactBadgesHelper.getBadgeColorStyle(birthdayBadgeDefinition);
        Test.stopTest();

        String expectedString = '--sds-c-badge-color-background:#D3D3D3;';
        System.assertEquals(expectedString, badgeColorStyle, 'Unexpected string for badge color style');
    }

    @IsTest
    static void testGetBadgeLabelStyle() {
        Test.startTest();
        String badgeLabelStyle = ContactBadgesHelper.getBadgeLabelStyle(birthdayBadgeDefinition);
        Test.stopTest();

        String expectedString = '--sds-c-badge-text-color:#000000;--slds-c-badge-icon-color-foreground:#000000';
        System.assertEquals(expectedString, badgeLabelStyle, 'Unexpected string for badge label style');
    }

    @IsTest
    static void testGetBadgeIconName() {
        Test.startTest();
        String badgeIconName = ContactBadgesHelper.getBadgeIconName(birthdayBadgeDefinition);
        Test.stopTest();
        
        String expectedString = birthdayBadgeDefinition.Icon_Name__c;
        System.assertEquals(expectedString, badgeIconName, 'Unexpected string for icon name');
    }

    @IsTest
    static void testMergeFields() {
        Contact ct = [SELECT Id, Title FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];
        Test.startTest();
        String badgeLabel = ContactBadgesHelper.getBadgeLabel(metsBadgeDefinition, ct);
        Test.stopTest();

        System.assert(badgeLabel.contains(CONTACT_TITLE), 'Label should have the merged contact title value');
    }

}