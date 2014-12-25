//
//  NXRemindTableViewCell.m
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import "NXRemindTableViewCell.h"
#import "RemindItem.h"
#import "NXRemindInputText.h"
#import "NXRemindCenter.h"
#import "NXWeekdaysTableViewController.h"

@interface NXRemindTableViewCell ()
@property (strong, nonatomic) NSTextStorage* textStorage;

@end

@implementation NXRemindTableViewCell
@synthesize itemData;
@synthesize textStorage;
@synthesize inputText;
@synthesize subTitle;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        textStorage = [[NSTextStorage alloc] initWithAttributedString:inputText.attributedText];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSAttributedString*)attributedText:(NSString*)text withStrike:(BOOL)strike {
    [textStorage beginEditing];
    
    NSDictionary *attribs = @{ NSStrikethroughStyleAttributeName: @(strike) };
    NSMutableAttributedString* textString = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
    [textStorage setAttributedString:textString];
    
    [textStorage endEditing];
    
    return textString;
}

- (void)userBuild {
    inputText.attributedText = [self attributedText:inputText.text withStrike:[itemData.taskCompleted boolValue]];
}

- (void)userBuildSubTitle {
    static NSString* subTitleFormats[] = {
        @"YYYY年MM月dd日 HH:MM",	// once
        @"每年 MM月dd日 HH:MM",		// year
        @"每月 dd日 HH:MM",			// month
        @"HH:MM",			// weekdays
        @"每天 HH:MM",				// day
    };
    
    if (itemData==nil) {
        subTitle.text = @"";
        return;
    }
    
    //NSTimeZone* timeZone = item.timeZone;
    
    unsigned char mask = [itemData getRepeatModeMask];
    [[NXRemindCenter sharedInstance].cellSubTitleFormatter setDateFormat:subTitleFormats[mask]];
    
    if (mask != RMRepeatMode_Weekdays) {
        NSString* t = [[NXRemindCenter sharedInstance].cellSubTitleFormatter stringFromDate:itemData.dataTime];
        subTitle.text = t;
    }else{
        NSString* weekdaysPrefix = [NXWeekdaysTableViewController stringFromWeekdaysMask:[itemData getWeekdaysMask]];
        NSString* weekdaysSuffix = [[NXRemindCenter sharedInstance].cellSubTitleFormatter stringFromDate:itemData.dataTime];
        subTitle.text = [NSString stringWithFormat:@"%@ %@", weekdaysPrefix, weekdaysSuffix];
    }
    
//    BOOL beStrike = YES;
//    if (item.timeConfigState == nil || [item.timeConfigState unsignedIntValue]==0) {
//        beStrike = NO;
//    }
    
//    zoneRepeatTime.attributedText = [self attributedText:zoneRepeatTime.text withStrike:beStrike];
}

- (void)doneToggle {
    BOOL mark = ![itemData.taskCompleted boolValue];
    
    itemData.taskCompleted = [NSNumber numberWithBool:mark];
    [[NXRemindCenter sharedInstance] saveContextWhenChanged];
    
    inputText.attributedText = [self attributedText:inputText.text withStrike:mark];
}

@end
