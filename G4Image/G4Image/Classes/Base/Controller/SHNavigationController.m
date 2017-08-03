//
//  SHNavigationController.m
//  G4Image
//
//  Created by LHY on 2017/4/4.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHNavigationController.h"

/**
 注意：这不是一个真正的协议，只是为了防止系统报警告
 */
@protocol recognizerDelegate <NSObject>

@optional

- (void)handleNavigationTransition:(UIGestureRecognizer *)recognizer;

@end


@interface SHNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation SHNavigationController

/// 设置字体
+ (void)load {

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // 滑动返回
//    // 创建手势
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
//    
//    pan.delegate = self;
//    
//    [self.view addGestureRecognizer:pan];
//    
//    // 禁用系统的
//    self.interactivePopGestureRecognizer.enabled = NO;
//}
//
//#pragma mark - 手势代理
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
//    return self.childViewControllers.count > 1; // 不是栈顶控制器才有效
//}

#pragma mark - 手机不横屏

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return [super supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
