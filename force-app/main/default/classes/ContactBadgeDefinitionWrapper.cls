public class ContactBadgeDefinitionWrapper implements Comparable {

    public Contact_Badge_Definition__mdt cbd;

    public ContactBadgeDefinitionWrapper(Contact_Badge_Definition__mdt definition) {
        cbd = definition;
    }

    // Compare Contact Badge Definitions based on sort order
    public Integer compareTo(Object compareTo) {
        // Cast argument to ContactBadgeDefinitionWrapper
        ContactBadgeDefinitionWrapper compareToDefinition = (ContactBadgeDefinitionWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (cbd.Sort_Order__c > compareToDefinition.cbd.Sort_Order__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (cbd.Sort_Order__c < compareToDefinition.cbd.Sort_Order__c) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((cbd.Sort_Order__c == null) && (compareToDefinition.cbd.Sort_Order__c != null)){
            // nulls-last implementation
            returnValue = 1;
        } else if ((cbd.Sort_Order__c != null) && (compareToDefinition.cbd.Sort_Order__c == null)){
            // nulls-last implementation
            returnValue = -1;
        }
        return returnValue;
    }

}