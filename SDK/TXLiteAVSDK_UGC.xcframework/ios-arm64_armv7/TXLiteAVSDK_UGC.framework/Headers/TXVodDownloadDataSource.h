/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"
#import "TXPlayerAuthParams.h"

/**
 * 下载视频的清晰度
 */
typedef NS_ENUM(NSInteger, TXVodQuality) {

    /// 原画
    TXVodQualityOD = 0,

    /// 流畅
    TXVodQualityFLU,

    /// 标清
    TXVodQualitySD,

    /// 高清
    TXVodQualityHD,

    /// 全高清
    TXVodQualityFHD,

    /// 2K
    TXVodQuality2K,

    /// 4K
    TXVodQuality4K,

    /// 流畅240p
    TXVodQuality240P = 240,

    /// 流畅360p
    TXVodQuality360P = 360,

    /// 标清480p
    TXVodQuality480P = 480,

    /// 标清540p
    TXVodQuality540P = 540,

    /// 高清720p
    TXVodQuality720P = 720,

    /// 全高清1080p
    TXVodQuality1080p = 1080,
};

/**
 * 下载源，通过fileid方式下载
 */
LITEAV_EXPORT @interface TXVodDownloadDataSource : NSObject

/// fileid信息，此参数仅用于兼容旧版本(V2)腾讯云点播 File ID下载参数
@property(nonatomic, strong) TXPlayerAuthParams *auth;

/// 下载清晰度，默认高清（获取下载信息时，此参数需和下载视频时使用的参数一致）
@property(nonatomic, assign) TXVodQuality quality;

/// 如地址有加密，请填写token
@property(nonatomic, copy) NSString *token;

/// 清晰度模板。如果后台转码是自定义模板，请在这里填写模板名。templateName和quality同时设置时，以templateName为准
@property(nonatomic, copy) NSString *templateName;

/// 文件Id
@property(nonatomic, copy) NSString *fileId;

/// 签名信息
@property(nonatomic, copy) NSString *pSign;

/// 应用appId。必填
@property(nonatomic, assign) int appId;

/// 账户名称，默认值为‘default’
@property(nonatomic, copy) NSString *userName;

/// HLS EXT-X-KEY 加解密参数
@property(nonatomic, copy) NSString *overlayKey;

@property(nonatomic, copy) NSString *overlayIv;

@end
