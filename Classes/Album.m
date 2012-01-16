//
//  Album.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import "Album.h"
#import "AlbumCell.h"
#import "AlbumUtils.h"

@interface Album (AlbumPrivate)

- (void)refreshContentSize;
- (void)tilePages;
- (void)configurePage:(AlbumCell *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (AlbumCell *)dequeueRecycledPage;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)tapImageAction:(UITapGestureRecognizer *)recognizer;

@end

@implementation Album

@synthesize imageLocalPathList;
@synthesize curIndex;
@synthesize isFullScreen;
@synthesize imageCount;
@synthesize delegate;
@synthesize imageSize;

#pragma mark -
#pragma mark init

- (void)loadView {
	UIView *view = [[UIView alloc] init];
	self.view = view;
	
	pagingScrollView = [[UIScrollView alloc] init];
    pagingScrollView.pagingEnabled = YES;
    pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.delegate = self;
    [view addSubview: pagingScrollView];
	[view release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] init] autorelease];
	[tap addTarget:self action:@selector(tapImageAction:)];
	[self.view addGestureRecognizer:tap];
	curIndex = 0;
	isFullScreen = NO;
}

- (void)dealloc {
	[imageLocalPathList release];
	[imageURLList release];
    [super dealloc];
}

- (id)initWithAlbumFrame:(CGRect)frame
{
	self = [super init];
	self.view.frame = frame;
	[self setAlbumSize:frame.size];
	return self;
}

- (void)setAlbumSize:(CGSize)size
{
	imageSize = size;
	CGRect oldFrame = self.view.frame;
	self.view.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, size.width, size.height);
	pagingScrollView.frame = self.view.frame;
	[self refreshContentSize];
}

#pragma mark -
#pragma mark image

- (void)setImageList:(NSArray *)list withCurrentIndex:(NSUInteger)index
{
	if (!list || index >= [list count]) {
		return;
	}
	
	if (recycledPages) {
		[recycledPages removeAllObjects];
	}
	recycledPages = [[NSMutableSet alloc] initWithCapacity:2];
	
	if (visiblePages) {
		[visiblePages removeAllObjects];
	}
    visiblePages = [[NSMutableSet alloc] initWithCapacity:2];
	self.imageLocalPathList = [NSMutableArray arrayWithArray:list] ;
	imageCount = [imageLocalPathList count];
	[self refreshContentSize];
	[self slideToIndex:index withAnimation:NO];
	[self tilePages];
	[self scrollViewDidEndDecelerating:pagingScrollView];
}

- (void)setURLList:(NSArray *)list withCurrentIndex:(NSUInteger)index
{
	if (!list || index >= [list count]) {
		return;
	}
	
	imageURLList = list;
	NSMutableArray *pathList = [[NSMutableArray alloc] initWithCapacity:[list count]];
	for (NSString *url in list) {
		NSString *localPath = [AlbumUtils localPathForURL:[NSURL URLWithString:url]];
		[pathList addObject:localPath];
	}
	
	[self setImageList:pathList withCurrentIndex:index];
	[pathList release];
}

- (void)updateImageAtIndex:(NSInteger)index
{
	if (index >= imageCount) {
		return;
	}
	
	for (AlbumCell *imageCell in visiblePages) {
		if (imageCell.index == index) {
			[imageCell updateImage];
			return;
		}
	}
	
	for (AlbumCell *imageCell in recycledPages) {
		if (imageCell.index == index) {
			[imageCell updateImage];
			return;
		}
	}
}

- (void)updateImageWithPath:(NSString *)imagePath
{
	int index = 0;
	for (; index < imageCount - 1; ++index) {
		if ([imagePath isEqualToString:[imageLocalPathList objectAtIndex:index]]) {
			break;
		}
	}
	if (index < imageCount) {
		[self updateImageAtIndex:index];
	}
}

- (void)addView:(UIView *)customView aboveImageAtIndex:(NSInteger)index
{
	if (index >= imageCount) {
		return;
	}
	
	for (AlbumCell *imageCell in visiblePages) {
		if (imageCell.index == index) {
			[imageCell addCustomView:customView];
			return;
		}
	}
	
	for (AlbumCell *imageCell in recycledPages) {
		if (imageCell.index == index) {
			[imageCell addCustomView:customView];
			return;
		}
	}
}

- (void)addView:(UIView *)customView aboveImageAtPath:(NSString *)imagePath
{
	int index = 0;
	for (; index < imageCount - 1; ++index) {
		if ([imagePath isEqualToString:[imageLocalPathList objectAtIndex:index]]) {
			break;
		}
	}
	if (index < imageCount) {
		[self addView:customView aboveImageAtIndex:index];
	}
}

- (void)removeCustomViewAtIndex:(NSInteger)index
{
	if (index >= imageCount) {
		return;
	}
	
	for (AlbumCell *imageCell in visiblePages) {
		if (imageCell.index == index) {
			[imageCell removeCustomView];
			return;
		}
	}
	
	for (AlbumCell *imageCell in recycledPages) {
		if (imageCell.index == index) {
			[imageCell removeCustomView];
			return;
		}
	}
}

- (void)removeCustomViewAtPath:(NSString *)imagePath
{
	int index = 0;
	for (; index < imageCount - 1; ++index) {
		if ([imagePath isEqualToString:[imageLocalPathList objectAtIndex:index]]) {
			break;
		}
	}
	if (index < imageCount) {
		[self removeCustomViewAtIndex:index];
	}
}

#pragma mark -
#pragma mark control

- (void)enterFullScreen
{
	if (isFullScreen) {
		return;
	}
	
	originalFrame = self.view.frame;
	CGRect newFrame = [[UIScreen mainScreen] bounds];
	//	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	//	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
	if (newFrame.size.width < newFrame.size.height) {
		float tmpWidth = newFrame.size.width;
		newFrame.size.width = newFrame.size.height;
		newFrame.size.height = tmpWidth;
	}
	//NSLog(@"%f, %f, %f, %f\n", newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
	
	self.view.frame = newFrame;
	[self setAlbumSize:newFrame.size];
	isFullScreen = YES;
	[visiblePages removeAllObjects];
	[self tilePages];
	[self slideToIndex:curIndex withAnimation:NO];
	if (delegate && [delegate respondsToSelector:@selector(albumEnterToFullScreen:)]) {
		[delegate albumEnterToFullScreen:self];
	}
}

- (void)exitFullScreen
{
	if (!isFullScreen) {
		return;
	}
	
	self.view.frame = originalFrame;
	[self setAlbumSize:originalFrame.size];
	isFullScreen = NO;
	[visiblePages removeAllObjects];
	[self tilePages];
	[self slideToIndex:curIndex withAnimation:NO];
	if (delegate && [delegate respondsToSelector:@selector(albumExitFromeFullScreen:)]) {
		[delegate albumExitFromeFullScreen:self];
	}
}


#pragma mark -
#pragma mark slide

- (void)slideToNextWithAnimation:(BOOL)animated
{
	if (curIndex < imageCount) {
		[self slideToIndex:++curIndex withAnimation:animated];
	}
}

- (void)slideToPrevWithAnimation:(BOOL)animated
{
	if (curIndex > 0) {
		[self slideToIndex:--curIndex withAnimation:animated];
	}
}

- (void)slideToIndex:(NSInteger)index withAnimation:(BOOL)animated
{
	if (index >= 0 && index < imageCount) {
		curIndex = index;
		CGPoint contentOffset = CGPointMake(curIndex * self.view.frame.size.width, 0);
		[pagingScrollView setContentOffset:contentOffset animated:animated]; 
	}
}

#pragma mark -
#pragma mark private

- (void)tilePages 
{
	if (!pagingScrollView) {
		return;
	}
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages 
    for (AlbumCell *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
			[page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
			
            AlbumCell *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[AlbumCell alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)] autorelease];
			}
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        } else {
			self.curIndex = index;
		}
    }    
}

- (void)configurePage:(AlbumCell *)page forIndex:(NSUInteger)index
{
    page.index = index;
	//CGRect pageFrame = [self frameForPageAtIndex:index];
    page.frame = [self frameForPageAtIndex:index];
	//NSLog(@"%d:%f, %f, %f, %f\n", index, page.frame.origin.x, page.frame.origin.y, page.frame.size.width, page.frame.size.height);
	NSString *imagePath = [self imagePathAtIndex:index];
	if (delegate && [delegate respondsToSelector:@selector(imageWillLoad:withPath:)]) {
		[delegate imageWillLoad:self withPath:imagePath];
	}
	//unsigned int orientation = imagePreview.orientation;
	//if (orientation == 0) {
	//	orientation = [[UIDevice currentDevice] orientation];
	//}
	//if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {
	[page displayImagePath:imagePath withSize:imageSize];
	//} else {
	//	[page displayImagePath:imagePath];
	//}
	if (delegate && [delegate respondsToSelector:@selector(imageDidLoad:withPath:errorCode:)]) {
		NSInteger retcode = 0;
		if (![page isSuccessLoadImage]) {
			retcode = -1;
		} 
		[delegate imageDidLoad:self withPath:imagePath errorCode:retcode];
	}
}

- (AlbumCell *)dequeueRecycledPage
{
    AlbumCell *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (NSString *)imagePathAtIndex:(NSUInteger)index
{
	if (index < imageCount) {
		return [imageLocalPathList objectAtIndex:index];
	}
	return nil;
}

- (NSString *)currentImagePath
{
	return [imageLocalPathList objectAtIndex:curIndex];
}

- (void)refreshContentSize
{
	pagingScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [imageLocalPathList count], 0);
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (AlbumCell *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
    CGRect pageFrame = self.view.frame;
	pageFrame.origin.x = (self.view.frame.size.width * index);
	pageFrame.origin.y = 0;
    return pageFrame;
}

- (void)tapImageAction:(UITapGestureRecognizer *)recognizer
{
	if (delegate && [delegate respondsToSelector:@selector(tapImageAlbum:)]) {
		[delegate tapImageAlbum:self];
	}
}

#pragma mark -
#pragma mark delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if (delegate && [delegate respondsToSelector:@selector(imageWillSlide:withPath:ofIndex:)]) {
		[delegate imageWillSlide:self withPath:[self currentImagePath] ofIndex:curIndex];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (delegate && [delegate respondsToSelector:@selector(imageDidSlide:withPath:ofIndex:)]) {
		[delegate imageDidSlide:self withPath:[self currentImagePath] ofIndex:curIndex];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark system

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
