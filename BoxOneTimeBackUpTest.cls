@isTest
public class BoxOneTimeBackUpTest {
     
    @IsTest
    public static void test_AccountfolderCreate(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;
        
         
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );      
        insert contentVersion_1; 
        system.debug('contentVersion_1 >>== '+contentVersion_1);
        
        ContentVersion contentVersionObj = [SELECT Id, Title, FileExtension,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string contentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1].contentdocumentid;
        system.debug('contentId >> '+contentId);
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = testAccount.id; // Test Account Id
        contentlink.contentdocumentid = contentId; // contentId
        contentlink.ShareType = 'V';
        insert contentlink;
        system.debug('contentlink >>== '+contentlink);
        
         Files_BackUp__c objFile = new Files_BackUp__c(File_Id__c=contentId,ParentID__c=testAccount.Id, Status__c='Waiting for Box Upload');
        insert objFile;
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxAccountApiMockCallout());
		System.Test.startTest();
        SchedulableContext sc = null;
       		BoxOneTimeBackUp box = new BoxOneTimeBackUp();
        box.execute(sc);   
        
        System.Test.stopTest();
    }
    
    @IsTest
    public static void test_CasefolderCreate(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;
        
        
         
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );      
        insert contentVersion_1; 
        system.debug('contentVersion_1 >>== '+contentVersion_1);
        
        ContentVersion contentVersionObj = [SELECT Id, Title, FileExtension,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string contentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1].contentdocumentid;
        system.debug('contentId >> '+contentId);
        
        ContentDocumentLink contentlink = new ContentDocumentLink(); 
        contentlink.LinkedEntityId = testCase.id; // Test Case Id
        contentlink.contentdocumentid = contentId; // contentId
        contentlink.ShareType = 'V';
        insert contentlink;
        system.debug('contentlink >>== '+contentlink);
        
         Files_BackUp__c objFile = new Files_BackUp__c(File_Id__c=contentId,ParentID__c=testCase.Id, Status__c='Waiting for Box Upload');
        insert objFile;
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxCaseApiMockCallout());
        System.Test.startTest();
        SchedulableContext sc = null;
        BoxOneTimeBackUp box = new BoxOneTimeBackUp();
        box.execute(sc);   
        System.Test.stopTest();
    }
    
    //HttpCalloutMock for test_folderCreate for Account
    public class BoxAccountApiMockCallout implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;
            
            Case testCase = new Case(
                Property_Name__c = testAccount.Id,
                AccountId = testAccount.Id,
                Location__c = testAccount.Id
            );
            insert testCase;
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', parentAccount2.Id);
            res.setBody(System.JSON.serialize(requestMap));
            res.setStatusCode(201);
            return res;
        }
    } 
    
    //HttpCalloutMock for test_folderCreate for Case
    public class BoxCaseApiMockCallout implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;
            
            Case testCase = new Case(
                Property_Name__c = testAccount.Id,
                AccountId = testAccount.Id,
                Location__c = testAccount.Id
            );
            insert testCase;
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', testCase.Id);
            res.setBody(System.JSON.serialize(requestMap));
            res.setStatusCode(200);
            return res;
        }
    } 
    
}