//
//  TCVideoCutViewController.h
//  TXXiaoShiPinDemo
//
//  Created by xiang zhang on 2017/12/7.
//  Copyright © 2017年 tencent. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface TCVideoCutViewController : UIViewController

@property (strong,nonatomic) NSString *videoPath;

@property (strong,nonatomic) AVAsset  *videoAsset;

@property (strong,nonatomic) NSArray  *imageList;

@end

