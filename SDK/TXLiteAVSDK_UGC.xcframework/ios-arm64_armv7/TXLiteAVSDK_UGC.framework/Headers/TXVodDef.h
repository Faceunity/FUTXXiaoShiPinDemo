//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

/**
 * 字幕回调数据
 */
LITEAV_EXPORT @interface TXVodSubtitleData : NSObject

/// 字幕内容
@property(nonatomic, copy) NSString *subtitleData;

/// 字幕持续时间, 单位毫秒
@property(nonatomic, assign) int64_t durationMs;

/// 字幕开始时间，也就是视频的position位置，单位毫秒
@property(nonatomic, assign) int64_t startPositionMs;

/// 当前字幕轨道的trackIndex
@property(nonatomic, assign) int64_t trackIndex;

@end
