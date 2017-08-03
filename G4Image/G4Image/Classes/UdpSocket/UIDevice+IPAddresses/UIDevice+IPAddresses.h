//
//  UIDevice+IPAddresses.h


#import <UIKit/UIKit.h>

@interface UIDevice (IPAddresses)


/**
 十进制ip字符串对应的数组(每个元素都是字符串)
 
 @return 结果数组
 */
+ (NSArray *)ipAddressStringByDecimal;

/**
 获得iPV4或者iPv6的地址字符串
 
 @param isIPv4 是否为iPV4 (YES - ipv4, NO - ipV6)
 @return ip地址字符串
 */
+ (NSString *)getIPAddress:(BOOL)isIPv4;

@end
