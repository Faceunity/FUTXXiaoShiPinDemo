/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Author: ianyanzhang
 */
#import <Foundation/Foundation.h>
#import "TXPlayerAuthParams.h"
#import "TXLiteAVSymbolExport.h"
#import "TXPlayerDrmBuilder.h"
#import "TXVodDownloadDataSource.h"
#import "TXVodDownloadMediaInfo.h"

/**
 * 下载错误码
 */
typedef NS_ENUM(NSInteger, TXDownloadError) {

    /// 下载成功
    TXDownloadSuccess = 0,

    /// fileid鉴权失败
    TXDownloadAuthFaild = -5001,

    /// 无此清晰度文件
    TXDownloadNoFile = -5003,

    /// 格式不支持
    TXDownloadFormatError = -5004,

    /// 网络断开
    TXDownloadDisconnet = -5005,

    /// 获取HLS解密key失败
    TXDownloadHlsKeyError = -5006,

    /// 下载目录访问失败
    TXDownloadPathError = -5007,

    /// 鉴权信息不通过，如签名过期或者请求不合法
    TXDownload403Forbidden = -5008,
};

@protocol TXVodDownloadDelegate <NSObject>

/**
 * 下载开始
 */
- (void)onDownloadStart:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载进度
 */
- (void)onDownloadProgress:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载停止
 */
- (void)onDownloadStop:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载完成
 */
- (void)onDownloadFinish:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载错误
 */
- (void)onDownloadError:(TXVodDownloadMediaInfo *)mediaInfo errorCode:(TXDownloadError)code errorMsg:(NSString *)msg;

/**
 * 下载HLS，遇到加密的文件，将解密key给外部校验
 *
 * @param mediaInfo 下载对象
 * @param url Url地址
 * @param data 服务器返回
 * @return 0：校验正确，继续下载；否则校验失败，抛出下载错误（SDK 获取失败）
 */
- (int)hlsKeyVerify:(TXVodDownloadMediaInfo *)mediaInfo url:(NSString *)url data:(NSData *)data;

@end

LITEAV_EXPORT @interface TXVodDownloadManager : NSObject

/**
 * 下载任务回调
 */
@property(nonatomic, weak) id<TXVodDownloadDelegate> delegate;

/**
 * 设置 HTTP 头
 */
@property(nonatomic, strong) NSDictionary *headers;

/**
 * 是否支持私有加密模式(配置为系统播放器请设置为NO，自研播放器设置为YES), 默认设置为YES
 */
@property(nonatomic, assign) BOOL supportPrivateEncryptMode;

/**
 * 全局单例接口
 */
+ (TXVodDownloadManager *)shareInstance;

/**
 * 设置下载文件的根目录。
 *
 * @discussion 此处设置的下载目录优先以 ‘ TXPlayerGlobalSetting #setCacheFolderPath’ 设置为准
 * @param path 目录地址，如不存在，将自动创建
 * @warning 开始下载前必须设置，否则不能下载
 */
- (void)setDownloadPath:(NSString *)path;

/**
 * 下载文件
 *
 * @param source 下载源。
 * @return 成功返回下载对象，否则nil
 */
- (TXVodDownloadMediaInfo *)startDownload:(TXVodDownloadDataSource *)source;

/**
 * 下载文件
 *
 * @param username username
 * @param url url
 */
- (TXVodDownloadMediaInfo *)startDownload:(NSString *)username url:(NSString *)url;

/**
 * 下载文件
 *
 * @param url 下载地址，必选参数，否则下载失败
 * @param resolution 偏好清晰度, 多清晰度url为必选参数,值为偏好清晰度宽x高(如720p传入921600=1280*720), 单清晰度传入-1
 * @param  username 账户名称,可选参数, 不传默认为"default"
 * @return 成功返回下载对象，否则nil
 */
- (TXVodDownloadMediaInfo *)startDownloadUrl:(NSString *)url resolution:(long)resolution userName:(NSString *)username;

/**
 * 下载文件
 *
 * @param drmBuilder drm下载对象，参考 TXPlayerDrmBuilder.h 来实现
 * @param resolution 偏好清晰度, 多清晰度url为必选参数,值为偏好清晰度宽x高(如720p传入921600=1280*720), 单清晰度传入-1
 * @param username 账户名称,可选参数, 不传默认为"default"
 * @return 成功返回下载对象，否则nil
 */
- (TXVodDownloadMediaInfo *)startDownloadDrm:(TXPlayerDrmBuilder *)drmBuilder resolution:(long)resolution userName:(NSString *)username;

/**
 * 停止下载
 *
 * @param media 停止下载对象
 */
- (void)stopDownload:(TXVodDownloadMediaInfo *)media;

/**
 * 删除下载产生的文件
 *
 * @param playPath 待删除的文件路径，此参数可以通过TXVodDownloadMediaInfo对象属性来获取
 * @return 文件正在下载将无法删除，返回NO
 */
- (BOOL)deleteDownloadFile:(NSString *)playPath;

/**
 * 删除下载信息
 *
 * @param downloadMediaInfo 下载的MediaInfo信息
 * @return 文件正在下载将无法删除，返回NO
 */
- (BOOL)deleteDownloadMediaInfo:(TXVodDownloadMediaInfo *)downloadMediaInfo;

/**
 * 获取下载列表
 * 调用此接口要确保之前通过 startDownload及相关接口启动过下载任务
 *
 * @return 返回查询到的下载文件信息列表
 */
- (NSArray<TXVodDownloadMediaInfo *> *)getDownloadMediaInfoList;

/**
 * 获取下载信息，调用此接口要确保之前通过 startDownload、startDownloadUrl或startDownloadDrm 创建过下载任务参数
 *
 * @param media 待查询的下载文件信息描述
 * @return 返回查询到的下载文件信息
 */
- (TXVodDownloadMediaInfo *)getDownloadMediaInfo:(TXVodDownloadMediaInfo *)media DEPRECATED_MSG_ATTRIBUTE("No longer supported, use getDownloadMediaInfo##fileId##qualityId##userName or getDownloadMediaInfo##resolution##userName instead.");

/**
 * 获取下载信息，调用此接口要确保之前通过 startDownload、startDownloadUrl或startDownloadDrm 创建过下载任务参数
 *
 * @param appId 腾讯云视频appId
 * @param fileId 腾讯云视频文件Id
 * @param qualityId 视频画质Id具体参考{ @link TXVodQuality 定义的常量值}
 * @param userName 须与下载时传入的账户名称一致, 若下载时未传入，这里传入空串""
 * @return 返回查询到的下载文件信息
 */
- (TXVodDownloadMediaInfo *)getDownloadMediaInfo:(int)appId fileId:(NSString *)fileId qualityId:(int)qualityId userName:(NSString *)userName;

/**
 * 获取下载信息，调用此接口要确保之前通过 startDownload、startDownloadUrl或startDownloadDrm 创建过下载任务参数
 *
 * @param url 下载链接
 * @param preferredResolution 须与下载时传入的偏好清晰度值相同,若下载时未传入，这里传入"-1"
 * @param userName 须与下载时传入的账户名称一致,若下载时未传入，这里传入空串""
 * @return 返回查询到的下载文件信息
 */
- (TXVodDownloadMediaInfo *)getDownloadMediaInfo:(NSString *)url resolution:(long)preferredResolution userName:(NSString *)userName;

/**
 * 获取HLS EXT-X-KEY 加解密的overlayKey和overlayIv
 *
 * @param appId 腾讯云视频appId
 * @param userName 须与下载时传入的账户名称一致，否则取不到值
 * @param fileId 腾讯云视频文件Id
 * @param qualityId 视频画质Id具体参考{ @link TXVodQuality定义的常量值}
 */
- (NSString *)getOverlayKeyIv:(int)appId userName:(NSString *)userName fileId:(NSString *)fileId qualityId:(int)qualityId DEPRECATED_MSG_ATTRIBUTE("No longer supported");

/**
 * 加密
 *
 * @param originHexStr originHexStr
 */
+ (NSString *)encryptHexStringHls:(NSString *)originHexStr;

@end
