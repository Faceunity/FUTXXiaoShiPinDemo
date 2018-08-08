//
//  TCLiveListViewController.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLiveListViewController.h"
#import "TCLiveListCell.h"
#import "TCLiveListModel.h"
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking.h>
#import "HUDHelper.h"
#import <MJExtension/MJExtension.h>
#import <BlocksKit/BlocksKit.h>
#import "TCLiveListModel.h"
#import "UIColor+MLPFlatColors.h"
#import "TCVodPlayViewController.h"

@interface TCLiveListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property TCLiveListMgr *liveListMgr;

@property(nonatomic, strong) NSMutableArray *lives;
@property(nonatomic, strong) UICollectionView *collectionView;
@property BOOL isLoading;

@end

@implementation TCLiveListViewController
{
    BOOL             _hasEnterplayVC;
    UIButton         *_ugcVideoBtn;
    UIView           *_scrollView;
    UIView           *_nullDataView;
    CGFloat          scrollViewWidth;
    CGFloat          scrollViewHeight;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lives = [NSMutableArray array];
        _liveListMgr = [TCLiveListMgr sharedMgr];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataAvailable:) name:kTCLiveListNewDataAvailable object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataUpdated:) name:kTCLiveListUpdated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(svrError:) name:kTCLiveListSvrError object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playError:) name:kTCLivePlayError object:nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = UIColorFromRGB(0xF6F2F4);
    self.navigationItem.title = @"点播列表";
    
    CGFloat btnWidth         = 38;
    CGFloat btnHeight        = 24;
    CGFloat statuBarHeight   = [UIApplication sharedApplication].statusBarFrame.size.height;
    scrollViewWidth  = 70;
    scrollViewHeight = 3;

    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0,statuBarHeight,SCREEN_WIDTH, 44)];
    tabView.backgroundColor = [UIColor whiteColor];

    _ugcVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ugcVideoBtn setFrame:CGRectMake(self.view.width / 2 - (btnWidth + 20) / 2 , 11, btnWidth + 20, btnHeight)];
    [_ugcVideoBtn setTitle:@"小视频" forState:UIControlStateNormal];
    [_ugcVideoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _ugcVideoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_ugcVideoBtn addTarget:self action:@selector(videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _scrollView = [[UIView alloc] initWithFrame:CGRectMake(_ugcVideoBtn.left - (scrollViewWidth - _ugcVideoBtn.width)/2, _ugcVideoBtn.bottom + 5, scrollViewWidth, scrollViewHeight)];
    _scrollView.backgroundColor = UIColorFromRGB(0xFF0ACBAB);
    
    UIView *boomView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.bottom, SCREEN_WIDTH, 1)];
    boomView.backgroundColor = UIColorFromRGB(0xD8D8D8);

    [tabView addSubview:_ugcVideoBtn];
    [tabView addSubview:_scrollView];
    [tabView addSubview:boomView];
    
    [self.view addSubview:tabView];
    
    //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,tabView.bottom, SCREEN_WIDTH, self.view.height - tabView.height - statuBarHeight) //style:UITableViewStylePlain];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,tabView.bottom, self.view.width, self.view.height - tabView.bottom) collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.collectionView registerClass:[TCLiveListCell class] forCellWithReuseIdentifier:@"TCLiveListCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    

    CGFloat nullViewWidth   = 90;
    CGFloat nullViewHeight  = 115;
    CGFloat imageViewWidth  = 68;
    CGFloat imageViewHeight = 74;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((nullViewWidth - imageViewWidth)/2, 0, imageViewWidth, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"null_image"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 5, nullViewWidth, 22)];
    label.text = @"暂无内容哦";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
    
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = YES;

    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor whiteColor];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _playVC = nil;
    _hasEnterplayVC = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setup
{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    if(self.lives) [self.lives removeAllObjects];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.isLoading = YES;
        self.lives = [NSMutableArray array];
        [_liveListMgr queryVideoList:GetType_Up];
    }];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.isLoading = YES;
        [_liveListMgr queryVideoList:GetType_Down];
    }];

    // 先加载缓存的数据，然后再开始网络请求，以防用户打开是看到空数据
    [self.liveListMgr loadVodsFromArchive];
    [self doFetchList];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView.mj_header beginRefreshing];
    });
    
    [(MJRefreshHeader *)self.collectionView.mj_header endRefreshingWithCompletionBlock:^{
        self.isLoading = NO;
    }];
    [(MJRefreshHeader *)self.collectionView.mj_footer endRefreshingWithCompletionBlock:^{
        self.isLoading = NO;
    }];
}

-(void)videoBtnClick:(UIButton *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        _scrollView.frame = CGRectMake(_ugcVideoBtn.left - (scrollViewWidth - _ugcVideoBtn.width)/2, _ugcVideoBtn.bottom + 5, scrollViewWidth, scrollViewHeight);
    }];
    [self setup];
}

#pragma mark - UICollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (self.lives.count + 1) / 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.lives.count % 2 != 0 && section == (self.lives.count + 1) / 2 - 1) {
        return 1;
    } else {
        return 2;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveListCell *cell = (TCLiveListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TCLiveListCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TCLiveListCell alloc] initWithFrame:CGRectZero];
    }
    
    NSInteger index = indexPath.section * 2 + indexPath.row;
    if (self.lives.count > index) {
        TCLiveInfo *live = self.lives[index];
        cell.model = live;
    }
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 图片的宽高比为9:16
    CGFloat width = (self.view.width - 1) / 2;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionView delegate

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 此处一定要用cell的数据，live中的对象可能已经清空了
    TCLiveListCell *cell = (TCLiveListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    TCLiveInfo *info = cell.model;
    
    // MARK: 打开播放界面
    if (_playVC == nil) {
        if (self.lives && self.lives.count > 0 && info) {
            _playVC = [[TCVodPlayViewController alloc] initWithPlayInfoS:self.lives liveInfo:info videoIsReady:^{
                if (!_hasEnterplayVC) {
                    [[TCBaseAppDelegate sharedAppDelegate] pushViewController:_playVC animated:YES];
                    _hasEnterplayVC = YES;
                }
            }];
        }
    }
    [self performSelector:@selector(enterPlayVC:) withObject:_playVC afterDelay:0.5];
}

-(void)enterPlayVC:(NSObject *)obj{
    if (!_hasEnterplayVC) {
        [[TCBaseAppDelegate sharedAppDelegate] pushViewController:_playVC animated:YES];
        _hasEnterplayVC = YES;
        
        if (self.listener) {
            [self.listener onEnterPlayViewController];
        }
    }
}

#pragma mark - Net fetch
/**
 * 拉取直播列表。TCLiveListMgr在启动是，会将所有数据下载下来。在未全部下载完前，通过loadLives借口，
 * 能取到部分数据。通过finish接口，判断是否已取到最后的数据
 *
 */
- (void)doFetchList {
    NSRange range = NSMakeRange(self.lives.count, 20);
    BOOL finish;
    NSArray *result = [_liveListMgr readVods:range finish:&finish];
    if (result.count) {
        result = [self mergeResult:result];
        [self.lives addObjectsFromArray:result];
    } else {
        if (finish) {
            MBProgressHUD *hud = [[HUDHelper sharedInstance] tipMessage:@"没有啦"];
            hud.userInteractionEnabled = NO;
        }
    }
    self.collectionView.mj_footer.hidden = finish;
    [self.collectionView reloadData];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    
    if (self.lives.count == 0) {
        _nullDataView.hidden = NO;
    }else{
        _nullDataView.hidden = YES;
    }
}

/**
 *  将取到的数据于已存在的数据进行合并。
 *
 *  @param result 新拉取到的数据
 *
 *  @return 新数据去除已存在记录后，剩余的数据
 */
- (NSArray *)mergeResult:(NSArray *)result {
   
    // 每个直播的播放地址不同，通过其进行去重处理
    NSArray *existArray = [self.lives bk_map:^id(TCLiveInfo *obj) {
        return obj.playurl;
    }];
    NSArray *newArray = [result bk_reject:^BOOL(TCLiveInfo *obj) {
        return [existArray containsObject:obj.playurl];
    }];
    
    return newArray;
}

/**
 *  TCLiveListMgr有新数据过来
 *
 *  @param noti
 */
- (void)newDataAvailable:(NSNotification *)noti {
    [self doFetchList];
}

/**
 *  TCLiveListMgr数据有更新
 *
 *  @param noti
 */
- (void)listDataUpdated:(NSNotification *)noti {
    [self setup];
}


/**
 *  TCLiveListMgr内部出错
 *
 *  @param noti
 */
- (void)svrError:(NSNotification *)noti {
    NSError *e = noti.object;
    if ([e isKindOfClass:[NSError class]]) {
        if ([e localizedFailureReason]) {
            [HUDHelper alert:[e localizedFailureReason]];
        }
        else if ([e localizedDescription]) {
            [HUDHelper alert:[e localizedDescription]];
        }
    }
    
    // 如果还在加载，停止加载动画
    if (self.isLoading) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        self.isLoading = NO;
    }
}

/**
 *  TCPlayViewController出错，加入房间失败
 *
 */
- (void)playError:(NSNotification *)noti {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.mj_header beginRefreshing];
        //加房间失败后，刷新列表，不需要刷新动画
        self.lives = [NSMutableArray array];
        self.isLoading = YES;
        [_liveListMgr queryVideoList:GetType_Up];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
