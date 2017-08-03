//
//  UIImage+Path.h
//  G4Image
//
//  Created by LHY on 2017/7/25.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Path)

+ (void)writeImageToDocment:(UInt16)zoneID data:(UIImage *)image;
+ (UIImage *)getImageForZones:(UInt16)zoneID;
+ (void)deleteImageFromDocment:(UInt16)zoneID;

+ (NSString *)getDocmetnPathAndImagLib;

@end
