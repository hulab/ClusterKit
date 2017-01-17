// CKPointObjectDownloader.h
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

#import <Foundation/Foundation.h>
#import "CKPointObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CKPointObjectDownloader<CKOpenDataType : CKPointObject *> : NSObject

/**
 A block that can act as a success for a task.
 */
typedef void(^CKDownloaderSuccessBlock)(__kindof CKPointObjectDownloader *downloader, NSArray<CKOpenDataType> *points);

/**
 A block that can act as a failure for a task.
 */
typedef void(^CKDownloaderFailureBlock)(__kindof CKPointObjectDownloader *downloader, NSError *error);

/**
 A block that can act as a progress for a task.
 */
typedef void(^CKDownloaderProgressBlock)(__kindof CKPointObjectDownloader *downloader, CGFloat progress, long long byteCount);

@property (nonatomic, readonly, copy) NSURL *url;

@property (nonatomic, readonly) NSArray<CKOpenDataType> *points;

@property (nonatomic, readonly) NSError *error;

- (void)setCompletionBlockWithSuccess:(CKDownloaderSuccessBlock)success failure:(nullable CKDownloaderFailureBlock)failure;

@property (nonatomic, readonly) CGFloat progress;

@property (nonatomic, readonly) long long byteCount;

@property (nonatomic, strong, nullable) CKDownloaderProgressBlock progressBlock;

- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) __kindof CKPointObject *(^parserBlock)(NSDictionary *json);

- (void)resume;

- (void)pause;

- (void)cancel;

@end


NS_ASSUME_NONNULL_END
