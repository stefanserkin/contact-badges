public with sharing class ContactBadgesController {

    @AuraEnabled(cacheable=true)
    public static List<ContactBadgesService.BadgeDataWrapper> getBadgeData(String recordId, String accountId) {
        try {
            List<ContactBadgesService.BadgeDataWrapper> wrapperResult = ContactBadgesService.getBadgeDataForContact(recordId, accountId);
            return wrapperResult;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
