/*

 封装说明:
    1.直接将UdpSocket这个文件夹中的所有内容全部拖入项目中就可以使用
    2.这个工具是基于线程安全的单例
    3.需要设置代理
    4.代理的回调只会把接收到的完整数据从SN2开始的二进制数据返回，不是全部返回。
 
 */

#import <Foundation/Foundation.h>
#import "Singleton.h"

@protocol SHUdpSocketDelegate <NSObject>

@optional

/**
 解析数据
 @param data 需要解析的数据
 */
- (void)analyzeReceiveData:(NSData *)data;

@end

@interface SHUdpSocket : NSObject


/**
 解析的数据代理
 */
@property (nonatomic, weak) id<SHUdpSocketDelegate> delegate;


/**
 发送控制器数据
 
 @param operatorCode 操作码(查询文档)
 @param targetSubnetID 目标设备ID (联网查询可得)
 @param targetDeviceID 目标子网ID (联网查询可得)
 @param additionalContentData 可变参数二进制
 @param needReSend 是否启动重发机制
 */
- (void)sendDataWithOperatorCode:(UInt16)operatorCode targetSubnetID:(Byte)targetSubnetID targetDeviceID:(Byte)targetDeviceID additionalContentData:(NSMutableData *)additionalContentData needReSend:(BOOL)needReSend;

SingletonInterface(SHUdpSocket)

@end
