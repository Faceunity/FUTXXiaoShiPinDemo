//  Copyright © 2022 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"
#import "TXPlayerAuthParams.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TXVodPreloadManagerDelegate <NSObject>

@optional

/**
 * 启动下载（此方法在换链成功以后，启动下载之前回调）
 *
 * @param taskID 下载任务ID
 * @param fileId 下载视频的 fileId。URL方式缓存时，此参数为nil
 * @param url 下载任务地址
 * @param param 附加参数
 */
- (void)onStart:(int)taskID fileId:(NSString *)fileId url:(NSString *)url param:(NSDictionary *)param;

/**
 * 下载完成回调
 *
 * @param taskID 下载任务ID
 * @param url 下载任务地址
 */
- (void)onComplete:(int)taskID url:(NSString *)url;

/**
 * 下载错误回调
 *
 * @param taskID 下载任务ID
 * @param url 下载任务地址
 * @param error 下载失败的错误信息
 */
- (void)onError:(int)taskID url:(NSString *)url error:(NSError *)error;

@end

LITEAV_EXPORT @interface TXVodPreloadManager : NSObject

/**
 * 获取视频预下载单列对象
 *
 *  @brief  播放器预下载管理类
 *  @discussion  播放器预下载管理类
 *  @return  返回播放器管理类对象
 */
+ (instancetype)sharedManager;

/**
 * 启动预下载
 * 【重要】启动预下载前，请先设置好播放引擎的缓存目录 [TXPlayerGlobalSetting  setCacheFolderPath: ]和缓存大小[ TXPlayerGlobalSetting setMaxCacheSizeMB:]，这个设置是全局配置需和播放器保持一致，否则会造成播放缓存失效。
 *
 * @param requestURL  预下载的URL
 * @param preloadSizeMB    预下载的大小（单位：MB）
 * @param preferredResolution  期望分辨率，long类型，取值如：从TXVodPlayConfig.VIDEO_RESOLUTION_720X1280，不支持多分辨率或不需指定时，传-1
 * @param delegate  回调
 * @return 任务ID，可用这个任务ID停止预下载 [ TXVodPreloadManager  stopPreload ]
 */
- (int)startPreload:(NSString *)requestURL preloadSize:(float)preloadSizeMB preferredResolution:(long)preferredResolution delegate:(id<TXVodPreloadManagerDelegate>)delegate;

/**
 * 启动预下载（此方法会阻塞调用线程）
 * 【重要】启动预下载前，请先设置好播放引擎的缓存目录 [TXPlayerGlobalSetting  setCacheFolderPath: ]和缓存大小[ TXPlayerGlobalSetting setMaxCacheSizeMB:]，这个设置是全局配置需和播放器保持一致，否则会造成播放缓存失效。
 *
 * @param params   预下载的视频数据
 * @param preloadSizeMB   预下载的大小（单位：MB）
 * @param preferredResolution  期望分辨率，long类型，取值如：从TXVodPlayConfig.VIDEO_RESOLUTION_720X1280，不支持多分辨率或不需指定时，传-1
 * @param delegate  回调
 * @return 任务ID，可用这个任务ID停止预下载 [ TXVodPreloadManager  stopPreload ]
 */
- (int)startPreloadWithModel:(TXPlayerAuthParams *)params preloadSize:(float)preloadSizeMB preferredResolution:(long)preferredResolution delegate:(id<TXVodPreloadManagerDelegate>)delegate;

/**
 *  停止预下载。
 *
 * @discussion  根据 ‘taskID’ 停止预下载
 * @param taskID 任务ID。ID从{@link TXVodPreloadManager#startPreload}返回值得到。
 */
- (void)stopPreload:(int)taskID;

@end

NS_ASSUME_NONNULL_END
