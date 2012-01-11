//
//  AlbumCell.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import "AlbumCell.h"
#import "AlbumUtils.h"

@interface AlbumCell (AlbumCellPrivate)

- (void)doLoadImage;
@end

@implementation AlbumCell

@synthesize index;
@synthesize imagePath;
@synthesize customView;

#pragma mark -
#pragma mark init

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;   
		self.maximumZoomScale = 2.0;
		self.minimumZoomScale = 1.0;
		self.backgroundColor = [UIColor blackColor];
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[imagePath release];
	[customView release];
    [super dealloc];
}

#pragma mark -
#pragma mark display

- (void)displayImagePath:(NSString *)path withSize:(CGSize)size
{
    // clear the previous imageView
	if (imageView) {
		[imageView removeFromSuperview];
		[imageView release];
		imageView = nil;
	}
	
	if (webView) {
		[webView removeFromSuperview];
		[webView release];
		webView = nil;
	}
	[self removeCustomView];
	self.imagePath = path;
	imageSize = size;
	[self doLoadImage];
}

- (void)updateImage
{
	[self doLoadImage];
}

- (BOOL)isSuccessLoadImage
{
	if (!imageView || !imageView.image) {
		return NO;
	}
	return YES;
}

- (void)addCustomView:(UIView *)view
{
	self.customView = view;
	[self addSubview:view];
}

- (void)removeCustomView
{
	if (customView) {
		[customView removeFromSuperview];
		[customView release];
		customView = nil;
	}
}

#pragma mark -
#pragma mark delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

#pragma mark -
#pragma mark private

- (void)doLoadImage
{
	if (!imagePath) {
		return;
	}
	
	if ([AlbumUtils detectFileType:imagePath] == EA_GIF) {
		NSData *gif = [NSData dataWithContentsOfFile:imagePath];
		UIImage *tmpImage = [UIImage imageWithData:gif];
		CGRect webViewFrame;
		if (tmpImage) {
			webViewFrame = CGRectMake((self.frame.size.width-tmpImage.size.width)/2, (self.frame.size.height-tmpImage.size.height)/2, tmpImage.size.width, tmpImage.size.height);
			
		} else {
			webViewFrame = CGRectMake(400, 200, 100, 100);
		}
		webView = [[UIWebView alloc] initWithFrame:webViewFrame];
		[webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
		[self addSubview:webView];
	} else {
		// reset our zoomScale to 1.0 before doing any further calculations
		self.zoomScale = 1.0;
		// make a new UIImageView for the new image
		
		UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

		//NSLog(@"%f, %f, %f, %f\n", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
		CGRect imageFrame = CGRectMake((self.frame.size.width - imageSize.width) / 2, (self.frame.size.height - imageSize.height) / 2, imageSize.width, imageSize.height);
		imageView = [[UIImageView alloc] initWithFrame:imageFrame];
		
		if (image.size.width > 1024 || image.size.height > 768) {
			if ((image = [AlbumUtils resizePhotoAndStore:imagePath]) != nil) {
				//none;
			} else {
				image = [AlbumUtils resizePhoto:image];
			}
		} 
		
		if (image.size.width > imageView.frame.size.width || image.size.height > imageView.frame.size.height) {
			imageView.contentMode = UIViewContentModeScaleAspectFit;
		} else {
			imageView.contentMode = UIViewContentModeCenter;
		}
		
		imageView.image = image;
		[self addSubview:imageView];
		self.contentSize = [image size];
		self.zoomScale = self.minimumZoomScale;
	}
}

@end
