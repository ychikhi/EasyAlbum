//
//  AlbumCell.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIScrollView;

@interface AlbumCell : UIScrollView <UIScrollViewDelegate> {
    UIImageView *imageView;
    NSUInteger   index;
	NSString	*imagePath;
	UIWebView *webView; //for gif
	UIView *customView;
	CGSize imageSize;
}

@property (nonatomic, retain) NSString	*imagePath;
@property (nonatomic, retain) UIView *customView;
@property (nonatomic) NSUInteger index;

- (void)displayImagePath:(NSString *)path withSize:(CGSize)size;
- (BOOL)isSuccessLoadImage;
- (void)updateImage;
- (void)addCustomView:(UIView *)view;
- (void)removeCustomView;

@end
