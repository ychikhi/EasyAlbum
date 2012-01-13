//
//  Downloader.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-13.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Downloader : NSObject {

}

+ (id)defaultDownloader;
- (BOOL)startDownloadURL:(NSURL *)url;

@end
