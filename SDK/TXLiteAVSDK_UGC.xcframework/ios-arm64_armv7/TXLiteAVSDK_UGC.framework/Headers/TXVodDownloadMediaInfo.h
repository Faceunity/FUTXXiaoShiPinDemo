/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"
#import "TXVodDownloadDataSource.h"

/**
 * 下载状态
 */
typedef NS_ENUM(NSInteger, TXVodDownloadMediaInfoState) {

    /// 初始化状态
    TXVodDownloadMediaInfoStateInit = 0,

    /// 启动
    TXVodDownloadMediaInfoStateStart = 1,

    /// 停止
    TXVodDownloadMediaInfoStateStop = 2,

    /// 错误
    TXVodDownloadMediaInfoStateError = 3,

    /// 下载完成
    TXVodDownloadMediaInfoStateFinish = 4,
};

LITEAV_EXPORT @interface TXVodDownloadMediaInfo : NSObject

/**
 * fileid下载对象（url下载时为可选，fileid下载时此参数为必填参数）
 */
@property(nonatomic, strong) TXVodDownloadDataSource *dataSource;

/**
 * 下载地址（使用私有加密下载时，请使用fileid对象下载）
 */
@property(nonatomic, copy) NSString *url;

/**
 * 账户名称, 默认值为default
 */
@property(nonatomic, copy) NSString *userName;

/**
 * 时长，单位：秒
 */
@property(nonatomic, assign) int duration;

/**
 * 可播放时长，单位：秒
 */
@property(nonatomic, assign) int playableDuration;

/**
 * 文件总大小，单位：byte
 */
@property(nonatomic, assign) long size;

/**
 * 已下载大小，单位：byte
 */
@property(nonatomic, assign) long downloadSize;

/**
 * 分段总数
 */
@property(nonatomic, assign) int segments;

/**
 * 已下载的分段数
 */
@property(nonatomic, assign) int downloadSegments;

/**
 * 进度
 */
@property(nonatomic, assign) float progress;

/**
 * 播放路径，视频下载完成后可传给TXVodPlayer进行本地文件播放
 *
 * @discussion 此参数用于下载播放时，需要通过getDownloadMediaInfoList或 getDownloadMediaInfo: 接口获取得到，不可以私下保存
 */
@property(nonatomic, copy) NSString *playPath;

/**
 * 下载速度，byte每秒
 */
@property(nonatomic, assign) int speed;

/**
 * 下载状态
 */
@property(nonatomic, assign) TXVodDownloadMediaInfoState downloadState;

/**
 * 偏好清晰度，查询播放状态时，需要与下载时保持一致。 默认720P
 */
@property(nonatomic, assign) long preferredResolution;

/**
 * 判断资源是否损坏，如下载完被删除等情况，默认值为NO
 */
@property(nonatomic, assign) BOOL isResourceBroken;

/**
 * 下载是否已完成
 */
- (BOOL)isDownloadFinished;

@end
