//
//  SHSendDeviceData.h
//  G4Image
//
//  Created by LHY on 2017/4/26.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHSendDeviceData : NSObject

// MARK: - Read

/// 读取当前设备的所有状态
+ (void)readDeviceStatus:(SHDeviceButton *)button;


// MARK: - Light

/// 设置调光器
+ (void)setDimmer:(SHDeviceButton *)button;

/// 改变灯光的值
+ (void)updateDimmerBrightness:(UIPanGestureRecognizer *)recognizer;

// MARK: - AC

/// 设置空调
+ (void)setAirConditioning:(SHDeviceButton *)button;

/// AC 空调开关
+ (void)acOnAndOff:(SHDeviceButton *)button;

/// 改变AC的温度值
+ (void)updateACTempture:(UIPanGestureRecognizer *)recognizer;


// MARK: - Audio

/// 播放或结束音乐
+ (void)musicPlayAndStop:(SHDeviceButton *)button;

/// 调整声音的大小
+ (void)updateAuidoVOL:(UIPanGestureRecognizer *)recognizer;

/// 切换音乐
+ (void)switchMusic:(UISwipeGestureRecognizer *)recognizer;


// MARK: - Curtain
 
/// 窗帘打开和关闭
+ (void)curtainOpenOrClose:(SHDeviceButton *)button;
 
// MARK: - TV

/// 播放电视
+ (void)watchTv:(SHDeviceButton *)button;

// MARK: - LED

/// 设置led
+ (void)ledOnAndOff:(SHDeviceButton *)button;

// 设置背景颜色
+ (void)setLED:(SHDeviceButton *)button colorData:(NSMutableData *)colorData;

@end
