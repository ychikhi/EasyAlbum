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

@interface EasyAlbumViewController(EasyAlbumViewControllerPrivate)

- (void)addProgress;
- (void)startProgressTimer;
- (void)stopProgressTimer;
- (void)refreshProgress:(NSTimer *)timer;

@end


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
	URLArray = [[NSArray arrayWithObjects:
						 @"http://hiphotos.baidu.com/yxl517/pic/item/b1f28e2c20927fb398250ac3.jpg",
						 @"http://hiphotos.baidu.com/yxl517/pic/item/42a2ccf59a51308e7831aacc.jpg",
						 @"http://hiphotos.baidu.com/yxl517/pic/item/77976eb1cf85b13e8ad4b2cd.jpg",
						 @"http://hiphotos.baidu.com/yxl517/pic/item/4d3a252676b43e09ac34dece.jpg", nil] retain];
	[album setURLList:URLArray withCurrentIndex:0];
}

- (void)addProgress
{
	UIScreen *screen = [UIScreen mainScreen];
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
	//customView.backgroundColor = [UIColor whiteColor];
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicator.frame = CGRectMake((screen.bounds.size.width - 30)/2, (screen.bounds.size.height - 30)/2, 30, 30);
	[customView addSubview:indicator];
	[indicator startAnimating];
	[indicator release];
	if (!progressLabel) {
		CGRect labelFrame = CGRectMake(0, indicator.frame.origin.y - 30, 320, 40);
		progressLabel = [[UILabel alloc] initWithFrame:labelFrame];
		progressLabel.textColor = [UIColor whiteColor];
		progressLabel.backgroundColor = [UIColor clearColor];
		progressLabel.textAlignment = UITextAlignmentCenter;
	}
	[customView addSubview:progressLabel];
	[album addView:customView aboveImageAtIndex:album.curIndex];
	//[customView release];
	[self startProgressTimer];
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
	[album removeCustomViewAtPath:path];
	[album updateImageWithPath:path];
	[self stopProgressTimer];
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
	[progressTimer invalidate];
	[progressTimer release];
	[progressLabel release];
    [super dealloc];
}

- (void)startProgressTimer
{
	if (!progressTimer) {
		progressTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(refreshProgress:) userInfo:nil repeats:YES] retain];
	}
}

- (void)stopProgressTimer
{
	[progressTimer invalidate];
	[progressTimer release];
	progressTimer = nil;
	[progressLabel removeFromSuperview];
}

- (void)refreshProgress:(NSTimer *)timer
{
	unsigned index = album.curIndex;
	NSURL *url = nil;
	if (URLArray && [URLArray count] > index) {
		url = [NSURL URLWithString:[URLArray objectAtIndex:index]];
	}
	if (url) {
		long long size = [Downloader sizeOfFileFor:url];
		unsigned long long progress = [Downloader progressFor:url];
		progressLabel.text = [NSString stringWithFormat:@"%lld / %lld", size, progress];
	}
}

@end
