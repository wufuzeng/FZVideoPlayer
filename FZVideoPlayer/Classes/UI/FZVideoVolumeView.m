//
//  FZVideoVolumeView.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoVolumeView.h"

#import <MediaPlayer/MediaPlayer.h>

@interface FZVideoVolumeView ()

@property (nonatomic,strong) UILabel *valueLabel;

@property (nonatomic,strong) UIProgressView *progressView;

@end

@implementation FZVideoVolumeView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupViews];
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(volumeControlTouch:)]];
        [self addObserver];
    }
    return self;
}

-(void)setupViews{
    [self valueLabel];
    [self progressView];
    self.valueLabel.alpha = self.progressView.alpha = 0;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

#pragma mark -- Notice Func ----------

-(void)addObserver{
    
    /** 改变铃声 的 通知
     
     "AVSystemController_AudioCategoryNotificationParameter" = Ringtone;    // 铃声改变
     "AVSystemController_AudioVolumeChangeReasonNotificationParameter" = ExplicitVolumeChange; // 改变原因
     "AVSystemController_AudioVolumeNotificationParameter" = "0.0625";  // 当前值
     "AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter" = 0; 最小值
     
     
     改变音量的通知
     "AVSystemController_AudioCategoryNotificationParameter" = "Audio/Video"; // 音量改变
     "AVSystemController_AudioVolumeChangeReasonNotificationParameter" = ExplicitVolumeChange; // 改变原因
     "AVSystemController_AudioVolumeNotificationParameter" = "0.3";  // 当前值
     "AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter" = 0; 最小值
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}


-(void)volumeChange:(NSNotification*)notifi{
    NSString * style = [notifi.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    CGFloat value = [[notifi.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] doubleValue];
    if ([style isEqualToString:@"Ringtone"]) {
        NSLog(@"铃声改变");
    }else if ([style isEqualToString:@"Audio/Video"]){
        NSLog(@"音量改变 当前值:%f",value);
        [self showPercentValue:value];
    }
}

#pragma mark -- Gesture Func -----

-(void)volumeControlTouch:(UIPanGestureRecognizer *)sender {
    if (self.touchActionBlock) {
        self.touchActionBlock(sender.state);
    }
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            self.valueLabel.alpha = self.progressView.alpha = 1;
            break;}
        case UIGestureRecognizerStateEnded:{
            self.valueLabel.alpha = self.progressView.alpha = 0;
            break;}
        default:
            break;
    }
    
    
    CGPoint moviePoint = [sender translationInView:self];
    float volume = -moviePoint.y/2000;
    volume += [FZVideoVolumeView getSystemVolumValue];
    if (volume >= 1) {
        volume = 1;
    }else if (volume <= -1) {
        volume = 0;
    }
    
    [FZVideoVolumeView setSysVolumWith:volume];
    
    [self showPercentValue:[FZVideoVolumeView getSystemVolumValue]];
    
}

-(void)showPercentValue:(CGFloat)value {
    self.valueLabel.text = [NSString stringWithFormat:@"%.lf%%",value *100];
    self.progressView.progress = value;
}

/*
 *获取系统音量滑块
 */
+(UISlider*)getSystemVolumSlider{
    static UISlider * volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 4)];
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    return volumeViewSlider;
}

/*
 *获取系统音量大小
 */
+(CGFloat)getSystemVolumValue{
    return [[self getSystemVolumSlider] value];
}
/*
 *设置系统音量大小
 */
+(void)setSysVolumWith:(double)value{
    [self getSystemVolumSlider].value = value;
}


#pragma mark -- Lazy Func ---


#pragma mark -- Lazy Func ---


-(UILabel *)valueLabel{
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:18];
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self.progressView addSubview:_valueLabel];
        
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:60];
        
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_valueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:44];
        [self.progressView addConstraints:@[right,centerY,width,height]];
        
        
    }
    return _valueLabel;
}

-(UIProgressView *)progressView{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc]init];
        _progressView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [_progressView setProgressTintColor:[UIColor whiteColor]];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1 alpha:0.5]];
        
        [self addSubview:_progressView];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.4 constant:0];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:2];
        
        [self addConstraints:@[centerX,centerY,width,height]];
        
        
    }
    return _progressView;
}




@end
