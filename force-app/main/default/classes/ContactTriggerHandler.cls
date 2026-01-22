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
                con.DummyJSON_Id__c = Math.round(MatH.random()*100).toString();
                System.debug('Value of randomNumber0To100:' );
            }
        }
        System.debug('See something');
    }

    /** this is the shell for the next steps
     * Can use a separate method for generating the random number
     * Pro, very modular.
     * If both of the below conditions happen in the same trigger context then I only need an else statement
     */
    
    public void handleAfterInsert(){
        if(hasFired){
            return;
        }
        hasFired = true;
        runAfterInsert();
        hasFired = false;
    }

    private void runAfterInsert(){
        System.debug('say something');
        //When a contact is inserted
        
    	// if DummyJSON_Id__c is less than or equal to 100, call the getDummyJSONUserFromId API    
        /* Loop through newContacts (trigger.new)
        Apply the condition
        Collect IDs
        Pass IDs to async integration**/

        //enqueue GET callout
        //DummyJSONCallout.getDummyJSONUserFromId();
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
        //When a contact is updated
        // if DummyJSON_Id__c is greater than 100, call the postCreateDummyJSONUser API
        //NOTE: Only fire when the value changes, not on every update.
        //check isChanged(pick a value)
        //All updated contacts where old value ≤ 100 and new value > 100
        //enqueue POST callout
        //That old vs new comparison is critical use oldContactsMap.
        System.debug('do something');
    }
}