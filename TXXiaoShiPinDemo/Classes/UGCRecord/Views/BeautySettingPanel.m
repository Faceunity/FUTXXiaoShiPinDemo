//
//  BeautySettingPanel.m
//  RTMPiOSDemo
//
//  Created by rushanting on 2017/5/5.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "BeautySettingPanel.h"
#import "PituMotionAddress.h"
#import "TextCell.h"
#import "AFNetworking.h"
#if POD_PITU
#import "ZipArchive.h"
#endif
#import "ColorMacro.h"

#define BeautyViewMargin 8
#define BeautyViewSliderHeight 30
#define BeautyViewCollectionHeight 50
#define BeautyViewTitleWidth 40

#define L(x) NSLocalizedString((x), nil)

@interface BeautySettingPanel() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSArray<NSArray *> *_optionsContainer;
    NSMutableDictionary<NSNumber*, NSIndexPath*> *_selectedIndexMap;
    NSDictionary *_motionNameMap;
}
@property (nonatomic, assign) PannelMenuIndex currentMenuIndex;
@property (nonatomic, strong) UICollectionView *menuCollectionView;
@property (nonatomic, strong) UICollectionView *optionsCollectionView;

@property (nonatomic, strong) NSMutableDictionary *beautyValueMap;
@property (nonatomic, strong) UILabel *filterLabel;
@property (nonatomic, strong) UISlider *filterSlider;
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) UISlider *beautySlider;
@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, strong) NSDictionary *motionAddressDic;
@property (nonatomic, strong) NSDictionary *koubeiAddressDic;
@property (nonatomic, strong) NSURLSessionDownloadTask *operation;
@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat whiteLevel;
@property (nonatomic, assign) CGFloat ruddyLevel;
@property (nonatomic, assign) TXVideoBeautyStyle beautyStyle;
@property (nonatomic, strong) NSMutableDictionary* filterMap;

@end

@implementation BeautySettingPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.beautySlider.frame = CGRectMake(BeautyViewMargin * 4, BeautyViewMargin, self.frame.size.width - 10 * BeautyViewMargin - BeautyViewSliderHeight, BeautyViewSliderHeight);
    [self addSubview:self.beautySlider];
    self.beautySlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.beautyLabel.frame = CGRectMake(self.beautySlider.frame.size.width + self.beautySlider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.beautyLabel.layer.cornerRadius = self.beautyLabel.frame.size.width / 2;
    self.beautyLabel.layer.masksToBounds = YES;
    [self addSubview:self.beautyLabel];
    self.beautyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    self.filterSlider.frame = CGRectMake(BeautyViewMargin * 4, BeautyViewMargin, self.frame.size.width - 10 * BeautyViewMargin - BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.filterSlider.hidden = YES;
    [self addSubview:self.filterSlider];
    self.filterSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.filterLabel.frame = CGRectMake(self.filterSlider.frame.size.width + self.filterSlider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.filterLabel.layer.cornerRadius = self.filterLabel.frame.size.width / 2;
    self.filterLabel.layer.masksToBounds = YES;
    self.filterLabel.hidden = YES;
    [self addSubview:self.filterLabel];
    self.filterLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    _menuArray = @[/*L(@"BeautySettingPanel.FunctionArray1"),*/
                   /*L(@"BeautySettingPanel.FunctionArray2"),*/
                   L(@"BeautySettingPanel.FunctionArray3"),
                   L(@"BeautySettingPanel.FunctionArray4"),
                   L(@"BeautySettingPanel.FunctionArray5"),
                   L(@"BeautySettingPanel.FunctionArray6"),
                   L(@"BeautySettingPanel.FunctionArray7")];

    NSArray *effectArray = @[L(@"BeautySettingPanel.EffectArray1"),
                             L(@"BeautySettingPanel.EffectArray2"),
                             L(@"BeautySettingPanel.EffectArray3"),
                             L(@"BeautySettingPanel.EffectArray4"),
                             L(@"BeautySettingPanel.EffectArray5"),
                             L(@"BeautySettingPanel.EffectArray6"),
                             L(@"BeautySettingPanel.EffectArray7"),
                             L(@"BeautySettingPanel.EffectArray8"),
                             L(@"BeautySettingPanel.EffectArray9"),
                             L(@"BeautySettingPanel.EffectArray10"),
                             L(@"BeautySettingPanel.EffectArray11"),
                             L(@"BeautySettingPanel.EffectArray12"),
                             L(@"BeautySettingPanel.EffectArray13"),
                             L(@"BeautySettingPanel.EffectArray14"),
                             L(@"BeautySettingPanel.EffectArray15"),
                             L(@"BeautySettingPanel.EffectArray16"),
                             L(@"BeautySettingPanel.EffectArray17"),
                             L(@"BeautySettingPanel.EffectArray18")];

    NSArray *beautyArray = @[L(@"BeautySettingPanel.BeautyArray1"),
                             L(@"BeautySettingPanel.Beauty-Natural"),
                             L(@"BeautySettingPanel.Beauty-P"),
                             L(@"BeautySettingPanel.BeautyArray2"), 
                             L(@"BeautySettingPanel.BeautyArray3"),
                             L(@"BeautySettingPanel.BeautyArray4"),
                             L(@"BeautySettingPanel.BeautyArray5"),
                             L(@"BeautySettingPanel.BeautyArray6"),
                             L(@"BeautySettingPanel.BeautyArray7"),
                             L(@"BeautySettingPanel.BeautyArray8"),
                             L(@"BeautySettingPanel.BeautyArray9")];
//    NSArray *beautyStyleArray = @[L(@"BeautySettingPanel.BeautyTypeArray1"),
//                                  L(@"BeautySettingPanel.BeautyTypeArray2"),
//                                  L(@"BeautySettingPanel.BeautyTypeArray3")];
    
    NSArray *motionArray = @[L(@"BeautySettingPanel.None"), @"video_boom" , @"video_nihongshu",    @"video_3DFace_dogglasses2",
                             @"video_fengkuangdacall", @"video_Qxingzuo_iOS", @"video_caidai_iOS",
                             @"video_liuhaifadai",     @"video_rainbow",      @"video_purplecat",
                             @"video_huaxianzi",       @"video_baby_agetest"];
    
    _motionAddressDic = NSDictionaryOfVariableBindings(video_3DFace_dogglasses2, video_baby_agetest, video_caidai_iOS, video_huaxianzi,
                                                        video_liuhaifadai, video_nihongshu, video_rainbow, video_boom, video_fengkuangdacall,
                                                        video_purplecat, video_Qxingzuo_iOS);
    
    NSArray *koubeiArray = @[L(@"BeautySettingPanel.None"), @"video_xiaofu"];
    _koubeiAddressDic = NSDictionaryOfVariableBindings(video_xiaofu);
    
    NSArray *greenArray = @[L(@"BeautySettingPanel.EffectArray1"), @"goodluck"];
    
    _optionsContainer = @[ beautyArray, effectArray, motionArray, koubeiArray, greenArray];
    _selectedIndexMap = [NSMutableDictionary dictionaryWithCapacity:_optionsContainer.count];
    
    self.optionsCollectionView.frame = CGRectMake(0, self.beautySlider.frame.size.height + self.beautySlider.frame.origin.y + BeautyViewMargin, self.frame.size.width, BeautyViewSliderHeight * 2 + 2 * BeautyViewMargin);
    self.optionsCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.optionsCollectionView];
    
    self.menuCollectionView.frame = CGRectMake(0, self.optionsCollectionView.frame.size.height + self.optionsCollectionView.frame.origin.y, self.frame.size.width, BeautyViewCollectionHeight);
    self.menuCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.menuCollectionView];
}

#pragma mark - collection
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.menuCollectionView) {
        return self.menuArray.count;
    }
    return [_optionsContainer[_currentMenuIndex] count];
}

- (NSIndexPath *)selectedIndexPath {
    return [self selectedIndexPathForMenu:_currentMenuIndex];
}

- (NSIndexPath *)selectedIndexPathForMenu:(PannelMenuIndex)index {
    return _selectedIndexMap[@(index)] ?: [NSIndexPath indexPathForItem:0 inSection:0];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedIndexPath:indexPath forMenu:_currentMenuIndex];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath forMenu:(PannelMenuIndex)menuIndex {
    _selectedIndexMap[@(menuIndex)] = indexPath;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == _menuCollectionView){
        TextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.font = [UIFont systemFontOfSize: [UIFont buttonFontSize]];
        cell.label.text = self.menuArray[indexPath.row];
        cell.selected = indexPath.row == _currentMenuIndex;
        return cell;
    } else {
        TextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.font = [UIFont systemFontOfSize: [UIFont buttonFontSize]];
        NSString *text = [self textAtIndex:indexPath.row inMenu:_currentMenuIndex];
        cell.label.text = text;
        cell.selected = [indexPath isEqual: [self selectedIndexPath]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TextCell *cell = (TextCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];

    if(collectionView == _menuCollectionView){
        if(indexPath.row != _currentMenuIndex){
            [self changeFunction:indexPath.row];
            //            if([self.delegate respondsToSelector:@selector(reset:)]){
            //                [self.delegate reset:(indexPath.row == 0? YES : NO)];
            //            }
        }
    } else {
        // select options
        NSIndexPath *prevSelectedIndexPath = [self selectedIndexPath];
        [collectionView cellForItemAtIndexPath:prevSelectedIndexPath].selected = NO;

        if([indexPath isEqual:prevSelectedIndexPath]){
            // 和上次选的一样
            return;
        }

        [self setSelectedIndexPath:indexPath];
        switch (_currentMenuIndex) {
            case PannelMenuIndexBeauty: {
                float value = [[self.beautyValueMap objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
                
                if (indexPath.row < 3) {
                    self.beautyStyle = indexPath.item;
                    _beautyLevel = value;
                }
                
                if(indexPath.row == 8){
                    //下巴
                    self.beautySlider.minimumValue = -10;
                    self.beautySlider.maximumValue = 10;
                } else {
                    self.beautySlider.minimumValue = 0;
                    self.beautySlider.maximumValue = 10;
                }
                self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)value];
                [self.beautySlider setValue:value];
                [self _applyBeautySettings];
            } break;
            case PannelMenuIndexEffect: {
                [self onSetEffectWithIndex:indexPath.row];
                NSNumber* value = [self.filterMap objectForKey:@(indexPath.row)];
                [self.filterSlider setValue:value.floatValue];
                [self onValueChanged:self.filterSlider];
            }
                break;
            case PannelMenuIndexMotion:
                [self onSetMotionWithIndex:indexPath.row];
                break;
            case PannelMenuIndexKoubei:
                [self onSetKoubeiWithIndex:indexPath.row];
                break;
            case PannelMenuIndexGreen:
                [self onSetGreenWithIndex:indexPath.row];
                break;
                
            default:
                break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = nil;
    if(collectionView == _menuCollectionView){
        text = self.menuArray[indexPath.row];
    } else {
        text = [self textAtIndex:indexPath.row inMenu:_currentMenuIndex];;
    }
    
    UIFont *font = [UIFont systemFontOfSize: [UIFont buttonFontSize]];
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize size=[text sizeWithAttributes:attrs];
    return CGSizeMake(size.width + 2 * BeautyViewMargin, collectionView.frame.size.height);
}

#pragma mark - layout

- (void)changeFunction:(PannelMenuIndex)index
{
    self.beautyLabel.hidden  = index != PannelMenuIndexBeauty;
    self.beautySlider.hidden = self.beautyLabel.hidden;
    
    self.filterLabel.hidden  = index != PannelMenuIndexEffect;
    self.filterSlider.hidden = self.filterLabel.hidden;

    NSAssert(index < _optionsContainer.count, @"index out of range");
    [self.menuCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentMenuIndex inSection:0]].selected = NO;
    _currentMenuIndex = index;
    [self.optionsCollectionView reloadData];
}

- (void)_applyBeautySettings {
    if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
        [self.delegate onSetBeautyStyle:self.beautyStyle beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
    }
}

#pragma mark - value changed
- (void)onValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    float value = slider.value;
    if(slider == self.filterSlider){
        [self.filterMap setObject:[NSNumber numberWithFloat:self.filterSlider.value] forKey:[NSNumber numberWithInteger:[self selectedIndexPath].row]];

        self.filterLabel.text = [NSString stringWithFormat:@"%d",(int)self.filterSlider.value];
        if([self.delegate respondsToSelector:@selector(onSetMixLevel:)]){
            [self.delegate onSetMixLevel:self.filterSlider.value];
        }
    } else {
        // 判断选择了哪个二级菜单
        int beautyIndex = (int)[self selectedIndexPathForMenu:PannelMenuIndexBeauty].row;
        
        [self.beautyValueMap setObject:[NSNumber numberWithFloat:self.beautySlider.value] forKey:@(beautyIndex)];
        self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)self.beautySlider.value];
        
        if(beautyIndex < 5) {
            if (beautyIndex < 3) {
                _beautyLevel = slider.value;
            } else if (beautyIndex == 3) {
                _whiteLevel = value;
            } else if (beautyIndex == 4) {
                _ruddyLevel = value;
            }
            [self _applyBeautySettings];
        } 
        
        if(beautyIndex == 5) {
            if([self.delegate respondsToSelector:@selector(onSetEyeScaleLevel:)]){
                [self.delegate onSetEyeScaleLevel:value];
            }
        }
        else if(beautyIndex == 6){
            if([self.delegate respondsToSelector:@selector(onSetFaceScaleLevel:)]){
                [self.delegate onSetFaceScaleLevel:value];
            }
        }
        //        else if(beautyIndex == 5){
        //            if([self.delegate respondsToSelector:@selector(onSetFaceBeautyLevel:)]){
        //                [self.delegate onSetFaceBeautyLevel:self.beautySlider.value];
        //            }
        //        }
        else if(beautyIndex == 7){
            if([self.delegate respondsToSelector:@selector(onSetFaceVLevel:)]){
                [self.delegate onSetFaceVLevel:value];
            }
        }
        else if(beautyIndex == 8){
            if([self.delegate respondsToSelector:@selector(onSetChinLevel:)]){
                [self.delegate onSetChinLevel:value];
            }
        }
        else if(beautyIndex == 9){
            if([self.delegate respondsToSelector:@selector(onSetFaceShortLevel:)]){
                [self.delegate onSetFaceShortLevel:value];
            }
        }
        else if(beautyIndex == 10){
            if([self.delegate respondsToSelector:@selector(onSetNoseSlimLevel:)]){
                [self.delegate onSetNoseSlimLevel:value];
            }
        }
    }
}

- (void)onSetEffectWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSetFilter:)]) {
        UIImage* image = [self filterImageByIndex:index];
        [self.delegate onSetFilter:image];
    }
}

- (UIImage*)filterImageByIndex:(NSInteger)index
{
    NSString* lookupFileName = @"";
    if (index < 0)
        index = _optionsContainer[1].count - 1;
    if (index > _optionsContainer[1].count - 1)
        index = 0;
    
    switch (index) {
        case 0:
            break;
        case 1:
            lookupFileName = @"biaozhun.png";
            break;
        case 2:
            lookupFileName = @"yinghong.png";
            break;
        case 3:
            lookupFileName = @"yunshang.png";
            break;
        case 4:
            lookupFileName = @"chunzhen.png";
            break;
        case 5:
            lookupFileName = @"bailan.png";
            break;
        case 6:
            lookupFileName = @"yuanqi.png";
            break;
        case 7:
            lookupFileName = @"chaotuo.png";
            break;
        case 8:
            lookupFileName = @"xiangfen.png";
            break;
        case 9:
            lookupFileName = @"white.png";
            break;
        case 10:
            lookupFileName = @"langman.png";
            break;
        case 11:
            lookupFileName = @"qingxin.png";
            break;
        case 12:
            lookupFileName = @"weimei.png";
            break;
        case 13:
            lookupFileName = @"fennen.png";
            break;
        case 14:
            lookupFileName = @"huaijiu.png";
            break;
        case 15:
            lookupFileName = @"landiao.png";
            break;
        case 16:
            lookupFileName = @"qingliang.png";
            break;
        case 17:
            lookupFileName = @"rixi.png";
            break;
        default:
            break;
    }
    NSString * path = [[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"];
    if (path != nil && index != FilterType_None) {
        path = [path stringByAppendingPathComponent:lookupFileName];
        return [UIImage imageWithContentsOfFile:path];
    }
    
    return nil;
}

- (NSInteger)currentFilterIndex
{
    return _selectedIndexMap[@(1)].row;
}

- (NSString*)currentFilterName
{
    NSInteger index = self.currentFilterIndex;
    return _optionsContainer[1][index];
}

- (void)setCurrentFilterIndex:(NSInteger)currentFilterIndex
{
    if (currentFilterIndex < 0)
        currentFilterIndex = _optionsContainer[1].count - 1;
    if (currentFilterIndex >= _optionsContainer[1].count)
        currentFilterIndex = 0;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:currentFilterIndex inSection:0];
    _selectedIndexMap[@(1)] = indexPath;
    //    self.selectEffectIndexPath = indexPath;
    //    [self.effectCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    //    [self onValueChanged:self.filterSlider];
//        [self collectionView:self.effectCollectionView didSelectItemAtIndexPath:indexPath];
    [self changeFunction:PannelMenuIndexEffect];
}

-(float)filterMixLevelByIndex:(NSInteger)index
{
    if (index < 0)
        index = self.filterMap.count - 1;
    if (index > self.filterMap.count - 1)
        index = 0;
    return ((NSNumber*)[self.filterMap objectForKey:@(index)]).floatValue;
}

- (void)onSetGreenWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSetGreenScreenFile:)]) {
        if (index == 0) {
            [self.delegate onSetGreenScreenFile:nil];
        }
        if (index == 1) {
            [self.delegate onSetGreenScreenFile:[[NSBundle mainBundle] URLForResource:@"goodluck" withExtension:@"mp4"]];
            
        }
    }
}

- (void)onSetMotionWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSelectMotionTmpl:inDir:)]) {
        NSString *localPackageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPackageDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:localPackageDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (index == 0){
            [self.delegate onSelectMotionTmpl:nil inDir:localPackageDir];
        }
        else{
            NSArray *motionAray = _optionsContainer[PannelMenuIndexMotion];
            NSString *tmp = [motionAray objectAtIndex:index];
            NSString *pituPath = [NSString stringWithFormat:@"%@/%@", localPackageDir, tmp];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pituPath]) {
                [self.delegate onSelectMotionTmpl:tmp inDir:localPackageDir];
            }else{
                [self startLoadPitu:localPackageDir pituName:tmp packageURL:[NSURL URLWithString:[_motionAddressDic objectForKey:tmp]]];
            }
        }
    }
}

- (void)onSetKoubeiWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSelectMotionTmpl:inDir:)]) {
        NSString *localPackageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPackageDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:localPackageDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (index == 0){
            [self.delegate onSelectMotionTmpl:nil inDir:localPackageDir];
        }
        else{
            NSArray *koubeiArray = _optionsContainer[PannelMenuIndexKoubei];
            NSString *tmp = [koubeiArray objectAtIndex:index];
            NSString *pituPath = [NSString stringWithFormat:@"%@/%@", localPackageDir, tmp];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pituPath]) {
                [self.delegate onSelectMotionTmpl:tmp inDir:localPackageDir];
            }else{
                [self startLoadPitu:localPackageDir pituName:tmp packageURL:[NSURL URLWithString:[_koubeiAddressDic objectForKey:tmp]]];
            }
        }
    }
}

- (void)startLoadPitu:(NSString *)pituDir pituName:(NSString *)pituName packageURL:(NSURL *)packageURL{
#if POD_PITU
    if (self.operation) {
        if (self.operation.state != NSURLSessionTaskStateRunning) {
            [self.operation resume];
        }
    }
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@.zip", pituDir, pituName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
    }
    
    __weak __typeof(self) weakSelf = self;
    NSURLRequest *downloadReq = [NSURLRequest requestWithURL:packageURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.f];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak AFHTTPSessionManager *weakManager = manager;
    [self.pituDelegate onLoadPituStart];
    self.operation = [manager downloadTaskWithRequest:downloadReq progress:^(NSProgress * _Nonnull downloadProgress) {
        if (weakSelf.pituDelegate) {
            CGFloat progress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
            [weakSelf.pituDelegate onLoadPituProgress:progress];
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath_, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:targetPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [weakManager invalidateSessionCancelingTasks:YES];
        if (error) {
            [weakSelf.pituDelegate onLoadPituFailed];
            return;
        }
        // 解压
        BOOL unzipSuccess = NO;
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:targetPath]) {
            unzipSuccess = [zipArchive UnzipFileTo:pituDir overWrite:YES];
            [zipArchive UnzipCloseFile];
            
            // 删除zip文件
            [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        }
        if (unzipSuccess) {
            [weakSelf.pituDelegate onLoadPituFinished];
            [weakSelf.delegate onSelectMotionTmpl:pituName inDir:pituDir];
        } else {
            [weakSelf.pituDelegate onLoadPituFailed];
        }
    }];
    [self.operation resume];
#endif
}

#pragma mark - height
+ (NSUInteger)getHeight
{
    return BeautyViewMargin * 4 + 3 * BeautyViewSliderHeight + BeautyViewCollectionHeight;
}

#pragma mark - Translator
- (NSString *)textAtIndex:(NSInteger)index inMenu:(PannelMenuIndex)menuIndex {
    NSString *text = _optionsContainer[menuIndex][index];
    if (menuIndex == PannelMenuIndexMotion || menuIndex == PannelMenuIndexKoubei) {
        text = [self getMotionName:text];
    }
    return text;
}

- (NSString *)getMotionName:(NSString *)motion
{
    if (_motionNameMap == nil) {
        _motionNameMap = @{
                           @"video_boom": L(@"BeautySettingPanel.MotionName1"),
                           @"video_nihongshu": L(@"BeautySettingPanel.MotionName2"),
                           @"video_3DFace_dogglasses2": L(@"BeautySettingPanel.MotionName3"),
                           @"video_fengkuangdacall": L(@"BeautySettingPanel.MotionName4"),
                           @"video_Qxingzuo_iOS" : L(@"BeautySettingPanel.MotionName5"),
                           @"video_caidai_iOS" : L(@"BeautySettingPanel.MotionName6"),
                           @"video_liuhaifadai" : L(@"BeautySettingPanel.MotionName7"),
                           @"video_rainbow": L(@"BeautySettingPanel.MotionName8"),
                           @"video_purplecat": L(@"BeautySettingPanel.MotionName9"),
                           @"video_huaxianzi": L(@"BeautySettingPanel.MotionName10"),
                           @"video_baby_agetest": L(@"BeautySettingPanel.MotionName11"),
                           @"video_xiaofu": L(@"BeautySettingPanel.MotionName12")
                           };
    }
    return _motionNameMap[motion] ?: motion;
}

- (NSMutableDictionary *)beautyValueMap
{
    if(!_beautyValueMap){
        _beautyValueMap = [[NSMutableDictionary alloc] init];
    }
    return _beautyValueMap;
}

- (UICollectionView *)optionsCollectionView {
    if (_optionsCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _optionsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _optionsCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _optionsCollectionView.showsHorizontalScrollIndicator = NO;
        _optionsCollectionView.delegate = self;
        _optionsCollectionView.dataSource = self;
        [_optionsCollectionView registerClass:[TextCell class] forCellWithReuseIdentifier:[TextCell reuseIdentifier]];
    }
    return _optionsCollectionView;
}

- (UICollectionView *)menuCollectionView
{
    if(!_menuCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //        layout.itemSize = CGSizeMake(100, 40);
        _menuCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _menuCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _menuCollectionView.showsHorizontalScrollIndicator = NO;
        _menuCollectionView.delegate = self;
        _menuCollectionView.dataSource = self;
        [_menuCollectionView registerClass:[TextCell class] forCellWithReuseIdentifier:[TextCell reuseIdentifier]];
    }
    return _menuCollectionView;
}

- (UISlider *)beautySlider
{
    if(!_beautySlider){
        _beautySlider = [[UISlider alloc] init];
        _beautySlider.minimumValue = 0;
        _beautySlider.maximumValue = 10;
        [_beautySlider setMinimumTrackTintColor:RGB(235, 100, 86)];
        [_beautySlider setMaximumTrackTintColor:RGB(166, 166, 165)];
        [_beautySlider setThumbImage:[UIImage imageNamed:@"beauty_slider"] forState:UIControlStateNormal];
        [_beautySlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _beautySlider;
}

- (UILabel *)beautyLabel
{
    if(!_beautyLabel){
        _beautyLabel = [[UILabel alloc] init];
        _beautyLabel.backgroundColor = [UIColor whiteColor];
        _beautyLabel.textAlignment = NSTextAlignmentCenter;
        _beautyLabel.text = @"0";
        [_beautyLabel setTextColor:UIColorFromRGB(0xFF584C)];
    }
    return _beautyLabel;
}

- (UISlider *)filterSlider
{
    if(!_filterSlider){
        _filterSlider = [[UISlider alloc] init];
        _filterSlider.minimumValue = 0;
        _filterSlider.maximumValue = 10;
        [_filterSlider setMinimumTrackTintColor:UIColorFromRGB(0x0ACCAC)];
        [_filterSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_filterSlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _filterSlider;
}

- (UILabel *)filterLabel
{
    if(!_filterLabel){
        _filterLabel = [[UILabel alloc] init];
        _filterLabel.backgroundColor = [UIColor whiteColor];
        _filterLabel.textAlignment = NSTextAlignmentCenter;
        _filterLabel.text = @"0";
        [_filterLabel setTextColor:UIColorFromRGB(0x0ACCAC)];
    }
    return _filterLabel;
}

- (void)resetValues
{
    self.beautySlider.hidden = NO;
    self.beautyLabel.hidden = NO;
    self.filterSlider.hidden = YES;
    self.filterLabel.hidden = YES;
    self.menuCollectionView.hidden = NO;
    
    [_selectedIndexMap removeAllObjects];

    [self onSetMotionWithIndex:0];
    [self onSetKoubeiWithIndex:0];
    [self onSetGreenWithIndex:0];
    
    [self.beautyValueMap removeAllObjects];
    [self.beautyValueMap setObject:@(6) forKey:@(1)]; //美颜默认值（自然）
    [self.beautyValueMap setObject:@(5) forKey:@(2)]; //美颜默认值（天天PITU）
    [self.beautyValueMap setObject:@(1) forKey:@(3)]; //美白默认值
    
    self.filterMap = [NSMutableDictionary new];
    [self.filterMap setObject:@(0) forKey:@(0)];
    [self.filterMap setObject:@(5) forKey:@(1)];
    [self.filterMap setObject:@(8) forKey:@(2)];
    [self.filterMap setObject:@(8) forKey:@(3)];
    [self.filterMap setObject:@(7) forKey:@(4)];
    [self.filterMap setObject:@(10) forKey:@(5)];
    [self.filterMap setObject:@(8) forKey:@(6)];
    [self.filterMap setObject:@(10) forKey:@(7)];
    [self.filterMap setObject:@(5) forKey:@(8)];
    [self.filterMap setObject:@(3) forKey:@(9)];
    [self.filterMap setObject:@(3) forKey:@(10)];
    [self.filterMap setObject:@(3) forKey:@(11)];
    [self.filterMap setObject:@(3) forKey:@(12)];
    [self.filterMap setObject:@(3) forKey:@(13)];
    [self.filterMap setObject:@(3) forKey:@(14)];
    [self.filterMap setObject:@(3) forKey:@(15)];
    [self.filterMap setObject:@(3) forKey:@(16)];
    [self.filterMap setObject:@(3) forKey:@(17)];
    
    _whiteLevel = 1;
    _beautyLevel = 6;
    _ruddyLevel = 0;
    
    self.beautySlider.minimumValue = 0;
    self.beautySlider.maximumValue = 10;
    float value = 6.3;;
    self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)value];
    self.beautySlider.value = value;
    self.filterSlider.value = 5;
        
    self.currentMenuIndex = PannelMenuIndexBeauty;
    [self onValueChanged:self.beautySlider];
//    [self onValueChanged:self.filterSlider];
    [self onSetEffectWithIndex:1];
    _selectedIndexMap[@(1)] = [NSIndexPath indexPathForRow:1 inSection:0];
}

@end
