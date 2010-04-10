#import <Foundation/Foundation.h>
#import "NSDataAdditions.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
	NSString *srcPath = @"";
	NSString *destPath = @"";
	
	
	/* -----------------------------------------------------------------------------

	 DO NOT EDIT ANYTHING BELOW THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
	 
	 ----------------------------------------------------------------------------- */
	
	NSDictionary *manifest = [NSPropertyListSerialization propertyListWithData:[[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@Manifest.plist", srcPath]] valueForKey:@"Data"]
																	   options:NSPropertyListImmutable format:nil error:nil];
	
	NSDictionary *applications = [manifest objectForKey:@"Applications"];
	NSMutableDictionary *files = [[manifest objectForKey:@"Files"] mutableCopy];
	
	NSFileManager *fm = [NSFileManager defaultManager];	
	
	/* lets do applications first */
	int i;
	NSString *currDest;
	NSArray *currArray;
	
	NSLog(@"Dealing with Application backup files now");
	
	for (id key in applications) {
		currDest = [NSString stringWithFormat:@"%@Applications/%@/",destPath,key];
		currArray = [[applications objectForKey:key] objectForKey:@"Files"];
		
		NSLog(@"\tDealing with %@ now...", key);
		[fm createDirectoryAtPath:currDest withIntermediateDirectories:YES attributes:nil error:nil];		
		
		for (i=0;i<[currArray count];i++) {
			NSLog(@"\t\tMoving %@ now...", [currArray objectAtIndex:i]);
			[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mdinfo",srcPath,[currArray objectAtIndex:i]]
				  toPath:[NSString stringWithFormat:@"%@%@.mdinfo",currDest,[currArray objectAtIndex:i]]
				   error:nil];
			[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mddata",srcPath,[currArray objectAtIndex:i]]
				  toPath:[NSString stringWithFormat:@"%@%@.mddata",currDest,[currArray objectAtIndex:i]]
				   error:nil];
			[files removeObjectForKey:[currArray objectAtIndex:i]];

		}
	}
	
	/* and all other files now */
	
	NSLog(@"Dealing with other backup files now");	
	
	BOOL isDir;
	
	for (id key in files) {
		currDest = [NSString stringWithFormat:@"%@Files/%@/", destPath, [[files objectForKey:key] objectForKey:@"Domain"]];
		
		if (!([fm fileExistsAtPath:currDest isDirectory:&isDir] && isDir) ) {
			[fm createDirectoryAtPath:currDest withIntermediateDirectories:YES attributes:nil error:nil];				
		}
		NSLog(@"Moving %@ to %@", key, [[files objectForKey:key] objectForKey:@"Domain"]);
		[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mdinfo",srcPath,key]
					toPath:[NSString stringWithFormat:@"%@%@.mdinfo",currDest,key]
					 error:nil];
		[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mddata",srcPath,key]
					toPath:[NSString stringWithFormat:@"%@%@.mddata",currDest,key]
					 error:nil];		
		
	}

	[pool drain];
    return 0;
}
