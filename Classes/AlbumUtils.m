//
//  AlbumUtils.m
//  EasyAlbum
//
//  Created by Liu Nan on 12-1-11.
//  Copyright 2012 Liu Nan. All rights reserved.
//

#import "AlbumUtils.h"

@implementation AlbumUtils

+ (BOOL)isFileExsit:(NSString *)filePath
{
	if (!filePath) {
		return NO;
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:filePath];
}

+ (UIImage *)resizePhoto:(UIImage *)originPhoto
{
	if (!originPhoto) {
		return nil;
	}
	
	NSLog(@"%f, %f\n", originPhoto.size.width, originPhoto.size.height);
	float scale = 1.0;
	if (originPhoto.size.width > 1024) {
		scale = 1024 / originPhoto.size.width;
	} else if(originPhoto.size.height > 768){
		scale = 768 / originPhoto.size.height;
	}
	
	if (scale < 1.0) {
		UIGraphicsBeginImageContext(CGSizeMake(originPhoto.size.width * scale, originPhoto.size.height * scale));
		[originPhoto drawInRect:CGRectMake(0, 0, originPhoto.size.width * scale, originPhoto.size.height * scale)];
		originPhoto = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	NSLog(@"%f, %f\n", originPhoto.size.width, originPhoto.size.height);
	return originPhoto;
}

+ (UIImage*)resizePhotoAndStore:(NSString*)imagePath
{
	if (![AlbumUtils isFileExsit:imagePath]) {
		return nil;
	}
	
	EAFileType type = [AlbumUtils detectFileType:imagePath];
	if (!(type == EA_PNG || type == EA_JPG || type == EA_JPEG)) {
		return nil;
	}
	
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	if (!image) {
		return nil;
	}
	image = [AlbumUtils resizePhoto:image];
	if (type == EA_PNG) {
		[UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
	} else {
		[UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
	}
	return image;
}

+(EAFileType) detectFileType:(NSString *)fileName
{
	NSArray *extNames = [NSArray arrayWithObjects:@"png", @"jpg", @"gif", @"bmp", @"jpeg", nil];	
	EAFileType extType[] = {EA_PNG, EA_JPG, EA_GIF, EA_BMP, EA_JPEG};
	if (fileName) {
		NSString *extension = [fileName pathExtension];	
		if (extension) {
			for (int i = 0; i < [extNames count]; ++i) {
				//	NSLog(@"%@: %@\n", extension, [extNames objectAtIndex:i]);
				if ([extension caseInsensitiveCompare:[extNames objectAtIndex:i]] == 0 ) {
					return extType[i];
				}
				
			}
		}
	}
	return EA_UNKOWN;	 
}

+ (BOOL)isSupportedFile:(NSString *)name
{
	if (!name) {
		return NO; 
	}   
    
	EAFileType type = [AlbumUtils detectFileType:name];
	return type != EA_UNKOWN; 
}

@end
