// UIViewController+ParisOpenData.m
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

#import <KVNProgress/KVNProgress.h>

#import "UIViewController+ParisOpenData.h"

@implementation UIViewController (ParisOpenData)

- (void)didLoadPoints:(NSArray<CKPointObject *> *)points {
    NSLog(@"warning: [%@ %@] is an abstract method", NSStringFromClass([UIViewController class]), NSStringFromSelector(_cmd));
}

@end

@implementation UIViewController (Museums)

- (void)loadMuseums {
    
    CKMuseumDownloader *downloader = [[CKMuseumDownloader alloc] init];
    
    [downloader setCompletionBlockWithSuccess:^(CKMuseumDownloader * _Nonnull downloader, NSArray<CKMuseum *> * _Nonnull points) {
        [KVNProgress showSuccess];
        [self didLoadPoints:points];
        
    } failure:^(__kindof CKPointObjectDownloader * _Nonnull downloader, NSError * _Nonnull error) {
        [KVNProgress showError];
    }];
    
    downloader.progressBlock = ^(__kindof CKPointObjectDownloader *downloader, CGFloat progress, long long byteCount) {
        NSString *status = [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleBinary];
        [KVNProgress updateStatus:status];
    };
    
    [KVNProgress showWithStatus:nil onView:self.view];
    [downloader resume];
}

@end

@implementation UIViewController (Stations)

- (void)loadStations {
    
    CKStationDownloader *downloader = [[CKStationDownloader alloc] init];
    
    [downloader setCompletionBlockWithSuccess:^(CKMuseumDownloader * _Nonnull downloader, NSArray<CKStation *> * _Nonnull points) {
        [KVNProgress showSuccess];
        [self didLoadPoints:points];
        
    } failure:^(__kindof CKPointObjectDownloader * _Nonnull downloader, NSError * _Nonnull error) {
        [KVNProgress showError];
    }];
    
    downloader.progressBlock = ^(__kindof CKPointObjectDownloader *downloader, CGFloat progress, long long byteCount) {
        NSString *status = [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleBinary];
        [KVNProgress updateStatus:status];
    };
    
    [KVNProgress showWithStatus:nil onView:self.view];
    [downloader resume];
}

@end

@implementation UIViewController (Trees)

- (void)loadTrees {
    
    CKTreeDownloader *downloader = [[CKTreeDownloader alloc] init];
    
    [downloader setCompletionBlockWithSuccess:^(CKTreeDownloader * _Nonnull downloader, NSArray<CKTree *> * _Nonnull points) {
        [KVNProgress showSuccess];
        [self didLoadPoints:points];
        
    } failure:^(__kindof CKPointObjectDownloader * _Nonnull downloader, NSError * _Nonnull error) {
        [KVNProgress showError];
    }];
    
    downloader.progressBlock = ^(__kindof CKPointObjectDownloader *downloader, CGFloat progress, long long byteCount) {
        NSString *status = [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleBinary];
        [KVNProgress updateStatus:status];
    };
    
    [KVNProgress showWithStatus:nil onView:self.view];
    [downloader resume];
}

@end
