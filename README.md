
# 你刚好需要，我刚好出现，请赏一颗小星星.

<p align="center" >

</p>

横屏效果：
<br />
<img src="https://github.com/wufuzeng/FZVideoPlayer/blob/master/Screenshots/example87.png" title="" float=left width = '1000px'>
<br />
竖屏效果：
<br />
<img src="https://github.com/wufuzeng/FZVideoPlayer/blob/master/Screenshots/example88.png" title="" float=left width = '400px'>
 

<p align="center" >
<img src= ”图片路径" title="">
</p>


# FZVideoPlayer
##  特征
- [x]  1.  封装源生 AVPlayer 。
- [x]  2.  支持横竖屏切换。
- [x]  3.  支持亮度调节。
- [x]  4.  支持音量调节。
- [x]  5.  支持进度调节。


[![CI Status](https://img.shields.io/travis/wufuzeng/FZVideoPlayer.svg?style=flat)](https://travis-ci.org/wufuzeng/FZVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/FZVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/FZVideoPlayer)
[![License](https://img.shields.io/cocoapods/l/FZVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/FZVideoPlayer)
[![Platform](https://img.shields.io/cocoapods/p/FZVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/FZVideoPlayer)

## 例

要运行示例项目，请克隆repo，然后从Example目录运行 ”pod install“。

## 要求


## 安装

FZVideoPlayer 可通过[CocoaPods](https://cocoapods.org)获得. 要安装它，只需将以下行添加到Podfile文件

```ruby
pod 'FZVideoPlayer'
```

## 怎样使用

* Objective-C

```objective-c

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Test"  ofType:@"mov"]];
    self.player.title = @"屌丝男士";
    [self.player playWithUrl:url];
}

-(void)viewDidAppear:(BOOL)animated{
        [super viewDidAppear:animated];
        [self.player play];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player stop]; 
}

-(FZVideoPlayer *)player{
if (_player == nil) {
    _player = [[FZVideoPlayer alloc]initWithFrame:CGRectMake(0, 200, [UIScreen  mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    self.player.showControlView = YES;
    self.player.showTitleBar = YES;
    self.player.showBackBtn = NO;
    self.player.autoReplay = YES;
    self.player.disableFullScreen = NO;
    self.player.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.player.showInView = self.view;
}
return _player;
}

```

* Swift

```swift

//swif代码

```


## 作者

wufuzeng, wufuzeng_lucky@sina.com
### 纵有疾风起，人生不言弃

## 许可证

FZVideoPlayer is available under the MIT license. See the LICENSE file for more info.
