//
//  EasyAlbumViewController.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#define PHOTO_COUNT	4

#import "EasyAlbumViewController.h"

@implementation EasyAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	album = [[Album alloc] initWithAlbumFrame:[[UIScreen mainScreen] bounds]]; //alloc and set frame to album.
	[album setAlbumSize: album.view.frame.size];	//set size of photo to show. 
	[self.view addSubview:album.view];
	
	[self setPhotoWithPath];
}

- (void)setPhotoWithPath
{
	NSMutableArray *pathArray = [[NSMutableArray alloc] initWithCapacity:PHOTO_COUNT];
	for (int i = 1; i < PHOTO_COUNT + 1; ++i) {
		NSString *photoPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", i] ofType:@"jpg"];
		[pathArray addObject:photoPath];
	}
	[album setImageList:pathArray withCurrentIndex:0];
	[pathArray release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[album release];
	album = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[album release];
    [super dealloc];
}

@end
