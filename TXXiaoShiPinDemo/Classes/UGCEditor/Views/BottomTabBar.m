//
//  BottomTabBar.m
//  DeviceManageIOSApp
//
//  Created by rushanting on 2017/5/11.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "BottomTabBar.h"
#import "ColorMacro.h"
#import "UIView+Additions.h"

#define kButtonCount 6

@implementation BottomTabBar
{
    UIView*         _contentView;
    UIButton*       _btnMusic;      //音乐
    UILabel*        _labelMusic;    //音乐
    UIButton*       _btnEffect;     //特效
    UILabel*        _labelEffect;   //特效
    UIButton*       _btnTime;       //时间特效
    UILabel*        _labelTime;     //时间特效
    UIButton*       _btnFilter;     //滤镜
    UILabel*        _labelFilter;   //滤镜
    UIButton*       _btnPaster;     //贴纸
    UILabel*        _labelPaster;   //贴纸
    UIButton*       _btnText;       //字幕
    UILabel*        _labelText;     //字幕
    BOOL _isHidden;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];

        _btnMusic = [[UIButton alloc] init];
        [_btnMusic setImage:[UIImage imageNamed:@"music_nomal"] forState:UIControlStateNormal];
        [_btnMusic setImage:[UIImage imageNamed:@"music_press"] forState:UIControlStateHighlighted];
        [_btnMusic addTarget:self action:@selector(onMusicBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnMusic];
        
        _labelMusic = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelMusic.text = @"音乐";
        _labelMusic.font = [UIFont systemFontOfSize:10];
        _labelMusic.textColor = [UIColor whiteColor];
        _labelMusic.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_labelMusic];
        
        _btnEffect = [[UIButton alloc] init];
        [_btnEffect setImage:[UIImage imageNamed:@"filter_nomal"] forState:UIControlStateNormal];
        [_btnEffect setImage:[UIImage imageNamed:@"filter_press"] forState:UIControlStateHighlighted];
        [_btnEffect addTarget:self action:@selector(onEffectBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnEffect];
        
        _labelEffect = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelEffect.text = @"滤镜";
        _labelEffect.font = [UIFont systemFontOfSize:10];
        _labelEffect.textColor = [UIColor whiteColor];
        _labelEffect.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_labelEffect];
        
        _btnTime = [[UIButton alloc] init];
        [_btnTime setImage:[UIImage imageNamed:@"speed_nomal"] forState:UIControlStateNormal];
        [_btnTime setImage:[UIImage imageNamed:@"speed_press"] forState:UIControlStateHighlighted];
        [_btnTime addTarget:self action:@selector(onTimeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnTime];
        
        _labelTime = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelTime.text = @"速度";
        _labelTime.font = [UIFont systemFontOfSize:10];
        _labelTime.textColor = [UIColor whiteColor];
        _labelTime.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_labelTime];

        _btnFilter = [[UIButton alloc] init];
        [_btnFilter setImage:[UIImage imageNamed:@"color_nomal"] forState:UIControlStateNormal];
        [_btnFilter setImage:[UIImage imageNamed:@"color_press"] forState:UIControlStateHighlighted];
        [_btnFilter addTarget:self action:@selector(onFilterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnFilter];
        
        _labelFilter = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelFilter.text = @"色调";
        _labelFilter.font = [UIFont systemFontOfSize:10];
        _labelFilter.textColor = [UIColor whiteColor];
        _labelFilter.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_labelFilter];

        _btnPaster = [[UIButton alloc] init];
        [_btnPaster setImage:[UIImage imageNamed:@"paster_normal"] forState:UIControlStateNormal];
        [_btnPaster setImage:[UIImage imageNamed:@"paster_press"] forState:UIControlStateHighlighted];
        [_btnPaster addTarget:self action:@selector(onPasterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnPaster];
        
        _labelPaster = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelPaster.text = @"贴纸";
        _labelPaster.font = [UIFont systemFontOfSize:10];
        _labelPaster.textColor = [UIColor whiteColor];
        _labelPaster.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_labelPaster];
        
        _btnText = [[UIButton alloc] init];
        [_btnText setImage:[UIImage imageNamed:@"subtitle_normal"] forState:UIControlStateNormal];
        [_btnText setImage:[UIImage imageNamed:@"subtitle_press"] forState:UIControlStateHighlighted];
        [_btnText addTarget:self action:@selector(onTextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_btnText];
        
        _labelText = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelText.text = @"字幕";
        _labelText.font = [UIFont systemFontOfSize:10];
        _labelText.textColor = [UIColor whiteColor];
        _labelText.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_labelText];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buttonWidth= self.width / kButtonCount;
    int i = 0;
    _btnMusic.frame = CGRectMake(buttonWidth * i++, 0, buttonWidth, self.height);
    _btnEffect.frame = CGRectMake(buttonWidth * i++, 0, buttonWidth, self.height);
    _btnTime.frame = CGRectMake(buttonWidth * i++, 0, buttonWidth, self.height);
    _btnFilter.frame = CGRectMake(buttonWidth * i++, 0, buttonWidth, self.height);
    _btnPaster.frame = CGRectMake(buttonWidth * i++, 0, buttonWidth, self.height);
    _btnText.frame = CGRectMake(buttonWidth * i++, 0, buttonWidth, self.height);
    
    CGFloat yOffset = 26 * kScaleY;
    _labelMusic.frame = CGRectOffset(_btnMusic.frame, 0, yOffset);
    _labelEffect.frame = CGRectOffset(_btnEffect.frame, 0, yOffset);
    _labelTime.frame = CGRectOffset(_btnTime.frame, 0, yOffset);
    _labelFilter.frame = CGRectOffset(_btnFilter.frame, 0, yOffset);
    _labelPaster.frame = CGRectOffset(_btnPaster.frame, 0, yOffset);
    _labelText.frame = CGRectOffset(_btnText.frame, 0, yOffset);
}

- (void)setHidden:(BOOL)hidden
{
    if (_isHidden == hidden) return;
    _isHidden = hidden;
    CGFloat height = self.frame.size.height;
    if (hidden) {
        if (_contentView.bottom > height) return;
        [UIView animateWithDuration:0.1 animations:^{
            _contentView.frame = CGRectOffset(_contentView.frame, 0, 62 * kScaleY);
            _contentView.alpha = 0.0;
        }];
    }else{
        if (_contentView.bottom <= height) return;
        [UIView animateWithDuration:0.5 animations:^{
            _contentView.frame = CGRectOffset(_contentView.frame, 0, -62 * kScaleY);
            _contentView.alpha = 1.0;
        }];
    }
}

- (BOOL)isHidden {
    return _isHidden;
}

#pragma mark - click handle
- (void)onMusicBtnClicked
{
    [self.delegate onMusicBtnClicked];
}

- (void)onTimeBtnClicked
{
    [self.delegate onTimeBtnClicked];
}

- (void)onEffectBtnClicked
{
    [self.delegate onEffectBtnClicked];
}

- (void)onFilterBtnClicked
{
    [self.delegate onFilterBtnClicked];
}


- (void)onTextBtnClicked
{
    [self.delegate onTextBtnClicked];
}

- (void)onPasterBtnClicked
{
    [self.delegate onPasterBtnClicked];
}

@end
