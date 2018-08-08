//
//  TCLivePusherInfo.m
//  TCLVBIMDemo
//
//  Created by lynxzhang on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLiveListCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "TCLiveListModel.h"
#import "UIView+Additions.h"
#import <sys/types.h>
#import <sys/sysctl.h>

@interface TCLiveListCell()
{
    UIImageView *_headImageView;
    UIImageView *_bigPicView;
    UIImageView *_flagView;
    UIImageView *_timeSelectView;
    UILabel     *_titleLabel;
    UILabel     *_nameLabel;
    UILabel     *_locationLabel;
    UILabel     *_timeLable;
    UILabel     *_reviewLabel;
    UIView      *_userMsgView;
    UIView      *_lineView;
    UIImage     *_defaultImage;
    CGRect      _titleRect;
}

@end

@implementation TCLiveListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIForUGC];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutForUGC];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_headImageView sd_setImageWithURL:nil];
    [_bigPicView sd_setImageWithURL:nil];
}

- (void)initUIForUGC {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    self.contentView.backgroundColor = [UIColor clearColor];
    //背景图
    _bigPicView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bigPicView.contentMode = UIViewContentModeScaleAspectFill;
    _bigPicView.clipsToBounds = YES;
    [self.contentView addSubview:_bigPicView];
    
    //左上角的审核状态
    _reviewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_reviewLabel setFont:[UIFont systemFontOfSize:14]];
    [_reviewLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_reviewLabel];
    
    //右上角的时间
    _timeSelectView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _timeSelectView.image = [UIImage imageNamed:@"time"];
    [self.contentView addSubview:_timeSelectView];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectZero];
    [_timeLable setFont:[UIFont systemFontOfSize:12]];
    [_timeLable setTextColor:UIColorFromRGB(0xFFFFFF)];
    [_timeLable setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_timeLable];
    
    //用户信息
    _userMsgView = [[UIView alloc] initWithFrame:CGRectZero];
    _userMsgView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_userMsgView];
    
    //头像
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_userMsgView addSubview:_headImageView];
    
    //用户名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_userMsgView addSubview:_nameLabel];
    
    if (_defaultImage == nil) {
        _defaultImage = [self scaleClipImage:[UIImage imageNamed:@"bg.jpg"] clipW: [UIScreen mainScreen].bounds.size.width * 2 clipH:274 * 2 ];
    }
}


- (void)layoutForUGC {
    //背景图
    _bigPicView.frame = CGRectMake(0 , 0.5, self.width, self.height - 1);
    
    //左上角的审核状态
    _reviewLabel.frame = CGRectMake(14, 5, 62, 20);

    //右上角的时间
    _timeSelectView.frame = CGRectMake(self.width - 67, 5, 62, 20);
    _timeLable.frame = _timeSelectView.frame;
    
    //用户信息
    _userMsgView.frame = CGRectMake(0, _bigPicView.bottom - 50, self.width, 50);
    
    //line
    _lineView.frame = CGRectMake(0, _userMsgView.height - 1, _userMsgView.width, 1);
    
    //头像
    _headImageView.frame = CGRectMake(14, 7.5, 35, 35);
    _headImageView.layer.cornerRadius  = _headImageView.height * 0.5;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderWidth   = 1;
    _headImageView.layer.borderColor   = kClearColor.CGColor;
    
    //用户名
    _nameLabel.frame = CGRectMake(_headImageView.right + 12, 18, self.width - _headImageView.right - 12, 14);
}

- (void)setModel:(TCLiveInfo *)model {
    _model = model;
    
    NSStringCheck(_model.userinfo.headpic);
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:_model.userinfo.headpic]]
                      placeholderImage:[UIImage imageNamed:@"face"]];
    
    if (_reviewLabel){
        if (_model.reviewStatus == 0) {
            _reviewLabel.text = @"未审核";
        }
        else if(_model.reviewStatus == 1){
            _reviewLabel.text = @"已审核";
        }
        else if(_model.reviewStatus == 2){
            _reviewLabel.text = @"涉黄";
        }
    }
    
    NSStringCheck(_model.title);
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:_model.title];
    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, title.length)];
    _titleRect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (_titleLabel) _titleLabel.attributedText = title;
   
    
    NSMutableString* name = [[NSMutableString alloc] initWithString:@""];
 
    NSStringCheck(_model.userinfo.nickname);
    if (0 == _model.userinfo.nickname.length) {
        [name appendString:_model.userid];
    }
    else {
        [name appendString:_model.userinfo.nickname];
    }
    if (_nameLabel) _nameLabel.text = name;
    if (_locationLabel) _locationLabel.text = _model.userinfo.location;
    
    //self.locationImageView.hidden = NO;
    if (_locationLabel && _locationLabel.text.length == 0) {
        _locationLabel.text = @"不显示地理位置";
    }
    
    __weak typeof(_bigPicView) weakPicView =  _bigPicView;
    [_bigPicView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:model.userinfo.frontcover]] placeholderImage:_defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        UIImage *newImage = [self scaleClipImage:image clipW:_bigPicView.width clipH:_bigPicView.height];
        if (image != nil) {
            weakPicView.image = image;
            model.userinfo.frontcoverImage = image;
        }
    }];
    
    if (_flagView) {
        _flagView.image = [UIImage imageNamed:@"playback"];
    }
    
    if (_timeLable) {
        [self setTimeLable:_model.timestamp];
    }
    
    [self layoutForUGC];
}

-(TCLiveInfo *)model{
    _model.userinfo.frontcoverImage = _bigPicView.image;
    return _model;
}

-(UIImage *)scaleClipImage:(UIImage *)image clipW:(CGFloat)clipW clipH:(CGFloat)clipH{
    UIImage *newImage = nil;
    if (image != nil) {
        if (image.size.width >=  clipW && image.size.height >= clipH) {
            newImage = [self clipImage:image inRect:CGRectMake((image.size.width - clipW)/2, (image.size.height - clipH)/2, clipW,clipH)];
        }else{
            CGFloat widthRatio = clipW / image.size.width;
            CGFloat heightRatio = clipH / image.size.height;
            CGFloat imageNewHeight = 0;
            CGFloat imageNewWidth = 0;
            UIImage *scaleImage = nil;
            if (widthRatio < heightRatio) {
                imageNewHeight = clipH;
                imageNewWidth = imageNewHeight * image.size.width / image.size.height;
                scaleImage = [self scaleImage:image scaleToSize:CGSizeMake(imageNewWidth, imageNewHeight)];
            }else{
                imageNewWidth = clipW;
                imageNewHeight = imageNewWidth * image.size.height / image.size.width;
                scaleImage = [self scaleImage:image scaleToSize:CGSizeMake(imageNewWidth, imageNewHeight)];
            }
            newImage = [self clipImage:image inRect:CGRectMake((scaleImage.size.width - clipW)/2, (scaleImage.size.height - clipH)/2, clipW,clipH)];
        }
    }
    return newImage;
}

/**
 *缩放图片
 */
-(UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *裁剪图片
 */
-(UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect{
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

- (void)setTimeLable:(int)timestamp {
    NSString *timeStr = @"刚刚";
    if (timestamp == 0) {
        timeStr = @"";
    } else {
        int interval = [[NSDate date] timeIntervalSince1970] - timestamp;
        
        if (interval >= 60 && interval < 3600) {
            timeStr = [[NSString alloc] initWithFormat:@"%d分钟前", interval/60];
        } else if (interval >= 3600 && interval < 60*60*24) {
            timeStr = [[NSString alloc] initWithFormat:@"%d小时前", interval/3600];
        } else if (interval >= 60*60*24 && interval < 60*60*24*365) {
            timeStr = [[NSString alloc] initWithFormat:@"%d天前", interval/3600/24];
        } else if (interval >= 60*60*24*265) {
            timeStr = [[NSString alloc] initWithFormat:@"很久前"];
        }
    }
    _timeLable.text = timeStr;
}

@end
