public with sharing class ContactBadgesController {

    @AuraEnabled(cacheable=true)
    public static List<ContactBadgesService.BadgeDataWrapper> getBadgeData(String recordId, String accountId) {
        List<ContactBadgesService.BadgeDataWrapper> wrapperResult = ContactBadgesService.getBadgeDataForContact(recordId, accountId);
        return wrapperResult;
    }

}