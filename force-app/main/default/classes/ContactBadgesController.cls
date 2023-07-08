public with sharing class ContactBadgesController {

    @AuraEnabled(cacheable=true)
    public static List<ContactBadgesService.BadgeDataWrapper> getBadgeData(String recordId, String accountId) {
        try {
            List<ContactBadgesService.BadgeDataWrapper> wrapperResult = ContactBadgesService.getBadgeDataForContact(recordId, accountId);
            return wrapperResult;
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

}
