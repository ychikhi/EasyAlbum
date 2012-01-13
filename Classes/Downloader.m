//
//  Downloader.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-13.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import "Downloader.h"

static Downloader *g_downloader;
static NSMutableDictionary *connectionDic;   //key: url value: NSURLConnection

@implementation Downloader

+ (id)defaultDownloader
{
	if (!g_downloader) {
		g_downloader = [[Downloader alloc] init];
		connectionDic = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return g_downloader;
}

- (void)dealloc
{
	for (NSURLConnection *connection in [connectionDic allValues]) {
		[connection cancel];
	}
	
	[connectionDic removeAllObjects];
	[connectionDic release];
	g_downloader = nil;
	[super dealloc];
}

- (BOOL)startDownloadURL:(NSURL *)url
{
	if (!url || !connectionDic) {
		return NO;
	}
	
	if ([connectionDic objectForKey:url]) {
		return YES;		//url is in downloading
	} 

	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
	[connectionDic setObject:connection forKey:url];
	return YES;
}

@end
