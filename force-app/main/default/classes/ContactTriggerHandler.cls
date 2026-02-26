public with sharing class ContactTriggerHandler {

    //instantiating class variables as references to the trigger context variables
    private List<Contact>   newContacts     = new List<Contact>();
    private List<Contact>   oldContacts     = new List<Contact>();
    private Map<Id,Contact> newContactsMap  = new Map<Id,Contact>();
    private Map<Id,Contact> oldContactsMap  = new Map<Id,Contact>();
    //static flag to prevent recursion
    static Boolean hasFired = false;


    public ContactTriggerHandler(List<Contact> newContacts, List<Contact> oldContacts, Map<Id,Contact> newContactsMap, Map<Id,Contact> oldContactsMap) {
        this.newContacts    = newContacts;
        this.oldContacts    = oldContacts;
        this.newContactsMap = newContactsMap;
        this.oldContactsMap = oldContactsMap;
    }

    public static void setTriggerHasFired(Boolean result){
        hasFired = result;
    }

    public class ContactCalloutQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> contactIds;

        public ContactCalloutQueueable(Set<Id> contactIds){
            this.contactIds = contactIds;
        }

        public void execute(QueueableContext context){
            List<Contact> contactsList = [SELECT Id, FirstName, LastName, Email, Phone, DummyJSON_Id__c 
                            FROM Contact
                            WHERE Id IN :contactIds                            
                            WITH USER_MODE
                            LIMIT 100
                            ]; //lIMIT set as a safe guard to the 100 callout limt.

            for(Contact con : contactsList){
                if(con.DummyJSON_Id__c != null){
                    DummyJSONCallout.getDummyJSONUserFromId(con.DummyJSON_Id__c);
                }
            }
        }
    }


    public void handleBeforeInsert(){
        if(hasFired){
            return;
        }
        hasFired = true;
        runBeforeInsert();
        hasFired = false;
    }

    private void runBeforeInsert() {
        for (Contact con : newContacts){
            if (con.DummyJSON_Id__c == null){
                //generate random number
                con.DummyJSON_Id__c = Math.round(Math.random()*100).toString();
            }
        }
    }

    public void handleAfterInsert(){
        if(hasFired){
            return;
        }
        hasFired = true;
        runAfterInsert();
        hasFired = false;
    }    

    private void runAfterInsert(){
        Set<Id> idsToProcess = new Set<Id>();
        
        for (Contact con : newContacts){         
            if(con.DummyJSON_Id__c != null && Integer.valueOf(con.DummyJSON_Id__c) <= 100){
                idsToProcess.add(con.Id);
            }
        }
        If(!idsToProcess.isEmpty()){
            System.enqueueJob(new ContactCalloutQueueable(idsToProcess));
        }
    }

    public void handleAfterUpdate(){
        if(hasFired){
            return;
        }
        hasFired = true;
        runAfterUpdate();
        hasFired = false;
    }

    private void runAfterUpdate(){
    Set<Id> idsToProcess = new Set<Id>();        
        for(Contact newCon : newContacts){
            Contact oldCon = oldContactsMap.get(NewCon.Id);

            Integer oldVal = (oldCon.DummyJSON_Id__c != null) ? Integer.valueOf(oldCon.DummyJSON_Id__c) : 0;
            Integer newVal = (newCon.DummyJSON_Id__c != null) ? Integer.valueOf(newCon.DummyJSON_Id__c) : 0;

            if(oldVal <= 100 && newVal >= 100){
                idsToProcess.add(newCon.Id);
            }                
        }
        if(!idsToProcess.isEmpty()){
            System.enqueueJob(new ContactCalloutQueueable(idsToProcess));
        }        
    }
}