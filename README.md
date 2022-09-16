# FUTXXiaoShiPinDemo 快速接入文档

FUTXXiaoShiPinDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能 和 腾讯短视频 功能的 Demo。

**本文是 FaceUnity SDK  快速对接 腾讯短视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**



## 快速集成方法

### 1、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，并且添加依赖库 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

### 2、在 `viewDidLoad` 中初始化 FaceUnity的界面和 SDK

#### 2.1 添加头文件，并创建页面属性

需要在录制视频时加入美颜贴纸效果就在 `UGCKitRecordPreviewController.m` 中添加头文件，并创建页面属性。  

```C
/**faceU */
#import "UIViewController+FaceUnityUIExtension.h"
#import <FURenderKit/FUGLContext.h>

// 使用纹理渲染时,记录当前glcontext
@property(nonatomic, strong) EAGLContext *mContext;

```

#### 2.2 FaceUnity界面工具和SDK都放在UIViewController+FaceUnityUIExtension中初始化了，也可以自行调用FUAPIDemoBar和FUManager初始化

```objc
[self setupFaceUnity];
```

#### 2.3  底部栏切换功能：使用不同的ViewModel控制

```C
-(void)bottomDidChangeViewModel:(FUBaseViewModel *)viewModel {
    if (viewModel.type == FUDataTypeBeauty || viewModel.type == FUDataTypebody) {
        self.renderSwitch.hidden = NO;
    } else {
        self.renderSwitch.hidden = YES;
    }

    [[FUManager shareManager].viewModelManager addToRenderLoop:viewModel];
    
    // 设置人脸数
    [[FUManager shareManager].viewModelManager resetMaxFacesNumber:viewModel.type];
}

```

#### 2.4 更新美颜参数

```C
- (IBAction)filterSliderValueChange:(FUSlider *)sender {
    _seletedParam.mValue = @(sender.value * _seletedParam.ratio);
    /**
     * 这里使用抽象接口，有具体子类决定去哪个业务员模块处理数据
     */
    [self.selectedView.viewModel consumerWithData:_seletedParam viewModelBlock:nil];
}
```

### 3、在视频数据回调中 加入 FaceUnity  的数据处理（FURenderInput输入和FURenderOutput输出）

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

    if ([FUGLContext shareGLContext].currentGLContext != [EAGLContext currentContext]) {
        [[FUGLContext shareGLContext] setCustomGLContext:[EAGLContext currentContext]];
    }

    if ([FUManager shareManager].isRender) {
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.renderConfig.stickerFlipH = YES;
        FUTexture tex = {texture, CGSizeMake(width, height)};
        input.texture = tex;
        
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        input.renderConfig.textureTransform = CCROT0_FLIPVERTICAL;
        
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
        if (output) {
            return output.texture.ID;
        }
    }
    return 0;

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
