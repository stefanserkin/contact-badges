@IsTest
private class ContactBadgesService_Test {

    private static List<Contact_Badge_Definition__mdt> lstDefinitions = Contact_Badge_Definition__mdt.getAll().values();
    private static final String CONTACT_TITLE = 'Third Baseman';
    private static final String CONTACT_EMAIL = 'capn@mets.com';

    private static Integer fakeIdNumber = 1;

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name='Wright Household');
        insert acc;
        Contact ct = new Contact(AccountId=acc.Id, FirstName='David', LastName='Wright', Email=CONTACT_EMAIL, Birthdate=Date.today(), Title=CONTACT_TITLE);
        insert ct;
    }

    @IsTest
    static void testBadgeWithDynamicLabel() {
        ContactBadgesService.isTestScenario = true;

        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        
        Test.startTest();
        wrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, ct.AccountId);
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

    @IsTest
    static void testDuplicateBadgeLabels() {
        ContactBadgesService.isTestScenario = true;

        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];

        List<Opportunity> lstOppys = new List<Opportunity>();
        Opportunity oppy  = new Opportunity(Name='Test Oppy', ContactId=ct.Id, AccountId=ct.AccountId, Amount=100000, StageName='Closed Won', CloseDate=Date.today().addDays(-1));
        Opportunity oppy2 = new Opportunity(Name='Test Oppy 2', ContactId=ct.Id, AccountId=ct.AccountId, Amount=100001, StageName='Closed Won', CloseDate=Date.today().addDays(-2));
        lstOppys.add(oppy);
        lstOppys.add(oppy2);
        insert lstOppys;

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        
        Test.startTest();
        wrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, ct.AccountId);
        Test.stopTest();

        System.assert(wrapperResult.size() > 0, 'Did not find matching badge for contact');

        Set<String> setLabels = new Set<String>();
        for (ContactBadgesService.BadgeDataWrapper badge : wrapperResult) {
            Assert.isFalse(setLabels.contains(badge.label), 'Should not have duplicate badge labels');
            setLabels.add(badge.label);
        }

    }
    
    @IsTest
    static void testBadgeWithNoDefinedFieldSet() {
        ContactBadgesService.isTestScenario = true;

        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        
        Test.startTest();
        wrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, ct.AccountId);
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

    @IsTest
    static void testCachedBadgeAlerts() {
        ContactBadgesService.isTestScenario = true;

        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];

        List<ContactBadgesService.BadgeDataWrapper> originalWrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        originalWrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, ct.AccountId);
        for (ContactBadgesService.BadgeDataWrapper badge : originalWrapperResult) {
            if (badge.label.contains(CONTACT_TITLE)) {
                System.assert(badge.hasAlert, 'The Mets badge in the first request should have an alert');
            }
        }

        List<ContactBadgesService.BadgeDataWrapper> refreshedWrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();
        Test.startTest();
        refreshedWrapperResult = ContactBadgesService.getBadgeDataForContact(ct.Id, ct.AccountId);
        Test.stopTest();

        for (ContactBadgesService.BadgeDataWrapper badge : refreshedWrapperResult) {
            if (badge.label.contains(CONTACT_TITLE)) {
                System.assert(!badge.hasAlert, 'The Mets badge in the second request should not have an alert');
            }
        }

    }

    @IsTest
    static void testInsufficientAccess() {
        UserRole uRole = new UserRole(DeveloperName = 'TestCustomRole', Name = 'Test Custom Role');
        insert uRole;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
        User u = createTestUser(uRole.Id, profile.Id, 'Test', 'User');
        insert u;

        // Give the user access to contact badges
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Contact_Badges_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permSet.Id);

        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];
        Id ctId  = ct.Id;
        Id accId = ct.AccountId;

        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = new List<ContactBadgesService.BadgeDataWrapper>();

        Test.startTest();
        System.runAs(u) {
            wrapperResult = ContactBadgesService.getBadgeDataForContact(ctId, accId);
        }
        Test.stopTest();

        System.assert(wrapperResult.isEmpty(), 'User with insufficient access should not have received badge results');
    }

    @IsTest
    static void testQueryLimit() {
        Contact ct = [SELECT Id, AccountId FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];
        Opportunity opp = new Opportunity(Name = 'Big Test Opp', AccountId = ct.AccountId, StageName = 'Closed Won', Amount = 50000, CloseDate = Date.today());
        insert opp;

        Test.startTest();
        List<Contact_Badge_Definition__mdt> lstDefinitions = createMockDefinitions(101);


        List<ContactBadgesService.BadgeDataWrapper> lstWrappers;
        lstWrappers = ContactBadgesService.getBadgeDataWrappers(
            lstDefinitions, 
            ct.Id, 
            ct.AccountId
        );
        System.assertEquals(Limits.getQueries(), lstWrappers.size(), 'Should have received a wrapper for each query');
        System.assertEquals(Limits.getQueries(), Limits.getLimitQueries(), 'Should have maxed out query limit');
        Test.stopTest();
    }

    private static User createTestUser(
        Id roleId, 
        Id profileId, 
        String firstName, 
        String lastName
    ) {
        String orgId      = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        User u = new User();
        u.IsActive          = true;
        u.TimeZoneSidKey    = UserInfo.getTimeZone().toString();
        u.LocaleSidKey      = UserInfo.getLocale();
        u.LanguageLocaleKey = UserInfo.getLocale();
        u.EmailEncodingKey  = 'ISO-8859-1';
        u.Username          = uniqueName + '@test' + orgId + '.org';
        u.Email             = uniqueName + '@test' + orgId + '.org';
        u.FirstName         = firstName;
        u.LastName          = lastName;
        u.Alias             = uniqueName.substring(18, 23);
        u.UserRoleId        = roleId;
        u.ProfileId         = profileId;
        return u;
    }

    private static List<Contact_Badge_Definition__mdt> createMockDefinitions(
        Integer numberOfDefinitions
    ) {
        String definitionString = '[';
        for (Integer i = 0; i < numberOfDefinitions; i++) {
            String defName = 'TestDefinition' + String.valueOf(i);
            definitionString += 
                '{"Id": "' + getFakeDefinitionId() + '",' +
                ' "Label": "' + defName + '",' +
                ' "DeveloperName": "' + defName + '",' +
                ' "sscb__Active__c": true,' + 
                ' "sscb__Sort_Order__c": "' + String.valueOf(i) + '",' +
                ' "sscb__Child_Object__c": "Opportunity",' +
                ' "sscb__Parent_Object__c": "Account",' + 
                ' "sscb__Parent_ID_Path__c": "AccountId",' +
                ' "sscb__Filter_Criteria__c": "Amount >= ' + Integer.valueOf(i) + '",' + 
                ' "sscb__Label__c": "Opp Over ' + String.valueOf(i) + '"}';
            if (i < (numberOfDefinitions - 1)) {
                definitionString += ', ';
            }
        }
        definitionString += ']';
        List<Contact_Badge_Definition__mdt> lstDefinitions;
        lstDefinitions = (List<Contact_Badge_Definition__mdt>) JSON.deserialize( 
            definitionString, 
            List<Contact_Badge_Definition__mdt>.class 
        );
        return lstDefinitions;
    }

    public static Id getFakeDefinitionId() {
		String result = String.valueOf(fakeIdNumber++);
		return (Id) ('m00' + '0'.repeat(12 - result.length()) + result);
	}

}