//
//  RemindItem+repeatModeOpt.m
//  RemindNote
//
//  Created by CornerZhang on 14-9-7.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "RemindItem+repeatModeOpt.h"

@implementation RemindItem (repeatModeOpt)

- (void)setRepeatModeMask:(NSUInteger)mode {
    NSUInteger value = [self.repeatMode unsignedIntegerValue];
    unsigned char hiMaskWeekdays = ((value>>8) & (0xff));
    unsigned char lowMaskRepeat = (mode & (0xff));
    
    NSUInteger masks = (hiMaskWeekdays<<8) | lowMaskRepeat;
    self.repeatMode = [NSNumber numberWithUnsignedInteger:masks];
}

- (void)setWeekdaysMask:(NSUInteger)bits {	// on low 8 bits
    NSUInteger value = [self.repeatMode unsignedIntegerValue];
    unsigned char lowMaskRepeat = (value & (0xff));
    NSUInteger masks = (bits<<8) | lowMaskRepeat;
    
	self.repeatMode = [NSNumber numberWithUnsignedInteger:masks];
}

- (unsigned char)getRepeatModeMask {
	return ([self.repeatMode unsignedIntegerValue] & 0xff);
}

- (unsigned char)getWeekdaysMask {
    NSUInteger value = [self.repeatMode unsignedIntegerValue];
    return ((value>>8) & (0xff));
}

@end
