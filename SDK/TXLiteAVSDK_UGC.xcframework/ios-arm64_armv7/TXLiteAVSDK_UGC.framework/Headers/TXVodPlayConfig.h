//  Copyright © 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

/**
 * 自适应码率 'bitrate index' 参数设置
 */
LITEAV_EXPORT extern NSInteger const INDEX_AUTO;

/**
 * 音量均衡预设参数：音量均衡，关
 */
LITEAV_EXPORT extern float const AUDIO_NORMALIZATION_OFF;

/**
 * 音量均衡预设参数：音量均衡，标准响度
 */
LITEAV_EXPORT extern float const AUDIO_NORMALIZATION_STANDARD;

/**
 * 音量均衡预设参数：音量均衡，低响度
 */
LITEAV_EXPORT extern float const AUDIO_NORMALIZATION_LOW;

/**
 * 音量均衡预设参数：音量均衡，高响度
 */
LITEAV_EXPORT extern float const AUDIO_NORMALIZATION_HIGH;

/**
 * MP4加密播放等级
 */
typedef NS_ENUM(NSInteger, TX_Enum_MP4EncryptionLevel) {

    /// mp4加密播放：不加密
    MP4_ENCRYPTION_LEVEL_NONE = 0,

    /// mp4加密播放：L1（在线加密）
    MP4_ENCRYPTION_LEVEL_L1 = 1,

    /// mp4加密播放：L2（本地加密）
    MP4_ENCRYPTION_LEVEL_L2 = 2,
};

/**
 * 播放器类型定义
 */
typedef NS_ENUM(NSInteger, TX_Enum_PlayerType) {

    /// 基于系统播放器
    PLAYER_AVPLAYER = 0,

    /// 基于FFmepg，支持软解，兼容性更好
    PLAYER_THUMB_PLAYER = 1,
};

/**
 * 播放器偏好分辨率选择，常见的分辨率width * height值，用于preferredResolution 的赋值
 */
typedef NS_ENUM(NSInteger, TX_Enum_VideoResolution) {

    /// RESOLUTION 720X1280
    VIDEO_RESOLUTION_720X1280 = 720 * 1280,

    /// RESOLUTION 1080X1920
    VIDEO_RESOLUTION_1080X1920 = 1080 * 1920,

    /// RESOLUTION 1440X2560
    VIDEO_RESOLUTION_1440X2560 = 1440 * 2560,

    /// RESOLUTION 2160X3840
    VIDEO_RESOLUTION_2160X3840 = 2160 * 3840,
};

/**
 * 媒资类型（ 使用自适应码率播放功能时需设定具体HLS码流是点播/直播媒资，暂时不支持Auto类型）
 */
typedef NS_ENUM(NSInteger, TX_Enum_MediaType) {

    /// AUTO类型（默认值，自适应码率播放暂不支持）
    MEDIA_TYPE_AUTO = 0,

    /// HLS点播媒资
    MEDIA_TYPE_HLS_VOD = 1,

    /// HLS直播媒资
    MEDIA_TYPE_HLS_LIVE = 2,

    /// MP4等通用文件点播媒资
    MEDIA_TYPE_FILE_VOD = 3,

    /// DASH点播媒资
    MEDIA_TYPE_DASH_VOD = 4,
};

/**
 * 视频帧输出类型
 */
typedef NS_ENUM(NSInteger, TX_Enum_Video_Pixel_Format) {

    /// 未定义None
    TX_VIDEO_PIXEL_FORMAT_NONE = 0,

    /// VIDEO TOOL BOX，直接原视频格式输出
    TX_VIDEO_PIXEL_FORMAT_VideoToolbox = 1,

    /// RGBA格式（由于苹果不推荐用RGBA，请使用BGRA格式进行替代）
    TX_VIDEO_PIXEL_FORMAT_RGBA DEPRECATED_ATTRIBUTE = 2,

    /// BGRA格式
    TX_VIDEO_PIXEL_FORMAT_BGRA = 3,
};

/**
 * VOD 播放器配置
 */
LITEAV_EXPORT @interface TXVodPlayConfig : NSObject

@property(nonatomic, assign) int connectRetryCount;

/// 播放器连接重试间隔：单位秒，最小值为3, 最大值为30，默认值为 3
@property(nonatomic, assign) int connectRetryInterval;

/// 超时时间：单位秒，默认 10s
@property(nonatomic, assign) NSTimeInterval timeout;

/// 视频渲染对象回调的视频格式。支持 kCVPixelFormatType_32BGRA、kCVPixelFormatType_420YpCbCr8BiPlanarFullRange、kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
@property(nonatomic, assign) OSType playerPixelFormatType DEPRECATED_MSG_ATTRIBUTE("Use videoFrameFormatType instead.");

/// 视频渲染对象回调的视频格式，默认值为TX_VIDEO_PIXEL_FORMAT_NONE
@property(nonatomic, assign) TX_Enum_Video_Pixel_Format videoFrameFormatType;

/// stopPlay 的时候是否保留最后一帧画面，默认值为 NO
@property(nonatomic, assign) BOOL keepLastFrameWhenStop;

/// 首缓需要加载的数据时长，单位 ms,   默认值为 100ms
@property(nonatomic, assign) int firstStartPlayBufferTime;

/// 缓冲时（缓冲数据不够引起的二次缓冲，或者seek引起的拖动缓冲）最少要缓存多长的数据才能结束缓冲，单位ms，默认值为250ms
@property(nonatomic, assign) int nextStartPlayBufferTime;

/// 视频缓存目录，点播MP4、HLS有效
///@note 缓存目录应该是单独的目录，SDK可能会清掉其中的文件
@property(nonatomic, copy) NSString *cacheFolderPath DEPRECATED_MSG_ATTRIBUTE("Use TXPlayerGlobalSetting##setCacheFolderPath instead.");

/// 最多缓存文件个数
@property(nonatomic, assign) int maxCacheItems DEPRECATED_MSG_ATTRIBUTE("Use TXPlayerGlobalSetting##setMaxCacheSizeMB instead.");

/// 播放器类型
@property(nonatomic, assign) NSInteger playerType;

/// 自定义 HTTP Headers
@property(nonatomic, strong) NSDictionary *headers;

/// 是否精确 seek，默认 YES。开启精确后 seek，seek 的时间平均多出 200ms
@property(nonatomic, assign) BOOL enableAccurateSeek;

/// 播放 MP4 文件时，若设为YES则根据文件中的旋转角度自动旋转。旋转角度可在 EVT_VIDEO_CHANGE_ROTATION 事件中获得。默认 YES
@property(nonatomic, assign) BOOL autoRotate;

/// 平滑切换码率。默认NO
@property(nonatomic, assign) BOOL smoothSwitchBitrate;

/// 设置进度回调间隔时间，单位毫秒。若不设置，SDK默认间隔500毫秒回调一次
@property(nonatomic, assign) NSTimeInterval progressInterval;

/// 最大缓存大小，单位 MB 此设置会影响playableDuration，设置越大，提前缓存的越多
@property(nonatomic, assign) float maxBufferSize;

/// 设置预加载最大缓冲大小，单位：MB
@property(nonatomic, assign) float maxPreloadSize;

/// 加密 key
@property(nonatomic, copy) NSString *overlayKey;

/// 加密Iv
@property(nonatomic, copy) NSString *overlayIv;

/// 设置mp4加密播放。MP4_ENCRYPTION_LEVEL_NONE：播放正常mp4 MP4_ENCRYPTION_LEVEL_L1：播放L1加密mp4 MP4_ENCRYPTION_LEVEL_L2：播放L2加密mp4
@property(nonatomic, assign) TX_Enum_MP4EncryptionLevel encryptedMp4Level;

/// 显示处理标志位
/// 设置Render 显示后处理标志位，包含超分、VR等功能，使用这些功能需要设置此标志位，默认为NO
@property(nonatomic, assign) BOOL enableRenderProcess;

/// Hls 多 Program 时，根据设定的 preferredResolution 选最优的Program进行起播，preferredResolution是宽高的乘积
/// 配置有效值为 >=-1 的整形数，缺省为-1播放内核理解为应使用优先级更低的信息进行配置，会从小于该值的program中匹配算数距离最接近的
/// 优先级为 bitrateIndex > mPreferredBitrate > mPreferredResolution
@property(nonatomic, assign) long preferredResolution;

/// 设置媒资类型
/// 【重要】若自适应码率播放，暂须指定具体类型，如自适应播放HLS直播资源，须传入MEDIA_TYPE_HLS_LIVE类型
@property(nonatomic, assign) TX_Enum_MediaType mediaType;

/// 设置一些不必周知的特殊配置
@property(nonatomic, strong) NSDictionary *extInfoMap;

/// 启播时优先加载的音轨名称 ，播放器高级版本 12.3 版本开始支持
@property(nonatomic, copy) NSString *preferAudioTrack;

@end
