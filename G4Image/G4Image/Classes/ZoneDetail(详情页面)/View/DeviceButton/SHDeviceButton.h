//
//  SHDeviceButton.h
//  TouchTest
//
//  Created by Firas on 4/4/17.
//  Copyright (c) 2013 SH. All rights reserved.
//

#import <UIKit/UIKit.h>


/// 按钮类型
typedef enum  {
    
    SHDeviceButtonTypeLight,
    
    SHDeviceButtonTypeLed,

    SHDeviceButtonTypeAirConditioning,
    SHDeviceButtonTypeAudio,

    SHDeviceButtonTypeCurtain,
    SHDeviceButtonTypeMediaTV
    
} SHDeviceButtonType ;


@interface SHDeviceButton : UIButton

/// 按钮区域ID
@property (assign,nonatomic)NSUInteger zoneID;

/// 按钮ID
@property (assign,nonatomic)NSUInteger buttonID;

/// 子网ID
@property (assign,nonatomic)Byte subNetID;

/// 设备ID
@property (nonatomic, assign) Byte deviceID;

/// 按钮类型
@property (assign,nonatomic ) SHDeviceButtonType deviceType;


#pragma mark - 不同的参数(不同设备不同)

/// 参数一:[Dim: 通道, Curtain: Open通道]
@property (assign, nonatomic) Byte buttonPara1;

/// 参数二: [Curtain:  Close 通道];
@property (assign, nonatomic) Byte buttonPara2;

@property (assign, nonatomic) Byte buttonPara3;
@property (assign, nonatomic) Byte buttonPara4;
@property (assign, nonatomic) Byte buttonPara5;
@property (assign, nonatomic) Byte buttonPara6;


/// 按钮的保存区域
@property (assign,nonatomic)CGRect buttonRectSaved;

/// 字典转换为模型
+ (instancetype)buttonWithDictionary:(NSDictionary *)dictionary;

/// 获得按钮种类的名称
+ (NSString *)titleKindForButton:(SHDeviceButton *)button;

/// 通过类型来构造设备按钮
+ (instancetype)deviceButtonType:(SHDeviceButtonType )deviceType;

@end
