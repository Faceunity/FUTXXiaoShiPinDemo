//
// Copyright (c) 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiveSDKTypeDef.h"
#import "TXVodSDKEventDef.h"
#import "TXVodDef.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                      VOD 相关回调
//
/////////////////////////////////////////////////////////////////////////////////

@class TXVodPlayer;
@protocol TXVodPlayListener <NSObject>

/**
 * 点播事件通知
 *
 * 点播事件通知
 */
@required

- (void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param;

/**
 * 网络状态通知
 *
 * 网络状态通知
 */
@optional

- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary *)param;

/**
 * 画中画状态回调
 *
 * 画中画状态回调
 */
- (void)onPlayer:(TXVodPlayer *)player pictureInPictureStateDidChange:(TX_VOD_PLAYER_PIP_STATE)pipState withParam:(NSDictionary *)param;

/**
 * 画中画错误信息回调
 *
 * 画中画错误信息回调
 */
- (void)onPlayer:(TXVodPlayer *)player pictureInPictureErrorDidOccur:(TX_VOD_PLAYER_PIP_ERROR_TYPE)errorType withParam:(NSDictionary *)param;

/**
 * AIRPLAY状态回调（仅支持系统播放器）
 *
 * AIRPLAY状态回调
 */
- (void)onPlayer:(TXVodPlayer *)player airPlayStateDidChange:(TX_VOD_PLAYER_AIRPLAY_STATE)airPlayState withParam:(NSDictionary *)param;

/**
 * AIRPLAY错误信息回调（仅支持系统播放器）
 *
 * AIRPLAY错误信息回调
 */
- (void)onPlayer:(TXVodPlayer *)player airPlayErrorDidOccur:(TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE)errorType withParam:(NSDictionary *)param;

/**
 * 字幕数据回调
 *
 * @param player  当前播放器对象
 * @param subtitleData  字幕数据，详细见 TXVodDef.h 文件
 */
- (void)onPlayer:(TXVodPlayer *)player subtitleData:(TXVodSubtitleData *)subtitleData;

@end
