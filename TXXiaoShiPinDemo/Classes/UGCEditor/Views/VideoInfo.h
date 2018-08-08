//
//  VideoInfo.h
//  TXXiaoShiPinDemo
//
//  Created by xiang zhang on 2017/12/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPasterView.h"
#import "VideoTextFiled.h"
typedef NS_ENUM(NSInteger,PasterInfoType)
{
    PasterInfoType_Animate,
    PasterInfoType_static,
};

@interface VideoInfo : NSObject
@property (nonatomic, assign) CGFloat startTime; //in seconds
@property (nonatomic, assign) CGFloat endTime;   //in seconds
@end

@interface VideoPasterInfo : VideoInfo
@property (nonatomic, assign) PasterInfoType pasterInfoType;
@property (nonatomic, strong) VideoPasterView* pasterView;
@property (nonatomic, strong) UIImage  *iconImage;
//动态贴纸
@property (nonatomic, strong) NSString *path;        //动态贴纸需要文件路径 -> SDK
@property (nonatomic, assign) CGFloat  rotateAngle;  //动态贴纸需要传入旋转角度 -> SDK
//静态贴纸
@property (nonatomic, strong) UIImage  *image;       //静态贴纸需要贴纸Image -> SDK
@end

@interface VideoTextInfo : VideoInfo
@property (nonatomic, strong) VideoTextFiled* textField;
@end
