// CKTreeClusterView.m
//
// Copyright © 2017 Hulab. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CKTreeClusterView.h"

@interface CKTreeClusterView ()
@property (nonatomic, strong) UILabel *countLabel;
@end

@implementation CKTreeClusterView

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.text = [NSString stringWithFormat:@"%lu", self.count];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor whiteColor];
        [self addSubview:_countLabel];
    }
    return _countLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.backgroundColor = [UIColor colorWithRed:0.06 green:0.44 blue:0.01 alpha:1.0].CGColor;
    
    self.countLabel.frame = self.bounds;
}

- (void)setCount:(NSUInteger)count {
    _count = count;
    _countLabel.text = [NSString stringWithFormat:@"%lu", count];
    [self setNeedsLayout];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = self.countLabel.intrinsicContentSize.width + 16;
    return CGSizeMake(width, width);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

+ (UIImage *)treeIcon {
    static UIImage *icon = nil;
    if (!icon) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        icon = [UIImage imageNamed:@"tree" inBundle:bundle compatibleWithTraitCollection:nil];
    }
    return icon;
}

@end
