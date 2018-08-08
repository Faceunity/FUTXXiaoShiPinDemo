//
//  TCVideoEditViewController.m
//  TCLVBIMDemo
//
//  Created by xiang zhang on 2017/4/10.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoCutViewController.h"
#import "TCVideoEditViewController.h"
#import <MediaPlayer/MPMediaPickerController.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoRangeSlider.h"
#import "VideoRangeConst.h"
#import "UIView+Additions.h"
#import "UIColor+MLPFlatColors.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VideoPreview.h"
#import "VideoCutView.h"
#import "SDKHeader.h"
#import "TransitionView.h"
#import "SmallButton.h"

typedef  NS_ENUM(NSInteger,VideoType)
{
    VideoType_Video,
    VideoType_Picture,
};

#define HeightDist  52 * kScaleY


@interface TCVideoCutViewController ()<TXVideoGenerateListener,VideoPreviewDelegate, VideoCutViewDelegate,TransitionViewDelegate>
@property(nonatomic,strong) TXVideoEditer *ugcEdit;
@property(nonatomic,strong) VideoPreview  *videoPreview;
@property CGFloat  duration;
@end

@implementation TCVideoCutViewController
{
    NSMutableArray      *_cutPathList;
    NSString            *_videoOutputPath;
    
    UIProgressView* _playProgressView;
    UILabel*        _startTimeLabel;
    UILabel*        _endTimeLabel;
    CGFloat         _leftTime;
    CGFloat         _rightTime;

    UILabel*        _generationTitleLabel;
    UIView*         _generationView;
    UIProgressView* _generateProgressView;
    UIButton*       _generateCannelBtn;
    
    UIColor            *_barTintColor;
    
    NSString*          _filePath;
    unsigned long long _fileSize;
    BOOL               _navigationBarHidden;
    
    BOOL               _hasQuickGenerate;
    BOOL               _hasNomalGenerate;
    
    VideoCutView*    _videoCutView;
    TransitionView*  _transitionView;
    RangeContentConfig *_config;
    VideoType        _videoType;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        _cutPathList = [NSMutableArray array];
        _videoOutputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputCut.mp4"];
        _config = [[RangeContentConfig alloc] init];
        _config.pinWidth = PIN_WIDTH;
        _config.thumbHeight = 50;
        _config.borderHeight = BORDER_HEIGHT;
        _config.imageCount = 15;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _barTintColor =  self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationBar.barTintColor =  UIColorFromRGB(0x181818);
    self.navigationController.navigationBar.translucent  =  NO;
    _navigationBarHidden = self.navigationController.navigationBar.hidden;
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor =  _barTintColor;
    self.navigationController.navigationBar.translucent  =  YES;
    self.navigationController.navigationBar.hidden = _navigationBarHidden;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_videoPreview playVideo];
}


- (void)dealloc
{
    [_videoPreview removeNotification];
    _videoPreview = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _videoPreview = [[VideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) coverImage:nil];
    _videoPreview.delegate = self;
    [self.view addSubview:_videoPreview];
    
    UILabel *barTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    barTitleLabel.backgroundColor = [UIColor clearColor];
    barTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    barTitleLabel.textColor = [UIColor whiteColor];
    barTitleLabel.textAlignment = NSTextAlignmentCenter;
    barTitleLabel.text = @"编辑视频";
    self.navigationItem.titleView = barTitleLabel;
    self.view.backgroundColor = UIColor.blackColor;
    
    UIButton *goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goBackButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [goBackButton addTarget:self action:@selector(onBtnPopClicked) forControlEvents:UIControlEventTouchUpInside];
    goBackButton.frame = CGRectMake(15 * kScaleX, 20 * kScaleY, 14 , 23);
    [self.view addSubview:goBackButton];
    
    CGFloat btnNextWidth = 70;
    CGFloat btnNextHeight = 30;
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.bounds = CGRectMake(0, 0, btnNextWidth, btnNextHeight);
    btnNext.center = CGPointMake(self.view.right - 15 * kScaleX - btnNextWidth / 2, 20 + btnNextHeight / 2);
    [btnNext setTitle:@"下一步" forState:UIControlStateNormal];
    btnNext.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnNext setBackgroundImage:[UIImage imageNamed:@"next_normal"] forState:UIControlStateNormal];
    [btnNext setBackgroundImage:[UIImage imageNamed:@"next_press"] forState:UIControlStateHighlighted];
    [btnNext addTarget:self action:@selector(onBtnNextClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnNext];
    
    _playProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, _videoPreview.bottom, self.view.width, 6)];
    _playProgressView.trackTintColor = UIColorFromRGB(0xd8d8d8);
    _playProgressView.progressTintColor = UIColorFromRGB(0x0accac);
    _playProgressView.hidden = YES;
    [self.view addSubview:_playProgressView];
    
    _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _playProgressView.bottom + 10 * kScaleY, 50, 12)];
    _startTimeLabel.text = @"0:00";
    _startTimeLabel.textAlignment = NSTextAlignmentLeft;
    _startTimeLabel.font = [UIFont systemFontOfSize:12];
    _startTimeLabel.textColor = UIColor.lightTextColor;
    _startTimeLabel.hidden = YES;
    [self.view addSubview:_startTimeLabel];
    
    _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 15 - 50, _playProgressView.bottom + 10, 50, 12)];
    _endTimeLabel.text = @"0:00";
    _endTimeLabel.textAlignment = NSTextAlignmentRight;
    _endTimeLabel.font = [UIFont systemFontOfSize:12];
    _endTimeLabel.textColor = UIColor.lightTextColor;
    _endTimeLabel.hidden = YES;
    [self.view addSubview:_endTimeLabel];
    
    //    CGFloat heightDist = 52 * kScaleY;
    //    _videoCutView = [[VideoCutView alloc] initWithFrame:CGRectMake(0, self.view.height - heightDist - 20 * kScaleY, self.view.width,heightDist) videoPath:_videoPath videoAssert:_videoAsset config:config];
    //    _videoCutView.delegate = self;
    //    [self.view addSubview:_videoCutView];
    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _videoPreview.renderView;
    param.renderMode =  PREVIEW_RENDER_MODE_FILL_EDGE;
    _ugcEdit = [[TXVideoEditer alloc] initWithPreview:param];
    _ugcEdit.generateDelegate = self;
    _ugcEdit.previewDelegate = _videoPreview;
    
    //video
    if (_videoAsset != nil) {
        _videoType = VideoType_Video;
        [_ugcEdit setVideoAsset:_videoAsset];
        [self initVideoCutView];
        
        TXVideoInfo *videoMsg = [TXVideoInfoReader getVideoInfoWithAsset:_videoAsset];
        _fileSize   = videoMsg.fileSize;
        _duration = videoMsg.duration;
        _rightTime = _duration;
        _endTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)_duration / 60, (int)_duration % 60];
    }
    //image
    if (_imageList != nil) {
        _videoType = VideoType_Picture;
        
        _transitionView = [[TransitionView alloc] initWithFrame:CGRectMake(0, self.view.height - 2.5 * HeightDist - 20 * kScaleY, self.view.width,HeightDist)];
        _transitionView.delegate = self;
        [self.view addSubview:_transitionView];
        
        [_ugcEdit setPictureList:_imageList fps:30];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self onVideoTransitionLefRightSlipping];
        });
    }
}

- (UIView*)generatingView
{
    /*用作生成时的提示浮层*/
    if (!_generationView) {
        _generationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height + 64)];
        _generationView.backgroundColor = UIColor.blackColor;
        _generationView.alpha = 0.9f;
        
        _generateProgressView = [UIProgressView new];
        _generateProgressView.center = CGPointMake(_generationView.width / 2, _generationView.height / 2);
        _generateProgressView.bounds = CGRectMake(0, 0, 225, 20);
        _generateProgressView.progressTintColor = RGB(238, 100, 85);
        [_generateProgressView setTrackImage:[UIImage imageNamed:@"slide_bar_small"]];
        //_generateProgressView.trackTintColor = UIColor.whiteColor;
        //_generateProgressView.transform = CGAffineTransformMakeScale(1.0, 2.0);
        
        _generationTitleLabel = [UILabel new];
        _generationTitleLabel.font = [UIFont systemFontOfSize:14];
        _generationTitleLabel.text = @"视频生成中";
        _generationTitleLabel.textColor = UIColor.whiteColor;
        _generationTitleLabel.textAlignment = NSTextAlignmentCenter;
        _generationTitleLabel.frame = CGRectMake(0, _generateProgressView.y - 34, _generationView.width, 14);
        
        _generateCannelBtn = [UIButton new];
        [_generateCannelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        _generateCannelBtn.frame = CGRectMake(_generateProgressView.right + 15, _generationTitleLabel.bottom + 10, 20, 20);
        [_generateCannelBtn addTarget:self action:@selector(onCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_generationView addSubview:_generationTitleLabel];
        [_generationView addSubview:_generateProgressView];
        [_generationView addSubview:_generateCannelBtn];
    }
    
    _generateProgressView.progress = 0.f;
    [[[UIApplication sharedApplication] delegate].window addSubview:_generationView];
    return _generationView;
}

- (void)initVideoCutView
{
    CGRect frame = CGRectMake(0, self.view.height - HeightDist - 20 * kScaleY, self.view.width,HeightDist);
    if (_videoType == VideoType_Video) {
        if(_videoCutView) [_videoCutView removeFromSuperview];
        _videoCutView = [[VideoCutView alloc] initWithFrame:frame videoPath:nil videoAssert:_videoAsset config:_config];
        [self.view addSubview:_videoCutView];
    }else{
        if (_videoCutView) {
            [_videoCutView updateFrame:_duration];
        }else{
            [_videoCutView removeFromSuperview];
            _videoCutView = [[VideoCutView alloc] initWithFrame:frame pictureList:_imageList duration:_duration config:_config];
            [self.view addSubview:_videoCutView];
        }
    }
    _videoCutView.delegate = self;
    [_videoCutView setCenterPanHidden:YES];
}


- (void)pause
{
    [_ugcEdit pausePlay];
    [_videoPreview setPlayBtn:NO];
}


- (void)onBtnPopClicked
{
    [self pause];
    [self dismissViewControllerAnimated:YES completion:^{
        //to do
    }];
}

-(void)onBtnNextClicked
{
    [self pause];
    [_videoPreview setPlayBtn:NO];
    
    if (_videoType == VideoType_Video) {
        if (_leftTime == 0 && _rightTime == _duration) {
            //视频如果没发生剪裁，这里不用走编辑逻辑，减少画面质量损失
            TCVideoEditViewController *vc = [[TCVideoEditViewController alloc] init];
            vc.videoAsset = _videoAsset;
            vc.isFromCut = YES;
            [self.navigationController pushViewController:vc animated:YES];
            //销毁掉编辑器，减少内存占用
            _ugcEdit = nil;
        }else{
            //优先使用快速剪切，速度快
            _generationView = [self generatingView];
            _generationView.hidden = NO;
            _hasQuickGenerate = YES;
            [_ugcEdit setCutFromTime:_leftTime toTime:_rightTime];
            [_ugcEdit quickGenerateVideo:VIDEO_COMPRESSED_720P videoOutputPath:_videoOutputPath];
        }
    }else{
        //图片编辑只能走正常生成逻辑，这里使用高码率，保留更多图片细节
        _generationView = [self generatingView];
        _generationView.hidden = NO;
        _hasNomalGenerate = YES;
        [_ugcEdit setVideoBitrate:10000];
        [_ugcEdit setCutFromTime:_leftTime toTime:_rightTime];
        [_ugcEdit quickGenerateVideo:VIDEO_COMPRESSED_720P videoOutputPath:_videoOutputPath];
    }
}

- (void)onCancelBtnClicked:(UIButton*)sender
{
    _generationView.hidden = YES;
    [_ugcEdit cancelGenerate];
}

#pragma mark TransitionViewDelegate
- (void)onVideoTransitionLefRightSlipping
{
    __weak __typeof(self) weakSelf = self;
    [_ugcEdit setPictureTransition:TXTransitionType_LefRightSlipping duration:^(CGFloat duration) {
        _duration = duration;
        _rightTime = duration;
        [weakSelf initVideoCutView];
        [weakSelf.ugcEdit startPlayFromTime:0 toTime:weakSelf.duration];
    }];
}

- (void)onVideoTransitionUpDownSlipping
{
    __weak __typeof(self) weakSelf = self;
    [_ugcEdit setPictureTransition:TXTransitionType_UpDownSlipping duration:^(CGFloat duration) {
        _duration = duration;
        _rightTime = duration;
        [weakSelf initVideoCutView];
        [weakSelf.ugcEdit startPlayFromTime:0 toTime:weakSelf.duration];
    }];
}

- (void)onVideoTransitionEnlarge
{
    __weak __typeof(self) weakSelf = self;
    [_ugcEdit setPictureTransition:TXTransitionType_Enlarge duration:^(CGFloat duration) {
        _duration = duration;
        _rightTime = duration;
        [weakSelf initVideoCutView];
        [weakSelf.ugcEdit startPlayFromTime:0 toTime:weakSelf.duration];
    }];
}

- (void)onVideoTransitionNarrow
{
    __weak __typeof(self) weakSelf = self;
    [_ugcEdit setPictureTransition:TXTransitionType_Narrow duration:^(CGFloat duration) {
        _duration = duration;
        _rightTime = duration;
        [weakSelf initVideoCutView];
        [weakSelf.ugcEdit startPlayFromTime:0 toTime:weakSelf.duration];
    }];
}

- (void)onVideoTransitionRotationalScaling
{
    __weak __typeof(self) weakSelf = self;
    [_ugcEdit setPictureTransition:TXTransitionType_RotationalScaling duration:^(CGFloat duration) {
        _duration = duration;
        _rightTime = duration;
        [weakSelf initVideoCutView];
        [weakSelf.ugcEdit startPlayFromTime:0 toTime:weakSelf.duration];
    }];
}

- (void)onVideoTransitionFadeinFadeout
{
    __weak __typeof(self) weakSelf = self;
    [_ugcEdit setPictureTransition:TXTransitionType_FadeinFadeout duration:^(CGFloat duration) {
        _duration = duration;
        _rightTime = duration;
        [weakSelf initVideoCutView];
        [weakSelf.ugcEdit startPlayFromTime:0 toTime:weakSelf.duration];
        [weakSelf.videoPreview setPlayBtn:YES];
    }];
}

#pragma mark TXVideoGenerateListener
-(void) onGenerateProgress:(float)progress
{
    _generateProgressView.progress = progress;
}

-(void) onGenerateComplete:(TXGenerateResult *)result
{
    _generationView.hidden = YES;
    if (result.retCode == 0) {
        TCVideoEditViewController *vc = [[TCVideoEditViewController alloc] init];
        vc.videoPath = _videoOutputPath;
        vc.isFromCut = YES;
        [self.navigationController pushViewController:vc animated:YES];
        //销毁掉编辑器，减少内存占用
        _ugcEdit = nil;
    }else{
        //系统剪切如果失败，这里使用SDK正常剪切，设置高码率，保留图像更多的细节
        if (_hasQuickGenerate && !_hasNomalGenerate) {
            _generationView = [self generatingView];
            _generationView.hidden = NO;
            [_ugcEdit cancelGenerate];
            [_ugcEdit setVideoBitrate:10000];
            [_ugcEdit setCutFromTime:_leftTime toTime:_rightTime];
            [_ugcEdit generateVideo:VIDEO_COMPRESSED_720P videoOutputPath:_videoOutputPath];
            _hasNomalGenerate = YES;
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频生成失败"
                                                                message:[NSString stringWithFormat:@"错误码：%ld 错误信息：%@",(long)result.retCode,result.descMsg]
                                                               delegate:self
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    if (_videoType == VideoType_Video) {
        [TCUtil report:xiaoshipin_videoedit userName:nil code:result.retCode msg:result.descMsg];
    }else{
        [TCUtil report:xiaoshipin_pictureedit userName:nil code:result.retCode msg:result.descMsg];
    }
}

#pragma mark VideoPreviewDelegate
- (void)onVideoPlay
{
    CGFloat currentPos = _videoCutView.videoRangeSlider.currentPos;
    if (currentPos < _leftTime || currentPos > _rightTime)
    currentPos = _leftTime;
    
    [_ugcEdit startPlayFromTime:currentPos toTime:_videoCutView.videoRangeSlider.rightPos];
}

- (void)onVideoPause
{
    [_ugcEdit pausePlay];
}

- (void)onVideoResume
{
    [self onVideoPlay];
}

- (void)onVideoPlayProgress:(CGFloat)time
{
    _playProgressView.progress = (time - _leftTime) / (_rightTime - _leftTime);
    [_videoCutView setPlayTime:time];
}

- (void)onVideoPlayFinished
{
    [_ugcEdit startPlayFromTime:_leftTime toTime:_rightTime];
}

- (void)onVideoEnterBackground
{
    if (_generationView && !_generationView.hidden) {
        [_ugcEdit pauseGenerate];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_ugcEdit pausePlay];
        [_videoPreview setPlayBtn:NO];
    }
}

- (void)onVideoWillEnterForeground
{
    if (_generationView && !_generationView.hidden) {
        [_ugcEdit resumeGenerate];
    }
}

#pragma mark - VideoCutViewDelegate
- (void)onVideoRangeLeftChanged:(VideoRangeSlider *)sender
{
    //[_ugcEdit pausePlay];
    [_videoPreview setPlayBtn:NO];
    [_ugcEdit previewAtTime:sender.leftPos];
}

- (void)onVideoRangeRightChanged:(VideoRangeSlider *)sender
{
    [_videoPreview setPlayBtn:NO];
    [_ugcEdit previewAtTime:sender.rightPos];
}

- (void)onVideoRangeLeftChangeEnded:(VideoRangeSlider *)sender
{
    _leftTime = sender.leftPos;
    _rightTime = sender.rightPos;
    _startTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)sender.leftPos / 60, (int)sender.leftPos % 60];
    _endTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)sender.rightPos / 60, (int)sender.rightPos % 60];
    [_ugcEdit startPlayFromTime:sender.leftPos toTime:sender.rightPos];
    [_videoPreview setPlayBtn:YES];
}
- (void)onVideoRangeRightChangeEnded:(VideoRangeSlider *)sender
{
    _leftTime = sender.leftPos;
    _rightTime = sender.rightPos;
    _startTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)sender.leftPos / 60, (int)sender.leftPos % 60];
    _endTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)sender.rightPos / 60, (int)sender.rightPos % 60];
    [_ugcEdit startPlayFromTime:sender.leftPos toTime:sender.rightPos];
    [_videoPreview setPlayBtn:YES];
}

- (void)onVideoSeekChange:(VideoRangeSlider *)sender seekToPos:(CGFloat)pos
{
    [_ugcEdit previewAtTime:pos];
    [_videoPreview setPlayBtn:NO];
    _playProgressView.progress = (pos - _leftTime) / (_rightTime - _leftTime);
}


@end

