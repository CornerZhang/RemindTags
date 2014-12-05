//
//  RemindItem.h
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface RemindItem : NSManagedObject

@property (nonatomic, retain) NSDate * dataTime;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * repeatMode;
@property (nonatomic, retain) NSString * soundName;
@property (nonatomic, retain) NSNumber * taskCompleted;
@property (nonatomic, retain) NSNumber * timeConfigState;
@property (nonatomic, retain) NSNumber * timeZone;
@property (nonatomic, retain) NSSet *withTags;
@end

@interface RemindItem (CoreDataGeneratedAccessors)

- (void)addWithTagsObject:(Tag *)value;
- (void)removeWithTagsObject:(Tag *)value;
- (void)addWithTags:(NSSet *)values;
- (void)removeWithTags:(NSSet *)values;

@end
