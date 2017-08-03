//
//  SHViewController.m
//  G4Image
//
//  Created by LHY on 2017/4/4.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHViewController.h"

@interface SHViewController ()

@end

@implementation SHViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 程序启动进入对应的界面
    [self viewWillTransitionToSize:self.view.bounds.size withTransitionCoordinator:self.transitionCoordinator];
}



@end
