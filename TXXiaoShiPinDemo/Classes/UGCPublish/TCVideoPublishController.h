#import "TXUGCPublishListener.h"
#import "TCLiveListModel.h"

#import "SDKHeader.h"

#define kRecordType_Camera 0
#define kRecordType_Play 1

@interface TCVideoPublishController : UIViewController<UITextViewDelegate, TXVideoPublishListener,TXLivePlayListener>

@property (strong, nonatomic) UITableView      *tableView;

- (instancetype)init:(id)videoRecorder recordType:(NSInteger)recordType RecordResult:(TXRecordResult *)recordResult TCLiveInfo:(TCLiveInfo *)liveInfo;

- (instancetype)initWithPath:(NSString *)videoPath videoMsg:(TXVideoInfo *) videoMsg;

@end
