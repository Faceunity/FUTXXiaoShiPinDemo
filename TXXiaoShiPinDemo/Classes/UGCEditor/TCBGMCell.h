//
//  TCBGMCell.h
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/12.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCircleProgressView.h"


@interface TCBGMCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet TCCircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *validView;
-(void) setFinish:(BOOL) finish;
@end
