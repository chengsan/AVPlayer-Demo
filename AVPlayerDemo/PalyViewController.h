//
//  PalyViewController.h
//  AVPlayerDemo
//
//  Created by 程三 on 16/3/14.
//  Copyright (c) 2016年 程三. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <notify.h>

@class PalyViewController;
@protocol PlayViewControllerDelegate <NSObject>

@optional

//开始播放
-(void)playViewControllerStart:(PalyViewController *)playViewController totalLong:(float)totalLong;
//正在播放
-(void)playViewControllerPlay:(PalyViewController *)playViewController totalLong:(float)totalLong currentLong:(float)currentLong;
//返回
-(void)playViewControllerBack:(PalyViewController *)playViewController totalLong:(float)totalLong currentLong:(float)currentLong;
//完成播放
-(void)playViewControllerFinish:(PalyViewController *)playViewController totalLong:(float)totalLong currentLong:(float)currentLong;
@end

@interface PalyViewController : UIViewController
{
    //总长度
    float totalLong;
    //当前播放的长度
    float currentLong;
}
//代理
@property(assign,nonatomic)id<PlayViewControllerDelegate> playViewControllerDelegate;

//容器View
@property (weak, nonatomic) IBOutlet UIButton *playView;
//播放器对象
@property(nonatomic,strong) AVPlayer *player;
//暂停播放按钮
@property (retain, nonatomic) UIButton *playOrPause;
//屏幕中间的播放暂停按钮
@property (retain, nonatomic) UIButton *playOrPause2;
//返回按钮
@property(retain,nonatomic)UIButton *backBtn;
//标题控件
@property (retain,nonatomic)UILabel *titleLabel;
//标题内容
@property (copy,nonatomic)NSString *titleStr;
//进度条
@property (strong, nonatomic) UISlider *progress;
//设置标题
@property (retain, nonatomic)UIView *titleView;
//底部菜单控制View
@property (retain, nonatomic)UIView *controllerView;
//时间
@property (retain,nonatomic)UILabel *timeShowLabel;
//播放状态
@property (assign,nonatomic)BOOL isPlaying;
//提示控件
@property (retain,nonatomic)UIActivityIndicatorView *activityView;
//播放观察者对象
@property (retain,nonatomic)id playbackObserver;
//设置播放进度
@property (assign,nonatomic)float seekValeu;
//设置是否可以快进
@property (assign,nonatomic)BOOL isFastForward;
//NSURL
@property (retain,nonatomic)NSURL *url;
//提示
@property (retain,nonatomic)UILabel *noticeLabel;
//动画加载提示,兼容保宝的需求
@property (retain,nonatomic)UIImageView *loadImageView;
//动画图片名称数组
@property (retain,nonatomic)NSArray *imageNameArray;

@end
