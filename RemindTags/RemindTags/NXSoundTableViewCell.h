//
//  NXSoundTableViewCell.h
//  RemindNote
//
//  Created by CornerZhang on 14-9-8.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXMusicItem;

@interface NXSoundTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *musicName;
@property (strong, nonatomic) IBOutlet UIProgressView *playProgress;
@property (weak, nonatomic) NXMusicItem* musicItem;

- (void)checkmarkOnSelf:(BOOL)check;
- (void)buildSelf;

- (void)play;
- (void)stop;

@end
