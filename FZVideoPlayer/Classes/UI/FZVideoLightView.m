//
//  FZVideoLightView.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoLightView.h"


@interface FZVideoLightView ()

@property (nonatomic,strong) UILabel *valueLabel;

@property (nonatomic,strong) UIProgressView *progressView;

@end
@implementation FZVideoLightView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(lightControlTouch:)]];
        
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    
    [self valueLabel];
    [self progressView];
    self.valueLabel.alpha = self.progressView.alpha = 0;
    
    
}


#pragma mark -- Gesture Func -----

-(void)lightControlTouch:(UIPanGestureRecognizer *)sender{
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
    float screenBrightNess = -moviePoint.y/2000;
    screenBrightNess += [FZVideoLightView getScreenBrightness];
    if (screenBrightNess >= 1) {
        screenBrightNess = 1;
    } else if (screenBrightNess <= -1) {
        screenBrightNess = 0;
    }
    
    //设置屏幕亮度
    [FZVideoLightView setScreenBrightness:screenBrightNess];
    //设置百分比
    [self showPercentValue:[FZVideoLightView getScreenBrightness]];
    
}
-(void)showPercentValue:(CGFloat)value {
    self.valueLabel.text = [NSString stringWithFormat:@"%.lf%%",value *100];
    
    self.progressView.progress = value;
    
}

/**
 设置系统屏幕亮度
 
 @param brightness 屏幕亮度
 */
+(void)setScreenBrightness:(CGFloat)brightness {
    [[UIScreen mainScreen] setBrightness:brightness];
}
/**
 获取屏幕亮度
 
 @return 返回屏幕亮度
 */
+(float)getScreenBrightness {
    return [UIScreen mainScreen].brightness;
}


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
        _progressView.progress = [FZVideoLightView getScreenBrightness];
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
