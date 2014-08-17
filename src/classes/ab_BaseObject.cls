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
 * @description Interface all BaseObject classes have to implement. View ab_BaseObjectAbstract for more information 
 */
public virtual interface ab_BaseObject {

    ab_BaseObjectType getObjectType();
    Boolean equals(Object toCompare);


    void setUserObject(Object uo);    
    Object getUserObject();
    /**
     *============================================================
     * SOBJECT METHODS
     *============================================================
     */

    sObject getsObject();
    void setsObject(sObject Precord);

    void setValue(String fieldName,Object value);
    Object getValue(String fieldName);

    /** 
     * Getter for the sObject Id field
     */    
    Id getRecordId();

    /**
     * ObjectId uniquely identifies the object, either by it's sObjectId or a random Long  
     */
    Object getObjectId();

    /**
     * Returns true if the associated record is unsaved
     */
    Boolean getIsNew();

    /**
     *============================================================
     * SOBJECT DESCRIBE
     *============================================================
     */
    Schema.DescribesObjectResult getDescribe();

    /**
     * Label of the record's sObjectType
     */
    String getObjectLabel();
    /**
     * Name of the record's sObjectType
     */
    String getObjectName();


    /**
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
    ApexPages.StandardController getStdCon();

    /**
     *============================================================
     * COLLECTION BEHAVIOR
     *============================================================
     */

    void setSelected(Boolean selected);
    Boolean getSelected();
    /**
     * Set the position within a collection
     * @param ProwIndex position
     */
    void setRowIndex(Integer ProwIndex);
    Integer getRowIndex();

    /**
     * use to store order information, without overwritting the actual rowIndex
     * e.g. for drag-and-drop in the ui, ...
     */
    Integer getSortOrder();
    void setSortOrder(Integer PsortOrder);


    /**
     *============================================================
     * Error Handling
     *============================================================
     */
    void throwException(String message);

    void addError(String message);
    List<String> getErrors();
    void clearErrors();

    /**
     * Evals if the RecordId or ObjectId match the param value
     * @param Pkey String to copare
     * @return Boolean result
     */    
    Boolean checkKey(Object Pkey);

    /**
     * sames previous but for Set param
     */
    Boolean checkKeys(Set<Object> Pkey);


    /**
     *============================================================
     * CHILD RELATIONSHIPS
     *
     * Do to some limitations and possible casting issues, it is required to specifiy a
     * collection, 
     *
     *============================================================
     */

    /** 
     * Register a relationship for a concrete list
     */
    void registerCRS(Object crsKey, List<sObject> children);
    /**
     * Store a relationship for a concrete container
     */
    void registerCRS(Object crsKey, ab_BaseContainer container);

    /**
     * GETTER
     */
    /**
     * Getter for a certain child container
     */
    ab_BaseContainer getChildren(Object crsKey);
    Map<Object,ab_BaseContainer> getChildren();
    List<ab_BaseContainer> getChildrenList();
    Boolean isValidCRS(Object crsKey);
    void setForeignKeyOnChildren(Object crsKey, String foreignKeyField);
    void setForeignKey(String foreignKeyField, Id foreignKey);
}