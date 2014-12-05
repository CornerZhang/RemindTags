//
//  NXRemindCenter.h
//  Reminder_restarter
//
//  Created by CornerZhang on 14-8-14.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "Tag.h"
#import "RemindItem+repeatModeOpt.h"

extern NSString* const kRemindItemNameKey;


@class UIApplication;
@class NXAppDelegate;

typedef NS_ENUM(NSUInteger, NXRepeatMode) {
	RMRepeatMode_Once = 0,
    RMRepeatMode_Year,
    RMRepeatMode_Month,
    RMRepeatMode_Weekdays,
    RMRepeatMode_Day
};

typedef NS_ENUM(NSUInteger, NXWeekdays) {
	RMWeekday_1 = 1,
    RMWeekday_2 = 1<<1,
    RMWeekday_3 = 1<<2,
    RMWeekday_4 = 1<<3,
    RMWeekday_5 = 1<<4,
    RMWeekday_Sat = 1<<5,
    RMWeekday_Sun = 1<<6
};

@interface NXRemindCenter : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSDateFormatter*	cellSubTitleFormatter;

+ (instancetype)sharedInstance;

- (NSURL *)		applicationDocumentsDirectory;


// Tag
- (NSUInteger)	numberOfTags;
- (void)		fetchTags;
- (Tag*)		createBlankTag;
- (void)		deleteTag:(Tag*)Tag;

// RemindItems
- (void)		setItemFetchControllerDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (NSUInteger)	numberOfItems;
- (void)		fetchItems;
- (RemindItem*) remindItemAtIndexPath:(NSIndexPath*)indexPath;
- (RemindItem*)	createBlankRemindItemWithDisplayOrder:(Tag*)tag;
- (RemindItem*)	createBlankRemindItemWithDisplayOrder;
- (RemindItem*)	createBlankRemindItem;
- (void)		deleteRemindItem:(RemindItem*)item fromTag:(Tag*)tag;

// save
- (void)		saveContextWhenChanged;
- (void)		saveContext;

// post & cancel as system notification
- (void)		initForNotificaions:(UIApplication*)app withAppDelegate:(NXAppDelegate*)appDelegate withOptions:(NSDictionary *)launchOptions;
- (void)		importItemsFromDevice;
- (void)		postItem:(RemindItem*)msg;
- (void)		cancelItem:(RemindItem*)msg;
- (void)		cancelAllItems;

@end
