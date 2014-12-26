//
//  NXRemindTableViewController.m
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import "NXRemindTableViewController.h"
#import "NXRemindCenter.h"
#import "NXRemindTableViewCell.h"
#import "NXRemindInputText.h"
#import "NXRemindParametersTableViewController.h"
#import <CoreData/CoreData.h>

#define DEBUG 1

@interface NXRemindTableViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NXRemindCenter* remindCenter;
@property (assign, nonatomic) BOOL userDrivenDataModelChange;
@property (assign, nonatomic) BOOL editState;
@property (weak, nonatomic) NXRemindTableViewCell* selectedCell;
@end

static NXRemindTableViewController* only;

@implementation NXRemindTableViewController
@synthesize editBarItem;
@synthesize statisticBarItem;
@synthesize userDrivenDataModelChange;
@synthesize textNormalColor;
@synthesize textTintColor;
@synthesize selectedCellIndexPath;
@synthesize editState;

+ (instancetype) sharedInstance {
    return only;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @synchronized(only) {
        only = self;
        userDrivenDataModelChange = NO;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _remindCenter = [NXRemindCenter sharedInstance];
    [_remindCenter setItemFetchControllerDelegate:self];
    [_remindCenter fetchItems];
    
    textNormalColor = [UIColor darkTextColor];
    textTintColor = self.tableView.tintColor;

    editState = self.tableView.editing;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateStatistic];
    
    UINavigationController* navigationController = self.navigationController;
    navigationController.toolbarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableVisibleCells:(BOOL)enable {
    for (UITableViewCell* cell in self.tableView.visibleCells) {
        NXRemindTableViewCell* remindCell = (NXRemindTableViewCell*)cell;
        remindCell.inputText.enabled = enable;
    }
}

- (IBAction)tapEditItem:(UIBarButtonItem *)sender {
    editState = !editState;
    
    [self.tableView setEditing:editState animated:YES];
    
    [self enableVisibleCells:!editState];
    
    // toolbar show/hidden
    UINavigationController* navigationController = self.navigationController;
    [UIView animateWithDuration:0.4
                     animations:^(void) {
                         navigationController.toolbarHidden = editState;
                     }
     ];


#if DEBUG
    NSLog(@"Running %@ '%@' -- editing: %d", self.class, NSStringFromSelector(_cmd), editState);
#endif
}

- (void)updateStatistic {
    NSUInteger n = [_remindCenter numberOfItems];

    [UIView animateWithDuration:0.4
                     animations:^(void) {
                         statisticBarItem.title = [NSString stringWithFormat:@"%lu个项目", (unsigned long)n];
                     }
     ];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_remindCenter numberOfItems] + 1;
}

- (BOOL)isForTailCell:(NSIndexPath*)indexPath {
    return indexPath.row == [_remindCenter numberOfItems];
}

- (void)configureCell:(NXRemindTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    RemindItem* data;
    
    if ([self isForTailCell:indexPath]) {
        cell.inputText.text = @"+";
        cell.inputText.textColor = textTintColor;

        cell.subTitle.text = nil;	// 使得外观动态调整
        cell.subTitle.hidden = YES;
    }else{
        data = [_remindCenter remindItemAtIndexPath:indexPath];
        cell.inputText.text = data.name;
        cell.inputText.textColor = textNormalColor;
        
        cell.subTitle.hidden = NO;
        cell.subTitle.enabled = YES;
        
        [cell userBuild];
    }
    
    cell.itemData = data;
    if (cell.itemData) {
        [cell userBuildSubTitle];
    }
    
    cell.inputText.indexPath = indexPath;
    cell.inputText.delegate = cell.inputText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindItemCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// 在编辑模式中
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
#if DEBUG
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
#endif

    if (editState) {
        [_remindCenter saveContext];
        if ( [self isForTailCell:indexPath] ) {
            return UITableViewCellEditingStyleNone;
        }else{
        	return UITableViewCellEditingStyleDelete;
        }
    }else{

        RemindItem* remindItem = [_remindCenter remindItemAtIndexPath:indexPath];
        if ([remindItem.timeConfigState unsignedIntValue]!=2) {	// 提醒
            if ( [self isForTailCell:indexPath] ) {
                return UITableViewCellEditingStyleNone;
            }
            
            return UITableViewCellEditingStyleDelete;
        }else{
            return UITableViewCellEditingStyleNone;
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
#if DEBUG
    NSLog(@"Running %@ '%@' -- editing: %d", self.class, NSStringFromSelector(_cmd), editState);
#endif

    if (editState) {
        return @"delete";
    }else{
        RemindItem* remindItem = [_remindCenter remindItemAtIndexPath:indexPath];
        
        return [remindItem.taskCompleted boolValue]? @"done" : @"undo";
    }
}

// move cells

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
    NXRemindTableViewCell* cell = (NXRemindTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [_remindCenter moveRemindItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    
    userDrivenDataModelChange = YES;
    [_remindCenter saveContext];
    userDrivenDataModelChange = NO;
    
    [self performSelector:@selector(configureCellAtIndexPath:) withObject:sourceIndexPath afterDelay:0.2];
    [self performSelector:@selector(configureCellAtIndexPath:) withObject:destinationIndexPath afterDelay:0.2];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row == [_remindCenter numberOfItems]) {	// 禁止与tail cell做重排
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isForTailCell:indexPath]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_remindCenter numberOfItems]) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editState) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // 删除RemindItem & cell
            
            RemindItem* remindItem = [_remindCenter remindItemAtIndexPath:indexPath];
            [_remindCenter cancelItem:remindItem];
            [_remindCenter deleteRemindItem:remindItem fromTag:nil];
            [self updateStatistic];
        }
    }else{
        // mark done!!!
        
        NXRemindTableViewCell* cell = (NXRemindTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell doneToggle];
        
        RemindItem* remindItem = [_remindCenter remindItemAtIndexPath:indexPath];
        if (remindItem.taskCompleted) {
            remindItem.timeConfigState = [NSNumber numberWithUnsignedShort:1];	// 有
            [_remindCenter cancelItem:remindItem];
        }else{
            remindItem.timeConfigState = [NSNumber numberWithUnsignedShort:0];	// 提醒
        	[_remindCenter postItem:remindItem];
        }
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    _selectedCell = (NXRemindTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NXRemindParametersTableViewController* parametersViewController = [segue destinationViewController];
    parametersViewController.itemCellIndexPath = self.selectedCellIndexPath;

}

#pragma mark -- NSFetchedResultsControllerDelegate

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (userDrivenDataModelChange)
        return;
    
    [self.tableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (userDrivenDataModelChange)
        return;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (userDrivenDataModelChange)
        return;
    
    [self.tableView endUpdates];
}

@end
