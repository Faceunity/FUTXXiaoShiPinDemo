//
//  SoundMixView.h
//  TXXiaoShiPinDemo
//
//  Created by shengcui on 2018/7/23.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SoundMixViewDelegate;

@interface SoundMixView : UIView
@property (weak, nonatomic) id<SoundMixViewDelegate> delegate;
+ (instancetype)instantiateFromNib;
@end

@protocol SoundMixViewDelegate <NSObject>
@optional
- (void)soundMixView:(SoundMixView *)view didSelectMixIndex:(NSInteger)index;
- (void)soundMixView:(SoundMixView *)view didSelectVoiceChangeIndex:(NSInteger)index;
@end
