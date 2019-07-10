//
//  FZVideoPlayControlView.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoPlayControlView.h"

#import "FZVideoPlayerTitleBar.h"
#import "FZVideoPlayerToolBar.h"
#import "FZVideoLightView.h"
#import "FZVideoVolumeView.h"

#import "FZVideoPlayerBundle.h"

@interface FZVideoPlayControlView ()

@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) FZVideoPlayerTitleBar *titleBar;
@property (nonatomic,strong) FZVideoPlayerToolBar  *toolBar;
@property (nonatomic,strong) FZVideoLightView      *lightControlView;
@property (nonatomic,strong) FZVideoVolumeView     *volumeControlView;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *retryButton;

@property (nonatomic,strong) NSTimer        *timer;
@property (nonatomic,assign) NSInteger      timeCount;
@property (nonatomic,assign) NSTimeInterval totalInterVals;
@property (nonatomic,assign) BOOL           isSliding;

@property (nonatomic,assign,readonly) CGFloat titleBarHeight;
@property (nonatomic,strong) NSLayoutConstraint *layoutTitleBarTop;

@end

@implementation FZVideoPlayControlView


#pragma mark -- Life Cycle Func ------------

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.opaque                 = YES;
        self.backgroundColor        = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.playerStatus  = VideoPlayerStatusPrepare;
        self.playerStyle  = VideoPlayerStyleNormal;
        [self timer];
        [self setupViews];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //[self setBufferInterval:self.bufferInterval];
}



-(void)setupViews{
    
    [self contentView];
    
    [self titleBar];
    [self toolBar];
    
    [self lightControlView];
    [self volumeControlView];
    
    [self playButton];
    [self retryButton];
    
    [self.contentView bringSubviewToFront:self.playButton];
    [self.contentView bringSubviewToFront:self.retryButton];
    
    self.title = @"标题";
}



#pragma mark - 设置播放器时间，进度等 ---

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    [self.toolBar.playProgress layoutIfNeeded];
}

-(void)setTotalInterval:(NSTimeInterval)totalInterval{
    _totalInterval = totalInterval;
    self.toolBar.totalTimeLabel.text = [FZVideoPlayControlView convertTime:totalInterval];
    self.toolBar.playProgress.maximumValue = totalInterval;
    _totalInterVals = totalInterval;
}

-(void)setBufferInterval:(NSTimeInterval)bufferInterval{
    _bufferInterval = bufferInterval;
    CGFloat scale = 0;
    if (bufferInterval) {
        if (bufferInterval<self.totalInterval) {
            scale = _bufferInterval/self.totalInterval;
        }else{
            scale = 1;
        }
    }else{
        scale = 0;
    }
    self.toolBar.bufferProgress.value = scale;
    self.toolBar.buffer_track_right.constant = -(1 - scale) * self.toolBar.bufferProgress.frame.size.width;
    
}

-(void)setProgressInterval:(NSTimeInterval)progressInterval{
    _progressInterval = progressInterval;
    self.toolBar.currentTimeLabel.text = [FZVideoPlayControlView convertTime:progressInterval];
    self.toolBar.playProgress.value = progressInterval;
}


#pragma mark -- Customs Func ----

-(void)showControlViewWithfireTimer:(BOOL)fire{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        if (fire) {
            [self fireTimer];
        }
    }];
}

-(void)hideControlView{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self cancelTimer];
    }];
}

-(void)fireTimer{
    [self.timer fire];
}

-(void)cancelTimer{
    self.timeCount = 0;
    //取消定时器
    [self.timer invalidate];
    self.timer = nil;
}

/**
 转换成显示的时间
 
 @param second 秒数
 @return 返回转换后的字符串
 */
+ (NSString *)convertTime:(CGFloat)second{
    
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}


#pragma mark -- Action Func ----

-(void)backButtonAction:(UIButton*)sender {
    if (self.playerStyle == VideoPlayerStyleFullScreenLeft) {
        if (self.showTitleBar) {
            self.layoutTitleBarTop.constant = 0;
        }else{
            self.layoutTitleBarTop.constant = -self.titleBarHeight;
        }
        self.playerStyle = VideoPlayerStyleNormal;
        if ([self.delegate respondsToSelector:@selector(control:playerStyleChanged:)]) {
            [self.delegate control:self playerStyleChanged:self.playerStyle];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(control:didClickedWithBackButton:)]) {
            [self.delegate control:self didClickedWithBackButton:sender];
        }
    }
}

-(void)controlViewTapAction:(UITapGestureRecognizer*)sender{
    
    if (self.contentView.alpha == 1) {
        [self hideControlView];
    }else{
        [self showControlViewWithfireTimer:YES];
    }
}

- (void)timerAction:(NSTimer *)sender {
    if (self.timeCount < 1.5) {
        self.timeCount++;
    } else {
        [self cancelTimer];
        [self hideControlView];
    }
}

- (void)fullScreenButtonAction:(UIButton *)sender {
    if (self.playerStyle == VideoPlayerStyleFullScreenLeft) {
        if (self.showTitleBar) {
            self.layoutTitleBarTop.constant = 0;
        }else{
            self.layoutTitleBarTop.constant = -self.titleBarHeight;
        }
        self.playerStyle = VideoPlayerStyleNormal;
    } else {
        self.layoutTitleBarTop.constant = 0;
        self.playerStyle = VideoPlayerStyleFullScreenLeft;
    }
}

-(void)playButtonAction:(UIButton *)sender {
    if (self.playerStatus == VideoPlayerStatusPaused ||
        self.playerStatus == VideoPlayerStatusPrepare ||
        self.playerStatus == VideoPlayerStatusFinished) {
        
        [self cancelTimer];
        [self showControlViewWithfireTimer:NO];
        
        self.playerStatus = VideoPlayerStatusPlaying;
    } else if (self.playerStatus == VideoPlayerStatusPlaying) {
        
        [self cancelTimer];
        self.playerStatus = VideoPlayerStatusPaused;
    }
}

-(void)retryButtonAction:(UIButton *)sender {
    self.playerStatus = VideoPlayerStatusPlaying;
    if ([self.delegate respondsToSelector:@selector(control:playerStatusChanged:)]) {
        [self.delegate control:self playerStatusChanged:self.playerStatus ];
    }
}

- (void)progressChanged:(UISlider *)sender {
    //赋值播放时间
    self.toolBar.currentTimeLabel.text = [FZVideoPlayControlView convertTime:sender.value];
    
    //进度条变化回调
    if ([self.delegate respondsToSelector:@selector(control:progressChanged:)]) {
        [self.delegate  control:self progressChanged:self.toolBar.playProgress.value];
    }
}

- (void)progressTouchDown:(UISlider *)sender {
    
    self.isSliding = YES;
    
    [self cancelTimer];
    
    if ([self.delegate respondsToSelector:@selector(control:sliderChanged:)]) {
        [self.delegate control:self sliderChanged:self.isSliding];
    }
}

- (void)progressTouchUp:(UISlider *)sender {
    
    self.isSliding = NO;
    
    [self fireTimer];
    
    if ([self.delegate respondsToSelector:@selector(control:sliderChanged:)]) {
        [self.delegate control:self sliderChanged:self.isSliding];
    }
}

#pragma mark -- Set Func -------

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleBar.titleLabel.text = title;
}

-(void)setPlayerStatus:(VideoPlayerStatus)playerStatus {
    
    if (_playerStatus != playerStatus) {
        _playerStatus = playerStatus;
        if ([self.delegate respondsToSelector:@selector(control:playerStatusChanged:)]) {
            [self.delegate control:self playerStatusChanged:playerStatus ];
        }
    }
    
    if (self.playerStatus == VideoPlayerStatusPlaying ||
        self.playerStatus == VideoPlayerStatusStoped) {
        
        //播放,重播 按钮
        self.playButton.selected = YES;
        self.playButton.alpha = 1;
        self.retryButton.alpha = 0;
    } else if (self.playerStatus == VideoPlayerStatusPaused ||
               self.playerStatus == VideoPlayerStatusSeeking) {
        //播放,重播 按钮
        self.playButton.selected = NO;
        self.playButton.alpha = 1;
        self.retryButton.alpha = 0;
    } else if (self.playerStatus == VideoPlayerStatusFinished ||
               self.playerStatus == VideoPlayerStatusPrepare) {
        
        //播放,重播 按钮
        self.playButton.selected = NO;
        self.playButton.alpha = 0;
        self.retryButton.alpha = 1;
        
        //重置toolBar
        self.toolBar.currentTimeLabel.text = @"00:00";
        self.toolBar.playProgress.value = 0;
        
//        [self showControlViewWithfireTimer:self.autoReplay];
    }
}

-(void)setPlayerStyle:(VideoPlayerStyle)playerStyle {
    
    if (_playerStyle != playerStyle) {
        _playerStyle = playerStyle;
        if ([self.delegate respondsToSelector:@selector(control:playerStyleChanged:)]) {
            [self.delegate control:self playerStyleChanged:playerStyle ];
        }
    }
    if (_playerStyle == VideoPlayerStyleFullScreenLeft ||
        _playerStyle ==  VideoPlayerStyleFullScreenRight) {
        self.toolBar.fullScreenButton.selected = NO;
        self.titleBar.backButton.alpha = 1;
        self.layoutTitleBarTop.constant = 0;
        
        if ([self isIPhoneXSeries]) {
            self.titleBar.layoutBackLeft.constant = 20;
            self.toolBar.layoutFullScreenRight.constant = -20;
        }else{
            self.titleBar.layoutBackLeft.constant = 0;
            self.toolBar.layoutFullScreenRight.constant = 0;
        }
        
    } else if (_playerStyle == VideoPlayerStyleNormal) {
        self.toolBar.fullScreenButton.selected = YES;
        self.toolBar.layoutFullScreenRight.constant = 0;
        if (self.showTitleBar) {
            if (self.showBackBtn == NO) {
                self.titleBar.backButton.alpha = 0;
            }
            self.layoutTitleBarTop.constant = 0;
            self.titleBar.layoutBackLeft.constant = 0;
        }else{
            self.layoutTitleBarTop.constant = -self.titleBarHeight;
        }
    }
}

-(void)setDisableFullScreen:(BOOL)disableFullScreen{
    _disableFullScreen = disableFullScreen;
    if (_disableFullScreen == YES) {
        self.toolBar.fullScreenButton.alpha = 0;
        self.toolBar.layoutFullScreenRight.constant = 45;
    }else{
        self.toolBar.fullScreenButton.alpha = 1;
    }
}


- (void)setShowBackBtn:(BOOL)showBackBtn {
    _showBackBtn = showBackBtn;
    if (!_showBackBtn && self.playerStyle == VideoPlayerStyleNormal) {
        self.titleBar.backButton.alpha = 0;
    }
}

 

#pragma mark -- Lazy Func -------

-(UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.alpha = 0;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        
        [self addConstraints:@[top,left,bottom,right]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlViewTapAction:)];
        [self addGestureRecognizer:tap];
    }
    return _contentView;
}



-(FZVideoPlayerTitleBar *)titleBar{
    if (_titleBar == nil) {
        _titleBar = [[FZVideoPlayerTitleBar alloc]init];
        
        _titleBar.backgroundColor = [UIColor blackColor];
        
        [self.contentView addSubview:_titleBar];
        _titleBar.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:self.showTitleBar?0:-self.titleBarHeight];
        self.layoutTitleBarTop = top;
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_titleBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.titleBarHeight];
        
        [self.contentView addConstraints:@[top,left,right,height]];
        
        [_titleBar.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _titleBar;
}

-(FZVideoPlayerToolBar *)toolBar{
    if (_toolBar == nil) {
        _toolBar = [[FZVideoPlayerToolBar alloc]init];
        
        _toolBar.backgroundColor = [UIColor blackColor];
        
        [self.contentView addSubview:_toolBar];
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.contentView addConstraints:@[left,bottom,right,height]];
        
        [_toolBar.playProgress addTarget:self action:@selector(progressTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_toolBar.playProgress addTarget:self action:@selector(progressChanged:) forControlEvents:UIControlEventValueChanged];
        [_toolBar.playProgress addTarget:self action:@selector(progressTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [_toolBar.fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolBar;
}



-(FZVideoLightView *)lightControlView{
    if (_lightControlView == nil) {
        _lightControlView = [[FZVideoLightView alloc] init];
        __weak __typeof(self) weakSelf = self;
        _lightControlView.touchActionBlock = ^(UIGestureRecognizerState state) {
            switch (state) {
                case UIGestureRecognizerStateBegan:{
                    [weakSelf cancelTimer];
                    break;}
                case UIGestureRecognizerStateEnded:{
                    [weakSelf fireTimer];
                    break;}
                default:
                    break;
            }
        };
        [self.contentView addSubview:_lightControlView];
        _lightControlView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.titleBar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1 constant:0];
        NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1 constant:0];
        NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.toolBar
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint * width = [NSLayoutConstraint constraintWithItem:_lightControlView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.5 constant:0];
        
        [self.contentView addConstraints:@[top,left,bottom,width]];
        
        
        
    }
    return _lightControlView;
}

-(FZVideoVolumeView *)volumeControlView{
    if (_volumeControlView == nil) {
        
        _volumeControlView = [[FZVideoVolumeView alloc] init];
        __weak __typeof(self) weakSelf = self;
        _volumeControlView.touchActionBlock = ^(UIGestureRecognizerState state) {
            switch (state) {
                case UIGestureRecognizerStateBegan:{
                    [weakSelf cancelTimer];
                    break;}
                case UIGestureRecognizerStateEnded:{
                    [weakSelf fireTimer];
                    break;}
                default:
                    break;
            }
        };
        [self.contentView addSubview:_volumeControlView];
        _volumeControlView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.titleBar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1 constant:0];
        NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.toolBar
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1 constant:0];
        NSLayoutConstraint * width = [NSLayoutConstraint constraintWithItem:_volumeControlView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.5 constant:0];
        
        [self.contentView addConstraints:@[top,bottom,right,width]];
        
        
        
    }
    return _volumeControlView;
}


-(UIButton *)playButton{
    if (_playButton == nil) {
        
        _playButton = [[UIButton alloc] init];
        [self.contentView addSubview:_playButton];
        
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_playButton
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_playButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_playButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:0 multiplier:1 constant:50];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_playButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:0 multiplier:1 constant:50];
        [self.contentView addConstraints:@[centerX,centerY,width,height]];
        
        
 
        
        
        [_playButton setImage:[FZVideoPlayerBundle fz_imageNamed:@"btn_video_play_90x90"] forState:UIControlStateNormal];
        [_playButton setImage:[FZVideoPlayerBundle fz_imageNamed:@"btn_video_stop_90x90"] forState:UIControlStateSelected];
        
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _playButton;
}




-(UIButton *)retryButton{
    if (_retryButton == nil) {
        _retryButton = [[UIButton alloc] init];
        
        [self.contentView addSubview:_retryButton];
        
        _retryButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil  attribute:0 multiplier:1 constant:60];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:30];
        [self.contentView addConstraints:@[centerX,centerY,width,height]];
        
        
        [_retryButton setImage:[FZVideoPlayerBundle fz_imageNamed:@"btn_play_again_icon_160x80"] forState:UIControlStateNormal];
        _retryButton.alpha = 0;
        [_retryButton addTarget:self action:@selector(retryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}




-(NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
    return _timer;
}

-(CGFloat)titleBarHeight{
    return 40;
}

-(BOOL)isIPhoneXSeries{
    if ([UIScreen mainScreen].bounds.size.width == 375.f && [UIScreen mainScreen].bounds.size.height == 812.f) {
        return YES;
    } else if ([UIScreen mainScreen].bounds.size.width == 414.f && [UIScreen mainScreen].bounds.size.height == 896.f) {
        return YES;
    }else{
        return NO;
    }
}


@end

