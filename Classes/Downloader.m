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
	[loader load];
	[loaderDic setObject:loader forKey:url];
	[loader release];
	return YES;
}

@end
