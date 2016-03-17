# AVPlayer-Demo
AVPlayer播放器Demo
最近在做IOS的播放器功能，要求要自定义的，于是在网上找了下，也借鉴了别人的代码，用AVPlayer做的，不多说，看代码：

参考了文章：http://www.cnblogs.com/kenshincui/p/4186022.html

核心知识点：

        1、AVPlayer和AVPlayerItem，不知道用法看API。

        2、没有网络时要及时注销KVO，不然会崩掉，这里：[self removeObserverFromPlayerItem:self.player.currentItem];
        3、AVPlayerStatus三个状态值：
              AVPlayerStatusUnknown：未知
              AVPlayerStatusReadyToPlay：准备播放
              AVPlayerStatusFailed：播放失败

        4、网络的几个状态：
              playbackBufferEmpty：加载卡顿，正在加载中
              playbackLikelyToKeepUp：可以连续保持播放
              playbackBufferFull：缓冲已满

         5、退出时及时销毁，不然会出现退出了还在播放：
         
              [self.player.currentItem cancelPendingSeeks];
              [self.player.currentItem.asset cancelLoading];
              [self removeNotification];
              [self removeObserverFromPlayerItem:self.player.currentItem];
              [self.player removeTimeObserver:self.playbackObserver];
              
         6、控制器对应的XIB，就一个黑色背景的横屏按钮

         7、调用
              PalyViewController *player = [[PalyViewController alloc] init];
              NSString *urlStr = @"换成你的视屏地址";
              urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
              NSURL *url=[NSURL URLWithString:urlStr];
              player.url = url;
              player.playViewControllerDelegate = self;
              [self presentViewController:player animated:YES completion:NULL];
         
         效果图:
               ![image](https://github.com/ButBueatiful/dotvim/raw/master/screenshots/vim-screenshot.jpg)
