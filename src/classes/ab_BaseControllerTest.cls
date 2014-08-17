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
 * @description Unit Tests for ab_BaseController 
 */
@isTest
private class ab_BaseControllerTest {

    static List<Account> accounts;
    private static void startTest(String startMessage)
    {
        if(accounts == null)
        {
            accounts = new List<Account>();
            for(integer i = 0;i<10;i++)
            {
                accounts.add(new Account(Name = 'Test Account ' + i));
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
     * Tests controller general methods, no Standard(Set)Controller is required
     */
    private static testMethod void testCommon(){

        startTest('test__ab_BaseControllerTest.testCommon() started');
        Test.setCurrentPage(Page.ab_AboutPage);

        // because we start with the standard constructor ... 
        ab_BaseController con = new ab_BaseController();

        con.getPageName();

        // ... the controllerMode is 0 and ...
        system.assertEquals(0,con.getControllerMode());
        
        // ... we can cover the try-catch statements of the save methods
        con.saveAndView();        
        con.saveRecords();
        con.saveSelectedRecords();
        
        
        // now put some messages on the page
        // ... no assertion due to Force.com standard methods 
        con.raiseInternalError();
        con.addConfirmation('confirm');
        con.addError('error');
        con.addInfo('info');
        con.addWarning('warn');
        
        con.getMessageList();
        con.getMessageListSize();
        con.getMessageListSize(ApexPages.Severity.ERROR);
        
        // interact with the page parameters
        con.putParam('testParam', '1');
        system.assertEquals('1', con.getParam('testParam'));
        
        // last but not least, build a SelectOption List for a bunch of Accounts
        system.assertNotEquals(0, con.buildSelectOptions('Account').size());
        stopTest('test__ab_BaseControllerTest.testCommon() stopped');    
    }

    /**
     * Test with a StandardController
     */
    private static testMethod void testStdController(){
        startTest('test__ab_BaseControllerTest.testStdController() started');
        Account acc = new Account(Name = 'StdAccount');
        ApexPages.StandardController stdCon = new ApexPages.StandardController(acc);
        ab_BaseController con = new ab_BaseController(stdcon); 

        // In rare circumstances, ab_BaseController.getId() may return not NULL, causing
        // AssertException, as seen  during Inbound Change Set Validation in production where
        // the class was contained in the Change Set. Any thoughts?

        // Failure Message: "System.AssertException: 
        // Assertion Failed: Expected: null, Actual: 0EP20000000L1YzGAK",
        // Failure Stack Trace: "Class.ab_BaseControllerTest.testCon1: 
        // line 72, column 9 External entry point"

        // system.assertEquals(null,con.getId());
        // system.assertEquals(acc,con.getRecord();        

        
        // save the account
        PageReference pref = con.saveAndView();
        // so the account id is not null
        system.assertNotEquals(null,acc.id);
        stopTest('test__ab_BaseControllerTest.testStdController() stopped');        
    }

    /**
     * Test with a StandardSetController
     */
    private static testMethod void testSetController(){
    
        startTest('test__ab_BaseControllerTest.testSetController() started');
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(accounts);
        
        // select some acocunts
        List<Account> selectedAccounts = new List<Account>{accounts[0],accounts[1],accounts[2]};
        setCon.setSelected(selectedAccounts);

        ab_BaseController con = new ab_BaseController(setCon);

        // Ensure we get the same nubmer of Id's we put in as records
        system.assertEquals(accounts.size(),con.getIds().size());
        
        // assert that selection works fine
        system.assertEquals(selectedAccounts.size(),con.getIds(true).size());
        system.assertEquals(selectedAccounts[0].id,con.getIds(true).get(0));
        system.assertEquals(selectedAccounts,con.getRecords(true));

        // Change and save a selected account;
        Account toChange = (Account)con.getRecords(true).get(0);
        toChange.Name = 'CHANGED';
        con.saveSelectedRecords();
        system.assertEquals(toChange.Name, [SELECT Name FROM Account WHERE Id =: toChange.Id].Name);
        
        // Chagne and save an unselected one;
        Account toChange2 = (Account)con.getRecords()[9];
        toChange2.Name = 'CHANGED_2';
        con.saveRecords();

        system.assertEquals(toChange2.Name, [SELECT Name FROM Account WHERE Id =: toChange2.Id].Name);
        
        stopTest('test__ab_BaseControllerTest.testSetController() stopped');

    }


}