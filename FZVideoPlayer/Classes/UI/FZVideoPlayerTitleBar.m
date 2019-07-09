//
//  FZVideoPlayerTitleBar.m
//  WFZTest
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import "FZVideoPlayerTitleBar.h"

#import "FZImage.h"

@interface FZVideoPlayerTitleBar ()

@end

@implementation FZVideoPlayerTitleBar

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    [self backButton];
    [self titleLabel];
}





#pragma mark -- Lazy Func ------------

-(UIButton *)backButton{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[FZImage fz_imageNamed:@"left_back_icon_white_60x60"] forState:UIControlStateNormal];
//        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _backButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        self.layoutBackLeft = left;
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:44];
         NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:40];
        
        [self addConstraints:@[left,bottom,width,height]];
        
        
    }
    return _backButton;
}

-(UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual toItem:self.backButton
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1 constant:5];
        
        NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-50];
        NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:40];
        
        [self addConstraints:@[left,bottom,right,height]];
        
        
    }
    return _titleLabel;
}
 
@end
