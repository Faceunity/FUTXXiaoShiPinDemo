//
//  BeautySettingPanel.h
//  RTMPiOSDemo
//
//  Created by rushanting on 2017/5/5.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDKHeader.h"

typedef NS_ENUM(NSUInteger, PannelMenuIndex) {
    PannelMenuIndexBeauty,
    PannelMenuIndexEffect,
    PannelMenuIndexMotion,
    PannelMenuIndexKoubei,
    PannelMenuIndexGreen
};

typedef NS_ENUM(NSInteger,DemoFilterType) {
    FilterType_None 		= 0,
    FilterType_biaozhun     ,   //标准滤镜
    FilterType_yinghong     ,   //樱红滤镜
    FilterType_yunshang     ,   //云裳滤镜
    FilterType_chunzhen     ,   //纯真滤镜
    FilterType_bailan       ,   //白兰滤镜
    FilterType_yuanqi       ,   //元气滤镜
    FilterType_chaotuo      ,   //超脱滤镜
    FilterType_xiangfen     ,   //香氛滤镜
    FilterType_white        ,   //美白滤镜
    FilterType_langman 		,   //浪漫滤镜
    FilterType_qingxin 		,   //清新滤镜
    FilterType_weimei 		,   //唯美滤镜
    FilterType_fennen 		,   //粉嫩滤镜
    FilterType_huaijiu 		,   //怀旧滤镜
    FilterType_landiao 		,   //蓝调滤镜
    FilterType_qingliang    ,   //清凉滤镜
    FilterType_rixi 		,   //日系滤镜
};

@protocol BeautySettingPanelDelegate <NSObject>
- (void)onSetBeautyStyle:(TXVideoBeautyStyle)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel;
- (void)onSetMixLevel:(float)mixLevel;
- (void)onSetEyeScaleLevel:(float)eyeScaleLevel;
- (void)onSetFaceScaleLevel:(float)faceScaleLevel;
- (void)onSetFaceBeautyLevel:(float)beautyLevel;
- (void)onSetFaceVLevel:(float)vLevel;
- (void)onSetChinLevel:(float)chinLevel;
- (void)onSetFaceShortLevel:(float)shortLevel;
- (void)onSetNoseSlimLevel:(float)slimLevel;
- (void)onSetFilter:(UIImage*)filterImage;
- (void)onSetGreenScreenFile:(NSURL *)file;
- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir;

@end

@protocol BeautyLoadPituDelegate <NSObject>
- (void)onLoadPituStart;
- (void)onLoadPituProgress:(CGFloat)progress;
- (void)onLoadPituFinished;
- (void)onLoadPituFailed;
@end

@interface BeautySettingPanel : UIView
@property (nonatomic, assign) NSInteger currentFilterIndex;
@property (nonatomic, readonly) NSString* currentFilterName;
@property (nonatomic, weak) id<BeautySettingPanelDelegate> delegate;
@property (nonatomic, weak) id<BeautyLoadPituDelegate> pituDelegate;

- (void)resetValues;
+ (NSUInteger)getHeight;
- (void)changeFunction:(PannelMenuIndex)i;
- (UIImage*)filterImageByIndex:(NSInteger)index;
- (float)filterMixLevelByIndex:(NSInteger)index;
@end
