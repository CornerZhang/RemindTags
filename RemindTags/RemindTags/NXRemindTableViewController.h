//
//  NXRemindTableViewController.h
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXRemindTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statisticBarItem;

@property (strong, nonatomic) UIColor*	textNormalColor;
@property (strong, nonatomic) UIColor*	textTintColor;
@property (weak, nonatomic) NSIndexPath* selectedCellIndexPath;

+ (instancetype)	sharedInstance;

- (BOOL)isForTailCell:(NSIndexPath*)indexPath;

- (void)updateStatistic;

@end
