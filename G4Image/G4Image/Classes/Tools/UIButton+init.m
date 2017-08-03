//
//  UIButton+init.m



#import "UIButton+init.h"

@implementation UIButton (init)

/**
 实例化按钮

 @param imageName 常态图片名称
 @param hightlightedImageName 点击下的图片名称
 @param target 点击响应者
 @param action 响应事件
 @return 按钮
 */
+ (instancetype)buttonWithImageName:(NSString *)imageName hightlightedImageName:(NSString *)hightlightedImageName addTarget:(id)target action:(SEL)action {
    
    UIButton *button  = [[UIButton alloc] init];
    
    if (imageName) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    }
    
    if (hightlightedImageName) {
        [button setImage:[UIImage imageNamed:hightlightedImageName] forState:UIControlStateHighlighted];
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button sizeToFit];
    
    return button;
}


/**
 设置按钮的属性
 
 @param title 标题
 @param imageName 图片名称
 @param target 响应者
 @param action 响应事件
 @return 按钮本身
 */
- (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

@end
