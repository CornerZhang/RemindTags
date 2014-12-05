//
//  CZStaticTableViewManipulator.h
//  ABStaticTableViewController
//
//  Created by CornerZhang on 14-6-30.
//  Copyright (c) 2014年 Codeless Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct tableViewSectionInfo_s {
    NSInteger realSection;
    NSInteger advancedCount;
} tableViewSectionInfo_t;

@interface CZStaticTableViewManipulator : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic)	UITableView*			tblView;
@property (weak, nonatomic) UITableViewController*	tblViewController;
@property (strong, nonatomic) NSMutableDictionary *	rowsVisibility;
@property (strong, nonatomic) NSMutableDictionary *	sectionsVisibility;

- (instancetype)initWithTableView:(UITableView *)tableViewParam withController:(UITableViewController*)controller;

- (BOOL)isRowVisible:(NSIndexPath *)indexPath;
- (BOOL)isSectionVisible:(NSInteger)section;

- (NSIndexPath *)convertRow:(NSIndexPath *)indexPath;
- (NSInteger)convertSection:(NSInteger)section;
- (NSIndexPath *)recoverRow:(NSIndexPath *)indexPath;
- (NSInteger)recoverSection:(NSInteger)section;

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (NSInteger)numberOfAdvancedSectionsInTableView;
- (tableViewSectionInfo_t)numberOfAdvancedRowsInSection:(NSInteger)section;

@end

@protocol CZStaticTableViewDelegate
@optional


@end