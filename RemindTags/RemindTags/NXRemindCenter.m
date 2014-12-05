//
//  NXRemindCenter.m
//  Reminder_restarter
//
//  Created by CornerZhang on 14-8-14.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "NXRemindCenter.h"
#import "NXAppDelegate.h"
//#import "NXFetchedRemindItemsController.h"
//#import "NXMusicItem.h"

NSString* const kRemindItemNameKey = @"ItemName";

@interface NXRemindCenter () {
    NSSortDescriptor* 	tagOrder;
    UIApplication*		sharedApplication;
}
// common property
@property (strong, nonatomic) NSEntityDescription* tagEntityDesc;
@property (strong, nonatomic) NSEntityDescription* remindItemEntityDesc;

// pages property
@property (strong, nonatomic) NSFetchRequest*		fetchTagsRequest;
@property (strong, nonatomic) NSFetchedResultsController* tagFetchedController;

// remind items property
@property (strong, nonatomic) NSFetchRequest*		fetchRemindItemsRequest;
@property (strong, nonatomic) NSFetchedResultsController* itemFetchedController;

@end

static NXRemindCenter* only = nil;

@implementation NXRemindCenter
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize cellSubTitleFormatter;

+ (instancetype) sharedInstance {
    @synchronized(self) {
        if (only==nil) {
            only = [[NXRemindCenter alloc] init];
        }
    }
    return only;
}

- (id) init {
	self = [super init];
#if DEBUG
    NSLog(@"RMStorageManager msg: %@",NSStringFromSelector(_cmd));
#endif
        
    sharedApplication = [UIApplication sharedApplication];
    
    cellSubTitleFormatter = [[NSDateFormatter alloc] init];
    [cellSubTitleFormatter setDateStyle:NSDateFormatterShortStyle];
    [cellSubTitleFormatter setTimeStyle:NSDateFormatterShortStyle];

    [NSFetchedResultsController deleteCacheWithName:nil];
    
    // init tag about
    _fetchTagsRequest = [[NSFetchRequest alloc] init];
    self.tagEntityDesc = [self tagEntityDescription];
    [_fetchTagsRequest setEntity:self.tagEntityDesc];
	[_fetchTagsRequest setFetchBatchSize:8];
    
    tagOrder = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    _fetchTagsRequest.sortDescriptors = @[tagOrder];
    
    _tagFetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchTagsRequest
                                                                managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"TagCache"];
    _tagFetchedController.delegate = nil;
    
    [self fetchTags];
#if DEBUG
    NSLog(@"tag count %lu", (unsigned long)_tagFetchedController.fetchedObjects.count);
#endif
    
    // init items
    NSString* cacheName = [NSString stringWithFormat:@"Master Items"];
    self.remindItemEntityDesc = [self remindItemEntityDescription];
    
    _fetchRemindItemsRequest = [[NSFetchRequest alloc] init];
    [_fetchRemindItemsRequest setEntity:self.remindItemEntityDesc];
    [_fetchRemindItemsRequest setFetchBatchSize:32];
    
    NSSortDescriptor* 	displayOrder = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
    _fetchRemindItemsRequest.sortDescriptors = @[displayOrder];
    
    [_fetchRemindItemsRequest setFetchLimit:0];	// 获取数据项目不受限制!
    
    _itemFetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRemindItemsRequest
                                                                 managedObjectContext:[self managedObjectContext]
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:cacheName];
    _itemFetchedController.delegate = nil;
    
    return self;
}

- (NSURL *)		applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)		setItemFetchControllerDelegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    _itemFetchedController.delegate = delegate;
}

- (NSUInteger)	numberOfTags {
    
    return _tagFetchedController.fetchedObjects.count;
}

- (void)		fetchTags {
    NSError *fetchingError = nil;
    if ([_tagFetchedController performFetch:&fetchingError]){
        NSLog(@"Successfully to fetch tags.");
    } else {
        NSLog(@"Failed to fetch tags.");
    }
}

- (Tag*)		createBlankTag {
    Tag* newTag = [NSEntityDescription insertNewObjectForEntityForName:[self.tagEntityDesc name]
                                                  inManagedObjectContext:self.managedObjectContext];
	return newTag;
}

- (void)		deleteTag:(Tag *)tag	{
    [self.managedObjectContext deleteObject:tag];
    
    if ([tag isDeleted]) {
        NSError *savingError = nil;
        
        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"Successful to delete the managed object context.");
        } else {
            NSLog(@"Failed to delete the managed object context.");
        }
    }
}

- (NSUInteger)	numberOfItems {
    return _itemFetchedController.fetchedObjects.count;
}

- (void)		fetchItems {
    NSError *fetchingError = nil;
    if ([_itemFetchedController performFetch:&fetchingError]){
        NSLog(@"Successfully fetched for remind items.");
    } else {
        NSLog(@"Failed to fetch for remind items.");
    }
}

- (RemindItem*) remindItemAtIndexPath:(NSIndexPath*)indexPath {
    return [_itemFetchedController objectAtIndexPath:indexPath];
}

- (RemindItem*)		createBlankRemindItemWithDisplayOrder:(Tag*)tag {
    RemindItem* newItem = [self createBlankRemindItem];
    
    newItem.displayOrder = [NSNumber numberWithUnsignedInteger:tag.attachedItems.count];
    
#if DEBUG
    NSLog(@"Running %@ '%@' -- displayOrder: %@", self.class, NSStringFromSelector(_cmd), newItem.displayOrder);
#endif
    return newItem;
}

- (RemindItem*)		createBlankRemindItemWithDisplayOrder {
    RemindItem* newItem = [self createBlankRemindItem];
    
    newItem.displayOrder = [NSNumber numberWithUnsignedInteger:_itemFetchedController.fetchedObjects.count];
    
#if DEBUG
    NSLog(@"Running %@ '%@' -- displayOrder: %@", self.class, NSStringFromSelector(_cmd), newItem.displayOrder);
#endif
    return newItem;
}

- (RemindItem*)		createBlankRemindItem {
    RemindItem* newItem = [NSEntityDescription insertNewObjectForEntityForName:self.remindItemEntityDesc.name
                                                        inManagedObjectContext:self.managedObjectContext];
    return newItem;
}

- (void)		deleteRemindItem:(RemindItem*)item fromTag:(Tag*)tag {
    [tag removeAttachedItemsObject:item];
    [item removeWithTagsObject:tag];
    
    [self.managedObjectContext deleteObject:item];
    
    if ([item isDeleted]) {
        NSError *savingError = nil;

        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"Successful to delete the managed object context.");
        } else {
            NSLog(@"Failed to delete the managed object context.");
        }
    }
}

- (void)saveContextWhenChanged
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveContext {
    NSError *savingError = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if ([managedObjectContext save:&savingError]) {
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch.");
    }
}

- (void)		initForNotificaions:(UIApplication*)app withAppDelegate:(NXAppDelegate*)appDelegate withOptions:(NSDictionary *)launchOptions {
    
    // for iOS8
    BOOL existMethod = [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)];
    if ( existMethod ) {
        NSUInteger optionFlags = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:optionFlags categories:nil]];
    }
    
    // general issue
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
        UILocalNotification* notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        [appDelegate application:app didReceiveLocalNotification:notification];
    }
}

- (void)		importItemsFromDevice {
    //...
}

- (UILocalNotification*) findNotificationWithItem:(RemindItem*)item {
    return [self findNotification:item.name];
}

- (UILocalNotification*) findNotification:(NSString*)itemName {
    NSArray* notifications = sharedApplication.scheduledLocalNotifications;
    NSDictionary* userInfo = nil;
    NSString*	localItemName = nil;
    
    for (UILocalNotification* notification in notifications) {
        userInfo = notification.userInfo;
        
        localItemName = [userInfo objectForKey:kRemindItemNameKey];
        if ([localItemName compare:itemName] == NSOrderedSame) {
            // found it!
            return notification;
        }
    }
    return nil;
}

- (NSCalendarUnit) systemRepeatInterval:(NSUInteger)repeatMode {
    static NSUInteger repeatIntervalMap[] = {
        0,	// once
        NSCalendarUnitYear,
        NSCalendarUnitMonth,
        NSCalendarUnitWeekOfMonth,	// or NSWeekdayCalendarUnit ???
        NSCalendarUnitDay
    };
    
    return repeatIntervalMap[repeatMode];
}

- (void)		postItem:(RemindItem*)msg {
    UILocalNotification* foundNotification = [self findNotificationWithItem:msg];
    if (!foundNotification) {
        foundNotification = [[UILocalNotification alloc] init];	// create new

        NSDictionary* infoDictionary = @{kRemindItemNameKey: msg.name};
        foundNotification.userInfo = infoDictionary;
        foundNotification.applicationIconBadgeNumber = 0;
    }
    
    foundNotification.fireDate = msg.dataTime;
    foundNotification.timeZone = [NSTimeZone defaultTimeZone];
    foundNotification.repeatInterval = [self systemRepeatInterval:[msg getRepeatModeMask]];
    foundNotification.repeatCalendar = [NSCalendar currentCalendar];
    //foundNotification = [NXMusicItem sourcePathOfMusicItem:msg.soundName];
    foundNotification.hasAction = YES;
    foundNotification.alertAction = @"OK";
    foundNotification.alertBody = msg.name;
    [UIApplication sharedApplication].applicationIconBadgeNumber += 1;

    
    if ([msg getRepeatModeMask] == RMRepeatMode_Weekdays) {
        unsigned char weekdaysMask = [msg getWeekdaysMask];
        NSDate* startDate = foundNotification.fireDate;
        NSDate* eachDate = nil;
        NSDateComponents* startDateComps = [[NSDateComponents alloc] init];
        NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        startDateComps = [foundNotification.repeatCalendar components:flags fromDate:startDate];
        
        for (int i=0; i<7; ++i) {
            if (weekdaysMask & (1<<i)) {
                eachDate = [[foundNotification.repeatCalendar dateFromComponents:startDateComps] dateByAddingTimeInterval:3600*24*i];
                foundNotification.fireDate = eachDate;
                [sharedApplication scheduleLocalNotification:foundNotification];
            }
        }
    }else{
        [sharedApplication scheduleLocalNotification:foundNotification];
    }
    
#if DEBUG
    NSLog(@"Running %@ '%@' -- app badge: %ld", self.class, NSStringFromSelector(_cmd), (long)[UIApplication sharedApplication].applicationIconBadgeNumber);
#endif
}

- (void)		cancelItem:(RemindItem*)msg {
    UILocalNotification* foundNotification = [self findNotificationWithItem:msg];
    if (foundNotification) {
        [sharedApplication cancelLocalNotification:foundNotification];
        if ([UIApplication sharedApplication].applicationIconBadgeNumber>0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
        }
        
#if DEBUG
        NSLog(@"Running %@ '%@' -- app badge: %ld", self.class, NSStringFromSelector(_cmd), (long)[UIApplication sharedApplication].applicationIconBadgeNumber);
#endif

    }
}

- (void)		cancelAllItems {
    [sharedApplication cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(NSEntityDescription *) tagEntityDescription
{
    return [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
}

-(NSEntityDescription *) remindItemEntityDescription {
    return [NSEntityDescription entityForName:@"RemindItem" inManagedObjectContext:self.managedObjectContext];    
}

@end
