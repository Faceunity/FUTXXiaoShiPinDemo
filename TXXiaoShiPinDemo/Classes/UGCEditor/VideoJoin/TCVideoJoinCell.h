//
//  TCVideoJoinCell.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 2017/4/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCVideoJoinCellModel : NSObject
@property NSString *videoPath;
@property AVAsset  *videoAsset;
@property UIImage *cover;
@property int duration;
@property int width;
@property int height;
@end

@interface TCVideoJoinCell : UITableViewCell
@property (nonatomic) TCVideoJoinCellModel *model;

@property (weak) IBOutlet UIImageView *cover;
@property (weak) IBOutlet UILabel *name;
@property (weak) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *resolution;

@end
