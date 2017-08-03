//
//  SHColorWheelView.h
//  SmartHomeColorWheel
//
//  Created by LHY on 2017/4/16.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHColorWheelViewDelegate <NSObject>

@optional

/**
 设置区域颜色
 */
- (void)setZonesColor:(UIColor *)color;


/**
 设置区域颜色
 */
- (void)setZonesColorData:(NSData *)colorData recognizer:(UIGestureRecognizer *)recognizer;

@end

@interface SHColorWheelView : UIView

/**
 代理
 */
@property (nonatomic, weak) id<SHColorWheelViewDelegate> delegate;

@end
