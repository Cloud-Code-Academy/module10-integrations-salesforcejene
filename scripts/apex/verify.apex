DummyJSONCallout.getDummyJSONUserFromId('47');

//insert contact
Contact newContact = new Contact (FirstName = 'Sam', LastName='Adams');
insert newContact;
System.debug('new Contact result: ' + newContact);

List<Contact> cont = [SELECT Id, Name, FirstName, LastName, DummyJSON_Id__c FROM Contact WHERE DummyJSON_Id__c != null];
System.debug('Contact results: ' + conResults);
System.debug('Contact results JSON: ' + JSON.serializePretty(conResults));