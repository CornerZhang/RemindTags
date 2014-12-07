//
//  Created by CornerZhang on 14-9-8.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RemindItem;

@interface NXSoundTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarItem;

@property (weak, nonatomic) NSMutableArray* soundItems;
@property (assign, nonatomic) RemindItem* remindItem;

@end
