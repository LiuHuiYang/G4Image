/**
    1.用于封装清除缓存的方法
    2.获得沙盒的路径
    3.保存账号与密码
 */

#import <UIKit/UIKit.h>
 

@interface FileTools : NSObject

/**
 获得当前应用的名称
 */
+ (NSString *)appName;

/**
 存储标志
 
 @param flag 记录的标志
 @param key 标志对应的记号
 */
+ (void)saveFlag:(BOOL)flag :(NSString *)key;

/**
 获取指定记号的值
 
 @param key 记号
 @return 值
 */
+ (BOOL)getFlag:(NSString *)key;

/**
 获得文件夹中内容的大小

 @param directoryPath 需要获取的文件夹(不能是文件)
 @param completion 获取的回调
 */
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger totalFileSize))completion;


/**
 删除文件夹中所有的内容(不包含隐藏文件 .DS)

 @param directoryPath 需要获取的文件夹(不能是文件)
 */
+ (void)removeDirectoryPath:(NSString *)directoryPath;


/**
 获得缓存大小的字符串
 
 @param totalSize 获取的大小
 @return 对应的字符串
 */
+ (NSString *)getFileSizeStr:(NSInteger)totalSize;

/**
 应用的主目录
 */
+ (NSString *)homePath;

/**
 应用的路径
 */
+ (NSString *)appPath;

/**
 沙盒 document文档 的路径
 */
+ (NSString *)documentPath;

/**
 偏好设置 -- 开发中使用这种方式
 */
+ (NSUserDefaults *)defaults;

/**
 沙盒Preference的路径
 */
+ (NSString *)libPreferencePath;


/**
 沙盒Cache的路径
 */
+ (NSString *)libCachePath;

/**
 临时文件夹
 */
+ (NSString *)tmpPath;

@end
