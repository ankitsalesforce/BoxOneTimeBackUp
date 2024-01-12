public class BoxOneTimeApiCallOut {
    
    public static void bulkfolderCreate(list<string> finalBody){
        list<account> accountToBeUpdate = new list<account>();
        list<case> caseToBeUpdate = new list<case>();
        list<Box_Callout_Status__c> boxStageToBeUpdate = new list<Box_Callout_Status__c> ();
        List<HttpRequest> requests = new List<HttpRequest>();
        system.debug('finalBody >> ' +finalBody);
        
        for(string str : finalBody){
            //folder creation with recordId
            system.debug('body >> '+str);
            HttpRequest request=new HttpRequest();
            request.setEndpoint('callout:Box_Connect/2.0/folders'); 
            request.setMethod('POST');
            //request.setHeader('Authorization', 'Bearer ' + authToken);
            request.setBody(str);
            requests.add(request);
        }
        
        List<HttpResponse> responses = new List<HttpResponse>();
        // Send the requests and capture the responses
        for (HttpRequest request : requests) {
            HttpResponse response = new Http().send(request);
            responses.add(response);
        }
        
        if(responses.size()>0){
            System.debug(System.LoggingLevel.ERROR, responses[0].getStatusCode());
  		    System.debug(System.LoggingLevel.ERROR, responses[0].getStatus());
            System.debug(System.LoggingLevel.ERROR, responses[0].getBody());  
         }
        
        if(!responses.isEmpty()){
            for(HttpResponse res : responses){
                system.debug('response in box upload >> ' +res);
                String result = res.getBody();
                system.debug('response Body >> ' +result);
                String folderId;
                String folderName;
                
                // Parse the JSON data
                Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(result);
                
                // Extract the 'id' and 'name' fields
                folderId = (String) jsonData.get('id');
                folderName = (String) jsonData.get('name');
                
                
                // Now, you have the 'id' and 'name' values in the folderId and folderName variables
                System.debug('Folder ID: ' + folderId);
                System.debug('Folder Name: ' + folderName);
                
                if(folderName != null){
                    if(folderName.startsWithIgnoreCase('500')){
                        case cs = new case();
                        cs.Id = Id.valueOf(folderName);
                        cs.Box_Folder_Id__c = folderId;
                        caseToBeUpdate.add(cs);
                    }//storing case box folder Id
                    
                    if(folderName.startsWithIgnoreCase('001')){
                        Account acc = new Account();
                        acc.Id = Id.valueOf(folderName);
                        acc.Box_Folder_Id__c = folderId;
                        accountToBeUpdate.add(acc);
                        
                    }//storing Account box folder Id
                } 
                if(folderName != null){
                    Box_Callout_Status__c status = new Box_Callout_Status__c();
                    status.Name = folderName;
                    status.Box_FolderId__c = folderId;
                    status.Status_Code__c = res.getStatusCode();
                    if(res.getStatusCode() == 201){
                        status.Operation_Status__c = 'Created Folder';
                    }else{
                        status.Error__c = res.getStatus();
                        status.Operation_Status__c = 'Error';
                    }
                    boxStageToBeUpdate.add(status);		
                }
            }
        }
        
        if(boxStageToBeUpdate.size() > 0){
           try{
                Database.SaveResult[] updateResults = Database.insert(boxStageToBeUpdate, false);
                for (Database.SaveResult sr : UpdateResults) {
                     if (sr.isSuccess()) {
                           // Operation was successful, so get the ID of the record that was processed
                           System.debug('Successfully inserted  box stageing number of attempt try: ' + sr.getId());
                        }else {
                            for(Database.Error err : sr.getErrors()) {
                                
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                          }
                        } 
            }catch(Exception e){
                system.debug('Error occure in box stage update '+e.getMessage());
                system.debug('Error occure in box stage update at line '+e.getLineNumber());
            }
        }
        if(accountToBeUpdate.size() > 0){
           try{
                Database.SaveResult[] updateResults = Database.update(accountToBeUpdate, false);
                for (Database.SaveResult sr : UpdateResults) {
                     if (sr.isSuccess()) {
                           // Operation was successful, so get the ID of the record that was processed
                           System.debug('Successfully inserted  box stageing number of attempt try: ' + sr.getId());
                        }else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                          }
                        } 
            }catch(Exception e){
                system.debug('Error occure in box stage update '+e.getMessage());
                system.debug('Error occure in box stage update at line '+e.getLineNumber());
            }
        }
        if(caseToBeUpdate.size() > 0 ){
            try{
                Database.SaveResult[] updateResults = Database.update(caseToBeUpdate, false);
                for (Database.SaveResult sr : UpdateResults) {
                     if (sr.isSuccess()) {
                           // Operation was successful, so get the ID of the record that was processed
                           System.debug('Successfully inserted  box stageing number of attempt try: ' + sr.getId());
                        }else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                          }
                        } 
            }catch(Exception e){
                system.debug('Error occure in box stage update '+e.getMessage());
                system.debug('Error occure in box stage update at line '+e.getLineNumber());
            }
        }
    }
    
    public static void BoxOneTimeFilesupload(Map<String, blob> fileVersionMap,
                                             Map<String, List<String>> folderIdWithFileName, 
                                             String fileBody,
                                             Map<String, List<String>> fileNamewithParent,
                                             Map<String, String> FileIdWithLabel,
                                             Map<String, String> fileLabelWithFolderId,
                                             list<String> boxIdToUpdate){
                                                 
                                                 system.debug('heap size used at beginnning of fileUploadCallout '+Limits.getHeapSize());
                                                 system.debug('total heap size used at beginnning of fileUploadCallout >> '+Limits.getLimitHeapSize());
                                                 
                                                 Map<Id, Box_Callout_Status__c> uniqueBoxStatusMap = new Map<Id, Box_Callout_Status__c>();
                                                 list<Box_Callout_Status__c> boxStatustoUpdate = new list<Box_Callout_Status__c>();
                                                 set<Id> fileBackUpIdToBeUpdate = new set<Id>();                                         
                                                 if(boxIdToUpdate != null){
                                                     boxStatustoUpdate = [SELECT Id,Name,Box_FolderId__c,Error__c,Box_File_ID__c,Number_Of_Attempt__c,Operation_Status__c,salesforce_File_Id__c,
                                                                          Status_Code__c FROM Box_Callout_Status__c WHERE ID IN:boxIdToUpdate];                                         
                                                 }                                         
                                                 
                                                 List<HttpRequest> requests = new List<HttpRequest>();
                                                 
                                                 Long HeapSizeUsed = Limits.getHeapSize(); //memory has been used in this context
    											 Long totalHeapSize = Limits.getLimitHeapSize(); //total memory allocated for this context
                                                 long remainingHeapSize = Limits.getLimitHeapSize() - Limits.getHeapSize();
                                                 system.debug('HeapSizeUsed >> '+HeapSizeUsed);
                                                 system.debug('totalHeapSize >> '+totalHeapSize);
                                                 system.debug('remainingHeapSize >> '+remainingHeapSize);
                                                 
                                                 for(string fileLabel : fileVersionMap.keySet()){
                                                     //List<String> fileNamelist = fileNameWithBase64data.get(base64);
                                                     //for(integer i=0;i<fileNamelist.size();i++){ 
                                                     if (remainingHeapSize > 0){
                                                         system.debug('folderId in loop>> '+fileLabelWithFolderId.get(fileLabel));
                                                         blob base64EncodeFile = BoxController.base64EncodeFileContent(fileVersionMap.get(fileLabel), fileLabel);//EncodingUtil.base64Decode(fileNameWithBase64data.get(fileLabel));
                                						 String uploadEndPointURL='callout:Box_FileUpload/api/2.0/files/content?parent_id='+fileLabelWithFolderId.get(fileLabel);
                                                         String boundary = '----------------------------741e90d31eff';
                                                         String body = fileBody;
                                                         HttpRequest req = new HttpRequest();
                                                         req.setBody(body);
                                                         req.setBodyAsBlob(base64EncodeFile);
                                                         req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                                                         //req.setHeader('Authorization', 'Bearer ' + accessToken);
                                                         req.setMethod('POST');
                                                         req.setEndpoint(uploadEndPointURL);
                                                         req.setTimeout(120000);
                                                         requests.add(req);
                                                         
                                                         base64EncodeFile = blob.valueOf('');
                                                        
                                                     }else{
                                                         // If heap size limit is reached, skip processing the current file
                                                        System.debug('Heap size limit reached. Skipping file: ' + fileLabel);
                                                     }
                                                         
                                                     
                                                     //}
                                                 }
                                                 List<HttpResponse> responses = new List<HttpResponse>();
                                                 // Send the requests and capture the responses
                                                 for (HttpRequest request : requests) {
                                                     HttpResponse response = new Http().send(request);
                                                     responses.add(response);
                                                 }
                                                 
                                                 if(responses.size()>0){
                                                    System.debug(System.LoggingLevel.ERROR, responses[0].getStatusCode());
                                                 	System.debug(System.LoggingLevel.ERROR, responses[0].getStatus());
                                                 	System.debug(System.LoggingLevel.ERROR, responses[0].getBody());  
                                                 }
                                                 
                                                 
                                                 list<Box_Callout_Status__c> boxstageToBeUpdate = new list<Box_Callout_Status__c>();
                                                 list<Box_Callout_Status__c> boxstageToBeInsert = new list<Box_Callout_Status__c>();
                                                 if(!responses.isEmpty()){
                                                     list<string> BoxfolderIds = new list<string>();
                                                     map<string,list<string>> parentIdwithFileName = new map<string,list<string>>();
                                                     map<string,string> boxfileIdwithFileName = new map<string,string>();//storing Box file Id
                                                     list<string> salesforceFileId = new list<String>();
                                                     list<String> ParentIds = new List<String>();
                                                     
                                                     
                                                     for(HttpResponse res : responses){
                                                         system.debug('response in box upload >> ' +res);
                                                         String result = res.getBody();
                                                         system.debug('response Body >>== ' +result);
                                                         String FolderResId;
                                                         String fileName;
                                                         String parentId;
                                                         String parentFolderId;
                                                         String SFDCfileId;
                                                         String BoxFileId;
                                                         // Parse the JSON data
                                                         Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(result);
                                                         
                                                         //replication/number of attempt logic    
                                                         if(boxIdToUpdate != null){
                                                             for(Box_Callout_Status__c box : boxStatustoUpdate){
                                                                 system.debug('payload ==>> '+payload);                            
                                                                 if(res.getStatusCode() == 201){
                                                                     // Check if the payload contains the "entries" key
                                                                     if (payload.containsKey('entries')) {
                                                                         List<Object> entries = (List<Object>) payload.get('entries');
                                                                         
                                                                         for(Object entry : entries) {
                                                                             Map<String, Object> fileEntry = (Map<String, Object>) entry;
                                                                             String entryName = (String) fileEntry.get('name');
                                                                             system.debug('entryName >> ' +entryName);
                                                                             Map<String, Object> entryMap = (Map<String, Object>) entry;
                                                                             // Access the "parent" object within each entry
                                                                             Map<String, Object> parent = (Map<String, Object>) entryMap.get('parent');
                                                                             // Loop through the entries to find the file with the desired name
                                                                             // Access the "name" value from the "parent" object
                                                                             parentId = (String) parent.get('name');
                                                                             parentFolderId = (String) parent.get('id');
                                                                             BoxfolderIds.add(parentFolderId);
                                                                             parentIdwithFileName.put(parentId,new list<string>());
                                                                             system.debug('parentName >> ' +parentId);
                                                                             //system.debug('folderId >> ' +folderId);
                                                                             parentIdwithFileName.get(parentId).add(entryName);
                                                                             BoxFileId = (String) fileEntry.get('id');
                                                                             boxfileIdwithFileName.put(parentId,BoxFileId);
                                                                         }
                                                                     }
                                                                     system.debug('parentIdwithFileName >> ' +parentIdwithFileName); //containing parentId with FileName
                                                                     system.debug('parentName >> ' +parentId);
                                                                     if(parentIdwithFileName.containsKey(parentId)){
                                                                         list<String> successFileName = parentIdwithFileName.get(parentId);
                                                                         system.debug('inside box stage Update');
                                                                         for(string fileStr : successFileName){
                                                                             if(box.salesforce_File_Id__c == FileIdWithLabel.get(fileStr) &&  box.Box_FolderId__c == parentFolderId){ 
                                                                                 Box_Callout_Status__c status = getBoxCallOutInstance(box,res.getStatusCode());    
                                                                                 uniqueBoxStatusMap.put(status.Id, status);
                                                                                } 
                                                                         }
                                                                     }
                                                                     system.debug('boxstageToBeUpdate at 201 >>' +boxstageToBeUpdate.size());
                                                                 }
                                                                 if(res.getStatusCode() != 201){
                                                                     system.debug('inside error');
                                                                     Box_Callout_Status__c status = new Box_Callout_Status__c();
                                                                     status.Status_Code__c = res.getStatusCode();
                                                                     status.Id = box.Id;    
                                                                     status.Operation_Status__c = 'Error';
                                                                     if(box.Number_Of_Attempt__c < 3){
                                                                         status.Number_Of_Attempt__c = box.Number_Of_Attempt__c + 1;
                                                                     }
                                                                     status.Error__c = res.getStatus();
                                                                     //boxstageToBeUpdate.add(status); 
                                                                     uniqueBoxStatusMap.put(status.Id, status);
                                                                 }
                                                             }    
                                                         }    
                                                         //for one time batch
                                                         else{
                                                             if(res.getStatusCode() == 201){
                                                                 // Check if the payload contains the "entries" key
                                                                 if (payload.containsKey('entries')) {
                                                                     List<Object> entries = (List<Object>) payload.get('entries');
                                                                     
                                                                     for (Object entry : entries) {
                                                                         Map<String, Object> fileEntry = (Map<String, Object>) entry;
                                                                         String entryName = (String) fileEntry.get('name');
                                                                         
                                                                         Map<String, Object> entryMap = (Map<String, Object>) entry;
                                                                         // Access the "parent" object within each entry
                                                                         Map<String, Object> parent = (Map<String, Object>) entryMap.get('parent');
                                                                         
                                                                         // Access the "name" value from the "parent" object
                                                                         parentId = (String) parent.get('name');
                                                                         parentFolderId = (String) parent.get('id');
                                                                         BoxfolderIds.add(parentFolderId);
                                                                         parentIdwithFileName.put(parentId,new list<string>());
                                                                        
                                                                         parentIdwithFileName.get(parentId).add(entryName);
                                                                         
                                                                         BoxFileId = (String) fileEntry.get('id');
                                                                         boxfileIdwithFileName.put(parentId,BoxFileId);
                                                                     }
                                                                 }
                                                                 system.debug('parentIdwithFileName >> ' +parentIdwithFileName); //containing parentId with FileName
                                                                 
                                                                 system.debug('201 status');
                                                                 
                                                                 if(parentIdwithFileName.containsKey(parentId)){
                                                                     list<String> successFileName = parentIdwithFileName.get(parentId);
                                                                     
                                                                     for(string fileStr : successFileName){
                                                                         system.debug('fileID in box stage Update >> ' +fileStr);
                                                                         Box_Callout_Status__c status = getBoxCalloutInstance(parentId,parentFolderId,boxfileIdwithFileName.get(parentId),
                                                                                                                              FileIdWithLabel.get(fileStr),res.getStatusCode());
                                                                         //status.Error__c = res.getStatus();
                                                                         boxstageToBeInsert.add(status);
                                                                         fileBackUpIdToBeUpdate.add(FileIdWithLabel.get(fileStr)); //storing ID to update file_backUp__c status to 'Copied to Box'
                                                                     }
                                                                 }
                                                                 system.debug('boxstageToBeInsert at 201 >>' +boxstageToBeInsert.size());
                                                             }
                                                             if(res.getStatusCode() == 409){
                                                                 system.debug('409 status');
                                                                 string ExistingFilename;
                                                                 
                                                                 Set<String> matchingKeys = new Set<String>();
                                                                 if (payload.containsKey('context_info')) {
                                                                     Map<String, Object> contextInfo = (Map<String, Object>) payload.get('context_info');
                                                                     
                                                                     if (contextInfo.containsKey('conflicts')) {
                                                                         Map<String, Object> conflicts = (Map<String, Object>) contextInfo.get('conflicts');
                                                                         
                                                                         if (conflicts.containsKey('name')) {
                                                                             ExistingFilename = (String) conflicts.get('name');
                                                                             
                                                                         }
                                                                         system.debug('ExistingFilename >> '+ExistingFilename);
                                                                         
                                                                         for(string key : fileNamewithParent.keySet()){
                                                                             List<String> values = fileNamewithParent.get(key);
                                                                             if (values.contains(ExistingFilename)) {
                                                                                 matchingKeys.add(key);
                                                                             }
                                                                         }
                                                                         system.debug('matching Parent ID >> '+matchingKeys);
                                                                         system.debug('FileIdWithLabel >> ' +FileIdWithLabel);
                                                                         //FileIdWithLabel => fileId and fileLabel
                                                                         for(string str : matchingKeys){
                                                                             system.debug('existed file Id >>' +FileIdWithLabel.get(ExistingFilename));
                                                                             Box_Callout_Status__c status = getBoxCalloutInstance(str, FileIdWithLabel.get(ExistingFilename),res.getStatusCode(),res.getStatus());
                                                                             boxstageToBeInsert.add(status);
                                                                         }
                                                                     }
                                                                 }
                                                                 system.debug('boxstageToBeInsert at 409 >>' +boxstageToBeInsert.size());
                                                             }
                                                             if(res.getStatusCode() == 401){
                                                                 Box_Callout_Status__c status = getBoxCalloutInstance(res.getStatusCode());
                                                                 boxstageToBeInsert.add(status);
                                                             }
                                                             
                                                             if(res.getStatusCode() != 201 || res.getStatusCode() != 409 || res.getStatusCode() != 401){
                                                                 String message;
                                                                 if (payload.containsKey('context_info')) {
                                                                     Map<String, Object> contextInfo = (Map<String, Object>) payload.get('context_info');
                                                                     if (contextInfo.containsKey('message')) {
                                                                         message = (String) contextInfo.get('message');
                                                                         System.debug('Message inside context_info: ' + message);
                                                                     }
                                                                     String requestId = (String) payload.get('request_id');
                                                                     Box_Callout_Status__c status = getBoxCalloutInstance(requestId,res.getStatusCode(),
                                                                                                                          message);
                                                                     boxstageToBeInsert.add(status);
                                                                 }
                                                                 
                                                             }
                                                         }
                                                         
                                                     }
                                                     
                                                     if(uniqueBoxStatusMap != null){
                                                         boxstageToBeUpdate = new List<Box_Callout_Status__c>(uniqueBoxStatusMap.values());
                                                         system.debug('Total boxstageToBeUpdate >>' +boxstageToBeUpdate.size());
                                                         if(boxstageToBeUpdate.size()> 0){
                                                             try{
                                                                 Database.SaveResult[] updateResults = Database.update(boxstageToBeUpdate, false);
                                                                 for (Database.SaveResult sr : UpdateResults) {
                                                                     if (sr.isSuccess()) {
                                                                         // Operation was successful, so get the ID of the record that was processed
                                                                         System.debug('Successfully inserted  box stageing number of attempt try: ' + sr.getId());
                                                                     }
                                                                     else {
                                                                         // Operation failed, so get all errors                
                                                                         for(Database.Error err : sr.getErrors()) {
                                                                             System.debug('The following error has occurred.');                    
                                                                             System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                                             System.debug('fields that affected this error: ' + err.getFields());
                                                                         }
                                                                     }
                                                                 } 
                                                             }catch(Exception e){
                                                                 system.debug('Error occure in box stage update '+e.getMessage());
                                                                 system.debug('Error occure in box stage update at line '+e.getLineNumber());
                                                             }
                                                         }
                                                     }
                                                     
                                                     //to insert new box staging record for one time batch
                                                     if(boxstageToBeInsert.size() > 0){
                                                         try{
                                                             Database.SaveResult[] insertResults = Database.Insert(boxstageToBeInsert, false);
                                                             // Iterate through each returned result
                                                             for (Database.SaveResult sr : insertResults) {
                                                                 if (sr.isSuccess()) {
                                                                     // Operation was successful, so get the ID of the record that was processed
                                                                     System.debug('Successfully inserted  box ID: ' + sr.getId());
                                                                 }
                                                                 else {
                                                                     // Operation failed, so get all errors                
                                                                     for(Database.Error err : sr.getErrors()) {
                                                                         System.debug('The following error has occurred.');                    
                                                                         System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                                         System.debug('fields that affected this error: ' + err.getFields());
                                                                     }
                                                                 }
                                                             }
                                                         }catch(Exception e){
                                                             system.debug('Error occure in box stage update '+e.getMessage());
                                                             system.debug('Error occure in box stage update at line '+e.getLineNumber());
                                                         }
                                                     }
                                                     
                                                     //to update files_backUp__c obj
                                                     if(fileBackUpIdToBeUpdate != null){
                                                         system.debug('to update file backup status');
                                                         list<Files_BackUp__c> filetobeUpdate = new list<Files_BackUp__c>();
                                                         for(Files_BackUp__c fileBack : [SELECT File_Id__c, ParentID__c FROM Files_BackUp__c WHERE File_Id__c IN:fileBackUpIdToBeUpdate]){ 
                                                             Files_BackUp__c File = new Files_BackUp__c();
                                                             file.Id = fileBack.Id;File.Status__c = 'Copied to Box';                           
                                                             filetobeUpdate.add(file);
                                                         }
                                                         
                                                         if(filetobeUpdate.size() > 0){
                                                             try{ 
                                                             Database.SaveResult[] UpdateResults = Database.Update(filetobeUpdate, false);  
                                                                 
                                                                 for (Database.SaveResult sr : UpdateResults) {
                                                                     if (sr.isSuccess()) {
                                                                         // Operation was successful, so get the ID of the record that was processed
                                                                         System.debug('Successfully updated  file ID: ' + sr.getId());
                                                                     }
                                                                     else {
                                                                         // Operation failed, so get all errors                
                                                                         for(Database.Error err : sr.getErrors()) {
                                                                             System.debug('The following error has occurred.');                    
                                                                             System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                                             System.debug('fields that affected this error: ' + err.getFields());
                                                                         }
                                                                     }
                                                                 } 
                                                             }catch(Exception e){
                                                                 system.debug('Error occure in fileBackUp update '+e.getMessage());
                                                                 system.debug('Error occure in fileBackUp update at line '+e.getLineNumber());
                                                             }
                                                         }
                                                     }
                                                     
                                                 }
                                                 
                                             }
    //Status Code 201
    public static Box_Callout_Status__c getBoxCallOutInstance(Box_Callout_Status__c box,Integer iStatusCode)
    {
        Box_Callout_Status__c status = new Box_Callout_Status__c();
        status.Status_Code__c = iStatusCode;
        status.Id = box.Id;    
        status.Operation_Status__c = 'Replicated to BOX';
        status.Error__c = '';
        if(box.Number_Of_Attempt__c < 3){
            status.Number_Of_Attempt__c = box.Number_Of_Attempt__c + 1;
        }
        return status;
    }
   
    // else Status Code 201
    public static Box_Callout_Status__c getBoxCalloutInstance(String parentId, String parentFolderId,String BoxFileId, String sSalesforceFileID,Integer iStatusCode)
    {
        Box_Callout_Status__c status = new Box_Callout_Status__c();
        status.Name = parentId;
        status.Box_FolderId__c = parentFolderId;
        status.Box_File_ID__c = BoxFileId;
        status.salesforce_File_Id__c = sSalesforceFileID;
        status.Status_Code__c = iStatusCode;
        status.Operation_Status__c = 'Copied to Box';
        return status;
    }
    //Status Code 401
    public static Box_Callout_Status__c getBoxCalloutInstance(Integer iStatusCode)
    {
        Box_Callout_Status__c status = new Box_Callout_Status__c();
        status.Name = 'Unauthorized';
        status.Box_FolderId__c = '';
        status.salesforce_File_Id__c = '';
        status.Status_Code__c = iStatusCode;
        status.Operation_Status__c = 'Error';
        status.Error__c = 'Unauthorized - Cannot authorize with this service';
        return status;
    }
    //Status Code !201 !409 !401 == 500
    public static Box_Callout_Status__c getBoxCalloutInstance(String requestId,Integer iStatusCode,String message)
    {
        Box_Callout_Status__c status = new Box_Callout_Status__c();
        status.Name = requestId;
        status.Box_FolderId__c = '';
        status.salesforce_File_Id__c = '';
        status.Operation_Status__c = 'Error';
        status.Status_Code__c = iStatusCode;
        status.Error__c = message;
        return status;
    }
    //Status Code 409
    public static Box_Callout_Status__c getBoxCalloutInstance(String str,String sSalesforceFileID,Integer iStatusCode,String sStatus)
    {
        Box_Callout_Status__c status = new Box_Callout_Status__c();
        status.Name = str;
        status.Box_FolderId__c = '';
        status.salesforce_File_Id__c = sSalesforceFileID;
        status.Status_Code__c = iStatusCode;
        status.Error__c = sStatus;
        status.Operation_Status__c = 'Error';
        return status;
    }

}