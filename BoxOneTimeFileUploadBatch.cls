global class BoxOneTimeFileUploadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
		global list<contentDocument> contentList;
        global map<String,String> FileIdWithfolderId = new  map<String,String>();  
        global map<String,list<String>> fileParentMap = new  map<String,list<String>>();
        global map<String,list<String>> folderIdWithFileName = new  map<String,list<String>>();
        global map<String,blob> fileVersionMap = new  map<String,blob>();
        global map<String,list<String>> fileNamewithParent = new  map<String,list<String>>();
        global map<String,String> FileIdWithLabel = new  map<String,String>();
        global map<string,string> fileLabelWithFolderId = new map<String,String>();
        global list<String> fileBody = new list<String>();
        global list<Id> parentIds = new list<Id>();
        global set<Id> contentId = new set<Id>(); 
    	global list<String> fileLabels = new list<String>();
    	global set<Id> linkedEntityIds = new set<Id>();
    	global set<Id> caseList = new set<Id>();
        global set<Id> accountList = new set<Id>();
    	global list<Case> cslst  = new  list<Case>(); 
        global list<Account> Accountlst  = new  list<Account>();
    	global list<contentDocumentLink> contentLink = new  list<contentDocumentLink>();
    	global list<contentVersion> conVersionData = new list<contentVersion>();
    	global String finalBody;
    	global String fileLabel;
        private boolean isExecuteCompleted = false;
    
        public BoxOneTimeFileUploadBatch(list<contentDocument>contentList) {
          this.contentList = contentList;  
        }
    
     global Database.QueryLocator start(Database.BatchableContext context) {
       for(contentDocument content : contentList){
                contentId.add(content.Id);
       }
        
        String contentQuery = 'SELECT ID, linkedEntityId, contentDocument.ContentSize, contentDocumentId, SystemModstamp, contentDocument.Title, contentDocument.FileExtension, ContentDocument.LatestPublishedVersion.versionData,ContentDocument.LastReferencedDate FROM contentDocumentLink WHERE contentDocumentId IN :contentId order by SystemModstamp DESC';
        
        return Database.getQueryLocator(contentQuery);

    }

    
    global void execute(Database.BatchableContext BC, List<ContentDocumentLink> scope) {
        system.debug('heap size used at start of batch scope '+Limits.getHeapSize());
        system.debug('total heap size used at start of batch scope >> '+Limits.getLimitHeapSize());
        for(ContentDocumentLink link  : scope){
           		string ParentId = link.linkedEntityId;
                if(ParentId.startsWithIgnoreCase('500') || ParentId.startsWithIgnoreCase('001')){
                     if (!fileParentMap.containsKey(link.linkedEntityId)) {
                        fileParentMap.put(link.linkedEntityId, new List<String>());
                    }
                     ParentIds.add(link.linkedEntityId);
                     fileParentMap.get(link.linkedEntityId).add(link.contentDocumentId); //storing parentId with files Id
                    
                     fileLabel = link.contentDocument.Title+'.'+link.contentDocument.FileExtension;
                 	 fileLabels.add(fileLabel);
					 
					 if(!fileNamewithParent.containsKey(link.linkedEntityId)){
						fileNamewithParent.put(link.linkedEntityId,new list<String>());
					}
                   
					if(fileLabels.contains(fileLabel)){
						//Datetime systemModstampDatetime = link.SystemModstamp;
						//String formattedDateString = systemModstampDatetime.format('MM_dd_yyyy_HH_mm_ss');
						string uniqueName = String.valueOf(System.currentTimeMillis()) + '_' + String.valueOf(Math.floor(Math.random() * 1000));
						fileLabel = link.contentDocument.Title+'_'+uniqueName+'.'+link.contentDocument.FileExtension;
                    }//duplicate file
                    
  			    
                linkedEntityIds.add(Link.linkedEntityId);   
				
				fileNamewithParent.get(link.linkedEntityId).add(fileLabel); //storing parentId with updated file label
             	FileIdWithLabel.put(fileLabel,link.ContentDocumentId); //storing FileId with updated file label
                fileVersionMap.put(fileLabel,link.ContentDocument.LatestPublishedVersion.versionData);   //storing fileLabel with base64 
			     system.debug('fileLabel >> '+fileLabel);
              }
        }
        
        if(!linkedEntityIds.isEmpty()){
            for(Id recordId : linkedEntityIds){
                String folderName = String.valueOf(recordId);
                
                if(folderName.startsWithIgnoreCase('500')){
                    caseList.add(recordId); 
                }//case obj
                
              if(folderName.startsWithIgnoreCase('001')){
                    accountList.add(recordId); 
               }//Account obj
            }
        }
        
        if(!caseList.isEmpty()){
            system.debug('heap size used at start of case '+Limits.getHeapSize());
            system.debug('total heap size used at start of case >> '+Limits.getLimitHeapSize());
            for(case cs : [SELECT Id,Box_Folder_Id__c FROM Case WHERE ID IN:caseList]){
				string folderBody;
                string folderName = cs.Id;
                String folderId = cs.Box_Folder_Id__c;
                
                
                //if(!contentLink.isEmpty()){
                   for(contentDocumentLink link : scope) {
                        if(cs.Id == link.LinkedEntityId) {
                            if (!folderIdWithFileName.containsKey(folderId)) {
                                folderIdWithFileName.put(folderId, new List<String>());
                            }
                            //Datetime systemModstampDatetime = link.SystemModstamp;
                            //String formattedDateString = systemModstampDatetime.format('MM_dd_yyyy_HH_mm_ss');
                            //string uniqueName = String.valueOf(System.currentTimeMillis()) + '_' + String.valueOf(Math.floor(Math.random() * 1000));
                            //string fileLabel = link.contentDocument.Title+'_'+uniqueName+'.'+link.contentDocument.FileExtension;
                            folderIdWithFileName.get(folderId).add(fileLabel);
                            
                            fileLabelWithFolderId.put(fileLabel,folderId);
                        }
                  }  
                //}
            	
				
				//converting all versionData To base64
               /* if(fileParentMap != null){
                  if(fileParentMap.containsKey(cs.Id)){
                    list<string> caseContentDocId = fileParentMap.get(cs.Id);
                    for(string csContent : caseContentDocId){
                        if(fileVersionMap.containsKey(csContent)){
                            system.debug('contentDocId >> ' +csContent);
                            String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(csContent));
                            base64Datalist.add(base64Data);
                        }
                        
                    }
                 }   
                }*/
				
                if(fileNamewithParent != null){
                   //forming body
				  if(fileNamewithParent.containsKey(cs.Id)){
                    list<string> filenamelst = fileNamewithParent.get(cs.Id);
                    for(string fileNameStr : filenamelst){
                        if(folderId != null){
                     		folderBody = '"name": "' + fileNameStr + '",' +
                                                '"parent": {' +
                                                    '"id": "' + folderId + '"' +
                                                '}';
                		}
                         //existing folder
                		fileBody.add(folderBody);
                    }
                 } 
                }
				
				//fileParentMap => parentId with files Id
				//fileNamewithParent => parnentId with file labels 
				//fileNameWithBase64data => base64 with file labels => should change to filelabels and list of base64 data
				
                /*if(fileParentMap != null || fileNamewithParent != null){
                   if(fileParentMap.containsKey(cs.Id) || fileNamewithParent.containsKey(cs.Id) ){
					list<string> fileIds = fileParentMap.get(cs.Id);
                    list<string> filesName = fileNamewithParent.get(cs.Id);
					if(!fileIds.isEmpty()){
						for(string fileLabel : filesName){
							String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(fileLabel));
                            system.debug('length >> '+base64Data.length());
							fileNameWithBase64data.put(fileLabel,base64Data);
                        }
					}
				 } 
                }*/
            }
            system.debug('heap size used at end of case '+Limits.getHeapSize());
            system.debug('total heap size used at end of case >> '+Limits.getLimitHeapSize());
        }
        
        if(!accountList.isEmpty()){
           
             for(Account acc :[SELECT Id,Box_Folder_Id__c FROM Account WHERE ID IN:accountList]){
				string folderBody;
                string folderName = acc.Id;
                String folderId = acc.Box_Folder_Id__c;
                
                 //if(!contentLink.isEmpty()){
                     for (contentDocumentLink link : scope) {
                    	if (acc.Id == link.LinkedEntityId) {
                            if(!folderIdWithFileName.containsKey(folderId)) {
                                folderIdWithFileName.put(folderId, new List<String>());
                            }
                            Datetime systemModstampDatetime = link.SystemModstamp;
                            String formattedDateString = systemModstampDatetime.format('MM_dd_yyyy_HH_mm_ss');
                            string fileLabel = link.contentDocument.Title+'_'+formattedDateString+'.'+link.contentDocument.FileExtension;
                            folderIdWithFileName.get(folderId).add(fileLabel);
                            
                            fileLabelWithFolderId.put(fileLabel,folderId);
                        }
                	} 
                // } 
            	
				
				//converting all versionData To base64
               /*  if(fileParentMap != null){
                    if(fileParentMap.containsKey(acc.Id)){
                    list<string> caseContentDocId = fileParentMap.get(acc.Id);
                    for(string csContent : caseContentDocId){
                        if(fileVersionMap.containsKey(csContent)){
                            system.debug('contentDocId >> ' +csContent);
                            String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(csContent));
                            base64Datalist.add(base64Data);
                        }
                    }
                  } 
                 }*/
				 
				
				//forming body
                 if(fileNamewithParent != null){
                    if(fileNamewithParent.containsKey(acc.Id)){
                    list<string> filenamelst = fileNamewithParent.get(acc.Id);
                    for(string fileNameStr : filenamelst){
                        if(folderId != null){
                     		folderBody = '"name": "' + fileNameStr + '",' +
                                                '"parent": {' +
                                                    '"id": "' + folderId + '"' +
                                                '}';
                		}
                         //existing folder
                		fileBody.add(folderBody);
                    }
                  } 
                }
				 
				
              /*  if(fileParentMap != null || fileNamewithParent != null){
                  if(fileParentMap.containsKey(acc.Id) || fileNamewithParent.containsKey(acc.Id) ){
					list<string> fileIds = fileParentMap.get(acc.Id);
                    list<string> filesName = fileNamewithParent.get(acc.Id);
					if(!fileIds.isEmpty()){
						for(string fileLabel : filesName){
							String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(fileLabel));
							fileNameWithBase64data.put(fileLabel,base64Data);
						}
					}
				 }   
                }*/
             }
        }
        
        finalBody =  '{'+String.join(fileBody, ',')+'}';
        system.debug('finalBody >> ' +finalBody);
        system.debug('fileBody size >> '+fileBody.size());
        system.debug('heap size used at file body '+Limits.getHeapSize());
        system.debug('folderIdWithFileName >> ' +folderIdWithFileName); 
        system.debug('fileLabelWithFolderId >> ' +fileLabelWithFolderId);
        
        if(system.Test.isRunningTest()){
            system.debug('isRunningTest');
        }else{
            BoxOneTimeApiCallOut.BoxOneTimeFilesupload(fileVersionMap,folderIdWithFileName,finalBody,fileNamewithParent,FileIdWithLabel,fileLabelWithFolderId,null);
         } 
        
        //making variable empty after use
        finalBody = null;
        folderIdWithFileName = null;
        fileLabelWithFolderId = null;
        fileNamewithParent = null;
        FileIdWithLabel = null;
        fileLabelWithFolderId = null;
        
        system.debug('heap size used at end of execute '+Limits.getHeapSize());
        system.debug('total heap size used at execute >> '+Limits.getLimitHeapSize());
    }
    global void finish(Database.BatchableContext context) {
     
    }
}