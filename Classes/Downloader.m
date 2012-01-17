//
//  Downloader.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-13.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import "Downloader.h"
#import "Loader.h"

static Downloader *g_downloader;
static NSMutableDictionary *loaderDic;   //key: url value: Loader

@implementation Downloader

@synthesize delegate;

+ (id)defaultDownloader
{
	if (!g_downloader) {
		g_downloader = [[Downloader alloc] init];
		loaderDic = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return g_downloader;
}

- (void)dealloc
{
	for (Loader *loader in [loaderDic allValues]) {
		[loader cancel];
	}
	
	[loaderDic removeAllObjects];
	[loaderDic release];
	loaderDic = nil;
	delegate = nil;
	g_downloader = nil;
	[super dealloc];
}

- (BOOL)startDownloadURL:(NSURL *)url
{
	if (!url || !loaderDic) {
		return NO;
	}
	
	if ([loaderDic objectForKey:url]) {
		return YES;		//url is in downloading
	} 

	Loader *loader = [[Loader alloc] initWithURL:url];
	loader.delegate = self;
	[loader load];
	[loaderDic setObject:loader forKey:url];
	[loader release];
	return YES;
}

- (void)loadDidFailed:(NSURL *)url withError:(NSInteger)errorCode
{
	[loaderDic removeObjectForKey:url];
	if (delegate && [delegate respondsToSelector:@selector(downloadDidFailed:withError:)]) {
		[delegate downloadDidFailed:url withError:errorCode];
	}
}

- (void)loadDidFinished:(NSURL *)url withLocalPath:(NSString *)path
{
	[loaderDic removeObjectForKey:url];
	if (delegate && [delegate respondsToSelector:@selector(downloadDidFinished:withLocalPath:)]) {
		[delegate downloadDidFinished:url withLocalPath:path];
	}
}

+ (long long)sizeOfFileFor:(NSURL *)url
{
	Loader *loader = [loaderDic objectForKey:url];
	if (loader) {
		return loader.size;
	}
	return -1;
}

+ (unsigned long long)progressFor:(NSURL *)url
{
	Loader *loader = [loaderDic objectForKey:url];
	if (loader) {
		return loader.progress;
	}
	return -1;
}

@end
