//
//  UIBarButtonItem+init.m


#import "UIBarButtonItem+init.h"
#import "UIButton+init.h"

@implementation UIBarButtonItem (init)

/**
实例BarButtonItem(如果不需要点击事件 参数使用 nil)

@param imageName 常态图片名称
@param hightlightedImageName 点击下的图片名称
@param target 点击响应者
@param action 响应事件
@return UIBarButtonItem
*/
+ (instancetype)barButtonItemWithImageName:(NSString *)imageName hightlightedImageName:(NSString *)hightlightedImageName addTarget:(id)target action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithImageName:imageName hightlightedImageName:hightlightedImageName addTarget:target action:action];
    
    button.frame_width = button.frame_width * 0.6;
    button.frame_height = button.frame_width;
               
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return item;
}


/**
 创建UIBarButtonItem

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
+ (instancetype)barButtonItemTitle:(NSString *)title font:(UIFont *)font normalTextColor:(UIColor *)normalTextColor highlightedTextColor:(UIColor *)highlightedTextColor  imageName:(NSString *)imageName hightlightedImageName:(NSString *)hightlightedImageName addTarget:(id)target action:(SEL)action {

    
    // 创建按钮
    UIButton *button = [UIButton buttonWithImageName:imageName hightlightedImageName:hightlightedImageName addTarget:target action:action];
    
    // 设置文字
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:normalTextColor forState:UIControlStateNormal];
    [button setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
    
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    [button sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
