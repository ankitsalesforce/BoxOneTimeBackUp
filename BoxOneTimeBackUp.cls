public class BoxOneTimeBackUp implements Schedulable{
    @testVisible
    private static Boolean doChainJob = true;
    
   
   // public static void createFolderAndUploadtoBox(){
    public void execute(SchedulableContext SC) {
        futureCallouExecute();
        
    }
    @future (callout=true)
    public static void futureCallouExecute(){
       // String query = 'SELECT File_Id__c, ParentID__c FROM Files_BackUp__c WHERE Status__c = \'Waiting for Box Upload\' ORDER by CreatedDate ASC LIMIT ';
        string numberOfLimit = system.label.LimitToFileForBackUp;
		list<Files_BackUp__c> scope = [SELECT Id,File_Id__c, ParentID__c FROM Files_BackUp__c WHERE Status__c = 'Waiting for Box Upload' AND Remark__c != 'File Size is larger than 6 MB' ORDER by CreatedDate ASC LIMIT :integer.valueOf(numberOfLimit)];
        
        set<Id> fileBackUpIdToUpdate = new set<Id>();
        map<string,string> fileIdWithParentId = new map<String,String>();
        map<string,string> fileIdWithRecord = new map<String,String>();
        map<string,string> boxStageFileWithParent = new map<string,string>();
        List<String> bodyList = new List<String>();
        system.debug('Body List >> '+bodyList);
        list<contentDocument> contentList = new list<contentDocument>();
        list<Box_Callout_Status__c> boxStatustoUpdate = [SELECT Id,Name,Box_FolderId__c,Error__c,Number_Of_Attempt__c,Operation_Status__c,salesforce_File_Id__c,
                                             			 Status_Code__c FROM Box_Callout_Status__c WHERE 
                                                         Operation_Status__c IN ('Replicated to BOX','Copied to Box') ORDER BY CreatedDate ASC
                                                         ];
        for(Box_Callout_Status__c box : boxStatustoUpdate){
            boxStageFileWithParent.put(box.salesforce_File_Id__c,box.Name);
        }
        
        for(Files_BackUp__c file : scope){
            if(boxStageFileWithParent.containsKey(file.File_Id__c)){
                system.debug('file already moved to box');
            }else{
                fileIdWithParentId.put(file.File_Id__c,file.ParentID__c);
                fileIdWithRecord.put(file.File_Id__c,file.Id);
            }
        }
        system.debug('file size to be moved in Box >> '+fileIdWithParentId.size());
        contentList = [SELECT Id,contentSize FROM ContentDocument WHERE Id IN:fileIdWithParentId.keySet()];
        list<Files_BackUp__c> fileToBeUpdate = new list<Files_BackUp__c>();
        
        list<contentDocument> UpdatedContentDocs = [SELECT Id,contentSize FROM ContentDocument WHERE Id IN:fileIdWithParentId.keySet() AND contentSize < 6000000];
        for(ContentDocument con : contentList){
            Files_BackUp__c file = new Files_BackUp__c();
            if(con.contentSize > 6000000 && fileIdWithParentId.containsKey(con.Id)){
                file.Id = fileIdWithRecord.get(con.Id);
                file.File_Id__c = con.Id;
                file.Remark__c = 'File Size is larger than 6 MB';
                fileToBeUpdate.add(file);
            }
        }
       
        
        string accountFolderId = system.label.accountboxfolderId;
    	string caseFolderId = system.label.caseboxfolderId;
        //forming body for folder Create
        if(fileIdWithParentId != null){
             String folderBody;
            
             for(string str : fileIdWithParentId.keySet()){
                 string folderName = fileIdWithParentId.get(str);
                 
                 if(folderName.startsWithIgnoreCase('500')){
                    folderBody = 
                        '{'+'"name": "' + folderName + '",' +
                                        '"parent": {' +
                                         '"id": "' + caseFolderId + '"' +
                                       '}'+'}';
                      bodyList.add(folderBody); 
                 	}
                 if(folderName.startsWithIgnoreCase('001')){
                    folderBody = 
                                        '{'+ '"name": "' + folderName + '",' +
                                        '"parent": {' +
                                          '"id": "' + accountFolderId + '"' +
                                       '}'+'}'; 
                     
                      bodyList.add(folderBody); 
                 	}   
                
                }
        	}
       String finalBody =  '{'+String.join(bodyList, ',')+'}';
       system.debug('finalBody >> ' +finalBody);
       system.debug('bodyList size >> ' +bodyList.size());
       
       if(finalBody != '{}' && finalBody != null){
            system.debug('inside finalBody');
         
            BoxOneTimeApiCallOut.bulkfolderCreate(bodyList); //calling folder create callout
       }
         if(doChainJob && !Test.isRunningTest()) {
            system.enqueueJob(new BoxOneTimeFileUpload(UpdatedContentDocs,fileToBeUpdate));
        }
    }
}