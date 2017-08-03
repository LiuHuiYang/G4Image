//
//  SHAnalyDeviceData.h
//  G4Image
//
//  Created by LHY on 2017/4/26.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHAnalyDeviceData : NSObject

/// 解析所有的数据
+ (void)analyDeviceData:(NSData *)data inZone:(SHZone *)zone;




@end
