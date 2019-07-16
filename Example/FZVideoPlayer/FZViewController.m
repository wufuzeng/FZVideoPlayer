//
//  FZViewController.m
//  FZVideoPlayer
//
//  Created by wufuzeng on 07/08/2019.
//  Copyright (c) 2019 wufuzeng. All rights reserved.
//

#import "FZViewController.h"

#import <FZVideoPlayer/FZVideoPlayer.h>
@interface FZViewController ()
@property (nonatomic,strong) FZVideoPlayer *player;

@property (nonatomic,strong) UIScrollView *scrollView;

@end

@implementation FZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self scrollView];
    //    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loginvideo" ofType:@"mp4"]];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Test" ofType:@"mov"]];
    self.player.title = @"屌丝男士";
    [self.player playWithUrl:url];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player stop];
}

-(void)dealloc{
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.player play];
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player pause];
    
    
}

-(UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      [UIScreen mainScreen].bounds.size.width,
                                                                     [UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor orangeColor];
        _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return _scrollView;
}


-(FZVideoPlayer *)player{
    if (_player == nil) {
        _player = [[FZVideoPlayer alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
        self.player.showControlView = YES;
        self.player.showTitleBar = YES;
        self.player.showBackBtn = NO;
        self.player.autoReplay = YES;
        self.player.disableFullScreen = NO;
        self.player.disableAdjustBrightnessOrVolume = YES;
        self.player.videoGravity = AVLayerVideoGravityResizeAspect;
        self.player.showInView = self.scrollView;
    }
    return _player;
}

@end
