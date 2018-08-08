//
//  PasterSelectView.m
//  TXLiteAVDemo
//
//  Created by xiang zhang on 2017/10/31.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "UIView+Additions.h"
#import "PasterAddView.h"

@implementation PasterQipaoInfo
@end

@implementation PasterAnimateInfo
@end

@implementation PasterStaticInfo
@end

@implementation PasterAddView
{
    UIScrollView * _selectView;
    NSArray *      _pasterList;
    NSString *     _boundPath;
    UIButton *     _animateBtn;
    UIButton *     _staticBtn;
    UIButton *     _qipaoBtn;
    UIButton *     _closeBtn;
    PasterType     _pasterType;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat btnWidth = 100 * kScaleX;
        CGFloat btnHeight = 46 * kScaleY;
        _animateBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width / 2 -  btnWidth, 0 , btnWidth, btnHeight)];
        [_animateBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_animateBtn setTitle:@"动态贴纸" forState:UIControlStateNormal];
        [_animateBtn addTarget:self action:@selector(onAnimateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_animateBtn];
        
        _staticBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width / 2, 0 , btnWidth, btnHeight)];
        [_staticBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_staticBtn setTitle:@"静态贴纸" forState:UIControlStateNormal];
        [_staticBtn addTarget:self action:@selector(onStaticBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_staticBtn];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 45, 8 , 30, 30)];
        [_closeBtn setImage:[UIImage imageNamed:@"closePaster_normal"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"closePaster_press"] forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 46 * kScaleY, self.width, 1)];
        lineView.backgroundColor = RGB(53, 59, 72);
        [self addSubview:lineView];
        
        _qipaoBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width / 2 - btnWidth / 2, 0 , btnWidth, btnHeight)];
        [_qipaoBtn setTitleColor:UIColorFromRGB(0x0accac) forState:UIControlStateNormal];
        [_qipaoBtn setTitle:@"选择气泡字幕" forState:UIControlStateNormal];
        _qipaoBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_qipaoBtn addTarget:self action:@selector(onQipaoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_qipaoBtn];
        
        _selectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, lineView.bottom + 10 * kScaleY, self.width, self.height - lineView.bottom)];
        [self addSubview:_selectView];
        
        self.backgroundColor = UIColorFromRGB(0x1F2531);
    }
    return self;
}

- (void)setPasterType:(PasterType)pasterType
{
    _pasterType = pasterType;
    if (_pasterType == PasterType_Animate || _pasterType == PasterType_static) {
        _animateBtn.hidden = NO;
        _staticBtn.hidden = NO;
        _qipaoBtn.hidden = YES;
    }else{
        _animateBtn.hidden = YES;
        _staticBtn.hidden = YES;
        _qipaoBtn.hidden = NO;
    }
    [self reloadSelectView];
}

- (void)onAnimateBtnClicked:(UIButton *)btn
{
    [_animateBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_staticBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _pasterType = PasterType_Animate;
    [self reloadSelectView];
}

- (void)onStaticBtnClicked:(UIButton *)btn
{
    [_animateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_staticBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _pasterType = PasterType_static;
    [self reloadSelectView];
}

- (void)onQipaoBtnClicked:(UIButton *)btn
{
    _pasterType = PasterType_Qipao;
    [self reloadSelectView];
}

-(void)onClose
{
    self.hidden = YES;
}

- (void)reloadSelectView;
{
    switch (_pasterType) {
        case PasterType_Animate:
        {
            _boundPath = [[NSBundle mainBundle] pathForResource:@"AnimatedPaster" ofType:@"bundle"];
        }
            break;
            
        case PasterType_static:
        {
            _boundPath = [[NSBundle mainBundle] pathForResource:@"Paster" ofType:@"bundle"];
        }
            break;
            
        case PasterType_Qipao:
        {
            _boundPath = [[NSBundle mainBundle] pathForResource:@"bubbleText" ofType:@"bundle"];
        }
            break;
        default:
            break;
    }
    NSString *jsonString = [NSString stringWithContentsOfFile:[_boundPath stringByAppendingPathComponent:@"config.json"] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dic = [self dictionaryWithJsonString:jsonString];
    _pasterList = dic[@"pasterList"];
    
    int column = 4;  //默认4列
    CGFloat btnWidth = 70 * kScaleX;
    CGFloat space =  (self.width - btnWidth *column) / (column + 1);
    _selectView.contentSize = CGSizeMake(self.width, (_pasterList.count + 3) / 4 * (btnWidth + space));
    [_selectView removeAllSubViews];
    for (int i = 0; i < _pasterList.count; i ++) {
        NSString *qipaoIconPath = [_boundPath stringByAppendingPathComponent:_pasterList[i][@"icon"]];
        UIImage *qipaoIconImage = [UIImage imageWithContentsOfFile:qipaoIconPath];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(space + i % column  * (btnWidth + space),space +  i / column  * (btnWidth + space), btnWidth, btnWidth)];
        [btn setImage:qipaoIconImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectBubble:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [_selectView addSubview:btn];
    }
}

- (void)selectBubble:(UIButton *)btn
{
    switch (_pasterType) {
        case PasterType_Qipao:
        {
            NSString *qipaoPath = [_boundPath stringByAppendingPathComponent:_pasterList[btn.tag][@"name"]];
            NSString *jsonString = [NSString stringWithContentsOfFile:[qipaoPath stringByAppendingPathComponent:@"config.json"] encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic = [self dictionaryWithJsonString:jsonString];
            
            PasterQipaoInfo *info = [PasterQipaoInfo new];
            info.image = [UIImage imageNamed:[qipaoPath stringByAppendingPathComponent:dic[@"name"]]];
            info.width = [dic[@"width"] floatValue];
            info.height = [dic[@"height"] floatValue];
            info.textTop = [dic[@"textTop"] floatValue];
            info.textLeft = [dic[@"textLeft"] floatValue];
            info.textRight = [dic[@"textRight"] floatValue];
            info.textBottom = [dic[@"textBottom"] floatValue];
            info.iconImage = btn.imageView.image;
            [self.delegate onPasterQipaoSelect:info];
        }
            break;
            
        case PasterType_Animate:
        {
            NSString *pasterPath = [_boundPath stringByAppendingPathComponent:_pasterList[btn.tag][@"name"]];
            NSString *jsonString = [NSString stringWithContentsOfFile:[pasterPath stringByAppendingPathComponent:@"config.json"] encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic = [self dictionaryWithJsonString:jsonString];
            
            NSArray *imagePathList = dic[@"frameArry"];
            NSMutableArray *imageList = [NSMutableArray array];
            for (NSDictionary *dic in imagePathList) {
                NSString *imageName = dic[@"picture"];
                UIImage *image = [UIImage imageNamed:[pasterPath stringByAppendingPathComponent:imageName]];
                [imageList addObject:image];
            }
            
            PasterAnimateInfo *info = [PasterAnimateInfo new];
            info.imageList = imageList;
            info.path = pasterPath;
            info.width = [dic[@"width"] floatValue];
            info.height = [dic[@"height"] floatValue];
            info.duration = [dic[@"period"] floatValue] / 1000.0;
            info.iconImage = btn.imageView.image;
            [self.delegate onPasterAnimateSelect:info];
        }
            break;
            
        case PasterType_static:
        {
            NSString *pasterPath = [_boundPath stringByAppendingPathComponent:_pasterList[btn.tag][@"name"]];
            NSString *jsonString = [NSString stringWithContentsOfFile:[pasterPath stringByAppendingPathComponent:@"config.json"] encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic = [self dictionaryWithJsonString:jsonString];
            
            PasterStaticInfo *info = [PasterStaticInfo new];
            info.image = [UIImage imageNamed:[pasterPath stringByAppendingPathComponent:dic[@"name"]]];
            info.width = [dic[@"width"] floatValue];
            info.height = [dic[@"height"] floatValue];
            info.iconImage = btn.imageView.image;
            [self.delegate onPasterStaticSelect:info];
        }
            break;
            
        default:
            break;
    }
    self.hidden = YES;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
