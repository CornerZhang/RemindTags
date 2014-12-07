//
//  NXMusicItem.h
//  RemindNote
//
//  Created by CornerZhang on 14-9-14.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMusicItem : NSObject
@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSURL* sourcePath;

+ (NSMutableArray*)buildLibrayItems;
+ (NXMusicItem*)defaultMusicItem;
+ (NSUInteger)indexOfSoundItem:(NSString*)name;
+ (NSString*)sourcePathOfMusicItem:(NSString*)fileName;

- (instancetype) initWithName:(NSString*)name andSourcePath:(NSURL*)path;
- (NSString*) description;
@end
