//
//  FZVideoPlayer.h
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FZVideoPlayControlView.h"



NS_ASSUME_NONNULL_BEGIN 
/**
 在iOS平台使用播放视频，可用的选项一般有这四个，他们各自的作用和功能如下：
 
 视频播放类                  使用环境                优点                   缺点          支持以下格式
 MPMoviePlayerController    MediaPlayer         简单易用                 不可定制
 AVPlayerViewController     AVKit               简单易用                 不可定制      .mov、.mp4、.mpv、.3gp。
 AVPlayer                   AVFoundation        可定制度高，功能强大       不支持流媒体
 IJKPlayer                  IJKMediaFramework   定制度高，支持流媒体播放    使用稍复杂
 
 由此可以看出，如果我们不做直播功能AVPlayer就是一个最优的选择。
 
 AVPlayer：控制播放器的播放，暂停，播放速度
 AVURLAsset : AVAsset 的一个子类，使用 URL 进行实例化，实例化对象包换 URL 对应视频资源的所有信息。
 AVPlayerItem：管理资源对象，提供播放数据源
 AVPlayerLayer：负责显示视频，如果没有添加该类，只有声音没有画面
 
 */

@class FZVideoPlayer;

@protocol  FZPlayerDelegate <NSObject>

//播放器播放状态
- (void)player:(FZVideoPlayer *)player playerStatusChanged:(VideoPlayerStatus)playState;
//播放器视图改变
- (void)player:(FZVideoPlayer *)player playerStyleChanged:(VideoPlayerStyle)playerStyle;
//返回按钮点击
- (void)player:(FZVideoPlayer *)plyer didClickedWithBackButton:(UIButton *)button;

@end


@interface FZVideoPlayer : UIView
<
FZPlayControlDelegate,
FZPlayManagerDelegate
>
/** 代理 */
@property (nonatomic,weak) id<FZPlayerDelegate> delegate;

/** 要显示的view (nil 则是显示在window上) */
@property (nonatomic,strong) UIView *showInView;
/** 视频拉伸模式 */
@property (nonatomic,assign) AVLayerVideoGravity videoGravity;
/** 播放视频的标题 */
@property (nonatomic,copy) NSString *title;
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;
/** 显示控制图层 */
@property (nonatomic,assign) BOOL showControlView;
/** 显示标题栏 */
@property (nonatomic,assign) BOOL showTitleBar;
/** 显示返回按钮 */
@property (nonatomic,assign) BOOL showBackBtn;
/** 禁止全屏 */
@property (nonatomic,assign) BOOL disableFullScreen;

/**
 播放url地址
 @param url url地址
 */
- (void) playWithUrl:(NSURL *)url;

- (void) play;
- (void) pause;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
