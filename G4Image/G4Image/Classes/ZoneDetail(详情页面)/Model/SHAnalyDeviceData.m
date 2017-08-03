//
//  SHAnalyDeviceData.m
//  G4Image
//
//  Created by LHY on 2017/4/26.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHAnalyDeviceData.h"

@implementation SHAnalyDeviceData

/// 解析空调
+ (void)analyAC:(NSData *)data inZone:(SHZone *)zone {
    
    Byte *recivedData = ((Byte *) [data bytes]);
    
     UInt16 operatorCode = ((recivedData[5] << 8) | recivedData[6]);
    if (operatorCode == 0XE0ED) {
        SHLog(@"ssss");
    }
    
    // 获得子网ID和设备ID
    Byte subNetID = recivedData[1];
    Byte deviceID = recivedData[2];
    
    // 获得操试方式
    Byte operatorKind = recivedData[9];
    // 获得操作结果
    Byte operatorResult = recivedData[10];
    
    NSString *status = @"";
    
    
    switch (operatorKind) {
            
            // AC ON/OFF
        case 0X03: {
            status = (operatorResult == 0X01) ? @"ON" : @"OFF";
        }
            break;
            
        case 0X01: // 程序启动进入状态
            // Cool temperature Set Point
        case 0X04:{
            status = [NSString stringWithFormat:@"%d°C", operatorResult];
        }
            break;
            
            // 没有处理的其他情况，暂时使用AC显示
        default:
            status = @"AC";
            break;
    }
    
    // 找到区域的按钮
    for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
        if (button.subNetID == subNetID && button.deviceID == deviceID) {
            
            // 设置改变的状态
            [button setTitle:status forState:UIControlStateNormal];
        }
    }
}

/// 解析调光器
+ (void)analyDimmer:(NSData *)data inZone:(SHZone *)zone {
    
    Byte *recivedData = ((Byte *) [data bytes]);
    
    // 获得操作码
    UInt16 operatorCode = ((recivedData[5] << 8) | recivedData[6]);
    
    // 获得子网ID和设备ID
    Byte subNetID = recivedData[1];
    Byte deviceID = recivedData[2];
    
    // 获得通道
    Byte channelNumber = recivedData[9];
    
    switch (operatorCode) {
        case 0X0032: {
            
            // 获得亮度
            Byte brightness = recivedData[11];
            
            // 找到当前区域的按钮
            for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
                
                // 这是灯光
                if (button.subNetID == subNetID && button.deviceID == deviceID && channelNumber == button.buttonPara1 && button.deviceType == SHDeviceButtonTypeLight) {
                    
                    [button setTitle:[NSString stringWithFormat:@"%d%%", brightness] forState:UIControlStateNormal];
                    
                    continue;
                }
                
                // 窗帘
                if (button.subNetID == subNetID && button.deviceID == deviceID && button.deviceType == SHDeviceButtonTypeCurtain) {
                    
                    SHLog(@"这是窗帘 -- 这里不能设置");
                }
            }
        }
            break;
            
        case 0X0034: {
            
            // 开始截取的有效数据
            Byte startIndex = 9;
            
            // 这是LED
            if (data.length == startIndex + 4 + 2 + 1) {
                [self analyLED:data inZone:zone];
                return;
            }
            
            // 这是普通灯炮
            Byte totalChannels = recivedData[startIndex];
            
            // 按通道赋值
            for (Byte i = 0; i < totalChannels; i++) {
                
                // 找到当前区域的按钮
                for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
                    
                    // 这是Light
                    if (button.subNetID == subNetID && button.deviceID == deviceID && (i + 1) == button.buttonPara1 && button.deviceType == SHDeviceButtonTypeLight) {
                        
                        [button setTitle:[NSString stringWithFormat:@"%d%%", recivedData[startIndex + 1 + i]] forState:UIControlStateNormal];
                    } else if (button.subNetID == subNetID && button.deviceID == deviceID && button.deviceType == SHDeviceButtonTypeCurtain) {
                        
                        SHLog(@"这是窗帘 -- 不能准确定位");
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
}


/// 解析音乐
+ (void)analyAudio:(NSData *)data inZone:(SHZone *)zone {
    
    Byte *recivedData = ((Byte *) [data bytes]);
    
    // 获得子网ID和设备ID
    Byte subNetID = recivedData[1];
    Byte deviceID = recivedData[2];
    
    // 播放控制
    if (recivedData[9] == 0X04) {
        
        // 获得播放状态
        NSString * playStatus = @"";
        
        if (recivedData[10] == SHAudoiPalyControlNone) {
            return;
            
        } else if (recivedData[10] == SHAudoiPalyControlStop) {
            playStatus = @"END";
        } else {
            
            playStatus = @"PLAY";
            
            if (recivedData[10] == SHAudoiPalyControlNext) {
                [MBProgressHUD showStatus:@"Next Song"];
            } else if(recivedData[10] == SHAudoiPalyControlPrevious) {
                [MBProgressHUD showStatus:@"Back Song"];
            }
        }
        
        // 设置按钮
        for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
            if (button.deviceType == SHDeviceButtonTypeAudio && button.subNetID == subNetID && button.deviceID == deviceID) {
                [button setTitle:playStatus forState:UIControlStateNormal];
            }
        }
        
        // 音量调节
    } else if(recivedData[9] == 0X05) {
        
        if (recivedData[10] == 0X01 && recivedData[11] == 0X03) {
            // 设置音量
            for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
                if (button.deviceType == SHDeviceButtonTypeAudio && button.subNetID == subNetID && button.deviceID == deviceID) {
                    [button setTitle:[NSString stringWithFormat:@"%d", 80 - recivedData[12]] forState:UIControlStateNormal];
                }
            }
        }
    }
}

/// 解析TV
+ (void)analyTV:(NSData *)data inZone:(SHZone *)zone {

    Byte *recivedData = ((Byte *) [data bytes]);
    
    // 获得子网ID和设备ID
    Byte subNetID = recivedData[1];
    Byte deviceID = recivedData[2];
    
    // 获得开关的状态
    Byte statues = recivedData[10];
    
    NSString *title = statues ? @"ON" : @"OFF";
    
    // 找到这个按钮
    for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
        if (button.deviceType == SHDeviceButtonTypeMediaTV && button.subNetID == subNetID && button.deviceID == deviceID) {
            [button setTitle:title forState:UIControlStateNormal];
        }
    }
}


// MARK: - LED

/// 解析LED
+ (void)analyLED:(NSData *)data inZone:(SHZone *)zone {
    
    Byte *recivedData = ((Byte *) [data bytes]);
    
    // 获得子网ID和设备ID
    Byte subNetID = recivedData[1];
    Byte deviceID = recivedData[2];
    
    NSUInteger startIndex = 9;
    
    for (int i = 0; i < data.length; i++) {
        printf("%#02X ", recivedData[i]);
    }
    
    SHLog(@"结束");

    // 获取颜色
    CGFloat red = recivedData[++startIndex] / 100.0;
    CGFloat green = recivedData[++startIndex] / 100.0;
    CGFloat blue = recivedData[++startIndex]  / 100.0 ;
    CGFloat alpha = recivedData[++startIndex]  / 100.0;

    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    // 找到button
    for (SHDeviceButton *button in zone.allDeviceButtonInCurrentZone) {
        if (button.deviceType == SHDeviceButtonTypeLed && button.subNetID == subNetID && button.deviceID == deviceID) {

            // 设置显示图征的控件渲染模式为白色
            [button.imageView setTintColor:color];
            
            // 获得原画的图片
            UIImage *image = [[button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
            // 设置图片 始终根据Tint Color绘制图片，忽略图片的颜色信息。
            [button setImage:image forState:UIControlStateNormal];
        }
    }
}

// MARK: - 解析总数据

/// 解析所有的数据
+ (void)analyDeviceData:(NSData *)data inZone:(SHZone *)zone {
    Byte *recivedData = ((Byte *) [data bytes]);
    
    // 2.获得操作码
    UInt16 operatorCode = ((recivedData[5] << 8) | recivedData[6]);
    
    switch (operatorCode) {
            
            // 空调温度变化
            //        case 0XE3E8:
        case 0XE0ED:
        case 0XE3D9: {
            [self analyAC:data inZone:zone];
        }
            break;
            
            /// Dimmer / Light
        case 0X0032:
        case 0x0034: {
            [self analyDimmer:data inZone:zone];
        }
            break;
            
            
            // 测试LED --
        case 0XF081: {
            [self analyLED:data inZone:zone];
        }
            break;
            
        case 0XF013: {
            [self analyLED:data inZone:zone];
        }
            break;
            
            // Audio
        case 0X0219: {
            [self analyAudio:data inZone:zone];
        }
            break;
            
            // TV
        case 0XE01D: {
            [self analyTV:data inZone:zone];
        }
            break;
            
        default:
            break;
    }
}

@end
