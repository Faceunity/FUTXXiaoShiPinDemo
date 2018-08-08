//
//  TCBGMCell.h
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/12.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCircleProgressView.h"

@class TCBGMCell;

@protocol TCBGMCellDelegate <NSObject>
- (void)onBGMDownLoad:(TCBGMCell *)cell;
@end

@interface TCBGMCell : UITableViewCell
@property (weak, nonatomic) id <TCBGMCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtn;
@property (weak, nonatomic) IBOutlet UILabel *musicLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) UIView *progressView;
-(void) setDownloadProgress:(CGFloat)progress;
@end
