//
//  Created by CornerZhang on 14-8-28.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RemindItem;

@interface NXWeekdaysTableViewController : UITableViewController
@property (assign, nonatomic) RemindItem* remindItem;

+ (NSString*)stringFromWeekdaysMask:(NSUInteger)mask;

@end
