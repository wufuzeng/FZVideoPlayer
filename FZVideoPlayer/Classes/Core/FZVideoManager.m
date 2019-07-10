//
//  FZVideoManager.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoManager.h"

@interface FZVideoManager ()
/** 播放对象 (控制 开始，跳转，暂停，停止)*/
@property (nonatomic,strong) AVPlayer *player;
/** 总秒数 */
@property (nonatomic,assign) NSTimeInterval totalSecond;
/** 视频持续时间 */
@property (nonatomic,assign) CGFloat duration;
/** 帧率 */
@property (nonatomic,assign) CGFloat fps;
/** 播放对象定期观察者 */
@property (nonatomic,strong) id playerObserve;

@end

@implementation FZVideoManager
/**
 初始化播放器
 
 @return 返回实例化的播放器
 */
-(instancetype)init{
    if (self = [super init]) {
        
        _player = [AVPlayer new];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        
        //AVAudioSession是音频会话的一个单例，将指定该APP在与系统之间的通信中如何使用音频。不加没有声音
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
        
        __weak typeof(FZVideoManager *)weakSelf = self;
        //对于1分钟以内的视频就每1/30秒刷新一次页面，大于1分钟的每秒一次就行 (总时间，时间刻度)：每段=总时间/时间刻度
        CMTime interval = self.duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
        //这个方法就是每隔多久调用一次block，函数返回的id类型的对象在不使用时用-removeTimeObserver:释放，官方api是这样说的
        _playerObserve = [_player addPeriodicTimeObserverForInterval:interval
                                                               queue:dispatch_get_main_queue()
                                                          usingBlock:^(CMTime time) {
                                                              
          if (CMTimeGetSeconds(time) >= weakSelf.totalSecond) {
              weakSelf.playerStatus = VideoPlayerStatusFinished;
              if ([weakSelf.delegate respondsToSelector:@selector(manager:playerStatusChanged:)]) {
                  [weakSelf.delegate manager:weakSelf playerStatusChanged:weakSelf.playerStatus];
              }
          } else {
              [weakSelf scheduleRefreshControl];
          }
      }];
    }
    return self;
}


/**
 跳转进度播放
 
 @param timeinterval  位置
 */
- (void) playWithTimeInterval:(NSTimeInterval)timeinterval {
    self.playerStatus = VideoPlayerStatusPaused;
    
    CMTime startTime = CMTimeMakeWithSeconds(timeinterval, _fps);
    
    if ([self.delegate respondsToSelector:@selector(manager:playItem:progressIntervalChanged:)]) {
        [self.delegate manager:self  playItem:self.item progressIntervalChanged:timeinterval];
    }
    
    __weak typeof(FZVideoManager *)weakSelf = self;
    
    /** 跳转进度 */
    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {
        
        if (!weakSelf.isSliding) {
            weakSelf.playerStatus = VideoPlayerStatusPlaying;
            if ([weakSelf.delegate respondsToSelector:@selector(manager:playerStatusChanged:)]) {
                [weakSelf.delegate manager:weakSelf playerStatusChanged:weakSelf.playerStatus];
            }
        }
    }];
}

#pragma mark - 设置方法
/**
 设置播放状态
 
 @param playerStatus 播放状态
 */
-(void)setPlayerStatus:(VideoPlayerStatus)playerStatus {
    
    switch (playerStatus) {
        case VideoPlayerStatusPlaying:{
            [self.player play];
            break;}
        case VideoPlayerStatusPaused:
        case VideoPlayerStatusSeeking:{
            [self.player pause];
            break;}
        case VideoPlayerStatusFinished:{
            [self.player seekToTime:kCMTimeZero];
            if (!self.autoReplay) {
                [self.player pause];
            }
            break;}
        case VideoPlayerStatusPrepare:{
            [self.player seekToTime:kCMTimeZero];
            break;}
        case VideoPlayerStatusStoped:{
            //暂停
            [self.player pause];
            //移除观察者
            [_item.playerItem cancelPendingSeeks];
            [_item.playerItem.asset cancelLoading];
            _item = nil;
            break;}
            
        default:
            break;
    }
    
    if (_playerStatus != playerStatus) {
        _playerStatus = playerStatus;
        if ([self.delegate respondsToSelector:@selector(manager:playerStatusChanged:)]) {
            [self.delegate manager:self playerStatusChanged:self.playerStatus ];
        }
    }
}


/**
 设置播放项目
 
 @param item item
 */
- (void)setItem:(FZVideoPlayItem *)item {
    _item = item;
    
    __weak typeof(FZVideoManager *)weakSelf = self;
    _item.itemStatusChangedBlock = ^(id objc) {
        AVPlayerItem *playerItem = (AVPlayerItem *)objc;
        
        switch (playerItem.status) {
            case AVPlayerStatusReadyToPlay:{
                // 转换成秒
                weakSelf.totalSecond = playerItem.duration.timescale ? playerItem.duration.value / playerItem.duration.timescale : 0;
                // 获取总时间，并回调
                if ([weakSelf.delegate respondsToSelector:@selector(manager:playItem:totalIntervalChanged:)]) {
                    [weakSelf.delegate manager:weakSelf playItem:weakSelf.item totalIntervalChanged:weakSelf.totalSecond];
                }
                //设置播放状态
                weakSelf.playerStatus = VideoPlayerStatusPlaying;
                [FZVideoPlayItem showDebugMessage:@"开始播放!!!"];
            break;}
            case AVPlayerStatusFailed:{
                //设置播放状态
                weakSelf.playerStatus = VideoPlayerStatusFailed;
                [FZVideoPlayItem showDebugMessage:@"播放失败"];
                break;}
            case AVPlayerStatusUnknown:{
                //设置播放状态
                weakSelf.playerStatus = VideoPlayerStatusUnKown;
                [FZVideoPlayItem showDebugMessage:@"播放状态未知"];
                break;}
            default:
                break;
        }
        
        //获取播放参数
        weakSelf.duration = CMTimeGetSeconds(weakSelf.item.playerItem.asset.duration);
        NSArray *videoArray = [weakSelf.item.playerItem.asset tracksWithMediaType:AVMediaTypeVideo];
        if (videoArray.count > 0) { 
            weakSelf.fps = [[videoArray objectAtIndex:0] nominalFrameRate];
        }
    };
    
    _item.itemBufferUpdateBlock = ^(id objc) {
        
        AVPlayerItem *playerItem = (AVPlayerItem *)objc;
        
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        
        NSLog(@"当前缓冲时间：%f",totalBuffer);
        
        if ([weakSelf.delegate respondsToSelector:@selector(manager:playItem:bufferIntervalChanged:)]) {
            [weakSelf.delegate manager:weakSelf playItem:weakSelf.item bufferIntervalChanged:totalBuffer];
        }
    };
    
    //放置播放源 （如果要切换视频需要调AVPlayer的replaceCurrentItemWithPlayerItem:方法）
    [self.player replaceCurrentItemWithPlayerItem:_item.playerItem];
    
    self.playerStatus = VideoPlayerStatusPlaying;
}


#pragma mark -- 其他状态 -------
/** 刷新时间表 */
- (void) scheduleRefreshControl{
    
    double currentSecond = CMTimeGetSeconds(_item.playerItem.currentTime);
    
    if ([[NSString stringWithFormat:@"%0.0f",currentSecond] integerValue] <= _totalSecond) {
        if ([self.delegate respondsToSelector:@selector(manager:playItem:progressIntervalChanged:)]) {
            [self.delegate manager:self  playItem:self.item progressIntervalChanged:currentSecond];
        }
    }
}



@end
