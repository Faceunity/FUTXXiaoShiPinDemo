//
//  TCCircleProgressView.h
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/12.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TCCircleProgressView: UIView

@property (strong, nonatomic)UIColor *centerColor;
@property (strong, nonatomic)UIColor *arcBackColor;
@property (strong, nonatomic)UIColor *arcFinishColor;
@property (strong, nonatomic)UIColor *arcUnfinishColor;


//百分比数值（0-1）
@property (assign, nonatomic)float percent;

//圆环宽度
@property (assign, nonatomic)float width;

@end
