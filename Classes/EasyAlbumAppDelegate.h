//
//  EasyAlbumAppDelegate.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EasyAlbumViewController;

@interface EasyAlbumAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EasyAlbumViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) EasyAlbumViewController *viewController;

@end

