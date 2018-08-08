//
//  TCBGMListViewController.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/8.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMListViewController.h"
#import "TCBGMHelper.h"
#import "UIView+CustomAutoLayout.h"
#import "TCBGMCell.h"

@interface TCBGMListViewController()<TCBGMHelperListener>{
    NSMutableDictionary* _progressList;
    NSTimeInterval lastUIFreshTick;
}
@property(nonatomic) NSDictionary* _bgmDict;
@property(nonatomic) NSArray* _bgmKeys;
@property(nonatomic) TCBGMHelper* _bgmHelper;
@property(nonatomic,weak) id<TCBGMControllerListener> _bgmListener;
@end


@implementation TCBGMListViewController
@synthesize _bgmDict;
@synthesize _bgmKeys;
@synthesize _bgmHelper;
@synthesize _bgmListener;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _progressList = [NSMutableDictionary new];
    }
    return self;
}

-(void)setBGMControllerListener:(id<TCBGMControllerListener>) listener{
    _bgmListener = listener;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TCBGMCell" bundle:nil] forCellReuseIdentifier:@"TCBGMCell"];
    
//    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
//                                                                         style:UIBarButtonItemStylePlain
//                                                                        target:self
//                                                                        action:@selector(goBack)];
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    customBackButton.tintColor = UIColorFromRGB(0x0accac);
    self.navigationItem.leftBarButtonItem = customBackButton;
    
    lastUIFreshTick = [[NSDate date] timeIntervalSince1970]*1000;
    
    _bgmHelper = [TCBGMHelper sharedInstance];
    [_bgmHelper setDelegate:self];
    [self loadBGMList];
    
//    UIButton* testBtn = [[UIButton alloc] init];
//    testBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
//    [testBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [testBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
//    [testBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateSelected];
//    [testBtn addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:testBtn];
//    [testBtn sizeWith:CGSizeMake(200, 50)];
//    [testBtn alignParentLeft];
}

- (void)goBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) updateCells{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[self tableView] reloadData];
    });
}

- (void)loadBGMList{
    NSString* jsonUrl = @"http://bgm-1252463788.cosgz.myqcloud.com/bgm_list.json";
//    NSString *jsonUrl = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"bgm_list.json"];
    [_bgmHelper initBGMListWithJsonFile:jsonUrl];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_bgmKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCBGMCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TCBGMCell"];
//    if (!cell) {
//        cell = [[TCBGMCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCBGMCell"];
//    }
    NSUInteger rowNum = indexPath.row;
    [[cell nameView] setText:[[_bgmDict objectForKey:[_bgmKeys objectAtIndex:rowNum]] name]];
    [[cell progressView] setWidth:2];
    NSNumber* nsPercent = [_progressList objectForKey:[_bgmKeys objectAtIndex:rowNum]];
    float percent = nsPercent? [nsPercent floatValue] : 0;
    [[cell progressView] setPercent: percent];
    [cell setFinish:(percent == 1.f)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCBGMElement* ele = [_bgmDict objectForKey:[_bgmKeys objectAtIndex:indexPath.row]];
    if([ele isValid] && [[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[ele localUrl]]]){
        [self goBack];
        [_bgmListener onBGMControllerPlay: [NSHomeDirectory() stringByAppendingPathComponent:[ele localUrl]]];
    }
    else [_bgmHelper downloadBGM:[_bgmDict objectForKey:[_bgmKeys objectAtIndex:indexPath.row]]];
}

-(void) onBGMListLoad:(NSDictionary*)dict{
    if(dict){
        BGMLog(@"BGM List 加载成功");
        _bgmDict = dict;
        _bgmKeys = [_bgmDict keysSortedByValueUsingComparator:^(TCBGMElement* e1, TCBGMElement* e2){
            return [[e1 name] compare:[e2 name]];
        }];
        for (NSString* url in _bgmKeys) {
            TCBGMElement* ele = [_bgmDict objectForKey:url];
            if([[ele isValid] boolValue]){
                [_progressList setObject :[NSNumber numberWithFloat:1.f] forKey:url];
            }
        }
        [self updateCells];
    }
}

-(void) onBGMDownloading:(TCBGMElement*)current percent:(float)percent{
    BGMLog(@"%@：%f",[current name], percent);
    [_progressList setObject :[NSNumber numberWithFloat:percent] forKey:[current netUrl]];
    if([[NSDate date] timeIntervalSince1970]*1000 - lastUIFreshTick > 300){
        lastUIFreshTick = [[NSDate date] timeIntervalSince1970]*1000;
        [self updateCells];
    }
}

-(void) onBGMDownloadDone:(TCBGMElement*)element{
    if([[element isValid] boolValue]){
        BGMLog(@"Download \"%@\" success!", [element name]);
        [_progressList setObject :[NSNumber numberWithFloat:1.f] forKey:[element netUrl]];
        [self goBack];
        [_bgmListener onBGMControllerPlay: [NSHomeDirectory() stringByAppendingPathComponent:[element localUrl]]];
    }
    else BGMLog(@"Download \"%@\" failed!", [element name]);
    [self updateCells];
}
@end
