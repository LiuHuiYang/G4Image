//
//  UIImage+Rotate.h
//  G4Image
//
//  Created by LHY on 2017/4/27.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotate)

/// 处理图片的自动旋转（从相片或相机中获取的图片会自动旋转90度处理类方法）
+ (UIImage *)fixOrientation:(UIImage *)sourceImage;

/// 指定宽度绘制等比例的新图片
+ (UIImage *)darwNewImage:(UIImage *)image width:(CGFloat)width;

@end
