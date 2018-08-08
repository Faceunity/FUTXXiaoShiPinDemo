//
//  TCVideoJoinController.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 2017/4/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoJoinViewController.h"
#import "TCVideoEditPrevViewController.h"
#import "TCVideoEditViewController.h"
#import "SDKHeader.h"
#import "TCVideoJoinCell.h"
#import "SDKHeader.h"

static NSString *indetifer = @"TCVideoJoinCell";

@interface TCVideoJoinViewController ()<UITableViewDelegate, UITableViewDataSource , TXVideoJoinerListener>
@property (weak) IBOutlet UITableView *tableView;
@end

@implementation TCVideoJoinViewController
{
    UIView *         _generationView;
    UIProgressView * _generateProgressView;
    NSString *       _videoOutputPath;
    BOOL             _appInbackground;
    TXVideoJoiner  * _videoJoiner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 视频列表
    [_tableView registerNib:[UINib nibWithNibName:@"TCVideoJoinCell" bundle:nil] forCellReuseIdentifier:indetifer];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setEditing:YES animated:YES];
    
    //视频合成相关逻辑
    _reorderVideoList = [NSMutableArray new];
    for (AVAsset *asset in self.videoAssertList) {
        TCVideoJoinCellModel *model = [TCVideoJoinCellModel new];
        model.videoAsset = asset;
        
        TXVideoInfo *info = [TXVideoInfoReader getVideoInfoWithAsset:asset];
        model.cover = info.coverImage;
        model.duration = info.duration;
        model.width = info.width;
        model.height = info.height;

        [_reorderVideoList addObject:model];
    }
    
    _videoOutputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputJoin.mp4"];
    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = [UIView new];
    _videoJoiner = [[TXVideoJoiner alloc] initWithPreview:param];
    _videoJoiner.joinerDelegate = self;
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(goBack)];
    customBackButton.tintColor = RGB(238, 100, 85);
    self.navigationItem.leftBarButtonItem = customBackButton;
    self.navigationItem.title = @"拼接视频";
    
    //监听后台事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAudioSessionEvent:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    /*用作生成时的提示浮层*/
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
    
    UILabel *generationTitleLabel = [UILabel new];
    generationTitleLabel.font = [UIFont systemFontOfSize:14];
    generationTitleLabel.text = @"视频合成中";
    generationTitleLabel.textColor = UIColor.whiteColor;
    generationTitleLabel.textAlignment = NSTextAlignmentCenter;
    generationTitleLabel.frame = CGRectMake(0, _generateProgressView.y - 34, _generationView.width, 14);
    
    UIButton *generateCannelBtn = [UIButton new];
    [generateCannelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    generateCannelBtn.frame = CGRectMake(_generateProgressView.right + 15, generationTitleLabel.bottom + 10, 20, 20);
    [generateCannelBtn addTarget:self action:@selector(onCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_generationView addSubview:generationTitleLabel];
    [_generationView addSubview:_generateProgressView];
    [_generationView addSubview:generateCannelBtn];
    _generateProgressView.progress = 0.f;
    _generationView.hidden = YES;
    [self.view addSubview:_generationView];
    [self.view bringSubviewToFront:_generationView];
}

- (void)goBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillEnterForeground:(NSNotification *)noti
{
    if (_appInbackground){
        _appInbackground = NO;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)noti
{
    if (!_appInbackground) {
        [self onVideoEnterBackground];
        _appInbackground = YES;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)noti
{
    if (_appInbackground){
        _appInbackground = NO;
    }
}

- (void)applicationWillResignActive:(NSNotification *)noti
{
    if (!_appInbackground) {
        [self onVideoEnterBackground];
        _appInbackground = YES;
    }
}

- (void) onAudioSessionEvent: (NSNotification *) notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (!_appInbackground) {
            [self onVideoEnterBackground];
            _appInbackground = YES;
        }
    }
}


- (void)onVideoEnterBackground
{
    [_videoJoiner pausePlay];
    if (_generationView && !_generationView.hidden) {
        _generateProgressView.progress = 0.f;
        _generationView.hidden = YES;
        [_videoJoiner cancelJoin];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频合成失败"
                                                            message:@"中途切后台导致,请重新合成"
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"视频将按照列表顺序进行合成，您可以拖动进行片段顺序调整。";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reorderVideoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCVideoJoinCell *cell = [tableView dequeueReusableCellWithIdentifier:indetifer];
    cell.model = self.reorderVideoList[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *toMove = [self.reorderVideoList objectAtIndex:sourceIndexPath.row];
    [self.reorderVideoList removeObjectAtIndex:sourceIndexPath.row];
    [self.reorderVideoList insertObject:toMove atIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.reorderVideoList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

- (IBAction)preview:(id)sender {
    if (self.reorderVideoList.count < 1)
        return;
    _generationView.hidden= NO;
    
    NSMutableArray *videoAssetList = [NSMutableArray array];
    for (TCVideoJoinCellModel *model in _reorderVideoList) {
        [videoAssetList addObject:model.videoAsset];
    }
    [_videoJoiner setVideoAssetList:videoAssetList];
    [_videoJoiner joinVideo:VIDEO_COMPRESSED_720P videoOutputPath:_videoOutputPath];
}

-(void)onCancelBtnClicked:(UIButton *)button
{
    [_videoJoiner cancelJoin];
    _generateProgressView.progress = 0.f;
    _generationView.hidden = YES;
}

#pragma mark TXVideoJoinerListener
-(void) onJoinProgress:(float)progress
{
    _generateProgressView.progress = progress;
}

-(void) onJoinComplete:(TXJoinerResult *)result
{
    if (result.retCode == JOINER_RESULT_OK) {
        TCVideoEditViewController *vc = [[TCVideoEditViewController alloc] init];
        vc.videoPath = _videoOutputPath;
        [self.navigationController pushViewController:vc animated:YES];
        _generationView.hidden = YES;
    }
    [TCUtil report:xiaoshipin_videojoiner userName:nil code:result.retCode msg:result.descMsg];
}

@end
