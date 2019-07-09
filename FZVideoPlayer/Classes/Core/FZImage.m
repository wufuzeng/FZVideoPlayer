//
//  FZImage.m
//  FZVideoPlayer
//
//  Created by 吴福增 on 2019/7/8.
//

#import "FZImage.h"

@implementation FZImage


+(UIImage *)fz_imageNamed:(NSString *)name{
    if (name == nil) {
        return nil;
    }
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *resourcesBundleName = currentBundle.infoDictionary[@"CFBundleName"];
    NSString *resourcesBundle = [NSString stringWithFormat:@"%@.bundle",resourcesBundleName];
    
    
    NSString * imagePathFramework = [NSString stringWithFormat:@"%@/%@",resourcesBundle,name];
    UIImage *imageFramework = [UIImage imageNamed:imagePathFramework];
    if (imageFramework) {
        return imageFramework;
    }
    
    NSString *(^block)(NSString *fileName) = ^(NSString *fileName){
        return [currentBundle pathForResource:fileName ofType:@".png" inDirectory:resourcesBundle];
    };
    NSString *image3xPath = block([name stringByAppendingString:@"@3x"]);
    NSString *image2xPath = block([name stringByAppendingString:@"@2x"]);
    NSString *image1xPath = block(name);
    NSString *imagePath = nil;
    // 判断屏幕类型，普通还是视网膜
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale == 3) {//Plus视网膜屏幕
        if (image3xPath) {
            imagePath = image3xPath;
        }else if (image2xPath){
            imagePath = image2xPath;
        }else{
            imagePath = image1xPath;
        }
    }else if (scale == 2) {//视网膜屏幕
        if (image2xPath){
            imagePath = image2xPath;
        }else{
            imagePath = image1xPath;
        }
    }else {//普通屏幕
        imagePath = image1xPath;
    }
    // 获取图片
    return [UIImage imageWithContentsOfFile:imagePath];
}


@end
