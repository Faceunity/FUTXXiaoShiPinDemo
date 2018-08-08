//
//  TCVideoTextViewController.m
//  DeviceManageIOSApp
//
//  Created by rushanting on 2017/5/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoTextViewController.h"
#import "TXVideoEditer.h"
#import "TCVideoPreview.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "TCRangeContent.h"
#import "TCTextCollectionCell.h"
#import "TCVideoTextFiled.h"



@implementation TCVideoTextInfo
@end


@interface TCVideoTextViewController () <TCVideoPreviewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, TCRangeContentDelegate, TCVideoTextFieldDelegate>
{
    TCVideoPreview  *_videoPreview;
    TXVideoEditer* _ugcEditer;
    
    TCRangeContent* _videoRangeSlider;
    UISlider*   _progressView;
    UILabel*    _progressedLabel;
    
    UICollectionView* _videoTextCollection;
    
    UIButton*      _playBtn;
    
    CGFloat        _videoStartTime;
    UILabel*       _leftTimeLabel;
    
    CGFloat        _videoEndTime;
    UILabel*       _rightTimeLabel;
    
    CGFloat        _videoDuration;
    UILabel*       _timeLabel;
    
    BOOL            _isVideoPlaying;
    
    NSMutableArray<TCVideoTextInfo*>* _videoTextInfos;
}

@end

@implementation TCVideoTextViewController

- (id)initWithVideoEditer:(TXVideoEditer *)videoEditer previewView:(TCVideoPreview *)previewView startTime:(CGFloat)startTime endTime:(CGFloat)endTime videoTextInfos:(NSArray<TCVideoTextInfo *> *)videoTextInfos
{
    if (self = [super init]) {
        _ugcEditer = videoEditer;
        _videoPreview = previewView;
        _videoPreview.delegate = self;
        _videoStartTime = startTime;
        _videoEndTime = endTime;
        _videoDuration = endTime - startTime;
        
        _videoTextInfos = videoTextInfos.mutableCopy;
        if (!_videoTextInfos) {
            _videoTextInfos = [NSMutableArray new];
        } else {
            for (TCVideoTextInfo* textInfo in _videoTextInfos) {
                textInfo.textField.delegate = self;
            }
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor =  UIColorFromRGB(0x181818);
    self.navigationController.navigationBar.translucent  =  NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)dealloc
{
    NSLog(@"VideoTextViewController dealloc");
}


- (void)initUI
{
    UILabel *barTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    barTitleLabel.backgroundColor = [UIColor clearColor];
    barTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    barTitleLabel.textColor = [UIColor whiteColor];
    barTitleLabel.textAlignment = NSTextAlignmentCenter;
    barTitleLabel.text = @"编辑视频";
    self.navigationItem.titleView = barTitleLabel;;
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(goBack)];
    customBackButton.tintColor = UIColorFromRGB(0x0accac);
    self.navigationItem.leftBarButtonItem = customBackButton;

    self.view.backgroundColor = UIColor.blackColor;
    
    _videoPreview.frame = CGRectMake(0, 0, self.view.width, 432 * kScaleY);
    _videoPreview.delegate = self;
    _videoPreview.backgroundColor = UIColor.darkTextColor;
    
    [_ugcEditer previewAtTime:_videoStartTime];
    [_ugcEditer pausePlay];
    _isVideoPlaying = NO;
   
    [_videoPreview setPlayBtnHidden:YES];
    [self.view addSubview:_videoPreview];
    
    
    UIImage* image = [UIImage imageNamed:@"videotext_play"];
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(15 * kScaleX, _videoPreview.bottom + 30 * kScaleY, image.size.width, image.size.height)];
    [_playBtn setImage:image forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(_videoDuration) / 60, (int)(_videoDuration) % 60];
    _timeLabel.textColor = UIColorFromRGB(0x777777);
    _timeLabel.font = [UIFont systemFontOfSize:14];
    [_timeLabel sizeToFit];
    _timeLabel.center = CGPointMake(self.view.width - 15 * kScaleX - _timeLabel.width / 2, _playBtn.center.y);
    [self.view addSubview:_timeLabel];
    
    UIView* toImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 2)];
    toImageView.backgroundColor = UIColor.lightGrayColor;
    UIImage* coverImage = toImageView.toImage;
    
    toImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    toImageView.backgroundColor = UIColorFromRGB(0x0accac);
    toImageView.layer.cornerRadius = 9;
    UIImage* thumbImage = toImageView.toImage;
    
    TCRangeContentConfig* config = [[TCRangeContentConfig alloc] init];
    config.pinWidth = 18;
    config.borderHeight = 0;
    config.thumbHeight = 20;
    config.leftPinImage = thumbImage;
    config.rightPigImage = thumbImage;
    config.leftCorverImage = coverImage;
    config.rightCoverImage = coverImage;
    
    toImageView = [UIView new];
    toImageView.backgroundColor = UIColorFromRGB(0x0accac);
    toImageView.bounds = CGRectMake(0, 0, _timeLabel.left - _playBtn.right - 15 - config.pinWidth * 2, 2);
    _videoRangeSlider = [[TCRangeContent alloc] initWithImageList:@[toImageView.toImage] config:config];
    _videoRangeSlider.center = CGPointMake(_playBtn.right + 7.5 + _videoRangeSlider.width / 2, _playBtn.center.y);
    _videoRangeSlider.delegate = self;
    _videoRangeSlider.hidden = YES;
    [self.view addSubview:_videoRangeSlider];
    
    _leftTimeLabel = [[UILabel alloc] init];
    _leftTimeLabel.textColor = UIColorFromRGB(0x777777);
    _leftTimeLabel.font = [UIFont systemFontOfSize:10];
    _leftTimeLabel.text = @"0:00";
    _leftTimeLabel.hidden = YES;
    [self.view addSubview:_leftTimeLabel];
    
    _rightTimeLabel = [[UILabel alloc] init];
    _rightTimeLabel.textColor = UIColorFromRGB(0x777777);
    _rightTimeLabel.font = [UIFont systemFontOfSize:10];
    _rightTimeLabel.text = @"0:00";
    _rightTimeLabel.hidden = YES;
    [self.view addSubview:_rightTimeLabel];
    
    _progressView = [UISlider new];
    _progressView.center = _videoRangeSlider.center;
    _progressView.bounds = CGRectMake(0, 0, _videoRangeSlider.width, 20);
    [self.view addSubview:_progressView];
    _progressView.tintColor = UIColorFromRGB(0x0accac);
    [_progressView setThumbImage:thumbImage forState:UIControlStateNormal];
    _progressView.minimumValue = _videoStartTime;
    _progressView.maximumValue = _videoEndTime;
    [_progressView addTarget:self action:@selector(onProgressSlided:) forControlEvents:UIControlEventValueChanged];
    [_progressView addTarget:self action:@selector(onProgressSlideEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    _progressedLabel = [[UILabel alloc] initWithFrame:CGRectMake(_progressView.x, _progressView.y - 12, 30, 10)];
    _progressedLabel.textColor = UIColorFromRGB(0x777777);
    _progressedLabel.text = @"0:00";
    _progressedLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:_progressedLabel];

    
    UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - (40 + 40 * kScaleY) - 65, self.view.width, (40 + 40 * kScaleY))];
    bottomView.backgroundColor = UIColorFromRGB(0x181818);
    [self.view addSubview:bottomView];
    
    UIButton* newTextBtn = [[UIButton alloc] initWithFrame:CGRectMake(17.5 * kScaleX, 20 * kScaleY, 40, 40)];
    [newTextBtn setImage:[UIImage imageNamed:@"text_add"] forState:UIControlStateNormal];
    newTextBtn.backgroundColor = UIColor.clearColor;
    newTextBtn.layer.borderWidth = 1;
    newTextBtn.layer.borderColor = UIColorFromRGB(0x777777).CGColor;
    [newTextBtn addTarget:self action:@selector(onNewTextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:newTextBtn];
    
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _videoTextCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(newTextBtn.right + 10, 20 * kScaleY, self.view.width - 35 - 10, 40) collectionViewLayout:layout];
    _videoTextCollection.delegate = self;
    _videoTextCollection.dataSource = self;
    _videoTextCollection.backgroundColor = UIColor.clearColor;
    _videoTextCollection.allowsMultipleSelection = NO;
    [_videoTextCollection registerClass:[TCTextCollectionCell class] forCellWithReuseIdentifier:@"TCTextCollectionCell"];
    [bottomView addSubview:_videoTextCollection];
}


- (void)setProgressHidden:(BOOL)isHidden
{
    [_playBtn setImage:[UIImage imageNamed:@"videotext_play"] forState:UIControlStateNormal];

    if (isHidden) {
        _progressView.hidden = YES;
        _progressedLabel.hidden = YES;
        _videoRangeSlider.hidden = NO;
        _leftTimeLabel.hidden = NO;
        _rightTimeLabel.hidden = NO;
        [_ugcEditer pausePlay];
        _isVideoPlaying = NO;
        [_ugcEditer previewAtTime:_videoRangeSlider.leftScale * (_videoDuration) + _videoStartTime];
    } else {
        _progressView.hidden = NO;
        _progressedLabel.hidden = NO;
        _videoRangeSlider.hidden = YES;
        _leftTimeLabel.hidden = YES;
        _rightTimeLabel.hidden = YES;
        NSArray* indexPaths = [_videoTextCollection indexPathsForSelectedItems];
        if (indexPaths.count > 0) {
            [_videoTextCollection deselectItemAtIndexPath:indexPaths[0] animated:NO];
        }
        [self showVideoTextInfo:nil];
    }
}

- (TCVideoTextInfo*)getSelectedVideoTextInfo
{
    NSIndexPath* selectedIndexPath = [_videoTextCollection indexPathsForSelectedItems][0];
    if (selectedIndexPath.row < _videoTextInfos.count) {
        return _videoTextInfos[selectedIndexPath.row];
    }
    
    return nil;
}

- (void)showVideoTextInfo:(TCVideoTextInfo*)textInfo
{
    NSMutableArray<TCVideoTextInfo*>* videoTexts = [NSMutableArray new];
    
    for (TCVideoTextInfo* info in _videoTextInfos) {
        info.textField.hidden = YES;
        if (info != textInfo) {
            [videoTexts addObject:info];
        }
    }
    
    if (!textInfo)
        return;
    
    
    textInfo.textField.hidden = NO;
    [_videoPreview addSubview:textInfo.textField];
    
    CGFloat leftX = MAX(0, (textInfo.startTime - _videoStartTime)) / (_videoDuration) * _videoRangeSlider.imageWidth;
    CGFloat rightX = MIN(_videoDuration, (textInfo.endTime - _videoStartTime)) / (_videoDuration) * _videoRangeSlider.imageWidth;
    _videoRangeSlider.leftPinCenterX = leftX + _videoRangeSlider.pinWidth / 2;
    _videoRangeSlider.rightPinCenterX = MAX(_videoRangeSlider.leftPinCenterX + _videoRangeSlider.pinWidth, rightX + _videoRangeSlider.pinWidth * 3 / 2);
    [_videoRangeSlider setNeedsLayout];
    
    _leftTimeLabel.frame = CGRectMake(_videoRangeSlider.x + _videoRangeSlider.leftPinCenterX - _videoRangeSlider.pinWidth / 2, _videoRangeSlider.top - 12, 30, 10);
    _leftTimeLabel.text = [NSString stringWithFormat:@"%.02f", _videoRangeSlider.leftScale *_videoDuration];
    
    _rightTimeLabel.frame = CGRectMake(_videoRangeSlider.x + _videoRangeSlider.rightPinCenterX - _videoRangeSlider.pinWidth / 2, _videoRangeSlider.top - 12, 30, 10);
    _rightTimeLabel.text = [NSString stringWithFormat:@"%.02f", _videoRangeSlider.rightScale *_videoDuration];
    
    [self setVideoSubtitles:videoTexts];
    [self setProgressHidden:YES];
}


- (void)setVideoSubtitles:(NSArray<TCVideoTextInfo*>*)videoTextInfos
{
    NSMutableArray* subtitles = [NSMutableArray new];
    
    //UIImageView* imageView = [UIImageView new];
    //imageView.contentMode = UIViewContentModeCenter;
    //[_videoPreview addSubview:imageView];
    //imageView.backgroundColor = UIColor.redColor;
    
    NSMutableArray<TCVideoTextInfo*>* emptyVideoTexts;
    
    for (TCVideoTextInfo* textInfo in videoTextInfos) {
        if (textInfo.textField.text.length < 1) {
            [emptyVideoTexts addObject:textInfo];
            continue;
        }
        
        TXSubtitle* subtitle = [TXSubtitle new];
        subtitle.titleImage = textInfo.textField.textImage;
        subtitle.frame = [textInfo.textField textFrameOnView:_videoPreview];
        subtitle.startTime = textInfo.startTime;
        subtitle.endTime = textInfo.endTime;
        //imageView.frame = CGRectMake(subtitle.frame.origin.x, subtitle.frame.origin.y, subtitle.frame.size.width, subtitle.frame.size.height);
        //imageView.image = subtitle.titleImage;
        
        [subtitles addObject:subtitle];
    }
    
    [_ugcEditer setSubtitleList:subtitles];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _videoTextInfos.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"TCTextCollectionCell";
    
    TCTextCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    if (indexPath.row < _videoTextInfos.count) {
        TCVideoTextInfo* info = _videoTextInfos[indexPath.row];
        cell.textLabel.text = info.textField.text;
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TCVideoTextInfo* textInfo = [self getSelectedVideoTextInfo];
    [self showVideoTextInfo:textInfo];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(40, 40);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


#pragma mark - UI event Handle

- (void)onPlayBtnClicked:(UIButton*)sender
{
    [self setProgressHidden:NO];
    if (!_isVideoPlaying) {
        [self setVideoSubtitles:_videoTextInfos];
        [_ugcEditer startPlayFromTime:_videoStartTime toTime:_videoEndTime];
        [_playBtn setImage:[UIImage imageNamed:@"videotext_stop"] forState:UIControlStateNormal];
        _isVideoPlaying = YES;
    } else {
        [_ugcEditer pausePlay];
        [_playBtn setImage:[UIImage imageNamed:@"videotext_play"] forState:UIControlStateNormal];
        _isVideoPlaying = NO;
    }
}

- (void)onNewTextBtnClicked:(UIButton*)sender
{
    [self setProgressHidden:YES];
    
    TCVideoTextFiled* videoTextField = [[TCVideoTextFiled alloc] initWithFrame:CGRectMake((_videoPreview.width - 170) / 2, (_videoPreview.height - 50) / 2, 170, 50)];
    videoTextField.delegate = self;
    [_videoPreview addSubview:videoTextField];

    
    
    CGFloat segDuration = (_videoDuration - 0.1) / 10;
    int segIndex = _videoTextInfos.count % 10;
    TCVideoTextInfo* info = [TCVideoTextInfo new];
    info.textField = videoTextField;
    info.startTime = _videoStartTime + segDuration * segIndex;
    info.endTime = info.startTime + segDuration;
    [_videoTextInfos addObject:info];
    
    [_videoTextCollection reloadData];
    [_videoTextCollection performBatchUpdates:nil completion:^(BOOL finished) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_videoTextInfos.count - 1 inSection:0];
        [_videoTextCollection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }];
    
    [self showVideoTextInfo:info];
}

- (void)onProgressSlided:(UISlider*)progressSlider
{
    _progressedLabel.x = _progressView.x + (progressSlider.value - _videoStartTime) / _videoDuration * (_progressView.width - _progressView.currentThumbImage.size.width);
    _progressedLabel.text = [NSString stringWithFormat:@"%.02f", progressSlider.value - _videoStartTime];
    [_ugcEditer previewAtTime:progressSlider.value];

}

- (void)onProgressSlideEnd:(UISlider*)progressSlider
{
//    [_ugcEditer pausePlay];
    [_ugcEditer startPlayFromTime:progressSlider.value toTime:_videoEndTime];
    _isVideoPlaying = YES;
    [_playBtn setImage:[UIImage imageNamed:@"videotext_stop"] forState:UIControlStateNormal];
}

- (void)goBack
{
    [self setVideoSubtitles:_videoTextInfos];
    
    for (TCVideoTextInfo* info in _videoTextInfos) {
        [info.textField resignFirstResponser];
        [info.textField removeFromSuperview];
    }
    
    [_videoPreview removeFromSuperview];
    
    [self.delegate onSetVideoTextInfosFinish:_videoTextInfos];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - VideoTextFieldDelegate
- (void)onTextInputDone:(NSString *)text
{
    NSIndexPath* selectedIndexPath = [_videoTextCollection indexPathsForSelectedItems][0];
    TCTextCollectionCell* selectedCell = (TCTextCollectionCell*)[_videoTextCollection cellForItemAtIndexPath:selectedIndexPath];
    selectedCell.textLabel.text = text;
}

- (void)onRemoveTextField:(TCVideoTextFiled *)textField
{
    TCVideoTextInfo* info = [self getSelectedVideoTextInfo];
    [info.textField resignFirstResponser];
    [_videoTextInfos removeObject:info];
    
    [_videoTextCollection reloadData];
    [self setProgressHidden:NO];
    [self setVideoSubtitles:_videoTextInfos];
}

#pragma mark - RangeContentDelegate
- (void)onRangeLeftChanged:(TCRangeContent *)sender
{
    CGFloat textStartTime =  _videoStartTime + sender.leftScale * (_videoDuration);
    //[_ugcEditer startPlayFromTime:textStartTime toTime:textEndTime];
    [_ugcEditer previewAtTime:textStartTime];
    
    _leftTimeLabel.frame = CGRectMake(_videoRangeSlider.x + _videoRangeSlider.leftPin.x, _videoRangeSlider.top - 12, 30, 10);
    _leftTimeLabel.text = [NSString stringWithFormat:@"%.02f", sender.leftScale * _videoDuration];
}

- (void)onRangeLeftChangeEnded:(TCRangeContent *)sender
{
    
    CGFloat textStartTime =  _videoStartTime + sender.leftScale * (_videoDuration);
    //[_ugcEditer startPlayFromTime:textStartTime toTime:textEndTime];
    [_ugcEditer previewAtTime:textStartTime];
    
    TCVideoTextInfo* textInfo = [self getSelectedVideoTextInfo];
    textInfo.startTime = textStartTime;
}

- (void)onRangeRightChanged:(TCRangeContent *)sender
{
    CGFloat textEndTime =  _videoStartTime+ sender.rightScale * (_videoDuration);
    [_ugcEditer previewAtTime:textEndTime];
    
    _rightTimeLabel.frame = CGRectMake(_videoRangeSlider.x + _videoRangeSlider.rightPin.x, _videoRangeSlider.top - 12, 30, 10);
    _rightTimeLabel.text = [NSString stringWithFormat:@"%.02f", sender.rightScale * _videoDuration];
}

- (void)onRangeRightChangeEnded:(TCRangeContent *)sender
{
    CGFloat textEndTime =  _videoStartTime+ sender.rightScale * (_videoDuration);
    [_ugcEditer previewAtTime:textEndTime];
    
    TCVideoTextInfo* textInfo = [self getSelectedVideoTextInfo];
    textInfo.endTime = textEndTime;
}

#pragma mark - VideoPreviewDelegate
- (void)onVideoPlay
{
    [_ugcEditer startPlayFromTime:_videoStartTime toTime:_videoEndTime];
    [_playBtn setImage:[UIImage imageNamed:@"videotext_stop"] forState:UIControlStateNormal];

    _isVideoPlaying = YES;

}

- (void)onVideoPause
{
    [_ugcEditer pausePlay];
    [_playBtn setImage:[UIImage imageNamed:@"videotext_play"] forState:UIControlStateNormal];
    _isVideoPlaying = NO;

}

- (void)onVideoResume
{
    //[_ugcEditer resumePlay];
    [_ugcEditer startPlayFromTime:_progressView.value toTime:_videoEndTime];
    _isVideoPlaying = YES;

}

- (void)onVideoPlayProgress:(CGFloat)time
{
    _progressView.value = time;
    _progressedLabel.text = [NSString stringWithFormat:@"%.02f", time - _videoStartTime];
    _progressedLabel.x = _progressView.x + (time - _videoStartTime) / _videoDuration * (_progressView.width - _progressView.currentThumbImage.size.width);
}

- (void)onVideoPlayFinished
{
    _isVideoPlaying = NO;
    [self onVideoPlay];
}

- (void)onVideoEnterBackground
{
    if (_isVideoPlaying) {
        [_ugcEditer pausePlay];
        [_playBtn setImage:[UIImage imageNamed:@"videotext_play"] forState:UIControlStateNormal];
        _isVideoPlaying = NO;
    }
}

@end
