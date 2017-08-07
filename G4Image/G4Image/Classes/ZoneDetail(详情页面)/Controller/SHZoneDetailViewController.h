//
//  SHZoneDetailViewController.h
//  G4Image
//
//  Created by LHY on 2017/4/4.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHViewController.h"
#import "SHZone.h"

@interface SHZoneDetailViewController : SHViewController <SHUdpSocketDelegate>

/// 区域模型
@property (strong, nonatomic) SHZone *zone;

/// 是否为新增的场景区域
@property (nonatomic, assign) BOOL isNew;

@end
