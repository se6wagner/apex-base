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
 */
public virtual class ab_BaseContainerAbstract extends ab_BaseObjectAbstract implements ab_BaseContainer {

    /*
     *============================================================
     * CONSTRUCTORS
     *============================================================
     */

    /**
     * @description Class constructor
     */
    public ab_BaseContainerAbstract(){
        this.rows = new List<ab_BaseObject>();
        this.indices = new Map<Object,Integer>();
        this.ALLOW_DUPLICATES = false;
        this.SET_ROW_INDEX = true;
    }

    /**
     * @description Constructor defines an BaseObject Array to store
     */
    public ab_BaseContainerAbstract(List<ab_BaseObject> baseObjects){
        this();
        setRows(baseObjects);
    }
    
    /**
     * @description Constructor defines an sObject Array to store
     */
    public ab_BaseContainerAbstract(List<sObject> sObjects){
        this();
        setRows(sObjects);
    }



    /*
     *============================================================
     * PROPERTIES AND FLAGS
     *============================================================
     */

    protected List<ab_BaseObject> rows {get;set;}
    protected Map<Object,Integer> indices {get;set;}


    /**
     * Controls wether the container prevents duplicates from being added or not, in addition it
     * affects the way contains(Object) method is executed, since no index is maintained it iterates
     * through all objects
     */
    protected Boolean ALLOW_DUPLICATES = false;

    public Boolean getAllowDuplicates(){
        return this.ALLOW_DUPLICATES;
    }
    public void setAllowDuplicates(Boolean doAllowDuplicates){
        this.ALLOW_DUPLICATES = doAllowDuplicates;
    }

    /**
     * Indicates if the container maintains the rowIndex of the objects
     */
    protected Boolean SET_ROW_INDEX = true;

    public Boolean getSetRowIndex(){
        return this.SET_ROW_INDEX ;
    }
    public void setRowIndex(Boolean doSetRowIndex){
        this.SET_ROW_INDEX  = doSetRowIndex;
    }
    
    /**
     * Controls wether rows are only removed from the container or are deleted from the database
     * for further details see the remove section
     */    
    protected Boolean DELETE_ON_REMOVE = false;

    public Boolean getDeleteOnRemove(){
        return this.DELETE_ON_REMOVE;
    }
    
    public void setDeleteOnRemove(Boolean deleteOnRemove){
        this.DELETE_ON_REMOVE = deleteOnRemove;
    }


    /**
     * Key of the Object you want to perform an action on, for on example see remove() method; 
     */
    private Object CONTEXT_ROW_KEY;

    public Object getContextRowKey(){
        return this.CONTEXT_ROW_KEY;
    }
    
    public void setContextRowKey(Object contextRowKey){
        this.CONTEXT_ROW_KEY = contextRowKey;
    }

    /*
     *============================================================
     * LIST STANDARD METHODS
     *============================================================
     */

    /**
     * @description Returns the acutal container size
     * @return Integer size
     */
    public virtual Integer getSize(){
        return this.rows.size();
    }

    /**
     * @description Evaluates if the container isEmpty()
     * @return Boolean isEmpty()
     */
    public virtual Boolean getIsEmpty(){
        return this.rows.isEmpty();
    }

    /**
     * @description Clears rows variable and indices
     */
    public virtual void clear(){
        this.rows.clear();
        this.indices.clear();
    }

    /**
     * @description Evalutes if an object is stored in the container
     * @param toCheck object to lookup in storage 
     * @return Boolean
     */ 
    public virtual Boolean contains(Object key){
        return indices.containsKey(key);
    }
    

    /*
     *============================================================
     * GETTER (BASIC)
     *============================================================
     */

    public ab_BaseObject getRow(integer i){
        return this.getRows(false).get(i);
    }
    
    /**
     * Lookup a row by it's object Id
     * @throws null-pointer if ALLOW_DUPLICATES
     */
    public ab_BaseObject getRow(Object obj){
        return this.getRow(this.indices.get(obj));
    }
    
    /**
     * Returns all Rows
     */
    public List<ab_BaseObject> getRows(){
        return this.getRows(false);
    }
    /**
     * Returns a list containing all selected rows
     */
    public List<ab_BaseObject> getSelectedObjects(){
        return this.getRows(true);
    }


    /**
     * Extract the Object Ids
     */
    public List<Object> getRowKeys(Boolean onlySelected){
        return this.getRowKeys(this.getRows(onlySelected));
    }

    /**
     * Main getter, returns either all or only selected records
     */
    public virtual List<ab_BaseObject> getRows(Boolean onlySelected){

        if(!onlySelected) return this.rows;
        List<ab_BaseObject> output = this.rows.clone();
        output.clear();
        for(ab_BaseObject bo : this.rows)
        {
            if(bo.getSelected()){
                output.add(bo);
            }
        }
        return output;
    }


    /*
     *============================================================
     * SETTER
     *============================================================
     */

    /**
     * Assign a list of baseObjects as the rows
     */
    public virtual void setRows(List<ab_BaseObject> baseObjects){
        this.rows = baseObjects.clone();
        this.clear();
        this.addRows(baseObjects);
    }

    /**
     * Fill Container from a StandardSetController
     */
    public virtual void setRows(ApexPages.StandardSetController stdCon){
        this.rows = new List<ab_BaseObject>();
        this.clear();
        
        Set<sObject> selectedSet = new Set<sObject>();
        selectedSet.addAll(stdCon.getSelected());

        for(sObject sobj : stdCon.getRecords()){
            ab_BaseObject bo = new ab_BaseObjectAbstract(sobj);
            bo.setSelected(selectedSet.contains(sobj));
            this.addRow(bo);
        }
    }
    /** 
     * accepts any sObject List, wraps the object in ab_BaseObjects and stores 'em
     */
    public virtual void setRows(List<sObject> sObjects){
        this.rows = new List<ab_BaseObject>();
        for(sObject sobj : sObjects)
        {
            this.addRow(new ab_BaseObjectAbstract(sobj));
        }
    }

    /**
     * As for SetController, allow users to set selected records
     */
    public virtual void setSelected(List<ab_BaseObject> selected){
        for(ab_BaseObject bo : selected){
            bo.setSelected(true);
            this.addRow(bo);
        }
    }
    
    public virtual void addRow(sObject PsObject){
        this.addRow(new ab_BaseObjectAbstract(PsObject));
    }

    /**
     * @see addRow(ab_BaseObject);
     */
    public virtual void addRows(List<ab_BaseObject> baseObjects){
        for(ab_BaseObject bo : baseObjects)
        {
            this.addRow(bo);
        }
    }

    /**
     * @description Core method stores objects, maintains the indices and assigns the rowIndex value
     * @param baseObject object to store in container
     */
    public virtual void addRow(ab_BaseObject baseObject){

        if(this.indices.containsKey(baseObject) && !ALLOW_DUPLICATES){
            system.debug('PREVENT DUPE');
        }
        else {
            Integer curSize = this.getSize();
            if(SET_ROW_INDEX){
                baseObject.setRowIndex(curSize);
                baseObject.setSortOrder(curSize);
            }
            // Store object and objectId in indices
            this.indices.put(baseObject,curSize);
            this.indices.put(baseObject.getObjectId(),curSize);
            this.rows.add(baseObject);    
        }
    }


    /*
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
    public virtual void removeSelected(){
        this.removeRows(getRowKeys(true));
    }
    /**
     * Use this method for inline removal in visualforce pages
     */
    public virtual void remove(){
        this.removeRows(new List<Object>{CONTEXT_ROW_KEY});
    }

    /**
     * Remove using the index
     */
    public virtual void remove(Integer index){
        this.removeRows(new List<Object>{getRow(index).getObjectId()});
    }
    /**
     * Remove using the row key
     */
    public virtual void remove(Object key){
        this.removeRows(new List<Object>{key});
    }

    /**
     * Remove any Object which ObjectId or RecordId is contained in the keys param
     * central remove method used by all other 
     */
    public virtual void removeRows(List<Object> keys){
        // create a working copy of the rows, and clear it
        List<ab_BaseObject> wcopy = this.rows.clone();
        this.clear();
        Set<Object> toRemoveSet = new Set<Object>();
        toRemoveSet.addAll(keys);

        List<sObject> toDelete = new List<sObject>();
        
        for(ab_BaseObject bo : wcopy){

            // check if we have to remove the row
            if(bo.checkKeys(toRemoveSet)){

                // delete will not work for new records, so for new skip
                if(!bo.getIsNew() && bo.getObjectType() == ab_BaseObjectType.RECORD){
                    toDelete.add(bo.getsObject());
                }
                continue;
            }
            // otherwise keep it
            this.addRow(bo);
        }
        if(DELETE_ON_REMOVE && !toDelete.isEmpty())
        {
            delete toDelete;
        }
    }


    /*
     *============================================================
     * GETTER (ADV)
     *============================================================
     */

    /**
     * Extracts sObjects wrapped inside rows. set param true to filter on selected
     */
    public List<sObject> getsObjects(Boolean onlySelected){
        return this.getsObjects(onlySelected, new List<sObject>());
    }

    /**
     * same as above, in addition it accepts a sObject list, extracted records are stored in 
     */
    public List<sObject> getsObjects(Boolean onlySelected, List<sObject> concreteList){
        return this.getsObjects(this.getRows(onlySelected),concreteList);
    }

    /** 
     * instead of just extracting the direct sObjects, specifiy a Childrelationship Key to extract
     * sObjects from those as well
     */
    public List<sObject> getChildrensObjects(Object crsKey, Boolean onlySelected){
        return this.getChildrensObjects(crsKey, onlySelected, new List<sObject>());
    }

    /**
     * same as above, but with concrete sObject List (USE TO PERFORM DIRECT DML ON CHILDREN)
     */
    public List<sObject> getChildrensObjects(Object crsKey, Boolean onlySelected,
        List<sObject> concreteList){
        return this.getsObjects(this.getChildren(crsKey,onlySelected).getRows(),concreteList);
    }

    /**
     * Extract children from the rows, using the specified CRSkey
     */
    public ab_BaseContainer getChildren(Object crsKey,Boolean onlySelected){
        List<ab_BaseObject> ccCopy = this.getRow(0).getChildren(crsKey).getRows().clone();
        ccCopy.clear();

        ab_BaseContainer container = new ab_BaseContainerAbstract(ccCopy);
        container.setRowIndex(false);

        for(ab_BaseObject bo : this.getRows(onlySelected)){
            if(bo.getChildren(crsKey) != null){
                container.addRows(bo.getChildren(crsKey).getRows());    
            }
            
        }
        return container;
    }
    

    /*
     *============================================================
     * UTILS
     *============================================================
     */

    /**
     * Rebuild indices and resets the rowIndex for the baseObjects 
     */
    public virtual void maintainIndices(){
        List<ab_BaseObject> wcopy = getRows(false).clone();
        clear();
        for(integer i = 0;i<wcopy.size();i++)
        {
            this.addRow(wcopy.get(i));
        }
    }

    /**
     * sorts the rows using the sortOrder value
     */
    public void sortByOrder(){
        // map holding objects to sort
        Map<Double,ab_BaseObject> bomap = new Map<Double,ab_BaseObject>();
        List<Double> toSort = new List<Double>();
        // store by sortOrder value
        for(ab_BaseObject bo : this.rows){
            bomap.put(bo.getSortOrder(),bo);
        }
        // store in list we are going to sort()
        toSort.addAll(boMap.keySet());
        toSort.sort();
        clear();
        // after sorting the list, loop through it to reflect sort order in collection
        for(Double d:toSort){
            addRow(bomap.get(d));
        }
    }

    /**
     * method to extract sObject records from inside baseObects
     */
    public List<sObject> getsObjects(List<ab_BaseObject> baseObjects, List<sObject> target){
        for(ab_BaseObject bo : baseObjects)
        {
            target.add(bo.getsObject());
        }
        return target;
    }

    public List<Object> getRowKeys(List<ab_BaseObject> baseObjects){
        List<Object> ids = new List<Object>();

        for(ab_BaseObject bo : baseObjects){
            ids.add(bo.getObjectId());
        }
        return ids;
    }

}