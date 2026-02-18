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

    
    public class CalloutQueueable implements Queueable, Database.AllowsCallouts {
        private Set<String> dummyIdsFromTrigger;

        public CalloutQueueable(Set<String> dummyIds){
            this.dummyIdsFromTrigger = dummyIds;
        }

        public void execute(QueueableContext context){
            List<Contact> contactsList = [SELECT FIELDS(STANDARD), DummyJSON_Id__c 
                FROM Contact
                WHERE Id IN :dummyIdsFromTrigger
                WITH USER_MODE
                LIMIT 100
                ];

            for(Contact con : contactsList){
                if(con.DummyJSON_Id__c != null){
                    //call service class logic      
                    DummyJSONCallout.getDummyJSONUserFromId(con.DummyJSON_Id__c);
                }
                System.debug('Async callout triggered for: ' + con.LastName + con.DummyJSON_Id__c);
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
                System.debug('Value of DummyJSON_Id__c:' + con.DummyJSON_Id__c );
            }
        }
        System.debug('See something');
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
        Set<String> dummyIdsToProcess = new Set<String>();
        
        for (Contact con : newContacts){
            // if DummyJSON_Id__c is less than or equal to 100, call the getDummyJSONUserFromId API            
            if(con.DummyJSON_Id__c != null && Integer.valueOf(con.DummyJSON_Id__c) <= 100){
                dummyIdsToProcess.add(con.DummyJSON_Id__c);
            }
        } //check for data first
        If(!dummyIdsToProcess.isEmpty()){
            System.enqueueJob(new CalloutQueueable(dummyIdsToProcess));
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
    Set<String> dummyIdsToProcess = new Set<String>();        
        for(Contact newCon : newContacts){
            //define oldMap reference to compare old vs new values
            Contact oldCon = oldContactsMap.get(NewCon.DummyJSON_Id__c);

            //Check whehter values are changed using ternary operator
            Integer oldVal = (oldCon.DummyJSON_Id__c != null) ? Integer.valueOf(oldCon.DummyJSON_Id__c) : 0;
            Integer newVal = (newCon.DummyJSON_Id__c != null) ? Integer.valueOf(newCon.DummyJSON_Id__c) : 0;

            //Value comparison logic
            // if(oldVal <= 100 && newVal >= 100){
            //     dummyIdsToProcess.add(newCon.Id);
            //     System.debug('value of newConId: ' + newCon.Id);
            //     System.debug('value of newCon Last Name: ' + newCon.LastName);
            // }
            if(oldVal <= 100 && newVal >= 100){
                dummyIdsToProcess.add(newCon.DummyJSON_Id__c);
                System.debug('value of newDummyId: ' + newCon.DummyJSON_Id__c);
                System.debug('value of newCon Last Name: ' + newCon.LastName);
            }       
        }
        //update set of Ids after verifying
        if(!dummyIdsToProcess.isEmpty()){
            System.enqueueJob(new CalloutQueueable(dummyIdsToProcess));
        }        
    }
}