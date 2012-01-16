//
//  AlbumUtils.h
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BASE_LOCAL_PATH_DIR	@"photos"

typedef enum {
	EA_UNKOWN,
	EA_GIF,
	EA_PNG,
	EA_JPG,
	EA_JPEG,
	EA_BMP,
} EAFileType;

@interface AlbumUtils : NSObject {
}

+ (BOOL)isFileExsit:(NSString *)filePath;
+ (UIImage *)resizePhoto:(UIImage *)originPhoto;
+ (UIImage*)resizePhotoAndStore:(NSString*)imagePath;
+ (EAFileType) detectFileType:(NSString *)fileName;
+ (BOOL)isSupportedFile:(NSString *)name;
+ (NSString *)localPathForURL:(NSURL *)url;
+ (BOOL)isDirExsit:(NSString *)dirPath;

@end

