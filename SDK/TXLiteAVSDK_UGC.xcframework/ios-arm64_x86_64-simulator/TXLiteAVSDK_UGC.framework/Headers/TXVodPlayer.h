//  Copyright © 2021 Tencent. All rights reserved.

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif
#import "TXLivePlayListener.h"
#import "TXVodPlayListener.h"
#import "TXVodPlayConfig.h"
#import "TXVideoCustomProcessDelegate.h"
#import "TXBitrateItem.h"
#import "TXPlayerAuthParams.h"
#import "TXPlayerDrmBuilder.h"
#import "TXLiteAVSymbolExport.h"
#import "TXTrackInfo.h"
#import "TXPlayerSubtitleRenderModel.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                    VOD 播放器相关接口
//
/////////////////////////////////////////////////////////////////////////////////

LITEAV_EXPORT @interface TXVodPlayer : NSObject

/**
 * 事件回调, 建议使用vodDelegate
 */
@property(nonatomic, weak) id<TXLivePlayListener> delegate DEPRECATED_MSG_ATTRIBUTE("Use vodDelegate instead.");

/**
 * 事件回调
 */
@property(nonatomic, weak) id<TXVodPlayListener> vodDelegate;

/**
 * 视频渲染回调。
 *
 * 全平台接口软解硬解均支持
 */
@property(nonatomic, weak) id<TXVideoCustomProcessDelegate> videoProcessDelegate;

/**
 * 是否开启硬件加速
 */
@property(nonatomic, assign) BOOL enableHWAcceleration;

/**
 * 点播配置
 */
@property(nonatomic, copy) TXVodPlayConfig *config;

/**
 * startPlay后是否立即播放，默认YES
 */
@property BOOL isAutoPlay;

/**
 * 加密HLS的token。设置此值后，播放器自动在URL中的文件名之前增加 voddrm.token.TOKEN
 */
@property(nonatomic, strong) NSString *token;

/**
 * setupContainView 创建Video渲染View,该控件承载着视频内容的展示。
 */
#if TARGET_OS_OSX
- (void)setupVideoWidget:(NSView *)view insertIndex:(unsigned int)idx;
#else
- (void)setupVideoWidget:(UIView *)view insertIndex:(unsigned int)idx;
#endif

/**
 * 移除Video渲染View
 */
- (void)removeVideoWidget;

/**
 * 设置播放开始时间
 */
- (void)setStartTime:(CGFloat)startTime;

/**
 * 启动从指定URL播放,此接口的全平台版本没有参数
 * @note 10.7版本开始，需要通过 {@link TXLiveBase#setLicence} 设置 Licence 后方可成功播放， 否则将播放失败（黑屏），全局仅设置一次即可。直播 Licence、短视频 Licence 和视频播放 Licence 均可使用，若您暂未获取上述 Licence ，可[快速免费申请测试版
 * Licence](https://cloud.tencent.com/act/event/License) 以正常播放，正式版 License 需[购买](https://cloud.tencent.com/document/product/881/74588#.E8.B4.AD.E4.B9.B0.E5.B9.B6.E6.96.B0.E5.BB.BA.E6.AD.A3.E5.BC.8F.E7.89.88-license)。
 *
 * 开始多媒体文件播放 注意此接口的全平台版本没有参数
 * 支持的视频格式包括：mp4、avi、mkv、wmv、m4v。
 * 支持的音频格式包括：mp3、wav、wma、aac。
 */
- (int)startVodPlay:(NSString *)url;

/**
 * 启动一个标准Fairplay drm播放
 *
 * 启动一个标准Fairplay drm播放
 */
- (int)startPlayDrm:(TXPlayerDrmBuilder *)drmBuilder;

/**
 * 通过fileid方式播放。
 * @note 10.7版本开始，需要通过 {@link TXLiveBase#setLicence} 设置 Licence 后方可成功播放， 否则将播放失败（黑屏），全局仅设置一次即可。直播 Licence、短视频 Licence 和视频播放 Licence 均可使用，若您暂未获取上述 Licence ，可[快速免费申请测试版
 * Licence](https://cloud.tencent.com/act/event/License) 以正常播放，正式版 License 需[购买](https://cloud.tencent.com/document/product/881/74588#.E8.B4.AD.E4.B9.B0.E5.B9.B6.E6.96.B0.E5.BB.BA.E6.AD.A3.E5.BC.8F.E7.89.88-license)。
 */
- (int)startVodPlayWithParams:(TXPlayerAuthParams *)params;

/**
 * 停止播放音视频流
 */
- (int)stopPlay;

/**
 * 是否正在播放
 */
- (bool)isPlaying;

/**
 * 暂停播放
 */
- (void)pause;

/**
 * 继续播放
 */
- (void)resume;

/**
 * 播放跳转到音视频流某个时间
 */
- (int)seek:(float)time;

/**
 * 播放跳转到音视频流某个时间
 * 注意：此接口 11.8 版本开始支持
 *
 * @param time 视频流时间点,单位秒(s),小数点后精确到3位
 * @param isAccurateSeek 是否精准 Seek
 *         -- YES: 表示精确 Seek，必须寻找到当前时间点，这个会比较耗时
 *         -- NO：表示非精准 Seek，也就是寻找前一个I帧
 */
- (void)seek:(float)time accurateSeek:(BOOL)isAccurateSeek;

/**
 * 播放跳转到音视频流某个PDT时间
 */
- (void)seekToPdtTime:(long long)pdtTimeMs;

/**
 * 获取当前播放时间
 */
- (float)currentPlaybackTime;

/**
 * 获取视频总时长
 */
- (float)duration;

/**
 * 可播放时长
 */
- (float)playableDuration;

/**
 * 视频宽度
 */
- (int)width;

/**
 * 视频高度
 */
- (int)height;

/**
 * 设置画面的方向
 *
 * @info 设置本地图像的顺时针旋转角度
 * @param rotation 支持 TRTCVideoRotation90 、 TRTCVideoRotation180 以及 TRTCVideoRotation270 旋转角度，默认值：TRTCVideoRotation0
 * @note 用于窗口渲染模式
 */
- (void)setRenderRotation:(TX_Enum_Type_HomeOrientation)rotation;

/**
 * 设置画面的裁剪模式
 *
 * @param mode 填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：TRTCVideoFillMode_Fit
 * @note 用于窗口渲染模式
 */
- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode;

/**
 * 设置静音
 */
- (void)setMute:(BOOL)bEnable;

/**
 * 设置音量大小
 *
 * @param volume 音量大小，100为原始音量，范围是：[0 ~ 150]，默认值为100
 */
- (void)setAudioPlayoutVolume:(int)volume;

/**
 * 设置音量均衡，响度范围：-70～0(LUFS)。注意：只对播放器高级版生效。
 *
 * @param value 关：AUDIO_NORMALIZATION_OFF (TXVodPlayConfig.h) ，开（标准）：AUDIO_NORMALIZATION_STANDARD (TXVodPlayConfig.h)
 */
- (void)setAudioNormalization:(float)value;

/**
 * snapshotCompletionBlock 通过回调返回当前图像
 */
#if TARGET_OS_OSX
- (void)snapshot:(void (^)(NSImage *))snapshotCompletionBlock;
#else
- (void)snapshot:(void (^)(UIImage *))snapshotCompletionBlock;
#endif

/**
 * 设置播放速率
 *
 * @param rate 播放速度
 */
- (void)setRate:(float)rate;

/**
 * 当播放地址为master playlist，返回支持的码率（清晰度）
 */
- (NSArray<TXBitrateItem *> *)supportedBitrates;

/**
 * 获取当前正在播放的码率索引
 */
- (NSInteger)bitrateIndex;

/**
 * 设置当前正在播放的码率索引，无缝切换清晰度。如果是自适用码率，设置为 `INDEX_AUTO`
 * 清晰度切换可能需要等待一小段时间。腾讯云支持多码率HLS分片对齐，保证最佳体验。
 */
- (void)setBitrateIndex:(NSInteger)index;

/**
 * 设置画面镜像
 */
- (void)setMirror:(BOOL)isMirror;

/**
 * 将当前vodPlayer附着至TRTC
 *
 * @param trtcCloud TRTC 实例指针
 * @note 用于辅流推送，绑定后音频播放由TRTC接管
 */
- (void)attachTRTC:(NSObject *)trtcCloud;

/**
 * 将当前vodPlayer和TRTC分离
 */
- (void)detachTRTC;

/**
 * 开始向TRTC发布辅路视频流
 */
- (void)publishVideo;

/**
 * 开始向TRTC发布辅路音频流
 */
- (void)publishAudio;

/**
 * 结束向TRTC发布辅路视频流
 */
- (void)unpublishVideo;

/**
 * 结束向TRTC发布辅路音频流
 */
- (void)unpublishAudio;

/**
 * 是否循环播放
 */
@property(nonatomic, assign) BOOL loop;

/**
 * 获取加固加密播放密钥
 */
+ (NSString *)getEncryptedPlayKey:(NSString *)key;

/**
 * 是否支持 Picture In Picture功能（‘画中画’功能）
 * 使用画中画能力时需要判断当前设备是否支持
 */
+ (BOOL)isSupportPictureInPicture;

/**
 * 是否支持 无缝切换 Picture In Picture功能（判断 高级版画中画功能 能否使用）
 * 使用无缝切换画中画功能，需要当前设备支持画中画功能、打开自动画中画功能（设置-通用-画中画-自动开启画中画）并且开通了高级版license权限[Licence](https://cloud.tencent.com/document/product/881/74588#.E8.B4.AD.E4.B9.B0.E5.B9.B6.E6.96.B0.E5.BB.BA.E6.AD.A3.E5.BC.8F.E7.89.88-license)
 */
+ (BOOL)isSupportSeamlessPictureInPicture;

/**
 * 无缝切换 Picture In Picture功能 是否允许
 * 无缝切换 Picture In Picture功能 属于高级版画中画功能，需要开通高级版license权限。此接口在集成高级版画中画功能并且开通权限以后，直接默认开启，不需要再进行设置
 *
 * @param enabled  无缝切换画中画功能是否允许，YES 表示允许 NO 表示不允许，默认为NO
 */
+ (void)setPictureInPictureSeamlessEnabled:(BOOL)enabled DEPRECATED_MSG_ATTRIBUTE("Deprecated ");

/**
 * 自动启动 Picture In Picture 是否允许（自动启动画中画控制开关）
 * 自动启动画中画功能属于高级版画中画能力，需要开通高级版license权限
 *
 * @param enabled 自动启动画中画功能是否允许，YES 表示允许  NO 表示不允许，默认为NO
 */
- (void)setAutoPictureInPictureEnabled:(BOOL)enabled;

/**
 * 进入画中画功能（此方法需要在Prepared后调用）
 */
- (void)enterPictureInPicture;

/**
 * 退出画中画功能
 */
- (void)exitPictureInPicture;

/**
 * 添加外挂字幕
 *
 * @param url  字幕地址
 * @param name  字幕的名称。如果添加多个字幕，字幕名称请设置为不同的名字，用于区分与其他添加的字幕，否则可能会导致字幕选择错误
 * @param mimeType  字幕类型，仅支持VVT和SRT格式，详细见 TXVodSDKEventDef.h 文件
 */
- (void)addSubtitleSource:(NSString *)url name:(NSString *)name mimeType:(TX_VOD_PLAYER_SUBTITLE_MIME_TYPE)mimeType;

/**
 * 选择轨道
 *
 * @param trackIndex 轨道的Index
 */
- (void)selectTrack:(NSInteger)trackIndex;

/**
 * 取消选择轨道
 *
 * @param trackIndex 轨道的Index
 */
- (void)deselectTrack:(NSInteger)trackIndex;

/**
 * 返回字幕轨道信息列表
 */
- (NSArray<TXTrackInfo *> *)getSubtitleTrackInfo;

/**
 * 返回音频轨道信息列表
 */
- (NSArray<TXTrackInfo *> *)getAudioTrackInfo;

/**
 * 设置字幕样式信息，可在播放后对字幕样式进行更新
 *
 * @param renderModel 字幕样式配置信息 {@link TXPlayerSubtitleRenderModel}。
 */
- (void)setSubtitleStyle:(TXPlayerSubtitleRenderModel *)renderModel;

/**
 * 设置扩展的Option参数
 */
- (void)setExtentOptionInfo:(NSDictionary<NSString *, id> *)extInfo;

/**
 * 设置扩展的Option参数
 */
- (void)setAutoMaxBitrate:(NSInteger)autoMaxBitrate;

@end
