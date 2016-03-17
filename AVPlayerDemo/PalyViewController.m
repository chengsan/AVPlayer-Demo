//
//  PalyViewController.m
//  AVPlayerDemo
//
//  Created by 程三 on 16/3/14.
//  Copyright (c) 2016年 程三. All rights reserved.
//

#import "PalyViewController.h"

#define NotificationLock CFSTR("com.apple.springboard.lockcomplete")

#define NotificationChange CFSTR("com.apple.springboard.lockstate")

#define NotificationPwdUI CFSTR("com.apple.springboard.hasBlankedScreen")

@interface PalyViewController ()


@end

@implementation PalyViewController

-(id)init
{
    self = [super init];
    if(self)
    {
        self.seekValeu = 0;
        self.isFastForward = false;
        self.titleStr = @"返回";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    if(self.seekValeu > 0)
    {
        if(nil != self.player)
        {
            [self.player seekToTime:CMTimeMake(self.seekValeu * 10000, 10000)];
        }
        //设置UI
        if(self.progress != nil)
        {
            [self.progress setValue:_seekValeu animated:YES];
        }
    }
    [self.player play];
    self.isPlaying = true;
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(dissMenuView) userInfo:nil repeats:YES];
    
    //添加播放完成通知
    [self addNotification];
    
    //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    //监听是否重新进入程序程序.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //添加锁屏监听
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationLock, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
//    
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationChange, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

//static void screenLockStateChanged(CFNotificationCenterRef center,void* observer,CFStringRef name,const void* object,CFDictionaryRef userInfo)
//
//{
//    
//    NSString* lockstate = (__bridge NSString*)name;
//    
//    if ([lockstate isEqualToString:(__bridge  NSString*)NotificationLock]) {
//        
//        NSLog(@"屏幕锁定.");
//        
//    } else {
//        
//        NSLog(@"屏幕锁定状态改变.");
//        
//    }
//    
//}

- (void)applicationWillResignActive:(NSNotification *)notification

{
    //NSLog(@"按理说是触发home按下");
    //正在播放
    [self.player pause];
    [self.playOrPause setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
    if(nil != self.playOrPause2)
    {
        [self.playOrPause2 setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
    }
}

//- (void)applicationDidBecomeActive:(NSNotification *)notification
//{
//    printf("按理说是重新进来后响应\n");
//}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark 初始化播放器
-(void)setUrl:(NSURL *)url
{
    _url = url;
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    if (!_player)
    {
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
}


#pragma mark 私有方法
-(void)initView
{
    float UIScreenWidth = [UIScreen mainScreen].bounds.size.height;
    float UIScreenHeight = [UIScreen mainScreen].bounds.size.width;
    
    //创建播放器层
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    //视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playView.layer addSublayer:playerLayer];
    
    
    
    int viewHeight = 46;
    int btnWidth = 36;
    int otherWidth = 6;
    
    //设置标题
    self.titleView = [[UIView alloc] init];
    self.titleView.frame = CGRectMake(0, 0, UIScreenWidth, viewHeight);
    self.titleView.backgroundColor =[UIColor grayColor];
    [self.playView addSubview:self.titleView];
    
    //返回按钮
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(otherWidth, (viewHeight-btnWidth)/2, btnWidth, btnWidth);
    [self.backBtn setBackgroundImage:[UIImage imageNamed:@"back_btn"] forState:UIControlStateNormal];
    [self.titleView addSubview:self.backBtn];
    
    //标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake(self.backBtn.frame.size.width + otherWidth * 2, (viewHeight-btnWidth)/2, UIScreenWidth - btnWidth - otherWidth * 2-self.backBtn.frame.size.width + otherWidth * 2, btnWidth);
    self.titleLabel.text = self.titleStr;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.titleView addSubview:self.titleLabel];
    
    //中间播放暂停按钮
    /*
    self.playOrPause2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPause2.frame = CGRectMake(0, 0, btnWidth, btnWidth);
    self.playOrPause2.center = CGPointMake(UIScreenWidth/2, UIScreenHeight/2);
    [self.playOrPause2 setBackgroundImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
    [self.playView addSubview:self.playOrPause2];
    */
    
    //判断是非有设置动画，没有就使用默认的
    if(self.imageNameArray != nil && self.imageNameArray.count > 0)
    {
        self.loadImageView = [[UIImageView alloc] init];
        [self.playView addSubview:self.loadImageView];
        
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.imageNameArray.count; i++)
        {
            if(nil != [self.imageNameArray objectAtIndex:i])
            {
                UIImage *tempImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[self.imageNameArray objectAtIndex:i]]];
                if(nil != tempImage)
                {
                    if(i == 0)
                    {
                        self.loadImageView.frame = CGRectMake(0, 0, tempImage.size.width, tempImage.size.height);
                        self.loadImageView.image = tempImage;
                    }
                    [imgs addObject:tempImage];
                }
                
                tempImage = nil;
            }
        }
        
        self.loadImageView.center = CGPointMake(UIScreenWidth/2, UIScreenHeight/2);
        self.loadImageView.animationImages = imgs;
        self.loadImageView.animationDuration = 0.8;
        [self.loadImageView startAnimating];
    }
    else
    {
        //缓冲提示框
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.frame = CGRectMake(0, 0, btnWidth, btnWidth);
        self.activityView.center = CGPointMake(UIScreenWidth/2, UIScreenHeight/2);
        [self.activityView startAnimating];
        [self.playView addSubview:self.activityView];
    }
    
    //提示
    self.noticeLabel = [[UILabel alloc] init];
    self.noticeLabel.textAlignment = NSTextAlignmentCenter;
    self.noticeLabel.frame = CGRectMake(0, 0, 300, btnWidth);
    self.noticeLabel.center = CGPointMake(UIScreenWidth/2, UIScreenHeight/2);
    self.noticeLabel.text = @"视频链接或者网络有问题";
    self.noticeLabel.font = [UIFont systemFontOfSize:13];
    self.noticeLabel.backgroundColor = [UIColor clearColor];
    self.noticeLabel.textColor = [UIColor whiteColor];
    self.noticeLabel.hidden = YES;
    [self.playView addSubview:self.noticeLabel];
    
    
    
    //控制器视图
    self.controllerView = [[UIView alloc] init];
    self.controllerView.frame = CGRectMake(0, UIScreenHeight-46, UIScreenWidth, viewHeight);
    self.controllerView.backgroundColor = [UIColor grayColor];
    [self.playView addSubview:self.controllerView];
    
    //底部暂停播放按钮
    self.playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playOrPause setBackgroundImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
    self.playOrPause.frame = CGRectMake(otherWidth, (viewHeight - btnWidth)/2, btnWidth, btnWidth);
    [self.controllerView addSubview:self.playOrPause];
    
    //进度条
    self.progress = [[UISlider alloc] init];
    self.progress.enabled = self.isFastForward;
    self.progress.minimumValue = 0;
    self.progress.maximumValue = 100;
    self.progress.value = 0;
    //这个属性设置为YES则在滑动时，其value就会随时变化，设置为NO，则当滑动结束时，value才会改变。
    self.progress.continuous = NO;
    self.progress.frame = CGRectMake(self.playOrPause.frame.size.width + otherWidth *2, (viewHeight - btnWidth)/2, self.controllerView.frame.size.width - otherWidth * 2 - 130 - self.playOrPause.frame.size.width + otherWidth *2
                                     , btnWidth);
    [self.controllerView addSubview:self.progress];
    
    //时间显示
    self.timeShowLabel = [[UILabel alloc] init];
    self.timeShowLabel.frame = CGRectMake(self.progress.frame.size.width + self.progress.frame.origin.x + otherWidth, (viewHeight - btnWidth)/2, 130, btnWidth);
    self.timeShowLabel.font = [UIFont systemFontOfSize:13];
    self.timeShowLabel.text = @"00:00:00/00:00:00";
    [self.controllerView addSubview:self.timeShowLabel];
    
    //添加事件
    [self.backBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    if(nil != self.playOrPause2)
    {
        [self.playOrPause2 addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.playView addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.progress addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark 事件回调方法
-(void)onClick:(UIButton *)btn
{
    if(btn == self.backBtn)
    {
        if(self.playViewControllerDelegate != nil)
        {
            [self.playViewControllerDelegate playViewControllerBack:self totalLong:totalLong currentLong:currentLong];
        }
        
        [self exitViewController];
    }
    else
    {
        if(self.titleView.hidden)
        {
            self.titleView.hidden = NO;
            self.controllerView.hidden = NO;
            if(nil != self.playOrPause2)
            {
                self.playOrPause2.hidden = NO;
            }
        }
        else
        {
            self.titleView.hidden = YES;
            self.controllerView.hidden = YES;
            if(nil != self.playOrPause2)
            {
                self.playOrPause2.hidden = YES;
            }

        }
    }
}

#pragma mark 退出销毁接口和通知
-(void)exitViewController
{
    //正在播放
    [self.player pause];
    
    [self.playOrPause setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
    if(nil != self.playOrPause2)
    {
        [self.playOrPause2 setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
    }
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self.player removeTimeObserver:self.playbackObserver];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark 隐藏菜单和控制栏
-(void)dissMenuView
{
    //隐藏控制UI
    if(!self.controllerView.hidden)
    {
        self.titleView.hidden = YES;
        self.controllerView.hidden = YES;
        self.playOrPause2.hidden = YES;
    }
}

#pragma mark 进度条滑动回调函数
-(void)updateValue:(UISlider *)sender
{
    __block PalyViewController *block = self;
    NSLog(@"updateValue重新定位到：%.2f",sender.value);
    [self.player seekToTime:CMTimeMake(sender.value * 10000 , 10000) completionHandler:^(BOOL finished) {

        NSLog(@"定位完成，开始播放");
        [block.playOrPause setImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
        [block.playOrPause2 setImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
        [block.player play];
        block.isPlaying = true;
    }];
}

#pragma mark 根据视频索引取得AVPlayerItem对象
//-(AVPlayerItem *)getPlayItem
//{
//    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
////    NSString *urlStr = @"http://download.yxybb.com/bbvideo/web/d1/d20/d20/f3-web.mp4";
////    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////    NSURL *url=[NSURL URLWithString:urlStr];
//    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:self.url];
//    return playerItem;
//}

#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 播放完成通知
-(void)playbackFinished:(NSNotification *)notification
{
    NSLog(@"视频播放完成.");
    if(self.playViewControllerDelegate != nil)
    {
        [self.playViewControllerDelegate playViewControllerFinish:self totalLong:totalLong currentLong:currentLong];
    }
    
    [self exitViewController];
}

#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    __block PalyViewController *BlockSelf = self;
    //AVPlayerItem *playerItem=self.player.currentItem;
    //UISlider *slider = self.progress;
    //UIProgressView *progress=self.progress;
    //这里设置每秒执行一次
    self.playbackObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([BlockSelf.player.currentItem duration]);
        
        if (current)
        {
            //NSLog(@"当前已经播放%.2fs.",current);
            if(nil != BlockSelf.activityView)
            {
                BlockSelf.activityView.hidden = YES;
                [BlockSelf.activityView stopAnimating];
            }
            
            if(nil != BlockSelf.loadImageView)
            {
                [BlockSelf.loadImageView stopAnimating];
                BlockSelf.loadImageView.hidden = YES;
            }
            
            //[progress setProgress:(current/total) animated:YES];
            //[slider setMaximumValue:total];
            BlockSelf.timeShowLabel.text = [NSString stringWithFormat:@"%@/%@",[BlockSelf TimeformatFromSeconds:(int)current],[BlockSelf TimeformatFromSeconds:(int)total]];
            [BlockSelf.progress setValue:current animated:YES];
            
            //NSLog(@"当前已经播放current = %.2fs,current(int) = %.2fs",current,((float)((int)current)));
            //为了保证每秒回调一次，这里做整数判断
            if([[NSString stringWithFormat:@"%.2f",current] isEqualToString:[NSString stringWithFormat:@"%.2f",((float)((int)current))]])
            {
                if(nil != self.playViewControllerDelegate)
                {
                    [BlockSelf.playViewControllerDelegate playViewControllerPlay:BlockSelf totalLong:total currentLong:current];
                }

            }
            totalLong = total;
            currentLong = current;
        }
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem
{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    
    if (!self.player)
    {
        return;
    }
    else if (object == playerItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (playerItem.playbackBufferEmpty)
        {
            if(nil != self.activityView)
            {
                self.activityView.hidden = NO;
                [self.activityView startAnimating];
            }
            
            if(nil != self.loadImageView)
            {
                self.loadImageView.hidden = NO;
                [self.loadImageView startAnimating];
            }
            
            //NSLog(@"===========>playbackBufferEmpty");
        }
    }
    else if (object == playerItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (playerItem.playbackLikelyToKeepUp)
        {
            //NSLog(@"===========>playbackLikelyToKeepUp");
            if(nil != self.activityView)
            {
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
            }
            
            if(nil != self.loadImageView)
            {
                self.loadImageView.hidden = YES;
                [self.loadImageView stopAnimating];
            }
            
            if(self.isPlaying)
            {
                [self.player play];
            }
        }
    }
    else if (object == playerItem && [keyPath isEqualToString:@"playbackBufferFull"])
    {
        if (playerItem.playbackLikelyToKeepUp)
        {
            //NSLog(@"===========>playbackBufferFull");
        }
    }

    
    
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay)
        {
            //NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            self.progress.maximumValue = CMTimeGetSeconds(playerItem.duration);
            self.timeShowLabel.text = [NSString stringWithFormat:@"00:00/%@",[self TimeformatFromSeconds:(int)(CMTimeGetSeconds(playerItem.duration))]];
            
            if(nil != self.activityView)
            {
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
            }
            
            if(nil != self.loadImageView)
            {
                self.loadImageView.hidden = YES;
                [self.loadImageView stopAnimating];
            }
            
            if(self.playViewControllerDelegate != nil)
            {
                [self.playViewControllerDelegate playViewControllerStart:self totalLong:CMTimeGetSeconds(playerItem.duration)];
            }
            
            totalLong = CMTimeGetSeconds(playerItem.duration);
        }
        else if(status == AVPlayerStatusUnknown || status == AVPlayerStatusFailed)
        {
            [self removeObserverFromPlayerItem:self.player.currentItem];
            //NSLog(@"视频链接或者网络有问题");
            
            if(nil != self.activityView)
            {
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
            }
            
            if(nil != self.loadImageView)
            {
                self.loadImageView.hidden = YES;
                [self.loadImageView stopAnimating];
            }
            
            self.noticeLabel.hidden = NO;
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度

        //NSLog(@"共缓冲：%.2f",totalBuffer);
        if(totalBuffer - currentLong > 5)
        {
            if(nil != self.activityView)
            {
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
            }
            
            if(nil != self.loadImageView)
            {
                self.loadImageView.hidden = YES;
                [self.loadImageView stopAnimating];
            }
            
            if(nil != self.player)
            {
                [self.player play];
            }
        }
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (void)playClick:(UIButton *)sender
{
    //AVPlayerItemDidPlayToEndTimeNotification
    //AVPlayerItem *playerItem= self.player.currentItem;
    if(self.isPlaying)
    {
        [self.player pause];
        [self.playOrPause setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
        [self.playOrPause2 setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
    }
    else
    {        
        //说明时暂停
        [self.playOrPause setImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
        [self.playOrPause2 setImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
        [self.player play];
    }
    
    self.isPlaying = !self.isPlaying;
    
    /*
    if(self.player.rate==0)
    {
        //说明时暂停
        [self.playOrPause setImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
        [self.playOrPause2 setImage:[UIImage imageNamed:@"start_btn"] forState:UIControlStateNormal];
        [self.player play];
        //[self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
    }
    else if(self.player.rate==1)
    {
        //正在播放
        [self.player pause];
        [self.playOrPause setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
        [self.playOrPause2 setImage:[UIImage imageNamed:@"stop_btn"] forState:UIControlStateNormal];
        //[self.playOrPause setTitle:@"播放" forState:UIControlStateNormal];
    }
     */
}

/**
 *  切换选集，这里使用按钮的tag代表视频名称
 *
 *  @param sender 点击按钮对象
 */
//- (void)navigationButtonClick:(UIButton *)sender {
//    [self removeNotification];
//    [self removeObserverFromPlayerItem:self.player.currentItem];
//    AVPlayerItem *playerItem=[self getPlayItem:sender.tag];
//    [self addObserverToPlayerItem:playerItem];
//    //切换视频
//    [self.player replaceCurrentItemWithPlayerItem:playerItem];
//    [self addNotification];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

@end
