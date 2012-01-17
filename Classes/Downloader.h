//
//  Downloader.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-13.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Loader.h"

@protocol LoaderDelegate;
@protocol DownloadDelegate;

@interface Downloader : NSObject <LoaderDelegate> {
	id <DownloadDelegate> delegate;
}

@property (nonatomic, assign) id <DownloadDelegate> delegate;

+ (id)defaultDownloader;
- (BOOL)startDownloadURL:(NSURL *)url;
+ (long long)sizeOfFileFor:(NSURL *)url;
+ (unsigned long long)progressFor:(NSURL *)url;

@end

@protocol DownloadDelegate <NSObject>

@optional
- (void)downloadDidFailed:(NSURL *)url withError:(NSInteger)errorCode;
- (void)downloadDidFinished:(NSURL *)url withLocalPath:(NSString *)path;

@end