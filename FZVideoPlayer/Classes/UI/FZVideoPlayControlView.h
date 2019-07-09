//
//  FZVideoPlayControlView.h
//  WFZTest
//
//  Created by 吴福增 on 2019/1/8.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FZVideoManager.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,VideoPlayerStyle) {
    VideoPlayerStyleNormal = 0,//正常
    VideoPlayerStyleFullScreenLeft,//全屏
    VideoPlayerStyleFullScreenRight,//全屏
};

@class FZVideoPlayControlView;

@protocol FZPlayControlDelegate <NSObject>
/** 播放状态改变 */
- (void)control:(FZVideoPlayControlView *)control playerStatusChanged:(VideoPlayerStatus)playerStatus ;
/** 视图状态改变*/
- (void)control:(FZVideoPlayControlView *)control playerStyleChanged:(VideoPlayerStyle)playerStyle ;
@optional
/** 缓存改变 */
- (void)control:(FZVideoPlayControlView *)control bufferChanged:(NSTimeInterval)timeInterval;
/** 进度条改变 */
- (void)control:(FZVideoPlayControlView *)control progressChanged:(NSTimeInterval)timeInterval;
/** 滑块正在滑动 */
- (void)control:(FZVideoPlayControlView *)control sliderChanged:(BOOL)isSliding;
/** 点击返回按钮 */
- (void)control:(FZVideoPlayControlView *)control didClickedWithBackButton:(UIButton *)button;

@end

@interface FZVideoPlayControlView : UIView

@property (nonatomic,weak) id <FZPlayControlDelegate> delegate;

@property (nonatomic,strong) NSString *title;
 
/** 自动重新播放 */
@property (nonatomic,assign) BOOL autoReplay;
/** 显示标题栏 */
@property (nonatomic,assign) BOOL showTitleBar;
@property (nonatomic,assign) BOOL showBackBtn;
/** 禁止全屏 */
@property (nonatomic,assign) BOOL disableFullScreen;

@property (nonatomic,assign) VideoPlayerStatus playerStatus;
@property (nonatomic,assign) VideoPlayerStyle  playerStyle;



/** 总时间 */
@property (nonatomic,assign) NSTimeInterval totalInterval;
/** 缓存时间 */
@property (nonatomic,assign) NSTimeInterval bufferInterval;
/** 进度时间 */
@property (nonatomic,assign) NSTimeInterval progressInterval;

@end


NS_ASSUME_NONNULL_END
