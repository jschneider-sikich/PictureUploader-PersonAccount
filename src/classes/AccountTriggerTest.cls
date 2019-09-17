/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountTriggerTest {

    @TestSetup
    static void setupData(){

        // create person account
        Account newPerson = new Account(
            firstName = 'first',
            lastName = 'last',
            recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert newPerson;
        
        Contact newPersonContact = [ SELECT id FROM contact where accountId = :newPerson.id ];

        // create household
        Account newHousehold = new Account(
            name = 'Test Household',
            recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId()
        );
        insert newHousehold;
        
        // create account contact relation
        AccountContactRelation newAcr = new AccountContactRelation(
            accountId = newHousehold.id,
            contactId = newPersonContact.id,
            FinServ__PrimaryGroup__c = true,
            FinServ__Primary__c = true,
            FinServ__Rollups__c = 'All',
            Roles = 'Member'
        );
        insert newAcr;
    }

    @isTest
    private static void test_changeHouseholdPrimaryAdvisor(){

        User newPrimaryAdvisor = [ SELECT id FROM user where profile.name = 'System Administrator' and id != :UserInfo.getUserId() LIMIT 1 ];
        Account household = [ SELECT id, ownerId FROM account WHERE recordType.name = 'Household' ]; 
        
        Test.startTest();
        
        // update the household's owner
        household.ownerId = newPrimaryAdvisor.id;
        update household;
        
        Test.stopTest();

        household = [ SELECT id, ownerId FROM account WHERE id = :household.id ];
        
        // retrieve account related to the household to confirm the owner matches the household's new owner
        AccountContactRelation acr = [ SELECT contact.account.ownerId FROM AccountContactRelation WHERE accountId = :household.id ];

        System.assertEquals( true, acr.contact.account.ownerId == household.ownerId );  // assert the contact's account's owner matches the household's new owner
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test        
        
        Account a = new Account();
        a.Name = 'Nameacc'; 
        a.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        insert a;
        
        Contact c1 = new Contact(LastName = 'Lastname', Firstname = 'FN1',AccountId = a.Id);
        insert c1;
        Contact c2 = new Contact(LastName = 'Lastname', Firstname = 'FN2',AccountId = a.Id);
        insert c2;
        Contact c3 = new Contact(LastName = 'Lastname2', Firstname = 'FN3',AccountId = a.Id);
        insert c3;
        
                
        Account a2 = new Account(Name = 'Nameacc2',Primary_HH_Member__c=c1.id,Secondary_HH_Member__c=c2.id);
        insert a2;
        Account a3 = new Account(Name = 'Nameacc3',Primary_HH_Member__c=c1.id,Secondary_HH_Member__c=c3.id);
        insert a3;
        Account a4 = new Account(Name = 'Nameacc3',Primary_HH_Member__c=c1.id);
        insert a4;
    }
}
