@isTest
public class BoxOneTimeFileUploadTest {

        @TestSetup
     public static void boxFolderCreateTest(){
        String ownType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        
        //Account Record
        Account objAcc = new Account(Name='Hello Owner', RecordTypeId = ownType,Box_Folder_Id__c='201256555');
        insert objAcc;
        
        //Contact record
        Contact objCon = new Contact(FirstName='Bunty', LastName='Modi', Email='sample@gmail.com', Phone='9988776655', AccountId=objAcc.Id);
        insert objCon;
        
        //Case record
        Case objCase = new Case(Status = 'Open', Origin = 'Web', Primary_Incident_type__c = 'Arrest', Property_Name__c= objAcc.Id, Subject = 'Sample Subject');
        insert objCase;  
    }
    
     @isTest
    public static void accountContentDocument(){
        list<Account> acc = [select Id,Box_Folder_Id__c from Account LIMIT 1]; 
        List<ContentVersion> cvlist = new List<ContentVersion>();
        ContentVersion objCV1 = new ContentVersion( Title = 'Sample File A',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert objCV1;
        
        ContentVersion objCV2 = new ContentVersion( Title = 'Sample File B',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
  		insert objCV2;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        list<contentDocument> contentDocs = new list<contentDocument>();
        ContentDocumentLink objCdAcc1 = New ContentDocumentLink();
        objCdAcc1.LinkedEntityId = acc[0].id;  // Account ID added
        objCdAcc1.ContentDocumentId = documents[0].Id;
        objCdAcc1.shareType = 'V';
        objCdAcc1.visibility = 'AllUsers';
        insert objCdAcc1;
        
        ContentDocumentLink objCdAcc2 = New ContentDocumentLink();
        objCdAcc2.LinkedEntityId = acc[0].id;  // Account ID added
        objCdAcc2.ContentDocumentId = documents[1].Id;
        objCdAcc2.shareType = 'V';
        objCdAcc2.visibility = 'AllUsers';
        insert objCdAcc2;
        
        list<Files_BackUp__c> fileToBeUpdate = new list<Files_BackUp__c>();
        system.Test.startTest();
       		System.enqueueJob(new BoxOneTimeFileUpload(documents,fileToBeUpdate));
        system.Test.stopTest();
        
    }
    
      
    @isTest
    public static void caseContentDocument(){
        list<Case> cases = [select Id,Box_Folder_Id__c from case LIMIT 1]; 
        List<ContentVersion> cvlist = new List<ContentVersion>();
        ContentVersion objCV1 = new ContentVersion( Title = 'Sample File A',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert objCV1;
        
        ContentVersion objCV2 = new ContentVersion( Title = 'Sample File A',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
  		insert objCV2;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        list<contentDocument> contentDocs = new list<contentDocument>();
        ContentDocumentLink objCdAcc1 = New ContentDocumentLink();
        objCdAcc1.LinkedEntityId = cases[0].id;  // Case ID added
        objCdAcc1.ContentDocumentId = documents[0].Id;
        objCdAcc1.shareType = 'V';
        objCdAcc1.visibility = 'AllUsers';
        insert objCdAcc1;
        
        ContentDocumentLink objCdAcc2 = New ContentDocumentLink();
        objCdAcc2.LinkedEntityId = cases[0].id;  // Account ID added
        objCdAcc2.ContentDocumentId = documents[1].Id; 
        objCdAcc2.shareType = 'V';
        objCdAcc2.visibility = 'AllUsers';
        insert objCdAcc2;
        
        list<Files_BackUp__c> fileToBeUpdate = new list<Files_BackUp__c>();
        system.Test.startTest();
       		System.enqueueJob(new BoxOneTimeFileUpload(documents,fileToBeUpdate));
        	BoxOneTimeFileUploadBatch bc = new BoxOneTimeFileUploadBatch(documents);
        	database.executebatch(bc);
        system.Test.stopTest();
        
    }
}