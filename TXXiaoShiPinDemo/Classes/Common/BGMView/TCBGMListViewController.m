//
//  TCBGMListViewController.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/8.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMListViewController.h"
#import "TCBGMHelper.h"
#import "UIView+CustomAutoLayout.h"
#import "TCBGMCell.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MPMediaPickerController.h>

@interface TCBGMListViewController()<TCBGMHelperListener,TCBGMCellDelegate,MPMediaPickerControllerDelegate>{
    NSMutableDictionary* _progressList;
    NSTimeInterval lastUIFreshTick;
}
@property(nonatomic,strong) NSDictionary* bgmDict;
@property(nonatomic,strong) NSArray* bgmKeys;
@property(nonatomic,strong) TCBGMHelper* bgmHelper;
@property(nonatomic,weak) id<TCBGMControllerListener> bgmListener;
@end


@implementation TCBGMListViewController
{
    TCBGMCell *_BGMCell;
    BOOL      _useLocalMusic;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _progressList = [NSMutableDictionary new];
        _useLocalMusic = NO;
    }
    return self;
}

-(void)setBGMControllerListener:(id<TCBGMControllerListener>) listener{
    _bgmListener = listener;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"选择背景音乐";
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = customBackButton;

    self.tableView.backgroundColor = RGB(25, 29, 38);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TCBGMCell" bundle:nil] forCellReuseIdentifier:@"TCBGMCell"];
}

- (void)goBack
{
    [_bgmListener onBGMControllerPlay:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadBGMList{
    if (_useLocalMusic) {
        [self showMPMediaPickerController];
    }else{
        lastUIFreshTick = [[NSDate date] timeIntervalSince1970]*1000;
        _bgmHelper = [TCBGMHelper sharedInstance];
        [_bgmHelper setDelegate:self];
        NSString* jsonUrl = @"http://bgm-1252463788.cosgz.myqcloud.com/bgm_list.json";
        [_bgmHelper initBGMListWithJsonFile:jsonUrl];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_bgmKeys count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCBGMCell* cell = (TCBGMCell *)[tableView dequeueReusableCellWithIdentifier:@"TCBGMCell"];
    if (!cell) {
        cell = [[TCBGMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCBGMCell"];
    }
    cell.delegate = self;
    TCBGMElement* ele =  _bgmDict[_bgmKeys[indexPath.row]];
    if (ele.localUrl) {
        [cell setDownloadProgress:1.0];
        cell.progressView.hidden = NO;
    }else{
        cell.progressView.hidden = YES;
        [cell.downLoadBtn setTitle:@"下载" forState:UIControlStateNormal];
    }
    cell.musicLabel.text = ele.name;
    return cell;
}

- (void)onBGMDownLoad:(TCBGMCell *)cell;
{
    _BGMCell = cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:_BGMCell];
    TCBGMElement* ele =  _bgmDict[_bgmKeys[indexPath.row]];
    if([ele isValid] && [[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[ele localUrl]]]){
        [_bgmListener onBGMControllerPlay: [NSHomeDirectory() stringByAppendingPathComponent:[ele localUrl]]];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else [_bgmHelper downloadBGM: _bgmDict[_bgmKeys[indexPath.row]]];
}

-(void) onBGMListLoad:(NSDictionary*)dict{
    BOOL findKeyBGM = NO;
    if(dict){
        BGMLog(@"BGM List 加载成功");
        _bgmDict = dict;
        _bgmKeys = [_bgmDict keysSortedByValueUsingComparator:^(TCBGMElement* e1, TCBGMElement* e2){
            return [[e1 name] compare:[e2 name]];
        }];
        for (NSString* url in _bgmKeys) {
            TCBGMElement* ele = [_bgmDict objectForKey:url];
            if([[ele isValid] boolValue]){
                [_progressList setObject :[NSNumber numberWithFloat:1.f] forKey:url];
            }
            NSRange range = [ele.name rangeOfString:@"青花瓷"];
            if (range.location != NSNotFound) {
                findKeyBGM = YES;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (findKeyBGM) {
            _useLocalMusic = NO;
            [self.tableView reloadData];
        }else{
            _useLocalMusic = YES;
            [self showMPMediaPickerController];
        }
    });
}

-(void) onBGMDownloading:(TCBGMElement*)current percent:(float)percent{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_BGMCell setDownloadProgress:percent];
    });
}

-(void) onBGMDownloadDone:(TCBGMElement*)element{
    if([[element isValid] boolValue]){
        BGMLog(@"Download \"%@\" success!", [element name]);
        [_progressList setObject :[NSNumber numberWithFloat:1.f] forKey:[element netUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        });
        [_bgmListener onBGMControllerPlay: [NSHomeDirectory() stringByAppendingPathComponent:[element localUrl]]];
    }
    else BGMLog(@"Download \"%@\" failed!", [element name]);

}

- (void)showMPMediaPickerController
{
    MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    mpc.delegate = self;
    mpc.editing = YES;
    mpc.allowsPickingMultipleItems = NO;
    [self.navigationController presentViewController:mpc animated:YES completion:nil];
}

#pragma mark - BGM
//选中后调用
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *songItem = [items objectAtIndex:0];
    NSURL *url = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVAsset *songAsset = [AVAsset assetWithURL:url];
    if (songAsset != nil) {
        [_bgmListener onBGMControllerPlay:songAsset];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//点击取消时回调
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_bgmListener onBGMControllerPlay:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
