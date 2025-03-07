// Copyright (c) 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

@protocol TXUGCBaseDelegate <NSObject>
/**
 @brief  setLicenceURL 接口回调, result = 0 成功，负数失败。
 @discussion
 需在调用 setLicenceURL 前设置 delegate
 */
- (void)onLicenceLoaded:(int)result Reason:(NSString *)reason;
@end

/// 短视频SDK基本信息设置类
LITEAV_EXPORT @interface TXUGCBase : NSObject
/// 通过这个 delegate 将 setLicenceURL 结果回调给SDK使用者
@property(nonatomic, weak) id<TXUGCBaseDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 设置sdk的licence下载url和key, 可以从控制台获取
 @param url licence 下载URL
 @param key licence钥匙
 */
+ (void)setLicenceURL:(NSString *)url key:(NSString *)key;

/// 获取Licence信息
+ (NSString *)getLicenceInfo;
/// 获取版本号
+ (NSString *)getSDKVersionStr;
 /// 获取License里的AppId
+ (NSString *)getLicenseAppId;

/// 调用试验性API
+ (NSString *)callExperimentalAPI:(NSString *)params;
@end
