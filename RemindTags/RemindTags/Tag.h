//
//  Tag.h
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *attachedItems;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addAttachedItemsObject:(NSManagedObject *)value;
- (void)removeAttachedItemsObject:(NSManagedObject *)value;
- (void)addAttachedItems:(NSSet *)values;
- (void)removeAttachedItems:(NSSet *)values;

@end
