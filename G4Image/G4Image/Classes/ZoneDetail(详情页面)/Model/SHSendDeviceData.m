//
//  SHSendDeviceData.m
//  G4Image
//
//  Created by LHY on 2017/4/26.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHSendDeviceData.h"

#import "SHSelectColorViewController.h"

#import "SHSetAirConditionerViewController.h"

/// 灯光的最高亮度
const Byte lightValue = 100;

/// 空调的最大温度
const Byte maxTempture = 30;

/// 空调的最低温度
const Byte minTempture = 16;

/// 最大的音量
const Byte maxVol = 80; // 其它只有80

@interface SHSendDeviceData ()


@end

@implementation SHSendDeviceData


// MARK: - Light or Dimmer

/// 读取调光器的当前值
+ (void)readDimmerStatus:(SHDeviceButton *)button {
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0X0033 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:nil needReSend:YES];
}

/// 设置调光器
+ (void)setDimmer:(SHDeviceButton *)button {
    
    // 获取按钮当前的值
    NSString *title = [button titleForState:UIControlStateNormal];
    
    // 目标亮度 有值就是0，第一次开灯或没有亮度就是开灯最亮（总之是相反的状态）
    Byte brightness = ![title integerValue] ? lightValue : 0;
    
    // 开始发送指令
    [button setTitle:[NSString stringWithFormat:@"%d%%", brightness] forState:UIControlStateNormal];
    
    Byte lightData[4] = {button.buttonPara1, brightness, 0X0, 0X0};
    
    // 发送指令
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0X0031 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:lightData length:sizeof(lightData)] needReSend:YES];
}


/// 改变灯光的值
+ (void)updateDimmerBrightness:(UIPanGestureRecognizer *)recognizer {
    
    // 必须是拖拽手势
    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    
    // 获得按钮
    SHDeviceButton *button = (SHDeviceButton *)recognizer.view;
    
    // 获得按钮的文字
    NSString *title = [button titleForState:UIControlStateNormal];
    
    Byte brightness = [title integerValue];
    
    //  横坐标上、纵坐标上拖动了多少
    CGPoint translation = [recognizer translationInView:button];
    
    // 获得移动的(距离与方向相反)
    brightness -= (translation.y);
    
    if (brightness >= 0 && brightness <= lightValue) {
        [button setTitle:[NSString stringWithFormat:@"%d%%", brightness] forState:UIControlStateNormal];
    
        // 手势结束才发送
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            Byte lightData[4] = {button.buttonPara1, brightness, 0X0, 0X0};
            
            [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0x0031 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:lightData length:sizeof(lightData)] needReSend:YES];

        }
    }
    //  因为拖动起来一直是在递增，所以每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [recognizer setTranslation:CGPointZero inView:button];
}

// MARK: - 空调

/// 设置空调
+ (void)setAirConditioning:(SHDeviceButton *)button {
    
    // 获得当前的状态
    
        SHSetAirConditionerViewController *setAirConditionerController = [[SHSetAirConditionerViewController alloc] init];
        [setAirConditionerController show:button];
    
}

///// 改变AC的温度值
//+ (void)updateACTempture:(UIPanGestureRecognizer *)recognizer {
//    
//    // 必须是拖拽手势
//    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        return;
//    }
//    
//    // 获得按钮
//    SHDeviceButton *button = (SHDeviceButton *)recognizer.view;
//    
//    // 获得按钮的文字
//    NSString *title = [button titleForState:UIControlStateNormal];
//    
//    Byte currentValue = [title integerValue];
//    
//    if ([title isEqualToString:SHDeviceButtonTypeAirConditioningStatusOFF]) {
//        [MBProgressHUD showWarning:@"turn on the air conditioner"];
//        return; // 空调是关闭状态不能调温度
//    }
//    
//    if ([title isEqualToString:SHDeviceButtonTypeAirConditioningStatusON]) {
//        currentValue = maxTempture;
//    }
//    
//    //  横坐标上、纵坐标上拖动了多少
//    CGPoint translation = [recognizer translationInView:button];
//    
//    // 获得移动的(距离与方向相反)
//    currentValue -= (translation.y);
//    
//    if (currentValue >= minTempture && currentValue <= maxTempture) {
//        
//        [button setTitle:[NSString stringWithFormat:@"%d°C", currentValue] forState:UIControlStateNormal];
//        
//        // 发送空调指令
//        Byte tempture[] = {0X04, currentValue};
//        [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE3D8 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:tempture length:sizeof(tempture)] needReSend:YES];
//    }
//    
//    //  因为拖动起来一直是在递增，所以每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
//    [recognizer setTranslation:CGPointZero inView:button];
//}

/// 读取当前AC的温度
+ (void)readAcStatus:(SHDeviceButton *)button {
    
    // 读取状态空调的开关状态
    Byte readHVACdata[] = { 0 };
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE0EC targetSubnetID:button.subNetID  targetDeviceID:button.deviceID  additionalContentData:[NSMutableData dataWithBytes:readHVACdata length:sizeof(readHVACdata)] needReSend:NO];
}


// MARK: - Audio

/// 播放或结束音乐
+ (void)musicPlayAndStop:(SHDeviceButton *)button {
    
    NSString *status = ([button.currentTitle isEqualToString:SHDeviceButtonTypeAudioStatusOFF] || !button.currentTitle) ? SHDeviceButtonTypeAudioStatusON : SHDeviceButtonTypeAudioStatusOFF;
    
    // 设置显示
    [button setTitle:status forState:UIControlStateNormal];
    
    Byte playOrEnd = ([status isEqualToString:SHDeviceButtonTypeAudioStatusON]) ? 0X03 : 0X04;
    
    Byte sonData[4] = {0X04, playOrEnd, 0X00, 0X00};
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0X0218 targetSubnetID:button.subNetID targetDeviceID: button.deviceID additionalContentData:[NSMutableData dataWithBytes:sonData length:sizeof(sonData)] needReSend:YES];
}

/// 调整声音的大小
+ (void)updateAuidoVOL:(UIPanGestureRecognizer *)recognizer {
    
    // 必须是拖拽手势
    if (![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    
    // 获得按钮
    SHDeviceButton *button = (SHDeviceButton *)recognizer.view;
    
    // 获得按钮的文字
    NSString *title = [button titleForState:UIControlStateNormal];
    
    // 设定音量大小
    Byte voice = [title integerValue];
    
    if ([title isEqualToString:SHDeviceButtonTypeAudioStatusOFF]) {
        [MBProgressHUD showWarning:@"No music settings are invalid"];
        return;
    }
    
    if ([title isEqualToString:SHDeviceButtonTypeAudioStatusON]) {
        voice = maxVol * 0.15;
    }
    
    //  横坐标上、纵坐标上拖动了多少
    CGPoint translation = [recognizer translationInView:button];
    
    // 获得移动的(距离与方向相反)
    voice -= (translation.y);
    
    if (voice >= 0 && voice <= maxVol) {
        
        // 显示成100
        [button setTitle:[NSString stringWithFormat:@"%d", voice] forState:UIControlStateNormal];
        
        // 手势结束才发发送
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            // 改变声音
            Byte array[4] = {0X05, 0X01, 0X03,  maxVol - voice };
            
            [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0x0218 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:array length:sizeof(array)] needReSend:YES];
        }
    }
    
    //  因为拖动起来一直是在递增，所以每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [recognizer setTranslation:CGPointZero inView:button];
}

/// 切换音乐
+ (void)switchMusic:(UISwipeGestureRecognizer *)recognizer {
    
    // 必须是清扫手势
    if (![recognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return;
    }
    
    // 获得按钮
    SHDeviceButton *button = (SHDeviceButton *)recognizer.view;
    
    // 获得当前按钮标题
    if ([[button titleForState:UIControlStateNormal] isEqualToString:SHDeviceButtonTypeAudioStatusOFF]) {
        [MBProgressHUD showWarning:@"No music settings are invalid"];
        return;
    }
    
    // 上一首向左01 下一首向右 02
    Byte previousOrNext = 0;
    
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft: {
            previousOrNext = 0X01;
            [MBProgressHUD showStatus:@"Back Song"];
        }
            break;
            
        case UISwipeGestureRecognizerDirectionRight: {
            previousOrNext = 0X02;
            [MBProgressHUD showStatus:@"Next Song"];
        }
            break;
            
        default:
            break;
    }
    
    Byte songDataArray[4] = {0X04, previousOrNext, 0X00, 0X00};
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0x0218 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:songDataArray length:sizeof(songDataArray)] needReSend:YES];
}

// MARK: - Curtain

/// 窗帘打开和关闭
+ (void)curtainOpenOrClose:(SHDeviceButton *)button {
    
    // 获得当前按钮的值并设置改变的状态
    NSString *status = ([button.currentTitle isEqualToString:SHDeviceButtonTypeCurtainStatusOFF] || !button.currentTitle) ? SHDeviceButtonTypeCurtainStatusON : SHDeviceButtonTypeCurtainStatusOFF;
    
    // 设置显示
    [button setTitle:status forState:UIControlStateNormal];
    
    // 打开和关闭通道
    Byte curtainStartOrStop = ([status isEqualToString:SHDeviceButtonTypeCurtainStatusOFF]) ? button.buttonPara1 : button.buttonPara2;
    
    // 和Dimmer一样
    Byte curtainData[] = {curtainStartOrStop, 100, 0, 0};
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0X0031 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:curtainData length:sizeof(curtainData)] needReSend:YES];
}

// MARK: - TV

/// 播放电视
+ (void)watchTv:(SHDeviceButton *)button {
    
    // 获得当前按钮的值并设置改变的状态
    NSString *status = ([[button titleForState:UIControlStateNormal] isEqualToString:SHDeviceButtonTypeMediaTVStatusOFF] || !button.currentTitle) ? SHDeviceButtonTypeMediaTVStatusON : SHDeviceButtonTypeMediaTVStatusOFF;
    
    // 设置显示
    [button setTitle:status forState:UIControlStateNormal];
    
    Byte tvOnAndOff = ([status isEqualToString:SHDeviceButtonTypeMediaTVStatusON]) ? 0XFF : 0X0;
    Byte data[] = {button.buttonPara1, tvOnAndOff};
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE01C targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:data length:sizeof(data)] needReSend:YES];
}

// MARK: - LED

/// 设置led
+ (void)ledOnAndOff:(SHDeviceButton *)button {
    
    // 获得当前的状态
    NSString *status = (!button.currentTitle || [button.currentTitle isEqualToString:SHDeviceButtonTypeLEDStatusOFF]) ?  SHDeviceButtonTypeLEDStatusON : SHDeviceButtonTypeLEDStatusOFF;
    
    [button setTitle:status forState:UIControlStateNormal];
    
    if ([button.currentTitle isEqualToString:SHDeviceButtonTypeMediaTVStatusOFF]) {
        
        Byte ledData[6] = {0X0, 0X0, 0X0, 0X0, 0X0, 0X0};
        
        // 发送指令
        [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XF080 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:[NSMutableData dataWithBytes:ledData length:sizeof(ledData)] needReSend:YES];
        
    } else {
        
        SHSelectColorViewController *selectController = [[SHSelectColorViewController alloc] init];
        [selectController show:button];
    }
}

/// 读取当前的颜色
+ (void)readLedCurrentColor:(SHDeviceButton *)button {
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0X0033 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:nil needReSend:YES];
}

// 设置背景颜色
+ (void)setLED:(SHDeviceButton *)button colorData:(NSMutableData *)colorData {
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0xF080 targetSubnetID:button.subNetID targetDeviceID:button.deviceID additionalContentData:colorData needReSend:YES];
}

// MARK: - Read

/// 读取当前设备的所有状态
+ (void)readDeviceStatus:(SHDeviceButton *)button {
    
    // 发送读取数据的指令
    switch (button.deviceType) {
            
            // 调光器
        case SHDeviceButtonTypeLight:
            [self readDimmerStatus:button];
            break;
            
            // 空调
        case SHDeviceButtonTypeAirConditioning: {
            [self readAcStatus:button];
        }
            break;
            
            // 窗帘
        case SHDeviceButtonTypeCurtain: {
            // 和读调光器一样, 但没有意义
        }
            break;
            
        case SHDeviceButtonTypeAudio: {
            // ... 暂时没有读
        }
            break;
            
        case SHDeviceButtonTypeLed: {
            // 读取lED
            [self readLedCurrentColor:button];
        }
            break;
            
        default:
            break;
    }
    
}

@end
