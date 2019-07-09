//
//  FZVideoPlayerTitleBar.h
//  WFZTest
//
//  Created by 吴福增 on 2019/1/5.
//  Copyright © 2019 吴福增. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZVideoPlayerTitleBar : UIView
@property (nonatomic,strong) NSLayoutConstraint* layoutBackLeft;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UILabel *titleLabel;
@end

NS_ASSUME_NONNULL_END
