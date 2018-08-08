
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaPickerController.h>
#import <TXLiteAVSDK_UGC_IJK/TXVideoEditer.h>
#import "TCVideoRecordViewController.h"
#import "TCVideoPublishController.h"
#import "TCVideoEditViewController.h"
#import "TCVideoRecordMusicView.h"
#import "TCVideoRecordProcessView.h"
#import "V8HorizontalPickerView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TCBGMListViewController.h"
#import "BeautySettingPanel.h"
#import "MBProgressHUD.h"
#import "UIAlertView+BlocksKit.h"
#import "SDKHeader.h"

#define BUTTON_RECORD_SIZE          75
#define BUTTON_CONTROL_SIZE         40
#define BUTTON_PROGRESS_HEIGHT      3
#define BUTTON_MASK_HEIGHT          170
#define BUTTON_SPEED_HEIGHT         34
#define BUTTON_SPEED_INTERVAL       30
#define BUTTON_SPEED_COUNT          5
#define BUTTON_SPEED_CHANGE_WIDTH   50
#define BUTTON_SPEED_CHANGE_HEIGHT  34


typedef NS_ENUM(NSInteger,SpeedMode)
{
    SpeedMode_VerySlow,
    SpeedMode_Slow,
    SpeedMode_Standard,
    SpeedMode_Quick,
    SpeedMode_VeryQuick,
};

typedef NS_ENUM(NSInteger,RecordType)
{
    RecordType_Normal,
    RecordType_Chorus,
};

@implementation RecordMusicInfo
@end

#if POD_PITU
#import "MCCameraDynamicView.h"
#import "MaterialManager.h"
#import "MCTip.h"


#import "FUManager.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>


@interface TCVideoRecordViewController () <MCCameraDynamicDelegate,VideoRecordMusicViewDelegate,BeautySettingPanelDelegate,BeautyLoadPituDelegate,

TXVideoCustomProcessDelegate>

@end
#endif

@interface TCVideoRecordViewController()<TXUGCRecordListener,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource,MPMediaPickerControllerDelegate,TCBGMControllerListener,TXVideoJoinerListener>
{
    BOOL                            _cameraFront;
    BOOL                            _lampOpened;
    BOOL                            _vBeautyShow;
    
    CGSize                          _size;
    int                             _fps;
    TXAudioSampleRate               _sampleRate;
    int                             _beautyDepth;
    int                             _whitenDepth;
    
    BOOL                            _cameraPreviewing;
    BOOL                            _videoRecording;
    UIView *                        _videoRecordView;
    UIView *                        _videoPlayView;
    UIButton *                      _btnStartRecord;
    UIButton *                      _btnCamera;
    UIButton *                      _btnLamp;
    UIButton *                      _btnBeauty;
    UILabel *                       _recordTimeLabel;
    CGFloat                         _currentRecordTime;
    
    UIView *                        _beautyPage;
    UIView *                        _filterPage;
    UIView *                        _speedView;
    
    UIButton *                      _btnNext;
    UIButton *                      _btnRatio;
    UIButton *                      _btnRatio43;
    UIButton *                      _btnRatio11;
    UIButton *                      _btnRatio169;
    UILabel  *                      _labelRatio43;
    UILabel  *                      _labelRatio11;
    UILabel  *                      _labelRatio169;
    UIButton *                      _btnMusic;
    UIButton *                      _btnFlash;
    UIButton *                      _btnDelete;
    UIButton *                      _beautyBtn;
    UIButton *                      _filterBtn;
    UIButton *                      _speedChangeBtn;
    
    UISlider*                       _sdBeauty;
    UISlider*                       _sdWhitening;
    V8HorizontalPickerView *        _filterPickerView;
    NSMutableArray *                _filterArray;
    NSInteger                       _filterIndex;
    
    BOOL                            _navigationBarHidden;
    BOOL                            _statusBarHidden;
    BOOL                            _appForeground;
    BOOL                            _isPaused;
    
    UIButton              *_motionBtn;
#if POD_PITU
    MCCameraDynamicView   *_tmplBar;
    NSString              *_materialID;
#else
    UIView                *_tmplBar;
#endif
    UIButton              *_greenBtn;
    V8HorizontalPickerView  *_greenPickerView;
    NSMutableArray *_greenArray;
    
    TCBGMListViewController*        _bgmListVC;
    
    UILabel               *_beautyLabel;
    UILabel               *_whiteLabel;
    UILabel               *_bigEyeLabel;
    UILabel               *_slimFaceLabel;
    
    UISlider              *_sdBigEye;
    UISlider              *_sdSlimFace;
    
    int    _filterType;
    NSInteger    _greenIndex;;
    
    float  _eye_level;
    float  _face_level;
    
    CGRect                    _btnRatioFrame;
    UIView *                  _mask_buttom;
    NSMutableArray *          _speedBtnList;
    NSInteger                 _speedBtnSelectTag;
    NSObject*                 _BGMPath;
    CGFloat                   _BGMDuration;
    CGFloat                   _recordTime;

    int                       _deleteCount;
    float                     _zoom;
    BOOL                      _isBackDelete;
    BOOL                      _isFlash;
    
    TXVideoAspectRatio        _videoRatio;
    TCVideoRecordMusicView *  _musicView;
    TCVideoRecordProcessView* _progressView;
    TXVideoAspectRatio        _aspectRatio;
    SpeedMode                 _speedMode;
    
    BeautySettingPanel *      _vBeauty;
    MBProgressHUD*            _hub;
    CGFloat                   _bgmBeginTime;
    BOOL                      _bgmRecording;
    
    TXVideoEditer *           _videoEditer;
    TXVideoJoiner *           _videoJoiner;
    RecordType                _recordType;
    NSString *                _recordVideoPath;
    NSString *                _joinVideoPath;
}


@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
@end


@implementation TCVideoRecordViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _appForeground = YES;
        _cameraFront = YES;
        _lampOpened = NO;
        _vBeautyShow = NO;
        
        _beautyDepth = 6.3;
        _whitenDepth = 2.7;
        
        _cameraPreviewing = NO;
        _videoRecording = NO;

        _currentRecordTime = 0;
        _sampleRate = AUDIO_SAMPLERATE_44100;
        
        _greenArray = [NSMutableArray new];
        [_greenArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"无";
            v.file = nil;
            v.face = [UIImage imageNamed:@"greens_no"];
            v;
        })];
        [_greenArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"卡通";
            v.file = [[NSBundle mainBundle] URLForResource:@"goodluck" withExtension:@"mp4"];;
            v.face = [UIImage imageNamed:@"greens_1"];
            v;
        })];
        [_greenArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"DJ";
            v.file = [[NSBundle mainBundle] URLForResource:@"2gei_5" withExtension:@"mp4"];
            v.face = [UIImage imageNamed:@"greens_2"];
            v;
        })];
        
        _filterIndex = 0;
        _filterArray = [NSMutableArray new];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"原图";
            v.face = [UIImage imageNamed:@"orginal"];
            v;
        })];
        
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"美白";
            v.face = [UIImage imageNamed:@"fwhite"];
            v;
        })];
        
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"浪漫";
            v.face = [UIImage imageNamed:@"langman"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"清新";
            v.face = [UIImage imageNamed:@"qingxin"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"唯美";
            v.face = [UIImage imageNamed:@"weimei"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"粉嫩";
            v.face = [UIImage imageNamed:@"fennen"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"怀旧";
            v.face = [UIImage imageNamed:@"huaijiu"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"蓝调";
            v.face = [UIImage imageNamed:@"landiao"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"清凉";
            v.face = [UIImage imageNamed:@"qingliang"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = @"日系";
            v.face = [UIImage imageNamed:@"rixi"];
            v;
        })];

        _videoRatio = VIDEO_ASPECT_RATIO_9_16;
        [TXUGCRecord shareInstance].recordDelegate = self;
        
        _bgmListVC = [[TCBGMListViewController alloc] init];
        [_bgmListVC setBGMControllerListener:self];
        _recordVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputRecord.mp4"];
        _joinVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputJoin.mp4"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    
    [[FUManager shareManager] destoryItems];
    
    [[TXUGCRecord shareInstance].partsManager deleteAllParts];
    [[TXUGCRecord shareInstance] stopCameraPreview];
    [TCUtil removeCacheFile:_videoPath];
    [TCUtil removeCacheFile:_recordVideoPath];
    [TCUtil removeCacheFile:_joinVideoPath];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self initBeautyUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAudioSessionEvent:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    
    [[TXUGCRecord shareInstance] setVideoProcessDelegate:self];
    
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
}

- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height {
    
    return [[FUManager shareManager] renderItemWithTexture:texture Width:width Height:height] ;
}


-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 200, self.view.frame.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
        _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;
        _demoBar.blurShape = [FUManager shareManager].blurShape ;
        _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
        _demoBar.whiteLevel = [FUManager shareManager].whiteLevel ;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        _demoBar.eyelightingLevel = [FUManager shareManager].eyelightingLevel ;
        _demoBar.beautyToothLevel = [FUManager shareManager].beautyToothLevel ;
        _demoBar.faceShape = [FUManager shareManager].faceShape ;
        
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}

/**      FUAPIDemoBarDelegate       **/

- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}

- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}












- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _navigationBarHidden = self.navigationController.navigationBar.hidden;
    _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    
    if (_cameraPreviewing == NO) {
        [self startCameraPreview];
    }else{
        [[TXUGCRecord shareInstance] resumeAudioSession];
        //停止特效的声音
        [[TXUGCRecord shareInstance] setMotionMute:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:_navigationBarHidden];
    [[UIApplication sharedApplication]setStatusBarHidden:_statusBarHidden];
}

-(void)onAudioSessionEvent:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        // 在10.3及以上的系统上，分享跳其它app后再回来会收到AVAudioSessionInterruptionWasSuspendedKey的通知，不处理这个事件。
        if ([info objectForKey:@"AVAudioSessionInterruptionWasSuspendedKey"]) {
            return;
        }
        _appForeground = NO;
        if (!_isPaused && _videoRecording)
            [self onBtnRecordStartClicked];
    }else{
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            _appForeground = YES;
        }
    }
}

- (void)onAppDidEnterBackGround:(UIApplication*)app
{
    _appForeground = NO;
    if (!_isPaused && _videoRecording)
        [self onBtnRecordStartClicked];

}

- (void)onAppWillEnterForeground:(UIApplication*)app
{
    _appForeground = YES;
}

-(void)onBtnPopClicked
{
    NSArray *videoPaths = [[TXUGCRecord shareInstance].partsManager getVideoPathList];
    if (videoPaths.count > 0) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"您确定要退出当前录制 ? 退出录制后，当前录制的片段会被删除" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[TXUGCRecord shareInstance].partsManager deleteAllParts];
                [self stopCameraPreview];
                if (_recordType == RecordType_Normal) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
        [alert show];
    }else{
        [self stopCameraPreview];
        [self stopVideoRecord];
        if (_recordType == RecordType_Normal) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        [[TXUGCRecord shareInstance] setZoom:MIN(MAX(1.0, _zoom * recognizer.scale),5.0)];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        _zoom = MIN(MAX(1.0, _zoom * recognizer.scale),5.0);
        recognizer.scale = 1;
    }
}

#pragma mark ---- Common UI ----
-(void)initUI
{
    self.title = @"";
    self.view.backgroundColor = UIColor.blackColor;
    
    _videoPlayView = [UIView new];
    _videoPlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_videoPlayView];
    
    _videoRecordView = [UIView new];
    _videoRecordView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_videoRecordView];
    
    if (_videoPath) {
        _videoRecordView.frame = CGRectMake(0, 0, self.view.width / 2, self.view.height);
        _videoPlayView.frame = CGRectMake(self.view.width / 2, 0, self.view.width / 2, self.view.height);
        
        TXVideoInfo *info = [TXVideoInfoReader getVideoInfo:_videoPath];
        CGFloat duration = info.duration;
        _fps = (int)(info.fps + 0.5);
        if (info.audioSampleRate == 8000) {
            _sampleRate = AUDIO_SAMPLERATE_8000;
        }else if (info.audioSampleRate == 16000){
            _sampleRate = AUDIO_SAMPLERATE_16000;
        }else if (info.audioSampleRate == 32000){
            _sampleRate = AUDIO_SAMPLERATE_32000;
        }else if (info.audioSampleRate == 44100){
            _sampleRate = AUDIO_SAMPLERATE_44100;
        }else if (info.audioSampleRate == 48000){
            _sampleRate = AUDIO_SAMPLERATE_48000;
        }
        _size = CGSizeMake(info.width, info.height);
        _recordType = RecordType_Chorus;
        MAX_RECORD_TIME = duration;
        MIN_RECORD_TIME = duration;
        
        TXPreviewParam *param = [TXPreviewParam new];
        param.videoView = _videoPlayView;
        param.renderMode = PREVIEW_RENDER_MODE_FILL_EDGE;
        //用于模仿视频播放
        _videoEditer = [[TXVideoEditer alloc] initWithPreview:param];
        [_videoEditer setVideoPath:_videoPath];
        //用于模仿视频和录制视频的合成
        _videoJoiner = [[TXVideoJoiner alloc] initWithPreview:nil];
        _videoJoiner.joinerDelegate = self;
    }else{
        _videoRecordView.frame = self.view.bounds;
        MAX_RECORD_TIME = 16;
        MIN_RECORD_TIME = 2;
        _recordType = RecordType_Normal;
    }
    
    UIPinchGestureRecognizer* pinchGensture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_videoRecordView addGestureRecognizer:pinchGensture];
    
    UIButton *btnPop = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPop.bounds = CGRectMake(0, 0, BUTTON_CONTROL_SIZE, BUTTON_CONTROL_SIZE);
    btnPop.center = CGPointMake(7 + BUTTON_CONTROL_SIZE / 2, 20 + BUTTON_CONTROL_SIZE / 2);
    [btnPop setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btnPop addTarget:self action:@selector(onBtnPopClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPop];
    
    CGFloat btnNextWidth = 70;
    CGFloat btnNextHeight = 30;
    _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnNext.bounds = CGRectMake(0, 0, btnNextWidth, btnNextHeight);
    _btnNext.center = CGPointMake(self.view.right - 15 - btnNextWidth / 2, 20 + btnNextHeight / 2);
    [_btnNext setTitle:@"下一步" forState:UIControlStateNormal];
    _btnNext.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnNext setBackgroundImage:[UIImage imageNamed:@"next_normal"] forState:UIControlStateNormal];
    [_btnNext setBackgroundImage:[UIImage imageNamed:@"next_press"] forState:UIControlStateHighlighted];
    [_btnNext addTarget:self action:@selector(onBtnDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    _btnNext.enabled = NO;
    [self.view addSubview:_btnNext];
    
    //BGM
    CGFloat btnMusicSize = 44;
    _btnMusic = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMusic.bounds = CGRectMake(0, 0, btnMusicSize, btnMusicSize);
    _btnMusic.center = CGPointMake(self.view.right - 9 - btnMusicSize / 2, _btnNext.bottom + 44 + btnMusicSize / 2);
    [_btnMusic setImage:[UIImage imageNamed:@"backMusic"] forState:UIControlStateNormal];
//    [_btnMusic setImage:[UIImage imageNamed:@"backMusic_hover"] forState:UIControlStateHighlighted];
    [_btnMusic addTarget:self action:@selector(onBtnMusicClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnMusic];
    
    UILabel *musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(_btnMusic.x, _btnMusic.bottom + 4, btnMusicSize, 14)];
    musicLabel.text = @"音乐";
    musicLabel.textColor = UIColorFromRGB(0xffffffff);
    musicLabel.font = [UIFont systemFontOfSize:10];
    musicLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:musicLabel];
    
    //
    _btnRatio169 = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRatio169.frame = CGRectOffset(_btnMusic.frame, 0, 44 + btnMusicSize);
    [_btnRatio169 setImage:[UIImage imageNamed:@"169"] forState:UIControlStateNormal];
    [_btnRatio169 setImage:[UIImage imageNamed:@"169_hover"] forState:UIControlStateHighlighted];
    [_btnRatio169 addTarget:self action:@selector(onBtnRatioClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnRatio169.tag = VIDEO_ASPECT_RATIO_9_16;
    _btnRatio169.hidden = NO;
    _btnRatio169.enabled = _recordType == RecordType_Normal;
    [self.view addSubview:_btnRatio169];
    _btnRatioFrame = _btnRatio169.frame;
    
    _labelRatio169 = [[UILabel alloc] initWithFrame:CGRectMake(_btnRatio169.x, _btnRatio169.bottom + 4, btnMusicSize, 14)];
    _labelRatio169.text = @"16:9";
    _labelRatio169.textColor = UIColorFromRGB(0xffffffff);
    _labelRatio169.font = [UIFont systemFontOfSize:10];
    _labelRatio169.textAlignment = NSTextAlignmentCenter;
    _labelRatio169.enabled = _recordType == RecordType_Normal;
    [self.view addSubview:_labelRatio169];
    
    _btnRatio11 = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRatio11.frame = CGRectOffset(_btnRatioFrame, -(30 + BUTTON_CONTROL_SIZE), 0);
    [_btnRatio11 setImage:[UIImage imageNamed:@"11"] forState:UIControlStateNormal];
    [_btnRatio11 setImage:[UIImage imageNamed:@"11_hover"] forState:UIControlStateHighlighted];
    [_btnRatio11 addTarget:self action:@selector(onBtnRatioClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnRatio11.tag = VIDEO_ASPECT_RATIO_1_1;
    _btnRatio11.hidden = YES;
    _btnRatio11.enabled = _recordType == RecordType_Normal;
    [self.view addSubview:_btnRatio11];
    
    _labelRatio11 = [[UILabel alloc] initWithFrame:CGRectMake(_btnRatio11.x, _btnRatio11.bottom + 4, btnMusicSize, 14)];
    _labelRatio11.text = @"1:1";
    _labelRatio11.textColor = UIColorFromRGB(0xffffffff);
    _labelRatio11.font = [UIFont systemFontOfSize:10];
    _labelRatio11.textAlignment = NSTextAlignmentCenter;
    _labelRatio11.hidden = YES;
    [self.view addSubview:_labelRatio11];
    
    _btnRatio43 = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRatio43.frame = CGRectOffset(_btnRatio11.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
    [_btnRatio43 setImage:[UIImage imageNamed:@"43"] forState:UIControlStateNormal];
    [_btnRatio43 setImage:[UIImage imageNamed:@"43_hover"] forState:UIControlStateHighlighted];
    [_btnRatio43 addTarget:self action:@selector(onBtnRatioClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnRatio43.tag = VIDEO_ASPECT_RATIO_3_4;
    _btnRatio43.hidden = YES;
    [self.view addSubview:_btnRatio43];
    
    _labelRatio43 = [[UILabel alloc] initWithFrame:CGRectMake(_btnRatio43.x, _btnRatio43.bottom + 4, btnMusicSize, 14)];
    _labelRatio43.text = @"4:3";
    _labelRatio43.textColor = UIColorFromRGB(0xffffffff);
    _labelRatio43.font = [UIFont systemFontOfSize:10];
    _labelRatio43.textAlignment = NSTextAlignmentCenter;
    _labelRatio43.hidden = YES;
    [self.view addSubview:_labelRatio43];
    
    _btnBeauty = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBeauty.frame = CGRectOffset(_btnRatio169.frame, 0, 44 + btnMusicSize);
    [_btnBeauty setImage:[UIImage imageNamed:@"beauty_record"] forState:UIControlStateNormal];
    [_btnBeauty setImage:[UIImage imageNamed:@"beauty_hover"] forState:UIControlStateHighlighted];
    [_btnBeauty addTarget:self action:@selector(onBtnBeautyClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnBeauty];
    
    UILabel *beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(_btnBeauty.x, _btnBeauty.bottom + 10, BUTTON_CONTROL_SIZE, 11)];
    beautyLabel.text = @"美颜";
    beautyLabel.textColor = UIColorFromRGB(0xffffffff);
    beautyLabel.font = [UIFont systemFontOfSize:12];
    beautyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:beautyLabel];
    
    _musicView = [[TCVideoRecordMusicView alloc] initWithFrame:CGRectMake(0, self.view.bottom - 330 * kScaleY, self.view.width, 330 * kScaleY) needEffect:YES];
    _musicView.delegate = self;
    _musicView.hidden = YES;
    [self.view addSubview:_musicView];
    
    _mask_buttom = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - BUTTON_MASK_HEIGHT, self.view.frame.size.width, BUTTON_MASK_HEIGHT)];
    [_mask_buttom setBackgroundColor:UIColorFromRGB(0x000000)];
    [_mask_buttom setAlpha:0.3];
    [self.view addSubview:_mask_buttom];
    
    CGFloat recordBtnSize = 82;
    _btnStartRecord = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, recordBtnSize, recordBtnSize)];
    _btnStartRecord.center = CGPointMake(self.view.frame.size.width / 2, self.view.height - recordBtnSize / 2 - 20);
    [_btnStartRecord setImage:[UIImage imageNamed:@"start_record"] forState:UIControlStateNormal];
    [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"start_ring"] forState:UIControlStateNormal];
    [_btnStartRecord addTarget:self action:@selector(onBtnStartRecord) forControlEvents:UIControlEventTouchDown];
    [_btnStartRecord addTarget:self action:@selector(onBtnStopRecord) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.view addSubview:_btnStartRecord];
    
    CGFloat btnStartSpace = (_btnStartRecord.left - BUTTON_CONTROL_SIZE * 2) / 3.0;
    _btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnFlash.bounds = CGRectMake(0, 0, BUTTON_CONTROL_SIZE, BUTTON_CONTROL_SIZE);
    _btnFlash.center = CGPointMake(btnStartSpace + BUTTON_CONTROL_SIZE / 2, _btnStartRecord.center.y);
    if (_cameraFront) {
        [_btnFlash setImage:[UIImage imageNamed:@"openFlash_disable"] forState:UIControlStateNormal];
        _btnFlash.enabled = NO;
    }else{
        [_btnFlash setImage:[UIImage imageNamed:@"closeFlash"] forState:UIControlStateNormal];
        [_btnFlash setImage:[UIImage imageNamed:@"closeFlash_hover"] forState:UIControlStateHighlighted];
        _btnFlash.enabled = YES;
    }
    [_btnFlash addTarget:self action:@selector(onBtnFlashClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnFlash];
    
    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCamera.bounds = CGRectMake(0, 0, BUTTON_CONTROL_SIZE, BUTTON_CONTROL_SIZE);
    _btnCamera.center = CGPointMake(_btnFlash.right + btnStartSpace + BUTTON_CONTROL_SIZE / 2, _btnStartRecord.center.y);
    [_btnCamera setImage:[UIImage imageNamed:@"camera_record"] forState:UIControlStateNormal];
    [_btnCamera setImage:[UIImage imageNamed:@"camera_hover"] forState:UIControlStateHighlighted];
    [_btnCamera addTarget:self action:@selector(onBtnCameraClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCamera];
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDelete.bounds = CGRectMake(0, 0, BUTTON_CONTROL_SIZE, BUTTON_CONTROL_SIZE);
    _btnDelete.center = CGPointMake(_btnStartRecord.right + (self.view.width - _btnStartRecord.right) / 2, _btnStartRecord.center.y);
    [_btnDelete setImage:[UIImage imageNamed:@"backDelete"] forState:UIControlStateNormal];
    [_btnDelete setImage:[UIImage imageNamed:@"backDelete_hover"] forState:UIControlStateHighlighted];
    [_btnDelete addTarget:self action:@selector(onBtnDeleteClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDelete];
    
    _progressView = [[TCVideoRecordProcessView alloc] initWithFrame:CGRectMake(0,_mask_buttom.y - BUTTON_PROGRESS_HEIGHT + 0.5, self.view.frame.size.width, BUTTON_PROGRESS_HEIGHT)];
    _progressView.backgroundColor = [UIColor blackColor];
    _progressView.alpha = 0.4;
    [self.view addSubview:_progressView];
    
    _recordTimeLabel = [[UILabel alloc]init];
    _recordTimeLabel.frame = CGRectMake(0, 0, 100, 100);
    [_recordTimeLabel setText:@"00:00"];
    _recordTimeLabel.font = [UIFont systemFontOfSize:10];
    _recordTimeLabel.textColor = [UIColor whiteColor];
    _recordTimeLabel.textAlignment = NSTextAlignmentLeft;
    [_recordTimeLabel sizeToFit];
    _recordTimeLabel.center = CGPointMake(CGRectGetMaxX(_progressView.frame) - _recordTimeLabel.frame.size.width / 2, _progressView.frame.origin.y - _recordTimeLabel.frame.size.height);
    [self.view addSubview:_recordTimeLabel];
    
    [self createSpeedView];
    
    switch (_videoRatio) {
        case VIDEO_ASPECT_RATIO_3_4:
            [self onBtnRatioClicked:_btnRatio43];
            break;
        case VIDEO_ASPECT_RATIO_1_1:
            [self onBtnRatioClicked:_btnRatio11];
            break;
        case VIDEO_ASPECT_RATIO_9_16:
            [self onBtnRatioClicked:_btnRatio169];
            break;
            
        default:
            break;
    }
}

#pragma mark ---- Video Beauty UI ----
-(void)initBeautyUI
{
    NSUInteger controlHeight = [BeautySettingPanel getHeight];
    CGFloat offset = 0;
    if (@available(iOS 11, *)) {
        offset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    _vBeauty = [[BeautySettingPanel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - controlHeight - offset, self.view.frame.size.width, controlHeight)];
    _vBeauty.hidden = YES;
    _vBeauty.delegate = self;
    _vBeauty.pituDelegate = self;
    [self.view addSubview:_vBeauty];
}

//加速录制
-(void)createSpeedView
{
    _speedBtnList = [NSMutableArray array];
    CGFloat viewWidth = self.view.frame.size.width;
    _speedView = [[UIView alloc] init];
    _speedView.bounds = CGRectMake(0, 0, viewWidth - 30 * kScaleX * 2, BUTTON_SPEED_HEIGHT * kScaleY);
    _speedView.center = CGPointMake(viewWidth / 2, self.view.frame.size.height - 140);
    _speedView.layer.cornerRadius = BUTTON_SPEED_HEIGHT / 2;
    _speedView.layer.masksToBounds = YES;
    _speedView.backgroundColor = [UIColor blackColor];
    _speedView.alpha = 0.5;
    
    _speedChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat btnSpace = 30;
    CGFloat btnWidth = (_speedView.width - 16 * 2 * kScaleX - btnSpace * 4 * kScaleX) / 5;
    for(int i = 0 ; i < BUTTON_SPEED_COUNT ; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(16 * kScaleX + (btnSpace * kScaleX + btnWidth) * i, 0, btnWidth, _speedView.height);
        [btn setTitle:[self getSpeedText:(SpeedMode)i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15 * kScaleX]];
        [btn addTarget:self action:@selector(onBtnSpeedClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [_speedView addSubview:btn];
        [_speedBtnList addObject:btn];
        
        if(i == 2){
            CGRect rect = [_speedView convertRect:btn.frame toView:self.view];
            _speedChangeBtn.frame = CGRectMake(rect.origin.x - (BUTTON_SPEED_CHANGE_WIDTH - rect.size.width) / 2, rect.origin.y - (BUTTON_SPEED_CHANGE_HEIGHT - rect.size.height) / 2, BUTTON_SPEED_CHANGE_WIDTH, BUTTON_SPEED_CHANGE_HEIGHT);
            [_speedChangeBtn setTitle:[self getSpeedText:(SpeedMode)i] forState:UIControlStateNormal];
            [_speedChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_speedChangeBtn setBackgroundImage:[UIImage imageNamed:@"speedChange_center"] forState:UIControlStateNormal];
        }else{
            //合唱暂不支持变速录制
            if (_recordType == RecordType_Chorus) {
                btn.hidden = YES;
            }
        }
    }
    [self.view addSubview:_speedView];
    [self.view addSubview:_speedChangeBtn];
    _speedBtnSelectTag = 2;
}

-(void)setSpeedBtnHidden:(BOOL)hidden{
    _speedView.hidden = hidden;
    _speedChangeBtn.hidden = hidden;
}

-(NSString *)getSpeedText:(SpeedMode)speedMode
{
    NSString *text = nil;
    switch (speedMode) {
        case SpeedMode_VerySlow:
            text = @"极慢";
            break;
        case SpeedMode_Slow:
            text = @"慢";
            break;
        case SpeedMode_Standard:
            text = @"标准";
            break;
        case SpeedMode_Quick:
            text = @"快";
            break;
        case SpeedMode_VeryQuick:
            text = @"极快";
            break;
        default:
            break;
    }
    return text;
}

-(void)onBtnRatioClicked:(UIButton *)btn
{
    switch (btn.tag) {
        case VIDEO_ASPECT_RATIO_9_16:
        {
            if (btn.right + 9 == self.view.frame.size.width && [self ratioIsClosure]) {
                _btnRatio11.frame = CGRectOffset(btn.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
                _btnRatio43.frame = CGRectOffset(_btnRatio11.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
                _btnRatio11.hidden = NO;
                _btnRatio43.hidden = NO;
                _labelRatio11.hidden = NO;
                _labelRatio43.hidden = NO;
            }else{
                btn.frame = _btnRatioFrame;
                _btnRatio11.frame = _btnRatioFrame;
                _btnRatio43.frame = _btnRatioFrame;
                _btnRatio11.hidden = YES;
                _btnRatio43.hidden = YES;
                _labelRatio11.hidden = YES;
                _labelRatio43.hidden = YES;
            }
            [self setAspectRatio:VIDEO_ASPECT_RATIO_9_16];
        }
            break;
        case VIDEO_ASPECT_RATIO_1_1:
        {
            if (btn.right + 9 == self.view.frame.size.width && [self ratioIsClosure]) {
                _btnRatio43.frame = CGRectOffset(btn.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
                _btnRatio169.frame = CGRectOffset(_btnRatio43.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
                _btnRatio43.hidden = NO;
                _btnRatio169.hidden = NO;
                _labelRatio43.hidden = NO;
                _labelRatio169.hidden = NO;
            }else{
                btn.frame = _btnRatioFrame;
                _btnRatio43.frame = _btnRatioFrame;
                _btnRatio169.frame = _btnRatioFrame;
                _btnRatio43.hidden = YES;
                _btnRatio169.hidden = YES;
                _labelRatio43.hidden = YES;
                _labelRatio169.hidden = YES;
            }
            [self setAspectRatio:VIDEO_ASPECT_RATIO_1_1];
        }
            
            break;
        case VIDEO_ASPECT_RATIO_3_4:
        {
            if (btn.right + 9 == self.view.frame.size.width && [self ratioIsClosure]) {
                _btnRatio169.frame = CGRectOffset(btn.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
                _btnRatio11.frame = CGRectOffset(_btnRatio169.frame, -(30 + BUTTON_CONTROL_SIZE), 0);
                _btnRatio169.hidden = NO;
                _btnRatio11.hidden = NO;
                _labelRatio169.hidden = NO;
                _labelRatio11.hidden = NO;
            }else{
                btn.frame = _btnRatioFrame;
                _btnRatio169.frame = _btnRatioFrame;
                _btnRatio11.frame = _btnRatioFrame;
                _btnRatio169.hidden = YES;
                _btnRatio11.hidden = YES;
                _labelRatio169.hidden = YES;
                _labelRatio11.hidden = YES;
            }
            [self setAspectRatio:VIDEO_ASPECT_RATIO_3_4];
        }
            
            break;
        default:
            break;
    }
    btn.hidden = NO;
}

- (void)setAspectRatio:(NSInteger)aspectRatio
{
    _aspectRatio = aspectRatio;
    [[TXUGCRecord shareInstance] setAspectRatio:_aspectRatio];
    CGFloat height = 0;
    switch (_aspectRatio) {
        case VIDEO_ASPECT_RATIO_9_16:
            height = _videoRecordView.frame.size.width * 16 / 9;
            break;
        case VIDEO_ASPECT_RATIO_3_4:
            height = _videoRecordView.frame.size.width * 4 / 3;
            break;
        case VIDEO_ASPECT_RATIO_1_1:
            height = _videoRecordView.frame.size.width * 1 / 1;
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _videoRecordView.frame = CGRectMake(0, (self.view.height - height) / 2.0, _videoRecordView.frame.size.width, height);;
    }];
    _labelRatio11.frame = CGRectMake(_btnRatio11.x, _btnRatio11.bottom + 4, 44, 14);
    _labelRatio43.frame = CGRectMake(_btnRatio43.x, _btnRatio43.bottom + 4, 44, 14);
    _labelRatio169.frame = CGRectMake(_btnRatio169.x, _btnRatio169.bottom + 4, 44, 14);
}

-(BOOL)ratioIsClosure
{
    if (CGRectEqualToRect(_btnRatio43.frame, _btnRatio11.frame)) {
        return YES;
    }
    return NO;
}

- (void)onBtnMusicClicked
{
    _vBeauty.hidden = YES;
    if (_BGMPath) {
        _musicView.hidden = !_musicView.hidden;
        [self hideBottomView:!_musicView.hidden];
    }else{
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:_bgmListVC];
        [nv.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        nv.navigationBar.barTintColor = RGB(25, 29, 38);
        [self presentViewController:nv animated:YES completion:nil];
        [_bgmListVC loadBGMList];
    }
}

-(void)onBtnSpeedClicked:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^{
        _speedBtnSelectTag = btn.tag;
        if (_speedBtnSelectTag == 0) {
            [_speedChangeBtn setBackgroundImage:[UIImage imageNamed:@"speedChange_left"] forState:UIControlStateNormal];
        }else if (_speedBtnSelectTag == 4){
            [_speedChangeBtn setBackgroundImage:[UIImage imageNamed:@"speedChange_right"] forState:UIControlStateNormal];
        }else{
            [_speedChangeBtn setBackgroundImage:[UIImage imageNamed:@"speedChange_center"] forState:UIControlStateNormal];
        }
        CGRect rect = [_speedView convertRect:btn.frame toView:self.view];
        _speedChangeBtn.frame = CGRectMake(rect.origin.x - (BUTTON_SPEED_CHANGE_WIDTH - rect.size.width) / 2, rect.origin.y - (BUTTON_SPEED_CHANGE_HEIGHT - rect.size.height) / 2, BUTTON_SPEED_CHANGE_WIDTH, BUTTON_SPEED_CHANGE_HEIGHT);
        [_speedChangeBtn setTitle:[self getSpeedText:(SpeedMode)_speedBtnSelectTag] forState:UIControlStateNormal];
        [_speedChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }];
}

-(void)setSpeedRate{
    switch ((SpeedMode)_speedBtnSelectTag) {
            case SpeedMode_VerySlow:
            [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_SLOWEST];
            break;
            case SpeedMode_Slow:
            [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_SLOW];
            break;
            case SpeedMode_Standard:
            [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_NOMAL];
            break;
            case SpeedMode_Quick:
            [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_FAST];
            break;
            case SpeedMode_VeryQuick:
            [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_FASTEST];
            break;
        default:
            break;
    }
}

-(void)onBtnFlashClicked
{
    if (_isFlash) {
        [_btnFlash setImage:[UIImage imageNamed:@"closeFlash"] forState:UIControlStateNormal];
        [_btnFlash setImage:[UIImage imageNamed:@"closeFlash_hover"] forState:UIControlStateHighlighted];
    }else{
        [_btnFlash setImage:[UIImage imageNamed:@"openFlash"] forState:UIControlStateNormal];
        [_btnFlash setImage:[UIImage imageNamed:@"openFlash_hover"] forState:UIControlStateHighlighted];
    }
    _isFlash = !_isFlash;
    [[TXUGCRecord shareInstance] toggleTorch:_isFlash];
}

-(void)onBtnDeleteClicked
{
    if (_videoRecording && !_isPaused) {
        [self onBtnRecordStartClicked];
    }
    if (0 == _deleteCount) {
        [_progressView prepareDeletePart];
    }else{
        [_progressView comfirmDeletePart];
        [[TXUGCRecord shareInstance].partsManager deleteLastPart];
        _isBackDelete = YES;
    }
    if (2 == ++ _deleteCount) {
        _deleteCount = 0;
    }
}

-(void)onBtnStartRecord
{
    [self onBtnRecordStartClicked];
}

-(void)onBtnStopRecord
{
    [self onBtnRecordStartClicked];
}

-(void)onBtnRecordStartClicked
{
    if (!_videoRecording)
    {
        [self startVideoRecord];
    }
    else
    {
        if (_isPaused) {
            [self setSpeedRate];
            
            if (_bgmRecording) {
                [self resumeBGM];
            }else{
                [self playBGM:_bgmBeginTime];
                _bgmRecording = YES;
            }
            [[TXUGCRecord shareInstance] resumeRecord];
            
            [_btnStartRecord setImage:[UIImage imageNamed:@"pause_record"] forState:UIControlStateNormal];
            [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"pause_ring"] forState:UIControlStateNormal];
            _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE * 0.85, BUTTON_RECORD_SIZE * 0.85);
            
            if (_deleteCount == 1) {
                [_progressView cancelDelete];
                _deleteCount = 0;
            }
            [self setSpeedBtnHidden:YES];
            
            _isPaused = NO;
            
            [_videoEditer startPlayFromTime:_recordTime toTime:MAX_RECORD_TIME];
        }
        else {
            [[TXUGCRecord shareInstance] pauseRecord];
            [self pauseBGM];
            
            [_btnStartRecord setImage:[UIImage imageNamed:@"start_record"] forState:UIControlStateNormal];
            [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"start_ring"] forState:UIControlStateNormal];
            _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE, BUTTON_RECORD_SIZE);
            
            [_progressView pause];
            [self setSpeedBtnHidden:NO];
            
            _isPaused = YES;
            
            [_videoEditer stopPlay];
        }
    }
}

- (void)onBtnDoneClicked
{
    if (!_videoRecording)
        return;
    
    [self stopVideoRecord];
}

-(void)startCameraPreview
{
    if (_cameraPreviewing == NO)
    {
        //简单设置
        //        TXUGCSimpleConfig * param = [[TXUGCSimpleConfig alloc] init];
        //        param.videoQuality = VIDEO_QUALITY_MEDIUM;
        //        [[TXUGCRecord shareInstance] startCameraSimple:param preview:_videoRecordView];
        //自定义设置
        TXUGCCustomConfig * param = [[TXUGCCustomConfig alloc] init];
        param.videoResolution =  VIDEO_RESOLUTION_720_1280;
        param.videoFPS = _fps > 0 ? _fps : 30;
        param.videoBitratePIN = 9600;
        param.GOP = 3;
        param.audioSampleRate = _sampleRate;
        param.minDuration = MIN_RECORD_TIME;
        param.maxDuration = MAX_RECORD_TIME;
        [[TXUGCRecord shareInstance] startCameraCustom:param preview:_videoRecordView];
        [[TXUGCRecord shareInstance] setBeautyStyle:0 beautyLevel:_beautyDepth whitenessLevel:_whitenDepth ruddinessLevel:0];
        [[TXUGCRecord shareInstance] setVideoRenderMode:VIDEO_RENDER_MODE_ADJUST_RESOLUTION];
        if (_greenIndex >=0 || _greenIndex < _greenArray.count) {
            V8LabelNode *v = [_greenArray objectAtIndex:_greenIndex];
            [[TXUGCRecord shareInstance] setGreenScreenFile:v.file];
        }
        
        [[TXUGCRecord shareInstance] setEyeScaleLevel:_eye_level];
        [[TXUGCRecord shareInstance] setFaceScaleLevel:_face_level];
      
        UIImage *watermark = [UIImage imageNamed:@"watermark.png"];
        CGRect watermarkFrame = (CGRect){0.01, 0.01, 0.3 , 0};
        [[TXUGCRecord shareInstance] setWaterMark:watermark normalizationFrame:watermarkFrame];
        
#if POD_PITU
        [self motionTmplSelected:_materialID];
#endif
        
        [_vBeauty resetValues];
        _cameraPreviewing = YES;
    }
}

-(void)stopCameraPreview
{
    if (_cameraPreviewing == YES)
    {
        [[TXUGCRecord shareInstance] stopCameraPreview];
        _cameraPreviewing = NO;
    }
}

-(void)startVideoRecord
{
    [self refreshRecordTime:0];
    [self startCameraPreview];
    [self setSpeedRate];
    int result = [[TXUGCRecord shareInstance] startRecord];
    [TCUtil report:xiaoshipin_startrecord userName:nil code:result msg:result == 0 ? @"启动录制成功" : @"启动录制失败"];
    if(0 != result)
    {
        if(-3 == result) [self alert:@"启动录制失败" msg:@"请检查摄像头权限是否打开"];
        if(-4 == result) [self alert:@"启动录制失败" msg:@"请检查麦克风权限是否打开"];
        if(-5 == result) [self alert:@"启动录制失败" msg:@"licence 验证失败"];
    }else{
        //如果设置了BGM，播放BGM
        [self playBGM:_bgmBeginTime];
        
        //初始化录制状态
        _bgmRecording = YES;
        _videoRecording = YES;
        _isPaused = NO;
        
        //录制过程中不能切换分辨率
        _btnRatio169.enabled = NO;
        _btnRatio43.enabled = NO;
        _btnRatio11.enabled = NO;
        
        [self setSpeedBtnHidden:YES];
        [_btnStartRecord setImage:[UIImage imageNamed:@"pause_record"] forState:UIControlStateNormal];
        [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"pause_ring"] forState:UIControlStateNormal];
        _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE * 0.85, BUTTON_RECORD_SIZE * 0.85);
        
        if (_recordType == RecordType_Chorus) {
            [_videoEditer startPlayFromTime:_recordTime toTime:MAX_RECORD_TIME];
        }
    }
}

-(void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)stopVideoRecord
{
    [_btnStartRecord setImage:[UIImage imageNamed:@"start_record"] forState:UIControlStateNormal];
    [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"start_ring"] forState:UIControlStateNormal];
    _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE, BUTTON_RECORD_SIZE);
    [self setSpeedBtnHidden:NO];

    //调用partsManager快速合成视频，不破坏录制状态，下次返回后可以接着录制（注意需要先暂停视频录制）
    if ([TXUGCRecord shareInstance].partsManager.getVideoPathList.count > 0) {
        int result = [[TXUGCRecord shareInstance].partsManager joinAllParts:_recordVideoPath];
        if(0 == result){
            if (_recordType == RecordType_Normal) {
                TCVideoEditViewController *vc = [[TCVideoEditViewController alloc] init];
                vc.videoPath = _recordVideoPath;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                CGFloat width = 720;
                CGFloat height = 1280;
                CGRect recordScreen = CGRectMake(0, 0, width, height);
                //播放视频所占画布的大小这里要计算下，防止视频拉伸
                CGRect playScreen = CGRectZero;
                if (_size.height / _size.width >= height / width) {
                    CGFloat playScreen_w = height * _size.width / _size.height;
                    playScreen = CGRectMake(width + (width - playScreen_w) / 2.0, 0, playScreen_w, height);
                }else{
                    CGFloat playScreen_h = width * _size.height / _size.width;
                    playScreen = CGRectMake(width, (height - playScreen_h) / 2.0, width, playScreen_h);
                }
                if (_recordVideoPath && _videoPath && [[NSFileManager defaultManager] fileExistsAtPath:_recordVideoPath] && [[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
                    [_videoJoiner setVideoPathList:@[_recordVideoPath,_videoPath]];
                    [_videoJoiner setSplitScreenList:@[[NSValue valueWithCGRect:recordScreen],[NSValue valueWithCGRect:playScreen]] canvasWidth:720 * 2 canvasHeight:1280];
                    [_videoJoiner splitJoinVideo:VIDEO_COMPRESSED_720P videoOutputPath:_joinVideoPath];
                    
                    _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    _hub.mode = MBProgressHUDModeText;
                    _hub.label.text = @"视频合成中...";
                }else{
                    [self alert:@"视频合成失败" msg:@"请重新录制合成"];
                }
            }
            [[TXUGCRecord shareInstance] pauseAudioSession];
            [[TXUGCRecord shareInstance] setMotionMute:YES];
            [TCUtil report:xiaoshipin_videorecord userName:nil code:0 msg:@"视频录制成功"];
        }else{
            [TCUtil report:xiaoshipin_videorecord userName:nil code:-1 msg:@"视频录制失败"];
        }
    }
}

-(void)resetVideoUI
{
    [_progressView deleteAllPart];
    [_btnStartRecord setImage:[UIImage imageNamed:@"start_record"] forState:UIControlStateNormal];
    [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"start_ring"] forState:UIControlStateNormal];
    _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE, BUTTON_RECORD_SIZE);
    
    [self resetSpeedBtn];
    [_musicView resetVolume];
    
    //合唱逻辑UI暂不适配
    if (_recordType == RecordType_Normal) {
        _btnRatio169.enabled = YES;
        _btnRatio43.enabled = YES;
        _btnRatio11.enabled = YES;
        _btnMusic.enabled = YES;
    }
    _btnNext.enabled = NO;
    _isPaused = NO;
    _videoRecording = NO;
}

-(void)resetSpeedBtn{
    [self setSpeedBtnHidden:NO];
    for(UIButton *btn in _speedBtnList){
        if (btn.tag == 2) {
            [self onBtnSpeedClicked:btn];
        }
    }
}

-(void)onBtnCameraClicked
{
    _cameraFront = !_cameraFront;
    [[TXUGCRecord shareInstance] switchCamera:_cameraFront];
    if (_cameraFront) {
        [_btnFlash setImage:[UIImage imageNamed:@"openFlash_disable"] forState:UIControlStateNormal];
        _btnFlash.enabled = NO;
    }else{
        if (_isFlash) {
            [_btnFlash setImage:[UIImage imageNamed:@"openFlash"] forState:UIControlStateNormal];
            [_btnFlash setImage:[UIImage imageNamed:@"openFlash_hover"] forState:UIControlStateHighlighted];
        }else{
            [_btnFlash setImage:[UIImage imageNamed:@"closeFlash"] forState:UIControlStateNormal];
            [_btnFlash setImage:[UIImage imageNamed:@"closeFlash_hover"] forState:UIControlStateHighlighted];
        }
        _btnFlash.enabled = YES;
    }
    [[TXUGCRecord shareInstance] toggleTorch:_isFlash];
}

-(void)onBtnLampClicked
{
    _lampOpened = !_lampOpened;
    
    BOOL result = [[TXUGCRecord shareInstance] toggleTorch:_lampOpened];
    if (result == NO)
    {
        _lampOpened = !_lampOpened;
        [self toastTip:@"闪光灯启动失败"];
    }
    
    if (_lampOpened)
    {
        [_btnLamp setImage:[UIImage imageNamed:@"lamp_press"] forState:UIControlStateNormal];
    }else
    {
        [_btnLamp setImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
    }
}

-(void)onBtnBeautyClicked
{
    _vBeautyShow = !_vBeautyShow;
    _musicView.hidden = YES;
    _vBeauty.hidden = !_vBeautyShow;
    [self hideBottomView:_vBeautyShow];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_vBeautyShow)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint _touchPoint = [touch locationInView:self.view];
        if (NO == CGRectContainsPoint(_vBeauty.frame, _touchPoint))
        {
            [self onBtnBeautyClicked];
        }
    }
    if (!_musicView.hidden) {
//        [self onBtnMusicClicked];
//        if([touches anyObject].view != _musicView){
//            _musicView.hidden = !_musicView.hidden;
//            [self hideBottomView:!_musicView.hidden];
//        }
        CGPoint _touchPoint = [[[event allTouches] anyObject] locationInView:self.view];
        if (NO == CGRectContainsPoint(_musicView.frame, _touchPoint)){
            _musicView.hidden = !_musicView.hidden;
            [self hideBottomView:!_musicView.hidden];
        }
    }
}

- (void)hideBottomView:(BOOL)bHide
{
    _speedView.hidden = bHide;
    _speedChangeBtn.hidden = bHide;
    _btnFlash.hidden = bHide;
    _btnCamera.hidden = bHide;
    _btnStartRecord.hidden = bHide;
    _btnDelete.hidden = bHide;
    _progressView.hidden = bHide;
    _recordTimeLabel.hidden = bHide;
    _mask_buttom.hidden = bHide;
}

-(void)selectBeautyPage:(UIButton *)button
{
    switch (button.tag)
    {
        case 0:
            _beautyPage.hidden = NO;
            _beautyBtn.selected = YES;
            
            _filterPage.hidden = YES;
            _filterBtn.selected = NO;
            
            _motionBtn.selected = NO;
            _greenBtn.selected  = NO;
            _tmplBar.hidden = YES;
            _greenPickerView.hidden = YES;
            
            break;
            
        case 1:
            _beautyPage.hidden = YES;
            _beautyBtn.selected = NO;
            
            _filterPage.hidden = NO;
            _filterBtn.selected = YES;
            
            [_filterPickerView scrollToElement:_filterIndex animated:NO];
            
            _motionBtn.selected = NO;
            _greenBtn.selected  = NO;
            _tmplBar.hidden = YES;
            _greenPickerView.hidden = YES;
            break;
            
        case 2: {
            _beautyPage.hidden = YES;
            _beautyBtn.selected = NO;
            
            _filterPage.hidden = YES;
            _filterBtn.selected = NO;
            
            _motionBtn.selected = YES;
            _greenBtn.selected  = NO;
            _tmplBar.hidden = NO;
            _greenPickerView.hidden = YES;
        }
            break;
        case 3: {
            _beautyPage.hidden = YES;
            _beautyBtn.selected = NO;
            
            _filterPage.hidden = YES;
            _filterBtn.selected = NO;
            
            _motionBtn.selected = NO;
            _greenBtn.selected  = YES;
            _tmplBar.hidden = YES;
            _greenPickerView.hidden = NO;
            [_greenPickerView scrollToElement:_greenIndex animated:NO];
        }
    }
}

-(void)sliderValueChange:(UISlider*)obj
{
    int tag = (int)obj.tag;
    float value = obj.value;
    
    switch (tag) {
        case 0:
            _beautyDepth = value;
            [[TXUGCRecord shareInstance] setBeautyStyle:0 beautyLevel:_beautyDepth whitenessLevel:_whitenDepth ruddinessLevel:0];
            break;
            
        case 1:
            _whitenDepth = value;
            [[TXUGCRecord shareInstance] setBeautyStyle:0 beautyLevel:_beautyDepth whitenessLevel:_whitenDepth ruddinessLevel:0];
            break;
        case 2: //大眼
            _eye_level = value;
            [[TXUGCRecord shareInstance] setEyeScaleLevel:_eye_level];
            break;
         case 3:  //瘦脸
            _face_level = value;
            [[TXUGCRecord shareInstance] setFaceScaleLevel:_face_level];
            break;
        default:
            break;
    }
}

-(void)refreshRecordTime:(CGFloat)second
{
    _currentRecordTime = second;
    [_progressView update:_currentRecordTime / MAX_RECORD_TIME];
    long min = (int)_currentRecordTime / 60;
    long sec = (int)_currentRecordTime % 60;
    
    [_recordTimeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld", min, sec]];
    [_recordTimeLabel sizeToFit];
}

#pragma mark TXUGCRecordListener
-(void) onRecordProgress:(NSInteger)milliSecond;
{
    _recordTime =  milliSecond / 1000.0;
    [self refreshRecordTime: _recordTime];
    
    //录制过程中不能切换BGM
    _btnMusic.enabled = (milliSecond == 0);
    _btnNext.enabled = milliSecond / 1000.0 >= MIN_RECORD_TIME;
    
    //回删之后被模仿视频进度回退
    if (_isBackDelete && _recordType == RecordType_Chorus) {
        [_videoEditer previewAtTime:_recordTime];
        _isBackDelete = NO;
    }
}

-(void) onRecordComplete:(TXUGCRecordResult*)result;
{
    if (_appForeground)
    {
        if (_currentRecordTime >= MIN_RECORD_TIME)
        {
            if (result.retCode != UGC_RECORD_RESULT_FAILED) {
                [self stopVideoRecord];
            }else{
                [self toastTip:@"录制失败"];
            }
        } else {
            [self toastTip:@"至少要录够5秒"];
        }
    }
}

#pragma mark TXVideoJoinerListener
-(void) onJoinProgress:(float)progress
{
    _hub.label.text = [NSString stringWithFormat:@"视频合成中%d%%",(int)(progress * 100)];
}
-(void) onJoinComplete:(TXJoinerResult *)result
{
    [_hub hideAnimated:YES];
    if (_appForeground && result.retCode == RECORD_RESULT_OK) {
        TCVideoEditViewController *vc = [[TCVideoEditViewController alloc] init];
        vc.videoPath = _joinVideoPath;
        vc.isFromChorus = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
        [[TXUGCRecord shareInstance] pauseAudioSession];
    }
    [TCUtil report:xiaoshipin_videojoiner userName:nil code:result.retCode msg:result.descMsg];
}

#if POD_PITU
- (void)motionTmplSelected:(NSString *)materialID {
    if (materialID == nil) {
        [MCTip hideText];
    }
    _materialID = materialID;
    if ([MaterialManager isOnlinePackage:materialID]) {
        [[TXUGCRecord shareInstance] selectMotionTmpl:materialID inDir:[MaterialManager packageDownloadDir]];
    } else {
        NSString *localPackageDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resource"];
        [[TXUGCRecord shareInstance] selectMotionTmpl:materialID inDir:localPackageDir];
    }
}
#endif
#pragma mark - HorizontalPickerView DataSource
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    if (picker == _greenPickerView) {
        return [_greenArray count];
    } else if(picker == _filterPickerView) {
        return [_filterArray count];
    }
    return 0;
}

#pragma mark - BeautyLoadPituDelegate
- (void)onLoadPituStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hub.mode = MBProgressHUDModeText;
        _hub.label.text = @"开始加载资源";
    });
}
- (void)onLoadPituProgress:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = [NSString stringWithFormat:@"正在加载资源%d %%",(int)(progress * 100)];
    });
}
- (void)onLoadPituFinished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = @"资源加载成功";
        [_hub hideAnimated:YES afterDelay:1];
    });
}
- (void)onLoadPituFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = @"资源加载失败";
        [_hub hideAnimated:YES afterDelay:1];
    });
}

#pragma mark - BeautySettingPanelDelegate
- (void)onSetBeautyStyle:(TXVideoBeautyStyle)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel{
    [[TXUGCRecord shareInstance] setBeautyStyle:beautyStyle beautyLevel:beautyLevel whitenessLevel:whitenessLevel ruddinessLevel:ruddinessLevel];
}

- (void)onSetEyeScaleLevel:(float)eyeScaleLevel
{
    [[TXUGCRecord shareInstance] setEyeScaleLevel:eyeScaleLevel];
}

- (void)onSetFaceScaleLevel:(float)faceScaleLevel
{
    [[TXUGCRecord shareInstance] setFaceScaleLevel:faceScaleLevel];
}

- (void)onSetFilter:(UIImage*)filterImage
{
    [[TXUGCRecord shareInstance] setFilter:filterImage];
}

- (void)onSetGreenScreenFile:(NSURL *)file
{
    [[TXUGCRecord shareInstance] setGreenScreenFile:file];
}

- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir
{
    [[TXUGCRecord shareInstance] selectMotionTmpl:tmplName inDir:tmplDir];
}

- (void)onSetFaceVLevel:(float)faceVLevel{
    [[TXUGCRecord shareInstance] setFaceVLevel:faceVLevel];
}

- (void)onSetChinLevel:(float)chinLevel{
    [[TXUGCRecord shareInstance] setChinLevel:chinLevel];
}

- (void)onSetNoseSlimLevel:(float)slimLevel{
    [[TXUGCRecord shareInstance] setNoseSlimLevel:slimLevel];
}

- (void)onSetFaceShortLevel:(float)faceShortlevel{
    [[TXUGCRecord shareInstance] setFaceShortLevel:faceShortlevel];
}

- (void)onSetMixLevel:(float)mixLevel{
    [[TXUGCRecord shareInstance] setSpecialRatio:mixLevel / 10.0];
}

- (void)onSetFaceBeautyLevel:(float)beautyLevel {
    // None
}


#pragma mark TCBGMControllerListener
-(void) onBGMControllerPlay:(NSObject*) path{
    if(path == nil) return;
    [self onSetBGM:path];
    //试听音乐这里要把RecordSpeed 设置为VIDEO_RECORD_SPEED_NOMAL，否则音乐可能会出现加速或则慢速播现象
    [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_NOMAL];
    [self playBGM:0];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [_musicView resetCutView];
        if(_musicView.hidden){
            _musicView.hidden = !_musicView.hidden;
            [self hideBottomView:!_musicView.hidden];
        }
    });
}

#pragma mark - VideoRecordMusicViewDelegate
-(void)selectAudioEffect:(NSInteger)index
{
    [[TXUGCRecord shareInstance] setReverbType:index];
}

-(void)selectAudioEffect2:(NSInteger)index
{
    [[TXUGCRecord shareInstance] setVoiceChangerType:index];
}

-(void)onBtnMusicSelected
{
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:_bgmListVC];
    [nv.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    nv.navigationBar.barTintColor = RGB(25, 29, 38);
    [self presentViewController:nv animated:YES completion:nil];
    [_bgmListVC loadBGMList];
}

-(void)onBtnMusicStoped
{
    _BGMPath = nil;
    _bgmRecording = NO;
    [[TXUGCRecord shareInstance] stopBGM];
    if (!_musicView.hidden) {
        _musicView.hidden = !_musicView.hidden;
        [self hideBottomView:!_musicView.hidden];
    }
}

-(void)onBGMValueChange:(CGFloat)value
{
    [[TXUGCRecord shareInstance] setBGMVolume:value];
}

-(void)onVoiceValueChange:(CGFloat)value
{
    [[TXUGCRecord shareInstance] setMicVolume:value];
}

-(void)onBGMRangeChange:(CGFloat)startPercent endPercent:(CGFloat)endPercent
{
    //切换bgm 范围的时候，bgm录制状态置NO
    _bgmRecording = NO;
    //试听音乐这里要把RecordSpeed 设置为VIDEO_RECORD_SPEED_NOMAL，否则音乐可能会出现加速或则慢速播现象
    [[TXUGCRecord shareInstance] setRecordSpeed:VIDEO_RECORD_SPEED_NOMAL];
    [self playBGM:_BGMDuration * startPercent toTime:_BGMDuration * endPercent];
}

-(void)onSetBGM:(NSObject *)path
{
    _BGMPath = path;
    if([_BGMPath isKindOfClass:[NSString class]]){
        _BGMDuration =  [[TXUGCRecord shareInstance] setBGM:(NSString *)_BGMPath];
    }else{
        _BGMDuration =  [[TXUGCRecord shareInstance] setBGMAsset:(AVAsset *)_BGMPath];
    }
    
    _bgmRecording = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];        
    });
}

-(void)playBGM:(CGFloat)beginTime{
    if (_BGMPath != nil) {
        [[TXUGCRecord shareInstance] playBGMFromTime:beginTime toTime:_BGMDuration withBeginNotify:^(NSInteger errCode) {

        } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {

        } andCompleteNotify:^(NSInteger errCode) {

        }];
        _bgmBeginTime = beginTime;
    }
}

-(void)playBGM:(CGFloat)beginTime toTime:(CGFloat)endTime
{
    if (_BGMPath != nil) {
        [[TXUGCRecord shareInstance] playBGMFromTime:beginTime toTime:endTime withBeginNotify:^(NSInteger errCode) {

        } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {

        } andCompleteNotify:^(NSInteger errCode) {

        }];
        _bgmBeginTime = beginTime;
    }
}

-(void)pauseBGM{
    if (_BGMPath != nil) {
        [[TXUGCRecord shareInstance] pauseBGM];
    }
}

- (void)resumeBGM
{
    if (_BGMPath != nil) {
        [[TXUGCRecord shareInstance] resumeBGM];
    }
}


#pragma mark - HorizontalPickerView Delegate Methods
- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index {
    if (picker == _greenPickerView) {
        V8LabelNode *v = [_greenArray objectAtIndex:index];
        return [[UIImageView alloc] initWithImage:v.face];
    } else if(picker == _filterPickerView) {
        V8LabelNode *v = [_filterArray objectAtIndex:index];
        return [[UIImageView alloc] initWithImage:v.face];
    }
    return nil;
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    if (picker == _greenPickerView) {
        return 70;
    }
    return 90;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
    if (picker == _greenPickerView) {
        _greenIndex = index;
        V8LabelNode *v = [_greenArray objectAtIndex:index];
        [[TXUGCRecord shareInstance] setGreenScreenFile:v.file];
        return;
    }
    if (picker == _filterPickerView) {
        _filterIndex = index;

        [self setFilter:_filterIndex];
    }
}

- (void)setFilter:(NSInteger)index
{
    NSString* lookupFileName = @"";

    switch (index) {
        case FilterType_None:
            break;
        case FilterType_white:
            lookupFileName = @"filter_white";
            break;
        case FilterType_langman:
            lookupFileName = @"filter_langman";
            break;
        case FilterType_qingxin:
            lookupFileName = @"filter_qingxin";
            break;
        case FilterType_weimei:
            lookupFileName = @"filter_weimei";
            break;
        case FilterType_fennen:
            lookupFileName = @"filter_fennen";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"filter_huaijiu";
            break;
        case FilterType_landiao:
            lookupFileName = @"filter_landiao";
            break;
        case FilterType_qingliang:
            lookupFileName = @"filter_qingliang";
            break;
        case FilterType_rixi:
            lookupFileName = @"filter_rixi";
            break;
        default:
            break;
    }

    NSString * path = [[NSBundle mainBundle] pathForResource:lookupFileName ofType:@"png"];
    if (path != nil && index != FilterType_None)
    {
        [[TXUGCRecord shareInstance] setFilter:[UIImage imageWithContentsOfFile:path]];
    }
    else
    {
        [[TXUGCRecord shareInstance] setFilter:nil];
    }
}

#pragma mark - Misc Methods

- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

- (void) toastTip:(NSString*)toastInfo
{
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 100;
    frameRC.size.height -= 100;
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

@end
