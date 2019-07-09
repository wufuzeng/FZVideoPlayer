//
//  FZVideoPlayItem.h
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <Foundation/Foundation.h>
// AVPlayer
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZVideoPlayItem : NSObject

/** 管理资源对象，提供播放数据源 */
@property (nonatomic,strong) AVPlayerItem *playerItem;
/** 状态回调 */
@property (nonatomic,copy) void (^itemStatusChangedBlock)(id objc);
/** 缓存回调 */
@property (nonatomic,copy) void (^itemBufferUpdateBlock)(id objc);
/** 播放路径 */
-(instancetype)initWithURL:(NSURL *)url;



#pragma mark - 工具方法 ----
/**
 获取缓存时间
 @param player 播放器
 @return 已经缓冲的总时间
 */
+ (NSTimeInterval)availableDuration:(AVPlayer *)player;
/**
 显示消息
 @param string 要显示的消息
 */
+ (void) showDebugMessage:(NSString *)string;

@end


NS_ASSUME_NONNULL_END
