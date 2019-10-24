//
//  TCBGMCell.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/12.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMCell.h"
#import "UIView+Additions.h"
#import "TCBGMProgressView.h"

@implementation TCBGMCell
{
    CGFloat _progress;
    TCBGMProgressView *_progressView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.downLoadBtn setTitle:NSLocalizedString(@"Common.Download", nil) forState:UIControlStateNormal];
}

-(void) setDownloadProgress:(CGFloat)progress
{
    UIImage *image = [UIImage imageNamed:@"music_select_normal"];

    if (_progressView == nil) {
        _progressView = [[TCBGMProgressView alloc] initWithFrame:_downLoadBtn.bounds];
        _progressView.label.text = NSLocalizedString(@"Common.Downloading", nil);
        _progressView.label.textColor = [UIColor whiteColor];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.progressBackgroundColor = [UIColor colorWithRed:0.21 green:0.22 blue:0.27 alpha:1.00];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_progressView];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_progressView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY 
                                                                    multiplier:1
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_progressView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_downLoadBtn
                                                                     attribute:NSLayoutAttributeHeight 
                                                                    multiplier:1
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_progressView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-8]];
    }
    _progress = progress;
    _progressView.progress = progress;
    if (progress == 1.0) {
        [self.downLoadBtn setTitle:NSLocalizedString(@"Common.Apply", nil) forState:UIControlStateNormal];
        [self.downLoadBtn setBackgroundImage:image forState:UIControlStateNormal];
        
        _progressView.hidden = YES;
    } else {
        [self.downLoadBtn setTitle:NSLocalizedString(@"Common.Download", nil) forState:UIControlStateNormal];
        [self.downLoadBtn setBackgroundImage:[UIImage imageNamed:@"musicDownload"] forState:UIControlStateNormal];
        _progressView.hidden = NO;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.downLoadBtn setTitle:NSLocalizedString(@"Common.Download", nil) forState:UIControlStateNormal];
    [self.downLoadBtn setBackgroundImage:[UIImage imageNamed:@"musicDownload"] forState:UIControlStateNormal];
}

- (IBAction)download:(id)sender {
    [self.delegate onBGMDownLoad:self];
    [_downLoadBtn setTitle:NSLocalizedString(@"Common.Downloading", nil) forState:UIControlStateNormal];
    _downLoadBtn.titleLabel.alpha = 0.5;
}

@end
