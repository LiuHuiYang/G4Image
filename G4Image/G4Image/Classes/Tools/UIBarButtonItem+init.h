//
//  UIBarButtonItem+init.h


#import <UIKit/UIKit.h>

@interface UIBarButtonItem (init)

/**
 实例BarButtonItem(如果不需要点击事件 参数使用 nil)
 
 @param imageName 常态图片名称
 @param hightlightedImageName 点击下的图片名称
 @param target 点击响应者
 @param action 响应事件
 @return UIBarButtonItem
 */
+ (instancetype)barButtonItemWithImageName:(NSString *)imageName hightlightedImageName:(NSString *)hightlightedImageName addTarget:(id)target action:(SEL)action;


/**
 创建UIBarButtonItem(如果创建移动位置的返回，请将实现代码的注释打开，并修改参数)
 
 @param title 标题
 @param font 字体
 @param normalTextColor 颜色
 @param highlightedTextColor 高亮颜色
 @param imageName 图片
 @param hightlightedImageName 高亮图片
 @param target 响应
 @param action 事件
 @return item
 */
+ (instancetype)barButtonItemTitle:(NSString *)title font:(UIFont *)font normalTextColor:(UIColor *)normalTextColor highlightedTextColor:(UIColor *)highlightedTextColor  imageName:(NSString *)imageName hightlightedImageName:(NSString *)hightlightedImageName addTarget:(id)target action:(SEL)action;

@end
