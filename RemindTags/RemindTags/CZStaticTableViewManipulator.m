//
//  CZStaticTableViewManipulator.m
//  ABStaticTableViewController
//
//  Created by CornerZhang on 14-6-30.
//  Copyright (c) 2014年 Codeless Solutions. All rights reserved.
//

#import "CZStaticTableViewManipulator.h"

@implementation CZStaticTableViewManipulator
@synthesize tblView;
@synthesize tblViewController;
@synthesize rowsVisibility;
@synthesize sectionsVisibility;

- (instancetype)initWithTableView:(UITableView *)tableViewParam withController:(UITableViewController *)controller
{
    self = [super init];
    if (self) {
        self.tblView = tableViewParam;
		self.tblViewController = controller;
        
        rowsVisibility = [NSMutableDictionary dictionary];
        sectionsVisibility = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL)isRowVisible:(NSIndexPath *)indexPath
{
    BOOL(^block)() = self.rowsVisibility[indexPath];
    return (!block) || block();
}

- (BOOL)isSectionVisible:(NSInteger)section
{
    BOOL(^block)() = self.sectionsVisibility[@(section)];
    return (!block) || block();
}

- (NSIndexPath *)convertRow:(NSIndexPath *)indexPath
{
    NSInteger section = [self convertSection:indexPath.section];
    NSInteger rowDelta = 0;
    for (NSIndexPath *ip in [self.rowsVisibility.allKeys sortedArrayUsingSelector:@selector(compare:)])
    {
        if (ip.section == section
            && ip.row <= indexPath.row + rowDelta)
        {
            BOOL (^block)() = self.rowsVisibility[ip];
            rowDelta += block() ? 0 : 1;
        }
    }
    return [NSIndexPath indexPathForRow:indexPath.row + rowDelta inSection:section];
}

- (NSInteger)convertSection:(NSInteger)section
{
    NSInteger secDelta = 0;
    for (NSNumber *sec in [self.sectionsVisibility.allKeys sortedArrayUsingSelector:@selector(compare:)])
    {
        if (sec.integerValue <= section + secDelta)
        {
            BOOL (^block)() = self.sectionsVisibility[sec];
            secDelta += block() ? 0 : 1;
        }
    }
    return section + secDelta;
}

- (NSIndexPath *)recoverRow:(NSIndexPath *)indexPath
{
    NSInteger section = [self recoverSection:indexPath.section];
    int rowDelta = 0;
    for (NSIndexPath * ip in [self.rowsVisibility.allKeys sortedArrayUsingSelector:@selector(compare:)])
    {
        if (ip.section == indexPath.section
            && ip.row < indexPath.row)
        {
            BOOL (^block)() = self.rowsVisibility[ip];
            rowDelta += block() ? 0 : 1;
        }
    }
    return [NSIndexPath indexPathForRow:indexPath.row - rowDelta inSection:section];
}

- (NSInteger)recoverSection:(NSInteger)section
{
    NSInteger secDelta = 0;
    for (NSNumber *sec in [self.sectionsVisibility.allKeys sortedArrayUsingSelector:@selector(compare:)])
    {
        if (sec.integerValue < section)
        {
            BOOL (^block)() = self.sectionsVisibility[sec];
            secDelta += block() ? 0 : 1;
        }
    }
    return section - secDelta;
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *ip in indexPaths)
        [self.rowsVisibility removeObjectForKey:ip];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *ip in indexPaths)
        self.rowsVisibility[ip] = ^{ return NO; };
}

- (void)insertSections:(NSIndexSet *)sections
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger sec, BOOL *stop) {
        [self.sectionsVisibility removeObjectForKey:@(sec)];
    }];
}

- (void)deleteSections:(NSIndexSet *)sections
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger sec, BOOL *stop) {
        self.sectionsVisibility[@(sec)] = ^{ return NO; };
    }];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tblView beginUpdates];
    NSMutableArray *ips = [NSMutableArray array];
    for (NSIndexPath *ip in indexPaths)
        [ips addObject:[self recoverRow:ip]];
    [self.tblView insertRowsAtIndexPaths:ips withRowAnimation:animation];
    [self insertRowsAtIndexPaths:indexPaths];
    [self.tblView endUpdates];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tblView beginUpdates];
    NSMutableArray *ips = [NSMutableArray array];
    for (NSIndexPath *ip in indexPaths)
        [ips addObject:[self recoverRow:ip]];
    [self.tblView deleteRowsAtIndexPaths:ips withRowAnimation:animation];
    [self deleteRowsAtIndexPaths:indexPaths];
    [self.tblView endUpdates];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tblView beginUpdates];
    NSMutableIndexSet *secs = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger sec, BOOL *stop) {
        [secs addIndex:[self recoverSection:sec]];
    }];
    [self.tblView insertSections:secs withRowAnimation:animation];
    [self insertSections:sections];
    [self.tblView endUpdates];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tblView beginUpdates];
    NSMutableIndexSet *secs = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger sec, BOOL *stop) {
        [secs addIndex:[self recoverSection:sec]];
    }];
    [self.tblView deleteSections:secs withRowAnimation:animation];
    [self deleteSections:sections];
    [self.tblView endUpdates];
}

- (NSInteger)numberOfAdvancedSectionsInTableView {
    NSInteger count = 0;
    for (NSNumber *sec in self.sectionsVisibility) {
        BOOL (^block)() = self.sectionsVisibility[sec];
        count += block() ? 0 : 1;
    }
	return count;
}

- (tableViewSectionInfo_t)numberOfAdvancedRowsInSection:(NSInteger)section {
    tableViewSectionInfo_t secInfo;
    
    secInfo.realSection = [self convertSection:section];
    secInfo.advancedCount = 0;
    for (NSIndexPath *ip in self.rowsVisibility) {
        if (ip.section == secInfo.realSection) {
            BOOL (^block)() = self.rowsVisibility[ip];
            secInfo.advancedCount += block() ? 0 : 1;
        }
    }
	return secInfo;
}

#pragma delegate
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tblViewController tableView:tableView indentationLevelForRowAtIndexPath:[self convertRow:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [tblViewController tableView:tableView heightForHeaderInSection:[self convertSection:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tblViewController tableView:tableView heightForRowAtIndexPath:[self convertRow:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [tblViewController tableView:tableView heightForFooterInSection:[self convertSection:section]];
}




#pragma data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [tblViewController tableView:tableView titleForHeaderInSection:[self convertSection:section]];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [tblViewController tableView:tableView titleForFooterInSection:[self convertSection:section]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tblViewController numberOfSectionsInTableView:tableView] - [self numberOfAdvancedSectionsInTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableViewSectionInfo_t secInfo = [self numberOfAdvancedRowsInSection:section];
    return [tblViewController tableView:tableView numberOfRowsInSection:secInfo.realSection] - secInfo.advancedCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tblViewController tableView:tableView cellForRowAtIndexPath:[self convertRow:indexPath]];
}

@end
