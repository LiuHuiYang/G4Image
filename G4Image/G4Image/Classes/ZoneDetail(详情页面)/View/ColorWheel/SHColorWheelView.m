//
//  SHColorWheelView.m
//  SmartHomeColorWheel
//
//  Created by LHY on 2017/4/16.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHColorWheelView.h"
#import "UIImageView+ColorAtPoint.h"

// 360度
const CGFloat Circle = 360.0;


@interface SHColorWheelView ()

/// 内部绘制出来的图片
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation SHColorWheelView


/// 布局时才切圆角
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setFillet];
}

// MARK: - 实例化加载手势

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        // 增加手势
        [self addGestureRecognizers];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // 此时，frame是没有值的 所以不要在这里切角
        // 增加手势
        [self addGestureRecognizers];
        
    }
    return self;
}

/// 切成圆角
- (void)setFillet {
    
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    self.layer.mask = maskLayer;
}

/// 增加手势
- (void)addGestureRecognizers {
    
    // 1.点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectColor:)];
    [self addGestureRecognizer:tap];
    
    // 2.拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    [self addGestureRecognizer:pan];
    
    [tap requireGestureRecognizerToFail:pan];
}

#pragma mark - 手势的方法

- (void)changeColor:(UIPanGestureRecognizer *)recognizer {
        
    // 获取点击的控件
    UIImageView *view = (UIImageView *)recognizer.view;
    
    // 获得移动了坐标
    CGPoint point = [recognizer locationInView:view];
    
    // 获得颜色
//    UIColor *color = [self.iconView colorAtPixel:point];
    
    
    //  因为拖动起来一直是在递增，所以每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [recognizer setTranslation:CGPointZero inView:view];
    
    // 执行代理
//    if ([self.delegate respondsToSelector:@selector(setZonesColor:)]) {
//        [self.delegate setZonesColor:color];
//    }
    
    if ([self.delegate respondsToSelector:@selector(setZonesColorData:recognizer:)]) {
        [self.delegate setZonesColorData:[self.iconView dataWithColor:point] recognizer:recognizer];
    }
}


- (void)selectColor:(UITapGestureRecognizer *)recognizer {
    
    // 获取点击的控件
    UIImageView *view = (UIImageView *)recognizer.view;
    
    // 获得移动了坐标
    CGPoint point = [recognizer locationInView:view];
    
    // 获得颜色
//    UIColor *color = [self.iconView colorAtPixel:point];
    
    // 执行代理
//    if ([self.delegate respondsToSelector:@selector(setZonesColor:)]) {
//        [self.delegate setZonesColor:color];
//    }
    
    if ([self.delegate respondsToSelector:@selector(setZonesColorData:recognizer:)]) {
        [self.delegate setZonesColorData:[self.iconView dataWithColor:point] recognizer:recognizer];
    }
}

/// 绘制配色卡(系统自动调用)
- (void)drawRect:(CGRect)rect {
    
    // 设置半径
    CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.48;
    CGFloat maxRadius = MIN(rect.size.width, rect.size.height) * 0.5;

    // 设置角度
    CGFloat angle = 2 * (M_PI) / Circle;
    
    // 设置中心点
    CGPoint center = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
    
    // 开启图形上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    
    /***********************去除整背景颜色*****************************/
    
    // 图片的背景颜色
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    /***********************外围区域的白色*****************************/
    
    // 绘制白色的线条
    UIBezierPath* whitePath = [UIBezierPath bezierPathWithArcCenter:center radius:maxRadius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [whitePath setLineWidth:maxRadius - radius];
    [whitePath addLineToPoint:center];
    [whitePath closePath];

    // 绘制颜色
    [[UIColor whiteColor] setFill];
    [[UIColor whiteColor] setStroke];
    
    [whitePath fill];
    [whitePath stroke];
    
    /***********************绘制区域中彩虹*****************************/
   
    // 开始绘制点
    for (NSUInteger i = 0; i <= (NSUInteger)Circle; i++) {
        
        // 绘制路径
        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:i * angle endAngle:(i + 1) * angle clockwise:YES];
        
        [path addLineToPoint:center];
        
        [path closePath];
        
        // 绘制颜色
        UIColor *color = [UIColor colorWithHue:i / Circle saturation:1 brightness:1 alpha:1];
        [color setFill];
        [color setStroke];
        
        [path fill];
        [path stroke];
        
    }

    // 取出图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();

    self.iconView = [[UIImageView alloc] initWithImage:image];
    self.iconView.bounds = self.bounds;
    self.iconView.userInteractionEnabled = YES;
    
    // 添加到父控件上
    [self addSubview:self.iconView];
    
}

@end
