//  Copyright © 2021 Tencent. All rights reserved.

#ifndef __TX_VOD_SDK_EVENT_DEF_H__
#define __TX_VOD_SDK_EVENT_DEF_H__

#import "TXLiveSDKEventDef.h"
#import "TXLiveSDKTypeDef.h"

/**
 * 以下为点播播放器的事件码和错误码
 */
enum TXVODEventID {

    /**
     * ​	/////////////////////////////////////////////////////////////////////////////////
     * ​    //       播放相关错误码、事件码和警告码
     * ​    /////////////////////////////////////////////////////////////////////////////////
     */
    /// 播放事件: 命中缓存
    VOD_PLAY_EVT_HIT_CACHE = 2002,

    /// 播放事件: 成功接受到第一个视频帧
    VOD_PLAY_EVT_RCV_FIRST_I_FRAME = 2003,

    /// 播放事件: 成功接受到第一个音频帧
    VOD_PLAY_EVT_RCV_FIRST_AUDIO_FRAME = 2026,

    /// 播放事件: 播放已经开始
    VOD_PLAY_EVT_PLAY_BEGIN = 2004,

    /// 播放事件: 播放进度更新，点播播放器（VodPlayer）专用
    VOD_PLAY_EVT_PLAY_PROGRESS = 2005,

    /// 播放事件: 播放已经结束
    VOD_PLAY_EVT_PLAY_END = 2006,

    /// 播放事件: 数据缓冲中
    VOD_PLAY_EVT_PLAY_LOADING = 2007,

    /// 播放事件: 视频解码器已经启动
    VOD_PLAY_EVT_START_VIDEO_DECODER = 2008,

    /// 播放事件: 视频分辨率发生变化
    VOD_PLAY_EVT_CHANGE_RESOLUTION = 2009,

    /// 播放事件: 成功获取到点播文件的信息，点播播放器（VodPlayer）专用
    VOD_PLAY_EVT_GET_PLAYINFO_SUCC = 2010,

    /// 播放事件: MP4 视频的旋转角度发生变化，点播播放器（VodPlayer）专用
    VOD_PLAY_EVT_CHANGE_ROTATION = 2011,

    /// 播放事件: 接收到视频流中的 SEI 消息（https://cloud.tencent.com/document/product/454/7880#Message）
    VOD_PLAY_EVT_GET_MESSAGE = 2012,

    /// 播放事件: 视频加载完毕，点播播放器（VodPlayer）专用
    VOD_PLAY_EVT_VOD_PLAY_PREPARED = 2013,

    /// 播放事件: 视频缓冲结束，点播播放器（VodPlayer）专用
    VOD_PLAY_EVT_VOD_LOADING_END = 2014,

    /// 播放事件: 已经成功完成切流（在不同清晰度的视频流之间进行切换）
    VOD_PLAY_EVT_STREAM_SWITCH_SUCC = 2015,

    /// TCP 连接成功
    VOD_PLAY_EVT_VOD_PLAY_TCP_CONNECT_SUCC = 2016,

    /// 收到首帧数据， 12.0 版本开始支持
    VOD_PLAY_EVT_VOD_PLAY_FIRST_VIDEO_PACKET = 2017,

    /// DNS 解析完成
    VOD_PLAY_EVT_VOD_PLAY_DNS_RESOLVED = 2018,

    /// 视频播放 Seek 完成
    VOD_PLAY_EVT_VOD_PLAY_SEEK_COMPLETE = 2019,

    /// 切换轨道完成
    VOD_PLAY_EVT_SELECT_TRACK_COMPLETE = 2020,

    /// 反选轨道完成
    VOD_PLAY_EVT_DESELECT_TRACK_COMPLETE = 2021,

    /// 播放事件: 视频 SEI
    VOD_PLAY_EVT_VIDEO_SEI = 2030,

    /// 播放事件: HEVC 降级播放
    VOD_PLAY_EVT_HEVC_DOWNGRADE_PLAYBACK = 2031,

    /// 播放事件: Audio Session 被其他 App 中断（仅适用于 iOS 平台）
    VOD_PLAY_EVT_AUDIO_SESSION_INTERRUPT = 2032,

    /// 直播错误: 网络连接断开（已经经过三次重试并且未能重连成功）
    VOD_PLAY_ERR_NET_DISCONNECT = -2301,

    /// 点播错误: 播放文件不存在
    VOD_PLAY_ERR_FILE_NOT_FOUND = -2303,

    /// 点播错误: HLS 解码 KEY 获取失败
    VOD_PLAY_ERR_HLS_KEY = -2305,

    /// 点播错误: 获取点播文件的文件信息失败
    VOD_PLAY_ERR_GET_PLAYINFO_FAIL = -2306,

    /// licence 检查失败
    VOD_PLAY_ERR_LICENCE_CHECK_FAIL = -5,

    /// 循环一轮播放结束（10.8 新增）
    VOD_PLAY_EVT_LOOP_ONCE_COMPLETE = 6001,

    /// 未知错误。
    VOD_PLAY_ERR_UNKNOW = -6001,

    /// 通用错误码。
    VOD_PLAY_ERR_GENERAL = -6002,

    /// 解封装失败。
    VOD_PLAY_ERR_DEMUXER_FAIL = -6003,

    /// 系统播放器播放错误。
    VOD_PLAY_ERR_SYSTEM_PLAY_FAIL = -6004,

    /// 解封装超时。
    VOD_PLAY_ERR_DEMUXER_TIMEOUT = -6005,

    /// 视频解码错误。
    VOD_PLAY_ERR_DECODE_VIDEO_FAIL = -6006,

    /// 音频解码错误。
    VOD_PLAY_ERR_DECODE_AUDIO_FAIL = -6007,

    /// 字幕解码错误。
    VOD_PLAY_ERR_DECODE_SUBTITLE_FAIL = -6008,

    /// 视频渲染错误。
    VOD_PLAY_ERR_RENDER_FAIL = -6009,

    /// 视频后处理错误。
    VOD_PLAY_ERR_PROCESS_VIDEO_FAIL = -6010,

    /// 视频下载出错。
    VOD_PLAY_ERR_DOWNLOAD_FAIL = -6011,
};

/**
 * 兼容定义
 *
 * 用于兼容老版本的错误码定义，请在代码中尽量使用右侧的新定义
 */
#define EVT_VOD_PLAY_TCP_CONNECT_SUCC VOD_PLAY_EVT_VOD_PLAY_TCP_CONNECT_SUCC
#define EVT_VOD_PLAY_FIRST_VIDEO_PACKET VOD_PLAY_EVT_VOD_PLAY_FIRST_VIDEO_PACKET
#define EVT_VOD_PLAY_DNS_RESOLVED VOD_PLAY_EVT_VOD_PLAY_DNS_RESOLVED
#define EVT_VOD_PLAY_SEEK_COMPLETE VOD_PLAY_EVT_VOD_PLAY_SEEK_COMPLETE

/**
 * 画中画控制器状态
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_PIP_STATE) {

    /// 未设置状态
    TX_VOD_PLAYER_PIP_STATE_UNDEFINED = 0,

    /// 画中画即将开始
    TX_VOD_PLAYER_PIP_STATE_WILL_START = 1,

    /// 画中画已经开始
    TX_VOD_PLAYER_PIP_STATE_DID_START = 2,

    /// 画中画即将结束
    TX_VOD_PLAYER_PIP_STATE_WILL_STOP = 3,

    /// 画中画已经结束
    TX_VOD_PLAYER_PIP_STATE_DID_STOP = 4,

    /// 重置UI
    TX_VOD_PLAYER_PIP_STATE_RESTORE_UI = 5,
};

/**
 * 画中画错误类型
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_PIP_ERROR_TYPE) {

    /// 无错误
    TX_VOD_PLAYER_PIP_ERROR_TYPE_NONE = 0,

    /// 设备或系统版本不支持（iPad iOS9+ 才支持PIP）
    TX_VOD_PLAYER_PIP_ERROR_TYPE_DEVICE_NOT_SUPPORT = 1,

    /// 播放器不支持
    TX_VOD_PLAYER_PIP_ERROR_TYPE_PLAYER_NOT_SUPPORT = 2,

    /// 视频不支持
    TX_VOD_PLAYER_PIP_ERROR_TYPE_VIDEO_NOT_SUPPORT = 3,

    /// PIP控制器不可用
    TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_IS_NOT_POSSIBLE = 4,

    /// PIP控制器报错
    TX_VOD_PLAYER_PIP_ERROR_TYPE_ERROR_FROM_SYSTEM = 5,

    /// 播放器对象不存在
    TX_VOD_PLAYER_PIP_ERROR_TYPE_PLAYER_NOT_EXIST = 10,

    /// PIP功能已经运行
    TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_IS_RUNNING = 11,

    /// PIP功能没有启动
    TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_NOT_RUNNING = 12,

    /// PIP启动超时
    TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_START_TIMEOUT = 13,

    /// 无缝PIP功能启动失败
    TX_VOD_PLAYER_PIP_ERROR_TYPE_SEAMLESS_PIP_ERROR = 20,

    /// 不支持无缝切换PIP
    TX_VOD_PLAYER_PIP_ERROR_TYPE_SEAMLESS_PIP_NOT_SUPPORT = 21,

    /// 无缝PIP功能已经运行
    TX_VOD_PLAYER_PIP_ERROR_TYPE_SEAMLESS_PIP_IS_RUNNING = 22,
};

/**
 * AIRPLAY状态(仅支持系统播放器)
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_AIRPLAY_STATE) {

    /// 未运行
    TX_VOD_PLAYER_AIRPLAY_STATE_NOT_RUNNING = 0,

    /// 运行中
    TX_VOD_PLAYER_AIRPLAY_STATE_DID_RUNNING = 1,
};

/**
 * AIRPLAY错误类型(仅支持系统播放器)
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE) {

    /// 无错误
    TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE_NONE = 0,

    /// 播放器不支持
    TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE_PLAYER_NOT_SUPPORT = 1,

    /// 视频不支持
    TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE_VIDEO_NOT_SUPPORT = 2,

    /// 播放器对象不可用
    TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE_PLAYER_INVALID = 10,

    /// 播放器状态错误
    TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE_PLAYER_STATE = 11,
};

/**
 * 外挂字幕Mime Type类型
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_SUBTITLE_MIME_TYPE) {

    /// 外挂字幕SRT格式
    TX_VOD_PLAYER_MIMETYPE_TEXT_SRT = 0,

    /// 外挂字幕VTT格式
    TX_VOD_PLAYER_MIMETYPE_TEXT_VTT = 1,
};

/**
 * 播放器缓冲类型定义
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_BUFFERING_TYPE) {

    /// 未定义
    TX_VOD_PLAYER_BUFFERING_TYPE_NONE = -1,

    /// 普通缓冲
    TX_VOD_PLAYER_BUFFERING_TYPE_NORMAL = 0,

    /// 播放器内部重启产生的缓冲事件
    TX_VOD_PLAYER_BUFFERING_TYPE_PLAYER_REOPEN = 1,
};

/**
 * 腾讯云 LiteAVSDK 通过  ‘onPlayEvent:播放器对象  event:事件ID withParam:参数’ 向您通知内部事件、错误、告警等
 * 信息。以下是参数部分携带的信息，采用 key-value 的组织格式，其中 key 值的定义如下：
 */
#ifndef TX_VOD_PLAY_EVENT_MSG
#define TX_VOD_PLAY_EVENT_MSG

/**
 * 参数Key值列表
 */
/// 雪碧图web Vtt描述文件下载URL
#define VOD_PLAY_EVENT_IMAGESPRIT_WEBVTTURL @"EVT_IMAGESPRIT_WEBVTTURL"

/// 雪碧图图片下载URL列表( NSArray类型 )
#define VOD_PLAY_EVENT_IMAGESPRIT_IMAGEURL_LIST @"EVT_IMAGESPRIT_IMAGEURL_LIST"

/// 视频关键帧描述信息
#define VOD_PLAY_EVENT_KEY_FRAME_CONTENT_LIST @"EVT_KEY_FRAME_CONTENT_LIST"

/// 关键帧时间(秒)
#define VOD_PLAY_EVENT_KEY_FRAME_TIME_LIST @"EVT_KEY_FRAME_TIME_LIST"

/// 视频旋转角度
#define VOD_PLAY_EVENT_KEY_VIDEO_ROTATION @"EVT_KEY_VIDEO_ROTATION"

/// 外挂字幕Event参数返回 — 切换的媒体轨道index
#define EVT_KEY_SELECT_TRACK_INDEX @"EVT_KEY_SELECT_TRACK_INDEX"

/// 外挂字幕Event参数返回 — 切换媒体轨道的返回错误码
#define EVT_KEY_SELECT_TRACK_ERROR_CODE @"EVT_KEY_SELECT_TRACK_ERROR_CODE"

/// 播放器Loading的Type类型
#define VOD_PLAY_BUFFERING_LOADING_TYPE @"VOD_PLAY_BUFFERING_LOADING_TYPE"

/// 幽灵水印文本（11.5版本开始支持）
#define EVT_KEY_WATER_MARK_TEXT @"EVT_KEY_WATER_MARK_TEXT"

/// 视频SEI类型
#define EVT_KEY_SEI_TYPE @"EVT_KEY_SEI_TYPE"

/// 视频SEI数据buffer大小
#define EVT_KEY_SEI_SIZE @"EVT_KEY_SEI_SIZE"

/// 视频SEI数据buffer
#define EVT_KEY_SEI_DATA @"EVT_KEY_SEI_DATA"

/**
 * 兼容定义
 * 用于兼容老版本的错误码定义，请在代码中尽量使用左侧 ‘VOD_PLAY_XXX’的新定义
 */
/// 事件ID
#define VOD_PLAY_EVENT_MSG EVT_MSG

/// 事件发生的UTC毫秒时间戳
#define VOD_PLAY_EVENT_TIME EVT_TIME

/// 事件发生的UTC毫秒时间戳(兼容性)
#define VOD_PLAY_EVENT_UTC_TIME EVT_UTC_TIME

/// 卡顿时间（毫秒）
#define VOD_PLAY_EVENT_BLOCK_DURATION EVT_BLOCK_DURATION

/// 播放器错误码。
#define VOD_PLAY_EVT_ERROR_CODE @"EVT_ERROR_CODE"

/// 事件参数1
#define VOD_PLAY_EVENT_PARAM1 EVT_PARAM1

/// 事件参数2
#define VOD_PLAY_EVENT_PARAM2 EVT_PARAM2

/// 消息内容
#define VOD_PLAY_EVENT_GET_MSG EVT_GET_MSG

/// 视频播放进度
#define VOD_PLAY_EVENT_PLAY_PROGRESS EVT_PLAY_PROGRESS

/// 视频总时长
#define VOD_PLAY_EVENT_PLAY_DURATION EVT_PLAY_DURATION

/// 视频可播放时长
#define VOD_PLAY_EVENT_PLAYABLE_DURATION EVT_PLAYABLE_DURATION

/// 视频封面
#define VOD_PLAY_EVENT_PLAY_COVER_URL EVT_PLAY_COVER_URL

/// 视频播放地址
#define VOD_PLAY_EVENT_PLAY_URL EVT_PLAY_URL

/// 视频名称
#define VOD_PLAY_EVENT_PLAY_NAME EVT_PLAY_NAME

/// 视频简介
#define VOD_PLAY_EVENT_PLAY_DESCRIPTION EVT_PLAY_DESCRIPTION

/// 视频播放PDT时间
#define VOD_PLAY_EVENT_PLAY_PDT_TIME_MS @"EVT_PLAY_PDT_TIME_MS"

/// 自定义透传上报字段 Key（11.7 版本新增）
#define VOD_KEY_CUSTOM_DATA @"VOD_KEY_CUSTOM_DATA"

/// 备选url Key（11.7 版本新增）
#define VOD_KEY_BACKUP_URL @"VOD_KEY_BACKUP_URL"

/// 视频编码类型 key，对应value为CMVideoCodecType（11.7 版本新增）
#define VOD_KEY_VIDEO_CODEC_TYPE @"VOD_KEY_VIDEO_CODEC_TYPE"

/// 备选播放资源 (VOD_KEY_BACKUP_URL)对应的类型（12.0 版本新增）
#define VOD_KEY_BACKUP_URL_MEDIA_TYPE @"VOD_KEY_BACKUP_URL_MEDIA_TYPE"

/// module类型参数
#define PLAYER_OPTION_PARAM_MODULE_TYPE @"PARAM_MODULE_TYPE"

/// module配置
#define PLAYER_OPTION_PARAM_MODULE_CONFIG @"PARAM_MODULE_CONFIG"

/// 是否开启传感器，默认true
#define PLAYER_OPTION_PARAM_MODULE_VR_ENABLE_SENSOR @"ENABLE_SENSOR"

/// 视场⻆，默认65.0f度, 限制范围30.0f-110.0f度
#define PLAYER_OPTION_PARAM_MODULE_VR_FOV @"FOV"

/// ⽔平旋转⻆度，正值右转，负值左转。0°表示正前⽅，取值范围-180°到180°
#define PLAYER_OPTION_PARAM_MODULE_VR_ANGEL_X @"ANGEL_X"

/// 垂直旋转⻆度，正值上转，负值下转。0°表示⽔平视⻆，取值范围-90°到90°
#define PLAYER_OPTION_PARAM_MODULE_VR_ANGEL_Y @"ANGEL_Y"

/**
 * module类型
 */
typedef NS_ENUM(NSInteger, TX_VOD_PLAYER_OPTION_PARAM_MODULE_TYPE) {

    /// 空类型，即关闭超分和VR等
    PLAYER_OPTION_PARAM_MODULE_TYPE_NONE = 0,

    /// 超分类型
    PLAYER_OPTION_PARAM_MODULE_TYPE_SR = 1,

    /// VR 全景模型，单目
    PLAYER_OPTION_PARAM_MODULE_TYPE_VR_PANORAMA = 11,

    /// VR 全景模型，双目
    PLAYER_OPTION_PARAM_MODULE_TYPE_VR_BINOCULAR = 12,
};

/// monet操作
/// VR旋转角度
#define PLAYER_OPTION_PARAM_MODULE_VR_DO_ROTATE @"MONET_AC_DO_ROTATE"

#endif  /* TX_VOD_PLAY_EVT_MSG */
#endif  // __TX_VOD_SDK_EVENT_DEF_H__
