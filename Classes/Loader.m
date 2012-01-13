//
//  Loader.m
//  EasyAlbum
//
//  Created by xl on 12-1-13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Loader.h"


@implementation Loader

@synthesize url;
@synthesize data;

- (id)initWithURL:(NSURL *)aUrl
{
	self = [super init];
	if (self) {
		self.url = aUrl;
		data = [[NSMutableData alloc] initWithCapacity:DEFAULT_DATA_LEN];
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

@end
