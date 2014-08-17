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
 * @description Interface all BaseContainer classes have to implement. View ab_BaseContainerAbstract for more information 
 */
public interface ab_BaseContainer extends ab_BaseObject {

    Boolean getAllowDuplicates();
    void setAllowDuplicates(Boolean doAllowDuplicates);

    /**
     * Indicates if the container maintains the rowIndex of the objects
     */

    Boolean getSetRowIndex();
    void setRowIndex(Boolean doSetRowIndex);

    /**
     * Controls wether rows are only removed from the container or are deleted from the database
     * for further details see the remove section
     */
    Boolean getDeleteOnRemove();
    void setDeleteOnRemove(Boolean deleteOnRemove);


    /**
     * Key of the Object you want to perform an action on, for on example see remove() method; 
     */
    Object getContextRowKey();
    void setContextRowKey(Object contextRowKey);

    /**
     *============================================================
     * LIST STANDARD METHODS
     *============================================================
     */

    Integer getSize();
    Boolean getIsEmpty();
    void clear();

    /**
     * Evals if the container contains the baseObject passed in 
     */
    Boolean contains(Object key);
    

    /**
     *============================================================
     * GETTER (BASIC)
     *============================================================
     */

    ab_BaseObject getRow(integer index);
    
    /**
     * Lookup a row by it's object Id
     * @throws null-pointer if ALLOW_DUPLICATES
     */
    ab_BaseObject getRow(Object key);
    
    /**
     * Returns all Rows
     */
    List<ab_BaseObject> getRows();
    /**
     * Returns a list containing all selected rows
     */
    List<ab_BaseObject> getSelectedObjects();
    
    
    /**
     * Extract the Object Ids
     */
    List<Object> getRowKeys(Boolean onlySelected);

    /**
     * Main getter, returns either all or only selected records
     */
    List<ab_BaseObject> getRows(Boolean onlySelected);


    /**
     *============================================================
     * SETTER
     *============================================================
     */

    /**
     * Assign a list of baseObjects as the rows
     */
    void setRows(List<ab_BaseObject> baseObjects);

    /**
     * Fill Container from a StandardSetController
     */
    void setRows(ApexPages.StandardSetController stdCon);
    /** 
     * accepts any sObject List, wraps the object in ab_BaseObjects and stores 'em
     */
    void setRows(List<sObject> sObjects);

    /**
     * As for SetController, allow users to set selected records
     */
     void setSelected(List<ab_BaseObject> selected);
    
     void addRow(sObject PsObject);

    /**
     * @see addRow(ab_BaseObject);
     */
     void addRows(List<ab_BaseObject> baseObjects);

    /**
     * Main method to store a BaseObject in the container. It maintains indicies, sets the rowIndex
     * and prevent's dupes from being stored if not disabled
     */
     void addRow(ab_BaseObject bo);


    /**
     *============================================================
     * REMOVE
     *
     * example for visualforce inline action
     *
     * ...
     * <apex:column id=="deleteCol">
     *    <apex:commandLink value="Delete" action="{!container.removeRow}">
     *      <apex:param name="contextRowKey" value="{!row.ObjectId}" assignTo="{!container.contextRowKey}"/>
     *      <apex:param name="deleteOnRemove" value="true" assignTo="{!container.deleteOnRemove}"/>
     *    </apex:commandLink>
     * </apex:column>
     * ...
     *
     *
     *
     * example usage for mass list action
     * 
     * <apex:commandButton value="Delete" 
     *        onclick="Are you sure you want to delete all selected records" 
     *        title="Click to delete selected records">
     *      <apex:param name="deleteOnRemove" value="true" assignTo="{!container.deleteOnRemove}"/>
     * </apex:commandButton>
     *
     * <apex:commandButton value="Remove" 
     *        title="Click to delete selected records">
     *      <apex:param name="deleteOnRemove" value="true" assignTo="{!container.deleteOnRemove}"/>
     * </apex:commandButton>
     *
     *============================================================
     */
     void removeSelected();
    /**
     * Use this method for inline removal in visualforce pages
     */
     void remove();

    /**
     * Remove using the index
     */
     void remove(Integer index);
    /**
     * Remove using the row key
     */
     void remove(Object key);

    /**
     * Remove any Object which ObjectId or RecordId is contained in the keys param
     * central remove method used by all other 
     */
     void removeRows(List<Object> keys);


     /**
     *============================================================
     * GETTER (ADV)
     *============================================================
     */

    /**
     * Extracts sObjects wrapped inside rows. set param true to filter on selected
     */
    List<sObject> getsObjects(Boolean onlySelected);

    /**
     * same as above, in addition it accepts a sObject list, extracted records are stored in 
     */
    List<sObject> getsObjects(Boolean onlySelected, List<sObject> concreteList);

    /** 
     * instead of just extracting the direct sObjects, specifiy a Childrelationship Key to extract
     * sObjects from those as well
     */
    List<sObject> getChildrensObjects(Object crsKey, Boolean onlySelected);

    /**
     * same as above, but with concrete sObject List (USE TO PERFORM DIRECT DML ON CHILDREN)
     */
    List<sObject> getChildrensObjects(Object crsKey, Boolean onlySelected,List<sObject> concreteList);

    /**
     * Extract children from the rows, using the specified CRSkey
     */
    ab_BaseContainer getChildren(Object crsKey,Boolean onlySelected);


    /**
     *============================================================
     * UTILS
     *============================================================
     */

    /**
     * Rebuild indices and resets the rowIndex for the baseObjects 
     */
    void maintainIndices();

    /**
     * sorts the rows using the sortOrder value
     */
    void sortByOrder();

    /**
     * method to extract sObject records from inside baseObects
     */
    List<sObject> getsObjects(List<ab_BaseObject> baseObjects, List<sObject> target);

    List<Object> getRowKeys(List<ab_BaseObject> baseObjects);

}