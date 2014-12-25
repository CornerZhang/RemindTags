//
//  NXMusicItem.m
//  RemindNote
//
//  Created by CornerZhang on 14-9-14.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "NXMusicItem.h"

#undef DEBUG
#define DEBUG 0

static __strong NSMutableArray* musicLibraryItems = nil;

@implementation NXMusicItem
@synthesize fileName;
@synthesize sourcePath;

+ (NSMutableArray*)buildLibrayItems {
    @synchronized(self) {
        if (musicLibraryItems==nil) {
            musicLibraryItems = [[NSMutableArray alloc] init];
            
            [NXMusicItem buildArrayOfSoundItems:musicLibraryItems];
        }        
    }
    return musicLibraryItems;
}

+ (void)buildArrayOfSoundItems:(NSMutableArray*)soundItemsArray {
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSURL* bundleDir = [[NSBundle mainBundle] bundleURL];
    NSArray *propertiesToGet = @[NSURLIsDirectoryKey];
    NSError *error = nil;
    NSArray *paths = [fileManager contentsOfDirectoryAtURL:bundleDir
                                includingPropertiesForKeys:propertiesToGet
                                                   options:0
                                                     error:&error];
    
    
    if (error != nil){
        NSLog(@"An error happened = %@", error);
    }
    
    NSArray* comps = nil;
    NSString* extName = nil;
    NSString* mediaFileName = nil;
    
    NXMusicItem* musicItem = nil;
    
    for (NSURL* path in paths) {
        extName = [path pathExtension];
        if ([extName isEqual: @"aif"]) {
            mediaFileName = [path lastPathComponent];
            comps = [mediaFileName componentsSeparatedByString:@"."];
#if DEBUG
            NSLog(@"Item name = %@", comps[0]);
            NSLog(@"-----------------------------------");
#endif
            musicItem = [[NXMusicItem alloc] initWithName:comps[0] andSourcePath:path];
            [soundItemsArray addObject:musicItem];
        }
    }
    
}

+ (NXMusicItem*)defaultMusicItem {
    return [musicLibraryItems firstObject];
}

+ (NSUInteger)indexOfSoundItem:(NSString*)name {
    BOOL (^findCondition)(NXMusicItem* , NSUInteger , BOOL *) = ^(NXMusicItem* obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj.fileName compare:name] == NSOrderedSame) {
            return YES;
        }
        return NO;
    };
    
    NSUInteger result = [musicLibraryItems indexOfObjectPassingTest:findCondition];
    return result;
}

+ (NSString*)sourceFullPathOfMusicItem:(NSString*)soundName {
    NSUInteger index = [NXMusicItem indexOfSoundItem:soundName];
    NXMusicItem* musicItem = [musicLibraryItems objectAtIndex:index];
    return [musicItem.sourcePath absoluteString];
}

+ (NSString*)sourceAppPathOfMusicItem:(NSString*)soundName {
    NSUInteger index = [NXMusicItem indexOfSoundItem:soundName];
    NXMusicItem* musicItem = [musicLibraryItems objectAtIndex:index];
    NSString* fileNameWithExt = [[NSString alloc] initWithFormat:@"%@.aif",musicItem.fileName];

    return fileNameWithExt;
}

- (instancetype)initWithName:(NSString *)name andSourcePath:(NSURL *)path {

    self = [super init];
    if (self) {
        fileName = name;
        sourcePath = path;
        
    }
    return self;
}

- (NSString*)description {
    NSString* desc = [super description];
    desc = [desc stringByAppendingString:fileName];
    desc = [desc stringByAppendingFormat:@" %@", [sourcePath absoluteString]];
    return desc;
}
@end
