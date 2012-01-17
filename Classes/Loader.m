//
//  Loader.m
//  EasyAlbum
//
//  Created by xl on 12-1-13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Loader.h"
#import "AlbumUtils.h"

@implementation Loader

@synthesize url;
@synthesize data;
@synthesize delegate;
@synthesize progress;
@synthesize size;

- (id)initWithURL:(NSURL *)aUrl
{
	self = [super init];
	if (self) {
		self.url = aUrl;
		data = [[NSMutableData alloc] initWithCapacity:DEFAULT_DATA_LEN];
		progress = 0;
	}
	return self;
}

- (void)dealloc 
{
	[url release];
	[data release];
	[connection cancel];
	[super dealloc];
}

- (void)load
{
	if (connection) {
		return;
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
}

- (void)cancel
{
	[connection cancel];
}

- (void) connection: (NSURLConnection *)conn didReceiveResponse: (NSURLResponse *)response
{
	size = [response expectedContentLength];
}

- (void) connection: (NSURLConnection *)conn didFailWithError: (NSError *)error
{
	if (delegate && [delegate respondsToSelector:@selector(loadDidFailed:withError:)]) {
		[delegate loadDidFailed:url withError:-1];
	}
}

- (void) connection: (NSURLConnection *) conn didReceiveData: (NSData *) moreData
{
	[data appendData:moreData];
	progress += [moreData length];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) conn
{
	NSString *localPath = [AlbumUtils localPathForURL:url];
	NSString *dirPath = [localPath stringByDeletingLastPathComponent];
	if (![AlbumUtils isDirExsit:dirPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];

	}
	if (![AlbumUtils isFileExsit:localPath]) {
		NSFileManager *manager = [NSFileManager defaultManager];
		[manager createFileAtPath:localPath contents:nil attributes:nil];
	}
	
	if ([data writeToFile:localPath atomically:YES]) {
		if (delegate && [delegate respondsToSelector:@selector(loadDidFinished:withLocalPath:)]) {
			[delegate loadDidFinished:url withLocalPath:localPath];
		}
	} else {
		if (delegate && [delegate respondsToSelector:@selector(loadDidFailed:withError:)]) {
			[delegate loadDidFailed:url withError:1];
		}
	}
}

@end
