//
//  Loader.h
//  EasyAlbum
//
//  Created by xl on 12-1-13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEFAULT_DATA_LEN	1024

@interface Loader : NSObject {
	NSURL *url;
	NSMutableData *data;
	NSURLConnection *connection;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableData *data;

- (id)initWithURL:(NSURL *)url;
- (void)load;
- (void)cancel;

@end
