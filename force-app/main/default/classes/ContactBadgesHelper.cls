public with sharing class ContactBadgesHelper {
    
    /****************************************************
     * Constants
     ****************************************************/

    private static final String DEFAULT_BACKGROUND_COLOR = '#D3D3D3';
    private static final String DEFAULT_LABEL_COLOR = '#000000';
    private static final String DEFAULT_ICON_NAME = 'utility:info';
    private static final String BADGE_LABEL_TYPE_VALUE = 'Value';
    private static final String BADGE_LABEL_TYPE_FIELD_REFERENCE = 'Field Reference';
    private static final String MERGE_FIELD_REGEX = '\\{!.+?\\}';

    /****************************************************
     * Sorts and returns a provided list of definitions, based on
     *     the sort order defined in the custom metadata record
     * @param List<Contact_Badge_Definition__mdt> Unsorted list of
     *     definitions
     ****************************************************/

    public static List<Contact_Badge_Definition__mdt> sortContactBadgeDefinitions(
        List<Contact_Badge_Definition__mdt> lstDefinitions
    ) {
        List<Contact_Badge_Definition__mdt> lstSortedDefinitions = new List<Contact_Badge_Definition__mdt>();
        ContactBadgeDefinitionWrapper[] lstCBDWrapper = new List<ContactBadgeDefinitionWrapper>();
        for (Contact_Badge_Definition__mdt definition : lstDefinitions) {
            lstCBDWrapper.add( new ContactBadgeDefinitionWrapper(definition) );
        }
        lstCBDWrapper.sort();
        for (ContactBadgeDefinitionWrapper cbdWrapper : lstCBDWrapper) {
            lstSortedDefinitions.add( cbdWrapper.cbd );
        }
        return lstSortedDefinitions;
    }

    /****************************************************
     * Returns a soql query string, constructed from custom metadata properties
     * @param Contact_Badge_Definition__mdt The definition record
     *     to construct a query for
     ****************************************************/

    public static String getQueryFromDefinition(
        Contact_Badge_Definition__mdt definition
    ) {
        // SELECT
        String query = 'SELECT Id ';
        Set<String> setDetailFields = getFieldsForSelector(definition);
        for (String field : setDetailFields) {
            query += ', ' + String.escapeSingleQuotes(field) + ' ';
        }

        // FROM
        query += 'FROM ' + String.escapeSingleQuotes(definition.Child_Object__c) + ' ';

        // WHERE
        query += 'WHERE ' + definition.Parent_ID_Path__c + ' = :';
        query += definition.Parent_Object__c == 'Account' ? 'accountId ' : 'recordId ';
        if (!String.isBlank(definition.Filter_Criteria__c)) {
            query += 'AND ' + definition.Filter_Criteria__c + ' ';
        }

        // ORDER BY
        if (!String.isBlank(definition.Order_By__c)) {
            query += 'ORDER BY ' + definition.Order_By__c;
        }

        return query;
    }

    /****************************************************
     * Returns the badge label for a single definition
     * @param Contact_Badge_Definition__mdt The definition record
     *     to construct a query for
     * @param SObject The api name of the sObject type being queried
     ****************************************************/

    public static String getBadgeLabel(
        Contact_Badge_Definition__mdt definition, 
        SObject obj
    ) {
        String badgeLabel = definition.Label__c.contains('{!')
            ? replaceMergeFieldsWithValues(definition.Label__c, obj) 
            : definition.Label__c;
        return badgeLabel;
    }

    /****************************************************
     * Returns the badge alert message for a single definition
     * @param Contact_Badge_Definition__mdt The definition record
     *     to construct a query for
     * @param SObject The api name of the sObject type
     ****************************************************/
    
    public static String getBadgeAlertMessage(
        Contact_Badge_Definition__mdt definition, 
        SObject obj
    ) {
        String alertMessage;
        if (
            definition.Alert__c && 
            !String.isBlank(definition.Alert_Message__c) &&
            definition.Alert_Message__c.contains('{!')
        ) {
            alertMessage = replaceMergeFieldsWithValues(
                definition.Alert_Message__c, 
                obj
            );
        } else {
            alertMessage = definition.Alert_Message__c;
        }
        return alertMessage;
    }

    /****************************************************
     * Returns a string that can be referenced in an html style attribute
     *     to display the badge's defined background color (or default)
     * @param Contact_Badge_Definition__mdt The definition record
     *     to get the badge color for
     ****************************************************/

    public static String getBadgeColorStyle(
        Contact_Badge_Definition__mdt definition
    ) {
        String hexColor = definition.Background_Color__c != null ? '#' + definition.Background_Color__c : DEFAULT_BACKGROUND_COLOR;
        String badgeColorStyle = '--sds-c-badge-color-background:' + hexColor + ';';
        return badgeColorStyle;
    }

    /****************************************************
     * Returns a string that can be referenced in an html style attribute
     *     to display the badge's defined label color (or default)
     * @param Contact_Badge_Definition__mdt The definition record
     *     to get the label color for
     ****************************************************/

    public static String getBadgeLabelStyle(
        Contact_Badge_Definition__mdt definition
    ) {
        String labelHexColor = definition.Label_Color__c != null ? '#' + definition.Label_Color__c : DEFAULT_LABEL_COLOR;
        String badgeLabelStyle = '--sds-c-badge-text-color:' + labelHexColor + ';--slds-c-badge-icon-color-foreground:' + labelHexColor;
        return badgeLabelStyle;
    }

    /****************************************************
     * Returns the name of the icon to display for this badge
     * @param Contact_Badge_Definition__mdt The definition record
     *     to get the badge icon for
     ****************************************************/

    public static String getBadgeIconName(
        Contact_Badge_Definition__mdt definition
    ) {
        String iconName = !String.isBlank(definition.Icon_Name__c) ? definition.Icon_Name__c : DEFAULT_ICON_NAME;
        return iconName;
    }

    /****************************************************
     * Returns a set of strings with each of the field names to include
     *     in the SELECT statement of the query
     * @param Contact_Badge_Definition__mdt The definition record
     *     to get selector fields for
     ****************************************************/

    private static Set<String> getFieldsForSelector(
        Contact_Badge_Definition__mdt definition
    ) {
        Set<String> fieldsForSelector = new Set<String>();
        // If displaying a label with merge fields, add the fields to the query
        if (
            !String.isBlank(definition.Label__c) && 
            definition.Label__c.contains('{!')
        ) {
            fieldsForSelector.addAll(
                getMergeFieldsFromString(definition.Label__c)
            );
        }
        // If displaying an alert, check for merge fields to add to query
        if (
            definition.Alert__c && 
            !String.isBlank(definition.Alert_Message__c) &&
            definition.Alert_Message__c.contains('{!')
        ) {
            fieldsForSelector.addAll(
                getMergeFieldsFromString(definition.Alert_Message__c)
            );
        }
        // Add all additional fields for the modal
        if (!String.isBlank(definition.Additional_Detail_Fields__c)) {
            fieldsForSelector.addAll(definition.Additional_Detail_Fields__c.replaceAll('\\s+', '').split(','));
        } else {
            fieldsForSelector.add('Name');
        }
        return fieldsForSelector;
    }


    /****************************************************
     * Returns a set of strings with each of the merge fields
     *     contained in the original string
     * @param String String containing merge fields
     ****************************************************/

    private static Set<String> getMergeFieldsFromString(
        String input
    ) {
        Set<String> setMergeFields = new Set<String>();
        Pattern p = Pattern.compile(MERGE_FIELD_REGEX);
        Matcher m = p.matcher(input);
        while(m.find()) {
            String mergeFieldApiName = m.group().substring(
                2, 
                m.group().length() - 1
            );
            setMergeFields.add(mergeFieldApiName);
        }
        return setMergeFields;
    }

    /****************************************************
     * Returns the original string with merge fields substituted
     *     for their values
     * @param String String containing merge fields to be replaced
     * @param SObject The api name of the sObject type
     ****************************************************/

    private static String replaceMergeFieldsWithValues(
        String input,
        SObject obj
    ) {
        String result = input;
        Map<String,Object> mapObjFields = obj.getPopulatedFieldsAsMap();
        Pattern p = Pattern.compile(MERGE_FIELD_REGEX);
        Matcher m = p.matcher(result);
        while(m.find()) {
            String fieldApiName = m.group().substring(
                2, 
                m.group().length() - 1
            );
            result = String.valueOf(mapObjFields.get(fieldApiName)) != null ?
                result.replace(m.group(0), String.valueOf(mapObjFields.get(fieldApiName))) :
                result.replace(m.group(0), '');
        }
        return result;
    }


}