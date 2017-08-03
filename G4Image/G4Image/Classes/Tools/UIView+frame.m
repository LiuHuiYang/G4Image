//
//  UIView+frame.m
//

#import "UIView+frame.h"

@implementation UIView (frame)

- (void)setFrame_x:(CGFloat)frame_x {
    CGRect frame = self.frame;
    frame.origin.x = frame_x;
    self.frame = frame;
}

- (CGFloat)frame_x {
    return self.frame.origin.x;
}

- (void)setFrame_y:(CGFloat)frame_y {
    CGRect frame = self.frame;
    frame.origin.y = frame_y;
    self.frame = frame;
}

- (CGFloat)frame_y {
    return self.frame.origin.y;
}


- (void)setFrame_width:(CGFloat)frame_width {
    CGRect frame = self.frame;
    frame.size.width = frame_width;
    self.frame = frame;
}

- (CGFloat)frame_width {
    return self.frame.size.width;
}


- (void)setFrame_height:(CGFloat)frame_height {
    CGRect frame = self.frame;
    frame.size.height = frame_height;
    self.frame = frame;
}

- (CGFloat)frame_height {
    return self.frame.size.height;
}


- (void)setFrame_CenterX:(CGFloat)frame_CenterX {
    CGPoint center = self.center;
    center.x = frame_CenterX;
    self.center = center;
}

- (CGFloat)frame_CenterX {
    return self.center.x;
}


- (void)setFrame_CenterY:(CGFloat)frame_CenterY {
    CGPoint center = self.center;
    center.y = frame_CenterY;
    self.center = center;
}

- (CGFloat)frame_CenterY {
    return self.center.y;
}


+ (CGFloat)frame_ScreenHeiht {
    return [UIScreen mainScreen].bounds.size.height;
}


+ (CGFloat)frame_ScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

@end
