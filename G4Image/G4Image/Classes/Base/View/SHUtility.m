//
//  SHUtility.m
//  G4Image
//
//  Created by Firas on 1/13/14.
//  Copyright (c) 2014 SH. All rights reserved.
//

#import "SHUtility.h"

// 图片文件夹
NSString * zoneImageFloderName = @"SmartImageForZones";

@interface SHUtility ()

@end

@implementation SHUtility


+ (void)deleteImageFromDocment:(UInt16)zoneID {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [searchPaths objectAtIndex:0];
    NSString *pathWithFolderAndName = [NSString stringWithFormat:@"%@/%@/imageByZoneID_%d",documentsPath,zoneImageFloderName, zoneID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathWithFolderAndName])
    {
        //  如果有了，先删除，
        [[NSFileManager defaultManager] removeItemAtPath:pathWithFolderAndName error:nil];
    }
}


/**
 将数据写入到沙盒中去
 */
+ (void)writeImageToDocment:(UInt16)zoneID data:(UIImage *)image {
    
    // 获得图片文件夹的内容
    NSString *pathWithFolder = [[FileTools documentPath] stringByAppendingPathComponent:zoneImageFloderName];
    
    // 如果文件夹不存在就创建，否则继承
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathWithFolder]) {
        
        // 创建一个
        [[NSFileManager defaultManager] createDirectoryAtPath:pathWithFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 获得图片名称
    NSString *pathWithFolderAndName = [NSString stringWithFormat:@"%@/imageByZoneID_%d",pathWithFolder,zoneID];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathWithFolderAndName])
    {
        // 直接写入
        [UIImagePNGRepresentation(image) writeToFile: pathWithFolderAndName  atomically:YES];
        
    } else {
        //  如果有了，先删除
        [[NSFileManager defaultManager] removeItemAtPath:pathWithFolderAndName error:nil];
        
        [UIImagePNGRepresentation(image) writeToFile: pathWithFolderAndName    atomically:YES];
    }
}

+ (UIImage *)getImageForZones:(UInt16)shortZoneID {
    // 获得图片文件夹的内容
    NSString *pathWithFolder = [[FileTools documentPath] stringByAppendingPathComponent:zoneImageFloderName];
    
    // 如果文件夹不存在就创建，否则继承
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathWithFolder]) {
        
        // 创建一个
        [[NSFileManager defaultManager] createDirectoryAtPath:pathWithFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 获得图片名称
    NSString *pathWithFolderAndName = [NSString stringWithFormat:@"%@/imageByZoneID_%d",pathWithFolder,shortZoneID];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathWithFolderAndName]) {
        
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:pathWithFolderAndName]];
    }
    
    return nil;
}


+ (NSString *)getDocmetnPathAndImagLib
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [searchPaths objectAtIndex:0];
    NSString *pathWithFolder = [NSString stringWithFormat:@"%@/%@",documentsPath, zoneImageFloderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathWithFolder])
    {
        SHLog(@"对应文件夹不存在，先创建文件夹，再写入数据");
        
        
        [[NSFileManager defaultManager] createDirectoryAtPath:pathWithFolder withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    return documentsPath;
}


+ (BOOL)isMember {
    BOOL result = NO;
    NSString *mobile = [[NSUserDefaults standardUserDefaults] objectForKey:@"mobile"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    if ((mobile != nil && ![mobile isEqualToString:@""]) || (email != nil && ![email isEqualToString:@""])) {
        result = YES;
    }
    return result;
}



+ (BOOL)matchPhone:(NSString *)accountStr {
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    if (![phoneTest evaluateWithObject:accountStr] && [accountStr compare:@""] != NSOrderedSame){
        return NO;
    }
    return YES;
}

+ (BOOL)matchEmail:(NSString *)accountStr {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF matches %@", @"^[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]\\.[a-zA-Z][a-zA-Z\\.]*[a-zA-Z]$"];
    if (![regex evaluateWithObject:accountStr] && [accountStr compare:@""] != NSOrderedSame){
        return NO;
    }
    return YES;
}

@end
