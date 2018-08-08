//
//  TCBGMSliderCutView.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/15.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMSliderCutView.h"


@implementation TCBGMSliderCutViewConfig
- (id)init
{
    if (self = [super init]) {
        _pinWidth = PIN_WIDTH;
        _thumbHeight = THUMB_HEIGHT;
        _borderHeight = BORDER_HEIGHT;
        _leftPinImage = [UIImage imageNamed:@"left"];
        _rightPigImage = [UIImage imageNamed:@"right"];
        _durationUnit = 15;
        _labelDurationInternal = 5;
    }
    
    return self;
}
@end


@interface TCBGMSliderCutView()<UIScrollViewDelegate>

@end

@implementation TCBGMSliderCutView {
    CGFloat _imageWidth;
    TCBGMSliderCutViewConfig* _appearanceConfig;
    float sliderWidth;
    int dragIdx;//0 non 1 left 2 right
}

- (instancetype)initWithImage:(UIImage*)image config:(TCBGMSliderCutViewConfig *)config
{
    _image = image;
    _appearanceConfig = config;
    
    self = [super initWithFrame:_appearanceConfig.frame];
    
    [self iniSubViews];
    
    return self;
}

- (void)iniSubViews
{
    CGRect frame = self.bounds;
    CGRect contentFrame = CGRectMake(_appearanceConfig.pinWidth,
                                     _appearanceConfig.borderHeight,
                                     _appearanceConfig.frame.size.width - 2 * _appearanceConfig.pinWidth,
                                     _appearanceConfig.thumbHeight);
    sliderWidth = (_appearanceConfig.frame.size.width - 2 * _appearanceConfig.pinWidth)*
    _appearanceConfig.duration / _appearanceConfig.durationUnit;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_appearanceConfig.pinWidth,
                                                                         _appearanceConfig.borderHeight,
                                                                         sliderWidth,
                                                                         _appearanceConfig.thumbHeight)];
    //        imgView.image = _imageList[i];
    //        imgView.contentMode = UIViewContentModeScaleToFill;
    UIColor *colorPattern = [[UIColor alloc] initWithPatternImage:_image];
    _imageView.clipsToBounds = YES;
    [_imageView setBackgroundColor:colorPattern];
    float labelW = 40;
    float labelH = 10;
    for (float l = _appearanceConfig.labelDurationInternal; l < sliderWidth;l += _appearanceConfig.labelDurationInternal) {
        CGFloat lw = (l / _appearanceConfig.duration) * sliderWidth;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(lw - labelW / 2,
                                                                  _appearanceConfig.borderHeight + _appearanceConfig.thumbHeight / 2 - labelH / 2,
                                                                  labelW,
                                                                  labelH)];
        [label setText:[TCBGMSliderCutView timeString:l]];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:10]];
        [_imageView addSubview:label];
    }
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
    [self addSubview:_bgScrollView];
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.scrollsToTop = NO;
    _bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _bgScrollView.delegate = self;
    _bgScrollView.contentSize = CGSizeMake(sliderWidth, _appearanceConfig.borderHeight);
    _bgScrollView.decelerationRate = 0.1f;
    _bgScrollView.bounces = NO;
    [_bgScrollView addSubview:_imageView];
    
    if (_appearanceConfig.leftCorverImage) {
        self.leftCover = [[UIImageView alloc] initWithImage:_appearanceConfig.leftCorverImage];
        self.leftCover.contentMode = UIViewContentModeCenter;
        self.leftCover.clipsToBounds = YES;
        
    }
    else {
        self.leftCover = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.leftCover.backgroundColor = [UIColor blackColor];
        self.leftCover.alpha = 0.5;
    };
    [self addSubview:self.leftCover];
    
    
    if (_appearanceConfig.rightCoverImage) {
        self.rightCover = [[UIImageView alloc] initWithImage:_appearanceConfig.rightCoverImage];
        self.rightCover.contentMode = UIViewContentModeCenter;
        self.rightCover.clipsToBounds = YES;
        
    }
    else {
        self.rightCover = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rightCover.backgroundColor = [UIColor blackColor];
        self.rightCover.alpha = 0.5;
    }
    [self addSubview:self.rightCover];
    
    self.leftPin = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_appearanceConfig.leftPinImage];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.width = _appearanceConfig.pinWidth;
        [self addSubview:imageView];
        imageView;
    });
    
    self.rightPin = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_appearanceConfig.rightPigImage];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.width = _appearanceConfig.pinWidth;
        [self addSubview:imageView];
        imageView;
    });
    
    self.topBorder = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view.backgroundColor = [UIColor colorWithRed:0.14 green:0.80 blue:0.67 alpha:1];
        view;
    });
    
    self.bottomBorder = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view.backgroundColor = [UIColor colorWithRed:0.14 green:0.80 blue:0.67 alpha:1];
        view;
    });
    
    _leftPinCenterX = _appearanceConfig.pinWidth / 2;
    _rightPinCenterX = frame.size.width- _appearanceConfig.pinWidth / 2;
}

+(NSString*) timeString:(CGFloat) time{
    int t = ((int)time) % 3600;
    int m = t / 60;
    NSString* ret = nil;
    if(m < 10){
        ret = [NSString stringWithFormat:@"0%d:", m];
    }
    else ret = [NSString stringWithFormat:@"%d:", m];
    int s = t % 60;
    if(s < 10){
        ret = [NSString stringWithFormat:@"%@0%d", ret ,s];
    }
    else ret = [NSString stringWithFormat:@"%@%d", ret ,s];
    return ret;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(_appearanceConfig.frame.size.width, _appearanceConfig.thumbHeight + 2 * _appearanceConfig.borderHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pos = scrollView.contentOffset.x;
    pos += scrollView.contentInset.left;
    if (pos < 0) pos = 0;
    if (pos > sliderWidth) pos = sliderWidth;
    
    [self.delegate onRangeLeftChanged:self percent:pos / sliderWidth];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        CGFloat pos = scrollView.contentOffset.x;
        pos += scrollView.contentInset.left;
        if (pos < 0) pos = 0;
        if (pos > sliderWidth) pos = sliderWidth;
        [self.delegate onRangeLeftChangeEnded:self percent:pos / sliderWidth];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pos = scrollView.contentOffset.x;
    pos += scrollView.contentInset.left;
    if (pos < 0) pos = 0;
    if (pos > sliderWidth) pos = sliderWidth;
    NSLog(@"EndDecelerating%f",pos / sliderWidth * _appearanceConfig.duration);
    [self.delegate onRangeLeftChangeEnded:self percent:pos / sliderWidth];
}

//-(void)scrollViewWillBeginDecelerating: (UIScrollView *)scrollView
//{
////    [scrollView setContentOffset:scrollView.contentOffset animated:NO];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.leftPin.center = CGPointMake(self.leftPinCenterX, self.height / 2);
    self.rightPin.center = CGPointMake(self.rightPinCenterX, self.height / 2);
    
    self.topBorder.height = _appearanceConfig.borderHeight;
    self.topBorder.width = self.rightPinCenterX - self.leftPinCenterX;
    self.topBorder.y = 0;
    self.topBorder.x = self.leftPinCenterX;
    
    self.bottomBorder.height = _appearanceConfig.borderHeight;
    self.bottomBorder.width = self.rightPinCenterX - self.leftPinCenterX;
    self.bottomBorder.y = self.leftPin.bottom-_appearanceConfig.borderHeight;
    self.bottomBorder.x = self.leftPinCenterX;
    
    
    self.leftCover.height = _appearanceConfig.thumbHeight;
    self.leftCover.width = self.leftPinCenterX - _appearanceConfig.pinWidth / 2;
    self.leftCover.y = _appearanceConfig.borderHeight;
    self.leftCover.x = _appearanceConfig.pinWidth;
    
    self.rightCover.height = _appearanceConfig.thumbHeight;
    self.rightCover.width = self.width - self.rightPinCenterX - _appearanceConfig.pinWidth/2;
    self.rightCover.y = _appearanceConfig.borderHeight;
    self.rightCover.x = self.rightPinCenterX - _appearanceConfig.pinWidth/2 + 1;
}

-(CGFloat) getPointDistance:(CGPoint) p1 point2:(CGPoint) p2{
    return sqrtf((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y));
}

- (CGFloat)pinWidth
{
    return _appearanceConfig.pinWidth;
}

- (CGFloat)leftScale {
    return (_leftPinCenterX - _appearanceConfig.pinWidth / 2) / sliderWidth;
}

- (CGFloat)rightScale {
    return (_rightPinCenterX - _appearanceConfig.pinWidth / 2 - _appearanceConfig.pinWidth) / sliderWidth;
}

-(void) resetCutView{
    _leftPinCenterX = _appearanceConfig.pinWidth / 2;
    _rightPinCenterX = self.width - _appearanceConfig.pinWidth / 2;
    [self setNeedsLayout];
}

@end

