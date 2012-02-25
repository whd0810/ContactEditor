/*
 
 Contact editor by memeller@gmail.com
 
 
 */
#import "ContactEditor.h"
@implementation ContactEditor


ABAddressBookRef addressBook;



FREObject addContact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    addressBook=ABAddressBookCreate();
	uint32_t usernameLength;
    const uint8_t *name;
    uint32_t surnameLength;
    const uint8_t *surname;
    uint32_t usercontactLength;
    const uint8_t *contact;
    uint32_t usercompanyLength;
    const uint8_t *company;
    uint32_t useremailLength;
    const uint8_t *email;
	uint32_t websiteLength;
    const uint8_t *website;
	NSLog(@"Parsing data...");
    //Turn our actionscrpt code into native code.
    FREGetObjectAsUTF8(argv[0], &usernameLength, &name);
    FREGetObjectAsUTF8(argv[1], &surnameLength, &surname);
    FREGetObjectAsUTF8(argv[2], &usercontactLength, &contact);
    FREGetObjectAsUTF8(argv[3], &usercompanyLength, &company);
    FREGetObjectAsUTF8(argv[4], &useremailLength, &email);
	FREGetObjectAsUTF8(argv[5], &websiteLength, &website);
    NSString *username = nil;
    NSString *usersurname=nil;
    NSString *usercontact = nil;
    NSString *usercompany = nil;
    NSString *useremail = nil;
    NSString *userwebsite = nil;
    NSLog(@"Creating strings");
    //Create NSStrings from CStrings
    if (FRE_OK == FREGetObjectAsUTF8(argv[0], &usernameLength, &name)) {
        username = [NSString stringWithUTF8String:(char*)name];
    }
    if (FRE_OK == FREGetObjectAsUTF8(argv[1], &surnameLength, &name)) {
        usersurname = [NSString stringWithUTF8String:(char*)surname];
    }
    if (FRE_OK == FREGetObjectAsUTF8(argv[2], &usercontactLength, &contact)) {
        usercontact = [NSString stringWithUTF8String:(char*)contact];
    }
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[3], &usercompanyLength, &company)) {
        usercompany = [NSString stringWithUTF8String:(char*)company];
    }
    
    if (argc >= 4 && (FRE_OK == FREGetObjectAsUTF8(argv[4], &useremailLength, &email))) {
        useremail = [NSString stringWithUTF8String:(char*)email];
    }
    
    if (argc >= 5 && (FRE_OK == FREGetObjectAsUTF8(argv[5], &websiteLength, &website))) {
        userwebsite = [NSString stringWithUTF8String:(char*)website];
    }
    
    ABRecordRef aRecord = ABPersonCreate(); 
    CFErrorRef  anError = NULL;
    
    NSLog(@"Adding name");
    // Username
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, username, &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, usersurname, &anError);
    // Phone Number.
    if(usercontact)
    {
        NSLog(@"Adding phone number");
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multi, (CFStringRef)usercontact, kABWorkLabel, NULL);
        ABRecordSetValue(aRecord, kABPersonPhoneProperty, multi, &anError);
        CFRelease(multi);
    }
    // Company
    NSLog(@"Adding company");
    if(usercompany)
    {
        ABRecordSetValue(aRecord, kABPersonOrganizationProperty, usercompany, &anError);
    }
    //// email
    NSLog(@"Adding email");
    if(usercompany)
    {
        ABMutableMultiValueRef multiemail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiemail, (CFStringRef)useremail, kABWorkLabel, NULL);
        ABRecordSetValue(aRecord, kABPersonEmailProperty, multiemail, &anError);
        CFRelease(multiemail);
    }
    // website
    NSLog(@"Adding website");
    //NSLog(userwebsite);
    if(userwebsite)
    {
        ABMutableMultiValueRef multiweb = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiweb, (CFStringRef)userwebsite, kABHomeLabel, NULL);
        ABRecordSetValue(aRecord, kABPersonURLProperty, multiweb, &anError);
        CFRelease(multiweb);
    }
    // Function
    //ABRecordSetValue(aRecord, kABPersonJobTitleProperty, userrole, &anError);
    CFErrorRef error =nil;
    NSLog(@"Writing values");
    
    
    NSLog(@"Saving to contacts");
    ABAddressBookAddRecord(addressBook, aRecord, &error);
    if (error != NULL) { 
		
		NSLog(@"error while creating..");
	} 
    if(ABAddressBookHasUnsavedChanges)
    ABAddressBookSave(addressBook, &error);
    
    NSLog(@"Releasing data");
    CFRelease(aRecord);
    [username release];
    [usersurname release];
    [usercontact release];
    [usercompany release];
    [useremail release];
    [userwebsite release];
   // CFRelease(addressBook);
    return NULL;
}
FREObject getContacts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    NSLog(@"Getting contact data");
       addressBook=ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSLog(@"Parsing data");
    FREObject returnedArray = NULL;
    FRENewObject((const uint8_t*)"Array", 0, NULL, &returnedArray, nil);
    FRESetArrayLength(returnedArray, CFArrayGetCount(people));
    int32_t j=0;
    FREObject retStr=NULL;
    for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
        FREObject contact;
        FRENewObject((const uint8_t*)"Object", 0, NULL, &contact,NULL);
        
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        //person id
        int personId = (int)ABRecordGetRecordID(person);
         NSLog(@"Adding person with id: %i",personId);
        FREObject recordId;
        FRENewObjectFromInt32(personId, &recordId);
        FRESetObjectProperty(contact, (const uint8_t*)"recordId", recordId, NULL);
        
        //composite name
        CFStringRef personCompositeName = ABRecordCopyCompositeName(person);
        retStr=NULL;
        if(personCompositeName)
        {
            NSString *personCompositeString = [NSString stringWithString:(NSString *)personCompositeName];
            NSLog(@"Adding composite name: %@",personCompositeString);
            FRENewObjectFromUTF8(strlen([personCompositeString UTF8String])+1, (const uint8_t*)[personCompositeString UTF8String], &retStr);
            FRESetObjectProperty(contact, (const uint8_t*)"compositename", retStr, NULL);
            //[personCompositeString release];
            CFRelease(personCompositeName);
        }
        else
            FRESetObjectProperty(contact, (const uint8_t*)"compositename", retStr, NULL);
        
        retStr=NULL;
        
        
        
        //person first name
        CFStringRef personName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if(personName)
        {
            NSString *personNameString = [NSString stringWithString:(NSString *)personName];
            NSLog(@"Adding first name: %@",personNameString);
            FRENewObjectFromUTF8(strlen([personNameString UTF8String])+1, (const uint8_t*)[personNameString UTF8String], &retStr);
            FRESetObjectProperty(contact, (const uint8_t*)"name", retStr, NULL);
            //[personNameString release];
            CFRelease(personName);
        }
        else
            FRESetObjectProperty(contact, (const uint8_t*)"name", retStr, NULL);
        retStr=NULL;
        //surname
        CFStringRef personSurName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        if(personSurName)
        {
            NSString *personSurNameString = [NSString stringWithString:(NSString *)personSurName];
            NSLog(@"Adding last name: %@",personSurNameString);
            FRENewObjectFromUTF8(strlen([personSurNameString UTF8String])+1, (const uint8_t*)[personSurNameString UTF8String], &retStr);
            FRESetObjectProperty(contact, (const uint8_t*)"lastname", retStr, NULL);
            //[personSurNameString release];
            CFRelease(personSurName);
        }
        else
            FRESetObjectProperty(contact, (const uint8_t*)"lastname", retStr, NULL);
        retStr=NULL;
        
        //birthdate
        CFStringRef personBirthdate = ABRecordCopyValue(person, kABPersonBirthdayProperty);
        if(personBirthdate)
        {
            NSString *personBirthdateString = [NSString stringWithString:(NSString *)personBirthdate];
            NSLog(@"Adding birthdate: %@",personBirthdateString);
            FRENewObjectFromUTF8(strlen([personBirthdateString UTF8String])+1, (const uint8_t*)[personBirthdateString UTF8String], &retStr);
            FRESetObjectProperty(contact, (const uint8_t*)"birthdate", retStr, NULL);
            [personBirthdateString release];
            //CFRelease(personBirthdate);
        }
        else
            FRESetObjectProperty(contact, (const uint8_t*)"birthdate", retStr, NULL);
        
        //emails
        retStr=NULL;
        FREObject emailsArray = NULL;
        FRENewObject((const uint8_t*)"Array", 0, NULL, &emailsArray, nil);
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        if(emails)
        {
            for (CFIndex k=0; k < ABMultiValueGetCount(emails); k++) {
                NSString* email = (NSString*)ABMultiValueCopyValueAtIndex(emails, k);
                NSLog(@"Adding email: %@",email);
                FRENewObjectFromUTF8(strlen([email UTF8String])+1, (const uint8_t*)[email UTF8String], &retStr);
                FRESetArrayElementAt(emailsArray, k, retStr);
                [email release];
            }
            CFRelease(emails);
            FRESetObjectProperty(contact, (const uint8_t*)"emails", emailsArray, NULL);
        }
        else
            FRESetObjectProperty(contact, (const uint8_t*)"emails", NULL, NULL);
        retStr=NULL;
        //phones
        FREObject phonesArray = NULL;
        FRENewObject((const uint8_t*)"Array", 0, NULL, &phonesArray, nil);
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if(phones)
        {
            for (CFIndex k=0; k < ABMultiValueGetCount(phones); k++) {
                NSString* phone = (NSString*)ABMultiValueCopyValueAtIndex(phones, k);
                NSLog(@"Adding phone: %@",phone);
                FRENewObjectFromUTF8(strlen([phone UTF8String])+1, (const uint8_t*)[phone UTF8String], &retStr);
                FRESetArrayElementAt(phonesArray, k, retStr);
                [phone release];

            }
            CFRelease(phones);
            FRESetObjectProperty(contact, (const uint8_t*)"phones", phonesArray, NULL);            
        }
        else
            FRESetObjectProperty(contact, (const uint8_t*)"phones", NULL, NULL);

        //addContact to array*/
        NSLog(@"Adding element to array %ld",i);
        FRESetArrayElementAt(returnedArray, j, contact);
        j++;
        CFRelease(person);
    }
    NSLog(@"Release");
    CFRelease(addressBook);
    NSLog(@"Return data");
    return returnedArray;
}
FREObject getContactCount(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
        addressBook=ABAddressBookCreate();
    NSLog(@"Getting emails");
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    FREObject contactCount;
    FRENewObjectFromInt32(CFArrayGetCount(people), &contactCount);
        // create an instance of Object and save it to FREObject position
    NSLog(@"Release");
     CFRelease(addressBook);
    NSLog(@"Return data");
    return contactCount;
}

// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.

void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                     uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
	
    
	*numFunctionsToTest = 3;
	FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * 3);
    
	func[0].name = (const uint8_t*)"addContact";
	func[0].functionData = NULL;
	func[0].function = &addContact;
    func[1].name = (const uint8_t*)"getContacts";
	func[1].functionData = NULL;
	func[1].function = &getContacts;
    func[2].name = (const uint8_t*)"getContactCount";
	func[2].functionData = NULL;
	func[2].function = &getContactCount;
    
    
	*functionsToSet = func;
    NSLog(@"Exiting ContextInitializer()");
}



// ContextFinalizer()
//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// ContextFinalizer().

void ContactEditorContextFinalizer(FREContext ctx) {
	
    
    // Nothing to clean up.
    
	return;
}



// ExtInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void ContactEditorExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                                 FREContextFinalizer* ctxFinalizerToSet) {
	
  	*extDataToSet = NULL;
	*ctxInitializerToSet = &ContactEditorContextInitializer;
	*ctxFinalizerToSet = &ContactEditorContextFinalizer;
} 



// ExtFinalizer()
//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.

void ContactEditorExtFinalizer(void* extData) {
	
    
	// Nothing to clean up.
	
    
    
	return;
}

@end