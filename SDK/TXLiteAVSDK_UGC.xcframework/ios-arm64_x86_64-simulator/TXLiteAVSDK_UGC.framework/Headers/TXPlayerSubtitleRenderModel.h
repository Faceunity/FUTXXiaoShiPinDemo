//  Copyright © 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

LITEAV_EXPORT @interface TXPlayerSubtitleRenderModel : NSObject

/// canvasWidth和canvasHeight是字幕渲染画布的大小，
/// canvasWidth和canvasHeight的比例必须和视频的宽高比一致，否则渲染出的字体会变形。
/// 如果设置了该两个参数，paramFlags须置位TXPlayerSubtitleRenderParamFlagCanvasWidth和TXPlayerSubtitleRenderParamFlagCanvasHeight
/// 如果不设置，播放器会取当前视频的大小作为渲染画布的大小。
@property(nonatomic, assign) int canvasWidth;
@property(nonatomic, assign) int canvasHeight;

/// font family name
/// iOS默认为"Helvetica"
/// 注意不要跟font name混淆，比如"Helvetica-Bold"是font name，其family Helvetica
/// familyName不受paramFlags的控制，字符串不为空则认为已设置
@property(nonatomic, copy) NSString *familyName;

/// 字体大小
/// 如果设置了fontSize，则必须设置canvasWidth和canvasHeight，否则内部不知道以什么大小为参考来渲染字体
/// 如果设置了fontSize，paramFlags须置位TPSubtitleRenderParamFlagFontSize
/// 如果不设置fontSize，内部会使用默认的字体大小
@property(nonatomic, assign) float fontSize;

/// 字体缩放比例 vtt css专用
/// 使用fontScale乘以vtt设定的font-size: em值再适应视频宽
/// 如果设置了fontScale，paramFlags须置位TP_SUBTITLE_PARAM_FLAG_FONT_SCALE
/// 最终字体像素为fontScale * vtt em * 16 * canvas width(video width) / default width(491)
/// fontScale默认1.0, 视频宽491像素时, 中文字号设定为16像素大小, 将vtt文件内字体大小设定为1em(font-size: 1.00em;)
/// 参考https://developer.mozilla.org/zh-CN/docs/Web/CSS/font-size#ems
/// 如果未设置则采用fontSize
@property(nonatomic, assign) float fontScale;

/// 字体颜色，ARGB格式
/// 如果设置了fontColor，paramFlags须置位TXPlayerSubtitleRenderParamFlagOutlineColor
/// 如果不设置，默认为白色不透明
@property(nonatomic, assign) uint32_t fontColor;

/// 描边宽度
/// 如果设置了outlineWidth，则必须设置canvasWidth和canvasHeight，否则内部不知道以什么大小为参考来渲染描边
/// 如果设置了outlineWidth，paramFlags须置位TPSubtitleRenderParamFlagOutlineWidth
/// 如果不设置，内部会使用默认的描边宽度
@property(nonatomic, assign) float outlineWidth;

/// 描边颜色，ARGB格式
/// 如果设置了outlineColor，paramFlags须置位TPSubtitleRenderParamFlagOutlineColor
/// 如果不设置，默认为黑色不透明
@property(nonatomic, assign) uint32_t outlineColor;

/// 字体样式，是否为粗体
@property(nonatomic, assign) BOOL isBondFontStyle;

/// 行距
/// 如果设置了lineSpace，则必须设置canvasWidth和canvasHeight
/// 如果设置了lineSpace，paramFlags须置位TXPlayerSubtitleRenderParamFlagLineSpace
/// 如果不设置，内部会使用默认的行距
@property(nonatomic, assign) float lineSpace;

/**
 * 以下startMargin、endMargin和yMargin定义字幕的绘制区域，如果不设置，则使用字幕文件中的设置，如果字幕文件也没有定义，则使用默认的
 * 注意：一旦设置了startMargin、endMargin和yMargin，而字幕文件也定义了这几个参数的一个或多个，则会覆盖字幕文件中相应的参数。
 * 下面示意图描绘了水平书写方向下这几个参数的意义，请借助每个参数的注释来理解
 *   \--------------------------------------------------------------------------------------------
 * |                                                                                                                |
 * |                                                                                                                |
 * |                                                                                                                |
 * |                                ________________________                                |
 * |----- startMargin -----|       This is subtitle text          |------endMargin-----  |
 * |                                |_______________________|                                 |
 * |                                                         | yMargin                                         |
 *   \--------------------------------------------------------------------------------------------
 */
/// 沿着字幕文本方向的边距，根据不同的书写方向意义不同。
/// startMargin是一个比例值，取值范围[0, 1]，即相对于视频画面大小的比例。
/// 对于水平书写方向，startMargin表示字幕左边距离视频画面左边的距离，比如startMargin=0.05则边距为视频宽度的0.05倍（5%）
/// 对于垂直书写方向（无论从右到左还是从左到右），startMargin表示字幕顶部距离视频画面顶部的距离，比如startMargin=0.05则边距为视频高度的0.05倍（5%）
/// 如果设置了startMargin，paramFlags须置位TXPlayerSubtitleRenderParamFlagStartMargin
@property(nonatomic, assign) float startMargin;

/// 沿着字幕文本方向的边距，根据不同的书写方向意义不同。
/// endMargin是一个比例值，取值范围[0, 1]，即相对于视频画面大小的比例。
/// 对于水平书写方向，endMargin表示字幕右边距离视频画面右边的距离，比如endMargin=0.05则边距为视频宽度的0.05倍（5%）
/// 对于垂直书写方向（无论从右到左还是从左到右），endMargin表示字幕底部距离视频画面底部的距离，比如endMargin=0.05则边距为视频高度的0.05倍（5%）
/// 如果设置了endMargin，paramFlags须置位TXPlayerSubtitleRenderParamFlagEndMargin
@property(nonatomic, assign) float endMargin;

/// 垂直字幕文本方向的边距，根据不同的书写方向意义不同。
/// yMargin为一个比例值，取值范围[0, 1]，即相对于视频画面大小的比例
/// 对于水平书写方向，yMargin表示字幕底部距离视频画面底部的距离，比如yMargin=0.05则边距为视频高度的0.05倍（5%）
/// 对于垂直、从右至左书写方向，yMargin表示字幕右边距离视频画面右边的距离，比如yMargin=0.05则边距为视频宽度的0.05倍（5%）
/// 对于垂直、从左至右书写方向，yMargin表示字幕左边距离视频画面左边的距离，比如yMargin=0.05则边距为视频宽度的0.05倍（5%）
/// 如果设置了verticalMargin，paramFlags须置位TXPlayerSubtitleRenderParamFlagVerticalMargin
@property(nonatomic, assign) float verticalMargin;

@end
