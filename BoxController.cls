public class BoxController {

   /* @AuraEnabled
    public static void createFolder(string parentFolderId,string folderName){
        Box__mdt myBox = Box__mdt.getInstance('Box');
        List<string> tokenList =  Box_Authorize.regenerateAccessToken(myBox.Client__c,myBox.ClientSecret__c,myBox.refresh_Token__c);
        String accessToken = tokenList[0];//'1akIalNEwipRGEiDLk8jJjUWsYZoOgBc';//getAccessToken();//
        system.debug('AccessToken >> ' +accessToken);
        String body = '{ "name": "' + folderName + '", "parent": { "id": "' + parentFolderId + '" } }';
        String endpoint = 'https://api.box.com/2.0/folders'; 
        // define transaction variables
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
 
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setBody(body);
        System.debug(req.getBody());
        //req.setTimeout(120000);
        res = h.send(req);
        
       
        System.debug(System.LoggingLevel.ERROR, res.getStatusCode());
        System.debug(System.LoggingLevel.ERROR, res.getStatus());
        System.debug(System.LoggingLevel.ERROR, res.getBody());
        System.debug(accessToken);
        
       /* if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized'){
            
           List<string> tokenList =  Box_Authorize.regenerateAccessToken(myBox.Client__c,myBox.ClientSecret__c,myBox.refresh_Token__c);
            String NewaccessToken = myBox.Access_Token__c;
            req.setHeader('Authorization', 'Bearer ' + tokenList[0]);
            res = Box_Authorize.performCallout(req);
        }
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
            Map<String, Object> untypedMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug(untypedMap);
            system.debug('Folder created successfully!');
        }else{
            system.debug('Error while creating folder');
        }
    }*/
    
    @AuraEnabled
    public static void uploadFile(String base64, String filename, String folderId){
        system.debug('base64 >> '+base64);
        //Box__mdt myBox = Box__mdt.getInstance('Box');
        String accessToken ='fGt8XKXnXQKkeCtklPQLNcyKHzwiqC6M'; //myBox.Access_Token__c;
        //String accessToken = getAccessToken();
        //system.debug('accessToken >> ' +accessToken);
        if(base64!=null){
            blob base64EncodeFile = base64EncodeFileContent(EncodingUtil.base64Decode(base64), filename);
            String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+folderId;
            String boundary = '----------------------------741e90d31eff';
            String body = '{"name":"' + filename + '", "parent":{"id":"' + folderId + '"}}';
            HttpRequest req = new HttpRequest();
            req.setBody(body);
            req.setBodyAsBlob(base64EncodeFile);
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setMethod('POST');
            req.setEndpoint(uploadEndPointURL);
            req.setTimeout(120000);
            //Send request to Box
            Http ht = new Http();
            HTTPResponse res = ht.send(req);
            
            System.debug('**Files upload Response: ' + res.getBody());
            Integer uploadStatusCode=res.getStatusCode();
            if(uploadStatusCode==201){
                system.debug('File uploaded successfully.');
            }else{
               system.debug('Error encountered. Status Code: ' + uploadStatusCode);                
            }
        }else{
           system.debug('file is empty');
        }
    }
    
    
   public static blob base64EncodeFileContent(Blob file_body, String file_name){
       String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){ 
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        system.debug('bodyEncoded length >> '+bodyEncoded.length());
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
  		system.debug('last4Bytes length >> '+last4Bytes.length());
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded); 
        } 
        else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N'; 
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes; 
            footer = '\n' + footer; 
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
  
        return bodyBlob;
    }
    /*
    public static String getAccessToken(){
      Box__mdt myBox = Box__mdt.getInstance('Box'); 
        String username = myBox.Client__c;
        String password =  myBox.ClientSecret__c;
        String endpoint = 'https://api.box.com/oauth2/token'; 
        String boxSubjectId = '29287088712';
        // define transaction variables
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
 
        // Configure the request
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setTimeout(120000);
        string payload = 'client_id=' + username + '&client_secret=' + password + '&grant_type=client_credentials&type=user&id=' + boxSubjectId;
        req.setBody(payload);
        res = h.send(req);
        system.debug('getBody >> ' +res.getBody());
        system.JSONParser jp = JSON.createParser(res.getBody());
         system.debug('getBody jp>> ' +jp);
        if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
            Map<String, Object> untypedMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(untypedMap.containsKey('access_token')){
                return (String) untypedMap.get('access_token');
              }
            return '';
        }else{
            return '';
        }
       
       
    }
    
   /*
    public static void folderCreate(string finalBody){
        system.debug('finalBody >> ' +finalBody);
         //folder creation with recordId
        HttpRequest request=new HttpRequest();
        request.setEndpoint('callout:Box_Connect/2.0/folders'); 
        request.setMethod('POST');
        //request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setBody(finalBody);
        
        Http p = new Http();
        HttpResponse response = p.send(request);
        System.debug(System.LoggingLevel.ERROR, response.getStatusCode());
        System.debug(System.LoggingLevel.ERROR, response.getStatus());
        System.debug(System.LoggingLevel.ERROR, response.getBody());
        
        string result = response.getBody();
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
                try{
                    update cs;
                }
                catch(Exception e){
                    system.debug('error on case update ' +e.getMessage());
                }
           }
        } 
       if(folderName != null){
        		Box_Callout_Status__c status = new Box_Callout_Status__c();
                status.Name = folderName;
                status.Box_FolderId__c = folderId;
           		status.Status_Code__c = response.getStatusCode();
                if(response.getStatusCode() == 201){
                   status.Operation_Status__c = 'Created Folder';
                }else{
                    status.Error__c = response.getStatus();
                }
        try{
            insert status;
        }catch(Exception e){
            system.debug('error to create box status record');
        }
       }
    }
    
    public static void uploadFileToBox(map<string,list<string>> fileNameWithBase64data,String FolderId,String fileBody,map<String,list<String>> fileNamewithParent, map<String,list<String>> fileParentMap,map<String,String> FileIdWithLabel){
        List<HttpRequest> requests = new List<HttpRequest>();
        for(string base64 : fileNameWithBase64data.keySet()){
           	    List<String> fileNamelist = fileNameWithBase64data.get(base64);
            for(integer i=0;i<fileNamelist.size();i++){
                blob base64EncodeFile = BoxController.base64EncodeFileContent(EncodingUtil.base64Decode(base64), fileNamelist[i]);
            	String uploadEndPointURL='callout:Box_FileUpload/api/2.0/files/content?parent_id='+FolderId;
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
            }
        }
        List<HttpResponse> responses = new List<HttpResponse>();
        // Send the requests and capture the responses
            for (HttpRequest request : requests) {
                HttpResponse response = new Http().send(request);
                responses.add(response);
            }
        	System.debug(System.LoggingLevel.ERROR, responses[0].getStatusCode());
            System.debug(System.LoggingLevel.ERROR, responses[0].getStatus());
            System.debug(System.LoggingLevel.ERROR, responses[0].getBody());
        
       
        if(!responses.isEmpty()){
            list<string> BoxfolderIds = new list<string>();
            map<string,list<string>> parentIdwithFileName = new map<string,list<string>>();
            list<string> salesforceFileId = new list<String>();
            list<String> ParentIds = new List<String>();
            
            list<Box_Callout_Status__c> boxstageToBeUpdate = new list<Box_Callout_Status__c>();
            for(HttpResponse res : responses){
                system.debug('response in box upload >> ' +res);
            	 String result = res.getBody();
                 system.debug('response Body >> ' +result);
                 String FolderResId;
                 String fileName;
                 String parentId;
                 String parentFolderId;
                 String SFDCfileId;
                // Parse the JSON data
             Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(result);
            
              if(res.getStatusCode() == 201){
                // Check if the payload contains the "entries" key
                if (payload.containsKey('entries')) {
                    List<Object> entries = (List<Object>) payload.get('entries');
                    
                    for (Object entry : entries) {
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
                        system.debug('folderId >> ' +folderId);
                        parentIdwithFileName.get(parentId).add(entryName);
                        }
                    }
                system.debug('parentIdwithFileName >> ' +parentIdwithFileName); //containing parentId with FileName
                system.debug('parentName >> ' +parentId);
               
                     system.debug('201 status');
                     if(parentIdwithFileName.containsKey(parentId)){
                         list<String> successFileName = parentIdwithFileName.get(parentId);
                         system.debug('inside box stage Update');
                         for(string fileStr : successFileName){
                             system.debug('fileID in box stage Update >> ' +fileStr);
                             Box_Callout_Status__c status = new Box_Callout_Status__c();
                             status.Name = parentId;
                             status.Box_FolderId__c = parentFolderId;
                             status.salesforce_File_Id__c = FileIdWithLabel.get(fileStr);
                             status.Status_Code__c = res.getStatusCode();
                             status.Operation_Status__c = 'Copy to BOX';
                             //status.Error__c = res.getStatus();
                             boxstageToBeUpdate.add(status);
                         }
                	}
               system.debug('boxstageToBeUpdate at 201 >>' +boxstageToBeUpdate.size());
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
                                                Box_Callout_Status__c status = new Box_Callout_Status__c();
                                                status.Name = str;
                                                status.Box_FolderId__c = '';
                                                status.salesforce_File_Id__c = FileIdWithLabel.get(ExistingFilename);
                                                status.Status_Code__c = res.getStatusCode();
                                                status.Error__c = res.getStatus();
                                                boxstageToBeUpdate.add(status);
                                        	
                                      
                                       
                                    
                                }
                            }
                        }
                       system.debug('boxstageToBeUpdate at 409 >>' +boxstageToBeUpdate.size());
                  }
                   
              
                
                /*if(!BoxfolderIds.isEmpty()){
                    list<Box_Callout_Status__c> ExistingBoxStage = [SELECT ID,Name,Box_FolderId__c FROM
                                                                    Box_Callout_Status__c where Box_FolderId__c IN:BoxfolderIds];
                    FOR(Box_Callout_Status__c existingStage: ExistingBoxStage){
                        for (Box_Callout_Status__c statusToBeUpdated : boxstageToBeUpdate) {
                             if (statusToBeUpdated.Box_FolderId__c == existingStage.Box_FolderId__c) {
                                // Update the fields of the existing record with the new values
                                existingStage.Name = statusToBeUpdated.Name;
                                existingStage.salesforce_File_Id__c = statusToBeUpdated.salesforce_File_Id__c;
                                existingStage.Operation_Status__c = statusToBeUpdated.Operation_Status__c;
                                existingStage.Error__c = statusToBeUpdated.Error__c;
                            }
                        }
                    }
                    
                    
                }
                
            }
            
            system.debug('Total boxstageToBeUpdate >>' +boxstageToBeUpdate.size());
                if(boxstageToBeUpdate.size()> 0){
                    try{
                        Insert boxstageToBeUpdate;
                        }catch(Exception e){
                            system.debug('Error occure in box stage update '+e.getMessage());
                            system.debug('Error occure in box stage update at line '+e.getLineNumber());
                        }
                    }
            
        }
        
        //if(!base64List.isEmpty()){
            /*for(string bl : base64list) {
                blob base64EncodeFile = BoxController.base64EncodeFileContent(EncodingUtil.base64Decode(bl), filename.get(bl));
                String uploadEndPointURL='callout:Box_FileUpload/api/2.0/files/content?parent_id='+FolderId;
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
            }
            
            
        //}
    }*/

    
}