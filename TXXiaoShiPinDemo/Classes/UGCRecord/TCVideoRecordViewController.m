
#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_UGC_IJK/TXLiteAVSDK.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaPickerController.h>
#import "SDKHeader.h"
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
#import "SoundMixView.h"
#import "Label.h"
#import <Masonry/Masonry.h>

#define BUTTON_RECORD_SIZE          75
#define BUTTON_CONTROL_SIZE         40
#define BUTTON_PROGRESS_HEIGHT      3
#define BUTTON_MASK_HEIGHT          170
#define BUTTON_SPEED_HEIGHT         34
#define BUTTON_SPEED_INTERVAL       30
#define BUTTON_SPEED_COUNT          5
#define BUTTON_SPEED_CHANGE_WIDTH   50
#define BUTTON_SPEED_CHANGE_HEIGHT  34



#import "FUManager.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>

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

typedef NS_ENUM(NSInteger,CaptureMode)
{
    CaptureModeStill,
    CaptureModeTap,
    CaptureModePress
};

@implementation RecordMusicInfo
@end

#if POD_PITU
#import "MCCameraDynamicView.h"
#import "MaterialManager.h"
#import "MCTip.h"
@interface TCVideoRecordViewController () <MCCameraDynamicDelegate,VideoRecordMusicViewDelegate,BeautySettingPanelDelegate,BeautyLoadPituDelegate, SoundMixViewDelegate>

@end
#endif

@interface TCVideoRecordViewController()<TXUGCRecordListener,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource,MPMediaPickerControllerDelegate,TCBGMControllerListener,TXVideoJoinerListener, TXVideoCustomProcessDelegate, FUAPIDemoBarDelegate>
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
    UIButton *                      _btnTorch;
    CGFloat                         _currentRecordTime;
    
    
    UIButton *                      _btnRatio;
    
    V8HorizontalPickerView *        _filterPickerView;
    NSMutableArray *                _filterArray;
    NSInteger                       _filterIndex;
    
    SoundMixView  *_soundMixView;
    
    BOOL                            _navigationBarHidden;
    BOOL                            _statusBarHidden;
    BOOL                            _appForeground;
    BOOL                            _isPaused;
    
    UIButton              *_motionBtn;
    UIButton              * __weak * _ratioMenuButtonIvarPtr;
    
    // 倒计时
    UILabel *_countDownLabel;
    UIView *_countDownView;
    NSTimer *_countDownTimer;
    
#if POD_PITU
    MCCameraDynamicView   *_tmplBar;
    NSString              *_materialID;
#else
    UIView                *_tmplBar;
#endif
    V8HorizontalPickerView  *_greenPickerView;
    NSMutableArray *_greenArray;
    
    TCBGMListViewController*        _bgmListVC;
    UIButton *_speedChangeBtn;
    
    NSInteger    _greenIndex;;
    
    float  _eye_level;
    float  _face_level;
    
    NSMutableArray *          _speedBtnList;
    NSObject*                 _BGMPath;
    CGFloat                   _BGMDuration;
    CGFloat                   _recordTime;
    
    int                       _deleteCount;
    float                     _zoom;
    BOOL                      _isBackDelete;
    BOOL                      _isFlash;
    
    TCVideoRecordMusicView *  _musicView;
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
    
    TXVideoVoiceChangerType   _voiceChangeType; // 变声参数
    NSInteger                 _soundMixChangeType; // 混音参数
}
@property (weak, nonatomic) IBOutlet UILabel *stillModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressModeLabel;

@property (weak, nonatomic) IBOutlet Label *recordTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnMusic;

@property (weak, nonatomic) IBOutlet UIButton *btnRatio169;
@property (weak, nonatomic) IBOutlet UIButton *btnRatio43;
@property (weak, nonatomic) IBOutlet UIButton *btnRatio11;
@property (weak, nonatomic) IBOutlet UIButton *btnRatioMenu;

@property (weak, nonatomic) IBOutlet UIButton *btnBeauty;
@property (weak, nonatomic) IBOutlet UIButton *btnAudioMix;
@property (weak, nonatomic) IBOutlet UIButton *btnCountDown;

@property (weak, nonatomic) IBOutlet UIButton *btnStartRecord;
@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *beautyBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;

@property (weak, nonatomic) IBOutlet UIView *speedView;
@property (weak, nonatomic) IBOutlet UIView *captureModeView;

@property (weak, nonatomic) IBOutlet UIView *bottomMask;
@property (weak, nonatomic) IBOutlet TCVideoRecordProcessView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMaskHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speedViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ratioTopConstraint;

@property (assign, nonatomic) CaptureMode captureMode;

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
        _sampleRate = AUDIO_SAMPLERATE_48000;
        
        _speedMode = SpeedMode_Standard;
        
        _voiceChangeType = -1; // 无变声
        _soundMixChangeType = -1; // 无混音效果

        _greenArray = [NSMutableArray new];
        [_greenArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label1", nil);
            v.file = nil;
            v.face = [UIImage imageNamed:@"greens_no"];
            v;
        })];
        [_greenArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label2", nil);
            v.file = [[NSBundle mainBundle] URLForResource:@"goodluck" withExtension:@"mp4"];;
            v.face = [UIImage imageNamed:@"greens_1"];
            v;
        })];
        [_greenArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label3", nil);
            v.file = [[NSBundle mainBundle] URLForResource:@"2gei_5" withExtension:@"mp4"];
            v.face = [UIImage imageNamed:@"greens_2"];
            v;
        })];
        
        _filterIndex = 0;
        _filterArray = [NSMutableArray new];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label4", nil);
            v.face = [UIImage imageNamed:@"orginal"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label5", nil);
            v.face = [UIImage imageNamed:@"biaozhun"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label6", nil);
            v.face = [UIImage imageNamed:@"yinghong"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label7", nil);
            v.face = [UIImage imageNamed:@"yunshang"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label8", nil);
            v.face = [UIImage imageNamed:@"chunzhen"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label9", nil);
            v.face = [UIImage imageNamed:@"bailan"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label10", nil);
            v.face = [UIImage imageNamed:@"yuanqi"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label11", nil);
            v.face = [UIImage imageNamed:@"chaotuo"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label12", nil);
            v.face = [UIImage imageNamed:@"xiangfen"];
            v;
        })];
        
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label13", nil);
            v.face = [UIImage imageNamed:@"fwhite"];
            v;
        })];
        
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label14", nil);
            v.face = [UIImage imageNamed:@"langman"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label15", nil);
            v.face = [UIImage imageNamed:@"qingxin"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label16", nil);
            v.face = [UIImage imageNamed:@"weimei"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label17", nil);
            v.face = [UIImage imageNamed:@"fennen"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label18", nil);
            v.face = [UIImage imageNamed:@"huaijiu"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label19", nil);
            v.face = [UIImage imageNamed:@"landiao"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label20", nil);
            v.face = [UIImage imageNamed:@"qingliang"];
            v;
        })];
        [_filterArray addObject:({
            V8LabelNode *v = [V8LabelNode new];
            v.title = NSLocalizedString(@"TCVideoRecordView.V8Label21", nil);
            v.face = [UIImage imageNamed:@"rixi"];
            v;
        })];
        
        _aspectRatio = VIDEO_ASPECT_RATIO_9_16;
        [TXUGCRecord shareInstance].recordDelegate = self;
        
        _bgmListVC = [[TCBGMListViewController alloc] init];
        [_bgmListVC setBGMControllerListener:self];
        _recordVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputRecord.mp4"];
        _joinVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputJoin.mp4"];
        
        self.captureMode = CaptureModeTap;
        
        NSLog(@"--- tx sdk version: %@", [TXLiveBase getSDKVersionStr]);
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
    
    [self uinit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
        self.bottomMaskHeight.constant += [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    _ratioMenuButtonIvarPtr = &_btnRatio169;
    [self initUI];
    [self initBeautyUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAudioSessionEvent:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    
    [[TXUGCRecord shareInstance] setVideoProcessDelegate:self];
    
    /**       FaceUnity       **/
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
}


- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height {
    
    return [[FUManager shareManager] renderItemWithTexture:texture Width:width Height:height] ;
}


-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 164 - 200, [UIScreen mainScreen].bounds.size.width, 164)];
        
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
        //停止特效的声音
        [[TXUGCRecord shareInstance] setMotionMute:NO];
    }
    // 恢复变声与混音效果
    if (_voiceChangeType >= 0) {
        [[TXUGCRecord shareInstance] setVoiceChangerType:_voiceChangeType];
    }
    if (_soundMixChangeType >= 0) {
        [[TXUGCRecord shareInstance] setReverbType:_soundMixChangeType];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:_navigationBarHidden];
    [[UIApplication sharedApplication]setStatusBarHidden:_statusBarHidden];
}

#pragma mark - Notification Handler
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
    [_btnNext setTitle:NSLocalizedString(@"Common.Next", nil)
              forState:UIControlStateNormal];
    [_btnMusic setTitle:NSLocalizedString(@"TCVideoRecordView.BeautyLabelMusic", nil)
               forState:UIControlStateNormal];
    [_btnBeauty setTitle:NSLocalizedString(@"TCVideoRecordView.BeautyLabelBeauty", nil)
                forState:UIControlStateNormal];    
    [_btnAudioMix setTitle:NSLocalizedString(@"TCVideoRecordView.AudioMix", nil)
                  forState:UIControlStateNormal];
    [_btnCountDown setTitle:NSLocalizedString(@"TCVideoRecordView.CountDown", nil)
                   forState:UIControlStateNormal];
    _stillModeLabel.text = NSLocalizedString(@"TCVideoRecordView.StillPhoto",nil);
    _tapModeLabel.text = NSLocalizedString(@"TCVideoRecordView.TapCapture", nil);
    _pressModeLabel.text = NSLocalizedString(@"TCVideoRecordView.PressCapture", nil);
    
    self.recordTimeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.recordTimeLabel.edgeInsets = UIEdgeInsetsMake(2, 8, 2, 8);
    self.recordTimeLabel.layer.cornerRadius  = self.recordTimeLabel.height / 2;
    self.recordTimeLabel.layer.masksToBounds = YES;
    
    _videoRecordView = [UIView new];
    _videoRecordView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_videoRecordView atIndex:0];
    
    if (_videoPath) {
        // 合唱
        self.speedView.hidden = YES;
        self.speedViewHeight.constant = 1;
        
        self.stillModeLabel.hidden = YES;
        self.progressView.minimumTimeTipHidden = YES;
        self.btnRatioMenu.hidden = YES;
        for (UIButton *button in @[self.btnRatio11, self.btnRatio43, self.btnRatio169]) {
            [button removeFromSuperview];
        }
        [self.btnMusic removeFromSuperview];
        [self.btnAudioMix removeFromSuperview];
        
        [self.btnBeauty mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.btnNext.mas_bottom).offset(38);
            make.right.equalTo(self.view).offset(-16);
        }];
        [self.btnCountDown mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.btnBeauty);
            make.top.equalTo(self.btnBeauty.mas_bottom).offset(30);
        }];
        
        
        _videoPlayView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoPlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view insertSubview:_videoPlayView atIndex:0];
        
        [_videoPlayView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).dividedBy(2);
            make.height.equalTo(self.view).dividedBy(2);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.bottomMask.mas_top).offset(30);
        }];
        
        [_videoRecordView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).dividedBy(2);
            make.height.equalTo(self.view).dividedBy(2);
            make.left.equalTo(self.view.mas_left);
            make.bottom.equalTo(self.bottomMask.mas_top).offset(30);
        }];
        
        _videoRecordView.translatesAutoresizingMaskIntoConstraints = NO;
        _videoPlayView.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        [self.view layoutIfNeeded];
    }else{
        self.btnCountDown.hidden = YES;
        _videoRecordView.frame = self.view.bounds;
        MAX_RECORD_TIME = 16;
        MIN_RECORD_TIME = 2;
        _recordType = RecordType_Normal;
    }
    
    UIPinchGestureRecognizer* pinchGensture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_videoRecordView addGestureRecognizer:pinchGensture];
    
    _btnNext.enabled = NO;
    
    
    
    _btnRatio169.tag = VIDEO_ASPECT_RATIO_9_16;
    _btnRatio11.tag  = VIDEO_ASPECT_RATIO_1_1;
    _btnRatio43.tag  = VIDEO_ASPECT_RATIO_3_4;
    _btnRatio169.enabled = _recordType == RecordType_Normal;
    
    
    _musicView = [[TCVideoRecordMusicView alloc] initWithFrame:CGRectMake(0, self.view.bottom - 330 * kScaleY, self.view.width, 330 * kScaleY) needEffect:YES];
    _musicView.delegate = self;
    _musicView.hidden = YES;
    [self.view addSubview:_musicView];
    _musicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _soundMixView = [SoundMixView instantiateFromNib];
    _soundMixView.delegate = self;
    _soundMixView.width = self.view.width;
    _soundMixView.top = self.view.height - _soundMixView.height; 
    //    _soundMixView = [[SoundMixView alloc] initWithFrame:_musicView.frame];
    [self.view addSubview:_soundMixView];
    _soundMixView.hidden = YES;
    _soundMixView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    if (_cameraFront) {
        _btnFlash.enabled = NO;
    }else{
        _btnFlash.enabled = YES;
    }
    
    [_recordTimeLabel setText:@"00:00"];
    
    [self configSpeedView];
    UIPanGestureRecognizer* panGensture = [[UIPanGestureRecognizer alloc] initWithTarget:self action: @selector (handlePanSlide:)];
    [self.view addGestureRecognizer:panGensture];
    //    switch (_videoRatio) {
    //        case VIDEO_ASPECT_RATIO_3_4:
    //            [self onBtnRatioClicked:_btnRatio43];
    //            break;
    //        case VIDEO_ASPECT_RATIO_1_1:
    //            [self onBtnRatioClicked:_btnRatio11];
    //            break;
    //        case VIDEO_ASPECT_RATIO_9_16:
    //            [self onBtnRatioClicked:_btnRatio169];
    //            break;
    //            
    //        default:
    //            break;
    //    }
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
    _vBeauty.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_vBeauty];
}

//加速录制
-(void)configSpeedView
{
    _speedBtnList = [NSMutableArray array];
    
    _speedView.layer.cornerRadius = _speedView.size.height / 2;
    _speedView.layer.masksToBounds = YES;
    _speedView.backgroundColor = [UIColor blackColor];
    _speedView.alpha = 0.5;
    
    if (_recordType != RecordType_Chorus)  {
        //合唱暂不支持变速录制
        
        _speedChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _speedChangeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _speedChangeBtn.titleLabel.minimumScaleFactor = 0.5;
        [_speedChangeBtn setTitle:[self getSpeedText:2] forState:UIControlStateNormal];
        [_speedChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_speedChangeBtn setBackgroundImage:[UIImage imageNamed:@"speedChange_center"] forState:UIControlStateNormal];
        
        CGFloat btnSpace = 0;
        CGFloat padding = 16 * kScaleX;
        CGFloat btnWidth = (_speedView.width -  2 * padding - btnSpace * 4 ) / 5;
        for(int i = 0 ; i < BUTTON_SPEED_COUNT ; i ++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.minimumScaleFactor = 0.5;
            btn.frame = CGRectMake(padding + (btnSpace + btnWidth) * i, 0, btnWidth, _speedView.height);
            [btn setTitle:[self getSpeedText:(SpeedMode)i] forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
            btn.titleLabel.minimumScaleFactor = 0.5;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [btn addTarget:self action:@selector(onBtnSpeedClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [_speedView addSubview:btn];
            [_speedBtnList addObject:btn];
        }
        [self setSelectedSpeed:SpeedMode_Standard];
        [self.bottomMask addSubview:_speedChangeBtn];
    }
}

- (void)setSelectedSpeed:(SpeedMode)tag
{
    if (tag >= _speedBtnList.count) {
        return;
    }
    const float padding = 16 * kScaleX;
    UIButton *btn = _speedBtnList[(NSInteger)tag];
    //    UIButton *btn = [self.speedView viewWithTag:(NSInteger)tag];
    CGRect rect = CGRectIntegral([_speedView convertRect:btn.frame toView:self.bottomMask]);
    CGRect frame = rect;
    frame.origin.y -= (BUTTON_SPEED_CHANGE_HEIGHT - rect.size.height) * 0.5;
    frame.size.height = BUTTON_SPEED_CHANGE_HEIGHT;
    
    NSString *bgName = @"speedChange_center";
    if (tag == 0) {
        frame.origin.x -= padding;
        frame.size.width += padding;
        bgName = @"speedChange_left";
    } else if (tag == 4) {
        frame.size.width += padding;
        bgName = @"speedChange_right";
    }
    [_speedChangeBtn setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    _speedChangeBtn.frame = frame;
    
    [_speedChangeBtn setTitle:[self getSpeedText:(SpeedMode)tag] forState:UIControlStateNormal];
    
    _speedMode = tag;
}

- (void)viewDidLayoutSubviews
{
    CGFloat btnSpace = 0;
    CGFloat padding = 16 * kScaleX;
    CGFloat btnWidth = (_speedView.width -  2 * padding - btnSpace * 4 ) / 5;
    [_speedBtnList enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger i, BOOL * _Nonnull stop) {
        btn.frame = CGRectMake(padding + (btnSpace + btnWidth) * i, 0, btnWidth, _speedView.height);
    }];
    [self setSelectedSpeed:_speedMode];
}

-(void)setSpeedBtnHidden:(BOOL)hidden{
    if (_videoPath != nil) hidden = YES;
    _speedView.hidden = hidden;
    _speedChangeBtn.hidden = hidden;
}

-(NSString *)getSpeedText:(SpeedMode)speedMode
{
    NSString *text = nil;
    switch (speedMode) {
        case SpeedMode_VerySlow:
            text = NSLocalizedString(@"TCVideoRecordView.SpeedSlow0", nil);
            break;
        case SpeedMode_Slow:
            text = NSLocalizedString(@"TCVideoRecordView.SpeedSlow", nil);
            break;
        case SpeedMode_Standard:
            text = NSLocalizedString(@"TCVideoRecordView.SpeedStandard", nil);
            break;
        case SpeedMode_Quick:
            text = NSLocalizedString(@"TCVideoRecordView.SpeedFast", nil);
            break;
        case SpeedMode_VeryQuick:
            text = NSLocalizedString(@"TCVideoRecordView.SpeedFast0", nil);
            break;
        default:
            break;
    }
    return text;
}


- (void)switchButton:(UIButton *)button0 withAnother:(UIButton *)button1
{
    NSInteger tmp = button0.tag;
    button0.tag = button1.tag;
    button1.tag = tmp;
    
    UIImage *tmpImage = [button0 imageForState:UIControlStateNormal];
    UIImage *tmpImage0 = [button0 imageForState:UIControlStateHighlighted];
    NSString *tmpTitle = [button0 titleForState:UIControlStateNormal];
    
    [button0 setImage:[button1 imageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [button0 setImage:[button1 imageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [button0 setTitle:[button1 titleForState:UIControlStateNormal] forState:UIControlStateNormal];
    
    [button1 setImage:tmpImage forState:UIControlStateNormal];
    [button1 setImage:tmpImage0 forState:UIControlStateHighlighted];
    [button1 setTitle:tmpTitle forState:UIControlStateNormal];
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
}

-(BOOL)ratioIsClosure
{
    if (CGRectEqualToRect(_btnRatio43.frame, _btnRatio11.frame)) {
        return YES;
    }
    return NO;
}

#pragma mark - Actions
- (void)takePhoto {
    [[TXUGCRecord shareInstance] snapshot:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void*)imageView);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = self.view.bounds;
            [self.view insertSubview:imageView belowSubview:self.bottomMask];
            
            CGAffineTransform t = CGAffineTransformMakeScale(0.33, 0.33);
            [UIView animateWithDuration:0.3 animations:^{
                imageView.transform = t;
            } completion:^(BOOL finished) {
                
            }];
        });
    }];
}

-(void)startVideoRecord
{
    self.btnCountDown.enabled = NO;
    [self startCameraPreview];
    [self setSpeedRate];
    int result = [[TXUGCRecord shareInstance] startRecord];
    [TCUtil report:xiaoshipin_startrecord userName:nil code:result msg:result == 0 ? @"启动录制成功" : @"启动录制失败"];
    if(0 != result)
    {
        if(-3 == result) [self alert:NSLocalizedString(@"TCVideoRecordView.HintLaunchRecordFailed", nil) msg:NSLocalizedString(@"TCVideoRecordView.ErrorCamera", nil)];
        if(-4 == result) [self alert:NSLocalizedString(@"TCVideoRecordView.HintLaunchRecordFailed", nil) msg:NSLocalizedString(@"TCVideoRecordView.ErrorMIC", nil)];
        if(-5 == result) [self alert:NSLocalizedString(@"TCVideoRecordView.HintLaunchRecordFailed", nil) msg:NSLocalizedString(@"TCVideoRecordView.ErrorLicense", nil)];
    }else{
        //如果设置了BGM，播放BGM
        [self playBGM:_bgmBeginTime];
        
        //初始化录制状态
        _bgmRecording = YES;
        _videoRecording = YES;
        _isPaused = NO;
        
        //录制过程中不能切换分辨率,不能切换拍照模式
        _btnRatio169.enabled = NO;
        _btnRatio43.enabled = NO;
        _btnRatio11.enabled = NO;
        self.captureModeView.userInteractionEnabled = NO;

        [self setSpeedBtnHidden:YES];
        [_btnStartRecord setImage:[UIImage imageNamed:@"pause_record"] forState:UIControlStateNormal];
        [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"pause_ring"] forState:UIControlStateNormal];
        _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE * 0.85, BUTTON_RECORD_SIZE * 0.85);
        
        if (_recordType == RecordType_Chorus) {
            [_videoEditer startPlayFromTime:_recordTime toTime:MAX_RECORD_TIME];
        }
    }
}

- (void)startCountDown {
    if (_countDownTimer) {
        return;
    }
    
    if (_countDownView == nil) {
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight]];
        view.layer.cornerRadius = 20;
        view.clipsToBounds = YES;
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        UILabel *countDownLabel = [[UILabel alloc] init];
        countDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
        countDownLabel.textColor = [UIColor colorWithWhite:0.33 alpha:1];
        countDownLabel.font = [UIFont systemFontOfSize:100];
        
        [view.contentView addSubview:countDownLabel];
        [view.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:countDownLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [view.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:countDownLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150]];
        
        [self.view addSubview:view];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        
        _countDownView = view;
        _countDownLabel = countDownLabel;
    }
    _countDownView.hidden = NO;
    _countDownLabel.text = @"3";  
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onCountDownTimer:) userInfo:nil repeats:YES];
    _countDownView.hidden = NO;
}

- (void)onCountDownTimer:(NSTimer *)timer {
    int count = _countDownLabel.text.intValue - 1;
    _countDownLabel.text = @(count).stringValue;
    if (count == 0) {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
        _countDownView.hidden = YES;
        [self changeCaptureModeUI:CaptureModeTap];
        self.captureMode = CaptureModeTap;
        [self onBtnRecordStartClicked];
        [self hideBottomView:NO];
    }
}

#pragma mark - Properties
-(void)setSpeedRate{
    switch (_speedMode) {
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

#pragma mark - Left Side Button Event Handler
-(IBAction)onBtnPopClicked:(id)sender
{
    NSArray *videoPaths = [[TXUGCRecord shareInstance].partsManager getVideoPathList];
    if (videoPaths.count > 0) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"TCVideoRecordView.AbandonRecord", nil) message:nil cancelButtonTitle:NSLocalizedString(@"Common.Cancel", nil) otherButtonTitles:@[NSLocalizedString(@"Common.OK", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:CACHE_PATH_LIST];
                if (_recordType == RecordType_Normal) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else{
                return;
            }
        }];
        [alert show];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:CACHE_PATH_LIST];
        if (_recordType == RecordType_Normal) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Right Side Button Event Handler
- (IBAction)onBtnDoneClicked:(id)sender
{
//    if (!_videoRecording)
//        return;
    
    [self stopVideoRecord];
}

- (IBAction)onBtnMusicClicked:(id)sender
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

- (IBAction)onBtnRatioClicked:(UIButton *)btn
{
    TXVideoAspectRatio targetRatio = btn.tag;
    if (btn == self.btnRatioMenu) {
        BOOL menuIsClosed = NO;
        if (self.btnRatio169 == self.btnRatioMenu) {
            menuIsClosed = self.btnRatio11.hidden;
        } else {
            menuIsClosed = self.btnRatio169.hidden;
        }
        BOOL shouldHidden = !menuIsClosed;
        
        self.btnRatio169.hidden = shouldHidden;
        self.btnRatio11.hidden = shouldHidden;
        self.btnRatio43.hidden = shouldHidden;
        
        self.btnRatioMenu.hidden = NO;
        
    } else {
        [self switchButton:self.btnRatioMenu withAnother:btn];
        __weak UIButton *tmp = *_ratioMenuButtonIvarPtr;
        *_ratioMenuButtonIvarPtr = btn;
        switch (targetRatio) {
            case VIDEO_ASPECT_RATIO_9_16: 
                self.btnRatio169 = tmp;
                _ratioMenuButtonIvarPtr = &_btnRatio169;
                break;
            case VIDEO_ASPECT_RATIO_3_4:
                self.btnRatio43 = tmp;
                _ratioMenuButtonIvarPtr = &_btnRatio43;
                break;
            case VIDEO_ASPECT_RATIO_1_1:
                self.btnRatio11 = tmp;
                _ratioMenuButtonIvarPtr = &_btnRatio11;
                break;
            default:
                break;
        }
        [self setAspectRatio:targetRatio];
        self.btnRatio169.hidden = YES;
        self.btnRatio11.hidden = YES;
        self.btnRatio43.hidden = YES;
        self.btnRatioMenu.hidden = NO;
    }   
}

-(IBAction)onBtnBeautyClicked:(id)sender
{
    _vBeautyShow = !_vBeautyShow;
    _musicView.hidden = YES;
    _vBeauty.hidden = !_vBeautyShow;
    [self hideBottomView:_vBeautyShow];
}

- (IBAction)onBtnAudioMix:(id)sender {
    [self hideBottomView:YES];
    _soundMixView.hidden = NO;
    _vBeauty.hidden = YES;
    _musicView.hidden = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, self.view.width, self.view.height - _soundMixView.height);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(onHideSoundMix:) forControlEvents:UIControlEventTouchUpInside];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    [_soundMixView.layer addAnimation:animation forKey:nil];
}

- (IBAction)onCountDown:(id)sender {
    [self hideBottomView:YES];
    [self startCountDown];
}


#pragma mark * Bottom Control Tap Handler
-(void)onBtnSpeedClicked:(UIButton *)btn
{
    [UIView animateWithDuration:0.3 animations:^{
        _speedMode = btn.tag;
        [self setSelectedSpeed:_speedMode];
    }];
}


-(IBAction)onBtnFlashClicked
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

-(IBAction)onBtnDeleteClicked
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

-(IBAction)onBtnStartRecord // touch down
{
    if (self.captureMode == CaptureModePress) {
        [self onBtnRecordStartClicked];
    }
}

-(IBAction)onBtnStopRecord  // touch up
{
    switch (self.captureMode) {
        case CaptureModePress:
            [self onBtnRecordStartClicked];
            break;
        case CaptureModeTap: 
            [self onBtnRecordStartClicked];
            break;
        default:
            break;
    }
}

- (IBAction)onRecordTouchUpInside:(id)sender
{
    if (self.captureMode == CaptureModeStill) {
        [self takePhoto];
    }
}

-(IBAction)onBtnCameraClicked
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

- (IBAction)onTapCaptureMode:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    CGFloat itemWidth = CGRectGetWidth(gesture.view.frame) / 3;
    CaptureMode mode = floor(point.x / itemWidth);
    [self changeCaptureModeUI:mode];
    self.captureMode = mode;
}

- (void)changeCaptureModeUI:(CaptureMode)captureMode
{
    NSInteger tag = captureMode + 1;
    if (_videoPath) {
        // 合唱
        if (tag - 1 == CaptureModeStill) {
            return;
        }
    }
    UIView *targetView = [self.captureModeView viewWithTag:tag];
    CGFloat offset = CGRectGetMidX(self.captureModeView.bounds) - targetView.center.x;
    self.captureMode = tag - 1;
    NSString *name = self.captureMode == CaptureModeStill ? @"start_record_white" : @"start_record";
    [UIView animateWithDuration:0.1 animations:^{
        [self.btnStartRecord setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        self.centerConstraint.constant = offset;
        [self.captureModeView layoutIfNeeded];
    }];
}

#pragma mark -

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIImageView *imageView = (__bridge UIImageView *)contextInfo;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGAffineTransform t = CGAffineTransformTranslate(imageView.transform, 0, self.view.height);
                         imageView.transform = CGAffineTransformScale(t, 0.5, 0.5);
                     } completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
                     }];
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
            self.btnCountDown.enabled = NO;
            self.captureModeView.userInteractionEnabled = NO;

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
            self.captureModeView.userInteractionEnabled = YES;
            self.btnCountDown.enabled = YES;
            
            __weak __typeof(self) weakSelf = self;
            [[TXUGCRecord shareInstance] pauseRecord:^{
                [weakSelf cacheVideoPathList];
            }];
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

- (void)onHideSoundMix:(UIButton *)sender
{
    [sender removeFromSuperview];
    _soundMixView.hidden = YES;
    self.bottomMask.hidden = NO;
    [self hideBottomView:NO];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.1;
    animation.type = kCATransitionFade;
    [_soundMixView.superview.layer addAnimation:animation forKey:nil];
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
        param.videoFPS = 30;
        param.videoBitratePIN = 9600;
        param.GOP = 3;
        param.audioSampleRate = AUDIO_SAMPLERATE_48000;
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
        
        //加载缓存视频
        if (_preloadingVideos) {
            NSArray *cachePathList = [[NSUserDefaults standardUserDefaults] objectForKey:CACHE_PATH_LIST];
            NSString *cacheFolder = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TXUGC"] stringByAppendingPathComponent:@"TXUGCParts"];
            //预加载视频 -> SDK
            for (NSInteger i = cachePathList.count - 1; i >= 0; i --) {
                NSString *videoPath = [cacheFolder stringByAppendingPathComponent:cachePathList[i]];
                [[TXUGCRecord shareInstance].partsManager insertPart:videoPath atIndex:0];
            }
            //进度条初始化
            CGFloat time = 0;
            for (NSInteger i = 0; i < cachePathList.count; i ++) {
                NSString *videoPath = [cacheFolder stringByAppendingPathComponent:cachePathList[i]];
                time = time + [TXVideoInfoReader getVideoInfo:videoPath].duration;
                [_progressView pauseAtTime:time];
            }
            _preloadingVideos = NO;
        }
        
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

-(void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Common.OK", nil) otherButtonTitles:nil, nil];
    [alert show];
}

-(void)stopVideoRecord
{
    self.btnCountDown.enabled = YES;
    [_btnStartRecord setImage:[UIImage imageNamed:@"start_record"] forState:UIControlStateNormal];
    [_btnStartRecord setBackgroundImage:[UIImage imageNamed:@"start_ring"] forState:UIControlStateNormal];
    _btnStartRecord.bounds = CGRectMake(0, 0, BUTTON_RECORD_SIZE, BUTTON_RECORD_SIZE);
    [self setSpeedBtnHidden:NO];
    [_videoEditer stopPlay];
    
    //调用partsManager快速合成视频，不破坏录制状态，下次返回后可以接着录制（注意需要先暂停视频录制）
    __weak __typeof(self) weakSelf = self;
    [[TXUGCRecord shareInstance] pauseRecord:^{
        [weakSelf cacheVideoPathList];
    }];
    [[TXUGCRecord shareInstance].partsManager joinAllParts:_recordVideoPath complete:^(int result) {
        [weakSelf joinAllPartsResult:result];
    }];
}

- (void)cacheVideoPathList
{
    NSMutableArray *cachePathList = [NSMutableArray array];
    for (NSString *videoPath in [TXUGCRecord shareInstance].partsManager.getVideoPathList) {
        [cachePathList addObject:[[videoPath pathComponents] lastObject]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:cachePathList forKey:CACHE_PATH_LIST];
}

-(void)joinAllPartsResult:(int)result
{
    if(0 == result){
        if (_recordType == RecordType_Normal) {
            [self stopCameraPreview];
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
            if (_recordVideoPath
                && _videoPath
                && [[NSFileManager defaultManager] fileExistsAtPath:_recordVideoPath]
                && [[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
                if (0 == [_videoJoiner setVideoPathList:@[_recordVideoPath,_videoPath]]) {
                    [_videoJoiner setSplitScreenList:@[[NSValue valueWithCGRect:recordScreen],[NSValue valueWithCGRect:playScreen]] canvasWidth:720 * 2 canvasHeight:1280];
                    [_videoJoiner splitJoinVideo:VIDEO_COMPRESSED_720P videoOutputPath:_joinVideoPath];
                    _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    _hub.mode = MBProgressHUDModeText;
                    _hub.label.text = NSLocalizedString(@"TCVideoEditPrevView.VideoSynthesizing", nil);
                }else{
                    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"TCVideoEditPrevView.HintVideoSynthesizeFailed", nil) message:NSLocalizedString(@"TCVideoEditPrevView.VideoChorusNotSupported",nil) cancelButtonTitle:NSLocalizedString(@"Common.OK", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    }];
                    [alert show];
                }
            }else{
                [self alert:NSLocalizedString(@"TCVideoEditPrevView.HintVideoSynthesizeFailed",nil) msg:NSLocalizedString(@"TCVideoEditPrevView.TryAgain",nil)];
            }
        }
        [TCUtil report:xiaoshipin_videorecord userName:nil code:0 msg:@"视频录制成功"];
    }else{
        [TCUtil report:xiaoshipin_videorecord userName:nil code:-1 msg:@"视频录制失败"];
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

-(void)onBtnLampClicked
{
    _lampOpened = !_lampOpened;
    
    BOOL result = [[TXUGCRecord shareInstance] toggleTorch:_lampOpened];
    if (result == NO)
    {
        _lampOpened = !_lampOpened;
        [self toastTip:NSLocalizedString(@"TCVideoRecordView.ErrorFlash", nil)];
    }
    
    if (_lampOpened)
    {
        [_btnTorch setImage:[UIImage imageNamed:@"lamp_press"] forState:UIControlStateNormal];
    }else
    {
        [_btnTorch setImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
    }
}



///  选拍照模式
- (void)setCaptureMode:(CaptureMode)captureMode
{
    _captureMode = captureMode;
    
    BOOL isStillMode = captureMode == CaptureModeStill;
    self.speedView.hidden = isStillMode;
    self.progressView.hidden = isStillMode;
    self.recordTimeLabel.hidden = isStillMode;
    self.btnDelete.hidden = isStillMode;
    _speedChangeBtn.hidden = isStillMode;
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_vBeautyShow)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint _touchPoint = [touch locationInView:self.view];
        if (NO == CGRectContainsPoint(_vBeauty.frame, _touchPoint))
        {
            [self onBtnBeautyClicked:nil];
        }
    }
    if (!_musicView.hidden) {
        CGPoint _touchPoint = [[[event allTouches] anyObject] locationInView:self.view];
        if (NO == CGRectContainsPoint(_musicView.frame, _touchPoint)){
            _musicView.hidden = !_musicView.hidden;
            [self hideBottomView:!_musicView.hidden];
        }
    }
}

- (void)hideBottomView:(BOOL)bHide
{
    _recordTimeLabel.hidden = bHide;
    _bottomMask.hidden = bHide;
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
}

#pragma mark TXUGCRecordListener
-(void) onRecordProgress:(NSInteger)milliSecond;
{
    _recordTime =  milliSecond / 1000.0;
    [self refreshRecordTime: _recordTime];
    
    BOOL isEmpty = milliSecond == 0;
    //录制过程中不能切换BGM, 不能改变声音效果
    _btnMusic.enabled = isEmpty;
    _btnNext.enabled = milliSecond / 1000.0 >= MIN_RECORD_TIME;
    _btnAudioMix.enabled = _btnMusic.enabled;
    _btnRatio169.enabled = isEmpty;
    _btnRatio43.enabled = isEmpty;
    _btnRatio11.enabled = isEmpty;

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
                [self toastTip:NSLocalizedString(@"TCVideoRecordView.ErrorREC", nil)];
            }
        } else {
            [self toastTip:NSLocalizedString(@"TCVideoRecordView.ErrorTime", nil)];
        }
    }
}

#pragma mark TXVideoJoinerListener
-(void) onJoinProgress:(float)progress
{
    _hub.label.text = [NSString stringWithFormat:@"%@%d%%",NSLocalizedString(@"TCVideoEditPrevView.VideoSynthesizing",nil), (int)(progress * 100)];
}
-(void) onJoinComplete:(TXJoinerResult *)result
{
    [_hub hideAnimated:YES];
    if (_appForeground && result.retCode == RECORD_RESULT_OK) {
        [self stopCameraPreview];
        TCVideoEditViewController *vc = [[TCVideoEditViewController alloc] init];
        vc.videoPath = _joinVideoPath;
        vc.isFromChorus = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"TCVideoRecordView.VideoJoinerFailed", nil) message:result.descMsg cancelButtonTitle:NSLocalizedString(@"Common.OK", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        [alert show];
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
        _hub.removeFromSuperViewOnHide = YES;
        _hub.mode = MBProgressHUDModeText;
        _hub.label.text = NSLocalizedString(@"TCVideoRecordView.ResourceLoadBegin", nil);
    });
}
- (void)onLoadPituProgress:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = [NSString stringWithFormat:NSLocalizedString(@"TCVideoRecordView.ResourceLoading", nil),(int)(progress * 100)];
    });
}
- (void)onLoadPituFinished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = NSLocalizedString(@"TCVideoRecordView.ResourceLoadSucceeded", nil);
        [_hub hideAnimated:YES afterDelay:1];
    });
}
- (void)onLoadPituFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = NSLocalizedString(@"TCVideoRecordView.ResourceLoadFailed", nil);
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

#pragma mark - SoundMixView
#pragma mark   * SoundMixViewDelegate
- (void)soundMixView:(SoundMixView *)view didSelectMixIndex:(NSInteger)index
{
    _soundMixChangeType = index;
    [[TXUGCRecord shareInstance] setReverbType:index];
}

- (void)soundMixView:(SoundMixView *)view didSelectVoiceChangeIndex:(NSInteger)index
{
    if (index >= VIDOE_VOICECHANGER_TYPE_5) {
        // 去掉感冒
        index ++;
    }
    _voiceChangeType = index;
    [[TXUGCRecord shareInstance] setVoiceChangerType:index];
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
        case FilterType_biaozhun:
            lookupFileName = @"filter_biaozhun";
            break;
        case FilterType_yinghong:
            lookupFileName = @"filter_yinghong";
            break;
        case FilterType_yunshang:
            lookupFileName = @"filter_yunshang";
            break;
        case FilterType_chunzhen:
            lookupFileName = @"filter_chunzhen";
            break;
        case FilterType_bailan:
            lookupFileName = @"filter_bailan";
            break;
        case FilterType_yuanqi:
            lookupFileName = @"filter_yuanqi";
            break;
        case FilterType_chaotuo:
            lookupFileName = @"filter_chaotuo";
            break;
        case FilterType_xiangfen:
            lookupFileName = @"filter_xiangfen";
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

#pragma mark - gesture handler
- (void)handlePanSlide:(UIPanGestureRecognizer*)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view.superview];
    [recognizer velocityInView:self.view];
    CGPoint speed = [recognizer velocityInView:self.view];
    
    NSLog(@"pan center:(%.2f)", translation.x);
    NSLog(@"pan speed:(%.2f)", speed.x);
    
    float ratio = translation.x / self.view.frame.size.width;
    float leftRatio = ratio;
    NSInteger index = [_vBeauty currentFilterIndex];
    UIImage* curFilterImage = [_vBeauty filterImageByIndex:index];
    UIImage* filterImage1 = nil;
    UIImage* filterImage2 = nil;
    CGFloat filter1Level = 0.f;
    CGFloat filter2Level = 0.f;
    if (leftRatio > 0) {
        filterImage1 = [_vBeauty filterImageByIndex:index - 1];
        filter1Level = [_vBeauty filterMixLevelByIndex:index - 1] / 10;
        filterImage2 = curFilterImage;
        filter2Level = [_vBeauty filterMixLevelByIndex:index] / 10;
    }
    else {
        filterImage1 = curFilterImage;
        filter1Level = [_vBeauty filterMixLevelByIndex:index] / 10;
        filterImage2 = [_vBeauty filterImageByIndex:index + 1];
        filter2Level = [_vBeauty filterMixLevelByIndex:index + 1] / 10;
        leftRatio = 1 + leftRatio;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [[TXUGCRecord shareInstance] setFilter:filterImage1 leftIntensity:filter1Level rightFilter:filterImage2 rightIntensity:filter2Level leftRatio:leftRatio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        BOOL isDependRadio = fabs(speed.x) < 500; //x方向的速度
        [self animateFromFilter1:filterImage1 filter2:filterImage2 filter1MixLevel:filter1Level filter2MixLevel:filter2Level leftRadio:leftRatio speed:speed.x completion:^{
            if (!isDependRadio) {
                if (speed.x < 0) {
                    _vBeauty.currentFilterIndex = index + 1;
                }
                else {
                    _vBeauty.currentFilterIndex = index - 1;
                }
            }
            else {
                if (ratio > 0.5) {   //过半或者速度>500就切换
                    _vBeauty.currentFilterIndex = index - 1;
                }
                else if  (ratio < -0.5) {
                    _vBeauty.currentFilterIndex = index + 1;
                }
            }
            
            UILabel* filterTipLabel = [UILabel new];
            filterTipLabel.text = [_vBeauty currentFilterName];
            filterTipLabel.font = [UIFont systemFontOfSize:30];
            filterTipLabel.textColor = UIColor.whiteColor;
            filterTipLabel.alpha = 0.1;
            [filterTipLabel sizeToFit];
            filterTipLabel.center = CGPointMake(self.view.size.width / 2, self.view.size.height / 3);
            [self.view addSubview:filterTipLabel];
            
            [UIView animateWithDuration:0.25 animations:^{
                filterTipLabel.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^{
                    filterTipLabel.alpha = 0.1;
                } completion:^(BOOL finished) {
                    [filterTipLabel removeFromSuperview];
                }];
            }];
        }];
        
        
    }
}

- (void)animateFromFilter1:(UIImage*)filter1Image filter2:(UIImage*)filter2Image filter1MixLevel:(CGFloat)filter1MixLevel filter2MixLevel:(CGFloat)filter2MixLevel leftRadio:(CGFloat)leftRadio speed:(CGFloat)speed completion:(void(^)(void))completion
{
    if (leftRadio <= 0 || leftRadio >= 1) {
        completion();
        return;
    }
    
    static float delta = 1.f / 12;
    
    BOOL isDependRadio = fabs(speed) < 500;
    if (isDependRadio) {
        if (leftRadio < 0.5) {
            leftRadio -= delta;
        }
        else {
            leftRadio += delta;
        }
    }
    else {
        if (speed > 0) {
            leftRadio += delta;
        }
        else
            leftRadio -= delta;
    }
    
    [[TXUGCRecord shareInstance] setFilter:filter1Image leftIntensity:filter1MixLevel rightFilter:filter2Image rightIntensity:filter2MixLevel leftRatio:leftRadio];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f / 30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateFromFilter1:filter1Image filter2:filter2Image filter1MixLevel:filter1MixLevel filter2MixLevel:filter2MixLevel leftRadio:leftRadio speed:speed completion:completion];
    });
}

- (void)uinit{
    [[TXUGCRecord shareInstance] stopRecord];
    [[TXUGCRecord shareInstance] stopCameraPreview];
    [[TXUGCRecord shareInstance].partsManager deleteAllParts];
    if (!_savePath) {
        [TCUtil removeCacheFile:_videoPath];
    }
    [TCUtil removeCacheFile:_recordVideoPath];
    [TCUtil removeCacheFile:_joinVideoPath];
}

@end
