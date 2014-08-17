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
 * @description standard implementation of BaseContainer interface. Providing advaced features for handling collections
 *
 * apex-base's core abstract class contains commonly used methods and features you can implement
 * in your custom Apex classes by extending it, allowing you to keep your code DRY.
 * Besides support for sObjects you can wrap any object inside
 * 
 * some features:
 * - selectable
 * - rowIndex / sortOrder
 * - uniqueIds
 * - conversion to ApexPages.StandardController
 * - dynamic child relationships 
 */  
public virtual class ab_BaseObjectAbstract implements ab_BaseObject{

    sObject recordObject;
    Object userObject;

    Integer rowIndex;
    Integer sortOrder;
    Boolean selected;

    String[] errorMsgs;

    Object objectId;
    String objectLabel;
    String objectName;

    // CRS related variables
    // contains keys of detail children e.g. PurchaseInvoice ==> Lines, Expenses
    protected Map<Object,ab_BaseContainer> childrenMap;

    protected Map<Integer,Object> crsOrder;

    /*
     *============================================================
     * CONSTRUCTORS & CORE METHODS
     *============================================================
     */

    /**
     * @description Class constructor
     */
    public ab_BaseObjectAbstract(){
        this.selected = false;
    }

    /**
     * @description Class constructor defines a sObject assigned to recordObject variable
     */
    public ab_BaseObjectAbstract(sObject Precord){
        this();
        this.recordObject = Precord;
    }

    /**
     * @description Constructor defines an object assigned to userObject variable
     */
    public ab_BaseObjectAbstract(Object uo){
        this();
        this.userObject = uo;
    }

    /**
     * @description returns the ab_BaseObjectType Enum for the stored object
     * @return ab_BaseObjectType  
     */
    public virtual ab_BaseObjectType getObjectType(){
        if(this.recordObject != null) return ab_BaseObjectType.RECORD;
        if(this.userObject != null){
        	return this.userObject instanceof ab_BaseContainer
        	       ? ab_BaseObjectType.CONTAINER
        	       : ab_BaseObjectType.APEX;
        }
        return ab_BaseObjectType.NONE;
    }

    /**
     * @description compares the current instance with an other object
     * @param Object toCompare
     * @return ab_BaseObjectType  
     */
    public virtual Boolean equals(Object toCompare){
        return this == toCompare;
    }


    /**
     * @description returns the userObject stored inside
     * @return Object userObject variable  
     */
    public virtual Object getUserObject(){
        return this.userObject;
    }
    /**
     * @description sets the userObject variable
     * @param Object userObject to store  
     */
    public virtual void setUserObject(Object userObj){
        this.userObject = userObj;
    }

    /*
     *============================================================
     * SOBJECT METHODS
     *============================================================
     */


    /**
     * @description gets the recordObject stored as recordObject
     * @return sObject recordObject  
     */
    public virtual sObject getsObject(){
        return this.recordObject;
    }
    
    /**
     * @description sets the recordObject variable
     * @param sObject Precord to store  
     */
    public virtual void setsObject(sObject Precord){
        this.recordObject = Precord;
    } 

    /**
     * @description sets a value on a recordObject's fields
     * @param fieldName API name of the target field
     * @param value Object to store 
     * @throws System.SObjectException for invalid field name
     */
    public virtual void setValue(String fieldName,Object value){
        this.getSObject().put(fieldName,value);
    }


    /**
     * @description returns a field value from the recordObject
     * @param fieldName API name of the field containing the value
     * @throws System.SObjectException for invalid field name
     * @return Object field value
     */
    public virtual Object getValue(String fieldName){
        return this.getSObject().get(fieldName);
    }


    /**
     * @description returns the Id of the recordObject
     * @return Id value of Id field or null
     */
    public virtual Id getRecordId(){
        return this.getsObject() != null ? (String)this.getsObject().get('Id') : null;
    }


    /**
     * @description Id to identify the object
     * @return Object either recordObjects Id or a formatted positive random long
     */  
    public virtual Object getObjectId(){
        if(this.objectId == null){
            this.objectId = this.getRecordId() == null 
                    ? Decimal.valueOf(Crypto.getRandomLong()).abs().format().replaceAll('\\.','') 
                    : this.getRecordId();
        }
        return this.objectId;
    }

    /**
     * @description Evals if the recordObject is unsaved, by checking getRecordId() for null
     * @return Boolean result
     */
    public virtual Boolean getIsNew(){
        return this.getRecordId() == null;
    }

    /*
     *============================================================
     * SOBJECT DESCRIBE
     *============================================================
     */

    /**
     * @description Returns recordObjects describeResult
     * @return Schema.DescribesObjectResult 
     * @throws System.NullPointerException if recordObject is null
     */  
    public virtual Schema.DescribesObjectResult getDescribe(){
        return this.getSObject().getSObjectType().getDescribe();
    }

    /**
     * @description recordObject's label
     * @return String sObject Label
     * @throws System.NullPointerException if recordObject is null
     */
    public virtual String getObjectLabel(){
        if(this.objectLabel == null){
            this.objectLabel = this.getDescribe().getLabel();
        }
        return this.objectLabel;
    }

    /**
     * @description recordObject's API Name
     * @return String sObject Name
     * @throws System.NullPointerException if recordObject is null
     */
    public virtual String getObjectName(){
        if(this.objectName == null){
            this.objectName = this.getDescribe().getName();
        }
        return this.objectName;
    }


    /*
     *============================================================
     * VISUALFORCE
     *============================================================
     */

    /**
     * Wrap record into StandardController and return it
     * e.g. 
     *
     * myObject.getStdCon().view() instead of
     * new ApexPages.StandardController(sObject).view();
     */

    /**
     * @description StandardController for recordObject 
     * @return ApexPages.StandardController StandardController constrcuted from recordObject  
     * @throws System.NullPointerException if recordObject is null
     */
    public virtual ApexPages.StandardController getStdCon(){
        return new ApexPages.StandardController(getsObject());
    }

    /*
     *============================================================
     * FEATURES
     *============================================================
     */

    /**
     * @description sets object's current position in a collection 
     * @param index Integer
     */
    public virtual void setRowIndex(Integer index){
        this.rowIndex = index;
    }

    /**
     * @description gets object's current position in a collection   
     * @param index Integer
     */
    public virtual Integer getRowIndex(){
        if(this.rowIndex == null){this.rowIndex = 0;}
        return this.rowIndex;
    }


    /**
     * @description object's sortOrder
     * @return Integer sortOrder value or rowIndex
     */
    public virtual Integer getSortOrder(){
        return this.sortOrder != null ? this.sortOrder : getRowIndex();
    }

    /**
     * @description sets sort order without overwritting the rowIndex
     * @param sorder value applied to sortOrder variable
     */
    public virtual void setSortOrder(Integer sorder){
        this.sortOrder = sorder;
    }


    /**
     * @description Selects/Deselects object
     * @param isSelected state
     */
    public virtual void setSelected(Boolean isSelected){
    	this.selected = isSelected;
    }

    /**
     * @description selected value
     * @return Boolean 
     */
    public virtual Boolean getSelected(){
        return this.selected;
    }
    

    /*
     *============================================================
     * ERROR HANDLING
     *============================================================
     */


    /**
     * @description throws an ab_Exception
     * @return message Exception message 
     */
    public virtual void throwException(String message){
        throw new ab_Exception(message);
    }


    /**
     * @description marks the recordObject with an error and stores message in a list
     * @return message Error message 
     */
    public virtual void addError(String message){
        if(getObjectType() == ab_BaseObjectType.RECORD){
            getsObject().addError(message);
        }
        getErrors().add(message);
    }

    /**
     * @description Array of errors generated by addError(string)
     * @return List<String> errors array
     */
    public virtual List<String> getErrors(){
        if(errorMsgs == null) errorMsgs = new String[]{};
        return errorMsgs;
    }

    /**
     * @description resets the error array
     */
    public virtual void clearErrors(){
        errorMsgs = null;
    }

     
    /**
     * @description compares an object with the recordId and ObjectId
     * @param keyToCheck Object to compare
     * @return Boolean evaluation result
     */     
    public virtual Boolean checkKey(Object keyToCheck){
        return this.getObjectId() == keyToCheck || (this.getRecordId() != null && this.getRecordId() == keyToCheck);
    }


    /**
     * @description see checkKey(Object) 
     * @param keysToCheck objects to compare 
     * @return Boolean evaluation result     
     */      
    public virtual Boolean checkKeys(Set<Object> keysToCheck){
        return keysToCheck.contains(this.getObjectId()) || (this.getRecordId() != null && keysToCheck.contains(this.getRecordId()));
    }

    /*
     *============================================================
     * CHILD RELATIONSHIPS (CRS)
     *
     * Do to some limitations and possible casting issues, it is required to specifiy a
     * collection, 
     *
     *============================================================
     */

    /**
     * @description accepts an Object as CRSkey and a BaseContainer and stores both in the childrenMap
     * @param crsKey key to access the child container
     * @param container BaseContainer containg all children
     */
    public virtual void registerCRS(Object crsKey, ab_BaseContainer container){
        this.getChildren().put(crsKey,container);
        this.getCRSOrder().put(this.childrenMap.size(),crsKey);
    }


    /**
     * @description accepts an Object and sObject Array and passes them to  registerCRS(Object,ab_BaseContainer)
     * @param crsKey key to access the child container
     * @param children sObject array to store in child container
     */ 
    public virtual void registerCRS(Object crsKey, List<sObject> children){
        this.registerCRS(crsKey,new ab_BaseContainerAbstract(children));
    }


    /**
     * @description Returns a Map containing all registered Child Container  
     * @return Map<Object,ab_BaseContainer> all child container 
     */
    public virtual void setForeignKeyOnChildren(Object crsKey, String foreignKeyField){
         if(this.isValidCRS(crsKey)){
             for(ab_BaseObject bo : this.getChildren(crsKey).getRows()){
                 bo.setForeignKey(foreignKeyField,this.getRecordId());
             }
         }
     }

    /**
     * @description Returns a Map containing all registered Child Container  
     * @return Map<Object,ab_BaseContainer> all child container 
     */
    public virtual void setForeignKey(String foreignKeyField, Id foreignKey){
        if((Id)this.getValue(foreignKeyField) == null){
            this.getsObject().put(foreignKeyField,foreignKey);
        }
    }

    /**
     * @description Evaluates if a object matches any registered crsKey stored
     * @param crsKey Object to validate
     */
    public virtual Boolean isValidCRS(Object crsKey){
        return this.getChildren().containsKey(crsKey);
    }



    /**
     * @description Returns a Map holding object's child container. do not register a crs using put, use registerCRS instead
     * @return Map<Object,ab_BaseContainer> all child container 
     */
    public virtual Map<Object,ab_BaseContainer> getChildren(){
        if(this.childrenMap == null){
            this.childrenMap = new Map<Object,ab_BaseContainer>();
        }
        return this.childrenMap;
    }


    /**
     * @description Holds information about the sort order of CRS  
     * @return Map<Object,Integer> all child container 
     */
    public virtual Map<Integer,Object> getCRSOrder(){
    	if(this.crsOrder == null){this.crsOrder = new Map<Integer,Object>();}
    		return this.crsOrder;
    }

    /**
     * @description Returns the child container for a crsKey  
     * @param crsKey key to access the child container
     * @return ab_BaseContainer container holding the children
     */
    public virtual ab_BaseContainer getChildren(Object crsKey){
        return this.getChildren().get(crsKey);
    }


    /**
     * @description Returns all child container in the same order they were registered
     * @return List<ab_BaseContainer> all child container 
     */
    public virtual List<ab_BaseContainer> getChildrenList(){
    	List<ab_BaseContainer> output = new List<ab_BaseContainer>();

    	List<Integer> toSort = new List<Integer>();
    	toSort.addAll(this.getCRSOrder().keySet());
    	toSort.sort();

        for(Integer i : toSort){
        	output.add(this.getChildren(this.getCRSOrder().get(i)));
        }

        return output;
    }





}