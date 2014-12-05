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

@interface NXRemindTableViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NXRemindCenter* remindCenter;
@property (assign, nonatomic) BOOL userDrivenDataModelChange;

@end

static NXRemindTableViewController* only;

@implementation NXRemindTableViewController
@synthesize userDrivenDataModelChange;
@synthesize textNormalColor;
@synthesize textTintColor;
@synthesize selectedCellIndexPath;

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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        cell.subTitle.hidden = YES;
        cell.subTitle.enabled = NO;
        
    }else{
        data = [_remindCenter remindItemAtIndexPath:indexPath];
        cell.inputText.text = data.name;
        cell.inputText.textColor = textNormalColor;
        
        cell.subTitle.hidden = YES;
        cell.subTitle.enabled = NO;
        
    }
    
    cell.itemData = data;

    cell.inputText.indexPath = indexPath;
    cell.inputText.delegate = cell.inputText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindItemCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


// 在编辑模式中
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//#if DEBUG
//    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//#endif
//    if (self.editing) {
//        if ( ![self isForTailCell:indexPath] ) {
//            return UITableViewCellEditingStyleDelete;
//        }
//    }
//    
//    return UITableViewCellEditingStyleNone;
//}

//-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//    [fetchRemindItemsController moveRemindItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
//    
//    userDrivenDataModelChange = YES;
//    [remindCenter saveContext];
//    userDrivenDataModelChange = NO;
//    
//    [self performSelector:@selector(configureCellAtIndexPath:) withObject:sourceIndexPath afterDelay:0.2];
//    [self performSelector:@selector(configureCellAtIndexPath:) withObject:destinationIndexPath afterDelay:0.2];
//}

//-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
//    if (proposedDestinationIndexPath.row == [self numberOfRowsFirstSection]) {	// 禁止与tail cell做重排
//        return sourceIndexPath;
//    }
//    
//    return proposedDestinationIndexPath;
//}

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == [self numberOfRowsFirstSection]) {
//        return NO;
//    }
//    
//    return YES;
//}

//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == [self numberOfRowsFirstSection]) {
//        return NO;
//    }
//    
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        RemindItem* remindItem = [fetchRemindItemsController objectAtIndexPath:indexPath];
//        if ([remindItem.timeConfigState unsignedIntValue]== 0) {
//            [remindCenter cancelItem:remindItem];
//        }
//        [remindCenter deleteRemindItem:remindItem fromPage:controller.page];
//    }
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//#if DEBUG
//    NSLog(@"Running %@ '%@' -- setEditing", self.class, NSStringFromSelector(_cmd));
//#endif
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
