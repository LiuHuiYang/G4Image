/*
 
 封装说明:
 1.直接将UdpSocket这个文件夹中的所有内容全部拖入项目中就可以使用
 2.这个工具是基于线程安全的单例
 3.需要设置代理
 4.代理的回调只会把接收到的完整数据从SN2开始的二进制数据返回，不是全部返回。
 
 */

#import "SHUdpSocket.h"
#import "UIDevice+IPAddresses.h"
#import "GCDAsyncUdpSocket.h"


//----------相关的终端参数（暂时不变）----------------

// 目标地址
NSString *server_IP = @"255.255.255.255";

// 绑定端口
const UInt16 server_PORT = 6000;

// 最后收到的最小有效数据长度
const NSUInteger reciveDataLenght = 27;

// 源终端子网ID
const Byte originalSubnetID = 0XBB;

// 源终端设备ID
const Byte originalDeviceID = 0XBB;

// 源终端设备类型
const UInt16 originalDeviceType = 0XCCCC;

/**
 获得CRC
 */
void pack_crc(Byte *ptr, unichar len);

@interface SHUdpSocket () <GCDAsyncUdpSocketDelegate>

/**
 内容使用的通信socket
 */
@property(nonatomic,strong)GCDAsyncUdpSocket *socket;

/**
 上一条数据(为了过滤区重复的数据，根据实现代码来决定是否使用)
 */
@property (strong, nonatomic) NSMutableData *previousReceiveData;

/**
 返回的操作码
 */
@property (assign, nonatomic) UInt16 operatorCodeForRecive;

/**
 每次发起的操作码
 */
@property (assign, nonatomic) UInt16 operatorCode;

@property (assign, nonatomic) BOOL reSend;

@end

@implementation SHUdpSocket

#pragma mark - 代理回调

/**
 接收到服务器返回的数据
 
 @param sock socket
 @param data 接收的数扰
 @param address 地址信息
 @param filterContext 过滤上下文
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    // 1.达到最低长度的字节
    if (data.length < reciveDataLenght) {
        return;
    }
    
    // 2.相同的数据只要一条
    if ([self.previousReceiveData isEqualToData:data]) {
        return;
    }
    // 记录上条的数据
    self.previousReceiveData = [NSMutableData dataWithData:data];
    
    // 3.只要SN2(包括)以后的内容 (总长度 - 16) (源IP + 协议头 + 开始的操作码统统不要)
    // 不需要前面的数据长度
    const NSUInteger subLength = 16;
    
    // 取得最后需要的数据
    NSData *sendData = [NSData dataWithBytes:(((Byte *) [data bytes]) + subLength) length:data.length - subLength];
    
    // 获得操作码
    Byte *recivedData = ((Byte *) [sendData bytes]);
    UInt16 operatorCodeForRecive =  ((recivedData[5] << 8) | recivedData[6]);
    self.operatorCodeForRecive = operatorCodeForRecive;
    if (operatorCodeForRecive == self.operatorCode + 1) {
        self.reSend = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(analyzeReceiveData:)]) {
        [self.delegate analyzeReceiveData:sendData];
    }
}

/**
 socket关闭
 */
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    
    SHLog(@"socket关闭");
    [self.socket close];
    self.socket = nil;
    
    //    [MBProgressHUD showError:@"socket closed"];
    
    //    [self.socket localHost];
    [self.socket enableBroadcast:YES error:&error];
}


#pragma mark - 发送指令

/**
 发送控制器数据
 
 @param operatorCode 操作码(查询文档)
 @param targetSubnetID 目标设备ID (联网查询可得)
 @param targetDeviceID 目标子网ID (联网查询可得)
 @param additionalContentData 可变参数二进制
 @param needReSend 是否启动重发机制
 */
- (void)sendDataWithOperatorCode:(UInt16)operatorCode targetSubnetID:(Byte)targetSubnetID targetDeviceID:(Byte)targetDeviceID additionalContentData:(NSMutableData *)additionalContentData needReSend:(BOOL)needReSend {
    
    // 1.先直接发送数据(不管是否启动重发机制)
    [self sendDataWithOperatorCode:operatorCode targetSubnetID:targetSubnetID targetDeviceID:targetDeviceID additionalContentData:additionalContentData];
    
    // 不启动重发机制就停止
    if (!needReSend) {
        self.reSend = NO;
        return;
    }
    self.reSend = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self sendDataWithOperatorCode:operatorCode targetSubnetID:targetSubnetID targetDeviceID:targetDeviceID additionalContentData:additionalContentData];
    });
}


/**
 发送控制器数据
 
 @param operatorCode 操作码(查询文档)
 @param targetSubnetID 目标设备ID (联网查询可得)
 @param targetDeviceID 目标子网ID (联网查询可得)
 @param additionalContentData 可变参数二进制
 */
- (void)sendDataWithOperatorCode:(UInt16)operatorCode targetSubnetID:(Byte)targetSubnetID targetDeviceID:(Byte)targetDeviceID additionalContentData:(NSMutableData *)additionalContentData {
    
    // 每次发送数据前都应该检查一下，当前的socket是否可用。(下面会调用sokcet会调用getter)
    
    // ----------------直接发送数据----------------
    
    // 1.协议的前半部分
    // 1.1 获得源设备的IP
    NSArray *ipArray = [UIDevice ipAddressStringByDecimal];
    
    // 发1.2 送协议的数据包头  数据包的下标 4 ~ 13 是协议头，固定 udpPckageHead数组
    const Byte udpPckageHeadArray[] = {0x53, 0x4D, 0x41, 0x52, 0x54, 0x43, 0x4C, 0x4F, 0x55, 0x44};
    
    // 2.发送指令的长度
    
    // 2.1 UDP Package Head + SoureceIP
    const NSUInteger protocolPackageAndSourceIPLength = ipArray.count + sizeof(udpPckageHeadArray);
    
    // 2.2.1 CRC 校验码长度(字节)
    const NSUInteger cRCLength = 2;
    
    // 2.2.2 可变参数的长度
    const NSUInteger additionalContentLength = [additionalContentData length];
    
    // 2.3 Protocol Base Structure 协议数据包的长度 (固定部分11 + additionalContent + CRC)
    NSUInteger protocolBaseStructureLength = 11 + additionalContentLength + cRCLength;
    
    // 2.4 数据包的总大小
    NSUInteger sendUDPBufLength = protocolPackageAndSourceIPLength + protocolBaseStructureLength;
    
    //3. 声明发送数据包
    Byte maraySendUDPBuf[sendUDPBufLength];
    
    // 4.输入数据
    
    // 设置索引
    NSUInteger index = 0;
    
    // 4.1.输入源设备的IP
    while (index < ipArray.count) {
        // 赋值ip地址
        maraySendUDPBuf[index++] = [ipArray[index] integerValue] & 0XFF;
    }
    
    // 4.2  协议头 固定 udpPckageHead数组
    for (NSUInteger i = 0; i  < sizeof(udpPckageHeadArray); i++) {
        maraySendUDPBuf[index++] = udpPckageHeadArray[i];
    }
    
    // 5.Protocol Base Structure 部分
    
    // 5.1 开始代码: 0XAAAA固定
    maraySendUDPBuf[index++] = 0xAA;
    maraySendUDPBuf[index++] = 0xAA;
    
    // 5.2 数据包的长度  -- 计算(SN2 ~ 10)
    maraySendUDPBuf[index++] = (protocolBaseStructureLength - 2) & 0XFF; // -2 是不含 SN1的内容
    
    // 5.3 .1 手机的子网ID
    maraySendUDPBuf[index++] = originalSubnetID & 0XFF;
    // 5.3.2 手机的设备ID
    maraySendUDPBuf[index++] = originalDeviceID & 0XFF;
    
    // 5.4 设备类型
    maraySendUDPBuf[index++] = (originalDeviceType >> 8) & 0XFF;
    maraySendUDPBuf[index++] = (originalDeviceType & 0XFF);
    
    // 5.5 操作码
    // 高8位
    maraySendUDPBuf[index++] = (operatorCode >> 8) & 0XFF;
    // 低8位
    maraySendUDPBuf[index++] = (operatorCode & 0XFF);
    
    // 5.6 目标设备的子网ID与设备ID
    
    // 5.6.1 目标设备的子网ID -- 如何获取? 变化的
    maraySendUDPBuf[index++] = targetSubnetID & 0XFF;
    // 4.6.2 目标设备的设备ID -- 如何获取?
    maraySendUDPBuf[index++] = targetDeviceID & 0XFF;
    
    // 5.7 可变参数 -- 查表
    for (NSUInteger i = 0; i < additionalContentLength; i++) {
        maraySendUDPBuf[index++] = (((Byte *)[additionalContentData bytes])[i]) & 0XFF;
    }
    
    // 5.8 校验码  -- 由CRC算法来生成
    // 方法说明
    // 第一个参数：整个数据包的中Protocol Base Structure部分的LEN of Data Package的地址
    // 第二个参数：从【Protocol Base Structure】数据的总大小 - CRC的两个字节(cRCLength) - Start code的大小(2个字节)
    pack_crc(&(maraySendUDPBuf[protocolPackageAndSourceIPLength + 2]), protocolBaseStructureLength - 2 - cRCLength);
    
    // 6.发送数据
    // 6.1  准备数据
    NSData *sendMessageData = [[NSData alloc] initWithBytes:maraySendUDPBuf length:sizeof(maraySendUDPBuf)];
    
    // 6.2 发送
    // 暂时不使用超时操作，这个方法不能用于连接已接了的socket
    
    // UDP通信永远是不连接的所以用下面的方法来发送
    [self.socket sendData:sendMessageData toHost:server_IP port:server_PORT withTimeout:-1 tag:0];
    // 接收数据
    [self.socket beginReceiving:nil];
}

#pragma mark - CRC校验码的获取列表与方法 -- 直接使用，不需要修改

// CRC 校验码查询数据的数组表格
const UInt16  CRC_TAB[] = {           /* CRC tab */
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
    0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
    0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
    0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
    0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
    0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
    0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
    0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
    0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
    0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
    0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
    0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
    0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
    0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
    0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
    0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
    0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
    0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
    0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
    0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
    0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
    0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
    0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
    0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
    0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
    0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
    0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
    0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
    0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
    0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
};


/**
 获得CRC
 
 @param ptr 结果地址: 是基础协议数据包中除了0XAAAA后开始的地址
 @param len 长度: ptr所对应的地址开始的数组再-2个字节（不要CRC的2个字节）
 */
void pack_crc(Byte *ptr, unichar len) {
    
    // 准备两个字节来存储 CRC
    unsigned short crc = 0;
    
    // 中间临时变量存储
    Byte dat = 0;
    
    while(len-- != 0) {  // 长度有效
        
        // CRC 高字节的内容
        dat = crc >> 8;
        
        // CRC 低字节的内容
        crc <<= 8;
        
        // 获得查询表中的内容
        crc ^= CRC_TAB[dat ^ *ptr];
        
        ptr++;
    }
    
    // 分别返回两个结果
    *ptr = crc >> 8;
    
    // 移位
    ptr++;
    
    // 赋值
    *ptr = crc;
}

#pragma mark - 初始化 - 端口

- (instancetype)init {
    if (self = [super init]) {
        [self.socket localPort];
    }
    return self;
}

/**
 初始化socket
 */
- (GCDAsyncUdpSocket *)socket {
    
    if (!_socket) {
        
        // 初始化
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 设置代理
        _socket.delegate = self;
        
        // 打开广播功能
        if (![_socket enableBroadcast:YES error:nil]) {
            // 开启失败
            return nil;
        }
        
        // 绑定端口接收数据
        if (![_socket bindToPort:server_PORT error:nil]) {
            return nil;
        }
        
        // 接收数据
        if (![_socket beginReceiving:nil]) {
            return nil;
        }
    }
    return _socket;
}


/**
 过滤数据 （保证外界访问时已经有值）
 */
- (NSMutableData *)previousReceiveData {
    
    if (!_previousReceiveData) {
        _previousReceiveData = [NSMutableData data];
    }
    return _previousReceiveData;
}



#pragma mark - 单例代码

SingletonImplementation(SHUdpSocket)

@end
