//
//  TCUserInfoController.m
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCUserInfoViewController.h"
#import "TCEditUserInfoViewController.h"
#import "TCUserInfoCell.h"
#import "TCUserInfoModel.h"
#import "TCLoginModel.h"
#import "TCConstants.h"
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "SDKHeader.h"

extern BOOL g_bNeedEnterPushSettingView;

@implementation TCUserInfoViewController
{
    UIButton *_loginBtn;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KReloadUserInfoNotification object:nil];
}

/**
 *  用于点击 退出登录 按钮后的回调,用于登录出原界面
 *
 *  @param sender 无意义
 */
- (void)logout:(id)sender
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[TCLoginModel sharedInstance] logout:^{
        [[TCLoginParam shareInstance] clearLocal];
        [app enterLoginUI];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置通知消息,接受到通知后重绘cell,确保更改后的用户资料能同步到用户信息界面
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KReloadUserInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfoOnController:) name:KReloadUserInfoNotification object:nil];
    
    [self initUI];
    return;
}

-(void)initUI
{
    UIView *viewBack=[[UIView alloc] init];
    viewBack.frame = self.view.frame;
    viewBack.backgroundColor= RGB(0x18, 0x1D, 0x27);
    [self.view addSubview:viewBack];
    
    // 初始化需要绘制在tableview上的数据
    __weak typeof(self) ws = self;
    TCUserInfoCellItem *backFaceItem = [[TCUserInfoCellItem alloc] initWith:@"" value:@"" type:TCUserInfo_View action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) {
         [ws onEditUserInfo:menu cell:cell];
        nil; }];
    
    //    TCUserInfoCellItem *setItem = [[TCUserInfoCellItem alloc] initWith:@"编辑个人信息" value:nil type:TCUserInfo_Edit action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) {
    //        [ws onEditUserInfo:menu cell:cell]; } ];
    
    TCUserInfoCellItem *aboutItem = [[TCUserInfoCellItem alloc] initWith:@"关于小视频" value:nil type:TCUserInfo_About action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) { [ws onShowAppVersion:menu cell:cell]; } ];
    
    CGFloat tableHeight = 320;
    CGFloat quitBtnYSpace = 340;
    //    _userInfoUISetArry = [NSMutableArray arrayWithArray:@[backFaceItem,setItem, aboutItem]];
    
    _userInfoUISetArry = [NSMutableArray arrayWithArray:@[backFaceItem,aboutItem]];
    
    //设置tableview属性
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, tableHeight);
    _dataTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [_dataTable setDelegate:self];
    [_dataTable setDataSource:self];
    [_dataTable setScrollEnabled:NO];
    [_dataTable setSeparatorColor:[UIColor clearColor]];
    [self setExtraCellLineHidden:_dataTable];
    [self.view addSubview:_dataTable];
    
    //计算退出登录按钮的位置和显示
    _loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginBtn.frame = CGRectMake(0, quitBtnYSpace, self.view.frame.size.width, 45);
    _loginBtn.backgroundColor = [UIColor whiteColor];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_loginBtn setTitle:@"登录" forState: UIControlStateNormal];
    [_loginBtn setTitleColor:RGB(0xFF,0x58,0x4C) forState:UIControlStateNormal];
    [_loginBtn setBackgroundColor:RGB(0x1F,0x25,0x31)];
    [_loginBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
}

#pragma mark 与view界面相关
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    if([TCLoginParam shareInstance].isExpired){
        [_loginBtn setTitle:@"登录" forState: UIControlStateNormal];
    }else{
        [_loginBtn setTitle:@"退出登录" forState: UIControlStateNormal];
    }
    [_dataTable reloadData];
}
/**
 *  用于接受头像下载成功后通知,因为用户可能因为网络情况下载头像很慢甚至失败数次,导致用户信息页面显示默认头像
 *  当用户头像下载成功后刷新tableview,使得头像信息得以更新
 *  另外如果用户在 编辑个人页面 修改头像或者修改昵称,也会发送通知,通知用户信息界面信息变更
 *
 *  @param notification 无意义
 */
-(void)updateUserInfoOnController:(NSNotification *)notification
{
    [_dataTable reloadData];
}

/**
 *  用于去掉界面上多余的横线
 *
 *  @param tableView 无意义
 */
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_dataTable setTableFooterView:view];
}
#pragma mark 绘制用户信息页面上的tableview
//获取需要绘制的cell数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userInfoUISetArry.count;
}
//获取需要绘制的cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoUISetArry[indexPath.row];
    return [TCUserInfoCellItem heightOf:item];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoUISetArry[indexPath.row];
    TCUserInfoTableViewCell *cell = (TCUserInfoTableViewCell*)[tableView  dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
         cell = [[TCUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell initUserinfoViewCellData:item];
    }
    
    [cell drawRichCell:item];
    return cell;
}
#pragma mark 点击用户信息页面上的tableview的回调
/**
 *  用于点击tableview中的cell后的回调相应
 *
 *  @param tableView tableview变量
 *  @param indexPath cell的某行
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoUISetArry[indexPath.row];
    TCUserInfoTableViewCell *cell = [_dataTable cellForRowAtIndexPath:indexPath];
    if (item.action)
    {
        item.action(item, cell);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
/**
 *  用于显示 编辑个人信息 页面
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)onEditUserInfo:(TCUserInfoCellItem *)menu cell:(TCUserInfoTableViewCell *)cell
{
    //个人信息编辑的逻辑不再维护
//    TCEditUserInfoViewController *vc = [[TCEditUserInfoViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:true];
}
/**
 *  用户显示小直播的版本号信息
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)onShowAppVersion:(TCUserInfoCellItem *)menu cell:(TCUserInfoTableViewCell *)cell
{
    NSString* rtmpSDKVersion = [NSString stringWithFormat:@"RTMP SDK版本号: %@",[TXLiveBase getSDKVersionStr]];
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *info = [NSString stringWithFormat:@"App版本号：%@\n%@", appVersion, rtmpSDKVersion];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"关于小视频" message:info delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alert show];
}

@end
