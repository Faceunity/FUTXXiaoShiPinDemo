//
//  VideoEffectSlider.h
//  TXLiteAVDemo
//
//  Created by xiang zhang on 2017/11/3.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDKHeader.h"

@protocol EffectSelectViewDelegate <NSObject>
-(void)onEffectBtnBeginSelect:(UIButton *)btn;
-(void)onEffectBtnEndSelect:(UIButton *)btn;
-(void)onEffectBtnSelected:(UIButton *)btn;
@end

@interface EffectInfo : NSObject
@property(nonatomic,strong) UIImage  *icon;
@property(nonatomic,strong) UIImage  *selectIcon;
@property(nonatomic,strong) NSMutableArray  *animateIcons;
@property(nonatomic,assign) BOOL  isSlow;
@property(nonatomic,strong) NSString *name;
@end

@interface EffectSelectView : UIView
@property (nonatomic,weak) id <EffectSelectViewDelegate> delegate;
/// 抬起手指时是否还原未选中状态
@property (nonatomic) BOOL momentary;
- (void)setEffectList:(NSArray<EffectInfo *> *)effecList;
- (void)setEffectList:(NSArray<EffectInfo *> *)effecList momentary:(BOOL)momentary;
@end
