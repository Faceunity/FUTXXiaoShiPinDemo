//
//  TCBGMListViewController.h
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/8.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCBGMControllerListener <NSObject>
-(void) onBGMControllerPlay:(NSString*) path;
@end

@interface TCBGMListViewController : UITableViewController
-(void)setBGMControllerListener:(id<TCBGMControllerListener>) listener;
-(void)loadBGMList;
@end
