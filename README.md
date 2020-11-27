# FUTXXiaoShiPinDemo 快速接入文档

FUTXXiaoShiPinDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能 和 腾讯短视频 功能的 Demo。

**本文是 FaceUnity SDK  快速对接 腾讯短视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**



## 快速集成方法

### 1、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 上述NamaSDK 依赖库使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### 2、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

#### 2.1、添加头文件，并创建页面属性

需要在录制视频时加入美颜贴纸效果就在 `UGCKitRecordPreviewController.m` 中添加头文件，并创建页面属性。  

```C
/**faceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"
@property (nonatomic, strong) FUAPIDemoBar *demoBar;

```

#### 2.2、加入展示美颜贴纸的UI

1、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换贴纸 和 `filterValueChange:` 更新美颜参数。

```C
// demobar 初始化
-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 231, self.view.frame.size.width, 231)];
        
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

```

#### 2.3、切换贴纸

```C
// 切换贴纸
-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}
```

#### 2.4、更新美颜参数

```C
// 更新美颜参数
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}
```

### 3、在 `viewDidLoad:` 中初始化 SDK  并将  demoBar 添加到页面上

```C
      /**       FaceUnity       **/
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].isRender = YES;
    [FUManager shareManager].flipx = YES;
    [FUManager shareManager].trackFlipx = YES;
    [self.view addSubview:self.demoBar];
```

### 4、在视频数据回调中 加入 FaceUnity  的数据处理

在 UGCKitRecordPreviewController  的  `viewDidLoad： `  遵循腾讯SDK数据回调代理 `TXVideoCustomProcessDelegate`   ，并且实现代理方法 `- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height; `  如下

```C
/**
* 在OpenGL线程中回调，在这里可以进行采集图像的二次处理
* @param texture    纹理ID
* @param width      纹理的宽度
* @param height     纹理的高度
* @return           返回给SDK的纹理
* 说明：SDK回调出来的纹理类型是GL_TEXTURE_2D，接口返回给SDK的纹理类型也必须是GL_TEXTURE_2D; 该回调在SDK美颜之后. 纹理格式为GL_RGBA
*/
- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height {

    return [[FUManager shareManager] renderItemWithTexture:texture Width:width Height:height] ;

}

```


### 5、推流结束时需要销毁道具

销毁道具需要调用以下代码
```C
[[FUManager shareManager] destoryItems];
```

切换摄像头需要调用一下代码
```C
切换摄像头需要调用 [[FUManager shareManager] onCameraChange];切换摄像头
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)