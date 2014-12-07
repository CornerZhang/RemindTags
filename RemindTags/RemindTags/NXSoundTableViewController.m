
//  Created by CornerZhang on 14-9-8.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "NXSoundTableViewController.h"
#import "NXSoundTableViewCell.h"
#import "NXMusicItem.h"
#import "RemindItem.h"
#import "NXRemindCenter.h"

#define DEBUG 1

@interface NXSoundTableViewController () {
    NXRemindCenter* remindCenter;
    NXSoundTableViewCell* selectedCell;
    
}

@end

@implementation NXSoundTableViewController
@synthesize saveBarItem;
@synthesize soundItems;
@synthesize remindItem;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        soundItems = [NXMusicItem buildLibrayItems];

        remindCenter = [NXRemindCenter sharedInstance];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    saveBarItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath* selectDefaultItemIndexPath = [NSIndexPath indexPathForRow:[NXMusicItem indexOfSoundItem:remindItem.soundName]
                                                                 inSection:0];
	[self.tableView selectRowAtIndexPath:selectDefaultItemIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    selectedCell = (NXSoundTableViewCell*)[self.tableView cellForRowAtIndexPath:selectDefaultItemIndexPath];
    [selectedCell checkmarkOnSelf:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapSaveButton:(UIBarButtonItem *)sender {
    [remindCenter saveContextWhenChanged];
    
    [selectedCell stop];
    
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return soundItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell"];

    NXMusicItem* musicItem = [soundItems objectAtIndex:indexPath.row];
    selectedCell.musicItem = musicItem;
    [selectedCell buildSelf];
    
    return selectedCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCell = (NXSoundTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    saveBarItem.enabled = YES;
    
    [selectedCell play];
    
    remindItem.soundName = selectedCell.musicItem.fileName;
    
#if DEBUG
    NSLog(@"Running %@ '%@' - %ld", self.class, NSStringFromSelector(_cmd), (long)indexPath.row);
#endif
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCell = (NXSoundTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [selectedCell stop];
    
#if DEBUG
    NSLog(@"Running %@ '%@' - %ld", self.class, NSStringFromSelector(_cmd), (long)indexPath.row);
#endif
    return indexPath;
}

@end
