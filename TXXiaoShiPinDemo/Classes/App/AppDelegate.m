//
//  AppDelegate.m
//  TCLVBIMDemo
//
//  Created by kuenzhang on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import  "AppDelegate.h"
#import "TCMainTabViewController.h"
#import "TCLoginViewController.h"
#import "TCLog.h"
#import "TCConstants.h"
#import <Bugly/Bugly.h>
#import "TCUserAgreementController.h"
#import <UMSocialCore/UMSocialCore.h>
#import "TCLoginModel.h"

#import "SDKHeader.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
{
    dispatch_source_t _timer;
    uint64_t          _beginTime;
    uint64_t          _endTime;
    TCMainTabViewController *_mainViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initCrashReport];
    _mainViewController = [[TCMainTabViewController alloc] init];

    //这里只是测试使用，客户需要按照官网文档生成正式的URL 和 key值
    [TXUGCBase setLicenceURL:@"" key:@"9bc74ac7bfd07ea392e8fdff2ba5678a"];
    
    //初始化log模块
    [TXLiveBase sharedInstance].delegate = [TCLog shareInstance];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:hasAgreeUserAgreement]) {
        [self confirmEnterMainUI];
    }else{
        [self enterUserAgreementUI];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:isFirstInstallApp]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isFirstInstallApp];
        [TCUtil report:xiaoshipin_install userName:nil code:0 msg:@"小视频安装成功"];
    }
    [TCUtil report:xiaoshipin_startup userName:nil code:0 msg:@"小视频启动成功"];
    
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"57f214fb67e58ecb11003aea"];
    
    // 获取友盟social版本号
    NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //设置微信的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWeiXin_Share_ID appSecret:kWeiXin_Share_Secrect redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置分享到QQ互联的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kQQZone_Share_ID  appSecret:kQQZone_Share_Secrect redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置新浪的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:kSina_WeiBo_Share_ID  appSecret:kSina_WeiBo_Share_Secrect redirectURL:@"http://sns.whalecloud.com/sina2/callback"];

    _beginTime = [[NSDate date] timeIntervalSince1970];
    [[TCLoginModel sharedInstance] refreshLogin];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _endTime = [[NSDate date] timeIntervalSince1970];
    [TCUtil report:xiaoshipin_staytime userName:nil code:_endTime - _beginTime  msg:@"app操作时长"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initCrashReport {
    
    //启动bugly组件，bugly组件为腾讯提供的用于crash上报和分析的开放组件，如果您不需要该组件，可以自行移除
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.version = [TXLiveBase getSDKVersionStr];
#if DEBUG
    config.debugMode = YES;
#endif
    
    config.channel = @"xiaoshipin";
    
    [Bugly startWithAppId:BUGLY_APP_ID config:config];
    
    NSLog(@"rtmp demo init crash report");
    
}

- (CAAnimation *)animationFrom:(UIViewController *)sourceController to:(UIViewController *)targetController {
    if (sourceController == nil) {
        return nil;
    }
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    if ([sourceController isKindOfClass:[UINavigationController class]]) {
        sourceController = [(UINavigationController *)sourceController viewControllers].firstObject;
    }
    if ([sourceController isKindOfClass:[TCUserAgreementController class]]) {
        transition.type = kCATransitionFade;
    } else if ([sourceController isKindOfClass:[TCMainTabViewController class]]) {
        transition.subtype = kCATransitionFromRight;
    } else if ([targetController isKindOfClass:[TCMainTabViewController class]]) {
        transition.subtype = kCATransitionFromLeft;
    }
    return transition;
}

- (void)enterLoginUI {
    TCLoginViewController *loginViewController = [[TCLoginViewController alloc] init];
//  CAAnimation *transition = [self animationFrom:self.window.rootViewController to:loginViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: loginViewController];
//    [self.window makeKeyAndVisible];
//    if (transition) {
//        [self.window.layer addAnimation:transition forKey:@"transition"];
//    }
}

- (void)confirmEnterMainUI{
    CAAnimation *transition = [self animationFrom:self.window.rootViewController to:_mainViewController];
    self.window.rootViewController = _mainViewController;
    [self.window makeKeyAndVisible];
    if (transition) {
        [self.window.layer addAnimation:transition forKey:@"transition"];
    }
}

- (void)enterUserAgreementUI{
    TCUserAgreementController *agreementController = [[TCUserAgreementController alloc] init];
    __weak __typeof(self) weakSelf = self;
    agreementController.agree = ^(BOOL isAgree) {
        if (isAgree) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasAgreeUserAgreement];
            [weakSelf confirmEnterMainUI];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppDelegate.TitleAlert", nil)  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Common.OK", nil) otherButtonTitles:nil, nil];
            [alertView show];
        }
    };
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:agreementController];
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        
    }
    return result;
}


@end

