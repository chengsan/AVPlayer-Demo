//
//  FirstViewController.m
//  AVPlayerDemo
//
//  Created by 程三 on 16/3/14.
//  Copyright (c) 2016年 程三. All rights reserved.
//

#import "FirstViewController.h"
#import "PalyViewController.h"


@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.btn1 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn2 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onClick:(UIButton *)button
{
    if(button == self.btn1)
    {
        PalyViewController *player = [[PalyViewController alloc] init];
        player.isFastForward = true;
        NSString *urlStr = @"http://krtv.qiniudn.com/150522nextapp";
         urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr];
        //设置动画
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        [imageArray addObject:@"pic01"];
        [imageArray addObject:@"pic02"];
        [imageArray addObject:@"pic03"];
        [imageArray addObject:@"pic04"];
        [imageArray addObject:@"pic05"];
        [imageArray addObject:@"pic06"];
        [imageArray addObject:@"pic07"];
        player.imageNameArray = imageArray;
        
        player.url = url;
        player.playViewControllerDelegate = self;
        [self presentViewController:player animated:YES completion:NULL];
    }
    else if(button == self.btn2)
    {
        PalyViewController *player = [[PalyViewController alloc] init];
        NSString *urlStr = @"http://krtv.qiniudn.com/150522nextapp";
        urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr];
        player.url = url;
        //设置开始的时间为10秒
        player.seekValeu = 10;
        [self presentViewController:player animated:YES completion:NULL];
    }
}
-(void)playViewControllerStart:(PalyViewController *)playViewController totalLong:(float)totalLong
{
    NSLog(@"playViewControllerStart---------------->");
}
-(void)playViewControllerPlay:(PalyViewController *)playViewController totalLong:(float)totalLong currentLong:(float)currentLong
{
    NSLog(@"playViewControllerPlay---------------->");
}
//返回
-(void)playViewControllerBack:(PalyViewController *)playViewController totalLong:(float)totalLong currentLong:(float)currentLong
{

}
//完成播放
-(void)playViewControllerFinish:(PalyViewController *)playViewController totalLong:(float)totalLong currentLong:(float)currentLong
{
    
}

//Home退出或者熄屏
-(void)playViewControllerWillResignActive
{

}
//重新进入
-(void)playViewControllerDidBecomeActive
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
