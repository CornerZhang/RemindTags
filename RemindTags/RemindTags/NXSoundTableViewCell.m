//
//  NXSoundTableViewCell.m
//  RemindNote
//
//  Created by CornerZhang on 14-9-8.
//  Copyright (c) 2014年 NeXtreme.com. All rights reserved.
//

#import "NXSoundTableViewCell.h"
#import "NXMusicItem.h"
#import <AVFoundation/AVFoundation.h>

#undef DEBUG
#define DEBUG 0

@interface NXSoundTableViewCell () <AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioPlayer* player;
@property (strong, nonatomic) NSTimer* timer;
@property (assign, nonatomic) NSTimeInterval pauseTime;
@end

@implementation NXSoundTableViewCell
@synthesize musicItem;
@synthesize playProgress;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)buildSelf {
    self.musicName.text = musicItem.fileName;
    self.accessoryType = UITableViewCellAccessoryNone;

    NSError* error = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicItem.sourcePath error:&error];
    _player.delegate = self;
    _player.numberOfLoops = -1;
    [_player prepareToPlay];
    
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playMusicProgress) userInfo:nil repeats:YES];
	_pauseTime = [_timer tolerance];
    _pauseTime = _timer.timeInterval;
    
    playProgress.progress = 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
#if DEBUG
    NSLog(@"Running %@ '%@' -- selected %d", self.class, NSStringFromSelector(_cmd), selected);
#endif
    
    [self checkmarkOnSelf:selected];

}

- (void)checkmarkOnSelf:(BOOL)check {
    if (check) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [_timer invalidate];
    }
}

- (void)playMusicProgress {
    playProgress.progress = _player.currentTime/_player.duration;
}

- (void)play {
    if (![_player isPlaying]) {
        [_player play];
        
        [_timer fire];
    }
}

- (void)stop {
    [_player stop];
        
    _player.currentTime = 0;
    [_player prepareToPlay];
}

@end
