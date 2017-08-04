//
//  SHSetAirConditionerViewController.m
//  G4Image
//
//  Created by LHY on 2017/8/4.
//  Copyright © 2017年 SmartHome. All rights reserved.
//

#import "SHSetAirConditionerViewController.h"

@interface SHSetAirConditionerViewController () <SHUdpSocketDelegate>

/// 当前触发的按钮
@property (nonatomic, strong) SHDeviceButton *currentButton;

// MARK: - 当前空调的一些标示

/// 开关显示视图
@property (weak, nonatomic) IBOutlet UIView *trunOnAndOffView;

/// 风速控制视图
@property (weak, nonatomic) IBOutlet UIView *fanSpeedControlView;

/// 模式显示视图
@property (weak, nonatomic) IBOutlet UIView *modeControlView;


/// 是否是摄式温度
@property (assign, nonatomic) BOOL isCelsiusFlag;

/// 当前空调是是否打开状态
@property (assign, nonatomic) BOOL isTurnOn;

/// 风速
@property (assign, nonatomic) SHAirConditioningFanSpeedKind fanRange;

/// 环境温度
@property (assign, nonatomic) Byte indoorTemperature;

// MARK: - 打开与关闭空调

/// 环境温度
@property (weak, nonatomic) IBOutlet UIButton *ambientTemperatureButton;

/// 空调开关
@property (weak, nonatomic) IBOutlet UIButton *trunOnAndOffButton;


// MARK: - 风速控制按钮

/// 低风速
@property (weak, nonatomic) IBOutlet UIButton *lowFanButton;

/// 中风速
@property (weak, nonatomic) IBOutlet UIButton *middleFanButton;

/// 高风速
@property (weak, nonatomic) IBOutlet UIButton *highFanButton;

/// 自动风速
@property (weak, nonatomic) IBOutlet UIButton *autoFanButton;

@end

@implementation SHSetAirConditionerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SHGlobalBackgroundColor;
    
    // 设置代理
    [SHUdpSocket shareSHUdpSocket].delegate = self;
    
    // 设置默认是摄氏温度
    self.isCelsiusFlag = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - 开启与关闭



// MARK: - 控制风速

/// 低风速
- (IBAction)lowFanButtonClick {
    
    [self changeHVACFanSpeed:self.lowFanButton Value:SHAirConditioningFanSpeedKindLow];
}

/// 中风速
- (IBAction)middleFanButtonClick {
    
    [self changeHVACFanSpeed:self.middleFanButton Value:SHAirConditioningFanSpeedKindMedial];
}

/// 高风速
- (IBAction)highFanButtonClick {
    
    [self changeHVACFanSpeed:self.highFanButton Value:SHAirConditioningFanSpeedKindHigh];
}

/// 自动风速
- (IBAction)autoFanButtonClick {
    
    [self changeHVACFanSpeed:self.autoFanButton Value:SHAirConditioningFanSpeedKindAuto];
}

/// 控制HVAC的风速
- (void)changeHVACFanSpeed:(UIButton *)selectModelButton Value:(Byte)sendValue {
    
    // 全部取消
    self.middleFanButton.selected = NO;
    self.lowFanButton.selected = NO;
    self.highFanButton.selected = NO;
    self.autoFanButton.selected = NO;
    
    // 选中的按钮
    selectModelButton.selected = YES;
    
    // 发送指令
    Byte controlData[2] = {SHAirConditioningControlTypeFanSpeedSet, sendValue};
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE3D8 targetSubnetID:self.currentButton.subNetID targetDeviceID:self.currentButton.deviceID additionalContentData:[NSMutableData dataWithBytes:controlData length:sizeof(controlData)] needReSend:YES];
}

// MARK: - 开启与关闭空调

/// 关闭空调
- (IBAction)turnOFFAirConditioning {
    
   
    Byte acControlData[] = {SHAirConditioningControlTypeOnAndOFF, !self.isTurnOn};
    
    // 设置按钮标题
//    [self.trunOnAndOffButton setTitle:(self.isTurnOn ? SHDeviceButtonTypeAirConditioningStatusOFF : SHDeviceButtonTypeAirConditioningStatusON) forState:UIControlStateNormal];
    
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE3D8 targetSubnetID:self.currentButton.subNetID targetDeviceID:self.currentButton.deviceID additionalContentData:[NSMutableData dataWithBytes:acControlData length:sizeof(acControlData)] needReSend:YES];
}

// MARK: - 解析数据

- (void)analyzeReceiveData:(NSData *)data {

    Byte *recivedData = ((Byte *) [data bytes]);
    
    // 获得操作码
    UInt16 operatorCode = ((recivedData[5] << 8) | recivedData[6]);
    
    // 获得子网ID和设备ID
    Byte subNetID = recivedData[1];
    Byte deviceID = recivedData[2];
    
    if ((subNetID != self.currentButton.subNetID) || (deviceID != self.currentButton.deviceID)) {
        return;
    }
    
    switch (operatorCode) {
            
            // 控制的返回数据
        case 0XE3D9: {
            
            // 获得操试方式
            Byte operatorKind = recivedData[9];
            // 获得操作结果
            Byte operatorResult = recivedData[10];
            
            switch (operatorKind) {
                    
                    // AC on/off
                case SHAirConditioningControlTypeOnAndOFF: {
                    
                    // 获得状态
                    self.isTurnOn = operatorResult;
                }
                    break;
                    
                    // 制冷温度
                case SHAirConditioningControlTypeCoolTemperatureSet: {
                    
                    // 获得状态
//                    self.currentSelecthvac.coolTemperture = operatorResult;
                }
                    break;
                    
                    // AC 风速
                case SHAirConditioningControlTypeFanSpeedSet: {
                    
                    // 获得状态
                    self.fanRange = operatorResult;
                }
                    break;
                    
                    // AC 工作模式
                case SHAirConditioningControlTypeAcModeSet: {
                    
                    // 获得状态
//                    self.currentSelecthvac.acMode = operatorResult;
                }
                    break;
                    
                    // 制热温度
                case SHAirConditioningControlTypeHeatTemperatureSet: {
                    
                    // 获得状态
//                    self.currentSelecthvac.heatTemperture = operatorResult;
                }
                    break;
                    
                    // 自动温度
                case SHAirConditioningControlTypeAutoTemperatureSet: {
                    
                    // 获得状态
//                    self.currentSelecthvac.autoTemperture = operatorResult;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
            // 读取回收到的状态
        case 0XE0ED: {
            
            // 获得状态
            self.isTurnOn = recivedData[9];

            // 获得环境温度
            self.indoorTemperature = recivedData[13];

            // 获得风速
            self.fanRange = recivedData[11] & 0X0F;
//
//            // 获得工作用模式
//            self.currentSelecthvac.acMode = (recivedData[11] & 0XF0) >> 4;
//            
//            // 获得三种不同的温度
//            
//            // 通风模式的温度
//            self.currentSelecthvac.coolTemperture = recivedData[10];
//            
//            // 制热模式的温度
//            self.currentSelecthvac.heatTemperture = recivedData[14];
//            
//            // 自动模式的温度
//            self.currentSelecthvac.autoTemperture = recivedData[16];
        }
            break;
            
            // 获得温度单位
        case 0XE121: {
            
            // 获得温度单位 是否为摄氏温度
            self.isCelsiusFlag = (recivedData[9] == 0);
        }
            break;
            
        default:
            break;
    }
    

    // 设置状态
    [self setAirConditioningStatus];
}

/// 设置空调的状态
- (void)setAirConditioningStatus {

    // 1.设置显示开和关
    self.fanSpeedControlView.hidden = !self.isTurnOn;
    self.modeControlView.hidden = !self.isTurnOn;
    
    self.trunOnAndOffButton.selected = self.isTurnOn;

//    [self.trunOnAndOffButton setImage:[UIImage imageNamed:@"turnon"] forState:UIControlStateSelected];
    
    // 2.设置环境温度
    
    [self.ambientTemperatureButton setTitle:[NSString stringWithFormat:@"%d%@", self.isTurnOn ? self.indoorTemperature : 0, self.isCelsiusFlag ? @"°C" : @"°F"] forState: UIControlStateNormal];

    // 3.设置风速等级
    self.autoFanButton.selected = NO;
    self.highFanButton.selected = NO;
    self.middleFanButton.selected = NO;
    self.lowFanButton.selected = NO;
    
    switch (self.fanRange) {
            
        case SHAirConditioningFanSpeedKindAuto: {
            
            // 选择按钮
            self.autoFanButton.selected = YES;
        }
            break;
            
        case SHAirConditioningFanSpeedKindHigh: {
            
            self.highFanButton.selected = YES;
        }
            break;
            
        case SHAirConditioningFanSpeedKindMedial: {
            
            self.middleFanButton.selected = YES;
        }
            break;
            
        case SHAirConditioningFanSpeedKindLow: {
            
            self.lowFanButton.selected = YES;
        }
            break;
            
        default:
            break;
    }

}


// MARK: - 读取状态

/// 读取状态
- (void)readCurrentButtonForAirConditioningStatus {
    
    // 读取温度单位
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE120 targetSubnetID:self.currentButton.subNetID targetDeviceID:self.currentButton.deviceID additionalContentData:nil needReSend:NO];
    
    // 读取状态空调的开关状态
    Byte readHVACdata[] = { 0 };
    [[SHUdpSocket shareSHUdpSocket] sendDataWithOperatorCode:0XE0EC targetSubnetID:self.currentButton.subNetID  targetDeviceID:self.currentButton.deviceID  additionalContentData:[NSMutableData dataWithBytes:readHVACdata length:sizeof(readHVACdata)] needReSend:NO];

}

/// 退出界面
- (IBAction)closeButtonClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - 显示界面

- (void)show:(SHDeviceButton *)button {
    
    // 记录按钮
    self.currentButton = button;
    
    // 读取一下空调的状态
    [self readCurrentButtonForAirConditioningStatus];
    
    // 设置弹出模式
    self.modalPresentationStyle = UIModalPresentationPopover;
    
    // 设置方向
    self.popoverPresentationController.permittedArrowDirections =
    UIPopoverArrowDirectionAny;
    
    // 设置区域
    self.popoverPresentationController.sourceView = button;
    self.popoverPresentationController.sourceRect = button.bounds;
    
    // 弹出
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:nil];
}

@end
