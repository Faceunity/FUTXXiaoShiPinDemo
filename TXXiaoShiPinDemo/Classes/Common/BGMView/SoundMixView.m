//
//  SoundMixView.m
//  TXXiaoShiPinDemo
//
//  Created by shengcui on 2018/7/23.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import "SoundMixView.h"
#define L(x) NSLocalizedString((x),nil)
static NSString * const CellIdentifier = @"cell";
@interface SoundMixView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *_mixEffectArray;
    NSMutableArray *_audioEffectArray;
}
@property (strong, nonatomic) IBOutlet UICollectionView *voiceCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *mixCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *foiceTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mixTitleLabel;

@end

@implementation SoundMixView
+ (instancetype)instantiateFromNib
{
    UINib *nib = [UINib nibWithNibName:@"SoundMixView" bundle:nil];
    return [nib instantiateWithOwner:nil options:nil].lastObject;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.foiceTitleLabel.text = NSLocalizedString(@"SoundMixView.Foice", nil);
    self.mixTitleLabel.text = NSLocalizedString(@"SoundMixView.Mix", nil);
    [self setupData];

    [self configLayout:self.voiceCollectionView.collectionViewLayout];
    [self configLayout:self.mixCollectionView.collectionViewLayout];
    
    UINib *nib = [UINib nibWithNibName:@"LabelCollectionCell" bundle:nil];
    [self.voiceCollectionView registerNib:nib forCellWithReuseIdentifier:CellIdentifier];
    [self.mixCollectionView registerNib:nib forCellWithReuseIdentifier:CellIdentifier];
    
    self.voiceCollectionView.dataSource = self;
    self.mixCollectionView.dataSource = self;
    
    self.voiceCollectionView.delegate   = self;
    self.mixCollectionView.delegate   = self;

    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.voiceCollectionView selectItemAtIndexPath:firstIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self.mixCollectionView selectItemAtIndexPath:firstIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    
}

- (void)configLayout:(UICollectionViewLayout *)inLayout {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)inLayout;
    CGFloat lineSpacing = [[NSLocale currentLocale].localeIdentifier isEqualToString:@"zh_CN"] ? 12 : 0;
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = 12;
}

- (void)setupData {
    _mixEffectArray = [NSMutableArray arrayWithObjects:L(@"TCVideoRecordMusicView.Origin"), 
                        L(@"TCVideoRecordMusicView.KTV"), 
                        L(@"TCVideoRecordMusicView.Room"), 
                        L(@"TCVideoRecordMusicView.Hall"), 
                        L(@"TCVideoRecordMusicView.Low"), 
                        L(@"TCVideoRecordMusicView.Bright"), 
                        L(@"TCVideoRecordMusicView.Metal"), 
                        L(@"TCVideoRecordMusicView.Magnetic"), 
                        nil];
    _audioEffectArray = [NSMutableArray arrayWithObjects:L(@"TCVideoRecordMusicView.Origin"), 
                         L(@"TCVideoRecordMusicView.Child"), 
                         L(@"TCVideoRecordMusicView.Loli"), 
                         L(@"TCVideoRecordMusicView.Uncle"), 
                         L(@"TCVideoRecordMusicView.HeavyMetal"), 
                         // 感冒去掉了
                         L(@"TCVideoRecordMusicView.Foreigner"), 
                         L(@"TCVideoRecordMusicView.Beast"), 
                         L(@"TCVideoRecordMusicView.Fatty"), 
                         L(@"TCVideoRecordMusicView.StrongCurrent"), 
                         L(@"TCVideoRecordMusicView.HeavyMachinery"), 
                         L(@"TCVideoRecordMusicView.Ethereal"), 
                         nil];
}

- (NSString *)textForView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.voiceCollectionView) {
        return _audioEffectArray[indexPath.item];
    } else if (collectionView == self.mixCollectionView) {
        return _mixEffectArray[indexPath.item];
    }
    return @"";
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    label.text = [self textForView:collectionView indexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    if (collectionView == self.voiceCollectionView) {
        return _audioEffectArray.count;
    } else if (collectionView == self.mixCollectionView) {
        return _mixEffectArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.voiceCollectionView) {
        if ([self.delegate respondsToSelector:@selector(soundMixView:didSelectVoiceChangeIndex:)]) {
            [self.delegate soundMixView:self didSelectVoiceChangeIndex:indexPath.item];
        }
    } else if (collectionView == self.mixCollectionView) {
        if ([self.delegate respondsToSelector:@selector(soundMixView:didSelectMixIndex:)]) {
            [self.delegate soundMixView:self didSelectMixIndex:indexPath.item];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [self textForView:collectionView indexPath:indexPath];
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    size.height = 30;
    if (size.width < 44) {
        size.width = 44;
    }
    return size;
}
@end


