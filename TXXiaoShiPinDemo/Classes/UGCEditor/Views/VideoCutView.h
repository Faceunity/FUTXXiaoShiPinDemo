//
//  VideoCutView.h
//  DeviceManageIOSApp
//
//  Created by rushanting on 2017/5/11.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoRangeSlider.h"

/**
 视频编辑的裁剪view
 */

@protocol VideoCutViewDelegate <NSObject>
@optional
- (void)onVideoRangeTap:(CGFloat)tapTime;

- (void)onVideoRangeLeftChanged:(VideoRangeSlider*)sender;
- (void)onVideoRangeLeftChangeEnded:(VideoRangeSlider*)sender;

- (void)onVideoRangeCenterChanged:(VideoRangeSlider*)sender;
- (void)onVideoRangeCenterChangeEnded:(VideoRangeSlider*)sender;

- (void)onVideoRangeRightChanged:(VideoRangeSlider*)sender;
- (void)onVideoRangeRightChangeEnded:(VideoRangeSlider*)sender;

- (void)onVideoSeekChange:(VideoRangeSlider*)sender seekToPos:(CGFloat)pos;
@end

@interface VideoCutView : UIView

@property (nonatomic, strong)  VideoRangeSlider *videoRangeSlider;  //缩略图条
@property (nonatomic, weak) id<VideoCutViewDelegate> delegate;
@property (nonatomic, strong)  NSMutableArray  *imageList;         //缩略图列表

- (id)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath  videoAssert:(AVAsset *)videoAssert config:(RangeContentConfig *)config;
- (id)initWithFrame:(CGRect)frame pictureList:(NSArray *)pictureList  duration:(CGFloat)duration config:(RangeContentConfig *)config;
- (void)updateFrame:(CGFloat)duration;
- (void)stopGetImageList;

- (void)setPlayTime:(CGFloat)time;

- (void)setLeftPanHidden:(BOOL)isHidden;
- (void)setCenterPanHidden:(BOOL)isHidden;
- (void)setRightPanHidden:(BOOL)isHidden;

- (void)setLeftPanFrame:(CGFloat)time;
- (void)setCenterPanFrame:(CGFloat)time;
- (void)setRightPanFrame:(CGFloat)time;

- (void)setColorType:(ColorType)colorType;
- (void)startColoration:(UIColor *)color alpha:(CGFloat)alpha;
- (void)stopColoration;

- (VideoColorInfo *)removeLastColoration:(ColorType)colorType;
- (void)removeColoration:(ColorType)colorType index:(NSInteger)index;
@end
