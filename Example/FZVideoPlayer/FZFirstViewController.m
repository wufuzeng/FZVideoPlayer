//
//  FZFirstViewController.m
//  FZVideoPlayer_Example
//
//  Created by 吴福增 on 2019/7/10.
//  Copyright © 2019 wufuzeng. All rights reserved.
//

#import "FZFirstViewController.h"

#import "FZViewController.h"

@interface FZFirstViewController ()

@end

@implementation FZFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    [self.navigationController pushViewController:[FZViewController new] animated:YES];
    
}


@end
