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
 * @description Controller for the apex-base About Page 
 */
public with sharing class ab_AboutPageController {

    public String TEST_URL_BASE {get {return '/setup/build/runApexTest.apexp?';}}
    public PageReference PROJECT_URL {get {return new PageReference('http://code.google.com/p/apex-base/');}}
    public PageReference CLASSES_TRUNK_URL_BASE {get {return new PageReference(PROJECT_URL.getUrl() + 'source/browse/trunk/apex-base/src/classes/');}}

    List<ApexClass> abClasses;

    public List<ApexClass> getClassList(){
        if(abClasses == null){
            abClasses = new List<ApexClass>();
            abClasses = [SELECT Id, Name, APIVersion, IsValid, LastModifiedById, LastModifiedDate FROM ApexClass WHERE Name Like 'ab_%' ORDER BY Name];
        }
        return abClasses;
    }


    private static testMethod void testCon(){
        ab_AboutPageController con = new ab_AboutPageController();
        string urlStr = con.TEST_URL_BASE;
        PageReference url = con.PROJECT_URL;
        url = con.CLASSES_TRUNK_URL_BASE;
        con.getClassList();
    }
    
}