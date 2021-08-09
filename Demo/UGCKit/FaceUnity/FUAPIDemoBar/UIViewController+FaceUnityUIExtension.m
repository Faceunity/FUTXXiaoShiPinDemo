//
//  UIViewController+FaceUnityUIExtension.m
//  BeautifyExample
//
//  Created by Chen on 2021/4/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "UIViewController+FaceUnityUIExtension.h"
#import "FUModuleDefine.h"
#import "FUBaseViewModel.h"
#import "FUModuleDefine.h"
#import <FURenderKit/FUAIKit.h>
#import <objc/runtime.h>

static NSString *switchKey;
static NSString *tipsLabelKey;
static NSString *fuApiDemoBarKey;

@interface UIViewController ()


@end

@implementation UIViewController (FaceUnityUIExtension)
/// faceunity
- (void)setupFaceUnity {
    
    [FUManager shareManager].isRender = YES;
    
    [self.view addSubview:self.demoBar];
    [self.view addSubview:self.renderSwitch];
}

- (UISwitch *)createSwitch {
    UISwitch *btn = [[UISwitch alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 447, 44, 44)];
    [btn addTarget:self action:@selector(renderSwitchAction:) forControlEvents:UIControlEventValueChanged];
    btn.hidden = YES;
    [btn setOn:YES];
    return btn;
}

- (UILabel *)createTipsLabel {
    /* 未检测到人脸提示 */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2.0 - 70, CGRectGetHeight(self.view.frame) / 2.0 - 11, 140, 22)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"No_Face_Tracking", @"未检测到人脸");
    label.hidden = YES;
    /* 未检测到人脸提示 */
    [self.view addSubview:label];
    return label;
}

#pragma mark 用于检测是否有ai人脸和人形
- (void)checkAI {
    dispatch_async(dispatch_get_main_queue(), ^{
        FUBaseViewModel *viewModel = [FUManager shareManager].viewModelManager.selectedViewModel;
        if (viewModel) {
            self.noTrackLabel.text = viewModel.provider.tipsStr;
            if (viewModel.type != FUDataTypebody) {
                int facenums = [FUAIKit shareKit].trackedFacesCount;
                if (facenums > 0) {
                    self.noTrackLabel.hidden = YES;
                } else {
                    self.noTrackLabel.hidden = NO;
                }
            } else {
                int bodyNums = [FUAIKit aiHumanProcessorNums];
                if (bodyNums > 0) {
                    self.noTrackLabel.hidden = YES;
                } else {
                    self.noTrackLabel.hidden = NO;
                }
            }
        }
    });
}


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

- (void)showTopView:(BOOL)shown {
    FUDataType type = [FUManager shareManager].viewModelManager.curType;
    if ((type == FUDataTypeBeauty || type == FUDataTypebody) && shown) {
        self.renderSwitch.hidden = NO;
    } else {
        self.renderSwitch.hidden = YES;
    }
}



//action
- (void)renderSwitchAction:(UISwitch *)btn {
    FUDataType type = [FUManager shareManager].viewModelManager.curType;
    if (btn.isOn) {
        [[FUManager shareManager].viewModelManager startRender:type];
    } else {
        //美颜有效
        [[FUManager shareManager].viewModelManager stopRender:type];
    }
}



#pragma mark - Set/Get
- (void)setRenderSwitch:(UISwitch *)renderSwitch {
    objc_setAssociatedObject(self,  &switchKey, renderSwitch, OBJC_ASSOCIATION_RETAIN);
}

- (UISwitch *)renderSwitch {
    UISwitch *btn = objc_getAssociatedObject(self, &switchKey);
    if (!btn) {
        btn = [self createSwitch];
        [self setRenderSwitch:btn];
    }
    return objc_getAssociatedObject(self, &switchKey);
}


- (void)setNoTrackLabel:(UILabel *)noTrackLabel {
    objc_setAssociatedObject(self,  &tipsLabelKey, noTrackLabel, OBJC_ASSOCIATION_RETAIN);
}

- (UILabel *)noTrackLabel {
    UILabel *label = objc_getAssociatedObject(self, &tipsLabelKey);
    if (!label) {
        label = [self createTipsLabel];
        [self setNoTrackLabel:label];;
    }
    return objc_getAssociatedObject(self, &tipsLabelKey);
}

- (void)setDemoBar:(FUAPIDemoBar *)demoBar {
    objc_setAssociatedObject(self,  &fuApiDemoBarKey, demoBar, OBJC_ASSOCIATION_RETAIN);
}


- (FUAPIDemoBar *)demoBar {
    FUAPIDemoBar *view = objc_getAssociatedObject(self, &fuApiDemoBarKey);
    if (!view) {
        view = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 395, self.view.frame.size.width, 194)];
        view.mDelegate = self;
        [self setDemoBar:view];
    }
    return view;
}

@end
