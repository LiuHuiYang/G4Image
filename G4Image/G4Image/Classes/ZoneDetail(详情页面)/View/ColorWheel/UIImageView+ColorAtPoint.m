//
//  UIImageView+ColorAtPoint.m
//  UIColorImage
//
//  Created by LHY on 2017/4/15.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "UIImageView+ColorAtPoint.h"

@implementation UIImageView (ColorAtPoint)

/**
 获得图片中某个点的颜色
 
 @param point 点击的点
 @return [red, green, blue, alpha]
 */
- (NSData *)dataWithColor:(CGPoint)point {
    
    Byte pixelData[4] = { 0, 0, 0, 0 };
    
    // 如果这个点在图片中
    if (CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
        
        NSInteger pointX = trunc(point.x);
        NSInteger pointY = trunc(point.y);
        CGImageRef cgImage = self.image.CGImage;
        NSUInteger width = self.image.size.width;
        NSUInteger height = self.image.size.height;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        int bytesPerPixel = 4;
        int bytesPerRow = bytesPerPixel * 1;
        NSUInteger bitsPerComponent = 8;
        
        
        
        CGContextRef context = CGBitmapContextCreate(pixelData,
                                                     1,
                                                     1,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
        // Draw the pixel we are interested in onto the bitmap context
        CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
        CGContextRelease(context);
        
    }
    
    return [NSData dataWithBytes:pixelData length:sizeof(pixelData)];
}


/**
 获得图片中某个点的颜色
 
 @param point 点击的点
 @return UIColor
 */
- (UIColor *)colorAtPixel:(CGPoint)point {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.image.CGImage;
    NSUInteger width = self.image.size.width;
    NSUInteger height = self.image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    Byte red   = pixelData[0];
    Byte green = pixelData[1];
    Byte blue  = pixelData[2];
    Byte alpha = pixelData[3];
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:alpha];
    
}

@end
