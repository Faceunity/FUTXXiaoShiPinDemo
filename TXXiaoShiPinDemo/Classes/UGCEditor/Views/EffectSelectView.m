//
//  VideoEffectSlider.m
//  TXLiteAVDemo
//
//  Created by xiang zhang on 2017/11/3.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "EffectSelectView.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"

#define EFFCT_COUNT        4
#define EFFCT_IMAGE_WIDTH  50 * kScaleY
#define EFFCT_IMAGE_SPACE  20

@implementation EffectInfo
@end

@implementation EffectSelectView
{
    UIScrollView *_effectSelectView;
    NSMutableArray *_selectViewList;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _effectSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, self.width,EFFCT_IMAGE_WIDTH + 20)];
        [self addSubview:_effectSelectView];
        _selectViewList = [NSMutableArray array];
    }
    return self;
}

- (void)setEffectList:(NSArray<EffectInfo *> *)effecList
{
    [self setEffectList:effecList momentary:NO];
}

- (void)setEffectList:(NSArray<EffectInfo *> *)effecList momentary:(BOOL)momentary
{
    self.momentary = momentary;
    [_effectSelectView removeAllSubViews];
    [_selectViewList removeAllObjects];
    CGFloat space = floorf(20 * kScaleX);
    CGFloat buttonSize = floorf(EFFCT_IMAGE_WIDTH);
    for (int i = 0 ; i < effecList.count ; i ++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(space + (space + buttonSize) * i, 0, buttonSize, buttonSize)];
        if (effecList[i].animateIcons) {
            UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:btn.bounds];
            animatedImageView.animationImages = effecList[i].animateIcons;
            if (effecList[i].isSlow) {
                animatedImageView.animationDuration = 1.0 / 15 * effecList[i].animateIcons.count;
            }
            [animatedImageView startAnimating];
            [btn addSubview:animatedImageView];
        }else{
            [btn setImage:effecList[i].icon forState:UIControlStateNormal];
        }
        btn.layer.cornerRadius = EFFCT_IMAGE_WIDTH / 2.0;
        btn.layer.masksToBounds = YES;
        btn.titleLabel.numberOfLines = 0;
        btn.tag = i;
        [btn addTarget:self action:@selector(beginPress:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(endPress:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [btn  addTarget:self action:@selector(upInsidePress:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *selectView = [[UIImageView alloc]initWithFrame:btn.frame];
        [selectView setImage:effecList[i].selectIcon];
        selectView.hidden = YES;
        selectView.tag = i;
        [_selectViewList addObject:selectView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(btn.x, btn.bottom + 8, btn.width, 12)];
        label.text = effecList[i].name;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        
        [_effectSelectView addSubview:btn];
        [_effectSelectView addSubview:selectView];
        [_effectSelectView addSubview:label];
        _effectSelectView.contentSize = CGSizeMake(btn.right, buttonSize);
    }
    if (_effectSelectView.contentSize.width > self.width) {
         _effectSelectView.alwaysBounceHorizontal = YES;
    }else{
        _effectSelectView.alwaysBounceHorizontal = NO;
    }
}

//开始按压
-(void) beginPress: (UIButton *) button {
    CGFloat offset = _effectSelectView.contentOffset.x;
    if (offset < 0 || offset > _effectSelectView.contentSize.width - _effectSelectView.bounds.size.width) {
        // 在回弹区域会触发button事件被cancel,导致收不到 TouchEnd 事件
        return;
    }
    [self.delegate onEffectBtnBeginSelect:button];
    for (UIImageView *view in _selectViewList) {
        if (view.tag == button.tag) {
            view.hidden = NO;
        }else{
            view.hidden = YES;
        }
    }
}

//结束按压
-(void) endPress: (UIButton *) button {
    if (self.momentary) {
        [_selectViewList enumerateObjectsUsingBlock:^(UIImageView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
    }
    [self.delegate onEffectBtnEndSelect:button];
}

//按压
-(void) upInsidePress: (UIButton *) button {
    [self.delegate onEffectBtnSelected:button];
}
@end
