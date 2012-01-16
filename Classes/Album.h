//
//  Album.h
//  EasyAlbum
//
//  Created by Liu Nan on 11-12-24.
//  Copyright 2011 Liu Nan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIScrollView;
@protocol EasyAlbumDelegate;

@interface Album : UIViewController <UIScrollViewDelegate> {
	UIScrollView *pagingScrollView;
	NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	NSMutableArray *imageLocalPathList;
	NSArray *imageURLList;
	NSInteger curIndex;
	BOOL isFullScreen;
	NSUInteger imageCount;
	id<EasyAlbumDelegate> delegate;
	CGRect originalFrame;
	CGSize imageSize;
}

@property (nonatomic, retain) NSMutableArray *imageLocalPathList;
@property (nonatomic, assign) id<EasyAlbumDelegate> delegate;
@property (nonatomic) NSInteger curIndex;
@property (nonatomic) NSUInteger imageCount;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) CGSize imageSize;

@end

@interface Album (AlbumInit) 

- (id)initWithAlbumFrame:(CGRect)frame;
- (void)setAlbumSize:(CGSize)size;

@end

@interface Album (AlbumImage) 

- (void)setImageList:(NSArray *)list withCurrentIndex:(NSUInteger)index;
- (void)setURLList:(NSArray *)list withCurrentIndex:(NSUInteger)index;

- (void)updateImageAtIndex:(NSInteger)index;
- (void)updateImageWithPath:(NSString *)imagePath;

- (void)addView:(UIView *)customView aboveImageAtIndex:(NSInteger)index;
- (void)addView:(UIView *)customView aboveImageAtPath:(NSString *)imagePath;
- (void)removeCustomViewAtIndex:(NSInteger)index;
- (void)removeCustomViewAtPath:(NSString *)imagePath;

@end

@interface Album (AlbumControl) 

- (void)enterFullScreen;
- (void)exitFullScreen;

@end

@interface Album (AlbumQuery) 

- (NSString *)imagePathAtIndex:(NSUInteger)index;
- (NSString *)currentImagePath;

@end

@interface Album (AlbumSlide) 

- (void)slideToNextWithAnimation:(BOOL)animated;
- (void)slideToPrevWithAnimation:(BOOL)animated;
- (void)slideToIndex:(NSInteger)index withAnimation:(BOOL)animated;

@end

@protocol EasyAlbumDelegate <NSObject>

@optional
- (void)imageWillLoad:(Album *)album withPath:(NSString *)imageLocalPath; 
- (void)imageDidLoad:(Album *)album withPath:(NSString *)imageLocalPath errorCode:(NSInteger)code; 

- (void)imageWillSlide:(Album *)album withPath:(NSString *)imageLocalPath ofIndex:(NSUInteger)index;
- (void)imageDidSlide:(Album *)album withPath:(NSString *)imageLocalPath ofIndex:(NSUInteger)index;

- (void)albumEnterToFullScreen:(Album *)album;
- (void)albumExitFromeFullScreen:(Album *)album;

- (void)tapImageAlbum:(Album *)album;

@end
