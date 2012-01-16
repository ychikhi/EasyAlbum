//
//  EasyAlbumViewController.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#define PHOTO_COUNT	4

#import "EasyAlbumViewController.h"
#import "AlbumUtils.h"

@implementation EasyAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	album = [[Album alloc] initWithAlbumFrame:[[UIScreen mainScreen] bounds]]; //alloc and set frame to album.
	album.delegate = self;
	[album setAlbumSize: album.view.frame.size];	//set size of photo to show. 
	[self.view addSubview:album.view];
	
	downloadManager = [Downloader defaultDownloader];
	downloadManager.delegate = self;
	//[self setPhotoWithPath];
	[self setPhotoWithURL];
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

- (void)setPhotoWithURL
{
	URLArray = [[NSArray arrayWithObjects:@"http://hiphotos.baidu.com/yxl517/pic/item/b1f28e2c20927fb398250ac3.jpg",
						 @"http://hiphotos.baidu.com/yxl517/pic/item/42a2ccf59a51308e7831aacc.jpg",
						 @"http://hiphotos.baidu.com/yxl517/pic/item/77976eb1cf85b13e8ad4b2cd.jpg",
						 @"http://hiphotos.baidu.com/yxl517/pic/item/4d3a252676b43e09ac34dece.jpg", nil] retain];
	[album setURLList:URLArray withCurrentIndex:0];
}

- (void)addProgress
{
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	UIScreen *screen = [UIScreen mainScreen];
	indicator.frame = CGRectMake((screen.bounds.size.width - 30)/2, (screen.bounds.size.height - 30)/2, 30, 30);
	[indicator startAnimating];
	[album addView:indicator aboveImageAtIndex:album.curIndex];
	[indicator release];
}

- (void)imageDidSlide:(Album *)album withPath:(NSString *)imageLocalPath ofIndex:(NSUInteger)index
{
	if (![AlbumUtils isFileExsit:imageLocalPath]) {
		[downloadManager startDownloadURL:[NSURL URLWithString:[URLArray objectAtIndex:index]]];
		[self addProgress];
	}
}

- (void)downloadDidFinished:(NSURL *)url withLocalPath:(NSString *)path
{
	[album updateImageWithPath:path];
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
	[URLArray release];
    [super dealloc];
}

@end
