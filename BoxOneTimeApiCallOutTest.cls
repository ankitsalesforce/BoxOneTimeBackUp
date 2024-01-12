@isTest
public class BoxOneTimeApiCallOutTest {
    
    
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
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxAccountApiMockCallout());
        System.Test.startTest();
        BoxOneTimeApiCallOut.bulkfolderCreate(new List<String>{'Test'});
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
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxCaseApiMockCallout());
        System.Test.startTest();
        BoxOneTimeApiCallOut.bulkfolderCreate(new List<String>{'Test'});
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
    
    
    
    // BoxOneTimeFilesupload Test 201
    @isTest
    public static void BoxOneTimeFilesuploadTestCallout_201(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account',Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );      
        insert contentVersion_1; 
        system.debug('contentVersion_1 >>== '+contentVersion_1);
        
        ContentVersion contentVersionObj = [SELECT Id, Title,versionData, FileExtension,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string contentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1].contentdocumentid;
        system.debug('contentId >> '+contentId);
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = parentAccount2.id; // Test Account Id
        contentlink.contentdocumentid = contentId; // contentId
        contentlink.ShareType = 'V';
        insert contentlink;
        system.debug('contentlink >>== '+contentlink);
        
        Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name=testAccount.id,Box_FolderId__c=parentAccount2.Id,Operation_Status__c='Created Folder',Number_Of_Attempt__c=1, salesforce_File_Id__c=contentId,Status_Code__c=201);
        insert objBox;  
        BoxOneTimeAPiCallOut.getBoxCallOutInstance(objBox,201);
        system.debug('objBox >>++ '+objBox);
        
       
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxOneTimeFilesuploadTestCallout_201());
        System.Test.startTest();
        map<string,BLOB> fileNameWithBase64data = new map<string,blob>();
        fileNameWithBase64data.put('Test', contentVersionObj.VersionData);        
        Map<String, List<String>> folderIdWithFileName = new  Map<String, List<String>>();
        folderIdWithFileName.put('Test', new List<String>{'Test'});        
        String fileBody = 'Test';        
        map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
        fileNamewithParent.put('Test', new List<String>{'Test'});        
        map<String,String> FileIdWithLabel = new map<String,String>();
        FileIdWithLabel.put('Test', 'Test');        
        Map<String, String> fileLabelWithFolderId = new Map<String, String>();
        fileLabelWithFolderId.put(parentAccount2.Id, 'Test'); 
        system.debug('fileLabelWithFolderId >>++ '+fileLabelWithFolderId);
        list<String> boxIdToUpdate = new list<String>();
        boxIdToUpdate.add(objBox.Id); 
        system.debug('objBox.Id >>++ '+objBox.Id);
        BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileNameWithBase64data,folderIdWithFileName,fileBody,fileNamewithParent,FileIdWithLabel,fileLabelWithFolderId,boxIdToUpdate);
        System.Test.stopTest();
        
    }
    
    public class BoxOneTimeFilesuploadTestCallout_201 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;  
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', parentAccount2.Id);
            res.setBody('{"entries":[{"name":"Test","parent":{"name":"Test","id":"test"}}]}');
            res.setStatusCode(201);
            return res;
        }
    }   
    
    
    // BoxOneTimeFilesupload Test 2011
    @isTest
    public static void BoxOneTimeFilesuploadTestCallout_2011(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account',Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );      
        insert contentVersion_1; 
        system.debug('contentVersion_1 >>== '+contentVersion_1);
        
        ContentVersion contentVersionObj = [SELECT Id, Title,VersionData, FileExtension,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string contentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1].contentdocumentid;
        system.debug('contentId >> '+contentId);
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = parentAccount2.id; // Test Account Id
        contentlink.contentdocumentid = contentId; // contentId
        contentlink.ShareType = 'V';
        insert contentlink;
        system.debug('contentlink >>== '+contentlink);
        
        Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name=testAccount.id,Box_FolderId__c=parentAccount2.Id,salesforce_File_Id__c=contentId,Status_Code__c=201);
        insert objBox;        
        BoxOneTimeAPiCallOut.getBoxCalloutInstance(testAccount.id,testAccount.id,'1403327114360',contentId,201);
        system.debug('objBox >>++ '+objBox);
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxOneTimeFilesuploadTestCallout_2011());
        System.Test.startTest();
         map<string,BLOB> fileNameWithBase64data = new map<string,blob>();
        fileNameWithBase64data.put('Test', contentVersionObj.VersionData); 
        
        Map<String, List<String>> folderIdWithFileName = new  Map<String, List<String>>();
        folderIdWithFileName.put('Test', new List<String>{'Test'});
        
        String fileBody = 'Test';
        
        map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
        fileNamewithParent.put('Test', new List<String>{'Test'});
        
        map<String,String> FileIdWithLabel = new map<String,String>();
        FileIdWithLabel.put('Test', 'Test');
        
        Map<String, String> fileLabelWithFolderId = new Map<String, String>();
        fileLabelWithFolderId.put('Test', 'Test');
        
        list<String> boxIdToUpdate = new list<String>();
        boxIdToUpdate.add(objBox.Id);   
        BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileNameWithBase64data,folderIdWithFileName,fileBody,fileNamewithParent,FileIdWithLabel,fileLabelWithFolderId,boxIdToUpdate);
       
        System.Test.stopTest();
       
    }
    
    // BoxOneTimeFilesupload Test 2011
    @isTest
    public static void BoxOneTimeFilesuploadTest(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account',Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );      
        insert contentVersion_1; 
        system.debug('contentVersion_1 >>== '+contentVersion_1);
        
        ContentVersion contentVersionObj = [SELECT Id, Title,versionData, FileExtension,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string contentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1].contentdocumentid;
        system.debug('contentId >> '+contentId);
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = parentAccount2.id; // Test Account Id
        contentlink.contentdocumentid = contentId; // contentId
        contentlink.ShareType = 'V';
        insert contentlink;
        system.debug('contentlink >>== '+contentlink);
        
               
        BoxOneTimeAPiCallOut.getBoxCalloutInstance(testAccount.id,testAccount.id,'1403327114360',contentId,201);
    
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxOneTimeFilesuploadTestCallout_2011());
        System.Test.startTest();
         map<string,BLOB> fileNameWithBase64data = new map<string,blob>();
        fileNameWithBase64data.put('Test', contentVersionObj.VersionData); 
        
        
        Map<String, List<String>> folderIdWithFileName = new  Map<String, List<String>>();
        folderIdWithFileName.put('241512027633', new List<String>{'Test'});
        
        String fileBody = 'Test';
        
        map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
        fileNamewithParent.put('Test', new List<String>{parentAccount2.id});
        
        map<String,String> FileIdWithLabel = new map<String,String>();
        FileIdWithLabel.put(contentId, 'Test');
        
        Map<String, String> fileLabelWithFolderId = new Map<String, String>();
        fileLabelWithFolderId.put('Test', '241512027633');
        
        list<String> boxIdToUpdate = new list<String>();
       
        
        BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileNameWithBase64data,folderIdWithFileName,fileBody,fileNamewithParent,FileIdWithLabel,fileLabelWithFolderId,null);
        System.Test.stopTest();
       
    }
    
    public class BoxOneTimeFilesuploadTestCallout_2011 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', parentAccount2.Id);
            res.setBody('{"entries":[{"name":"Test","parent":{"name":"Test","id":"test"}}]}');
            res.setStatusCode(201);
            return res;
        }
    } 
    
    // BoxOneTimeFilesupload Test 401
    @isTest
    public static void BoxOneTimeFilesuploadTestCallout_401(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account',Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',Box_Folder_Id__c='12345',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',Box_Folder_Id__c='12345',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );      
        insert contentVersion_1; 
        system.debug('contentVersion_1 >>== '+contentVersion_1);
        
        ContentVersion contentVersionObj = [SELECT Id, Title,VersionData, FileExtension,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        string contentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1].contentdocumentid;
        system.debug('contentId >> '+contentId);
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = parentAccount2.id; // Test Account Id
        contentlink.contentdocumentid = contentId; // contentId
        contentlink.ShareType = 'V';
        insert contentlink;
        system.debug('contentlink >>== '+contentlink);
        
        Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name=testAccount.id,Box_FolderId__c=testAccount.Id,salesforce_File_Id__c=contentId,Number_Of_Attempt__c = 1,Status_Code__c=201);
        insert objBox;  
        BoxOneTimeAPiCallOut.getBoxCalloutInstance(401);
        
        system.debug('objBox >>++ '+objBox);
        /*Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name=testAccount.id,Box_FolderId__c=testAccount.Id, Operation_Status__c='Created Folder', Number_Of_Attempt__c = 1,salesforce_File_Id__c='12345',Status_Code__c=200);
insert objBox;*/
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxOneTimeFilesuploadTestCallout_401());
        System.Test.startTest();
         map<string,BLOB> fileNameWithBase64data = new map<string,blob>();
        fileNameWithBase64data.put('Test', contentVersionObj.VersionData); 
        
        Map<String, List<String>> folderIdWithFileName = new  Map<String, List<String>>();
        folderIdWithFileName.put('Test', new List<String>{'Test'});
        
        String fileBody = 'Test';
        
        map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
        fileNamewithParent.put('Test', new List<String>{'Test'});
        
        map<String,String> FileIdWithLabel = new map<String,String>();
        FileIdWithLabel.put('Test', 'Test');
        
        Map<String, String> fileLabelWithFolderId = new Map<String, String>();
        fileLabelWithFolderId.put('Test', 'Test');
        
        list<String> boxIdToUpdate = new list<String>();
        boxIdToUpdate.add(objBox.Id);
        BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileNameWithBase64data,folderIdWithFileName,fileBody,fileNamewithParent,FileIdWithLabel,fileLabelWithFolderId,boxIdToUpdate);
        System.Test.stopTest();
       
    }
    
    public class BoxOneTimeFilesuploadTestCallout_401 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', testAccount.Id);
            res.setBody('{"context_info":{"Unauthorized":{"name":"test"}}}');
            res.setStatusCode(401);
            return res;
        }
        
    }
    // BoxOneTimeFilesupload Test 409
    @isTest 
    public static void BoxOneTimeFilesuploadTestCallout_409(){
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
        
        Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name='12345',Box_FolderId__c='12345', Operation_Status__c='Created Folder', Number_Of_Attempt__c = 1,salesforce_File_Id__c='12345',Status_Code__c=409);
        insert objBox; 
        
        BoxOneTimeAPiCallOut.getBoxCalloutInstance(testAccount.id,testAccount.Id,409,'Error');
        
        System.Test.setMock(HttpCalloutMock.Class, new BoxOneTimeFilesuploadTestCallout_409());
        System.Test.startTest();
         map<string,BLOB> fileNameWithBase64data = new map<string,blob>();
         
        
        Map<String, List<String>> folderIdWithFileName = new  Map<String, List<String>>();
        folderIdWithFileName.put('Test', new List<String>{'Test'});
        
        String fileBody = 'Test';
        
        map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
        fileNamewithParent.put('Test', new List<String>{'Test'});
        
        map<String,String> FileIdWithLabel = new map<String,String>();
        FileIdWithLabel.put('12345', 'Test');
        
        Map<String, String> fileLabelWithFolderId = new Map<String, String>();
        fileLabelWithFolderId.put('12345', 'Test');
        
        list<String> boxIdToUpdate = new list<String>();
        boxIdToUpdate.add(objBox.Id);
        BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileNameWithBase64data, folderIdWithFileName, fileBody,fileNamewithParent,FileIdWithLabel, fileLabelWithFolderId, boxIdToUpdate);
        System.Test.stopTest();
    }
    
    public class BoxOneTimeFilesuploadTestCallout_409 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;
            Contact con=new Contact(FirstName='Test1', AccountId=testAccount.Id,LastName='Test2', Email='test@gmail.com',Phone='1234567890');
            insert con;
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', con.Id);
            res.setBody('{"context_info":{"conflicts":{"name":"Test"}}}');
            res.setStatusCode(409);
            return res;
        }
    }
    
    
    // failedBoxFilesupload Test 500
    @isTest
    public static void failedBoxFilesuploadTest_500(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name=testAccount.id,Box_FolderId__c='123456', Number_Of_Attempt__c = 1,salesforce_File_Id__c='12345');
        insert objBox; 
        BoxOneTimeAPiCallOut.getBoxCalloutInstance(testAccount.id,500,'Error');
        
        System.Test.setMock(HttpCalloutMock.Class, new failedBoxFilesTestCallout_500());
        System.Test.startTest();
        map<string,BLOB> fileNameWithBase64data = new map<string,blob>();
       
        
        Map<String, List<String>> folderIdWithFileName = new  Map<String, List<String>>();
        folderIdWithFileName.put('Test', new List<String>{'Test'});
        
        String fileBody = 'Test';
        
        map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
        fileNamewithParent.put('Test', new List<String>{'Test'});
        
        map<String,String> FileIdWithLabel = new map<String,String>();
        FileIdWithLabel.put('12345', 'Test');
        
        Map<String, String> fileLabelWithFolderId = new Map<String, String>();
        fileLabelWithFolderId.put('12345', 'Test');
        
        list<String> boxIdToUpdate = new list<String>();
        boxIdToUpdate.add(objBox.Id);   
        BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileNameWithBase64data, folderIdWithFileName, fileBody,fileNamewithParent,FileIdWithLabel, fileLabelWithFolderId, boxIdToUpdate);
        System.Test.stopTest();
    }
    
    public class failedBoxFilesTestCallout_500 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
            Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
            insert parentAccount2;
            Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
            insert parentAccount;
            Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
            insert testAccount;
            
            Box_Callout_Status__c objBox = new Box_Callout_Status__c(Name=testAccount.id,Box_FolderId__c='123456', Number_Of_Attempt__c = 1,salesforce_File_Id__c='12345');
            insert objBox; 
            
            
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> requestMap = new map<String, String>();
            requestMap.put('id','test');
            requestMap.put('name', testAccount.Id);
            res.setBody('{"entries":{"Error":"An error has occured."}}');
            res.setStatusCode(500);
            return res;
        }
    }
    
    
    
}