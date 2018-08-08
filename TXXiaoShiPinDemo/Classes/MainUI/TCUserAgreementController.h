//
//  TCUserAgreementController.h
//  TCLVBIMDemo
//
//  Created by zhangxiang on 16/9/14.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Agree)(BOOL isAgree);

@interface TCUserAgreementController : UIViewController
@property(nonatomic,strong)Agree agree;
@end
