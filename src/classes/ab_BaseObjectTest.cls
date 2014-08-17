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
 * @description Unit Tests for ab_BaseObjectAbstract 
 */ 
@isTest
private class ab_BaseObjectTest {


    private static testMethod void testMain(){
        Account acc = new Account();
        acc.Name = 'bo_test_Account';
        insert acc;
        Test.startTest();

        system.debug('-------------------------');
        system.debug('test__ab_BaseObjectTest.testsObject() started');
        system.debug('-------------------------');

        ab_BaseObject bo = new ab_BaseObjectAbstract (acc);
        // of cours the object equals to itself
        system.assertEquals(true, bo.equals(bo));
        // since we passed in a sObject DataType is RECORD
        system.assertEquals(ab_BaseObjectType.RECORD, bo.getObjectType());
        system.assertEquals(acc,(Account)bo.getStdCon().getRecord());

        // Account goes in, and comes back via getsObject()
        system.assertEquals(acc, bo.getsObject());
        system.assertEquals(false, bo.getIsNew());

        // ... getRecordId() and getObjectId() return both the account's id ...
        system.assertEquals(acc.id, bo.getRecordId());
        system.assertEquals(acc.id, bo.getObjectId());

        // ... but if the record is unsaved ...
        bo = new ab_BaseObjectAbstract();

        bo.setsObject(new Account(Name = 'TestAccount1'));
        // ... a random long is return as the ObjectId instead of an accountId
        system.assertNotEquals(true, ((String)bo.getObjectId()).startsWith(Account.sObjectType.getDescribe().getKeyPrefix()));

        // Setting and getting field values
        Object nameObj = 'TestAccount1.1';
        bo.setValue('Name', nameObj);
        system.assertEquals(nameObj, bo.getValue('Name'));        

        // Describe Methods
        // 
        system.assertEquals(acc.getsObjectType().getDescribe().getKeyPrefix(), bo.getDescribe().getKeyPrefix());
        system.assertEquals(acc.getsObjectType().getDescribe().getLabel(), bo.getObjectLabel());
        system.assertEquals(acc.getsObjectType().getDescribe().getName(), bo.getObjectName());

        // check Object keys
        // ... passing the ObjectId evals to true ...
        system.assertEquals(true,bo.checkKey(bo.getObjectId()));
        // ... but passing a string other than the record or object id
        system.assertEquals(false, bo.checkKeys(new Set<Object>{'NO_KEY_STRING'}));

        // Common Features
        //
        // by default the record is not selected and ...
        system.assertEquals(false, bo.getSelected());
        // ... the row index returns 0, because it is null
        system.assertEquals(0,bo.getRowIndex());
        // set the index and ...
        bo.setRowIndex(1);
        // ... it returns the same as we set
        system.assertEquals(1, bo.getRowIndex());

        // Errors
        bo.addError('Error');
        system.assertEquals(1,bo.getErrors().size());
        bo.clearErrors();
        system.assertEquals(true,bo.getErrors().isEmpty());
        
        try {
        	bo.throwException('test');
        } catch(Exception ex){
        	system.assertEquals(true, ex instanceof ab_Exception);
        }

        Test.stopTest();

        system.debug('-------------------------');
        system.debug('test__ab_BaseObjectTest.testsObject() stopped');
        system.debug('-------------------------');        
    }

    /**
     * Tests for wrapping userObjects inside
     */
    private static testMethod void testUserObjects(){
        Test.startTest();

        system.debug('-------------------------');
        system.debug('test__ab_BaseObjectTest.testUserObjects() started');
        system.debug('-------------------------');


        // NONE OBJECT   
        ab_BaseObject noneuserObject = new ab_BaseObjectAbstract();
        system.assertEquals(ab_BaseObjectType.NONE, noneUserObject.getObjectType());


        // APEX OBJECT
        Object strObj = 'String';
        ab_BaseObject apexUserObject = new ab_BaseObjectAbstract(strObj);
        system.assertEquals(strObj, apexUserObject.getUserObject());

        ab_BaseObject containerUserObject = new ab_BaseObjectAbstract();
        containerUserObject.setUserObject(new ab_BaseContainerAbstract());
        boolean checkInstance = containerUserObject.getUserObject() instanceof ab_BaseContainer;
        system.assertEquals(true,checkInstance);
        system.assertEquals(ab_BaseObjectType.CONTAINER, containerUserObject.getObjectType());
        Test.stopTest();
        
        system.debug('-------------------------');
        system.debug('test__ab_BaseObjectTest.testUserObjects() stopped');
        system.debug('-------------------------');        
    }

}