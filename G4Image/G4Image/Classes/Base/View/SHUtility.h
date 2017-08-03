//
//  SHUtility.h
//  G4Image
//
//  Created by Firas on 1/13/14.
//  Copyright (c) 2014 SH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHUtility : NSObject


+ (void)writeImageToDocment:(UInt16)zoneID data:(UIImage *)image;
+ (UIImage *)getImageForZones:(UInt16)zoneID;
+ (void)deleteImageFromDocment:(UInt16)zoneID;


+ (NSString *)getDocmetnPathAndImagLib;



+ (BOOL)isMember;//是否是会员

+ (BOOL)matchPhone:(NSString *)accountStr;//验证手机号码格式
+ (BOOL)matchEmail:(NSString *)accountStr;//验证邮箱地址格式


@end
