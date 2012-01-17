//
//  Loader.h
//  EasyAlbum
//
//  Created by xl on 12-1-13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEFAULT_DATA_LEN	1024

@protocol LoaderDelegate;

@interface Loader : NSObject {
	NSURL *url;
	NSMutableData *data;
	NSURLConnection *connection;
	id <LoaderDelegate> delegate;
	unsigned long long progress;
	long long size;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) id <LoaderDelegate> delegate;
@property (nonatomic, readonly) unsigned long long progress;
@property (nonatomic, readonly) long long size;

- (id)initWithURL:(NSURL *)url;
- (void)load;
- (void)cancel;

@end

@protocol LoaderDelegate <NSObject>

- (void)loadDidFailed:(NSURL *)url withError:(NSInteger)errorCode;
- (void)loadDidFinished:(NSURL *)url withLocalPath:(NSString *)path;

@end

