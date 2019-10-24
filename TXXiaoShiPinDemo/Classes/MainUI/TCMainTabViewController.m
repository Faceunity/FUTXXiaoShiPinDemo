//
//  TCMainTabViewController.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCMainTabViewController.h"
#import "TCNavigationController.h"
//#import "TCShowViewController.h"
#import "TCLiveListViewController.h"
#import "UIImage+Additions.h"
#import "TCUserInfoViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "TCVideoRecordViewController.h"
#import "QBImagePickerController.h"
#import "TCVideoLoadingController.h"
#import "TCLoginModel.h"
#import "TCLoginParam.h"
#import "VerticalButton.h"
#import "UIAlertView+BlocksKit.h"

#define BOTTOM_VIEW_HEIGHT              225

@interface TCMainTabViewController ()<UITabBarControllerDelegate, TCLiveListViewControllerListener,
                                    QBImagePickerControllerDelegate>

@property UIButton *liveBtn;
@property (nonatomic) QBImagePickerMediaType mediaType;
@end

@implementation TCMainTabViewController
{
    TCLiveListViewController *_showVC;
    UIView *                 _botttomView;
    MBProgressHUD *          _hub;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
    [self initBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addChildViewMiddleBtn];
    
    //检查有没缓存的视频
    NSArray *cachePathList = [[NSUserDefaults standardUserDefaults] objectForKey:CACHE_PATH_LIST];
    if (cachePathList && cachePathList.count > 0) {
        [UIAlertView bk_showAlertViewWithTitle:@"温馨提示" message:@"你有未录制完成的视频，是否继续？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1){
                //继续录制
                TCVideoRecordViewController *videoRecord = [[TCVideoRecordViewController alloc] initWithNibName:nil bundle:nil];
                videoRecord.preloadingVideos = YES;
                TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:videoRecord];
                [self presentViewController:nav animated:YES completion:nil];
                _botttomView.hidden = YES;
            }else{
                //移除缓存数据
                NSArray *cachePathList = [[NSUserDefaults standardUserDefaults] objectForKey:CACHE_PATH_LIST];
                NSString *cacheFolder = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TXUGC"] stringByAppendingPathComponent:@"TXUGCParts"];
                for (NSInteger i = 0; i < cachePathList.count; i ++) {
                    NSString *videoPath = [cacheFolder stringByAppendingPathComponent:cachePathList[i]];
                    [TCUtil removeCacheFile:videoPath];
                }
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:CACHE_PATH_LIST];
            }
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tabBar invalidateIntrinsicContentSize];
    [self.tabBar bringSubviewToFront:self.liveBtn];
}

- (void)setupViewControllers {
    _showVC = [TCLiveListViewController new];
    _showVC.listener = self;
    UIViewController *_ = [UIViewController new];
    UIViewController *v3 = [TCUserInfoViewController new];
    self.viewControllers = @[_showVC, _, v3];
    
    [self addChildViewController:_showVC imageName:@"video_normal" selectedImageName:@"video_click" title:nil];
    [self addChildViewController:_ imageName:@"" selectedImageName:@"" title:nil];
    [self addChildViewController:v3 imageName:@"User_normal" selectedImageName:@"User_click" title:nil];
    
    self.delegate = self; // this make tabBaController call
    [self setSelectedIndex:0];
}

- (void) initBottomView
{
    UIImage *shadowImage = [UIImage imageNamed:@"tabBarShadow"];
    UIImage *shadowLine = [UIImage imageNamed:@"tabBarShadow_line"];

    CGFloat lineWidth = (SCREEN_WIDTH-shadowImage.size.width)/2.0;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, shadowImage.size.height),NO,0);
    [shadowLine drawInRect:CGRectMake(0, 0, lineWidth, shadowLine.size.height)];
    [shadowImage drawInRect:CGRectMake(lineWidth, 0, shadowImage.size.width, shadowImage.size.height)];
    [shadowLine drawInRect:CGRectMake(lineWidth+shadowImage.size.width, 0, lineWidth, shadowLine.size.height)];

    UIImage *finalShadow = UIGraphicsGetImageFromCurrentImageContext();
    self.tabBar.shadowImage = finalShadow;
    UIGraphicsEndImageContext();

    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:0.15 green:0.17 blue:0.27 alpha:1.00] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [self.tabBar setBackgroundImage: UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();

    CGFloat bottomInset = 0;
    CGFloat topInset = 0;
    if (@available(iOS 11,*)) {
        UIEdgeInsets insets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
        topInset = insets.top;
        bottomInset = insets.bottom;
    }
    CGFloat bottomViewHeight = bottomInset + BOTTOM_VIEW_HEIGHT;
    _botttomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.size.height - bottomViewHeight, self.view.width, bottomViewHeight)];
    _botttomView.backgroundColor = [UIColor blackColor];
    _botttomView.hidden = YES;
    [self.view addSubview:_botttomView];
    CGSize size = _botttomView.frame.size;

    int btnBkgViewHeight = 65;
    int btnSize = 50;//bottomViewHeight - barTopCap;


    UIView * btnBkgView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - btnBkgViewHeight, size.width, btnBkgViewHeight)];
    btnBkgView.backgroundColor = [UIColor blackColor];
    btnBkgView.userInteractionEnabled = YES;
    [_botttomView addSubview:btnBkgView];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [btnBkgView addGestureRecognizer:singleTap];

    UIImageView * imageHidden = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    imageHidden.image = [UIImage imageNamed:@"hidden"];
    imageHidden.center = CGPointMake(self.view.width / 2, btnBkgViewHeight / 2);
    [btnBkgView addSubview:imageHidden];

    UIButton *(^createButton)(NSString *title, NSString *imageName, SEL action) = ^(NSString *title, NSString *imageName, SEL action) {
        UIButton * button = [[VerticalButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[imageName stringByAppendingString:@"_press"]] forState:UIControlStateSelected];
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
        [button sizeToFit];
        button.height = 80;
        return button;
    };

    UIButton * btnVideo = createButton(@"TCMainTabView.Record", @"videoex", @selector(onVideoBtnClicked));
    UIButton * btnChorus = createButton(@"TCMainTabView.Chorus", @"composite", @selector(onVideoChorusSelectClicked));
    UIButton * btnComp = createButton(@"TCMainTabView.EditVideo", @"composite", @selector(onVideoSelectClicked));
    UIButton * btnPic = createButton(@"TCMainTabView.EditImage", @"composite", @selector(onPictureSelectClicked));

    CGFloat centerDiff = self.view.width / 4;
    CGFloat centerX = centerDiff / 2;
    CGFloat centerY = _botttomView.height / 2 - 20;

    btnVideo.center  = CGPointMake(centerX, centerY);
    centerX += centerDiff;
    
    btnChorus.center = CGPointMake(centerX, centerY);
    centerX += centerDiff;
    
    btnComp.center = CGPointMake(centerX, centerY);
    centerX += centerDiff;

    btnPic.center = CGPointMake(centerX, centerY);

    [_botttomView addSubview:btnVideo];
    [_botttomView addSubview:btnComp];
    [_botttomView addSubview:btnPic];
    [_botttomView addSubview:btnChorus];
}

//添加推流按钮
- (void)addChildViewMiddleBtn {
    if (nil == self.liveBtn) {
        self.liveBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [self.tabBar addSubview:btn];
            [btn setImage:[UIImage imageNamed:@"play_normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"play_click"] forState:UIControlStateSelected];
            btn.adjustsImageWhenHighlighted = NO;//去除按钮的按下效果（阴影）
            [btn addTarget:self action:@selector(onLiveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(self.tabBar.frame.size.width/2-60, -6, 120, 120);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 35, 70, 35);
            btn;
        });
    } else {
        UIButton *btn = self.liveBtn;
        btn.frame = CGRectMake(self.tabBar.frame.size.width/2-60, -6, 120, 120);
    }
}

- (void)addChildViewController:(UIViewController *)childController imageName:(NSString *)normalImg selectedImageName:(NSString *)selectImg title:(NSString *)title {
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:childController];
    childController.tabBarItem.image = [[UIImage imageNamed:normalImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [[UIImage imageNamed:selectImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.title = title;

    [self addChildViewController:nav];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)onLiveButtonClicked {
    if(![self loginCheck])return;
    if (_botttomView) {
        [_botttomView removeFromSuperview];
        [self.view addSubview:_botttomView];
        _botttomView.hidden = NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if (_botttomView) {
        _botttomView.hidden = YES;
    }
}

-(BOOL)loginCheck{
    if([TCLoginParam shareInstance].isExpired){
        [[AppDelegate sharedAppDelegate] enterLoginUI];
        return FALSE;
    }
    else return TRUE;
}

-(void)onVideoBtnClicked
{
    TCVideoRecordViewController *videoRecord = [[TCVideoRecordViewController alloc] initWithNibName:nil bundle:nil];
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:videoRecord];
    [self presentViewController:nav animated:YES completion:nil];
    _botttomView.hidden = YES;
}

-(void)onEnterPlayViewController
{
    if (_botttomView) {
        _botttomView.hidden = YES;
    }
}

-(void)onVideoSelectClicked
{
    _mediaType = QBImagePickerMediaTypeVideo;
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = _mediaType;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.showsNumberOfSelectedAssets = YES;
//    imagePickerController.maximumNumberOfSelection = 5;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
    _botttomView.hidden = YES;
}

-(void)onPictureSelectClicked
{
    _mediaType = QBImagePickerMediaTypeImage;
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = _mediaType;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.minimumNumberOfSelection = 3;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
    _botttomView.hidden = YES;
}

-(void)onVideoChorusSelectClicked
{
    if([TCLoginParam shareInstance].isExpired){
        [[AppDelegate sharedAppDelegate] enterLoginUI];
        return;
    }
    [TCUtil report:xiaoshipin_videochorus userName:nil code:0 msg:@"合唱事件"];
    _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hub.mode = MBProgressHUDModeText;
    _hub.label.text = NSLocalizedString(@"TCVodPlay.VideoLoading", nil);
    
    __weak __typeof(self) weakSelf = self;
    NSString *ducumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cachePath = [ducumentPath stringByAppendingPathComponent: @"Chorus.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]){
        [self onloadVideoComplete:cachePath];
    }else{
        [TCUtil downloadVideo:DEFAULT_CHORUS_URL cachePath:cachePath  process:^(CGFloat process) {
            [weakSelf onloadVideoProcess:process];
        } complete:^(NSString *videoPath) {
            [weakSelf onloadVideoComplete:videoPath];
        }];
    }
    _botttomView.hidden = YES;
}

-(void)onloadVideoProcess:(CGFloat)process {
    _hub.label.text = [NSString stringWithFormat:NSLocalizedString(@"TCVodPlay.VideoLoadingFmt", nil),(int)(process * 100)];
}

-(void)onloadVideoComplete:(NSString *)videoPath {
    if (videoPath) {
        TCVideoRecordViewController *vc = [[TCVideoRecordViewController alloc] init];
        vc.videoPath = videoPath;
        vc.savePath = YES;
        [[TCBaseAppDelegate sharedAppDelegate] pushViewController:vc animated:YES];
        [_hub hideAnimated:YES];
    }else{
        _hub.label.text = NSLocalizedString(@"TCVodPlay.VideoLoadFailed", nil);
        [_hub hideAnimated:YES afterDelay:1.0];
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    
    [self dismissViewControllerAnimated:YES completion:^ {
        TCVideoLoadingController *loadvc = [[TCVideoLoadingController alloc] init];
        if (_mediaType == QBImagePickerMediaTypeVideo) {
            loadvc.composeMode = (assets.count > 1);
            [loadvc exportAssetList:assets assetType:AssetType_Video];
        }else{
            loadvc.composeMode = ComposeMode_Edit;
            [loadvc exportAssetList:assets assetType:AssetType_Image];
        }
        TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:loadvc];
        [self presentViewController:nav animated:YES completion:nil];
    }];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
