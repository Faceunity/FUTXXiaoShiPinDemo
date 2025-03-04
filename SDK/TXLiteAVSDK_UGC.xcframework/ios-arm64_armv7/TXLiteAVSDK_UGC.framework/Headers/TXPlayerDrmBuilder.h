/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

/**
 * 点播Drm构造器
 */
LITEAV_EXPORT @interface TXPlayerDrmBuilder : NSObject

/// 证书提供商url
@property(nonatomic, strong) NSString *deviceCertificateUrl;

/// 解密key url
@property(nonatomic, strong) NSString *keyLicenseUrl;

/// 播放链接
@property(nonatomic, strong) NSString *playUrl;

/**
 * 初始化DRM
 *
 * @param certificateUrl 证书提供商url
 * @param licenseUrl 解密的key url
 * @param videoUrl 待播放的Url地址
 * @return 返回创建的DRM对象
 */
- (instancetype)initWithDeviceCertificateUrl:(NSString *)certificateUrl licenseUrl:(NSString *)licenseUrl videoUrl:(NSString *)videoUrl;

@end
