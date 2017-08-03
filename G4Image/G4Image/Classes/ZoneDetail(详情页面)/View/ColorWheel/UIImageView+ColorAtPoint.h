//
//  UIImageView+ColorAtPoint.h
//  UIColorImage
//
//  Created by LHY on 2017/4/15.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ColorAtPoint)

/**
 获得图片中某个点的颜色
 
 @param point 点击的点
 @return UIColor
 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/**
 获得图片中某个点的颜色
 
 @param point 点击的点
 @return [red, green, blue, alpha]
 */
- (NSData *)dataWithColor:(CGPoint)point;


@end
