//
//  SHConstant.h
//  G4Image
//
//  Created by LHY on 2017/4/28.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#ifndef SHConstant_h
#define SHConstant_h

#import <UIKit/UIKit.h>

// ============= 音乐控制相关的一些参数 =============

// 音乐播放控制
typedef enum  {
    
    SHAudoiPalyControlNone,
    SHAudoiPalyControlPrevious,
    SHAudoiPalyControlNext,
    SHAudoiPalyControlPlay,
    SHAudoiPalyControlStop
    
} SHAudoiPalyControl;


// ============= 空调的控制及相关的一些参数 =============

// 空调温度范围(前两个对应的是摄氏温度的最大和最小值，后面两是华氏的最大与最小温度值)
typedef enum {
    
    SHAirConditioningTemperatureRangeCentigradeMinimumValue = 16, // 0
    
    SHAirConditioningTemperatureRangeCentigradeMaximumValue = 32,  // 30
    
    SHAirConditioningTemperatureRangeFahrenheitMinimumValue = 60, // 32
    
    SHAirConditioningTemperatureRangeFahrenheitMaximumValue = 89, //86
    
} SHAirConditioningTemperatureRange;

/// 空调控制类型(设置方式)
typedef enum {
    
    SHAirConditioningControlTypeOnAndOFF = 0X03,
    
    SHAirConditioningControlTypeCoolTemperatureSet = 0X04,
    
    SHAirConditioningControlTypeFanSpeedSet = 0X05,
    
    SHAirConditioningControlTypeAcModeSet = 0X06,
    
    SHAirConditioningControlTypeHeatTemperatureSet = 0X07,
    
    SHAirConditioningControlTypeAutoTemperatureSet = 0X08
    
} SHAirConditioningControlType;

/// 空调风速等级
typedef enum {
    
    SHAirConditioningFanSpeedKindAuto,
    
    SHAirConditioningFanSpeedKindHigh,
    
    SHAirConditioningFanSpeedKindMedial,
    
    SHAirConditioningFanSpeedKindLow
    
} SHAirConditioningFanSpeedKind;


/// 空调的工作模式
typedef enum {
    
    SHAirConditioningModeKindCool,
    
    SHAirConditioningModeKindHeat,
    
    SHAirConditioningModeKindFan,
    
    SHAirConditioningModeKindAuto
    
} SHAirConditioningModeKind;


// ============= 不同设备按钮的标示状态 =============

// led
#define SHDeviceButtonTypeLEDStatusON (@"ON")
#define SHDeviceButtonTypeLEDStatusOFF (@"OFF")

// ac
#define SHDeviceButtonTypeAirConditioningStatusON (@"ON")
#define SHDeviceButtonTypeAirConditioningStatusOFF (@"OFF")

// curtain
#define SHDeviceButtonTypeCurtainStatusON (@"OPEN")
#define SHDeviceButtonTypeCurtainStatusOFF (@"CLOSE")

// audio
#define SHDeviceButtonTypeAudioStatusON (@"PLAY")
#define SHDeviceButtonTypeAudioStatusOFF (@"STOP")

// tv
#define SHDeviceButtonTypeMediaTVStatusON (@"ON")
#define SHDeviceButtonTypeMediaTVStatusOFF (@"OFF")


// ============= UI界面常用的一些设置高度 =============

/// 状态栏高度
extern const CGFloat SHStatusHeight;


/// 导航栏的高度
extern const CGFloat SHNavigationBarHeight ;

/// tabBar的高度
extern const CGFloat SHTabBarHeight ;


#endif /* SHConstant_h */
