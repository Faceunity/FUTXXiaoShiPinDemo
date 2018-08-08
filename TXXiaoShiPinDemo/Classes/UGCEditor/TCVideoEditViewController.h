//
//  TCVideoEditViewController.h
//  TCLVBIMDemo
//
//  Created by xiang zhang on 2017/4/10.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCVideoEditViewController : UIViewController

@property (strong,nonatomic) NSString *videoPath;

@property (strong,nonatomic) AVAsset  *videoAsset;

//从剪切过来
@property (assign,nonatomic) BOOL     isFromCut;

//从合唱过来
@property (assign,nonatomic) BOOL     isFromChorus;
@end
