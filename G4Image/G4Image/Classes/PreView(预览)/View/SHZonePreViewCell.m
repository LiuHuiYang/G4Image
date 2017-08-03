//
//  SHZonePreViewCell.m
//  G4Image
//
//  Created by LHY on 2017/4/4.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHZonePreViewCell.h"

@interface SHZonePreViewCell()

/// 图片
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

/// 描述文字
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation SHZonePreViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModelZone:(SHZone *)modelZone {
    
    _modelZone = modelZone;
    
    self.iconView.image = [SHUtility getImageForZones:modelZone.zoneID];
    
    // 设置圆角
    self.iconView.layer.cornerRadius = 10;
    self.iconView.clipsToBounds = YES;
    
    self.descLabel.text = modelZone.zoneName;
}

@end
