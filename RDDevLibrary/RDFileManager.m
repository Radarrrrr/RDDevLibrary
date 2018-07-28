//
//  RDFileManager.m
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "RDFileManager.h"



@implementation RDFileManager



#pragma mark -
#pragma mark in use functions
+ (BOOL)checkIfTheVersionUpdated
{
	BOOL bUpdated = YES;
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *lastVersion = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
	
	if(lastVersion != nil && [lastVersion compare:version] == NSOrderedSame) 
	{
		bUpdated = NO;
	}
	
	return bUpdated;
}





#pragma mark -
#pragma mark out use functions
+ (BOOL)writeDictionaryToFile:(NSString*)fileName withData:(NSDictionary*)dic
{
	if(!dic) return NO;
	
	NSString *path = [self getPathForFileName:fileName];
	BOOL bSuccess = [dic writeToFile:path atomically:YES];

	return bSuccess;
}
+ (NSDictionary*)dictionaryFromFile:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
	return dic;
}

+ (BOOL)writeArrayToFile:(NSString*)fileName withData:(NSArray*)array
{
	if(!array) return NO;
	
	NSString *path = [self getPathForFileName:fileName];
	BOOL bSuccess = [array writeToFile:path atomically:YES];
	
	return bSuccess;
}
+ (NSArray*)arrayFromFile:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	NSArray *array = [NSArray arrayWithContentsOfFile:path];
	return array;	
}

+ (BOOL)writePhotoToFile:(NSString*)fileName withData:(UIImage*)photo
{
	if(!photo) return NO;
	
	NSData *photoData = UIImageJPEGRepresentation(photo, 1.0);
	NSString *path = [self getPathForFileName:fileName];
	BOOL bSuccess = [photoData writeToFile:path atomically:YES];
	
	return bSuccess;
}
+ (UIImage*)photoFromFile:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	UIImage *photo = [UIImage imageWithContentsOfFile:path];
	return photo;	
}

+ (BOOL)writeDataToFile:(NSString*)fileName withData:(NSData*)data
{
	if(!data) return NO;
	
	NSString *path = [self getPathForFileName:fileName];
	BOOL bSuccess = [data writeToFile:path atomically:YES];
	
	return bSuccess;
}
+ (NSData*)dataFromFile:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	NSData *data = [NSData dataWithContentsOfFile:path];
	return data;	
}


+ (BOOL)deleteFileForName:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	BOOL bExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if(!bExist) return YES;
	
	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	if(error != nil) return NO;
	
	return YES;
}
+ (NSString*)getPathForFileName:(NSString*)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	//NSLog(@"%@", path);
	
	return path;
}

+ (void)checkAndCreateFileForName:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if(success) 
	{
		BOOL bUpdated = [self checkIfTheVersionUpdated];
		if(bUpdated)
		{
			//remove the old file
			[self deleteFileForName:fileName];
		}
		else
		{
			return;
		}
	}
	
	[self moveBundleFileToDocument:fileName];
}
+ (void)moveBundleFileToDocument:(NSString*)fileName
{
	NSString *path = [self getPathForFileName:fileName];
	NSString *pathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	[[NSFileManager defaultManager] copyItemAtPath:pathFromApp toPath:path error:nil];

	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}




@end
