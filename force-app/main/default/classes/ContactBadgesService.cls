public with sharing class ContactBadgesService {

    private static final String CACHE_KEY_PREFIX = 'cb';
    private static final String CACHE_PARTITION_NAME = 'sscb.ContactBadges';
    private static final String DEFAULT_BADGE_FIELDSET = 'Name';

    @TestVisible static Boolean isTestScenario = false;

    /****************************************************
     * Main entry
     * @param String Contact Id (recordId)
     * @param String Contact's Account Id (accountId)
     ****************************************************/

    public static List<BadgeDataWrapper> getBadgeDataForContact(String recordId, String accountId) {
        List<Contact_Badge_Definition__mdt> lstDefinitions = getSortedDefinitions();
        List<BadgeDataWrapper> lstBadgeData = getBadgeDataWrappers(lstDefinitions, recordId, accountId);
        return lstBadgeData;
    }

    /****************************************************
     * Returns a list of all badge definitions, sorted by 
     *     the sort order defined in the custom metadata record
     ****************************************************/

    private static List<Contact_Badge_Definition__mdt> getSortedDefinitions() {
        List<Contact_Badge_Definition__mdt> lstUnsortedDefinitions = Contact_Badge_Definition__mdt.getAll().values();
        List<Contact_Badge_Definition__mdt> lstDefinitions = ContactBadgesHelper.sortContactBadgeDefinitions(
            lstUnsortedDefinitions
        );
        return lstDefinitions;
    }

    /****************************************************
     * Returns a list of badge data wrappers, with properties
     *     set by helper methods in ContactBadgesHelper.cls
     * @param List<Contact_Badge_Definition__mdt> A list of custom
     *     metadata records to create badges from
     * @param String Contact Id (recordId)
     * @param String Contact's Account Id (accountId)
     ****************************************************/

    private static List<BadgeDataWrapper> getBadgeDataWrappers(
        List<Contact_Badge_Definition__mdt> lstDefinitions,
        String recordId, 
        String accountId
    ) {
        // Create empty list of wrappers to return
        List<BadgeDataWrapper> lstBadgeData = new List<BadgeDataWrapper>();
        // Create set to store label names to avoid duplicates
        Set<String> setLabelNames = new Set<String>();
        // Check platform cache for previous visits in the current session
        Boolean isFirstVisit = verifyFirstSessionVisit(recordId);
        
        for (Contact_Badge_Definition__mdt definition : lstDefinitions) {
            // In test scenarios, must be a sample badge
            // In live scenarios, must be an active badge
            if ((isTestScenario && !definition.Is_Sample_Badge__c) || (!isTestScenario && !definition.Active__c)) {
                continue;
            }

            // Query for related records
            String query = ContactBadgesHelper.getQueryFromDefinition(definition);
            List<SObject> queryResults;
            try {
                queryResults = Database.query(query);
            } catch (System.QueryException ex) {
                // User does not have required CRUD/FLS access
                continue;
            }

            // Create wrapper from mdt details and add to list
            for (SObject obj : queryResults) {
                BadgeDataWrapper badge = new BadgeDataWrapper();
                badge.id         = obj.Id;
                badge.objType    = definition.Child_Object__c;
                badge.label      = ContactBadgesHelper.getBadgeLabel(definition, obj);
                // Prevent duplicates
                if (setLabelNames.contains(badge.label)) {
                    continue;
                } else {
                    setLabelNames.add(badge.label);
                }
                badge.colorStyle = ContactBadgesHelper.getBadgeColorStyle(definition);
                badge.labelStyle = ContactBadgesHelper.getBadgeLabelStyle(definition);
                badge.iconName   = ContactBadgesHelper.getBadgeIconName(definition);
                badge.fieldSet   = String.isBlank(definition.Additional_Detail_Fields__c) 
                    ? DEFAULT_BADGE_FIELDSET 
                    : definition.Additional_Detail_Fields__c.replaceAll('\\s+', '');
                if (definition.Alert__c && isFirstVisit) {
                    badge.hasAlert     = true;
                    badge.alertMessage = ContactBadgesHelper.getBadgeAlertMessage(definition, obj);
                } else {
                    badge.hasAlert = false;
                }
                lstBadgeData.add(badge);
            }
        }
        return lstBadgeData;
    }

    /****************************************************
     * Returns true if this is the running user's first visit to this
     *     Contact page in the current session and caches the current
     *     visit. Returns false if a visit is found in the session cache
     * @param String Contact Id (recordId)
     ****************************************************/

    private static Boolean verifyFirstSessionVisit(String recordId) {
        Boolean isFirstVisit;
        // Create cache key out of user and contact ids
        String userId = UserInfo.getUserId();
        String cacheContactKey = CACHE_KEY_PREFIX + userId + recordId;
        // Create instance of session partition
        Cache.SessionPartition part = Cache.Session.getPartition(CACHE_PARTITION_NAME);
        if (part.contains(cacheContactKey)) {
            isFirstVisit = false;
        } else {
            part.put(cacheContactKey, Datetime.now());
            isFirstVisit = true;
        }
        return isFirstVisit;
    }

    /****************************************************
     * Wrapper with all the attributes needed in component
     ****************************************************/

     public class BadgeDataWrapper {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String objType {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String colorStyle {get;set;}
        @AuraEnabled
        public String labelStyle {get;set;}
        @AuraEnabled
        public String iconName {get;set;}
        @AuraEnabled
        public String fieldSet {get;set;}
        @AuraEnabled
        public Boolean hasAlert {get;set;}
        @AuraEnabled
        public String alertMessage {get;set;}
    }

}