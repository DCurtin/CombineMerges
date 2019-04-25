public with sharing class WebmergeCombineController{

    //private List<SObject> recordsList;
    public List<SObject>    recordsList       {set;get;}
    public string           sobjectTypeName   {set;get;}
    public string           errorMessage      {set;get;}

    public list<webm__Webmerge_Mapping__c> mappings {set; 
        get{
            if(mappings == null)
            {
                mappings = [SELECT Id, Name, webm__Description__c, webm__Salesforce_Object_Name__c  FROM webm__Webmerge_Mapping__c WHERE webm__Salesforce_Object_Name__c=:sobjectTypeName];
            }
            return mappings;}
    }
    
    private final PageReference returnPage {set; 
        get{
            if(sobjectTypeName != null && returnPage == null)
            {
                 returnPage = new PageReference('/lightning/o/'+sobjectTypeName+'/list?filterName=Recent');
            }
            if(returnPage == null)
            {
                returnPage = new PageReference('/lightning');
            }
            return returnPage;
        }
    }

    public Boolean showMappings {set;
        get{
            
            if(recordsList == null)
            {
                errorMessage = 'No records selected.';
                return false;
            }

            if(mappings == null || mappings.size() == 0)
            {
                errorMessage = 'No mappings available for this object.';
                return false;
            }
            return true;
        }
    }

    public PageReference generateWebmerges()
    {
        id mappingId = (id) ApexPages.currentPage().getParameters().get('mergeId');   
        List<Id> recordIds = new List<Id>();
        System.debug('recordsList: ' + recordsList);
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