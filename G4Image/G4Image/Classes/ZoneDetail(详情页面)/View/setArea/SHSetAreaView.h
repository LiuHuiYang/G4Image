//
//  SHSetAreaView.h
//  G4Image
//
//  Created by LHY on 2017/6/2.
//  Copyright © 2017年 LHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHSetAreaViewDelegate <NSObject>

@optional

/// 获得区域图片的回调
- (void)setAreaViewPictureForZone:(UIImage *)image;

/// 删除区域
- (void)setAreaViewDeleteZone;

/// 控制区域中的设备列显示
- (void)setAreaViewShowDeviceList:(UIButton *)deviceButton;

@end

@interface SHSetAreaView : UIView

/// 代理
@property (weak, nonatomic) id<SHSetAreaViewDelegate> delegate;


/// 返回固定的大小
+ (CGSize)areaViewSize;

/// 实例化设置界面
+ (instancetype)setAreaView;

@end
