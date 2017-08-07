//
//  SHSetAirConditionerViewController.h
//  G4Image
//
//  Created by LHY on 2017/8/4.
//  Copyright © 2017年 SmartHome. All rights reserved.
//

#import "SHViewController.h"
#import "SHZoneDetailViewController.h"

@interface SHSetAirConditionerViewController : SHViewController

/// 源控制器
@property (strong, nonatomic) SHZoneDetailViewController *sourceController;

// 显示界面
- (void)show:(SHDeviceButton *)button;


@end
