//  Copyright © 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

/**
 * 播放器类型定义
 */
typedef NS_ENUM(NSInteger, TX_VOD_MEDIA_TRACK_TYPE) {

    /// 未知
    TX_VOD_MEDIA_TRACK_TYPE_UNKNOW = 0,

    /// 视频轨
    TX_VOD_MEDIA_TRACK_TYPE_VIDEO = 1,

    /// 音频轨
    TX_VOD_MEDIA_TRACK_TYPE_AUDIO = 2,

    /// 字幕轨
    TX_VOD_MEDIA_TRACK_TYPE_SUBTITLE = 3,
};

NS_ASSUME_NONNULL_BEGIN

LITEAV_EXPORT @interface TXTrackInfo : NSObject

/**
 * track信息(参考 ‘TX_VOD_MEDIA_TRACK_TYPE’ )
 */
@property(nonatomic, assign) TX_VOD_MEDIA_TRACK_TYPE trackType;

/**
 * 轨道index
 */
@property(nonatomic, assign) int trackIndex;

/**
 * 轨道名字
 */
@property(nonatomic, copy) NSString *name;

/**
 * 当前轨道是否被选中
 */
@property(nonatomic, assign) bool isSelected;

/**
 * 如果是true，该类型轨道每个时刻只有一条能被选中，如果是false，该类型轨道可以同时选中多条。
 */
@property(nonatomic, assign) bool isExclusive;

/**
 * 当前的轨道是否是内部原始轨道
 */
@property(nonatomic, assign) bool isInternal;

/**
 * 获取轨道index
 *
 * @return 返回轨道index
 */
- (int)getTrackIndex;

/**
 * 获取轨道类型
 *
 * @return 获取轨道类型(类型可以参考 'TX_VOD_MEDIA_TRACK_TYPE' )
 */
- (TX_VOD_MEDIA_TRACK_TYPE)getTrackType;

/**
 * 获取轨道的名称
 *
 * @return 获取轨道的名称
 */
- (NSString *)getTrackName;

/**
 * 轨道是否相同
 *
 * @param trackInfo  待比较的轨道对象
 * @return YES 表示相同  NO 表示不同
 */
- (bool)isEqual:(TXTrackInfo *)trackInfo;

@end

NS_ASSUME_NONNULL_END
