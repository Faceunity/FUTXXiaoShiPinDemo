//
//  TCLoginModel.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef APP_EXT
#import "TCLoginModel.h"
#endif
#import "TCLoginParam.h"
#import <Foundation/Foundation.h>

#define  logoutNotification  @"logoutNotification"

typedef void (^TCRegistSuccess)(NSString* userName, NSString* md5pwd);
typedef void (^TCRegistFail)(int errCode, NSString* errMsg);

typedef void (^TCLoginSuccess)(NSString* userName, NSString* md5pwd ,NSString *token,NSString *refreshToken,NSInteger expires);
typedef void (^TCLoginFail)(NSString* userName,int errCode, NSString* errMsg);

typedef void (^TCLogoutComplete)(void);

@protocol TCLoginListener <NSObject>

/**
 *
 *  @param userinfo 登录成功的用户
 */
- (void)loginOK:(NSString*)userName hashedPwd:(NSString*)pwd token:(NSString *)token refreshToken:(NSString *)refreshToken expires:(NSInteger) expires;
- (void)loginFail:(NSString*)userName code:(int)errCode message:(NSString *)errMsg;
@end

/**
 *  业务server登录
 */
@interface TCLoginModel : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)isAutoLogin;

+ (void)setAutoLogin:(BOOL)autoLogin;

- (void)registerWithUsername:(NSString *)username password:(NSString *)password succ:(TCRegistSuccess)succ fail:(TCRegistFail)fail;

- (void)loginWithUsername:(NSString*)username password:(NSString*)password succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail;
- (void)login:(NSString*)username hashPwd:(NSString*)hashPwd succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail;

- (void)logout:(TCLogoutComplete)completion;

// 获取login传入的login param参数
//- (TIMLoginParam *)getLoginParam;
- (TCLoginParam *)getLoginParam;

- (void)getCosSign:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;
- (void)getVodSign:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;
- (void)uploadUGC:(NSDictionary*)params completion:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;

- (BOOL)validateUserName:(NSString *)username failedReason:(NSString **)reason;
- (BOOL)validatePassword:(NSString *)password failedReason:(NSString **)reason;
@end
