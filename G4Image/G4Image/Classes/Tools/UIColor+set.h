//
//  UIColor+set.h


#import <UIKit/UIKit.h>

@interface UIColor (set)



/**
 通过32位的hex值设置 UIColor*

 @param colorHex 颜色的hex表示 (去掉#直接填入)
 @param alpha 透明度
 @return UIColor *
 */
+ (UIColor *)cololrWithHex:(u_int32_t)colorHex alpa:(CGFloat)alpha;



/**
 生成随机颜色
 */
+ (UIColor *)colorWithRanddom;

@end
