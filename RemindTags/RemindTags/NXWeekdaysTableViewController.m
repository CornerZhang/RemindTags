//
//  Created by CornerZhang on 14-8-28.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "NXWeekdaysTableViewController.h"
#import "NXRemindCenter.h"

@interface NXWeekdaysTableViewController () {
    BOOL weekdaysTag[7];
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) NXRemindCenter* remindCenter;

@end

static NSString* dayNames[7] = { @"一", @"二", @"三", @"四", @"五", @"六", @"日" };
static NSString* stringOfDayNamesHead = @"每周";
static NSString* stringOfDayNames = @"";

@implementation NXWeekdaysTableViewController
@synthesize remindItem;

+ (NSString*)stringFromWeekdaysMask:(NSUInteger)mask {
	BOOL tag;
    
    stringOfDayNames = stringOfDayNamesHead;
    
    for (int i=0; i<7; ++i) {
        tag = (mask>>i) & (0x01);
        if (tag) {
            stringOfDayNames = [stringOfDayNames stringByAppendingString:dayNames[i]];
            stringOfDayNames = [stringOfDayNames stringByAppendingString:@" "];
        }
    }
    
    return stringOfDayNames;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _remindCenter = [NXRemindCenter sharedInstance];
        
        [self clearWeekdayTags];
    }
    return self;
}

- (void)clearWeekdayTags {
    for (int i=0; i<7; ++i) {
		weekdaysTag[i] = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    stringOfDayNames = stringOfDayNamesHead;

    [self clearWeekdayTags];
    
	NSUInteger weekdaysMask = [remindItem getWeekdaysMask];
    BOOL tag = NO;
    for (int i=0; i<7; ++i) {
        tag = (weekdaysMask>>i) & (0x01);
		weekdaysTag[i] = tag;
    }
    
    _saveButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapSaveButton:(UIBarButtonItem *)sender {
    NSUInteger			lowMask = 0;
    
    for (int i=0; i<7; ++i) {
        if (weekdaysTag[i]) {
            lowMask = lowMask | (1<<i);
        }
    }
    
    [NXWeekdaysTableViewController stringFromWeekdaysMask:lowMask];
    
    [remindItem setWeekdaysMask:lowMask];
    [_remindCenter saveContextWhenChanged];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* newCell = [tableView dequeueReusableCellWithIdentifier:@"WeekdayCell" forIndexPath:indexPath];

    newCell.textLabel.text = dayNames[indexPath.row];
    if (weekdaysTag[indexPath.row]) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        newCell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    return newCell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _saveButton.enabled = YES;
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	NSUInteger index = indexPath.row;
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        weekdaysTag[index] = YES;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        weekdaysTag[index] = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
