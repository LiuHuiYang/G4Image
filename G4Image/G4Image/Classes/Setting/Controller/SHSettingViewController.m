//
//  SHSettingViewController.m
//  G4Image
//
//  Created by LHY on 2017/4/6.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHSettingViewController.h"


@interface SHSettingViewController ()

/// 子网ID
@property (weak, nonatomic) IBOutlet UITextField *subNetTextField;

/// 设备ID
@property (weak, nonatomic) IBOutlet UITextField *deviceTextField;

/// 调光器通道
@property (weak, nonatomic) IBOutlet UITextField *dimmerChannel;

/// 打开窗帘
@property (weak, nonatomic) IBOutlet UITextField *curtainOpenChannel;

/// 关闭窗帘
@property (weak, nonatomic) IBOutlet UITextField *curtainCloseChannel;

/// dimmer通道设置
@property (weak, nonatomic) IBOutlet UILabel *dimmerLabel;

/// 窗帘打开
@property (weak, nonatomic) IBOutlet UILabel *curtainOpenLabel;

/// 窗帘打开
@property (weak, nonatomic) IBOutlet UILabel *curtainCloseLabel;

@end

@implementation SHSettingViewController


#pragma mark - 点击事件

/// 保存
- (IBAction)saveButtonClick:(UIButton *)sender {
    
    self.settingButton.subNetID = (Byte)self.subNetTextField.text.integerValue;
    self.settingButton.deviceID = (Byte)self.deviceTextField.text.integerValue;
    
    if (self.settingButton.deviceType == SHDeviceButtonTypeLight) {
        self.settingButton.buttonPara1 = (Byte)self.dimmerChannel.text.integerValue;
    }
    
    if (self.settingButton.deviceType == SHDeviceButtonTypeCurtain) {
        self.settingButton.buttonPara1 = (Byte)self.curtainOpenChannel.text.integerValue;
        self.settingButton.buttonPara2 = (Byte)self.curtainCloseChannel.text.integerValue;
    }
    
    [MBProgressHUD showSuccess:@"save Data"];
    [self.navigationController popViewControllerAnimated:YES];
}

/// 删除按钮
- (IBAction)deleteButtonClick:(UIButton *)sender {
    
    // 来源控制器的保存按钮数组中删除
    if ([self.sourceViewController.zone.allDeviceButtonInCurrentZone containsObject:self.settingButton]) {
        [self.sourceViewController.zone.allDeviceButtonInCurrentZone removeObject:self.settingButton];
    }
    
    // 数据库也要删除
    [[SHSQLiteManager shareSHSQLiteManager] deleteButton:self.settingButton];;
    
    // 从界面上删除这个按钮
    [self.settingButton removeFromSuperview];
    
    // 返回
    [self.navigationController popViewControllerAnimated:YES];
}

/// 取消操作
- (IBAction)cancelButtonClick:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // 设置当前设置的标题
    self.title = [SHDeviceButton titleKindForButton:self.settingButton];
    
    // 设置初值
    self.subNetTextField.text = [NSString stringWithFormat:@"%d", self.settingButton.subNetID];
    self.deviceTextField.text = [NSString stringWithFormat:@"%d", self.settingButton.deviceID];
    
    
    if (self.settingButton.deviceType == SHDeviceButtonTypeLight) {
        self.dimmerChannel.text = [NSString stringWithFormat:@"%d", self.settingButton.buttonPara1];
    }
    
    if (self.settingButton.deviceType == SHDeviceButtonTypeCurtain) {
        self.curtainOpenChannel.text = [NSString stringWithFormat:@"%d", self.settingButton.buttonPara1];
        self.curtainCloseChannel.text = [NSString stringWithFormat:@"%d", self.settingButton.buttonPara2];
    }
    
    // 子网ID成为第一响应者
    [self.subNetTextField becomeFirstResponder];
    
    // 先隐藏不同的部分
    self.dimmerLabel.hidden = YES;
    self.dimmerChannel.hidden = YES;
    
    self.curtainOpenLabel.hidden = YES;
    self.curtainOpenChannel.hidden = YES;
    
    self.curtainCloseLabel.hidden = YES;
    self.curtainCloseChannel.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 如果是调光器
    if (self.settingButton.deviceType == SHDeviceButtonTypeLight) {
//        self.dimmerLabel.text = @"Dimmer Channel NO.";
        self.dimmerChannel.hidden = NO;
        self.dimmerLabel.hidden = NO;
    }
    
    if (self.settingButton.deviceType == SHDeviceButtonTypeMediaTV) {
//        self.dimmerLabel.text = @"TV Channel NO.";
        self.dimmerChannel.hidden = NO;
        self.dimmerLabel.hidden = NO;
    }
    
    // 如果是窗帘
    if (self.settingButton.deviceType == SHDeviceButtonTypeCurtain) {
        
        self.curtainCloseLabel.hidden = NO;
        self.curtainOpenLabel.hidden = NO;
        self.curtainCloseChannel.hidden = NO;
        self.curtainOpenChannel.hidden = NO;
    }
}

@end
