//
//  NXRemindParametersTableViewController.h
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXRemindParametersTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *timeConfigStatusLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timeConfigState;

// TimeZone | NSLocal ???

@property (strong, nonatomic) IBOutlet UIDatePicker *dateTimePicker;

@property (strong, nonatomic) IBOutlet UISegmentedControl *repeatModeSegmentedControl;

@property (strong, nonatomic) IBOutlet UILabel *weekdaysLabel;
@property (strong, nonatomic) IBOutlet UIButton *weekdaysEditButton;

@property (strong, nonatomic) IBOutlet UILabel *soundName;

@property (weak, nonatomic) NSIndexPath* itemCellIndexPath;
//@property (strong, nonatomic) NXFetchedRemindItemsController* fetchController;

- (IBAction)dateTimeChanged:(UIDatePicker *)sender;

@end
