//
//  TCVideoEditBGMHelper.m
//  TXXiaoShiPinDemo
//
//  Created by linkzhzhu on 2017/12/7.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCBGMHelper.h"
#import "AFHTTPSessionManager.h"
#import "pthread.h"
#import "TCLoginModel.h"

@interface TCBGMHelper(){
    NSDictionary* _configs;
    NSUserDefaults* _userDefaults;
    NSString* _userIDKey;
//    NSMutableDictionary* _tasks;
    NSURLSessionDownloadTask* _currentTask;
    TCBGMElement* _currentEle;
    NSString* _bgmPath;
}
@property(nonatomic, assign)pthread_mutex_t lock;
@property(nonatomic, assign)pthread_cond_t cond;
@property(nonatomic, strong)dispatch_queue_t queue;
@property(nonatomic)NSMutableDictionary* bgmDict;
@property(nonatomic)NSMutableDictionary* bgmList;//只用来存储路径
@property(nonatomic,weak) id <TCBGMHelperListener>delegate;
@end

static TCBGMHelper* _sharedInstance;
static pthread_mutex_t _instanceLock = PTHREAD_MUTEX_INITIALIZER;
@implementation TCBGMHelper

+ (instancetype)sharedInstance {
    if(!_sharedInstance){
        pthread_mutex_lock(&_instanceLock);
        _sharedInstance = [TCBGMHelper new];
        pthread_mutex_unlock(&_instanceLock);
    }
    return _sharedInstance;
}

-(void) setDelegate:(nonnull id<TCBGMHelperListener>) delegate{
    _delegate = delegate;
}

-(id) init{
    if(self = [super init]){
//        if(![[TCLoginModel sharedInstance] isLogin]){
//            self = nil;
//            return nil;
//        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        _bgmPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/bgm"];
        if(![fileManager fileExistsAtPath:_bgmPath]){
            if(![fileManager createDirectoryAtPath:_bgmPath withIntermediateDirectories:YES attributes:nil error:nil]){
                BGMLog(@"创建BGM目录失败");
                return nil;
            }
        }
        pthread_mutex_init(&_lock, NULL);
        pthread_cond_init(&_cond, NULL);
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:BGM_GROUP];
        if (_userDefaults == nil) {
            _userDefaults = [NSUserDefaults standardUserDefaults];
        }
//        _tasks = [[NSMutableDictionary alloc] init];
        _userIDKey = [[TCLoginParam shareInstance].identifier stringByAppendingString:@"_bgm"];
        _queue = dispatch_queue_create("com.tencent.txcloud.videoedit.bgm.download", NULL);
        dispatch_async(_queue, ^{[self loadLocalData];});
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
    pthread_cond_destroy(&_cond);
}

-(void) initBGMListWithJsonFile:(NSString* _Nonnull)url{
    if(url == nil)return;
    __weak TCBGMHelper* weak = self;
    void (^task)(void) = ^{
        NSString* localListPath = url;
        __strong TCBGMHelper* strong = weak;
        if([url hasPrefix:@"http"]){
            localListPath = [_bgmPath stringByAppendingPathComponent:@"bgm_list.json"];
            __block BOOL ret = false;
            pthread_mutex_lock(&_lock);
            [TCBGMHelper downloadFile:url dstUrl:localListPath callback:^(float percent, NSString* path){
                __strong TCBGMHelper* strong = weak;
                if(strong){
                    if(percent < 0){
                        pthread_cond_signal(&(strong->_cond));
                    }
                    else{
                        if(path != nil){
                            pthread_mutex_lock(&(strong->_lock));
                            ret = true;
                            pthread_cond_signal(&(strong->_cond));
                            pthread_mutex_unlock(&(strong->_lock));
                        }
                    }
                }
            }];
            pthread_cond_wait(&_cond, &_lock);
            pthread_mutex_unlock(&_lock);
        }
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:localListPath];
        strong->_configs = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(strong->_configs == nil){
            [strong->_delegate onBGMListLoad:nil];
        }
        else{
            NSArray* nameList = [strong->_configs valueForKeyPath:@"bgm.list.name"];
            if([nameList count]){
                NSArray* urlList = [strong->_configs valueForKeyPath:@"bgm.list.url"];
                for (int i = 0; i < [nameList count]; i++) {
                    TCBGMElement* ele = [strong->_bgmDict objectForKey:[urlList objectAtIndex:i]];
                    if(ele != nil){
                        
                    }
                    else{
                        ele = [TCBGMElement new];
                        ele.netUrl = [urlList objectAtIndex:i];
                        ele.name = [nameList objectAtIndex:i];
                        [strong saveBGMStat:ele];
                    }
                }
            }
        }
        [strong->_delegate onBGMListLoad:_bgmDict];
    };
    dispatch_async(_queue, task);
    return;
}

-(void) loadLocalData{
    _bgmDict = [NSMutableDictionary new];
    _bgmList = [[_userDefaults objectForKey:[_userIDKey stringByAppendingString:@".tc.bgm.list"]] mutableCopy];
    if(_bgmList == nil){
        _bgmList = [NSMutableDictionary new];
    }
    for (id it in _bgmList) {
        TCBGMElement* ele = [NSKeyedUnarchiver unarchiveObjectWithData:[_userDefaults objectForKey:[_userIDKey stringByAppendingString:it]]];
        if(ele)[_bgmDict setObject:ele forKey:[ele netUrl]];
    }
}

-(void) saveBGMStat:(TCBGMElement*) ele{
    [_bgmDict setObject:ele forKey:ele.netUrl];
    [_bgmList setObject:[ele netUrl] forKey:[ele netUrl]];
    NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:ele];
    [_userDefaults setObject:udObject forKey:[_userIDKey stringByAppendingString:[ele netUrl]]];
    [_userDefaults setObject:_bgmList forKey:[_userIDKey stringByAppendingString:@".tc.bgm.list"]];
}

-(void) downloadBGM:(TCBGMElement*) current{
//    TCBGMElement* bgm = [_bgmDict objectForKey:[current netUrl]];
    __block bool needOverride = true;
//    if(bgm && [[bgm isValid] boolValue]){
//        if(([[bgm netUrl] isEqualToString:[current netUrl]])){
//            return;
//        }
//        else needOverride = false;
//        return;
//    }
    __weak TCBGMHelper* weak = self;
    dispatch_async(_queue, ^(){
        __strong TCBGMHelper* strong = weak;
        if(strong != nil){
            if([[_currentEle netUrl] isEqualToString:[current netUrl]]){
                if([_currentTask state] == NSURLSessionTaskStateRunning){
                    BGMLog(@"暂停：%@", [current name]);
                    [_currentTask suspend];
                    return;
                }
                else if([_currentTask state] == NSURLSessionTaskStateSuspended){
                    BGMLog(@"恢复：%@", [current name]);
                    [_currentTask resume];
                    return;
                }
            }
            else{
                if(_currentTask){
                    if([_currentTask state] != NSURLSessionTaskStateCompleted){
                        [_currentTask cancel];
                        [strong.delegate onBGMDownloading:_currentEle percent:0];
                    }
                    _currentTask = nil;
                }
            }
            NSString* localListPath = nil;
            NSString* url = [current netUrl];
            
            __block NSString* justName = [current name];
            if(needOverride){
                localListPath = [_bgmPath stringByAppendingPathComponent:justName];
            }
            else{
                justName = [NSString stringWithFormat:@"%@1.%@", [justName stringByDeletingPathExtension], [[current name] pathExtension]];
                localListPath = [_bgmPath stringByAppendingPathComponent:justName];
            }
            NSURLSessionDownloadTask* task = [TCBGMHelper downloadFile:url dstUrl:localListPath callback:^(float percent, NSString* path){
                __strong TCBGMHelper* strong = weak;
                if(strong){
                    if(percent < 0){
                        dispatch_async(_queue, ^{
                            [strong.delegate onBGMDownloadDone:current];
                        });
                    }
                    else{
                        TCBGMElement* ele = [strong->_bgmDict objectForKey:[current netUrl]];
                        if(path != nil){
                            ele.localUrl = [NSString stringWithFormat:@"Documents/bgm/%@", justName];
                            ele.isValid = [NSNumber numberWithBool:true];
                            dispatch_async(_queue, ^{
                                [strong.delegate onBGMDownloadDone:ele];
                            });
                            [strong saveBGMStat:ele];
                        }else{
                            dispatch_async(_queue, ^{
                                [strong.delegate onBGMDownloading:ele percent:percent];
                            });
                        }
                    }
                }
            }];
            _currentTask = task;
            _currentEle = current;
        }
    });
}

//-(void) pauseAllTasks{
//    __weak TCBGMHelper* weak = self;
//    dispatch_async(_queue, ^(){
//        __strong TCBGMHelper* strong = weak;
//        for (id item in strong->_tasks) {
//            if([item state] == NSURLSessionTaskStateRunning)[item suspend];
//        }
//    });
//}
//
//-(void) resumeAllTasks{
//    __weak TCBGMHelper* weak = self;
//    dispatch_async(_queue, ^(){
//        __strong TCBGMHelper* strong = weak;
//        for (id item in strong->_tasks) {
//            if([item state] == NSURLSessionTaskStateSuspended)[item resume];
//        }
//    });
//}

/**
 下载函数回调
 
 @param percent 下载进度 < 0 出错并终止
 @param url 最终文件地址 nil != url则下载完成
 */
typedef void(^DownLoadCallback)(float percent, NSString* url);
+(NSURLSessionDownloadTask*) downloadFile:(NSString*)srcUrl dstUrl:(NSString*)dstUrl callback:(DownLoadCallback)callback{
//    __weak __typeof(self) weakSelf = self;
    NSURLRequest *downloadReq = [NSURLRequest requestWithURL:[NSURL URLWithString:srcUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:300.f];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //注意这里progress/destination是异步线程 completionHandler是main-thread
    NSURLSessionDownloadTask* task = [manager downloadTaskWithRequest:downloadReq progress:^(NSProgress * _Nonnull downloadProgress) {
        if (callback != nil) {
            callback(downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount, nil);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath_, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:dstUrl];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if(callback){
                callback(-1, nil);
            }
            return;
        }
        else{
            if(callback){
                callback(0, dstUrl);
            }
        }
    }];
    [task resume];
    return task;
}
@end


@implementation TCBGMElement
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.name = [coder decodeObjectForKey:@"name"];
        self.netUrl = [coder decodeObjectForKey:@"netUrl"];
        self.localUrl = [coder decodeObjectForKey:@"localUrl"];
        self.author = [coder decodeObjectForKey:@"author"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.isValid = [coder decodeObjectForKey:@"isValid"];
        self.duration = [coder decodeObjectForKey:@"duration"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_netUrl forKey:@"netUrl"];
    [coder encodeObject:_localUrl forKey:@"localUrl"];
    [coder encodeObject:_author forKey:@"author"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeObject:_isValid forKey:@"isValid"];
    [coder encodeObject:_duration forKey:@"duration"];
}
@end
