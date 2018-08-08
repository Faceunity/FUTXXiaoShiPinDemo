//
//  VideoRecordMusicView.m
//  TXLiteAVDemo
//
//  Created by zhangxiang on 2017/9/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TCVideoRecordMusicView.h"
#import "ColorMacro.h"
#import "UIView+Additions.h"
#import "TCBGMSliderCutView.h"
@interface TCVideoRecordMusicView() <BGMCutDelegate>{
    
}
@end

@implementation TCVideoRecordMusicView
{
    UISlider *_sldVolumeForBGM;
    UISlider *_sldVolumeForVoice;
    TCBGMSliderCutView* _musicCutSlider;
    UILabel* _startTimeLabel;
    TCBGMSliderCutViewConfig* sliderConfig;
    
    NSMutableArray* _audioEffectArry;
    NSMutableArray* _audioEffectArry2;
    UIScrollView* _audioScrollView;
    UIScrollView* _audioScrollView2;
}

-(instancetype)initWithFrame:(CGRect)frame needEffect:(BOOL)needEffect;
{
    self = [super initWithFrame:frame];
    if (self) {
        _audioEffectArry = [NSMutableArray arrayWithObjects:@"原声", @"KTV", @"房间", @"会堂", @"低沉", @"洪亮", @"金属", @"磁性", nil];
        _audioEffectArry2 = [NSMutableArray arrayWithObjects:@"原声", @"熊孩子", @"萝莉", @"大叔", @"重金属", @"外国人", @"困兽", @"死肥仔", @"强电流", @"重机械", @"空灵", nil];
        [self initUI:needEffect];
    }
    return self;
}

-(void)initUI:(BOOL)needEffect{
    self.backgroundColor = [UIColor clearColor];
    //***
    //混响，功能展示用，暂时先放这里
    if (needEffect) {
        CGFloat btnSpace = 10;
        CGFloat btnWidth = 40 * kScaleY;
        _audioScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, self.width, btnWidth)];
        _audioScrollView.contentSize = CGSizeMake((btnWidth + btnSpace) * _audioEffectArry.count, btnWidth);
        _audioScrollView.showsVerticalScrollIndicator = NO;
        _audioScrollView.showsHorizontalScrollIndicator = NO;
        for (int i=0; i<_audioEffectArry.count; ++i) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnSpace +(btnWidth + btnSpace) * i, 0, btnWidth, btnWidth)];
            btn.titleLabel.font = [UIFont systemFontOfSize:12.f];
            [btn setTitle:[_audioEffectArry objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:btnWidth/2];
            [btn addTarget:self action:@selector(selectEffect:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [_audioScrollView addSubview:btn];
            
            if (i == 0) {
                btn.selected = YES;
                [btn setBackgroundColor:[UIColor redColor]];
            }
        }
        
        //变声类型
        _audioScrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _audioScrollView.bottom + 5, self.width, btnWidth)];
        _audioScrollView2.contentSize = CGSizeMake((btnWidth + btnSpace) * _audioEffectArry2.count, btnWidth);
        _audioScrollView2.showsVerticalScrollIndicator = NO;
        _audioScrollView2.showsHorizontalScrollIndicator = NO;
        for (int i=0; i<_audioEffectArry2.count; ++i) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnSpace +(btnWidth + btnSpace) * i, 0, btnWidth, btnWidth)];
            btn.titleLabel.font = [UIFont systemFontOfSize:12.f];
            [btn setTitle:[_audioEffectArry2 objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:btnWidth/2];
            [btn addTarget:self action:@selector(selectEffect2:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [_audioScrollView2 addSubview:btn];
            
            if (i == 0) {
                btn.selected = YES;
                [btn setBackgroundColor:[UIColor redColor]];
            }
        }
        [self addSubview:_audioScrollView];
        [self addSubview:_audioScrollView2];
    }

    
    //BGM
    UIButton *btnSelectBGM = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 90 * kScaleX, needEffect ? _audioScrollView2.bottom + 5 : 5, 30, 30)];
    [btnSelectBGM setImage:[UIImage imageNamed:@"music_change_normal"] forState:UIControlStateNormal];
    [btnSelectBGM setImage:[UIImage imageNamed:@"music_change_press"] forState:UIControlStateHighlighted];
    [btnSelectBGM addTarget:self action:@selector(onBtnMusicSelected) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnStopBGM = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 36 * kScaleX,needEffect ? _audioScrollView2.bottom + 5 : 5, 30, 30)];
    [btnStopBGM setImage:[UIImage imageNamed:@"music_delete_normal"] forState:UIControlStateNormal];
    [btnStopBGM setImage:[UIImage imageNamed:@"music_delete_press"] forState:UIControlStateHighlighted];
    [btnStopBGM addTarget:self action:@selector(onBtnMusicStoped) forControlEvents:UIControlEventTouchUpInside];

    UILabel *labVolumeForVoice = [[UILabel alloc] initWithFrame:CGRectMake(15, btnSelectBGM.bottom + 10, 80, 16)];
    [labVolumeForVoice setText:@"录音音量"];
    [labVolumeForVoice setFont:[UIFont systemFontOfSize:14.f]];
    labVolumeForVoice.textColor = UIColorFromRGB(0xFFFFFF);
    _sldVolumeForVoice = [[UISlider alloc] initWithFrame:CGRectMake(labVolumeForVoice.left, labVolumeForVoice.bottom + 10,self.width - 30, 20)];
    _sldVolumeForVoice.minimumValue = 0;
    _sldVolumeForVoice.maximumValue = 2;
    _sldVolumeForVoice.value = 1;
    [_sldVolumeForVoice setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sldVolumeForVoice setMinimumTrackTintColor:RGB(238, 100, 85)];
    [_sldVolumeForVoice setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sldVolumeForVoice addTarget:self action:@selector(onVoiceValueChange:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *labVolumeForBGM = [[UILabel alloc] initWithFrame:CGRectMake(labVolumeForVoice.left, _sldVolumeForVoice.bottom + 20 , 80 , 16)];
    [labVolumeForBGM setText:@"背景音音量"];
    [labVolumeForBGM setFont:[UIFont systemFontOfSize:14.f]];
    labVolumeForBGM.textColor = UIColorFromRGB(0xFFFFFF);
    _sldVolumeForBGM = [[UISlider alloc] initWithFrame:CGRectMake(labVolumeForVoice.left, labVolumeForBGM.bottom + 10,self.width - 30, 20)];
    _sldVolumeForBGM.minimumValue = 0;
    _sldVolumeForBGM.maximumValue = 2;
    _sldVolumeForBGM.value = 1;
    [_sldVolumeForBGM setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sldVolumeForBGM setMinimumTrackTintColor:RGB(238, 100, 85)];
    [_sldVolumeForBGM setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sldVolumeForBGM addTarget:self action:@selector(onBGMValueChange:) forControlEvents:UIControlEventValueChanged];
    
    _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,_sldVolumeForBGM.bottom + 20,200,16)];
    [_startTimeLabel setTextColor:[UIColor whiteColor]];
    [_startTimeLabel setFont:[UIFont systemFontOfSize:14.f]];
    [_startTimeLabel setText:[NSString stringWithFormat:@"当前从%@开始",[TCBGMSliderCutView timeString:0]]];
    
    [self addSubview:btnSelectBGM];
    [self addSubview:btnStopBGM];
    [self addSubview:labVolumeForBGM];
    [self addSubview:_sldVolumeForBGM];
    [self addSubview:labVolumeForVoice];
    [self addSubview:_sldVolumeForVoice];
    [self addSubview:_startTimeLabel];
    [self freshCutView:150];
}

-(void) freshCutView:(CGFloat) duration{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [_musicCutSlider removeFromSuperview];
        //1.thumbHeight + 2* borderHeight =_musicCutSlider.frame.y;
        //2._musicCutSlider.frame.y目前只支持40
        sliderConfig = [TCBGMSliderCutViewConfig new];
        sliderConfig.duration = duration;
        sliderConfig.frame = CGRectMake(15, _startTimeLabel.bottom + 10, self.width - 30, 54);
        _musicCutSlider = [[TCBGMSliderCutView alloc] initWithImage:[UIImage imageNamed:@"wave_chosen"] config:sliderConfig];
        _musicCutSlider.delegate = self;
        [self addSubview:_musicCutSlider];
    });
}

-(void)onBtnMusicSelected
{
    if (_delegate && [_delegate respondsToSelector:@selector(onBtnMusicSelected)]) {
        [_delegate onBtnMusicSelected];
    }
}

-(void) resetCutView{
    [_musicCutSlider resetCutView];
}

- (void)selectEffect:(UIButton *)button {
    for(UIView *view in _audioScrollView.subviews){
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
            [btn setBackgroundColor:[UIColor clearColor]];
        }
    }
    button.selected = YES;
    [button setBackgroundColor:[UIColor redColor]];
    if (self.delegate) [self.delegate selectAudioEffect:button.tag];
}

- (void)selectEffect2:(UIButton *)button {
    for(UIButton *view in _audioScrollView2.subviews){
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
            [btn setBackgroundColor:[UIColor clearColor]];
        }
    }
    button.selected = YES;
    [button setBackgroundColor:[UIColor redColor]];
    if (self.delegate) [self.delegate selectAudioEffect2:button.tag >= 5 ? button.tag + 1 : button.tag];
}

-(void)onBtnMusicStoped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onBtnMusicStoped)]) {
        [_delegate onBtnMusicStoped];
    }
}

-(void)onBGMValueChange:(UISlider*)slider
{
    if (_delegate && [_delegate respondsToSelector:@selector(onBGMValueChange:)]) {
        [_delegate onBGMValueChange:slider.value];
    }
}

-(void)onVoiceValueChange:(UISlider*)slider
{
    if (_delegate && [_delegate respondsToSelector:@selector(onVoiceValueChange:)]) {
        [_delegate onVoiceValueChange:slider.value];
    }
}

#pragma mark - RangeContentDelegate
- (void)onRangeLeftChanged:(TCBGMSliderCutView*)sender percent:(CGFloat)percent{
    if(sliderConfig){
        [_startTimeLabel setText:[NSString stringWithFormat:@"当前从%@开始",[TCBGMSliderCutView timeString:percent*sliderConfig.duration]]];
    }
    else{
        [_startTimeLabel setText:[NSString stringWithFormat:@"当前从%@开始",[TCBGMSliderCutView timeString:0]]];
    }
}

- (void)onRangeLeftChangeEnded:(TCBGMSliderCutView*)sender percent:(CGFloat)percent
{
//    NSLog(@"end:%f",percent*sliderConfig.duration);
    if (_delegate && [_delegate respondsToSelector:@selector(onBGMRangeChange:endPercent:)]) {
        [_delegate onBGMRangeChange:_musicCutSlider.leftScale endPercent:_musicCutSlider.rightScale];
    }
}

- (void)onRangeRightChangeEnded:(id)sender
{
//    NSLog(@"left:%f right:%f",_musicCutSlider.leftScale, _musicCutSlider.rightScale);
    if (_delegate && [_delegate respondsToSelector:@selector(onBGMRangeChange:endPercent:)]) {
        [_delegate onBGMRangeChange:_musicCutSlider.leftScale endPercent:_musicCutSlider.rightScale];
    }
}

-(void)resetVolume
{
    _sldVolumeForBGM.value = 1;
    _sldVolumeForVoice.value = 1;
}
@end
