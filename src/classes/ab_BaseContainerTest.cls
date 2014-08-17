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
 * @description Unit Tests for ab_BaseContainerAbstract 
 */
@isTest
private class ab_BaseContainerTest {

    static List<Account> accounts;
    static List<BaseObjectExt> extobjects;

    private static void startTest(String startMessage){
        if(accounts == null)
        {
            accounts = new List<Account>();
            extobjects = new List<BaseObjectExt>();
            for(integer i = 0;i<20;i++)
            {
                Account acc = new Account(Name = 'ab_acc_' + i);
                accounts.add(acc);
                extobjects.add(new BaseObjectExt(acc));
            }
            insert accounts;
        }
        Test.startTest();
        system.debug('-------------------------');
        system.debug(startMessage);
        system.debug('-------------------------');
    }

    private static void stopTest(String stopMessage){
    	Test.stopTest();
        system.debug('-------------------------');
        system.debug(stopMessage);
        system.debug('-------------------------');
    }

    /**
     * INTERNAL CLASS FOR TEST
     */
    private class BaseObjectExt extends ab_BaseObjectAbstract {
        public BaseObjectExt(sObject record){
            super(record);
        }
    }
    /**
     * Main test
     */
    private static testMethod void testContainer(){
        startTest('test__ab_BaseContainerTest.testContainer() started');
        // Empty constructor
        ab_BaseContainerAbstract abc = new ab_BaseContainerAbstract();

        // FLAGS
        abc.setRowIndex(true);
        system.assertEquals(true, abc.getSetRowIndex());

        abc.setAllowDuplicates(false);
        system.assertEquals(false,abc.getAllowDuplicates());

        abc.setContextRowKey(abc.getObjectId());
        system.assertEquals(abc.getObjectId(),abc.getContextRowKey());

        abc.setDeleteOnRemove(true);
        system.assertEquals(true,abc.getDeleteOnRemove());


        // set Rows from a sObject collection
        abc.setRows(extobjects);
        system.assertEquals(extobjects.size(),abc.getSize());
        system.assertEquals(false, abc.getIsEmpty());
        
        // validate rowIndexing works        
        system.assertEquals(1, abc.getRows().get(1).getRowIndex());

        // Pick an Object
        BaseObjectExt testBO = (BaseObjectExt)abc.getRow(2);
        // doesn't matter if we use index or objectId
        system.assertEquals(testBo, abc.getRow(testBo.getObjectId()));
        // ... of course true, we got i from the container
        system.assertEquals(true, abc.contains(testBO));


        // select the object ...
        testBO.setSelected(true);

        // ... as a result select list contains 1 record and ...
        system.assertEquals(1,abc.getSelectedObjects().size());
        testBo.setSelected(false);
        system.assertEquals(true, abc.getSelectedObjects().isEmpty());
        // now set using Arrary
        abc.setSelected(new List<ab_BaseObject>{testBo});
        system.assertEquals(1, abc.getSelectedObjects().size());

        system.assertEquals(testBO.getObjectId(), abc.getRowKeys(true).get(0));

        // by default, dupes are skipped therefore ...
        abc.addRow(testBO);
        system.assertEquals(extobjects.size(), abc.getSize());


        // ALLOW dupes
        abc.setAllowDuplicates(true);
        // ... this should increase the size
        abc.addRow(testBO);
        system.assertEquals(extobjects.size() + 1, abc.getSize());

        // ... and force the contain method to iterate through the rows instead of checking indices
        system.assertEquals(true, abc.contains(testBO));

        // DISABLE dupes and maintain the indices
        abc.setAllowDuplicates(false);
        abc.maintainIndices();
        system.assertEquals(extobjects.size(), abc.getSize());
        // finally add an additional record to the container

        // REMOVE ROWS
        // make sure we do not delete the accounts
        abc.setDeleteOnRemove(false);

        // remove by index
        abc.remove(0);
        system.assertNotEquals(extObjects[0].getObjectId(),abc.getRow(0).getObjectId());

        // remove with contextKey
        abc.setContextRowKey(abc.getRow(0).getObjectId());
        abc.remove();
        system.assertEquals(extObjects.size() - 2, abc.getSize());

        // remove by Key
        abc.remove(abc.getRow(0).getObjectId());
        system.assertEquals(extObjects.size() - 3, abc.getSize());


        // let's change the sort Order
        
        ab_BaseObject sort1 = abc.getRow(1);
        ab_BaseObject sort2 = abc.getRow(2);
        
        // switch the sort order for these 2
        sort1.setSortOrder(2);
        sort2.setSortOrder(1);
        
        abc.sortByOrder();
        system.assertEquals(sort1, abc.getRow(2));
        system.assertEquals(1, sort2.getRowIndex());

        
        
        // at the end delete selected records
        abc.setDeleteOnRemove(true);
        abc.getRow(5).setSelected(true);
        abc.getRow(10).setSelected(true);
        
        List<String> deletedIds = new List<String>();
        for(Object o : abc.getRowKeys(true)){
        	deletedIds.add((String)o);
        }
        abc.removeSelected();

        List<Account> deleteQuery = [SELECT Id FROM Account WHERE Id IN: deletedIds];
        system.assertEquals(0, deleteQuery.size());

        stopTest('test__ab_BaseContainerTest.testContainer() stopped');
    }

    /**
     * Unit Tests for sObject related Methods
     */
    private static testMethod void testsObjectContainer(){
        startTest('test__ab_BaseContainerTest.testsObjectContainer() stopped');
        
        ab_BaseContainer abc = new ab_BaseContainerAbstract();
        
        abc.setRows(accounts);
        system.assertEquals(accounts.size(), abc.getSize());
        abc.addRow(new Account(Name = 'new Account'));
        system.assertEquals(accounts.size() + 1, abc.getSize());
        system.assertEquals(0, abc.getSelectedObjects().size());
        
        // not much to test here
        abc.getsObjects(false);
        
        // only concrete methods support upsert, so here we go
        boolean success = false;
        try{
        	upsert abc.getsObjects(false, new List<Account>());
        	success = true;
        } catch(Exception ex){
            success = false;	
        }
        system.assertEquals(true, success);

        stopTest('test__ab_BaseContainerTest.testsObjectContainer() stopped');
    }


    /**
     * Unit Tests when build from SetController
     */
    private static testMethod void testSetController(){
        startTest('test__ab_BaseContainerTest.testSetController() started');
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(accounts);
        setCon.setSelected(new List<Account>{accounts.get(0),accounts.get(1)});

        ab_BaseContainer abc = new ab_BaseContainerAbstract();
        abc.setRows(setCon);
        system.assertEquals(accounts.size(), abc.getSize());
        system.assertEquals(2, abc.getSelectedObjects().size());

        stopTest('test__ab_BaseContainerTest.testSetController() stopped');        
    }

}