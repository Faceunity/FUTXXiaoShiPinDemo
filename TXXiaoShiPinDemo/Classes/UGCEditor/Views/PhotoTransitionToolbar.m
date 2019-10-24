//
//  TransitionView.m
//  TXLiteAVDemo_Enterprise
//
//  Created by xiang zhang on 2018/5/11.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "PhotoTransitionToolbar.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "VerticalButton.h"

#define TRANSITIN_IMAGE_WIDTH  50 * kScaleY
#define TRANSITIN_IMAGE_SPACE  10

@implementation PhotoTransitionToolbar
{
    UIScrollView *_transitionView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *transitionNames = @[NSLocalizedString(@"TransitionView.Horizontal", nil),
                                     NSLocalizedString(@"TransitionView.Vertical", nil),
                                     NSLocalizedString(@"TransitionView.ZoomIn", nil),
                                     NSLocalizedString(@"TransitionView.ZoomOut", nil),
                                     NSLocalizedString(@"TransitionView.Rotation", nil),
                                     NSLocalizedString(@"TransitionView.FadeInFadeOut", nil)];
        NSArray *imageNames = @[@"Horizontal", @"Vertical", @"ZoomIn", @"ZoomOut", @"Rotation", @"FadeInFadeOut"];
        NSAssert(transitionNames.count == imageNames.count, @"Count mismatch, please check");
        
        _transitionView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, self.width,TRANSITIN_IMAGE_WIDTH)];
        _transitionView.showsVerticalScrollIndicator = NO;
        _transitionView.showsHorizontalScrollIndicator = NO;
    
        CGFloat itemWidth = floor(frame.size.width / imageNames.count);
        CGFloat halfSpace = 2;
        
        for (int i = 0 ; i < transitionNames.count ; i ++){
            UIButton *btn = [[VerticalButton alloc] initWithTitle:transitionNames[i]];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [btn setImage:[UIImage imageNamed:[imageNames[i] stringByAppendingString:@"-normal"]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:[imageNames[i] stringByAppendingString:@"-press"]] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor colorWithWhite:0.94 alpha:1] forState:UIControlStateSelected];
            btn.tag = i;
            
            [btn setFrame:CGRectMake(itemWidth * i + halfSpace, 0, itemWidth - halfSpace * 2, TRANSITIN_IMAGE_WIDTH)];
            
            [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_transitionView addSubview:btn];
            
            if (i == 0) {
                [self resetBtnColor:btn];
            }
        }
        [self addSubview:_transitionView];
    }
    return self;
}

- (void)onBtnClick:(UIButton *)btn
{
    if (btn.tag == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoTransitionUpDownSlipping)]) {
            [_delegate onVideoTransitionLefRightSlipping];
        }
    }
    else if (btn.tag == 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoTransitionUpDownSlipping)]) {
            [_delegate onVideoTransitionUpDownSlipping];
        }
    }
    else if (btn.tag == 2){
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoTransitionEnlarge)]) {
            [_delegate onVideoTransitionEnlarge];
        }
    }
    else if (btn.tag == 3){
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoTransitionNarrow)]) {
            [_delegate onVideoTransitionNarrow];
        }
    }
    else if (btn.tag == 4){
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoTransitionNarrow)]) {
            [_delegate onVideoTransitionRotationalScaling];
        }
    }
    else if (btn.tag == 5){
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoTransitionNarrow)]) {
            [_delegate onVideoTransitionFadeinFadeout];
        }
    }
    [self resetBtnColor:btn];
}

- (void)resetBtnColor:(UIButton *)btn
{
    for (UIButton * btn in _transitionView.subviews) {
        btn.selected = NO;
    }
    btn.selected = YES;
}
@end
