//
//  EasyAlbumViewController.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "Downloader.h"

@interface EasyAlbumViewController : UIViewController <EasyAlbumDelegate, DownloadDelegate> {
	Album *album;
	Downloader *downloadManager;
	NSArray *URLArray;
}

- (void)setPhotoWithPath;
- (void)setPhotoWithURL;

@end

