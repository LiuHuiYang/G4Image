//
//  SHSettingViewController.h
//  G4Image
//
//  Created by LHY on 2017/4/6.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHZoneDetailViewController.h"

@interface SHSettingViewController : SHViewController


/// 设置按钮
@property (strong,nonatomic)SHDeviceButton *settingButton;

/// 来源控制器
@property (nonatomic, strong) SHZoneDetailViewController *sourceViewController;

@end
