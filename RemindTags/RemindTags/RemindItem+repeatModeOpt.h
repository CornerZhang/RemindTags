//
//  RemindItem+repeatModeOpt.h
//  RemindNote
//
//  Created by CornerZhang on 14-9-7.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "RemindItem.h"

@interface RemindItem (repeatModeOpt)

- (void)setRepeatModeMask:(NSUInteger)mode;	// on low 8 bits, be set on low 8 bits of repeatMode
- (void)setWeekdaysMask:(NSUInteger)bits;	// on low 8 bits, be set on high 8 bits of repeatMode

- (unsigned char)getRepeatModeMask;
- (unsigned char)getWeekdaysMask;

@end
