#import <UIKit/UIKit.h>

@interface RecordMusicInfo : NSObject
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, copy) NSString* soneName;
@property (nonatomic, copy) NSString* singerName;
@property (nonatomic, assign) CGFloat duration;
@end

/**
 *  短视频录制VC
 */
@interface TCVideoRecordViewController : UIViewController
@property (nonatomic,strong) NSString *videoPath;
@end
