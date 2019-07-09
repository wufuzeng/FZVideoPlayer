//
//  FZVideoManager.h
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FZVideoPlayItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,VideoPlayerStatus) {
    VideoPlayerStatusPrepare,         //准备播放
    VideoPlayerStatusPlaying,         //正在播放
    VideoPlayerStatusPaused,          //暂停
    VideoPlayerStatusStoped,          //停止
    VideoPlayerStatusFinished,        //完成
    VideoPlayerStatusSeeking,         //正在定位
    VideoPlayerStatusFailed,          //失败
    VideoPlayerStatusUnKown,          //未知
};

@class FZVideoManager;

@protocol FZPlayManagerDelegate <NSObject>

/** 播放状态改变 */
- (void)manager:(FZVideoManager *)manager playerStatusChanged:(VideoPlayerStatus)playerStatus;
/** 总时间改变 */
- (void)manager:(FZVideoManager *)manager playItem:(FZVideoPlayItem *)playItem totalIntervalChanged:(NSTimeInterval)totalInterval;
/** 时间表更新(当前播放位置) */
- (void)manager:(FZVideoManager *)manager playItem:(FZVideoPlayItem *)playItem progressIntervalChanged:(NSTimeInterval)progressInterval;
/** 缓存时间改变 */
- (void)manager:(FZVideoManager *)manager playItem:(FZVideoPlayItem *)playItem bufferIntervalChanged:(NSTimeInterval)bufferInterval;

@end

@interface FZVideoManager : NSObject

@property (nonatomic,weak) id<FZPlayManagerDelegate> delegate;

/** 播放图层 (负责显示视频，如果没有添加该类，只有声音没有画面)*/
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
/** 设置播放源 */
@property (nonatomic,strong) FZVideoPlayItem *item;
/** 播放状态 */
@property (nonatomic,assign) VideoPlayerStatus playerStatus;
/** 进度条正在被拖拽 */
@property (nonatomic,assign) BOOL isSliding;
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;

/** 跳转进度播放
 @param timeinterval  位置
 */
- (void) playWithTimeInterval:(NSTimeInterval)timeinterval;

@end


NS_ASSUME_NONNULL_END
