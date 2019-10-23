//
//  VideoRecordProcessView.h
//  TXLiteAVDemo
//
//  Created by zhangxiang on 2017/9/12.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat MAX_RECORD_TIME = 16.0;
static CGFloat MIN_RECORD_TIME = 2.0;

@interface TCVideoRecordProcessView : UIView
@property (assign, nonatomic) BOOL minimumTimeTipHidden;
-(void)update:(CGFloat)progress;

-(void)pause;

-(void)pauseAtTime:(CGFloat)time;

-(void)prepareDeletePart;

-(void)cancelDelete;

-(void)comfirmDeletePart;

-(void)deleteAllPart;
@end
