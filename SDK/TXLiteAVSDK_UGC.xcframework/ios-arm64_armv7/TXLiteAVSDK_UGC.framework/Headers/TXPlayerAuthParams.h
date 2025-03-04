//  Copyright © 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"
#import "TXVodPlayConfig.h"

/**
 * 点播fileid鉴权信息
 */
LITEAV_EXPORT @interface TXPlayerAuthParams : NSObject

/// 应用appId。如果不设置url该字段必填
@property(nonatomic, assign) int appId;

/// 文件id。如果不设置url该字段必填
@property(nonatomic, copy) NSString *fileId;

/// 加密链接超时时间戳，转换为16进制小写字符串，腾讯云 CDN 服务器会根据该时间判断该链接是否有效。可选
@property(nonatomic, copy) NSString *timeout;

/// 试看时长，单位：秒。可选
@property(nonatomic, assign) int exper;

/// 唯一标识请求，增加链接唯一性
@property(nonatomic, copy) NSString *us;

/// 无防盗链不填
/// 普通防盗链签名：
/// sign = md5(KEY+appId+fileId+t+us)
/// 带试看的防盗链签名：
/// sign = md5(KEY+appId+fileId+t+exper+us)
/// 播放器API使用的防盗链参数(t, us, exper) 与CDN防盗链参数一致，只是sign计算方式不同
/// 参考防盗链产品文档: https://cloud.tencent.com/document/product/266/11243
@property(nonatomic, copy) NSString *sign;

/// 是否用https请求，默认NO
@property(nonatomic, assign) BOOL https;

/// url，如果不设置fileId，该字段必填
@property(nonatomic, copy) NSString *url;

/// 设置媒资类型，默认`MEDIA_TYPE_AUTO`
@property(nonatomic, assign) TX_Enum_MediaType mediaType;

/// 设置mp4加密等级。同TXVodPlayConfig.encryptedMp4Level。
/// MP4_ENCRYPTION_LEVEL_NONE: 不加密
/// MP4_ENCRYPTION_LEVEL_L1: L1（在线加密）
/// MP4_ENCRYPTION_LEVEL_L2: L2（本地加密）
@property(nonatomic, assign) TX_Enum_MP4EncryptionLevel encryptedMp4Level;

/// 设置 HTTP 头
@property(nonatomic, strong) NSDictionary *headers;

@end
