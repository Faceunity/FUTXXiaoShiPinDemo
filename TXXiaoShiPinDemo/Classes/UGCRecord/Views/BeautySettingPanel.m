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

typedef NS_ENUM(NSUInteger, PannelMenuIndex) {
    PannelMenuIndexBeautyStyle,
    PannelMenuIndexBeauty,
    PannelMenuIndexEffect,
    PannelMenuIndexMotion,
    PannelMenuIndexKoubei,
    PannelMenuIndexGreen
};

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
    
    self.beautyLabel.frame = CGRectMake(self.beautySlider.frame.size.width + self.beautySlider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.beautyLabel.layer.cornerRadius = self.beautyLabel.frame.size.width / 2;
    self.beautyLabel.layer.masksToBounds = YES;
    [self addSubview:self.beautyLabel];
    
    
    self.filterSlider.frame = CGRectMake(BeautyViewMargin * 4, BeautyViewMargin, self.frame.size.width - 10 * BeautyViewMargin - BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.filterSlider.hidden = YES;
    [self addSubview:self.filterSlider];
    
    self.filterLabel.frame = CGRectMake(self.filterSlider.frame.size.width + self.filterSlider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.filterLabel.layer.cornerRadius = self.filterLabel.frame.size.width / 2;
    self.filterLabel.layer.masksToBounds = YES;
    self.filterLabel.hidden = YES;
    [self addSubview:self.filterLabel];
    _menuArray = @[/*@"原图", */@"风格", @"美颜", @"滤镜", @"动效", @"抠背", @"绿幕"];

    NSArray *effectArray = @[@"清除", @"美白", @"浪漫", @"清新", @"唯美", @"粉嫩", @"怀旧", @"蓝调", @"清亮", @"日系"];
    NSArray *beautyArray = @[@"美颜", @"美白", @"红润", @"大眼", @"瘦脸", /*@"美型", */@"v脸", @"下巴", @"短脸", @"瘦鼻"];
    NSArray *beautyStyleArray = @[@"光滑", @"自然", @"p图"];
    
    NSArray *motionArray = @[@"无动效", @"video_boom" , @"video_nihongshu",    @"video_3DFace_dogglasses2",
                             @"video_fengkuangdacall", @"video_Qxingzuo_iOS", @"video_caidai_iOS",
                             @"video_liuhaifadai",     @"video_rainbow",      @"video_purplecat",
                             @"video_huaxianzi",       @"video_baby_agetest"];
    
    _motionAddressDic = NSDictionaryOfVariableBindings(video_3DFace_dogglasses2, video_baby_agetest, video_caidai_iOS, video_huaxianzi,
                                                        video_liuhaifadai, video_nihongshu, video_rainbow, video_boom, video_fengkuangdacall,
                                                        video_purplecat, video_Qxingzuo_iOS);
    
    NSArray *koubeiArray = @[@"无动效", @"video_xiaofu"];
    _koubeiAddressDic = NSDictionaryOfVariableBindings(video_xiaofu);
    
    NSArray *greenArray = @[@"清除", @"goodluck"];
    
    _optionsContainer = @[beautyStyleArray, beautyArray, effectArray, motionArray, koubeiArray, greenArray];
    _selectedIndexMap = [NSMutableDictionary dictionaryWithCapacity:_optionsContainer.count];
    
    self.optionsCollectionView.frame = CGRectMake(0, self.beautySlider.frame.size.height + self.beautySlider.frame.origin.y + BeautyViewMargin, self.frame.size.width, BeautyViewSliderHeight * 2 + 2 * BeautyViewMargin);
    [self addSubview:self.optionsCollectionView];
    
    self.menuCollectionView.frame = CGRectMake(0, self.optionsCollectionView.frame.size.height + self.optionsCollectionView.frame.origin.y, self.frame.size.width, BeautyViewCollectionHeight);
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
            case PannelMenuIndexBeautyStyle:
                [self onValueChanged:self.beautySlider];
                break;
            case PannelMenuIndexBeauty: {
                if(indexPath.row == 6){
                    //下巴
                    self.beautySlider.minimumValue = -10;
                    self.beautySlider.maximumValue = 10;
                } else {
                    self.beautySlider.minimumValue = 0;
                    self.beautySlider.maximumValue = 10;
                }
                float value = [[self.beautyValueMap objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
                self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)value];
                [self.beautySlider setValue:value];
            } break;
            case PannelMenuIndexEffect: 
                [self onSetEffectWithIndex:indexPath.row];
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

- (void)changeFunction:(NSInteger)index
{
    self.beautyLabel.hidden = index == 1? NO: YES;
    self.beautySlider.hidden = index == 1? NO: YES;
    self.filterLabel.hidden = index == 2? NO: YES;
    self.filterSlider.hidden = index == 2? NO: YES;

    NSAssert(index < _optionsContainer.count, @"index out of range");
    [self.menuCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentMenuIndex inSection:0]].selected = NO;
    _currentMenuIndex = index;
    [self.optionsCollectionView reloadData];
}


#pragma mark - value changed
- (void)onValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    if(slider == self.filterSlider){
        self.filterLabel.text = [NSString stringWithFormat:@"%d",(int)self.filterSlider.value];
        if([self.delegate respondsToSelector:@selector(onSetMixLevel:)]){
            [self.delegate onSetMixLevel:self.filterSlider.value];
        }
    }
    else{
        int beautyIndex = (int)[self selectedIndexPathForMenu:PannelMenuIndexBeauty].row;
        int beautyStyleIndex = (int)[self selectedIndexPathForMenu:PannelMenuIndexBeautyStyle].row;
        
        [self.beautyValueMap setObject:[NSNumber numberWithFloat:self.beautySlider.value] forKey:@(beautyIndex)];
        self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)self.beautySlider.value];
        
        if(beautyIndex == 0){
            if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
                _beautyLevel = self.beautySlider.value;
                [self.delegate onSetBeautyStyle:beautyStyleIndex beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
            }
        }
        else if(beautyIndex == 1){
            if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
                _whiteLevel = self.beautySlider.value;
                [self.delegate onSetBeautyStyle:beautyStyleIndex beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
            }
        }
        else if(beautyIndex == 2){
            if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
                _ruddyLevel = self.beautySlider.value;
                [self.delegate onSetBeautyStyle:beautyStyleIndex beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
            }
        }
        else if(beautyIndex == 3){
            if([self.delegate respondsToSelector:@selector(onSetEyeScaleLevel:)]){
                [self.delegate onSetEyeScaleLevel:self.beautySlider.value];
            }
        }
        else if(beautyIndex == 4){
            if([self.delegate respondsToSelector:@selector(onSetFaceScaleLevel:)]){
                [self.delegate onSetFaceScaleLevel:self.beautySlider.value];
            }
        }
//        else if(beautyIndex == 5){
//            if([self.delegate respondsToSelector:@selector(onSetFaceBeautyLevel:)]){
//                [self.delegate onSetFaceBeautyLevel:self.beautySlider.value];
//            }
//        }
        else if(beautyIndex == 5){
            if([self.delegate respondsToSelector:@selector(onSetFaceVLevel:)]){
                [self.delegate onSetFaceVLevel:self.beautySlider.value];
            }
        }
        else if(beautyIndex == 6){
            if([self.delegate respondsToSelector:@selector(onSetChinLevel:)]){
                [self.delegate onSetChinLevel:self.beautySlider.value];
            }
        }
        else if(beautyIndex == 7){
            if([self.delegate respondsToSelector:@selector(onSetFaceShortLevel:)]){
                [self.delegate onSetFaceShortLevel:self.beautySlider.value];
            }
        }
        else if(beautyIndex == 8){
            if([self.delegate respondsToSelector:@selector(onSetNoseSlimLevel:)]){
                [self.delegate onSetNoseSlimLevel:self.beautySlider.value];
            }
        }
        else{
            
        }
    }
}

- (void)onSetEffectWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSetFilter:)]) {
        NSString* lookupFileName = @"";
        
        switch (index) {
            case 0:
                break;
            case 1:
                lookupFileName = @"white.png";
                break;
            case 2:
                lookupFileName = @"langman.png";
                break;
            case 3:
                lookupFileName = @"qingxin.png";
                break;
            case 4:
                lookupFileName = @"weimei.png";
                break;
            case 5:
                lookupFileName = @"fennen.png";
                break;
            case 6:
                lookupFileName = @"huaijiu.png";
                break;
            case 7:
                lookupFileName = @"landiao.png";
                break;
            case 8:
                lookupFileName = @"qingliang.png";
                break;
            case 9:
                lookupFileName = @"rixi.png";
                break;
            default:
                break;
        }
        NSString * path = [[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"];
        if (path != nil && index != FilterType_None) {
            path = [path stringByAppendingPathComponent:lookupFileName];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [self.delegate onSetFilter:image];
            
        } else {
            [self.delegate onSetFilter:nil];
        }
    }
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
                           @"video_boom": @"Boom",
                           @"video_nihongshu": @"霓虹鼠",
                           @"video_3DFace_dogglasses2": @"眼镜狗",
                           @"video_fengkuangdacall": @"疯狂打call",
                           @"video_Qxingzuo_iOS" : @"Q星座",
                           @"video_caidai_iOS" : @"彩色丝带",
                           @"video_liuhaifadai" : @"刘海发带",
                           @"video_rainbow": @"彩虹云",
                           @"video_purplecat": @"紫色小猫",
                           @"video_huaxianzi": @"花仙子",
                           @"video_baby_agetest": @"小公举",
                           @"video_xiaofu": @"AI抠背"
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
    [self.beautyValueMap setObject:@(6.3) forKey:@(0)]; //美颜默认值
    [self.beautyValueMap setObject:@(2.7) forKey:@(1)]; //美白默认值
    [self.beautyValueMap setObject:@(2.7) forKey:@(2)]; //红润默认值
    
    _whiteLevel = 2.7;
    _beautyLevel = 6.3;
    _ruddyLevel = 2.7;
    
    self.beautySlider.minimumValue = 0;
    self.beautySlider.maximumValue = 10;
    float value = 6.3;;
    self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)value];
    self.beautySlider.value = value;
    self.filterSlider.value = 3;
    
    [self setSelectedIndexPath:[NSIndexPath indexPathForItem:VIDOE_BEAUTY_STYLE_NATURE inSection:0]
                       forMenu:PannelMenuIndexBeautyStyle];
    
    self.currentMenuIndex = PannelMenuIndexBeauty;
    [self onValueChanged:self.beautySlider];
    [self onValueChanged:self.filterSlider];
}

@end
