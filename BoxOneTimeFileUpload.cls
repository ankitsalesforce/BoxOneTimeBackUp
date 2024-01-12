public class BoxOneTimeFileUpload implements Queueable,Database.AllowsCallouts{
	
    Public list<contentDocument> contentList;
    public list<Files_BackUp__c> fileToBeUpdate; 	
    
    public BoxOneTimeFileUpload(list<contentDocument>contentList,list<Files_BackUp__c> fileToBeUpdate){
        this.contentList = contentList;
        this.fileToBeUpdate = fileToBeUpdate;
    }
    
    public void execute(QueueableContext context){
        if(fileToBeUpdate.size() > 0){
            update fileToBeUpdate;
        }
        if(contentList.size() > 0 && !Test.isRunningTest()){
            database.executeBatch(new BoxOneTimeFileUploadBatch(contentList),1); //calling batch class to avoid heap size
        }
    }
}