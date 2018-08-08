//
//  TCBGMCell.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/12.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMCell.h"

@implementation TCBGMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_validView setImage:[UIImage imageNamed:@"confirm_hover"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setFinish:(BOOL) finish{
    [_progressView setVisible:!finish];
    [_validView setVisible:finish];
}

@end
