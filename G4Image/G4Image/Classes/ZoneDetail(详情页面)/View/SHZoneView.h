//
//  SHZoneShowView.h
//  G4Image
//
//  Created by LHY on 2017/4/6.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHZoneView : UIView

/// 内部的滚动视图
@property (strong,nonatomic) UIScrollView *scrollView;

/// 设置区域图片
- (void)setImageForZone:(UIImage *)sourceImge scale:(CGFloat)scale;

@end
