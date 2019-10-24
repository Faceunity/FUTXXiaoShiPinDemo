//
//  SUVerticalButton.m
//  
//
//  Created by stcui on 15/9/1.
//
//

#import "VerticalButton.h"

static const CGFloat kPadding = 7;

@implementation VerticalButton
- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [self init]) {
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.3;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.3;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSDictionary *attr = @{NSFontAttributeName: self.titleLabel.font};
    CGSize textSize = [[self titleForState:self.state] sizeWithAttributes:attr];
    CGSize imageSize = [self imageForState:self.state].size;
    CGFloat width = MAX(textSize.width, imageSize.width);
    CGFloat height = textSize.height + imageSize.height + kPadding;
    return CGSizeMake(truncf(width), truncf(height));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSDictionary *attr = @{NSFontAttributeName: self.titleLabel.font};
    CGSize textSize = [[self titleForState:self.state] sizeWithAttributes:attr];
    CGFloat width = CGRectGetWidth(self.bounds);
    if (textSize.width > width) {
        textSize.width = width;
    }
    CGSize imageSize = [self imageForState:self.state].size;
    CGFloat totalHeight = textSize.height + imageSize.height + kPadding;
    CGFloat centerX = CGRectGetMidX(self.bounds);
    self.imageView.center = CGPointMake(centerX, (CGRectGetHeight(self.bounds) - totalHeight) / 2 + imageSize.height / 2);
    CGRect imageFrame = self.imageView.frame;
    BOOL changed = NO;
    if (imageFrame.origin.x < 0) {
        imageFrame.size.width += 2*imageFrame.origin.x;
        imageFrame.origin.x = 0;
        changed = YES;
    }
    if (imageFrame.origin.y < 0) {
        imageFrame.size.height += 2*imageFrame.origin.y;
        imageFrame.origin.y = 0;
        changed = YES;
    }
    if (changed) {
        self.imageView.frame = imageFrame;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - textSize.width)/2, CGRectGetHeight(self.bounds) - textSize.height, textSize.width, textSize.height);
}
                                                                                            
- (CGSize)intrinsicContentSize {
    // 在iOS8以下，intrinsicContentSize中直接调用控件，会造成循环调用
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)) {
        return [super intrinsicContentSize];
    }
    return [self sizeThatFits:CGSizeZero];
}

@end
