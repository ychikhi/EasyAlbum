//
//  EasyAlbumViewController.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface EasyAlbumViewController : UIViewController <EasyAlbumDelegate> {
	Album *album;
}

- (void)setPhotoWithPath;

@end

