//
//  Label.m
//
//  Created by shengcui on 16/9/22.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "Label.h"
#import <objc/runtime.h>

@implementation Label

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retSize = [super sizeThatFits:size];
    retSize.width += self.edgeInsets.left + self.edgeInsets.right;
    retSize.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return CGSizeMake(ceilf(retSize.width), ceilf(retSize.height));
}

@end

@interface UILabel (Copyable)

@end
static BOOL yes(id self, SEL cmd) {
    return YES;
}
@implementation UILabel (Copyable)
+ (void)load {
    Class clz = UILabel.class;
    unsigned int count = 0;
    Method *methods = class_copyMethodList(clz, &count);
    unsigned int canPerformActionIndex = -1;
    unsigned int canBecomeFirstResopnderIndex = -1;
    for (unsigned int i = 0; i < count; ++i) {
        SEL methodName = method_getName(methods[i]);
        if (methodName == @selector(canPerformAction:withSender:)) {
            canPerformActionIndex = i;
            NSLog(@"found");
        } else if (methodName == @selector(canBecomeFirstResponder)) {
            canBecomeFirstResopnderIndex = i;
        }
    }
    if (canPerformActionIndex > -1) {
        Method m0 = class_getInstanceMethod(self.class, @selector(canPerformAction:withSender:));
        Method m1 = class_getInstanceMethod(self.class, @selector(_canPerformAction:withSender:));
        method_exchangeImplementations(m0, m1);
    } else {
        Method method = class_getInstanceMethod(clz, @selector(_canPerformAction:withSender:));
        class_addMethod(clz, @selector(canPerformAction:withSender:), method_getImplementation(method), "B@::@");
    }
    if (canBecomeFirstResopnderIndex > -1) {
        class_replaceMethod(clz, @selector(canBecomeFirstResponder), (IMP)yes, "B@:");
    } else {
        class_addMethod(clz, @selector(canBecomeFirstResponder), (IMP)yes, "B@:");
    }
    free(methods);
}
- (BOOL)_canPerformAction:(SEL)action withSender:(id)sender
{
    if (![self respondsToSelector:@selector(text)]) {
        return NO;
    }
    return self.text.length > 0 && action == @selector(copy:);
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
}
@end
