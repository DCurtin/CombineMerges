@isTest 
private class WebmergeCombineControllerTest {

    private WebmergeCombineController testController;
    private static final integer MAXACCOUNTS = 3;
    private static final integer MAPPINGCOUNT = 3;
    private static final string SOBJECTTYPENAME = 'Account';
    

    @testSetup 
    static void setup() {
        TestUtils.insertAccounts(MAXACCOUNTS);

        generateAndInsertMappings(MAPPINGCOUNT, SOBJECTTYPENAME);
    }

    static testmethod void generateWebmerges_generalTestWithCorrectInput_returnsPageReferenceWithSObjectRecentRecordsURL()
    {
        WebmergeCombineController WMCC = testSetup(1);

        string returnUrlWithType = '/lightning/o/'+WMCC.sobjectTypeName+'/list?filterName=Recent';

        List<webm__Webmerge_Mapping__c> mappings = [SELECT id FROM webm__Webmerge_Mapping__c WHERE webm__Salesforce_Object_Name__c=:WMCC.sobjectTypeName];
        Test.setCurrentPageReference(new PageReference('WebmergeCombine.page'));
        System.assert(mappings.size() > 0);

        System.currentPageReference().getParameters().put('mergeId', mappings.get(0).id);
        PageReference returnPage = WMCC.generateWebmerges();

        System.assertEquals(returnUrlWithType, returnPage.getUrl());
    }

    static testmethod void getMappings_testMappingQueryForNumberOfAvailableMappings_numberOfMappingsEquallsMAPPINGCOUNTConstant() 
    {
        WebmergeCombineController WMCC = testSetup();

        System.assertNotEquals(WMCC.mappings, null);

        Integer mappingCount = WMCC.mappings.size();

        System.assertEquals(3,mappingCount);
	}

    static testmethod void goBack_setControllerWithRecordTypeString_returnsPageReferenceWithURLForRecentRecords() 
    {
        string recordTypeStr = 'Account';
        List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];

        string returnUrlWithType = '/lightning/o/'+recordTypeStr+'/list?filterName=Recent';
     
        WebmergeCombineController wMCCWithTypeSet = testSetup(testAccounts, recordTypeStr);
        
        PageReference returnPageWithType    = wMCCWithTypeSet.goBack();
        
        System.assertEquals(returnPageWithType.getUrl(), returnUrlWithType);
    }

    static testmethod void goBack_setControllerWithNoRecordTypeString_returnsPageReferenceWithURLForLightningHomePage() 
    {
        List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];

        string returnUrlWithOutType = '/lightning';

        WebmergeCombineController wMCCWithOutTypeSet = testSetup(testAccounts, null);

        PageReference returnPageWithoutType = wMCCWithOutTypeSet.goBack();

        System.assertEquals(returnPageWithoutType.getUrl(), returnUrlWithOutType);
    }

    static testmethod void getIdsFromRecords_givenListofRecords_returnsEquallSizedListOfRecordIDs()
    {
        WebmergeCombineController testController = new WebmergeCombineController();
        List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];

        List<Id> recordIds = testController.getIdsFromRecords(testAccounts);

        System.assertEquals(recordIds.size(), testAccounts.size());
        for(integer index=0; index < recordIds.size(); ++index)
        {
            System.assertEquals(testAccounts.get(index).Id, recordIds.get(index));
        }
    }

    static testmethod void getShowMappings_setControllerWithoutRecordsOrRecordType_returnsFalseAndNoRecordsErrorMessage()
    {
        String recordsNotSet = 'No records selected.';

        string recordTypeStr = 'Account';

        List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];

        WebmergeCombineController WMCCTestNullVars = testSetup(null, null);

        //Test recordList andsobjectTypeName null
        Boolean areMappingsShown = WMCCTestNullVars.showMappings;
        String errorMessage = WMCCTestNullVars.errorMessage;
        System.assertEquals(FALSE, areMappingsShown);
        System.assertEquals(recordsNotSet, errorMessage);
    }

    static testmethod void getShowMappings_setControllerWithRecordsWithoutRecordType_returnsFalseAndNoMappingsErrorMessage()
    {
        String noMappingsAvailable = 'No mappings available for this object.';

        string recordTypeStr = 'Account';

        List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];

        WebmergeCombineController WMCCTestNullSobjectTypeName = testSetup(testAccounts,null);

        //Test only sobjectTypeName null
        Boolean areMappingsShown = WMCCTestNullSobjectTypeName.showMappings;
        String errorMessage = WMCCTestNullSobjectTypeName.errorMessage;
        System.assertEquals(FALSE, areMappingsShown);
        System.assertEquals(noMappingsAvailable, errorMessage);
    }

    static testmethod void getShowMappings_setControllerWithRecordsAndRecordType_returnsTrue()
    {
        string noError = '';

        string recordTypeStr = 'Account';

        List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];

        WebmergeCombineController WMCCTestGeneralCase = testSetup(testAccounts, recordTypeStr);

        //Test general case, should be no error and show mappings
        Boolean areMappingsShown = WMCCTestGeneralCase.showMappings;
        String errorMessage = WMCCTestGeneralCase.errorMessage;
        System.assertEquals(TRUE, areMappingsShown);
        System.assertEquals(noError, errorMessage);
    }

    //HELPER FUNCTIONS

     public static WebmergeCombineController testSetup()
     {
        return testSetup(MAXACCOUNTS);
     }

    public static WebmergeCombineController testSetup(integer numOfAccounts)
    {
        if(numOfAccounts > MAXACCOUNTS)
        {
            System.debug('account selection to high, please use a smaller number or increase MAXACCOUNTS. ' + MAXACCOUNTS + ' number of accounts will be used');
            List<Account> testAccounts = [SELECT id FROM Account LIMIT :MAXACCOUNTS];
            return testSetup(testAccounts, SOBJECTTYPENAME);
        }else
        {
            List<Account> testAccounts = [SELECT id FROM Account LIMIT :numOfAccounts];
            return testSetup(testAccounts, SOBJECTTYPENAME);
        }
        
    }
    public static WebmergeCombineController testSetup(List<SObject> recordList, String recordTypeStr)
    {
        WebmergeCombineController testController = new WebmergeCombineController();
        testController.recordsList = recordList;
        testController.sobjectTypeName = recordTypeStr;
        return testController;
    }
    public static void generateAndInsertMappings(integer mappingCount, string typeName)
    {
        List<webm__Webmerge_Mapping__c> mappingsToInsert = new List<webm__Webmerge_Mapping__c>();
        for(Integer step=0; step < mappingCount; ++step)
        {
            webm__Webmerge_Mapping__c testMapping = new webm__Webmerge_Mapping__c();
            testMapping.Name = 'testMapping'+ step;
            testMapping.webm__Salesforce_Object_Name__c = typeName;
            mappingsToInsert.add(testMapping);
        }
        insert mappingsToInsert;
    }
}
