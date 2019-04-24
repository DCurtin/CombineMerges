public with sharing class WebmergeCombineController{

    private List<SObject> recordsList;
    public list<webm__Webmerge_Mapping__c> mappings {get; set;}
    public Boolean showMappings { get; set;}
    public string errorMessage {get; set;}
    private final string sobjectTypeName;
    private final PageReference returnPage;

    
    public WebmergeCombineController(ApexPages.StandardSetController stdController)
    {
        showMappings = true;
        sobjectTypeName = stdController.getRecord().getSObjectType().getDescribe().getName();
        returnPage = new PageReference('/lightning/o/'+sobjectTypeName+'/list?filterName=Recent');

        List<SObject> selectedRecords =  stdController.getSelected();
        if(selectedRecords.size() == 0)
        {
            showMappings = false;
            errorMessage = 'No records selected.';
            return;
        }
        
        if(!stdController.getSelected().isEmpty())
        {   string query = 'select Id, Name from '+ sobjectTypeName + ' where Id IN :selectedRecords';
            recordsList = Database.query(query);
        }

        mappings = [SELECT Id, Name, webm__Description__c, webm__Salesforce_Object_Name__c  FROM webm__Webmerge_Mapping__c WHERE webm__Salesforce_Object_Name__c=:sobjectTypeName ];
        if(mappings.size() == 0)
        {
            showMappings = false;
            errorMessage = 'No mappings available for this object.';
            return;
        }
    }

    public PageReference generateWebmerges()
    {
        id mappingId = (id) ApexPages.currentPage().getParameters().get('mergeId');   
        List<Id> recordIds = new List<Id>();

        for(SObject record : recordsList)
        {
            recordIds.add(record.id);
        }

        combineWebmerges(mappingId, recordIds, sobjectTypeName);

        return returnAddress(returnPage);
    }

    public PageReference goBack()
    {
        return returnAddress(returnPage);
    }

    //@future(callout=true)
    private void combineWebmerges(id mappingId,List<Id> recordIds, string objectType)
    {
        webm.WebmergeGenerator.generateDocumentBatchCombined(
            mappingId, 
            recordIds, 
            objectType
            );
    }

    private PageReference returnAddress(PageReference returnPage)
    {
        return returnPage;
    }


}