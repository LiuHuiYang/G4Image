//
//  UIColor+set.m


#import "UIColor+set.h"

@implementation UIColor (set)

/**
 通过32位的hex值设置 UIColor*
 
 @param colorHex 颜色的hex表示 (去掉#直接填入)
 @param alpha 透明度
 @return UIColor *
 */
+ (UIColor *)cololrWithHex:(u_int32_t)colorHex alpa:(CGFloat)alpha {
    
    //  255 255 255 ==  #0x ff ff ff
    // 获得各种颜色
    NSUInteger red = (colorHex & 0xFF0000) >> 16;
    NSUInteger green = (colorHex & 0x00FF00) >> 8;
    NSUInteger blue = colorHex & 0x0000FF;
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

/**
 生成随机颜色
 */
+ (UIColor *)colorWithRanddom {
    
    return [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
}
@end
