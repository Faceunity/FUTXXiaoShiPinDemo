#import "TCVideoPublishController.h"
#import "UIView+CustomAutoLayout.h"
#import <UShareUI/UMSocialUIManager.h>
#import "NSString+Common.h"
#import "TCUserInfoModel.h"
#import "TCVideoRecordViewController.h"
#import "SDKHeader.h"
#import "TXUGCPublish.h"
#import "TCLoginModel.h"
#import <UMSocialCore/UMSocialCore.h>
#import <AFNetworking.h>

@interface TCVideoPublishController()
@property UILabel         *labPublishState;
@property BOOL isNetWorkErr;
@property UIImageView      *imgPublishState;

@end

@implementation TCVideoPublishController
{
    //分享
    UIView          *_vShare;
    UIView          *_vShareInfo;
    UIView          *_vVideoPreview;
    UITextView       *_txtShareWords;
    UILabel         *_labDefaultWords;
    UILabel         *_labLeftWords;
    
    UILabel         *_labRecordVideo;
    
    UIView          *_vSharePlatform;
    NSMutableArray   *_btnShareArry;
    
    //发布
    UIView          *_vPublishInfo;
    UIImageView      *_imgPublishState;
    UILabel         *_labPublishState;
    
    TXUGCPublish   *_videoPublish;
    TXLivePlayer     *_livePlayer;
    
    TXPublishParam   *_videoPublishParams;
    TXRecordResult   *_recordResult;
    
    NSInteger       _selectBtnTag;
    BOOL            _isPublished;
    
    BOOL            _playEnable;
    
    id              _videoRecorder;
    BOOL            _isNetWorkErr;
}

- (instancetype)init:(id)videoRecorder recordType:(NSInteger)recordType RecordResult:(TXRecordResult *)recordResult  TCLiveInfo:(TCLiveInfo *)liveInfo
{
    self = [super init];
    if (self) {
        _videoPublishParams = [[TXPublishParam alloc] init];
        _recordResult = recordResult;
        
        _videoRecorder = videoRecorder;
        
        _isPublished = NO;
        
        _playEnable  = YES;
        
        _isNetWorkErr = NO;
        
        _selectBtnTag = -1;
        
        _videoPublish = [[TXUGCPublish alloc] initWithUserID:[[TCUserInfoModel sharedInstance] getUserProfile].identifier];
        _videoPublish.delegate = self;
        _livePlayer  = [[TXLivePlayer alloc] init];
        _livePlayer.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)videoPath videoMsg:(TXVideoInfo *) videoMsg
{
    TXRecordResult *recordResult = [TXRecordResult new];
    recordResult.coverImage = videoMsg.coverImage;
    recordResult.videoPath = videoPath;

    
    return [self init:nil recordType:0
         RecordResult:recordResult
           TCLiveInfo:nil];
}

- (void)dealloc
{
    [_livePlayer removeVideoWidget];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x0ACCAC);
    self.navigationItem.title = @"发布";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor blackColor]}] ;
    self.view.backgroundColor = UIColorFromRGB(0xefeff4);
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(videoPublish)];
    self.navigationItem.rightBarButtonItems = [NSMutableArray arrayWithObject:btn];

    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    
    //分享
    _vShare = [[UIView alloc] init];
    _vShare.backgroundColor = [UIColor clearColor];
    
    _vShareInfo = [[UIView alloc] init];
    _vShareInfo.backgroundColor = [UIColor whiteColor];
    
    _vVideoPreview = [[UIView alloc] init];
    
    _txtShareWords = [[UITextView alloc] init];
    _txtShareWords.delegate = self;
    _txtShareWords.layer.borderColor = _vShareInfo.backgroundColor.CGColor;
    _txtShareWords.font = [UIFont systemFontOfSize:16];
    _txtShareWords.textColor = UIColorFromRGB(0x0ACCAC);
 
    _labDefaultWords = [[UILabel alloc] init];
    _labDefaultWords.text = @"说点什么...";
    _labDefaultWords.textColor = UIColorFromRGB(0xefeff4);
    _labDefaultWords.font = [UIFont systemFontOfSize:16];
    _labDefaultWords.backgroundColor =[UIColor clearColor];
    _labDefaultWords.textAlignment = NSTextAlignmentLeft;
    
    _labLeftWords = [[UILabel alloc] init];
    _labLeftWords.text = @"0/500";
    _labLeftWords.textColor = UIColorFromRGB(0xefeff4);
    _labLeftWords.font = [UIFont systemFontOfSize:12];
    _labLeftWords.backgroundColor =[UIColor clearColor];
    _labLeftWords.textAlignment = NSTextAlignmentRight;
    
    _vSharePlatform = [[UIView alloc] init];
    _vSharePlatform.backgroundColor = [UIColor whiteColor];
    
    NSArray * shareTitleArray       = @[
                                        @"微信",
                                        @"朋友圈",
                                        @"QQ",
                                        @"QQ空间",
                                        @"微博"];
    
    NSArray * shareIconPressArray        = @[
                                        @"video_record_wechat",
                                        @"video_record_friends",
                                        @"video_record_QQ",
                                        @"video_record_Qzone",
                                        @"video_record_sina"];
    NSArray * shareIconArray   = @[
                                        @"video_record_wechat_gray",
                                        @"video_record_friends_gray",
                                        @"video_record_QQ_gray",
                                        @"video_record_Qzone_gray",
                                        @"video_record_sina_gray"];
    
    _btnShareArry = [[NSMutableArray alloc] init];
    for(int i=0; i<shareTitleArray.count && i<shareIconArray.count && i<shareIconPressArray.count; ++i)
    {
        UIButton * _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setImage:[UIImage imageNamed:[shareIconArray objectAtIndex:i]] forState:UIControlStateNormal];
        [_btn setImage:[UIImage imageNamed:[shareIconPressArray objectAtIndex:i]] forState:UIControlStateSelected];
        [_btn setTitle:[shareTitleArray objectAtIndex:i] forState:UIControlStateNormal];
        [_btn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
        _btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_btn addTarget:self action:@selector(selectShare:) forControlEvents:UIControlEventTouchUpInside];
        _btn.tag = i;
        _btn.selected = NO;
//        [_btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        [_btnShareArry addObject:_btn];
        [_vSharePlatform addSubview:_btn];
    }
    [_vShare addSubview:_vSharePlatform];
    
    [self.view addSubview:_vShare];
    
    [_vShare addSubview:_vShareInfo];
    
    [_vShareInfo addSubview:_vVideoPreview];
    [_vShareInfo addSubview:_txtShareWords];
    [_vShareInfo addSubview:_labDefaultWords];
    [_vShareInfo addSubview:_labLeftWords];
    
    [_vShare sizeWith:CGSizeMake(self.view.width, self.view.height - [[UIApplication sharedApplication] statusBarFrame].size.height - self.navigationController.navigationBar.height)];
    [_vShare alignParentTopWithMargin:[[UIApplication sharedApplication] statusBarFrame].size.height+self.navigationController.navigationBar.height];
    [_vShare alignParentLeft];
    
    [_vShareInfo setSize:CGSizeMake(self.view.width, 180)];
    [self setBorderWithView:_vShareInfo top:YES left:NO bottom:YES right:NO borderColor:UIColorFromRGB(0xd8d8d8) borderWidth:0.5];
    [_vShareInfo alignParentTopWithMargin:42];
    [_vShareInfo alignParentLeft];
    
    [_vSharePlatform setSize:CGSizeMake(self.view.width, 100)];
    [self setBorderWithView:_vSharePlatform top:YES left:NO bottom:YES right:NO borderColor:UIColorFromRGB(0xd8d8d8) borderWidth:0.5];
    [_vSharePlatform alignParentTopWithMargin:264];
    [_vSharePlatform alignParentLeft];
    
    [_vVideoPreview setSize:CGSizeMake(100, 150)];
    [_vVideoPreview alignParentLeftWithMargin:15];
    [_vVideoPreview alignParentTopWithMargin:15];
    
    [_txtShareWords setSize:CGSizeMake(self.view.width - _vVideoPreview.width - 45, _vVideoPreview.height)];
    [_txtShareWords layoutToRightOf:_vVideoPreview margin:15];
    [_txtShareWords alignParentTopWithMargin:15];
    
    [_labDefaultWords setSize:CGSizeMake(90, 16)];
    [_labDefaultWords layoutToRightOf:_vVideoPreview margin:25];
    [_labDefaultWords alignParentTopWithMargin:24];
    
    [_labLeftWords setSize:CGSizeMake(50, 12)];
    [_labLeftWords alignParentRightWithMargin:15];
    [_labLeftWords alignParentBottomWithMargin:15];
    
    
    UILabel* publish_promise = [[UILabel alloc] init];
    publish_promise.text = @"发布到小视频";
    publish_promise.textColor = UIColorFromRGB(0x777777);
    publish_promise.font = [UIFont systemFontOfSize:12];
    publish_promise.backgroundColor =[UIColor clearColor];
    publish_promise.textAlignment = NSTextAlignmentLeft;
    [_vShare addSubview:publish_promise];
    [publish_promise setSize:CGSizeMake(90, 12)];
    [publish_promise alignParentTopWithMargin:20];
    [publish_promise alignParentLeftWithMargin:15];
    
    UILabel* share_promise = [[UILabel alloc] init];
    share_promise.text = @"同时分享到";
    share_promise.textColor = UIColorFromRGB(0x777777);
    share_promise.font = [UIFont systemFontOfSize:12];
    share_promise.backgroundColor =[UIColor clearColor];
    share_promise.textAlignment = NSTextAlignmentLeft;
    [_vShare addSubview:share_promise];
    [share_promise setSize:CGSizeMake(90, 12)];
    [share_promise alignParentTopWithMargin:242];
    [share_promise alignParentLeftWithMargin:15];
    
    int gap = 15;
    int shareBtnWidth = 45;
    if (_btnShareArry.count > 1) gap = (self.view.width - 30 - _btnShareArry.count*shareBtnWidth)/(_btnShareArry.count-1);
    for(int i=0; i<_btnShareArry.count; ++i)
    {
        UIButton *btn = [_btnShareArry objectAtIndex:i];
        [btn setSize:CGSizeMake(shareBtnWidth, 70)];
        if (0 == i) {
            [btn alignParentLeftWithMargin:15];
        } else {
            [btn layoutToRightOf:[_btnShareArry objectAtIndex:i-1] margin:gap];
        }
        [btn alignParentTopWithMargin:15];
        
        btn.titleLabel.backgroundColor = btn.backgroundColor;
        btn.imageView.backgroundColor = btn.backgroundColor;
        CGSize titleSize = btn.titleLabel.bounds.size;
        CGSize imageSize = btn.imageView.bounds.size;
        CGFloat interval = 8.0;
        //(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0,0, titleSize.height + interval, -(titleSize.width))];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(imageSize.height + interval, -(imageSize.width), 0, 0)];
    }
    
    //发布
    _vPublishInfo = [[UIView alloc] init];
    _vPublishInfo.backgroundColor = [UIColor clearColor];
    _vPublishInfo.hidden = YES;
    
    _imgPublishState = [[UIImageView alloc] init];
    _imgPublishState.image = [UIImage imageNamed:@"video_record_share_loading_0"];
    
    _labPublishState = [[UILabel alloc] init];
    _labPublishState.text = @"正在上传请稍等";
    _labPublishState.textColor = UIColorFromRGB(0x0ACCAC);
    _labPublishState.font = [UIFont systemFontOfSize:24];
    _labPublishState.backgroundColor =[UIColor clearColor];
    _labPublishState.textAlignment = NSTextAlignmentCenter;
    
    _labRecordVideo = [[UILabel alloc] init];
    _labRecordVideo.text = @"";
    _labRecordVideo.textColor = UIColorFromRGB(0x0ACCAC);
    _labRecordVideo.font = [UIFont systemFontOfSize:12];
    _labRecordVideo.backgroundColor =[UIColor clearColor];
    _labRecordVideo.numberOfLines = 0;
    _labRecordVideo.lineBreakMode = NSLineBreakByWordWrapping;
    _labRecordVideo.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_vPublishInfo];
    [_vPublishInfo addSubview:_imgPublishState];
    [_vPublishInfo addSubview:_labPublishState];
    [_vPublishInfo addSubview:_labRecordVideo];
    
    
    [_vPublishInfo sizeWith:CGSizeMake(self.view.width, self.view.height - [[UIApplication sharedApplication] statusBarFrame].size.height - self.navigationController.navigationBar.height)];
    [_vPublishInfo alignParentTopWithMargin:[[UIApplication sharedApplication] statusBarFrame].size.height+self.navigationController.navigationBar.height];
    [_vPublishInfo alignParentLeft];
    
    [_imgPublishState setSize:CGSizeMake(50, 50)];
    [_imgPublishState alignParentTopWithMargin:100];
    _imgPublishState.center = CGPointMake(self.view.center.x, _imgPublishState.center.y);
    
    [_labPublishState setSize:CGSizeMake(self.view.width, 24)];
    [_labPublishState alignParentTopWithMargin:175];
    _labPublishState.center = CGPointMake(self.view.center.x, _labPublishState.center.y);
    
    _labRecordVideo.hidden = YES;
    
    [_livePlayer setupVideoWidget:CGRectZero containView:_vVideoPreview insertIndex:0];
}

- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    _playEnable = YES;
    if (_isPublished == NO) {
        [_livePlayer startPlay:_recordResult.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    _playEnable = NO;
    [_livePlayer stopPlay];
}

- (void)closeKeyboard:(UITapGestureRecognizer *)gestureRecognizer
{
    [_txtShareWords resignFirstResponder];
}

- (void)videoPublish
{
    [[TCLoginModel sharedInstance] getVodSign:^(int errCode, NSString *msg, NSDictionary *resultDict){
        if (200 == errCode && resultDict[@"signature"]) {
            _videoPublishParams.signature = resultDict[@"signature"];
            _videoPublishParams.coverPath = [self getCoverPath:_recordResult.coverImage];
            _videoPublishParams.videoPath = _recordResult.videoPath;
            errCode = [_videoPublish publishVideo:_videoPublishParams];
        }else{
            [self toastTip:[NSString stringWithFormat:@"获取签名失败[errcode:%d]", errCode]];
            return;
        }
    
        __weak typeof(self) wkSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    wkSelf.labPublishState.text = @"网络连接断开，视频上传失败";
                    wkSelf.imgPublishState.hidden = YES;
                    wkSelf.isNetWorkErr = YES;
                    break;
                default:
                    break;
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring]; //开启网络监控
        
        if(errCode != 0){
            [self toastTip:[NSString stringWithFormat:@"视频上传失败[errcode:%d]", errCode]];
            return;
        }
        
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.title = @"发布中";
        
        _vPublishInfo.hidden = NO;
        _vShare.hidden = YES;
        
        _labPublishState.text = @"正在发布请稍等";
        _imgPublishState.image = [UIImage imageNamed:@"video_record_share_loading_0"];
        
        [_txtShareWords resignFirstResponder];
        [_livePlayer stopPlay];
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView*)textView
{
    if([textView.text length] == 0){
        _labDefaultWords.hidden = NO;
    }else{
        _labDefaultWords.hidden = YES;
    }
    
    _labLeftWords.text = [NSString stringWithFormat:@"%02ld/500", 500 - (long)[textView.text length]];
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    if (range.location >= 500)
    {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - TXVideoPublishListener
-(void) onPublishProgress:(uint64_t)uploadBytes totalBytes: (uint64_t)totalBytes
{
    long progress = (long)(8 * uploadBytes / totalBytes);
    _imgPublishState.image = [UIImage imageNamed:[NSString stringWithFormat:@"video_record_share_loading_%ld", progress]];
}

-(void) onPublishComplete:(TXPublishResult*)result
{
    if (!result.retCode) {
        _labPublishState.text = @"发布成功啦！";
    } else {
        if (_isNetWorkErr == NO) {
            _labPublishState.text = [NSString stringWithFormat:@"发布失败啦![%d]", result.retCode];
        }
        return;
    }
    
    NSString *title = _txtShareWords.text;
    if (title.length<=0) title = @"小视频";
    NSDictionary* dictParam = @{@"userid" :[TCLoginParam shareInstance].identifier,
                                @"file_id" : result.videoId,
                                @"title":title,
                                @"frontcover":result.coverURL == nil ? @"" : result.coverURL,
                                @"location":@"未知",
                                @"play_url":result.videoURL};
    [[TCLoginModel sharedInstance] uploadUGC:dictParam completion:^(int errCode, NSString *msg, NSDictionary *resultDict)  {
        if (200 == errCode) {
            if (_selectBtnTag >= 0) {
                int  shareIndex[] = {1,2,4,5,0};
                [self shareDataWithPlatform:shareIndex[_selectBtnTag] withFileID:result.videoId];
            }
        } else {
            [self toastTip:[NSString stringWithFormat:@"UploadUGCVideo Failed[%d]", errCode]];
        }
        
        _isPublished = YES;
    }];
    
    _imgPublishState.image = [UIImage imageNamed:@"video_record_success"];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(publishFinished)];
    self.navigationItem.rightBarButtonItems = [NSMutableArray arrayWithObject:btn];
}


- (void)selectShare:(UIButton *)button
{
    for(int i=0; i<_btnShareArry.count; ++i)
    {
        UIButton *btn = [_btnShareArry objectAtIndex:i];
        if (button == btn) {
            continue;
        }
        btn.selected = NO;
    }
    
    if (button.selected == YES) {
        button.selected = NO;
        _selectBtnTag = -1;
    } else {
        button.selected = YES;
        _selectBtnTag = button.tag;
    }
    
}

- (void)shareDataWithPlatform:(UMSocialPlatformType)platformType withFileID:(NSString *)fileId
{
    TCUserInfoData *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    
    // 创建UMSocialMessageObject实例进行分享
    // 分享数据对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    NSString *title = _txtShareWords.text;
    NSString *text = [NSString stringWithFormat:@"%@ 的短视频", profile.nickName ? profile.nickName: profile.identifier];
    if ( [title length] == 0) title = text;
    
    NSString *url = [NSString stringWithFormat:@"%@?userid=%@&type=%@&fileid=%@&ts=%@&sdkappid=%@&acctype=%@",
                     kLivePlayShareAddr,
                     TC_PROTECT_STR([profile.identifier stringByUrlEncoding]),
                     [NSString stringWithFormat:@"%d", 2],
                     TC_PROTECT_STR([fileId stringByUrlEncoding]),
                     [NSString stringWithFormat:@"%d", 2],
                     [[TCUserInfoModel sharedInstance] getUserProfile].appid,
                     [[TCUserInfoModel sharedInstance] getUserProfile].accountType];
    
    
    /* 以下分享类型，开发者可根据需求调用 */
    // 1、纯文本分享
    messageObject.text = text;
    
    // 2、 图片或图文分享
    // 图片分享参数可设置URL、NSData类型
    // 注意：由于iOS系统限制(iOS9+)，非HTTPS的URL图片可能会分享失败
    UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:text thumImage:_recordResult.coverImage];
    [shareObject setShareImage:_recordResult.coverImage];
    
    UMShareWebpageObject *share2Object = [UMShareWebpageObject shareObjectWithTitle:title descr:text thumImage:_recordResult.coverImage];

    share2Object.webpageUrl = url;
    
    //新浪微博有个bug，放在shareObject里面设置url，分享到网页版的微博不显示URL链接，这里在text后面也加上链接
    if (platformType == UMSocialPlatformType_Sina) {
        messageObject.text = [NSString stringWithFormat:@"%@  %@",messageObject.text,share2Object.webpageUrl];
    }else{
        messageObject.shareObject = share2Object;
    }
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        
        
        NSString *message = nil;
        if (!error) {
            message = [NSString stringWithFormat:@"分享成功"];
        } else {
            if (error.code == UMSocialPlatformErrorType_Cancel) {
                message = [NSString stringWithFormat:@"分享取消"];
            } else if (error.code == UMSocialPlatformErrorType_NotInstall) {
                message = [NSString stringWithFormat:@"应用未安装"];
            } else {
                message = [NSString stringWithFormat:@"分享失败，失败原因(Code＝%d)\n",(int)error.code];
            }
            
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];
}


- (void)applicationWillEnterForeground:(NSNotification *)noti
{
    //temporary fix bug
    if ([self.navigationItem.title isEqualToString:@"发布中"])
        return;
    
    if (_isPublished == NO) {

        [_livePlayer startPlay:_recordResult.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
    }
}

- (void)publishFinished
{
    if ([_videoRecorder isMemberOfClass:[TXLivePlayer class]]) {
        [self.navigationController  popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)noti
{
    [_livePlayer stopPlay];
}


#pragma mark TXLivePlayListener
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_END && _playEnable) {
            [_livePlayer stopPlay];
            [_livePlayer startPlay:_recordResult.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
            return;
        }
    });

}

-(void) onNetStatus:(NSDictionary*) param
{
    return;
}


#pragma mark Utils

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
@end
