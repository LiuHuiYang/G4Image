
//  UIDevice+IPAddresses.m

#import "UIDevice+IPAddresses.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

// ip字典信息中出现的的key

NSString *iOS_CELLULAR = @"pdp_ip0";

NSString *iOS_WIFI = @"en0";

NSString *iOS_VPN = @"utun0";

NSString *IP_ADDR_IPV4 = @"ipv4";

NSString *IP_ADDR_IPV6 = @"ipv6";


@implementation UIDevice (IPAddresses)

/**
 十进制ip字符串对应的数组

 @return 结果数组
 */
+ (NSArray *)ipAddressStringByDecimal {
    
    return [[self getIPAddress:YES] componentsSeparatedByString:@"."];
}

/**
 获得iPV4或者iPv6的地址

 @param isIPv4 是否为iPV4 (YES - ipv4, NO - ipV6)
 @return ip地址字符串
 */
+ (NSString *)getIPAddress:(BOOL)isIPv4 {

    // 初始化查询字典的key
    NSArray *searchKeyArray = isIPv4 ?
    @[
        [iOS_VPN stringByAppendingPathComponent:IP_ADDR_IPV4],
        [iOS_VPN stringByAppendingPathComponent:IP_ADDR_IPV6],
        [iOS_WIFI stringByAppendingPathComponent:IP_ADDR_IPV4],
        [iOS_WIFI stringByAppendingPathComponent:IP_ADDR_IPV6],
        [iOS_CELLULAR stringByAppendingPathComponent:IP_ADDR_IPV4],
        [iOS_CELLULAR stringByAppendingPathComponent:IP_ADDR_IPV6]
    ] :
    
    @[
       [iOS_VPN stringByAppendingPathComponent:IP_ADDR_IPV6],
       [iOS_VPN stringByAppendingPathComponent:IP_ADDR_IPV4],
       [iOS_WIFI stringByAppendingPathComponent:IP_ADDR_IPV6],
       [iOS_WIFI stringByAppendingPathComponent:IP_ADDR_IPV4],
       [iOS_CELLULAR stringByAppendingPathComponent:IP_ADDR_IPV6],
       [iOS_CELLULAR stringByAppendingPathComponent:IP_ADDR_IPV4]
    ];
    
    // 获得所有的ip地址
    NSDictionary *addresses = [self getIPAddresses];
    
    // 结果ip字符串
    __block NSString *address;
    
    // 遍历所有的结果
    [searchKeyArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         // 取出字典中的每一个结果
         address = addresses[key];
         
         // 筛选出可用的IP地址格式
         if([self isValidatIP:address]) {
             *stop = YES;
         }
     } ];
    
    // 返回最终的结果
    return address ? address : @"0.0.0.0";
}

/**
 ip地址是否可用
 
 @param ipAddress 指定的ip地址的字符串
 @return YES - 可用，NO - 不可用
 */
+ (BOOL)isValidatIP:(NSString *)ipAddress {
    
    // 地址无效
    if (ipAddress.length == 0) {
        return NO;
    }
    
    // 检验使用的正则表达式的字符串
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    
    // 转换成正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            
            // 匹配结果 -> 返回值 
            [ipAddress substringWithRange:resultRange];

            
            return YES;
        }
    }
    return NO;
}

/**
 获取所有相关IP信息
 
 @return 信息字典
 */
+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPV4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPV6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
