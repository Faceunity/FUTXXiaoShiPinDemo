//  Copyright © 2022 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

NS_ASSUME_NONNULL_BEGIN

LITEAV_EXPORT @interface TXPlayerGlobalSetting : NSObject

/**
 * 设置播放引擎的cache目录。设置后，预下载，播放器等会优先从此目录读取和存储。
 *
 * @discussion 设置播放器Cache缓存目录路径
 * @param  cacheFolder  缓存目录路径，nil 表示不开启缓存
 */
+ (void)setCacheFolderPath:(NSString *)cacheFolder;

/**
 * 获取设置的播放引擎的cache目录
 *
 * @discussion 返回播放器Cache缓存目录的Path
 * @return  返回 Cache缓存目录的Path
 */
+ (NSString *)cacheFolderPath;

/**
 * 设置播放引擎的最大缓存大小。设置后会根据设定值自动清理Cache目录的文件
 *
 * @discussion 设置播放器最大缓存的Cache Size大小（单位MB）
 * @param maxCacheSizeMB 最大缓存大小（单位：MB）
 */
+ (void)setMaxCacheSize:(NSInteger)maxCacheSizeMB;

/**
 * 获取设置的播放引擎的最大缓存大小
 *
 * @discussion 返回播放器最大缓存的Cache Size大小（单位M）
 * @return  返回 Cache Size的大小
 */
+ (NSInteger)maxCacheSize;

+ (id)getOptions:(NSNumber *)featureId;

/**
 * 开启播放器 License 柔性校验，开启后，在播放器首次启动后前2 次播放校验将默认通过
 *
 * @param value  --YES：开启柔性校验   --NO：关闭柔性校验
 */
+ (void)setLicenseFlexibleValid:(BOOL)value;

/**
 * 设置腾讯云PlayCGI主机地址列表
 *
 * @param hosts 要设置的主机地址列表，例如"playvideo.qcloud.com"。发起PlayCGI请求时依次使用传入的hosts地址，在某个host请求失败时自动切换到下个host重试请求。
 */
+ (void)setPlayCGIHosts:(NSArray<NSString *> *)hosts;

@end

NS_ASSUME_NONNULL_END
