//
//  TCBGMProgressView.h
//  TXXiaoShiPinDemo
//
//  Created by shengcui on 2018/7/26.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCBGMProgressView : UIView
@property (strong, nonatomic, readonly) UILabel *label;
@property (assign, nonatomic) float progress;
@property (strong, nonatomic) UIColor *progressBackgroundColor;
@end
