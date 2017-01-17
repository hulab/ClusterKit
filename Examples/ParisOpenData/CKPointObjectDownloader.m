// CKPointObjectDownloader.m
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

#import "CKPointObjectDownloader.h"

@interface CKPointObjectDownloader () <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) CKDownloaderSuccessBlock successBlock;
@property (nonatomic, strong) CKDownloaderFailureBlock failureBlock;

@property (nonatomic, weak) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSData *resumeData;
@end

@implementation CKPointObjectDownloader

- (instancetype)init {
    return [self initWithURL:[NSURL new]];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url.copy;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
        _successBlock = ^(CKPointObjectDownloader *downloader, NSArray *points) {};
        _failureBlock = ^(CKPointObjectDownloader *downloader, NSError *error) {};
        _progressBlock = ^(CKPointObjectDownloader *downloader, CGFloat progress, long long byteCount) {};
        
        _progress = -1;
        _byteCount = 0;
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(CKDownloaderSuccessBlock)success failure:(CKDownloaderFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
}

- (void)setSuccessBlock:(CKDownloaderSuccessBlock)successBlock {
    _successBlock = ^(CKPointObjectDownloader *downloader, NSArray *points) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(downloader, points);
            }
        });
    };
}

- (void)setFailureBlock:(CKDownloaderFailureBlock)failureBlock {
    _failureBlock = ^(CKPointObjectDownloader *downloader, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(downloader, error);
            }
        });
    };
}

- (void)setProgressBlock:(CKDownloaderProgressBlock)progressBlock {
    _progressBlock = ^(CKPointObjectDownloader *downloader, CGFloat progress, long long byteCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(downloader, progress, byteCount);
            }
        });
    };
}

- (void)resume {
    
    if (self.resumeData) {
        self.task= [self.session downloadTaskWithResumeData:self.resumeData];
    } else {
        self.task = [self.session downloadTaskWithURL:self.url];
    }
    
    [self.task resume];
}

- (void)pause {
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumeData = resumeData;
    }];
}

- (void)cancel {
    [self.task cancel];
}

#pragma mark <NSURLSessionDelegate>

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    self.resumeData = nil;
    
    if (downloadTask.error) {
        _error = downloadTask.error;
        self.failureBlock(self, downloadTask.error);
        return;
    }
    
    
    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithContentsOfURL:location options:0 error:&error];
    if (error) {
        _error = error;
        self.failureBlock(self, error);
        return;
    }

    NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        _error = error;
        self.failureBlock(self, error);
        return;
    }
    
    NSMutableArray *points = [NSMutableArray array];
    for (NSDictionary *json in objects) {
        CKPointObject *object = self.parserBlock? self.parserBlock(json) : [[CKPointObject alloc] initWithJSON:json];
        [points addObject:object];
    }
    
    _points = points.copy;
    self.successBlock(self, _points);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    _progress = totalBytesExpectedToWrite > 0? totalBytesWritten / totalBytesExpectedToWrite : -1;
    _byteCount = totalBytesWritten;
    
    self.progressBlock(self, _progress, _byteCount);
}

@end
