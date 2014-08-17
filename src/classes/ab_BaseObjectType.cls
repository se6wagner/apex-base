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
 * @description Type of Objects ab_BaseObject can contain 
 */
public enum ab_BaseObjectType {

    RECORD,         // responds to getsObject()
    CONTAINER,      // getUserObject() returns an instance of ab_BaseContainer 
    APEX,           // getUserObject() returns any other Apex Object
    NONE            // stands for NULL
}