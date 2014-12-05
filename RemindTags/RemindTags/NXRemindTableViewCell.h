//
//  NXRemindTableViewCell.h
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXRemindInputText;
@class RemindItem;

@interface NXRemindTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet NXRemindInputText *inputText;
@property (strong, nonatomic) IBOutlet UILabel *subTitle;

@property (weak, nonatomic)	RemindItem* itemData;

@end
