//
//  VideoRecordProcessView.h
//  TXLiteAVDemo
//
//  Created by zhangxiang on 2017/9/12.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

static int MAX_RECORD_TIME = 16;
static int MIN_RECORD_TIME = 2;

@interface TCVideoRecordProcessView : UIView

-(void)update:(CGFloat)progress;

-(void)pause;

-(void)prepareDeletePart;

-(void)cancelDelete;

-(void)comfirmDeletePart;

-(void)deleteAllPart;
@end
