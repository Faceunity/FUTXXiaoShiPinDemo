//
//  VideoCutView.m
//  DeviceManageIOSApp
//
//  Created by rushanting on 2017/5/11.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "VideoCutView.h"
#import "VideoRangeConst.h"
#import "VideoRangeSlider.h"
#import "ColorMacro.h"
#import "UIView+Additions.h"
#import "SDKHeader.h"
#import <CoreImage/CoreImage.h>

@interface VideoCutView ()<VideoRangeSliderDelegate>

@end

@implementation VideoCutView
{
    CGFloat         _duration;          //视频时长
    NSString*       _videoPath;         //视频路径
    AVAsset*        _videoAsset;
    BOOL            _isContinue;
}

- (id)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath  videoAsset:(AVAsset *)videoAsset config:(RangeContentConfig *)config
{
    if (self = [super initWithFrame:frame]) {
        _videoPath = videoPath;
        _videoAsset = videoAsset;
        if (videoAsset == nil) {
            _videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        }
        
        _videoRangeSlider = [[VideoRangeSlider alloc] initWithFrame:self.bounds];
        [_videoRangeSlider setAppearanceConfig:config];
        [self addSubview:_videoRangeSlider];
        
        TXVideoInfo *videoMsg = [TXVideoInfoReader getVideoInfoWithAsset:_videoAsset];
        _duration   = videoMsg.duration;
        _videoRangeSlider.fps = videoMsg.fps;
        
        //显示微缩图列表
        _imageList = [NSMutableArray new];
        int imageNum = (int)config.imageCount;
        
        _isContinue = YES;
        
        UIGraphicsBeginImageContext(CGSizeMake(1, 1));
        UIImage *placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        CGFloat size = round(frame.size.height * [UIScreen mainScreen].scale);

        [TXVideoInfoReader getSampleImages:imageNum maxSize:CGSizeMake(size, size) videoAsset:_videoAsset progress:^BOOL(int number, UIImage *image) {
            if (!_isContinue) {
                return NO;
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{@autoreleasepool {
                    if (!_isContinue) {
                        return;
                    }
                    UIImage *img = image ?: placeholder;
                    
                    if (number == 1) {
                        _videoRangeSlider.delegate = self;
                        for (int i = 0; i < imageNum; i++) {
                            [_imageList addObject:img];
                        }
                        [_videoRangeSlider setImageList:_imageList];
                        [_videoRangeSlider setDurationMs:_duration];
                    } else {
                        _imageList[number-1] = img;
                        [_videoRangeSlider updateImage:img atIndex:number-1];
                    }
                }});
                return YES;
            }
        }];
      
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame pictureList:(NSArray *)pictureList  duration:(CGFloat)duration fps:(float)fps config:(RangeContentConfig *)config
{
    if (self = [super initWithFrame:frame]) {
        _duration   = duration;
        _imageList = [pictureList mutableCopy];
        
        _videoRangeSlider = [[VideoRangeSlider alloc] initWithFrame:self.bounds];
        [_videoRangeSlider setAppearanceConfig:config];
        _videoRangeSlider.fps = fps;
        [self addSubview:_videoRangeSlider];
        _videoRangeSlider.delegate = self;
        
        [_videoRangeSlider setImageList:_imageList];
        [_videoRangeSlider setDurationMs:_duration];
    }
    return self;
}

- (void)updateFrame:(CGFloat)duration
{
    
}

- (void)stopGetImageList
{
    _isContinue = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc
{
    NSLog(@"VideoCutView dealloc");
}

- (void)setPlayTime:(CGFloat)time
{
    _videoRangeSlider.currentPos = time;
}

- (void)setLeftPanHidden:(BOOL)isHidden
{
    [_videoRangeSlider setLeftPanHidden:isHidden];
}

- (void)setCenterPanHidden:(BOOL)isHidden
{
    [_videoRangeSlider setCenterPanHidden:isHidden];
}

- (void)setRightPanHidden:(BOOL)isHidden
{
    [_videoRangeSlider setRightPanHidden:isHidden];
}

- (void)setLeftPanFrame:(CGFloat)time
{
    [_videoRangeSlider setLeftPanFrame:time];
}

- (void)setCenterPanFrame:(CGFloat)time
{
    [_videoRangeSlider setCenterPanFrame:time];
}

- (void)setRightPanFrame:(CGFloat)time
{
    [_videoRangeSlider setRightPanFrame:time];
}

- (void)setColorType:(ColorType)colorType
{
    [_videoRangeSlider setColorType:colorType];
}

- (void)startColoration:(UIColor *)color alpha:(CGFloat)alpha
{
    [_videoRangeSlider startColoration:color alpha:alpha];
}

- (void)stopColoration
{
    [_videoRangeSlider stopColoration];
}

- (VideoColorInfo *)removeLastColoration:(ColorType)colorType
{
    return [_videoRangeSlider removeLastColoration:colorType];
}

- (void)removeColoration:(ColorType)colorType index:(NSInteger)index
{
    [_videoRangeSlider removeColoration:colorType index:index];
}

#pragma mark - VideoRangeDelegate
- (void)onVideoRangeTap:(CGFloat)tapTime
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeTap:)]){
        [self.delegate onVideoRangeTap:tapTime];
    }
}

//左拉
- (void)onVideoRangeLeftChanged:(VideoRangeSlider *)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeLeftChanged:)]){
        [self.delegate onVideoRangeLeftChanged:sender];
    }
}

- (void)onVideoRangeLeftChangeEnded:(VideoRangeSlider *)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeLeftChangeEnded:)]){
        _videoRangeSlider.currentPos = sender.leftPos;
        [self.delegate onVideoRangeLeftChangeEnded:sender];
    }
}

//中拉
- (void)onVideoRangeCenterChanged:(VideoRangeSlider *)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeCenterChanged:)]){
        [self.delegate onVideoRangeCenterChanged:sender];
    }
}

- (void)onVideoRangeCenterChangeEnded:(VideoRangeSlider *)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeCenterChangeEnded:)]){
        [self.delegate onVideoRangeCenterChangeEnded:sender];
    }
}

//右拉
- (void)onVideoRangeRightChanged:(VideoRangeSlider *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeRightChanged:)]){
        [self.delegate onVideoRangeRightChanged:sender];
    }
}

- (void)onVideoRangeRightChangeEnded:(VideoRangeSlider *)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoRangeRightChangeEnded:)]){
        _videoRangeSlider.currentPos = sender.leftPos;
        [self.delegate onVideoRangeRightChangeEnded:sender];
    }
}

- (void)onVideoRangeLeftAndRightChanged:(VideoRangeSlider *)sender {
    
}

//拖动缩略图条
- (void)onVideoRange:(VideoRangeSlider *)sender seekToPos:(CGFloat)pos {
    if(self.delegate && [self.delegate respondsToSelector:@selector(onVideoSeekChange:seekToPos:)]){
        [self.delegate onVideoSeekChange:sender seekToPos:pos];
    }
}

@end
