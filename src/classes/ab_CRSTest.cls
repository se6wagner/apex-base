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
 * @description Unit Test for ab_BaseObject and ab_BaseContainer Relationship Methods 
 */
@isTest
private class ab_CRSTest {

    static Account account;
    static ConcreteBO accountExt;
    static List<ConcreteBO> accountExts;
    static List<Contact> contacts;
    static String crsKey = 'Contacts';

    private static void startTest(String startMessage){
        if(account == null)
        {
            List<Account> accounts = new List<Account>();
            accountExts = new List<ConcreteBO>();
            contacts = new List<Contact>();


            for(integer i = 0;i<10;i++)
            {
                Account a = new Account(Name = 'Test_Acount');
                accounts.add(a);
                accountExts.add(new ConcreteBO(a));
            }
            insert accounts;

            account = accounts.get(0);
            accountExt = accountExts.get(0);

            for(ConcreteBO bo : accountExts)
            {
                List<Contact> acons = new List<Contact>(); 
                for(integer i = 0;i<3;i++)
                {
                    Contact c = new Contact(LastName = 'Contact' + 1);
                    c.AccountId = i != 0 ? bo.getRecordId() : null;
                    acons.add(c);
                }
                contacts.addAll(acons);
                bo.registerCRS(crsKey,acons);
            }
        }
        Test.startTest();
        system.debug('-------------------------');
        system.debug(startMessage);
        system.debug('-------------------------');
    }



    /**
     * class for testing purposes
     */
    private class ConcreteBO extends ab_BaseObjectAbstract {
        public ConcreteBO(sObject record){
            super(record);
        }
    }

    /**
     * Unit Test for CRS method contained in ab_BaseObject
     */
    private static testMethod void testObject(){
        
        startTest('test__ab_CRSTest.testObject() started');
        // since the realationship has not yet been registered, it's not valid
        system.assertEquals(false, accountExt.isValidCRS('crsKey'));

        // therefore register it
        accountExt.registerCRS(crsKey, contacts);
        // now the crs should be valid
        system.assertEquals(true, accountExt.isValidCRS(crsKey));
        // contacts go in, and go out
        system.assertEquals(contacts, accountExt.getChildren(crsKey).getsObjects(false));
        system.assertEquals(accountExt.getChildren(crsKey), accountExt.getChildrenList().get(0));

        accountExt.setForeignKeyOnChildren(crsKey, 'AccountId');
        system.assertEquals(account.id, contacts[0].AccountId);

        Test.stopTest();
        system.debug('-------------------------');
        system.debug('test__ab_CRSTest.testObject() stoped');
        system.debug('-------------------------');
    }



    /**
     * Unit Test for CRS methods in ab_BaseObject not covered by testObject()
     */
    private static testMethod void testContainer(){
        startTest('test__ab_CRSTest.testContainer() started');

        ab_BaseContainer abc = new ab_BaseContainerAbstract();
        abc.setRows(accountExts);
        
        system.assertEquals(contacts,abc.getChildrensObjects(crsKey, false));
        
        Boolean success = false;
        try{
        	upsert(abc.getChildrensObjects(crsKey,false,new List<Contact>()));
        	success = true;
        } catch(Exception ex){
        	success = false;
        }
        system.assertEquals(true,success);
        Test.stopTest();
        system.debug('-------------------------');
        system.debug('test__ab_CRSTest.testContainer() stoped');
        system.debug('-------------------------');
    }

}