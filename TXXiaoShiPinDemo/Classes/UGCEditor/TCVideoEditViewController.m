//
//  VideoEditViewController.m
//  TCLVBIMDemo
//
//  Created by xiang zhang on 2017/4/10.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoEditViewController.h"
#import "TCBGMListViewController.h"
#import <TXLiteAVSDK_UGC_IJK/TXVideoEditer.h>
#import <MediaPlayer/MPMediaPickerController.h>
#import "VideoPreview.h"
#import "VideoRangeSlider.h"
#import "VideoRangeConst.h"
#import "TCVideoRecordMusicView.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "MBProgressHUD.h"
#import "BottomTabBar.h"
#import "VideoCutView.h"
#import "PasterAddView.h"
#import "EffectSelectView.h"
#import "VideoPasterView.h"
#import "VideoTextFiled.h"
#import "TCBGMHelper.h"
#import "TXUGCPublish.h"
#import "TCUserInfoModel.h"
#import "VideoInfo.h"
#import "TCLoginModel.h"
#import "TCLiveListModel.h"
#import "TCUserAgreementController.h"
#import "UIActionSheet+BlocksKit.h"
#import "UIAlertView+BlocksKit.h"
#import <AFNetworking.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TXCVEFColorPalette.h"

typedef  NS_ENUM(NSInteger,ActionType)
{
    ActionType_Save,
    ActionType_Publish,
    ActionType_Save_Publish,
};

typedef  NS_ENUM(NSInteger,TimeType)
{
    TimeType_Clear,
    TimeType_Back,
    TimeType_Repeat,
    TimeType_Speed,
};

typedef NS_ENUM(NSInteger,EffectSelectType)
{
    EffectSelectType_Effect,
    EffectSelectType_Time,
    EffectSelectType_Filter,
    EffectSelectType_Paster,
    EffectSelectType_Text,
};

typedef NS_ENUM(NSInteger,TCLVFilterType) {
    FilterType_None         = 0,
    FilterType_white        ,   //美白滤镜
    FilterType_langman         ,   //浪漫滤镜
    FilterType_qingxin         ,   //清新滤镜
    FilterType_weimei         ,   //唯美滤镜
    FilterType_fennen         ,   //粉嫩滤镜
    FilterType_huaijiu         ,   //怀旧滤镜
    FilterType_landiao         ,   //蓝调滤镜
    FilterType_qingliang     ,   //清凉滤镜
    FilterType_rixi         ,   //日系滤镜
};


@interface TCVideoEditViewController ()<TXVideoGenerateListener,VideoPreviewDelegate, BottomTabBarDelegate, VideoCutViewDelegate,EffectSelectViewDelegate, PasterAddViewDelegate, VideoPasterViewDelegate ,VideoTextFieldDelegate ,TXVideoPublishListener,TCBGMControllerListener,VideoRecordMusicViewDelegate,UIActionSheetDelegate, UITabBarDelegate , UIPickerViewDelegate ,UIPickerViewDelegate ,UIAlertViewDelegate>

@end

@implementation TCVideoEditViewController
{
    TCBGMListViewController *_bgmListVC;
    TXVideoEditer*   _ugcEdit;        //sdk编辑器
    VideoPreview*    _videoPreview;   //视频预览
    
    //特效View
    UIView*             _effectView;
    
    //cover view
    UIImageView*        _coverImageView;
    
    //背景音
    TCVideoRecordMusicView *_musicView;
    
    //特效确定btn
    UIButton *          _effectConfirmBtn;
    
    UIButton *          _generateCannelBtn;
    
    //生成时的进度浮层
    UIView*             _generationView;
    UIProgressView*     _generateProgressView;
    UILabel*            _generationTitleLabel;
    UILabel*            _timeLabel;
    UIButton*           _deleteBtn;
    UIButton*           _playBtn;

    //pulish
    TXUGCPublish*       _videoPublish;
    
    BottomTabBar*       _bottomBar;          //底部栏
    VideoCutView*       _videoCutView;       //裁剪
    PasterAddView*      _pasterAddView;      //贴图
    EffectSelectView*   _effectSelectView;   //动效选择
    EffectSelectType    _effectSelectType;
    
    ActionType          _actionType;
    TimeType            _timeType;
    
    NSMutableArray <EffectInfo *> *_pasterEffectArray;
    NSMutableArray <EffectInfo *> *_textEffectArray;
    NSMutableArray <VideoPasterInfo *>* _videoPasterInfoList;
    NSMutableArray <VideoTextInfo *>*   _videoTextInfoList;
    NSMutableArray  *_cutPathList;
    
    //裁剪时间
    CGFloat             _duration;
    CGFloat             _playTime;
    CGFloat             _BGMDuration;
    CGFloat             _BGMVolume;
    CGFloat             _videoVolume;
    NSInteger           _effectSelectIndex;
    NSInteger           _effectType;

    NSObject*     _BGMPath;
    NSString*    _videoOutputPath;
    BOOL          _isReverse;
    BOOL          _isSeek;
    BOOL          _isPlay;
    BOOL          _navigationBarHidden;
    dispatch_queue_t _imageLoadingQueue;
    NSArray<EffectInfo*> *_effectList;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _effectType = -1;
        _cutPathList = [NSMutableArray array];
        _videoOutputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputCut.mp4"];
    
        _pasterEffectArray = [NSMutableArray array];
        [_pasterEffectArray addObject:({
            EffectInfo * v= [EffectInfo new];
            v.name = @"新增";
            v.icon = [UIImage imageNamed:@"addPaster_normal"];
            v;
        })];
        
         _textEffectArray = [NSMutableArray array];
        [_textEffectArray addObject:({
            EffectInfo * v= [EffectInfo new];
            v.name = @"新增";
            v.icon = [UIImage imageNamed:@"addPaster_normal"];
            v;
        })];
        
        _videoPasterInfoList = [NSMutableArray array];
        _videoTextInfoList = [NSMutableArray array];
        _BGMVolume = 1.0;
        _videoVolume = 1.0;
        _imageLoadingQueue = dispatch_queue_create("TCVideoEditImageLoading", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _navigationBarHidden = self.navigationController.navigationBar.hidden;
    self.navigationController.navigationBar.translucent  =  NO;
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = _navigationBarHidden;
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [_videoCutView stopGetImageList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_videoPreview.isPlaying) {
        [_videoPreview playVideo];
    }
}

- (void)onVideoEnterBackground
{
    if (_generationView && !_generationView.hidden) {
        [_ugcEdit pauseGenerate];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_ugcEdit pausePlay];
        [self setPlayBtn:NO];
    }
}

- (void)onVideoWillEnterForeground
{
    if (_generationView && !_generationView.hidden) {
        [_ugcEdit resumeGenerate];
    }else{
        [_ugcEdit resumePlay];
        [self setPlayBtn:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    __weak __typeof(self) wself = self;
    dispatch_async(_imageLoadingQueue, ^{
        EffectInfo *(^CreateEffect)(NSString *name, NSString *animPrefix)=^(NSString *name, NSString *animPrefix){
            EffectInfo * v= [EffectInfo new];
            v.name = name;
            v.animateIcons = [NSMutableArray array];
            NSString *imageName = [NSString stringWithFormat: @"%@_select", animPrefix];
            NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
            v.selectIcon = [UIImage imageWithContentsOfFile:path];
            for (int i = 0; i < 24; i ++) {
                imageName = [NSString stringWithFormat: @"%@%d", animPrefix, i];
                path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
                [v.animateIcons addObject:[UIImage imageWithContentsOfFile:path]];
            }
            return v;
        };

        NSArray <EffectInfo *> *effectList = @[ CreateEffect(@"动感光波", @"donggan"),
                                                CreateEffect(@"暗黑幻境", @"anhei"),
                                                CreateEffect(@"灵魂出窍", @"linghun"),
                                                CreateEffect(@"画面分裂", @"fenlie"),
                                                CreateEffect(@"百叶窗", @"donggan"),
                                                CreateEffect(@"鬼影", @"donggan"),
                                                CreateEffect(@"幻影", @"donggan"),
                                                CreateEffect(@"幽灵", @"donggan"),
                                                CreateEffect(@"闪电", @"donggan"),
                                                CreateEffect(@"镜像", @"donggan"),
                                                CreateEffect(@"幻觉", @"donggan"),
                                                ];
        __strong __typeof(wself) self = wself;
        if (self) {
            self->_effectList = effectList;
        }
    });

    if (_videoAsset == nil && _videoPath != nil) {
        NSURL *avUrl = [NSURL fileURLWithPath:_videoPath];
        _videoAsset = [AVAsset assetWithURL:avUrl];
    }
    self.view.backgroundColor = UIColor.blackColor;
    
    _videoPreview = [[VideoPreview alloc] initWithFrame:self.view.bounds coverImage:nil];
    _videoPreview.delegate = self;
    [_videoPreview setPlayBtnHidden:YES];
    [self.view addSubview:_videoPreview];
    //点击选中文字
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [_videoPreview addGestureRecognizer:singleTap];
    CGFloat offset = 0;
    if (@available(iOS 11, *)) {
        offset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    _bottomBar = [[BottomTabBar alloc] initWithFrame:CGRectMake(0, self.view.height - 62 * kScaleY - offset, self.view.width, 40 * kScaleY)];
    _bottomBar.delegate = self;
    [self.view addSubview:_bottomBar];

    // 特效取消按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10 * kScaleX, 10 * kScaleY, 50 * kScaleX, 44 * kScaleY);
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    CGFloat btnConfirmWidth = 70;
    CGFloat btnConfirmHeight = 30;
    _effectConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_effectConfirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    _effectConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_effectConfirmBtn setBackgroundImage:[UIImage imageNamed:@"next_normal"] forState:UIControlStateNormal];
    [_effectConfirmBtn setBackgroundImage:[UIImage imageNamed:@"next_press"] forState:UIControlStateHighlighted];
    _effectConfirmBtn.frame = CGRectMake(self.view.width - 15 * kScaleX - btnConfirmWidth, 20 * kScaleY, btnConfirmWidth, btnConfirmHeight);
    [_effectConfirmBtn addTarget:self action:@selector(goFinish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_effectConfirmBtn];
    
    _coverImageView = [[UIImageView alloc] initWithFrame:_videoPreview.frame];
    _coverImageView.hidden = YES;
    _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_coverImageView];

    // 特效容器
    _effectView= [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 205 * kScaleY)];
    [self.view addSubview:_effectView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 * kScaleX, 0, 40, 54)];
    _timeLabel.text = @"00:00";
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.textColor = [UIColor whiteColor];
    [_effectView addSubview:_timeLabel];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"editPlay_normal"] forState:UIControlStateNormal];
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"editPlay__press"] forState:UIControlStateHighlighted];
    _playBtn.frame = CGRectMake(self.view.width / 2 - 15, 10 * kScaleY, 30, 30);
    [_playBtn addTarget:self action:@selector(onPlayVideo) forControlEvents:UIControlEventTouchUpInside];
    [_effectView addSubview:_playBtn];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"effectDelete_normal"] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"effectDelete_press"] forState:UIControlStateHighlighted];
    _deleteBtn.frame = CGRectMake(self.view.width - 15 * kScaleX - 30, 10 * kScaleY, 30, 30);
    [_deleteBtn addTarget:self action:@selector(onDeleteEffect) forControlEvents:UIControlEventTouchUpInside];
    [_effectView addSubview:_deleteBtn];

    CGFloat cutViewHeight = 34 * kScaleY;
    RangeContentConfig *config = [[RangeContentConfig alloc] init];
    config.pinWidth = PIN_WIDTH;
    config.thumbHeight = cutViewHeight;
    config.borderHeight = 0;
    config.imageCount = 20;
    _videoCutView = [[VideoCutView alloc] initWithFrame:CGRectMake(0,_timeLabel.bottom + 3, _effectView.width,cutViewHeight) videoPath:_videoPath videoAssert:_videoAsset config:config];
    _videoCutView.delegate = self;
    [_videoCutView setCenterPanHidden:YES];
    [_effectView addSubview:_videoCutView];
    
    UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width / 2 - 6, _timeLabel.bottom, 12, 48)];
    flagView.image = [UIImage imageNamed:@"videoSlider"];
    [_effectView addSubview:flagView];
    
    _effectSelectView = [[EffectSelectView alloc] initWithFrame:CGRectMake(0, _videoCutView.bottom + 24 * kScaleY,_effectView.width,70 * kScaleY)];
    _effectSelectView.delegate = self;
    _effectSelectView.hidden = NO;
    [_effectView addSubview:_effectSelectView];
    
    _pasterAddView = [[PasterAddView alloc] initWithFrame:CGRectMake(0,self.view.height - 205 * kScaleY, self.view.width,205 * kScaleY)];
    _pasterAddView.delegate = self;
    _pasterAddView.hidden = YES;
    [self.view addSubview:_pasterAddView];
    
    _musicView = [[TCVideoRecordMusicView alloc] initWithFrame:CGRectMake(0, self.view.bottom - 268 * kScaleY, self.view.width, 268 * kScaleY) needEffect:NO];
    _musicView.delegate = self;
    _musicView.hidden = YES;
    [self.view addSubview:_musicView];
    
    _bgmListVC = [[TCBGMListViewController alloc] init];
    [_bgmListVC setBGMControllerListener:self];

    [self initVideoEditor];
    [self initVideoPublish];
}

- (void)initVideoEditor
{
    TXVideoInfo *videoMsg = [TXVideoInfoReader getVideoInfoWithAsset:_videoAsset];
    _duration = videoMsg.duration;
    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _videoPreview.renderView;
    param.renderMode = PREVIEW_RENDER_MODE_FILL_EDGE;
    _ugcEdit = [[TXVideoEditer alloc] initWithPreview:param];
    _ugcEdit.generateDelegate = self;
    _ugcEdit.previewDelegate = _videoPreview;
    
    //[_ugcEdit setVideoPath:_videoPath];
    [_ugcEdit setVideoAsset:_videoAsset];
    
//    UIImage *waterimage = [UIImage imageNamed:@"watermark"];
//    [_ugcEdit setWaterMark:waterimage normalizationFrame:CGRectMake(0.01, 0.01, 0.3 , 0)];

    UIImage *tailWaterimage = [UIImage imageNamed:@"tcloud_logo"];
    float w = 0.15;
    float x = (1.0 - w) / 2.0;
    float width = w * videoMsg.width;
    float height = width * tailWaterimage.size.height / tailWaterimage.size.width;
    float y = (videoMsg.height - height) / 2 / videoMsg.height;
    [_ugcEdit setTailWaterMark:tailWaterimage normalizationFrame:CGRectMake(x,y,w,0) duration:2];
}

- (void)initVideoPublish
{
    _videoPublish = [[TXUGCPublish alloc] initWithUserID:[[TCUserInfoModel sharedInstance] getUserProfile].identifier];
    _videoPublish.delegate = self;
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
        [_generateCannelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [_generationView addSubview:_generationTitleLabel];
        [_generationView addSubview:_generateProgressView];
        [_generationView addSubview:_generateCannelBtn];
        [[[UIApplication sharedApplication] delegate].window addSubview:_generationView];
    }
    
    _generateProgressView.progress = 0.f;
    return _generationView;
}

-(void)onPlayVideo
{
    if (_isPlay) {
        [_ugcEdit pausePlay];
        _isPlay = NO;
    }else{
        CGFloat currentPos = _videoCutView.videoRangeSlider.currentPos;
        if(_isReverse && currentPos != 0){
            [self startPlayFromTime:0 toTime:currentPos];
        }else{
            [self startPlayFromTime:currentPos toTime:_duration];
        }
        if (_effectSelectType == EffectSelectType_Paster) {
            [self removeAllPasterViewFromSuperView];
            [self setVideoPastersToSDK];
        }
        if (_effectSelectType == EffectSelectType_Text) {
            [self removeAllTextFieldFromSuperView];
            [self setVideoSubtitlesToSDK];
        }
        _isPlay = YES;
    }
    [self setPlayBtn:_isPlay];
}

- (void)setPlayBtn:(BOOL)isPlay
{
    if (isPlay) {
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"editPause_normal"] forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"editPause_press"] forState:UIControlStateHighlighted];
    }else{
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"editPlay_normal"] forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"editPlay__press"] forState:UIControlStateHighlighted];
    }
}

- (void)onTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint tapPoint = [recognizer locationInView:recognizer.view];
    if (_bottomBar.isHidden && _musicView.hidden) {
        BOOL findEffect = NO;
        if (_effectSelectType == EffectSelectType_Paster) {
            for (NSInteger i = 0; i < _videoPasterInfoList.count; i++) {
                CGRect pasterFrame = [_videoPasterInfoList[i].pasterView pasterFrameOnView:recognizer.view];
                if (CGRectContainsPoint(pasterFrame, tapPoint)) {
                    VideoPasterInfo *info = _videoPasterInfoList[i];
                    if (_playTime >= info.startTime && _playTime <= info.endTime) {
                        [self removeAllPasterViewFromSuperView];
                        [_videoPreview addSubview:info.pasterView];
                        [self setVideoPastersToSDK];
                        findEffect = YES;
                        break;
                    }
                }
            }
        }
        else if (_effectSelectType == EffectSelectType_Text){
            for (NSInteger i = 0; i < _videoTextInfoList.count; i++) {
                CGRect textFrame = [_videoTextInfoList[i].textField textFrameOnView:recognizer.view];
                if (CGRectContainsPoint(textFrame, tapPoint)) {
                    VideoTextInfo *info = _videoTextInfoList[i];
                    if (_playTime >= info.startTime && _playTime <= info.endTime){
                        [self removeAllTextFieldFromSuperView];
                        [_videoPreview addSubview:info.textField];
                        [self setVideoSubtitlesToSDK];
                        findEffect = YES;
                        break;
                    }
                }
            }
        }
        if (findEffect) {
            [_ugcEdit previewAtTime:_playTime];
            [_ugcEdit pausePlay];
            [self setPlayBtn:NO];
        }
    }else{
        _musicView.hidden = YES;
        _bottomBar.hidden = NO;
    }
}

- (void)resetConfirmBtn
{
    if(_bottomBar.isHidden){
        [_effectConfirmBtn setTitle:@"" forState:UIControlStateNormal];
        [_effectConfirmBtn setBackgroundImage:[UIImage imageNamed:@"cofirm_normal"] forState:UIControlStateNormal];
        [_effectConfirmBtn setBackgroundImage:[UIImage imageNamed:@"cofirm_press"] forState:UIControlStateHighlighted];
        _effectConfirmBtn.frame = CGRectMake(self.view.width - 15 * kScaleX - 44, 20 * kScaleY, 44, 30);
    }else{
        [_effectConfirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        _effectConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_effectConfirmBtn setBackgroundImage:[UIImage imageNamed:@"next_normal"] forState:UIControlStateNormal];
        [_effectConfirmBtn setBackgroundImage:[UIImage imageNamed:@"next_press"] forState:UIControlStateHighlighted];
        _effectConfirmBtn.frame = CGRectMake(self.view.width - 15 * kScaleX - 70, 20 * kScaleY, 70, 30);

    }
}

- (void)goBack
{
    if (_bottomBar.hidden) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"您确定要放弃当前添加的特效？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                _musicView.hidden = YES;
                [self clearEffect];
                [self onHideEffectView];
                [self resetConfirmBtn];
            }
        }];
        [alert show];
    }else{
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"您确定要放弃当前编辑？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [_ugcEdit stopPlay];
                [self setPlayBtn:NO];
                if (_isFromCut) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
        [alert show];
    }
}


- (void)goFinish
{
    if (_bottomBar.hidden) {
        if (_effectSelectType == EffectSelectType_Paster) {
            [self removeAllPasterViewFromSuperView];
            [self setVideoPastersToSDK];
        }
        if (_effectSelectType == EffectSelectType_Text) {
            [self removeAllTextFieldFromSuperView];
            [self setVideoSubtitlesToSDK];
        }
        _bottomBar.hidden = NO;
        _musicView.hidden = YES;
        [self onHideEffectView];
        [self resetConfirmBtn];
    }else{
        __weak __typeof(self) ws = self;
        UIActionSheet *testSheet = [[UIActionSheet alloc] init];
        [testSheet bk_addButtonWithTitle:@"保存" handler:^{
            [ws goSave];
        }];
        [testSheet bk_addButtonWithTitle:@"发布" handler:^{
            [ws goPublish];
        }];
        [testSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [testSheet showInView:self.view];
    }
}

- (void)goSave
{
    _actionType = ActionType_Save;
    [self generateVideo];
}

- (void)goPublish
{
    _actionType = ActionType_Publish;
    [self generateVideo];
}

- (void)onCancel:(UIButton*)sender
{
    _generationView.hidden = YES;
    [_ugcEdit cancelGenerate];
    [_ugcEdit startPlayFromTime:0 toTime:_duration];
    [self setPlayBtn:YES];
}

- (void)onSelectMusic
{
    if (_BGMPath) {
        _musicView.hidden = !_musicView.hidden;
    }else{
        [self resetVideoProgress];
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:_bgmListVC];
        [nv.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        nv.navigationBar.barTintColor = RGB(25, 29, 38);
        [self presentViewController:nv animated:YES completion:nil];
        [_bgmListVC loadBGMList];
    }
}

/// 特效入口点击事件响应函数
- (void)onShowEffectView
{
    [self resetVideoProgress];
    _coverImageView.hidden = NO;
    _coverImageView.image = [TXVideoInfoReader getSampleImage:_playTime videoAsset:_videoAsset];
    _videoPreview.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        _coverImageView.frame = CGRectMake(0, 54 * kScaleY, self.view.width, 410 * kScaleY);
        _effectView.frame = CGRectMake(0, self.view.height - 205 * kScaleY, _effectView.width, _effectView.height);
    } completion:^(BOOL finished) {
        _videoPreview.frame = _coverImageView.frame;
        _videoPreview.hidden = NO;
        _coverImageView.hidden = YES;
        _bottomBar.hidden = YES;
    }];
}

- (void)onHideEffectView
{
    _coverImageView.hidden = NO;
    _coverImageView.image =  [TXVideoInfoReader getSampleImage:_playTime videoAsset:_videoAsset];
    _videoPreview.hidden = YES;
    _bottomBar.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _coverImageView.frame = CGRectMake(0, 0, self.view.width,self.view.height);
        _effectView.frame = CGRectMake(0, self.view.height, _effectView.width, _effectView.height);
    } completion:^(BOOL finished) {
        _videoPreview.frame = _coverImageView.frame;
        _videoPreview.hidden = NO;
        _coverImageView.hidden = YES;
    }];
    [self startPlayFromTime:0 toTime:_duration];
    [self setPlayBtn:YES];
}

-(void)onDeleteEffect
{
    CGFloat endTime = 0;
    if (_effectSelectType == EffectSelectType_Effect) {
        VideoColorInfo *info = [_videoCutView removeLastColoration:ColorType_Effect];
        if (info) {
            float time = _isReverse ? MAX(info.endPos, info.startPos) : MIN(info.endPos, info.startPos);
            [_videoCutView setPlayTime:time];
            _playTime = time;
        }
        [_ugcEdit deleteLastEffect];
    }
    else if (_effectSelectType == EffectSelectType_Paster){
        if (_pasterEffectArray.count <= 1) {
            return;
        }
        VideoPasterInfo *info = [_videoPasterInfoList lastObject];
        [info.pasterView removeFromSuperview];
        [_videoPasterInfoList removeLastObject];
        [_pasterEffectArray removeObjectAtIndex:_pasterEffectArray.count - 2];
        [_effectSelectView setEffectList:_pasterEffectArray];
        [_videoCutView removeLastColoration:ColorType_Paster];
        if (_videoPasterInfoList.count > 0) {
            VideoPasterInfo *info = [_videoPasterInfoList lastObject];
            [self setLeftPanFrame:info.startTime rightPanFrame:info.endTime];
            endTime = info.endTime;
        }else{
            [self setLeftPanFrame:0 rightPanFrame:0];
            endTime = 0;
        }
        [self setVideoPastersToSDK];
        [_ugcEdit previewAtTime:endTime];
    }
    else if (_effectSelectType == EffectSelectType_Text){
        if (_textEffectArray.count <= 1) {
            return;
        }
        VideoTextInfo *info = [_videoTextInfoList lastObject];
        [info.textField removeFromSuperview];
        [_videoTextInfoList removeLastObject];
        [_textEffectArray removeObjectAtIndex:_textEffectArray.count - 2];
        [_effectSelectView setEffectList:_textEffectArray];
        [_videoCutView removeLastColoration:ColorType_Text];
        if (_videoTextInfoList.count > 0) {
            VideoTextInfo *info = [_videoTextInfoList lastObject];
            [self setLeftPanFrame:info.startTime rightPanFrame:info.endTime];
            endTime = info.endTime;
        }else{
            [self setLeftPanFrame:0 rightPanFrame:0];
            endTime = 0;
        }
        [self setVideoSubtitlesToSDK];
        [_ugcEdit previewAtTime:endTime];
    }
}

- (void)removeAllPasterViewFromSuperView
{
    for (VideoPasterInfo* pasterInfo in _videoPasterInfoList) {
        [pasterInfo.pasterView removeFromSuperview];
    }
}

- (void)removeAllTextFieldFromSuperView
{
    for (VideoTextInfo* textInfo in _videoTextInfoList) {
        [textInfo.textField removeFromSuperview];
    }
}

- (void)removeCurrentPasterInfo
{
    if (_effectSelectIndex >= _videoPasterInfoList.count
        ||  _effectSelectIndex >= _pasterEffectArray.count - 1
        || _effectSelectIndex < 0) {
        return;
    }
    [_videoPasterInfoList removeObjectAtIndex:_effectSelectIndex];
    [_pasterEffectArray removeObjectAtIndex:_effectSelectIndex];
    [_effectSelectView setEffectList:_pasterEffectArray];
    [_videoCutView removeColoration:ColorType_Paster index:_effectSelectIndex];
    
    if (_videoPasterInfoList.count > 0) {
        VideoPasterInfo *info = [_videoPasterInfoList lastObject];
        [self setLeftPanFrame:info.startTime rightPanFrame:info.endTime];
    }else{
        [self setLeftPanFrame:0 rightPanFrame:0];
    }
    _effectSelectIndex = _pasterEffectArray.count - 2;
    [self setVideoPastersToSDK];
}


- (void)removeCurrentTextInfo
{
    if (_effectSelectIndex >= _videoTextInfoList.count
        ||  _effectSelectIndex >= _textEffectArray.count - 1
        || _effectSelectIndex < 0) {
        return;
    }
    [_videoTextInfoList removeObjectAtIndex:_effectSelectIndex];
    [_textEffectArray removeObjectAtIndex:_effectSelectIndex];
    [_effectSelectView setEffectList:_textEffectArray];
    [_videoCutView removeColoration:ColorType_Text index:_effectSelectIndex];
    
    if (_videoTextInfoList.count > 0) {
        VideoTextInfo *info = [_videoTextInfoList lastObject];
        [self setLeftPanFrame:info.startTime rightPanFrame:info.endTime];
    }else{
        [self setLeftPanFrame:0 rightPanFrame:0];
    }
    _effectSelectIndex = _textEffectArray.count - 2;
    [self setVideoSubtitlesToSDK];
}


- (CGFloat)getLastPasterEndTime
{
    if (_videoPasterInfoList.count > 0) {
        return [_videoPasterInfoList lastObject].endTime;
    }
    return 0;
}

- (CGFloat)getLastTextEndTime
{
    if (_videoTextInfoList.count > 0) {
        return [_videoTextInfoList lastObject].endTime;
    }
    return 0;
}

- (void)clearEffect
{
    switch (_effectSelectType) {
        case EffectSelectType_Effect:
            break;
        case EffectSelectType_Time:
        {
            [_ugcEdit setSpeedList:nil];
            [_ugcEdit setReverse:NO];
            [_ugcEdit setRepeatPlay:nil];
            [_videoCutView setCenterPanHidden:YES];
        }
            break;
        case EffectSelectType_Filter:
        {
            [_ugcEdit setFilter:nil];
        }
            break;
        case EffectSelectType_Paster:
        {
            NSInteger i = _videoPasterInfoList.count;
            while (i > 0) {
                [_videoCutView removeLastColoration:ColorType_Paster];
                i -- ;
            }
            [self removeAllPasterViewFromSuperView];
            [_videoPasterInfoList removeAllObjects];
            [_pasterEffectArray removeObjectsInRange:NSMakeRange(0, _pasterEffectArray.count - 1)];
            [_ugcEdit setPasterList:nil];
            [_ugcEdit setAnimatedPasterList:nil];
        }
            break;
        case EffectSelectType_Text:
        {
            NSInteger i = _videoTextInfoList.count;
            while (i > 0) {
                [_videoCutView removeLastColoration:ColorType_Text];
                i -- ;
            }
            [self removeAllTextFieldFromSuperView];
            [_videoTextInfoList removeAllObjects];
            [_textEffectArray removeObjectsInRange:NSMakeRange(0, _textEffectArray.count - 1)];
            [_ugcEdit setSubtitleList:nil];
        }
            break;
        default:
            break;
    }
}

- (void)resetVideoProgress
{
    _playTime = 0;
    _isSeek = YES;
    _isPlay = NO;
    _timeLabel.text = @"00:00";
    [_ugcEdit previewAtTime:_playTime];
    [self setPlayBtn:NO];
}

//设置特效选中区间
- (void)setLeftPanFrame:(CGFloat)leftTime rightPanFrame:(CGFloat)rightTime
{
    if (leftTime == 0 && rightTime == 0) {
        [_videoCutView setLeftPanHidden:YES];
        [_videoCutView setRightPanHidden:YES];
        [_videoCutView setLeftPanFrame:0];
        [_videoCutView setRightPanFrame:0];
        [_videoCutView setPlayTime:0];
    }else{
        [_videoCutView setLeftPanHidden:NO];
        [_videoCutView setRightPanHidden:NO];
        [_videoCutView setLeftPanFrame:leftTime];
        [_videoCutView setRightPanFrame:rightTime];
        [_videoCutView setPlayTime:leftTime];
    }
}

-(void)startPlayFromTime:(CGFloat)startTime toTime:(CGFloat)endTime
{
    [_ugcEdit startPlayFromTime:startTime toTime:endTime];
    _isSeek = NO;
    _isPlay = YES;
}
#pragma mark - To SDK

- (void)generateVideo
{
    [_ugcEdit pausePlay];
    [self setPlayBtn:NO];
    
    //if (YES == [[[NSUserDefaults standardUserDefaults] objectForKey:hasAgreeUserAgreement] boolValue] || _actionType == ActionType_Save) {
        [self confirmGenerateVideo];
//    }else{
//        TCUserAgreementController *agreementController = [[TCUserAgreementController alloc] init];
//        __weak __typeof(self) weakSelf = self;
//        agreementController.agree = ^(BOOL isAgree) {
//            if (isAgree) {
//                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:hasAgreeUserAgreement];
//                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//                [weakSelf confirmGenerateVideo];
//            }else{
//                UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"不同意用户协议将无法发布视频" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:hasAgreeUserAgreement];
//                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//                }];
//                [alert show];
//            }
//        };
//        [self.navigationController presentViewController:agreementController animated:YES completion:nil];
//    }
}

- (void)confirmGenerateVideo
{
    _generationView = [self generatingView];
    _generationView.hidden = NO;
    _generateCannelBtn.hidden = NO;
    [_ugcEdit setCutFromTime:0 toTime:_duration];
    [_ugcEdit generateVideo:VIDEO_COMPRESSED_720P videoOutputPath:_videoOutputPath];
}

- (void)publishVideo
{
    [[TCLoginModel sharedInstance] getVodSign:^(int errCode, NSString *msg, NSDictionary *resultDict) {
        [TCUtil report:xiaoshipin_videosign userName:nil code:errCode msg:msg];
        if (errCode == 200 && resultDict){
            NSString *signature = resultDict[@"signature"];
            if (signature && signature.length > 0 && _videoPublish) {
                TXVideoInfo *videoInfo = [TXVideoInfoReader getVideoInfo:_videoOutputPath];
                TXPublishParam *publishParam = [[TXPublishParam alloc] init];
                publishParam.signature  = signature;
                publishParam.coverPath = [self getCoverPath:videoInfo.coverImage];
                publishParam.videoPath  = _videoOutputPath;
                [_videoPublish publishVideo:publishParam];
            }
        }else{
            _generationView.hidden = YES;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频上传失败"
                                                                message:[NSString stringWithFormat:@"错误码：%d",errCode]
                                                               delegate:self
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

//设置贴纸（静态/动态贴纸）
- (void)setVideoPastersToSDK
{
    NSMutableArray* animatePasters = [NSMutableArray new];
    NSMutableArray* staticPasters = [NSMutableArray new];
    for (VideoPasterInfo* pasterInfo in _videoPasterInfoList) {
        if ([_videoPreview.subviews containsObject:pasterInfo.pasterView]) {
            continue;
        }
        if (pasterInfo.pasterInfoType == PasterInfoType_Animate) {
            TXAnimatedPaster* paster = [TXAnimatedPaster new];
            paster.startTime = pasterInfo.startTime;
            paster.endTime = pasterInfo.endTime;
            paster.frame = [pasterInfo.pasterView pasterFrameOnView:_videoPreview];
            paster.rotateAngle = pasterInfo.pasterView.rotateAngle * 180 / M_PI;
            paster.animatedPasterpath = pasterInfo.path;
            [animatePasters addObject:paster];
        }
        else if (pasterInfo.pasterInfoType == PasterInfoType_static){
            TXPaster *paster = [TXPaster new];
            paster.startTime = pasterInfo.startTime;
            paster.endTime = pasterInfo.endTime;
            paster.frame = [pasterInfo.pasterView pasterFrameOnView:_videoPreview];
            paster.pasterImage = pasterInfo.pasterView.staticImage;
            [staticPasters addObject:paster];
        }
    }
    [_ugcEdit setAnimatedPasterList:animatePasters];
    [_ugcEdit setPasterList:staticPasters];
}

//设置字幕(气泡)
- (void)setVideoSubtitlesToSDK
{
    NSMutableArray* subtitles = [NSMutableArray new];
    NSMutableArray<VideoTextInfo*>* emptyVideoTexts;
    for (VideoTextInfo* textInfo in _videoTextInfoList) {
        if (textInfo.textField.text.length < 1) {
            [emptyVideoTexts addObject:textInfo];
            continue;
        }
        if ([_videoPreview.subviews containsObject:textInfo.textField]) {
            continue;
        }
        
        TXSubtitle* subtitle = [TXSubtitle new];
        subtitle.titleImage = textInfo.textField.textImage;
        subtitle.frame = [textInfo.textField textFrameOnView:_videoPreview];
        subtitle.startTime = textInfo.startTime;
        subtitle.endTime = textInfo.endTime;
        [subtitles addObject:subtitle];
    }
    [_ugcEdit setSubtitleList:subtitles];
}


- (void)setFilter:(NSInteger)index
{
    NSString* lookupFileName = @"";
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_white:
            lookupFileName = @"white.png";
            break;
        case FilterType_langman:
            lookupFileName = @"langman.png";
            break;
        case FilterType_qingxin:
            lookupFileName = @"qingxin.png";
            break;
        case FilterType_weimei:
            lookupFileName = @"weimei.png";
            break;
        case FilterType_fennen:
            lookupFileName = @"fennen.png";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"huaijiu.png";
            break;
        case FilterType_landiao:
            lookupFileName = @"landiao.png";
            break;
        case FilterType_qingliang:
            lookupFileName = @"qingliang.png";
            break;
        case FilterType_rixi:
            lookupFileName = @"rixi.png";
            break;
        default:
            break;
    }
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"];
    UIImage* image;
    if (path != nil && index != FilterType_None) {
        path = [path stringByAppendingPathComponent:lookupFileName];
        image = [UIImage imageWithContentsOfFile:path];
    } else {
        image = nil;
    }
    [_ugcEdit setFilter:image];
}

#pragma mark VideoPreviewDelegate
- (void)onVideoPlay
{
    [self startPlayFromTime:0 toTime:_duration];
}

- (void)onVideoPlayProgress:(CGFloat)time
{
    if (!_isSeek) {
        _playTime = time;
        [_videoCutView setPlayTime:_playTime];
        _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)_playTime / 60 , (int)_playTime % 60];
    }
}

- (void)onVideoPlayFinished
{
    if (_effectType != -1) {
        [self onEffectBtnEndSelect:nil];
    }else{
        [self startPlayFromTime:0 toTime:_duration];
    }
}

#pragma mark TXVideoGenerateListener
-(void) onGenerateProgress:(float)progress
{
    _generateProgressView.progress = progress;
}

-(void) onGenerateComplete:(TXGenerateResult *)result
{
    [TCUtil report:xiaoshipin_videoedit userName:nil code:result.retCode msg:result.descMsg];
    if (result.retCode == 0) {
        if (_actionType == ActionType_Publish) {
            _generationTitleLabel.text = @"视频发布中";
            _generateProgressView.progress = 0;
            _generateCannelBtn.hidden = YES;
            [self publishVideo];
        }else{
            _generationView.hidden = YES;
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:_videoOutputPath] completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error != nil) {
                    [self toastTip:@"视频保存失败！"];
                }else{
                    [self toastTip:@"视频保存成功啦！"];
                }
                [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:1];
            }];
        }
        
    }else{
        _generationView.hidden = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频生成失败"
                                                            message:[NSString stringWithFormat:@"错误码：%ld 错误信息：%@",(long)result.retCode,result.descMsg]
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - TXVideoPublishListener
-(void) onPublishProgress:(uint64_t)uploadBytes totalBytes: (uint64_t)totalBytes
{
    _generateProgressView.progress = (float)uploadBytes / totalBytes;;
}

-(void) onPublishComplete:(TXPublishResult*)result
{
    [TCUtil report:xiaoshipin_videouploadvod userName:nil code:result.retCode msg:result.descMsg];
    _generationView.hidden = YES;
    if (result.retCode != 0) {
        [self toastTip:@"发布失败！"];
    }else{
        NSString *title = @"小视频";
        NSDictionary* dictParam = @{@"userid" :[TCLoginParam shareInstance].identifier,
                                    @"file_id" : result.videoId,
                                    @"title":title,
                                    @"frontcover":result.coverURL == nil ? @"" : result.coverURL,
                                    @"location":@"未知",
                                    @"play_url":result.videoURL};
        [[TCLoginModel sharedInstance] uploadUGC:dictParam completion:^(int errCode, NSString *msg, NSDictionary *resultDict) {
            [TCUtil report:xiaoshipin_videouploadserver userName:nil code:errCode msg:msg];
            if (200 == errCode) {
                [self toastTip:@"发布成功了！"];
            } else {
                [self toastTip:[NSString stringWithFormat:@"UploadUGCVideo Failed[%d]", errCode]];
            }
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:1];
        }];
    }
}

- (void)dismissViewController
{
    [_ugcEdit stopPlay];
    if (_isFromChorus){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCLiveListUpdated object:nil];
        }];
    }
}

#pragma mark - BottomTabBarDelegate
- (void)onMusicBtnClicked
{
    _bottomBar.hidden = YES;
    [self onSelectMusic];
    [self setLeftPanFrame:0 rightPanFrame:0];
    [self resetConfirmBtn];
}

- (void)onEffectBtnClicked
{
    _bottomBar.hidden = YES;
    _deleteBtn.hidden = NO;
    [self resetConfirmBtn];
    [self resetVideoProgress];
    [self onShowEffectView];
    [self removeAllTextFieldFromSuperView];
    [self removeAllPasterViewFromSuperView];
    [self setLeftPanFrame:0 rightPanFrame:0];
    _effectSelectType = EffectSelectType_Effect;
    [_videoCutView setColorType:ColorType_Effect];
    [_videoCutView setCenterPanHidden:YES];
    __block NSArray <EffectInfo *> *effectArray = nil;
    dispatch_barrier_sync(_imageLoadingQueue, ^{
        effectArray = _effectList;
    });
    [_effectSelectView setEffectList:effectArray momentary:YES];
}

-(void)onTimeBtnClicked
{
    _bottomBar.hidden = YES;
    _deleteBtn.hidden = YES;
    [self resetConfirmBtn];
    [self resetVideoProgress];
    [self onShowEffectView];
    [self removeAllTextFieldFromSuperView];
    [self removeAllPasterViewFromSuperView];
    [self setLeftPanFrame:0 rightPanFrame:0];
    _effectSelectType = EffectSelectType_Time;
    [_videoCutView setColorType:ColorType_Time];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray <EffectInfo *> *effectArray = [NSMutableArray array];
        [effectArray addObject:({
            EffectInfo * v= [EffectInfo new];
            v.name = @"无";
            v.animateIcons = [NSMutableArray array];
            for (int i = 0; i < 20; i ++) {
                [v.animateIcons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"jump_%d",i]]];
            }
            v;
        })];
        [effectArray addObject:({
            EffectInfo * v= [EffectInfo new];
            v.name = @"时光倒流";
            v.animateIcons = [NSMutableArray array];
            v.selectIcon = [UIImage imageNamed:@"timeBack_select"];
            for (int i = 19; i >= 0; i --) {
                [v.animateIcons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"jump_%d",i]]];
            }
            v;
        })];
        [effectArray addObject:({
            EffectInfo * v= [EffectInfo new];
            v.name = @"反复";
            v.animateIcons = [NSMutableArray array];
            v.selectIcon = [UIImage imageNamed:@"repeat_select"];
            NSMutableArray *repeatIcons = [NSMutableArray array];
            for (int i = 0; i < 20; i ++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"jump_%d",i]];
                if (i >= 5 && i <= 15) {
                    [repeatIcons addObject:image];
                }
                if (i == 15) {
                    [v.animateIcons addObjectsFromArray:repeatIcons];
                    [v.animateIcons addObjectsFromArray:repeatIcons];
                }
                [v.animateIcons addObject:image];
            }
            v;
        })];
        [effectArray addObject:({
            EffectInfo * v= [EffectInfo new];
            v.name = @"慢动作";
            v.animateIcons = [NSMutableArray array];
            v.selectIcon = [UIImage imageNamed:@"slow_select"];
            v.isSlow = YES;
            for (int i = 0; i < 20; i ++) {
                [v.animateIcons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"jump_%d",i]]];
            }
            v;
        })];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_effectSelectView setEffectList:effectArray];
        });
    });
}

- (void)onFilterBtnClicked
{
    _bottomBar.hidden = YES;
    _deleteBtn.hidden = YES;
    [self resetConfirmBtn];
    [self resetVideoProgress];
    [self onShowEffectView];
    [self setLeftPanFrame:0 rightPanFrame:0];
    NSMutableArray <EffectInfo *> *effectArray = [NSMutableArray array];
    [effectArray addObject:({
        EffectInfo * v= [EffectInfo new];
        v.name = @"原图";
        v.icon = [UIImage imageNamed:@"orginal"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"美白";
        v.icon = [UIImage imageNamed:@"fwhite"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"浪漫";
        v.icon = [UIImage imageNamed:@"langman"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"清新";
        v.icon = [UIImage imageNamed:@"qingxin"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"唯美";
        v.icon = [UIImage imageNamed:@"weimei"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"粉嫩";
        v.icon = [UIImage imageNamed:@"fennen"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"怀旧";
        v.icon = [UIImage imageNamed:@"huaijiu"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"蓝调";
        v.icon = [UIImage imageNamed:@"landiao"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"清凉";
        v.icon = [UIImage imageNamed:@"qingliang"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [effectArray addObject:({
        EffectInfo *v = [EffectInfo new];
        v.name = @"日系";
        v.icon = [UIImage imageNamed:@"rixi"];
        v.selectIcon = [UIImage imageNamed:@"orginal_select"];
        v;
    })];
    [_effectSelectView setEffectList:effectArray];
    _effectSelectType = EffectSelectType_Filter;
    [_videoCutView setColorType:ColorType_Filter];
    [_videoCutView setCenterPanHidden:YES];
    [self removeAllTextFieldFromSuperView];
    [self removeAllPasterViewFromSuperView];
}

- (void)onPasterBtnClicked
{
    _bottomBar.hidden = YES;
    _deleteBtn.hidden = NO;
    [self resetConfirmBtn];
    [self resetVideoProgress];
    [self onShowEffectView];
    [self removeAllTextFieldFromSuperView];
    [self setLeftPanFrame:0 rightPanFrame:0];
    [_effectSelectView setEffectList:_pasterEffectArray];
    [_videoCutView setColorType:ColorType_Paster];
    [_videoCutView setCenterPanHidden:YES];
    _effectSelectType = EffectSelectType_Paster;
}

- (void)onTextBtnClicked
{
    _bottomBar.hidden = YES;
    _deleteBtn.hidden = NO;
    [self resetConfirmBtn];
    [self resetVideoProgress];
    [self onShowEffectView];
    [self removeAllPasterViewFromSuperView];
    [self setLeftPanFrame:0 rightPanFrame:0];
    [_effectSelectView setEffectList:_textEffectArray];
    [_videoCutView setColorType:ColorType_Text];
    [_videoCutView setCenterPanHidden:YES];
    _effectSelectType = EffectSelectType_Text;
}

#pragma mark EffectSelectViewDelegate
-(void)onEffectBtnBeginSelect:(UIButton *)btn
{
    if (_effectSelectType != EffectSelectType_Effect) {
        return;
    }
    _effectType = (TXEffectType)btn.tag;
    UIColor *color = TXCVEFColorPaletteColorAtIndex(btn.tag);
    [_videoCutView startColoration:color alpha:0.7];

    [_ugcEdit startEffect:(TXEffectType)_effectType startTime:_playTime];
    if (!_isReverse) {
        [self startPlayFromTime:_playTime toTime:_duration];
    }else{
        [self startPlayFromTime:0 toTime:_playTime];
    }
    [self setPlayBtn:YES];
}

-(void)onEffectBtnEndSelect:(UIButton *)btn
{
    if (_effectType != -1) {
        [_videoCutView stopColoration];
        [_ugcEdit stopEffect:_effectType endTime:_playTime];
        [_ugcEdit pausePlay];
        _effectType = -1;
        [self setPlayBtn:NO];
    }
}

-(void)onEffectBtnSelected:(UIButton *)btn
{
    _effectSelectIndex = btn.tag;
    switch (_effectSelectType) {
        case EffectSelectType_Time:
        {
            switch (_effectSelectIndex) {
                case 0:
                    [self onVideoTimeEffectsClear];
                    break;
                case 1:
                    [self onVideoTimeEffectsBackPlay];
                    break;
                case 2:
                    [self onVideoTimeEffectsRepeat];
                    break;
                case 3:
                    [self onVideoTimeEffectsSpeed];
                    break;
                default:
                    break;
            }
        }
            break;
        case EffectSelectType_Filter:
        {
            [self setFilter:_effectSelectIndex];
            if (!_isPlay) {
                [_ugcEdit resumePlay];
                [self setPlayBtn:YES];
                _isPlay = YES;
                _isSeek = NO;
            }
        }
            break;
        case EffectSelectType_Paster:
        {
            [_ugcEdit pausePlay];
            [self setPlayBtn:NO];
            [self removeAllPasterViewFromSuperView];
            if (_effectSelectIndex == _pasterEffectArray.count - 1) {
                _pasterAddView.hidden = NO;
                [_pasterAddView setPasterType:PasterType_Animate];
            }else{
                VideoPasterInfo* pasterInfo = _videoPasterInfoList[_effectSelectIndex];
                [_videoPreview addSubview:pasterInfo.pasterView];
                [self setLeftPanFrame:pasterInfo.startTime rightPanFrame:pasterInfo.endTime];
                [_ugcEdit previewAtTime:pasterInfo.endTime];
            }
        }
            break;
            
        case EffectSelectType_Text:
        {
            [_ugcEdit pausePlay];
            [self setPlayBtn:NO];
            [self removeAllTextFieldFromSuperView];
            if (_effectSelectIndex == _textEffectArray.count - 1) {
                _pasterAddView.hidden = NO;
                [_pasterAddView setPasterType:PasterType_Qipao];
            }else{
                VideoTextInfo* textInfo = _videoTextInfoList[_effectSelectIndex];
                [_videoPreview addSubview:textInfo.textField];
                [self setLeftPanFrame:textInfo.startTime rightPanFrame:textInfo.endTime];
                [_ugcEdit previewAtTime:textInfo.endTime];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)onVideoTimeEffectsClear
{
    _timeType = TimeType_Clear;
    _isReverse = NO;
    [_ugcEdit setReverse:_isReverse];
    [_ugcEdit setRepeatPlay:nil];
    [_ugcEdit setSpeedList:nil];
    [self startPlayFromTime:0 toTime:_duration];
    
    [self setPlayBtn:YES];
    [_videoCutView setCenterPanHidden:YES];
}
- (void)onVideoTimeEffectsBackPlay
{
    _timeType = TimeType_Back;
    _isReverse = YES;
    [_ugcEdit setReverse:_isReverse];
    [_ugcEdit setRepeatPlay:nil];
    [_ugcEdit setSpeedList:nil];
    [self startPlayFromTime:0 toTime:_duration];
    
    [self setPlayBtn:YES];
    [_videoCutView setCenterPanHidden:YES];
}
- (void)onVideoTimeEffectsRepeat
{
    _timeType = TimeType_Repeat;
    _isReverse = NO;
    [_ugcEdit setReverse:_isReverse];
    [_ugcEdit setSpeedList:nil];
    TXRepeat *repeat = [[TXRepeat alloc] init];
    repeat.startTime = _duration / 5;
    repeat.endTime = repeat.startTime + 0.5;
    repeat.repeatTimes = 3;
    [_ugcEdit setRepeatPlay:@[repeat]];
    [self startPlayFromTime:0 toTime:_duration];
    
    [self setPlayBtn:YES];
    [_videoCutView setCenterPanHidden:NO];
    [_videoCutView setCenterPanFrame:repeat.startTime];
}

- (void)onVideoTimeEffectsSpeed
{
    _timeType = TimeType_Speed;
    _isReverse = NO;
    [_ugcEdit setReverse:_isReverse];
    [_ugcEdit setRepeatPlay:nil];

    TXSpeed *speed1 =[[TXSpeed alloc] init];
    speed1.startTime = _duration* 1.5 / 5;
    speed1.endTime = speed1.startTime + 0.5;
    speed1.speedLevel = SPEED_LEVEL_SLOW;
    TXSpeed *speed2 =[[TXSpeed alloc] init];
    speed2.startTime = speed1.endTime;
    speed2.endTime = speed2.startTime + 0.5;
    speed2.speedLevel = SPEED_LEVEL_SLOWEST;
    TXSpeed *speed3 =[[TXSpeed alloc] init];
    speed3.startTime = speed2.endTime;
    speed3.endTime = speed3.startTime + 0.5;
    speed3.speedLevel = SPEED_LEVEL_SLOW;
    [_ugcEdit setSpeedList:@[speed1,speed2,speed3]];
    
    [self startPlayFromTime:0 toTime:_duration];
    [self setPlayBtn:YES];
    [_videoCutView setCenterPanHidden:NO];
    [_videoCutView setCenterPanFrame:speed1.startTime];
}

#pragma mark PasterAddViewDelegate
- (void)onPasterQipaoSelect:(PasterQipaoInfo *)info
{
    [self removeAllTextFieldFromSuperView];
    int width = 170;
    int height = info.height / info.width * width;
    VideoTextFiled* videoTextField = [[VideoTextFiled alloc] initWithFrame:CGRectMake((_videoPreview.width - 170) / 2, (_videoPreview.height - 50) / 2, 170, 50)];
    [videoTextField setTextBubbleImage:info.image textNormalizationFrame:CGRectMake(info.textLeft / info.width, info.textTop / info.height, (info.width - info.textLeft - info.textRight) / info.width, (info.height - info.textTop - info.textBottom) / info.height)];
    videoTextField.frame = CGRectMake((_videoPreview.width - width) / 2, (_videoPreview.height - height) / 2, width, height);
    videoTextField.delegate = self;
    [_videoPreview addSubview:videoTextField];
    
    CGFloat percent = _duration / 10.0;
    CGFloat startTime = ([self getLastTextEndTime] == 0 ? 0 : [self getLastTextEndTime] + percent);
    if (startTime > _duration) {
        startTime = 0;
    }
    CGFloat endTime = startTime + percent;
    if(endTime > _duration){
        endTime = _duration;
    }
    VideoTextInfo* textInfo = [VideoTextInfo new];
    textInfo.textField = videoTextField;
    textInfo.startTime = startTime;
    textInfo.endTime = endTime;
    [_videoTextInfoList addObject:textInfo];
    
    [_textEffectArray insertObject:({
        EffectInfo * v= [EffectInfo new];
        v.name = @"气泡字幕";
        v.icon = info.iconImage;
        v;
    }) atIndex:_textEffectArray.count - 1];
    [_effectSelectView setEffectList:_textEffectArray];
    _effectSelectIndex = _textEffectArray.count - 2;
    
    [self setLeftPanFrame:startTime rightPanFrame:endTime];
    [_ugcEdit previewAtTime:endTime];
    [_videoCutView startColoration:[UIColor redColor] alpha:0.7];
}

- (void)onPasterAnimateSelect:(PasterAnimateInfo *)info
{
    [self removeAllPasterViewFromSuperView];
    int width = 170;
    int height = info.height / info.width * width;
    VideoPasterView *pasterView = [[VideoPasterView alloc] initWithFrame:CGRectMake((_videoPreview.width - width) / 2, (_videoPreview.height - height) / 2, width, height)];
    pasterView.delegate = self;
    [pasterView setImageList:info.imageList imageDuration:info.duration];
    [_videoPreview addSubview:pasterView];
    
    CGFloat percent = _duration / 10.0;
    CGFloat startTime = ([self getLastPasterEndTime] == 0 ? 0 : [self getLastPasterEndTime] + percent);
    if (startTime > _duration) {
        startTime = 0;
    }
    CGFloat endTime = startTime + percent;
    if(endTime > _duration){
        endTime = _duration;
    }
    VideoPasterInfo* pasterInfo = [[VideoPasterInfo alloc] init];
    pasterInfo.pasterView = pasterView;
    pasterInfo.pasterInfoType = PasterInfoType_Animate;
    pasterInfo.path = info.path;
    pasterInfo.iconImage = info.iconImage;
    pasterInfo.startTime = startTime;
    pasterInfo.endTime = endTime;
    [_videoPasterInfoList addObject:pasterInfo];
    
    [_pasterEffectArray insertObject:({
        EffectInfo * v= [EffectInfo new];
        v.name = @"动态贴纸";
        v.icon = info.iconImage;
        v;
    }) atIndex:_pasterEffectArray.count - 1];
    [_effectSelectView setEffectList:_pasterEffectArray];
     _effectSelectIndex = _pasterEffectArray.count - 2;
    
    [self setLeftPanFrame:startTime rightPanFrame:endTime];
    [_ugcEdit previewAtTime:endTime];
    [_videoCutView startColoration:[UIColor redColor] alpha:0.7];
}

- (void)onPasterStaticSelect:(PasterStaticInfo *)info
{
    [self removeAllPasterViewFromSuperView];
    int width = 170;
    int height = info.height / info.width * width;
    VideoPasterView *pasterView = [[VideoPasterView alloc] initWithFrame:CGRectMake((_videoPreview.width - width) / 2, (_videoPreview.height - height) / 2, width, height)];
    pasterView.delegate = self;
    [pasterView setImageList:@[info.image] imageDuration:0];
    [_videoPreview addSubview:pasterView];
    
    CGFloat percent = _duration / 10.0;
    CGFloat startTime = ([self getLastPasterEndTime] == 0 ? 0 : [self getLastPasterEndTime] + percent);
    if (startTime > _duration) {
        startTime = 0;
    }
    CGFloat endTime = startTime + percent;
    if(endTime > _duration){
        endTime = _duration;
    }
    VideoPasterInfo* pasterInfo = [[VideoPasterInfo alloc] init];
    pasterInfo.pasterView = pasterView;
    pasterInfo.pasterInfoType = PasterInfoType_static;
    pasterInfo.image = info.image;
    pasterInfo.iconImage = info.iconImage;
    pasterInfo.startTime = startTime;
    pasterInfo.endTime = endTime;
    [_videoPasterInfoList addObject:pasterInfo];
    
    [_pasterEffectArray insertObject:({
        EffectInfo * v= [EffectInfo new];
        v.name = @"静态贴纸";
        v.icon = info.iconImage;
        v;
    }) atIndex:_pasterEffectArray.count - 1];
    [_effectSelectView setEffectList:_pasterEffectArray];
    _effectSelectIndex = _pasterEffectArray.count - 2;
    
    [self setLeftPanFrame:startTime rightPanFrame:endTime];
    [_ugcEdit previewAtTime:endTime];
    [_videoCutView startColoration:[UIColor redColor] alpha:0.7];
}
#pragma mark VideoPasterViewDelegate
- (void)onPasterViewTap
{
    
}
- (void)onRemovePasterView:(VideoPasterView*)pasterView
{
    [pasterView removeFromSuperview];
    [self removeCurrentPasterInfo];
}

#pragma mark VideoTextFieldDelegate
- (void)onBubbleTap
{
    
}

- (void)onTextInputBegin
{
    _effectConfirmBtn.enabled = NO;
}

- (void)onTextInputDone:(NSString*)text
{
    _effectConfirmBtn.enabled = YES;
}

- (void)onRemoveTextField:(VideoTextFiled*)textField
{
    [textField removeFromSuperview];
    [self removeCurrentTextInfo];
}

#pragma mark - VideoCutViewDelegate
- (void)onVideoRangeTap:(CGFloat)tapTime
{
    if (_effectSelectType == EffectSelectType_Paster) {
        [self removeAllPasterViewFromSuperView];
        for (VideoPasterInfo *info in _videoPasterInfoList) {
            if (tapTime >= info.startTime && tapTime <= info.endTime) {
                [_videoPreview addSubview:info.pasterView];
                [self setPlayBtn:NO];
                [_ugcEdit previewAtTime:info.startTime];
                [self setLeftPanFrame:info.startTime rightPanFrame:info.endTime];
                _effectSelectIndex = [_videoPasterInfoList indexOfObject:info];
                break;
            }
        }
    }
    else if (_effectSelectType == EffectSelectType_Text) {
        [self removeAllTextFieldFromSuperView];
        for (VideoTextInfo *info in _videoTextInfoList) {
            if (tapTime >= info.startTime && tapTime <= info.endTime) {
                [_videoPreview addSubview:info.textField];
                [self setPlayBtn:NO];
                [_ugcEdit previewAtTime:info.startTime];
                [self setLeftPanFrame:info.startTime rightPanFrame:info.endTime];
                _effectSelectIndex = [_videoTextInfoList indexOfObject:info];
                break;
            }
        }
    }
}

- (void)onVideoRangeLeftChanged:(VideoRangeSlider *)sender
{
    [self setPlayBtn:NO];
    [_ugcEdit previewAtTime:sender.leftPos];
}

- (void)onVideoRangeLeftChangeEnded:(VideoRangeSlider *)sender
{
    if (_effectSelectType == EffectSelectType_Paster) {
        VideoPasterInfo *info = _videoPasterInfoList[_effectSelectIndex];
        info.startTime = sender.leftPos;
    }
    else if (_effectSelectType == EffectSelectType_Text) {
        VideoTextInfo *info = _videoTextInfoList[_effectSelectIndex];
        info.startTime = sender.leftPos;
    }
}

- (void)onVideoRangeRightChanged:(VideoRangeSlider *)sender
{
    [self setPlayBtn:NO];
    [_ugcEdit previewAtTime:sender.rightPos];
}

- (void)onVideoRangeRightChangeEnded:(VideoRangeSlider *)sender
{
    if (_effectSelectType == EffectSelectType_Paster) {
        VideoPasterInfo *info = _videoPasterInfoList[_effectSelectIndex];
        info.endTime = sender.rightPos;
    }
    else if (_effectSelectType == EffectSelectType_Text) {
        VideoTextInfo *info = _videoTextInfoList[_effectSelectIndex];
        info.endTime = sender.rightPos;
    }
}

- (void)onVideoRangeCenterChanged:(VideoRangeSlider*)sender
{
    [self setPlayBtn:NO];
    [_ugcEdit previewAtTime:sender.centerPos];
}

- (void)onVideoRangeCenterChangeEnded:(VideoRangeSlider*)sender;
{
    if (_timeType == TimeType_Repeat) {
        TXRepeat *repeat = [[TXRepeat alloc] init];
        repeat.startTime = sender.centerPos;
        repeat.endTime = sender.centerPos + 0.5;
        repeat.repeatTimes = 3;
        [_ugcEdit setRepeatPlay:@[repeat]];
        [_ugcEdit setSpeedList:nil];
    }
    else if (_timeType == TimeType_Speed) {
        TXSpeed *speed1 =[[TXSpeed alloc] init];
        speed1.startTime = sender.centerPos;;
        speed1.endTime = speed1.startTime + 0.5;
        speed1.speedLevel = SPEED_LEVEL_SLOW;
        TXSpeed *speed2 =[[TXSpeed alloc] init];
        speed2.startTime = speed1.endTime;
        speed2.endTime = speed2.startTime + 0.5;
        speed2.speedLevel = SPEED_LEVEL_SLOWEST;
        TXSpeed *speed3 =[[TXSpeed alloc] init];
        speed3.startTime = speed2.endTime;
        speed3.endTime = speed3.startTime + 0.5;
        speed3.speedLevel = SPEED_LEVEL_SLOW;
        [_ugcEdit setSpeedList:@[speed1,speed2,speed3]];
        [_ugcEdit setRepeatPlay:nil];
    }
    
    if (_isReverse) {
        [self startPlayFromTime:0 toTime:sender.centerPos + 1.5];
    }else{
        [self startPlayFromTime:sender.centerPos toTime:_duration];
    }
    [self setPlayBtn:YES];
}

- (void)onVideoSeekChange:(VideoRangeSlider *)sender seekToPos:(CGFloat)pos
{
    _playTime = pos;
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)_playTime / 60 , (int)_playTime % 60];
    [_ugcEdit previewAtTime:_playTime];
    [self setPlayBtn:NO];
}

#pragma mark - TCFilterSettingViewDelegate
//美颜
- (void)onSetBeautyDepth:(float)beautyDepth WhiteningDepth:(float)whiteningDepth
{
    [_ugcEdit setBeautyFilter:beautyDepth setWhiteningLevel:whiteningDepth];
}

#pragma mark TCBGMControllerListener
-(void) onBGMControllerPlay:(NSObject*) path
{
    if (path == nil) {
        _bottomBar.hidden = NO;
        [self resetConfirmBtn];
        [self startPlayFromTime:0 toTime:_duration];
        [self setPlayBtn:YES];
        return;
    }else{
        _BGMPath = path;
    }
    __weak __typeof(self) ws = self;
    if([_BGMPath isKindOfClass:[NSString class]]){
        _BGMDuration = [TXVideoInfoReader getVideoInfo:(NSString *)_BGMPath].duration;
        [_ugcEdit setBGM:(NSString *)_BGMPath result:^(int result) {
        if (result == 0) {
            [ws setBGMStartTime:0 endTime:MAXFLOAT];
        }
    }];
    }else{
        _BGMDuration = [TXVideoInfoReader getVideoInfoWithAsset:(AVAsset *)_BGMPath].duration;
        [_ugcEdit setBGMAsset:(AVAsset *)_BGMPath result:^(int result) {
            if (result == 0) {
                [ws setBGMStartTime:0 endTime:MAXFLOAT];
            }
        }];
    }
}

- (void)setBGMStartTime:(CGFloat)startTime endTime:(CGFloat)endTime
{
    if (!_BGMPath ) return;
    if (endTime == MAXFLOAT) {
        endTime = _BGMDuration;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_ugcEdit setBGMStartTime:startTime endTime:endTime];
        [_ugcEdit setBGMVolume:_BGMVolume];
        [_ugcEdit setVideoVolume:_videoVolume];
        [self startPlayFromTime:0 toTime:_duration];
        [self setPlayBtn:YES];
        _musicView.hidden = NO;
        _bottomBar.hidden = YES;
        [self resetConfirmBtn];
    });
}

#pragma mark VideoRecordMusicViewDelegate
-(void)onBtnMusicSelected
{
    [self resetVideoProgress];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:_bgmListVC];
    [nv.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    nv.navigationBar.barTintColor = RGB(25, 29, 38);
    [self presentViewController:nv animated:YES completion:nil];
    [_bgmListVC loadBGMList];
}
-(void)onBtnMusicStoped
{
    _BGMPath = nil;
    [_ugcEdit setBGM:nil result:^(int result) {
        
    }];
    _musicView.hidden = YES;
    _bottomBar.hidden = NO;
    [self resetConfirmBtn];
    [self startPlayFromTime:0 toTime:_duration];
}

-(void)onBGMValueChange:(CGFloat)percent
{
    _BGMVolume = 1.0 * percent;
    [_ugcEdit setBGMVolume:_BGMVolume];
}
-(void)onVoiceValueChange:(CGFloat)percent
{
    _videoVolume = 1.0 * percent;
    [_ugcEdit setVideoVolume:_videoVolume];
}
-(void)onBGMRangeChange:(CGFloat)startPercent endPercent:(CGFloat)endPercent
{
    [self setBGMStartTime:_BGMDuration * startPercent endTime:_BGMDuration * endPercent];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self onHideEffectView];
        [self clearEffect];
    }
}

#pragma mark - Utils
- (void)checkVideoOutputPath
{
    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:_videoOutputPath]) {
        BOOL success =  [manager removeItemAtPath:_videoOutputPath error:nil];
        if (success) {
            NSLog(@"Already exist. Removed!");
        }
    }
}

- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}


- (void) toastTip:(NSString*)toastInfo
{
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block UITextView * toastView = [[UITextView alloc] init];
    
    toastView.editable = NO;
    toastView.selectable = NO;
    
    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];
    
    toastView.frame = frameRC;
    
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;
    
    [self.view addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
}

-(NSString *)getCoverPath:(UIImage *)coverImage
{
    UIImage *image = coverImage;
    if (image == nil) {
        return nil;
    }
    
    NSString *coverPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TXUGC"];
    coverPath = [coverPath stringByAppendingPathComponent:[self getFileNameByTimeNow:@"TXUGC" fileType:@"jpg"]];
    if (coverPath) {
        // 保证目录存在
        [[NSFileManager defaultManager] createDirectoryAtPath:[coverPath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:coverPath atomically:YES];
    }
    return coverPath;
}

-(NSString *)getFileNameByTimeNow:(NSString *)type fileType:(NSString *)fileType {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = ((fileType == nil) ||
                          (fileType.length == 0)
                          ) ? [NSString stringWithFormat:@"%@_%@",type,timeStr] : [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,fileType];
    return fileName;
}


- (void)dealloc
{
    [_videoPreview removeNotification];
    _videoPreview = nil;
}

@end

