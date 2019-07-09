//
//  FZVideoPlayerBundle.m
//  FZVideoPlayer
//
//  Created by 吴福增 on 2019/7/9.
//

#import "FZVideoPlayerBundle.h"

@implementation FZVideoPlayerBundle

+ (UIImage *)zlc_imageNamed:(NSString *)name ofType:(nullable NSString *)type {
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"ZhuanResourcesBundle.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if (bundle == nil) {
        bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"Frameworks/ZhuanResources.framework/ZhuanResourcesBundle.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:type]];
    }
}
 
+ (NSBundle *)fz_bundle{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSString *resourcesBundleName = currentBundle.infoDictionary[@"CFBundleName"];
        NSLog(@"---->1.%@",currentBundle);
        NSLog(@"---->2.%@",resourcesBundleName);
        bundle = [NSBundle bundleWithPath:[currentBundle pathForResource:resourcesBundleName ofType:@"bundle"]];
        if (bundle == nil) {
            NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
            NSLog(@"---->3.%@",mainBundlePath);
            NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"FZVideoPlayer.bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
    }
    return bundle;
}

+ (UIImage *)fz_imageNamed:(NSString *)name{
    if (name == nil) {
        return nil;
    }
   UIImage *image = [[UIImage imageWithContentsOfFile:[[self fz_bundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return image;
}

+ (NSString *)fz_localizedStringForKey:(NSString *)key{
    return [self fz_localizedStringForKey:key value:nil];
}

+ (NSString *)fz_localizedStringForKey:(NSString *)key value:(NSString *)value{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
        NSString *language = [NSLocale preferredLanguages].firstObject;
        
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else if ([language hasPrefix:@"ko"]) {
            language = @"ko";
        } else if ([language hasPrefix:@"ru"]) {
            language = @"ru";
        } else if ([language hasPrefix:@"uk"]) {
            language = @"uk";
        } else {
            language = @"en";
        }
        
        // 从MJRefresh.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[self fz_bundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
