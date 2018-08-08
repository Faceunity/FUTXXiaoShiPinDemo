//
//  VideoRecordMusicView.h
//  TXLiteAVDemo
//
//  Created by zhangxiang on 2017/9/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol VideoRecordMusicViewDelegate <NSObject>
-(void)onBtnMusicSelected;
-(void)onBtnMusicStoped;
-(void)onBGMValueChange:(CGFloat)percent;
-(void)onVoiceValueChange:(CGFloat)percent;
-(void)onBGMRangeChange:(CGFloat)startPercent endPercent:(CGFloat)endPercent;

@optional
-(void)selectAudioEffect:(NSInteger)index;
-(void)selectAudioEffect2:(NSInteger)index;
@end

@interface TCVideoRecordMusicView : UIView
@property(nonatomic,weak) id<VideoRecordMusicViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame needEffect:(BOOL)needEffect;
-(void) resetVolume;
-(void) resetCutView;
@end
