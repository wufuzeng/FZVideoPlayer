
//
//  FZVideoPlayer.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoPlayer.h"

#import "FZVideoManager.h"
@interface FZVideoPlayer ()
/** 播放管理 */
@property (nonatomic,strong) FZVideoManager *videoManager;
/** 播放控制界面 */
@property (nonatomic,strong) FZVideoPlayControlView *controlView;

/** 原始的rect */
@property (nonatomic,assign) CGRect originRect;
/** 视频链接 */
@property (nonatomic,copy)   NSURL *urlPath;

@end

@implementation FZVideoPlayer

#pragma mark -- Life Cycle Func -------

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self addObserver];
    }
    return self;
}

-(void)dealloc{
    
    NSLog(@"%@释放了",NSStringFromClass([self class]));
    [self removeObserver];
}

#pragma mark -- SetupViews Func -----
/** 配置视图 */
-(void)setupView{
    self.backgroundColor = [UIColor blackColor];
    self.layer.masksToBounds = YES;
    self.originRect = self.frame;
    [self controlView];
}


#pragma mark -- Notice Func -------

/** 添加监听 */
-(void)addObserver{
    //-------------------------------监听屏幕方向-------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void) handleDeviceOrientationDidChange:(NSNotification *)notifi {
    UIDevice *device = [UIDevice currentDevice];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (device.orientation == UIDeviceOrientationPortrait ||
            device.orientation == UIDeviceOrientationPortraitUpsideDown) {
            //竖屏
            self.controlView.playerStyle = VideoPlayerStyleNormal;
            
        } else if (device.orientation == UIDeviceOrientationLandscapeLeft) {
            if (self.disableFullScreen) {
                
            }else{
                self.controlView.playerStyle = VideoPlayerStyleFullScreenLeft;
            }
        } else if (device.orientation == UIDeviceOrientationLandscapeRight) {
            if (self.disableFullScreen) {
                
            }else{
                self.controlView.playerStyle = VideoPlayerStyleFullScreenRight;
            }
        } else{
            // 不处理
        }
    });
}

#pragma mark -- Play Func -------------


-(void)playWithUrl:(NSURL *)url {
    _urlPath = url;
    self.videoManager.item = [[FZVideoPlayItem alloc] initWithURL:url];
}


-(void)play{
    self.controlView.playerStatus  = VideoPlayerStatusPlaying;
    self.videoManager.playerStatus = VideoPlayerStatusPlaying;
}


-(void)pause{
    self.controlView.playerStatus  = VideoPlayerStatusPaused;
    self.videoManager.playerStatus = VideoPlayerStatusPaused;
}

- (void)stop{
    self.controlView.playerStatus  = VideoPlayerStatusStoped;
    self.videoManager.playerStatus = VideoPlayerStatusStoped;
}


#pragma mark -- FZPlayControlDelegate ---------
/** 播放状态改变 */
- (void)control:(FZVideoPlayControlView *)control playerStatusChanged:(VideoPlayerStatus)playerStatus{
    
    self.videoManager.playerStatus = playerStatus;
    [self bringSubviewToFront:self.controlView];
    
    if ([self.delegate respondsToSelector:@selector(player:playerStatusChanged:)]) {
        [self.delegate player:self playerStatusChanged:playerStatus];
    }
}

- (void)control:(FZVideoPlayControlView *)control playerStyleChanged:(VideoPlayerStyle)playerStyle{
    if (playerStyle == VideoPlayerStyleFullScreenLeft) {
        [self rotateView:UIDeviceOrientationLandscapeLeft];
    } else if (playerStyle == VideoPlayerStyleFullScreenRight) {
        [self rotateView:UIDeviceOrientationLandscapeRight];
    } else {
        [self rotateView:UIDeviceOrientationPortrait];
    }
    
    //传递视图状态的改变
    if ([self.delegate respondsToSelector:@selector(player:playerStyleChanged:)]){
        [self.delegate player:self playerStyleChanged:playerStyle];
    }
}

- (void)control:(FZVideoPlayControlView *)control progressChanged:(NSTimeInterval)timeInterval{
    [self.videoManager playWithTimeInterval:timeInterval];
}

- (void)control:(FZVideoPlayControlView *)control sliderChanged:(BOOL)isSliding{
    if (isSliding) {
        self.videoManager.playerStatus = VideoPlayerStatusPaused;
    }
    self.videoManager.isSliding = isSliding;
}

- (void)control:(FZVideoPlayControlView *)control didClickedWithBackButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(control:didClickedWithBackButton:)]){
        [self.delegate player:self didClickedWithBackButton:button];
    }
}


#pragma mark - FZPlayManagerDelegate ---
/** 播放状态改变 */
- (void)manager:(FZVideoManager *)manager playerStatusChanged:(VideoPlayerStatus)playerStatus{
    
    if (self.controlView.playerStatus == playerStatus) {
        return;
    }
    self.controlView.playerStatus = playerStatus;
    [self bringSubviewToFront:self.controlView];
    
    switch (playerStatus) {
        case VideoPlayerStatusPlaying:{
            [self play];
        } break;
        case VideoPlayerStatusFinished:{
            if (self.autoReplay) {
                [self play];
            }
        } break;
        default:
            break;
    } 
    //传递播放状态的改变
    if ([self.delegate respondsToSelector:@selector(player:playerStatusChanged:)]){
        [self.delegate player:self playerStatusChanged:playerStatus ];
    }
    
}
/** 总时间改变 */
- (void)manager:(FZVideoManager *)manager playItem:(FZVideoPlayItem *)playItem totalIntervalChanged:(NSTimeInterval)totalInterval {
    [self.controlView setTotalInterval:totalInterval];
}
/** 时间表更新(当前播放位置) */
- (void)manager:(FZVideoManager *)manager  playItem:(FZVideoPlayItem *)playItem progressIntervalChanged:(NSTimeInterval)progressInterval{
    [self.controlView setProgressInterval:progressInterval];
}
/** 缓存时间改变 */
- (void)manager:(FZVideoManager *)manager playItem:(FZVideoPlayItem *)playItem bufferIntervalChanged:(NSTimeInterval)bufferInterval {
    [self.controlView setBufferInterval:bufferInterval];
}



#pragma mark -- Rotation Func ----

/**
 旋转播放视图
 */
-(void)rotateView:(UIDeviceOrientation)orientation {
    
    [self bringSubviewToFront:self.controlView];
    
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        //隐藏系统状态栏
        [[[UIApplication sharedApplication] keyWindow] setWindowLevel:UIWindowLevelNormal];
//        [self removeFromSuperview];
        [self.showInView addSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            //更新并旋转主界面
            if (orientation == UIDeviceOrientationPortrait) {
                self.transform = CGAffineTransformMakeRotation(0/180.0 * M_PI);
            }else{
                self.transform = CGAffineTransformMakeRotation(180/180.0 * M_PI);
            }
            self.frame = self.originRect;
        }];
    } else if (orientation == UIDeviceOrientationLandscapeLeft ||
               orientation == UIDeviceOrientationLandscapeRight) {
        //打开系统的状态条
        [[[UIApplication sharedApplication] keyWindow] setWindowLevel:UIWindowLevelStatusBar];
//        [self removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
        [UIView animateWithDuration:0.3 animations:^{
            //更新并旋转主界面
            if (orientation == UIDeviceOrientationLandscapeLeft) {
                self.transform = CGAffineTransformMakeRotation(90/180.0 * M_PI);
            }else{
                self.transform = CGAffineTransformMakeRotation(270/180.0 * M_PI);
            }
            self.frame  = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            self.layer.cornerRadius = 0;
        }];
    }
}

#pragma mark -- Set Func -----

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect nRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.videoManager.playerLayer.frame = nRect;
    self.controlView.frame = nRect;
    [self.controlView layoutIfNeeded];
}


-(void)setTitle:(NSString *)title {
    _title = title;
    self.controlView.title = title;
}

-(void)setShowBackBtn:(BOOL)showBackBtn {
    _showBackBtn = showBackBtn;
    self.controlView.showBackBtn = showBackBtn;
}

-(void)setDisableFullScreen:(BOOL)disableFullScreen{
    _disableFullScreen = disableFullScreen;
    self.controlView.disableFullScreen = disableFullScreen;
}

-(void)setDisableAdjustBrightnessOrVolume:(BOOL)disableAdjustBrightnessOrVolume{
    _disableAdjustBrightnessOrVolume = disableAdjustBrightnessOrVolume;
    self.controlView.disableAdjustBrightnessOrVolume = disableAdjustBrightnessOrVolume;
}

-(void)setShowInView:(UIView *)showInView {
    _showInView = showInView;
    [_showInView addSubview:self];
}

-(void)setShowControlView:(BOOL)showControlView {
    _showControlView = showControlView;
    if (!showControlView) {
        [_controlView removeFromSuperview];
    }
}
-(void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    self.videoManager.playerLayer.videoGravity = _videoGravity;
}

-(void)setAutoReplay:(BOOL)autoReplay {
    _autoReplay = autoReplay;
    self.videoManager.autoReplay = autoReplay;
    self.controlView.autoReplay = autoReplay;
}

-(void)setShowTitleBar:(BOOL)showTitleBar{
    _showTitleBar = showTitleBar;
    self.controlView.showTitleBar = showTitleBar;
}


#pragma mark -- Lazy Func -----

-(FZVideoPlayControlView *)controlView{
    if (_controlView == nil) {
        _controlView = [[FZVideoPlayControlView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _controlView.delegate = self;
        [self addSubview:_controlView];
    }
    return _controlView;
}

-(FZVideoManager *)videoManager {
    if (_videoManager == nil) {
        _videoManager = [[FZVideoManager alloc] init];
        _videoManager.delegate = self;
        [self.layer addSublayer:_videoManager.playerLayer];
    }
    return _videoManager;
}


@end
