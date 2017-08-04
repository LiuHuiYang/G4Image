//
//  SHDeviceOperatorKindAndStatus.h
//  G4Image
//
//  Created by LHY on 2017/8/4.
//  Copyright © 2017年 SmartHome. All rights reserved.
//

#ifndef SHDeviceOperatorKindAndStatus_h
#define SHDeviceOperatorKindAndStatus_h


// 空调温度范围
typedef enum {
    
    SHAirConditioningTemperatureRangeCentigradeMinimumValue = 16, // 0
    
    SHAirConditioningTemperatureRangeCentigradeMaximumValue = 32,  // 30
    
    SHAirConditioningTemperatureRangeFahrenheitMinimumValue = 60, // 32
    
    SHAirConditioningTemperatureRangeFahrenheitMaximumValue = 89, //86
    
} SHAirConditioningTemperatureRange;

/// 空调控制类型
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
#define SHDeviceButtonTypeAudioStatusOFF (@"END")

// tv
#define SHDeviceButtonTypeMediaTVStatusON (@"ON")
#define SHDeviceButtonTypeMediaTVStatusOFF (@"OFF")

// 音乐播放控制
typedef enum  {
    
    SHAudoiPalyControlNone,
    SHAudoiPalyControlPrevious,
    SHAudoiPalyControlNext,
    SHAudoiPalyControlPlay,
    SHAudoiPalyControlStop
    
} SHAudoiPalyControl;


#endif /* SHDeviceOperatorKindAndStatus_h */
