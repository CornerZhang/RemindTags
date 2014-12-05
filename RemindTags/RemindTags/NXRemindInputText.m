//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import "NXRemindInputText.h"
#import "NXRemindTableViewController.h"
#import "NXRemindTableViewCell.h"
#import "RemindItem.h"
#import "NXRemindCenter.h"

@interface NXRemindInputText ()
@end

@implementation NXRemindInputText
@synthesize indexPath;

- (BOOL)textFieldShouldClear:(UITextField *)textField {
#if DEBUG
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
#endif
    if ( [textField.text compare:@"+"] == NSOrderedSame ) {
        textField.text = @"";	// clear
        return YES;
    }else{
        return NO;
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [NXRemindTableViewController sharedInstance].selectedCellIndexPath = indexPath;
    
    if ( textField.text.length != 0 ) {
        // 显示info view
        UITableViewCell* cell = [[NXRemindTableViewController sharedInstance].tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField.text.length != 0) {
//        // 显示info view
//        cell.accessoryType = UITableViewCellAccessoryDetailButton;
//    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
#if DEBUG
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
#endif
    
    // 隐藏info view
    NXRemindTableViewCell* cell = (NXRemindTableViewCell*)[[NXRemindTableViewController sharedInstance].tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ( ![[NXRemindTableViewController sharedInstance] isForTailCell:indexPath] ) {
        // 如果这是normal cell
        
        // 输入内容改为空时，提示用户输入不合法 (最好，输入时有全词completion)
        // ...
        
        cell.itemData.name = textField.text;
        [[NXRemindCenter sharedInstance] saveContext];
    }else{
        // 如果这是个tailCell时
        
        // checking textField.text
        // ...
        
        if (textField.text.length == 0) {	//输入内容为空，就保持“＋”
            textField.text = @"+";
        }else{
            RemindItem* newItem = [[NXRemindCenter sharedInstance] createBlankRemindItemWithDisplayOrder];
            
            newItem.name = textField.text;
            
            [[NXRemindCenter sharedInstance] saveContextWhenChanged];	// be cached to fetchController
            
            //[currentRemindItemsViewController.itemsCount updateDisplay];
            
            textField.text = @"+";
        }
    }
}

@end
