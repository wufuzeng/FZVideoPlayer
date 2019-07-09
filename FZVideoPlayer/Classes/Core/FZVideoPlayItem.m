//
//  FZVideoPlayItem.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoPlayItem.h"

@implementation FZVideoPlayItem

#pragma mark -- 初始化方法 ----------

-(instancetype)initWithURL:(NSURL *)url{
    if(self = [super init]){
        
        _playerItem = [[AVPlayerItem alloc] initWithURL:url];
        
        if (_playerItem) {
            [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            //获取视频的缓存情况我们需要监听playerItem的loadedTimeRanges属性
            [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            //监听playbackBufferEmpty我们可以获取当缓存不够，视频加载不出来的情况：
            [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
            //playbackLikelyToKeepUp和playbackBufferEmpty是一对，用于监听缓存足够播放的状态
            [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    return self;
}

-(void)dealloc{
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
} 

/**
 添加播放项目
 
 @param url URL链接
 */
- (void) addItemWihtURL:(NSURL *)url{
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    if (_playerItem) {
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //获取视频的缓存情况我们需要监听playerItem的loadedTimeRanges属性
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        //监听playbackBufferEmpty我们可以获取当缓存不够，视频加载不出来的情况：
        [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        //playbackLikelyToKeepUp和playbackBufferEmpty是一对，用于监听缓存足够播放的状态
        [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark -- NSKeyValueObserving ------

/**
 观察者模式 观察item的值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if (_itemStatusChangedBlock) {
            _itemStatusChangedBlock(playerItem);
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if (_itemBufferUpdateBlock){
            _itemBufferUpdateBlock(playerItem);
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        //[player play];
    }
}




#pragma mark -- 工具方法 ------
/**
 获取缓存时间
 
 @param player 播放器
 @return 已经缓冲的总时间
 */
+ (NSTimeInterval)availableDuration:(AVPlayer *)player{
    
    NSArray *loadedTimeRanges = [[player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}



/**
 显示消息
 
 @param string 要显示的消息
 */
+ (void) showDebugMessage:(NSString *)string{
#ifdef DEBUG
    NSLog(@"%@",string);
#endif
}



@end
