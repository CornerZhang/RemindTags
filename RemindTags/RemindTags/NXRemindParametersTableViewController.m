//
//  NXRemindParametersTableViewController.m
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import "NXRemindParametersTableViewController.h"
#import "CZStaticTableViewManipulator.h"
//#import "NXWeekdaysConfigTableViewController.h"
//#import "NXSoundLibraryTableViewController.h"
#import "NXRemindCenter.h"
//#import "NXMusicItem.h"

@interface NXRemindParametersTableViewController ()
@property (weak, nonatomic) NXRemindCenter* remindCenter;
@property (weak, nonatomic) RemindItem* currentItemData;
@property (assign, nonatomic) NSUInteger lastTimeConfigState;

@end

@implementation NXRemindParametersTableViewController
@synthesize staticTableViewManipulator;
@synthesize timeConfigStatusLabel;
@synthesize timeConfigState;
@synthesize lastTimeConfigState;
@synthesize itemCellIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _remindCenter = [NXRemindCenter sharedInstance];
    _currentItemData = [_remindCenter remindItemAtIndexPath:itemCellIndexPath];
    
    staticTableViewManipulator = [[CZStaticTableViewManipulator alloc] initWithTableView:self.tableView withController:self];
    
    self.tableView.dataSource = staticTableViewManipulator;
    self.tableView.delegate = staticTableViewManipulator;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self readyRemindItem:_currentItemData];
    
    [self loadUIData:_currentItemData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self showRepeatModeCell: _repeatModeSegmentedControl.selectedSegmentIndex];
    [self showWeekdaysCell: _repeatModeSegmentedControl.selectedSegmentIndex==RMRepeatMode_Weekdays];
    [self showSoundSection: timeConfigState.selectedSegmentIndex==TCS_Remind];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readyRemindItem:(RemindItem*)item {
    
    // date time
    if ( item.dataTime==nil ) {
        item.dataTime = [NSDate date];	// 初始化为当前的日期时间
    }
    
    // displayOrder -- on other code
    
    // name -- be create & modify on RemindItemsView
    
    // repeat mode & weekdays mask
    if ( item.repeatMode==nil ) {
        [item setRepeatModeMask:RMRepeatMode_Once];	// 0 == once, as default
        [item setWeekdaysMask:0];	// clear flags
    }
    
    // sound name
    if ( item.soundName==nil ) {
        item.soundName = [NSString stringWithFormat:@""];
    }
    
    // taskCompleted
    if ( item.taskCompleted==nil) {
        item.taskCompleted = [NSNumber numberWithBool:NO];
    }
    
    // timeConfigState
    if ( item.timeConfigState==nil ) {
        item.timeConfigState = [NSNumber numberWithUnsignedShort:2];
    }
    
    // time zone
    if ( item.timeZone==nil ) {
        item.timeZone = [NSNumber numberWithUnsignedInt:0];
    }
}

enum timeConfigState_e {
    TCS_Remind,
    TCS_With,
    TCS_None
};

- (void)loadUIData:(RemindItem*)item {
    // navi title
    NSAssert(_currentItemData.name!=nil, @"RemindItem.name == nil");
    
    self.title = _currentItemData.name;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // navi backward
    //self.navigationItem.backBarButtonItem.title = item.ownerPage.name;
    
    // timeConfigState
    timeConfigState.selectedSegmentIndex = lastTimeConfigState = [item.timeConfigState unsignedShortValue];
    [self showDateTimeCells:timeConfigState.selectedSegmentIndex!=TCS_None];
    
    // tags
    //self.pageNameLabel.text = _currentRemindItem.ownerPage.name;
    
    // sound
    [self showSoundSection:timeConfigState.selectedSegmentIndex==TCS_Remind];
}

- (IBAction)tapSaveBarButtonItem:(UIBarButtonItem *)sender {
    // timeConfigState
    if (timeConfigState.selectedSegmentIndex==TCS_Remind) {
        [_remindCenter postItem:_currentItemData];
    }else{
        [_remindCenter cancelItem:_currentItemData];
    }
    
    // timeZone
    
    // ...
    
    // dataTime
    _currentItemData.dataTime = _dateTimePicker.date;
    
    // repeatMode
    [_currentItemData setRepeatModeMask:_repeatModeSegmentedControl.selectedSegmentIndex];
    
    // weekdaysFlags -- on other UI
    
    // tags
    
    // soundName -- on other UI
    
    // save
    [_remindCenter saveContextWhenChanged];
    
    [self.navigationController popViewControllerAnimated:YES];
}

typedef NSIndexPath* (^IndexPathValue)();

const NSUInteger sectionNumberTime = 0;
IndexPathValue ConstIndexPathDateTimeConfigState = ^() { return [NSIndexPath indexPathForRow:0 inSection:sectionNumberTime]; };
//IndexPathValue ConstIndexPathTimeZone = ^() { return [NSIndexPath indexPathForRow:1 inSection:0]; };
IndexPathValue ConstIndexPathDateTime = ^() { return [NSIndexPath indexPathForRow:1 inSection:sectionNumberTime]; };
IndexPathValue ConstIndexPathRepeatMode = ^() { return [NSIndexPath indexPathForRow:2 inSection:sectionNumberTime]; };
IndexPathValue ConstIndexPathWeekdaysTitle = ^() { return [NSIndexPath indexPathForRow:3 inSection:sectionNumberTime]; };

const NSUInteger sectionNumberPage = 1;
IndexPathValue ConstIndexPathPageName = ^() { return [NSIndexPath indexPathForRow:0 inSection:sectionNumberPage]; };

const NSUInteger sectionNumberSound = 2;
IndexPathValue ConstIndexPathSoundName = ^() { return [NSIndexPath indexPathForRow:0 inSection:sectionNumberSound]; };


- (void)showDateTimeCells:(BOOL)show {
    
    if (show) {
        NSUInteger repeatMode = [_currentItemData getRepeatModeMask];
        if (![staticTableViewManipulator isRowVisible:ConstIndexPathDateTime()]) {
            //[staticTableViewManipulator insertRowsAtIndexPaths:@[ConstIndexPathTimeZone()] withRowAnimation:(UITableViewRowAnimationTop)];
            [staticTableViewManipulator insertRowsAtIndexPaths:@[ConstIndexPathDateTime()] withRowAnimation:(UITableViewRowAnimationTop)];
            [staticTableViewManipulator insertRowsAtIndexPaths:@[ConstIndexPathRepeatMode()] withRowAnimation:(UITableViewRowAnimationTop)];
            
            [self showWeekdaysCell:repeatMode == RMRepeatMode_Weekdays];
        }
        
        // to UI
        [_dateTimePicker setDate:_currentItemData.dataTime animated:YES];
        [self showRepeatModeCell:repeatMode];
        [self showWeekdaysCell:YES];
    }else{
        if ([staticTableViewManipulator isRowVisible:ConstIndexPathDateTime()]) {
            [staticTableViewManipulator deleteRowsAtIndexPaths:@[//ConstIndexPathTimeZone()
                                                                 ConstIndexPathDateTime(),
                                                                 ConstIndexPathRepeatMode()]
                                              withRowAnimation:(UITableViewRowAnimationTop)];
            
            [self showWeekdaysCell:NO];
        }
    }
}

- (void)showRepeatModeCell:(NSUInteger)selectedIndex {
    _repeatModeSegmentedControl.selectedSegmentIndex = selectedIndex;
    if ([_currentItemData getRepeatModeMask] == RMRepeatMode_Weekdays && [_currentItemData getWeekdaysMask]==0) {
        _repeatModeSegmentedControl.selectedSegmentIndex = RMRepeatMode_Day;
    }
}

- (void)showWeekdaysCell:(BOOL)show {
    if (show) {
        if (![staticTableViewManipulator isRowVisible:ConstIndexPathWeekdaysTitle()]) {
            [staticTableViewManipulator insertRowsAtIndexPaths:@[ConstIndexPathWeekdaysTitle()] withRowAnimation:(UITableViewRowAnimationTop)];
        }
        
        // to UI
        NSUInteger lowMask = [_currentItemData getWeekdaysMask];
        //_weekdaysLabel.text = [NXWeekdaysConfigTableViewController stringFromWeekdaysMask:lowMask];
    }else{
        if ([staticTableViewManipulator isRowVisible:ConstIndexPathWeekdaysTitle()]) {
            [staticTableViewManipulator deleteRowsAtIndexPaths:@[ConstIndexPathWeekdaysTitle()] withRowAnimation:(UITableViewRowAnimationTop)];
        }
    }
}

- (void)showSoundSection:(BOOL)show {
    if (show) {
        if (![staticTableViewManipulator isSectionVisible:sectionNumberSound]) {
            [staticTableViewManipulator insertSections:[NSIndexSet indexSetWithIndex:sectionNumberSound]
                                      withRowAnimation:(UITableViewRowAnimationTop)];
        }
        
        // to UI
        _soundName.text = _currentItemData.soundName;
    }else{
        if ([staticTableViewManipulator isSectionVisible:sectionNumberSound]) {
            [staticTableViewManipulator deleteSections:[NSIndexSet indexSetWithIndex:sectionNumberSound]
                                      withRowAnimation:(UITableViewRowAnimationTop)];
        }
    }
}

- (IBAction)tapTimeConfigState:(UISegmentedControl *)sender {
    NSInteger sn = sender.selectedSegmentIndex;
    _currentItemData.timeConfigState = [NSNumber numberWithInteger:sn];
    
    if (sn==TCS_Remind) {
//        NXMusicItem* defaultMusicItem = [NXMusicItem defaultMusicItem];
//        _currentItemData.soundName = defaultMusicItem.fileName;
    }else{
        _currentItemData.soundName = @"";
    }
    
    [self showRepeatModeCell: _repeatModeSegmentedControl.selectedSegmentIndex];
    [self showDateTimeCells: sn!=TCS_None];
    [self showWeekdaysCell: _repeatModeSegmentedControl.selectedSegmentIndex==RMRepeatMode_Weekdays];
    [self showSoundSection: sn==TCS_Remind];
}


// 进入时区选择界面
// ...

// "时间选择器"操作
- (IBAction)dateTimeChanged:(UIDatePicker *)sender {
    _currentItemData.dataTime = sender.date;
}

- (IBAction)tapRepeatModeSegments:(UISegmentedControl *)sender {
#if DEBUG
    NSLog(@"selected weekdays mode");
#endif
    
    NSUInteger selectedState = sender.selectedSegmentIndex;
    
    // 循环模式选择时会影响时间选择器的样式
    switch (selectedState) {
        case 0:
        case 1:
        case 2: {
            _dateTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }   break;
        case 3:
        case 4: {
            _dateTimePicker.datePickerMode = UIDatePickerModeTime;
        }
    }
    
    // to store data
    switch (sender.selectedSegmentIndex) {
        case 0:
            [_currentItemData setRepeatModeMask:RMRepeatMode_Once];
            break;
        case 1:
            [_currentItemData setRepeatModeMask:RMRepeatMode_Year];
            break;
        case 2:
            [_currentItemData setRepeatModeMask:RMRepeatMode_Month];
            break;
        case 3:
            [_currentItemData setRepeatModeMask:RMRepeatMode_Weekdays];
            break;
        case 4:
            [_currentItemData setRepeatModeMask:RMRepeatMode_Day];
            break;
    }
    
    // 当选择“每周...”进入选择"具体周几的界面"
    // 当没有选择此项时，不显示“格式化信息栏”
    if (sender.selectedSegmentIndex == RMRepeatMode_Weekdays) {
//        NXWeekdaysConfigTableViewController* weekdaysViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NXWeekdaysConfigTableViewController"];
//        weekdaysViewController.remindItem = _currentRemindItem;
//        
//        [self.navigationController pushViewController:weekdaysViewController animated:YES];
    }else{	// other selection
        [self showWeekdaysCell:NO];
    }
}

// 格式化信息栏显示“每周...”的细节内容
//- (IBAction)tapWeekdaysEdit:(UIButton *)sender {
//    NXWeekdaysConfigTableViewController* weekdaysViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NXWeekdaysConfigTableViewController"];
//    weekdaysViewController.remindItem = _currentRemindItem;
//    
//    [self.navigationController pushViewController:weekdaysViewController animated:YES];
//}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // tap右侧的“》”回进入音效选择界面，左侧显示选择的音乐名称，默认设置为“布谷鸟”
    
//    if ( [segue.identifier compare: @"ToSoundLibrary"] == NSOrderedSame ) {
//        NXSoundLibraryTableViewController* soundLibaray = [segue destinationViewController];
//        
//        soundLibaray.remindItem = _currentRemindItem;
//    }
}

@end
