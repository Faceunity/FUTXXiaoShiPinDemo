//
//  TCBGMCell.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/12.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMCell.h"
#import "UIView+Additions.h"

@implementation TCBGMCell
{
    UIView *_progressView;
    UIImageView *_imageView;
    UILabel *_label;
    CGFloat _progress;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void) setDownloadProgress:(CGFloat)progress
{
    if (_progressView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:_downLoadBtn.bounds];
        _imageView.image = [UIImage imageNamed:@"music_select_normal"];
        _imageView.userInteractionEnabled = NO;
        _label = [[UILabel alloc] initWithFrame:_downLoadBtn.bounds];
        _label.text = @"下载中";
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:15];
        _label.alpha = 0.5;
        _label.userInteractionEnabled = NO;
        _progressView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.contentMode = UIViewContentModeLeft;
        [_progressView addSubview:_imageView];
        [_progressView addSubview:_label];
        _progressView.layer.masksToBounds = YES;
        _progressView.userInteractionEnabled = NO;
        [self addSubview:_progressView];
        [self bringSubviewToFront:_progressView];
    }
    _progress = progress;
     CGSize size = [UIScreen mainScreen].bounds.size;
    _progressView.frame = CGRectMake(size.width - 85, _downLoadBtn.y, _downLoadBtn.width * _progress, _downLoadBtn.height);
    if (progress == 1.0) {
        _label.text = @"使用";
        _label.alpha = 1.0;
    }
}

- (IBAction)download:(id)sender {
    [self.delegate onBGMDownLoad:self];
    [_downLoadBtn setTitle:@"下载中" forState:UIControlStateNormal];
    _downLoadBtn.titleLabel.alpha = 0.5;
}

@end
