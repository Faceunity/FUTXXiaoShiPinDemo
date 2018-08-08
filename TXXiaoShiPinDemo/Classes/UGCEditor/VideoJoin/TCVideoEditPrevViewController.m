//
//  TCVideoEditPrevController
//  TCLVBIMDemo
//
//  Created by annidyfeng on 2017/4/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoEditPrevViewController.h"
#import "TCVideoPublishController.h"
#import "SDKHeader.h"
#import <MBProgressHUD/MBProgressHUD.h>

typedef  NS_ENUM(NSInteger,ActionType)
{
    ActionType_Save,
    ActionType_Publish,
    ActionType_Save_Publish,
};

@interface TCVideoEditPrevViewController ()<TXVideoGenerateListener,TXVideoJoinerListener,VideoPreviewDelegate>

@end

@implementation TCVideoEditPrevViewController {
    VideoPreview  *_videoPreview;
    TXVideoJoiner   *_ugcJoin;
    TXVideoEditer   *_ugcEdit;
    CGFloat         _currentPos;
    BOOL            _saveToLocal;
    NSString        *_outFilePath;
    
    ActionType      _actionType;
    
    UILabel*        _generationTitleLabel;
    UIView*         _generationView;
    UIProgressView* _generateProgressView;
    UIButton*       _generateCannelBtn;


}

//- (id)init
//{
//    self = [super initWithNibName:@"Myview" bundle:nil];
//    if (self != nil)
//    {
//        // Further initialization if needed
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#if 0
    _outFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mp4"];
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _outFilePath = [documentsDirectory stringByAppendingPathComponent:@"output.mp4"];
#endif
  
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = customBackButton;
    customBackButton.tintColor = UIColorFromRGB(0x0accac);
    self.navigationItem.title = @"视频预览";
    
    _actionType = -1;
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
        _generateProgressView.progressTintColor = UIColorFromRGB(0x0accac);
        [_generateProgressView setTrackImage:[UIImage imageNamed:@"slide_bar_small"]];

        
        _generationTitleLabel = [UILabel new];
        _generationTitleLabel.font = [UIFont systemFontOfSize:14];
        _generationTitleLabel.text = @"视频合成中";
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

- (void)onCancelBtnClicked:(UIButton*)sender
{
    _generationView.hidden = YES;
    [_ugcJoin cancelJoin];
}

- (void)goBack
{
    [self onVideoPause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _videoPreview = [[VideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.prevPlaceHolder.width, self.prevPlaceHolder.height) coverImage:[TXVideoInfoReader getVideoInfoWithAsset:_composeArray.firstObject].coverImage];
    _videoPreview.delegate = self;
    [self.prevPlaceHolder addSubview:_videoPreview];

    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _videoPreview.renderView;
    param.renderMode =  PREVIEW_RENDER_MODE_FILL_EDGE;

    _ugcJoin = [[TXVideoJoiner alloc] initWithPreview:param];
    [_ugcJoin setVideoAssetList:_composeArray];
    _ugcJoin.previewDelegate = _videoPreview;
    _ugcJoin.joinerDelegate = self;
    [self play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_ugcJoin pausePlay];
}

- (void)play{
    [_ugcJoin startPlay];
    [_videoPreview setPlayBtn:YES];
}


#pragma mark VideoPreviewDelegate
- (void)onVideoPlay
{
    if (_ugcJoin) {
        [_ugcJoin startPlay];
    }else{

    }
}

- (void)onVideoPause
{
    if (_ugcJoin) {
        [_ugcJoin pausePlay];
    }else{
        
    }
}

- (void)onVideoResume
{
    if (_ugcJoin) {
        [_ugcJoin resumePlay];
    } else {
        
    }
}

- (void)onVideoPlayProgress:(CGFloat)time
{
    _currentPos = time;
    
}

- (void)onVideoPlayFinished
{
    [_ugcJoin startPlay];
}

- (void)onVideoEnterBackground
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self onVideoPause];
    
    if (_generationView && !_generationView.hidden) {
        _generationView.hidden = YES;
        [_ugcJoin cancelJoin];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频合成失败"
                                                            message:@"中途切后台导致,请重新合成"
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}



-(void) onJoinComplete:(TXJoinerResult *)result
{
    _generationView.hidden = YES;
    if(result.retCode == 0)
    {
        if (_actionType == ActionType_Save || _actionType == ActionType_Save_Publish) {
            UISaveVideoAtPathToSavedPhotosAlbum(_outFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }else{
            [self performSelector:@selector(video:didFinishSavingWithError:contextInfo:) withObject:nil];
        }
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频合成失败"
                                                            message:[NSString stringWithFormat:@"错误码：%ld 错误信息：%@",(long)result.retCode,result.descMsg]
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void) onJoinProgress:(float)progress {
//    [MBProgressHUD HUDForView:self.view].progress = progress;
    _generateProgressView.progress = progress;
}
// ------

- (IBAction)saveToLocal:(id)sender {
    _actionType = ActionType_Save;
    [self process];
}
- (IBAction)publish:(id)sender {
    _actionType = ActionType_Publish;
    [self process];
}
- (IBAction)saveAndPublish:(id)sender {
    _actionType = ActionType_Save_Publish;
    [self process];
}


- (void)process {
    [_videoPreview setPlayBtn:NO];
    [self onVideoPause];
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"视频生成中...";
    if (_ugcJoin) {
        [_ugcJoin joinVideo:VIDEO_COMPRESSED_540P videoOutputPath:_outFilePath];
    }
    
    // Set the bar determinate mode to show task progress.
//    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    _generationView = [self generatingView];
    _generationView.hidden = NO;
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _generationView.hidden = YES;
    
    if (_actionType == ActionType_Save) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self publish];
}

- (void)publish {
    TCVideoPublishController *vc = [[TCVideoPublishController alloc] initWithPath:_outFilePath
                                                                         videoMsg:[TXVideoInfoReader getVideoInfo:_outFilePath]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
