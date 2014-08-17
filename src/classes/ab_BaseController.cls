/*============================================================
 * apex-base 2011
 *
 * http://code.google.com/p/apex-base/
 *
 * Code is licensed under "New BSD License". A copy of the license is included in the
 * ab_AboutPage.page file, included in the release
 *============================================================
 */

/**
 * @author Sebastian Wagner <sbw.dev@gmail.com>
 * @date 15-05-2011
 * @description Extendable class provides common methods for your controllers 
 *
 *
 * inspired by Ian Zepp's Agile Process Management (OSS) app
 * http://code.google.com/p/ianzepp/source/browse/branches/salesforce.com-apm-oss/ 
 */
public virtual class ab_BaseController {

    public ApexPages.StandardController stdCon {get;set;}
    public ApexPages.StandardSetController setCon {get;set;}

    /**
     * Class Constructor
     */
    public ab_BaseController(){}

    /**
     * Class Constructor defines a StandardController
     */
    public ab_BaseController(ApexPages.StandardController controller){
        this.stdCon = controller;
    }
        
    /**
     * Class Constructor defines a StandardSetController
     */
    public ab_BaseController(ApexPages.StandardSetController controller){
        this.setCon = controller;
    }

    /**
     * Number determining what controller is available
     * 0 = no controller defined
     * 1 = StandardController
     * 2 = StandardSetController
     */
    public Decimal getControllerMode(){
        if(stdCon != null) return 1;
        if(setCon != null) return 2;
        return 0;
   }

   /**
    * STANDARD (SET) CONTROLLER METHODS
    */

   /**
    * Return the StandardController's Id
    */
   public Id getId(){
      return this.stdCon.getId();
   }
        
   /**
    * get the SetController Record Ids
    */
   public List<Id> getIds(){
      return this.getIds(false);
   }

   /**
    * get the StandardSetController Record Ids (true to get only the selected)
    */
   public List<Id> getIds(Boolean selected){
      List<Id> output = new List<Id>(); 
        for(sObject obj : this.getRecords(selected)){
           output.add((Id)obj.get('Id'));
        }
        return output;
   }

   /**
    * Return the sObject wrapped inside the StandardController
    */
   public sObject getRecord(){
      return this.stdCon.getRecord();
   }

   /**
    * Get all sObjects from the SetController
    */
   public List<sObject> getRecords(){
      return this.getRecords(false);
   }


   /**
    * @description Get Records from the SetController or a list only containing the
    * StandardController record
    * @param selected Boolean true to retrieve only selected records
    * @return List<sObject> sObjects from SetController
    */
   public List<sObject> getRecords(Boolean selected){
      if(this.getControllerMode() == 1){return new List<sObject>{getRecord()};}
      if(selected)return this.setCon.getSelected();
      return this.setCon.getRecords();
   }

    /**
     *============================================================
     * DML
     *============================================================
     */

    /**
     * DML - SAVE
     * be carefull when calling methods from within Apex, since they contain
     * contain try-catch so you will not know if it was successful or not
     */
    public virtual PageReference saveAndView(){
      try{
         upsert this.getRecord();
            PageReference pref = new ApexPages.Standardcontroller(this.getRecord()).view();
            return pref;
      } catch(Exception ex){
           ApexPages.addMessages(ex);
      }
        return null;
   }

   /**
    * Preform upsert on all sObjects in SetController 
    */
   public virtual void saveRecords(){
      try{
         upsert getRecords();
        } catch(Exception ex){
         ApexPages.addMessages(ex);
        }
   }

   /**
    * Preform upsert on all selected sObjects in SetController 
    */
   public virtual void saveSelectedRecords(){
       try{
           upsert getRecords(true);
      } catch(Exception ex){
           ApexPages.addMessages(ex);
      }
   }

   /**
    * VISUALFORCE
    */

   /**
    * PAGE MESSAGES
    */
   public void raiseInternalError(){
       addError('Internal Error occured while processing your request');
   }

    public void addConfirmation(String message){
       addMessage(ApexPages.Severity.CONFIRM,message);
    }
        
    public void addError(String message){
       addMessage(ApexPages.Severity.ERROR,message);
    }
        
    public void addInfo(String message){
       addMessage(ApexPages.Severity.INFO, message);
    }

    public void addWarning(String message){
       addMessage(ApexPages.Severity.WARNING,message);
    }
   /**
    * Generic Method used by concrete Methods like addError
    */
    public void addMessage(ApexPages.Severity severity, String message){
       ApexPages.addMessage(new ApexPages.Message(severity, message));
    }

    public List<ApexPages.Message> getMessageList() {
        return ApexPages.getMessages();
    }

    public Integer getMessageListSize() {
        return getMessageList().size();
    }
    
    public Integer getMessageListSize(ApexPages.Severity severity) {
        Integer messageListSize = 0;
        
        for(ApexPages.Message message : getMessageList()) {
            if (message.getSeverity() == severity)
                messageListSize ++;
        }
        
        return messageListSize;
    }



    /**
     * PAGE PARAMETERS
     */
    public String getPageName(){
    	PageReference pref = ApexPages.currentPage();
    	pref.getParameters().clear();
    	return pref.getUrl().replace('/apex/','');
    }
    
    public void putParam(String name,String value){
    	ApexPages.currentPage().getParameters().put(name,value);
    }
    
    public String getParam(String name){
       return ApexPages.currentPage().getParameters().get(name);
    }
        

   /**
    * SELECT OPTION BUILDER
    */
        
    public List<SelectOption> buildSelectOptions(String objectName){
       string qryString = 'SELECT Id, Name FROM ' + objectName + ' ORDER BY Name LIMIT 100';
        return buildSelectOptions(Database.Query(qryString),'Id','Name');
    }
        
    public List<SelectOption> buildSelectOptions(List<sObject> data, String valueField,String labelField){
       List<SelectOption> output = new List<SelectOption>();
       output.add(new SelectOption('','--None--'));
        for(sObject o : data){
           output.add(new SelectOption((String)o.get(valueField),(String)o.get(labelField)));
        }
    return output;
    }

}