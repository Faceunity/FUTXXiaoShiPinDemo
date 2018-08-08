//
//  TCVideoTextViewController.h
//  DeviceManageIOSApp
//
//  Created by rushanting on 2017/5/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TXVideoEditer;
@class TCVideoPreview;
@class TCVideoTextFiled;

@interface TCVideoTextInfo : NSObject
@property (nonatomic, strong) TCVideoTextFiled* textField;
@property (nonatomic, assign) CGFloat startTime; //in seconds
@property (nonatomic, assign) CGFloat endTime;
@end


@protocol TCVideoTextViewControllerDelegate <NSObject>

- (void)onSetVideoTextInfosFinish:(NSArray<TCVideoTextInfo*>*)videoTextInfos;

@end

@interface TCVideoTextViewController : UIViewController

@property (nonatomic, weak) id<TCVideoTextViewControllerDelegate> delegate;

- (id)initWithVideoEditer:(TXVideoEditer*)videoEditer previewView:(TCVideoPreview*)previewView startTime:(CGFloat)startTime endTime:(CGFloat)endTime videoTextInfos:(NSArray<TCVideoTextInfo*>*)videoTextInfos;

@end
