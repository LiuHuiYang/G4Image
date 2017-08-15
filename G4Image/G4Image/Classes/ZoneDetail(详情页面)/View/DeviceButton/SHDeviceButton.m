//
//  SHDeviceButton.m
//  TouchTest
//
//  Created by Firas on 12/11/13.
//  Copyright (c) 2013 SH. All rights reserved.
//

#import "SHDeviceButton.h"

#define SHDeviceButtonMaign (5)

@interface SHDeviceButton ()

/// 图片名称
@property (strong, nonatomic) NSMutableArray *imageNames;

@end

@implementation SHDeviceButton

/// 获得按钮种类的名称
+ (NSString *)titleKindForButton:(SHDeviceButton *)button {
    
    switch (button.deviceType) {
        case SHDeviceButtonTypeMediaTV:
            return @"TV";
            
        case SHDeviceButtonTypeCurtain:
            return @"Curtain";
            
        case SHDeviceButtonTypeLight:
            return @"Light";
            
        case SHDeviceButtonTypeAirConditioning:
            return @"Air Conditioner";
            
        case SHDeviceButtonTypeLed:
            return @"LED";
            
        case SHDeviceButtonTypeAudio:
            return @"Audio";
            
        default:
            return @"";
    }
}




/// 字典转换为模型
+ (instancetype)buttonWithDictionary:(NSDictionary *)dictionary {
    
//    SHDeviceButton *btn = [[self alloc] init];
    
    SHDeviceButton *btn = [self deviceButtonType:(SHDeviceButtonType)[dictionary[@"deviceType"] integerValue]];
    
    // 设置每个属性
    
    btn.subNetID = [[dictionary objectForKey:@"subnetID"] integerValue];
    btn.deviceID = [[dictionary objectForKey:@"deviceID"] integerValue];
    
    
    btn.zoneID = [[dictionary objectForKey:@"zoneID"] integerValue];
    btn.buttonID = [[dictionary objectForKey:@"buttonID"] integerValue];
    
    btn.buttonRectSaved = CGRectFromString(dictionary[@"buttonRectSaved"]);
    
    btn.buttonPara1 = [dictionary[@"buttonPara1"] integerValue];
    btn.buttonPara2 = [dictionary[@"buttonPara2"] integerValue];
    btn.buttonPara3 = [dictionary[@"buttonPara3"] integerValue];
    btn.buttonPara4 = [dictionary[@"buttonPara4"] integerValue];
    btn.buttonPara5 = [dictionary[@"buttonPara5"] integerValue];
    btn.buttonPara6 = [dictionary[@"buttonPara6"] integerValue];
    
    return btn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame_x = SHDeviceButtonMaign;
    self.titleLabel.frame_width = self.frame_width * 0.5;
    self.titleLabel.frame_height = self.titleLabel.frame_width;
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame_width;
    
    self.titleLabel.frame_y = (self.frame_height - self.titleLabel.frame_height) * 0.5;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    return self;
}

/// 通过类型来构造设备按钮
+ (instancetype)deviceButtonType:(SHDeviceButtonType )deviceType {

    
     SHDeviceButton *deviceButton = [[self alloc] init];
    
    deviceButton.deviceType = deviceType;
    
    [deviceButton setBackgroundImage:[UIImage imageNamed:deviceButton.imageNames[deviceType]] forState:UIControlStateNormal];
    
    return deviceButton;
}


// MARK: - getter && sett

- (NSMutableArray *)imageNames {
 
      // 注意： 这和枚举值一一对应
    if (!_imageNames) {
        _imageNames = [NSMutableArray arrayWithObjects:@"light", @"led", @"ac", @"audio", @"curtain", @"tv",  nil];
    }
    
    return _imageNames;
}

@end
