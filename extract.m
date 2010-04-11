#import <Foundation/Foundation.h>
#import "NSDataAdditions.h"

void doMagic(NSString *src, NSString *dest) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString *srcPath;
	NSString *destPath;

	if ([src hasSuffix:@"/"]) {
		srcPath = src;		
	} else {
		srcPath = [NSString stringWithFormat:@"%@/", src];
	}

	if ([dest hasSuffix:@"/"]) {
		destPath = dest;		
	} else {
		destPath = [NSString stringWithFormat:@"%@/", dest];
	}

	NSDictionary *manifest = [NSPropertyListSerialization propertyListWithData:[[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@Manifest.plist", srcPath]] valueForKey:@"Data"]
																	   options:NSPropertyListImmutable format:nil error:nil];
	
	NSDictionary *applications = [manifest objectForKey:@"Applications"];
	NSMutableDictionary *files = [[manifest objectForKey:@"Files"] mutableCopy];
	
	NSFileManager *fm = [NSFileManager defaultManager];	
	
	// lets do applications first
	int i;
	NSString *currDest;
	NSArray *currArray;
	
	printf("Dealing with Application backup files now\n");
	
	for (id key in applications) {
		currDest = [NSString stringWithFormat:@"%@Applications/%@/",destPath,key];
		currArray = [[applications objectForKey:key] objectForKey:@"Files"];
		
		printf("\tDealing with %s now...\n", [key cString]);
		[fm createDirectoryAtPath:currDest withIntermediateDirectories:YES attributes:nil error:nil];		
		
		for (i=0;i<[currArray count];i++) {
			printf("\t\tMoving %s now...\n", [[currArray objectAtIndex:i] cString]);
			[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mdinfo",srcPath,[currArray objectAtIndex:i]]
						toPath:[NSString stringWithFormat:@"%@%@.mdinfo",currDest,[currArray objectAtIndex:i]]
						 error:nil];
			[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mddata",srcPath,[currArray objectAtIndex:i]]
						toPath:[NSString stringWithFormat:@"%@%@.mddata",currDest,[currArray objectAtIndex:i]]
						 error:nil];
			[files removeObjectForKey:[currArray objectAtIndex:i]];
			
		}
	}
	
	// and all other files now
	
	printf("\nDealing with other backup files now\n");	
	
	BOOL isDir;
	
	for (id key in files) {
		currDest = [NSString stringWithFormat:@"%@Files/%@/", destPath, [[files objectForKey:key] objectForKey:@"Domain"]];
		
		if (!([fm fileExistsAtPath:currDest isDirectory:&isDir] && isDir) ) {
			[fm createDirectoryAtPath:currDest withIntermediateDirectories:YES attributes:nil error:nil];				
		}
		printf("Moving %s to %s\n", [key cString], [[[files objectForKey:key] objectForKey:@"Domain"] cString]);
		[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mdinfo",srcPath,key]
					toPath:[NSString stringWithFormat:@"%@%@.mdinfo",currDest,key]
					 error:nil];
		[fm copyItemAtPath:[NSString stringWithFormat:@"%@%@.mddata",srcPath,key]
					toPath:[NSString stringWithFormat:@"%@%@.mddata",currDest,key]
					 error:nil];		
		
	}
	[files release];
	[pool drain];
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
	if (argc < 3) {
		printf("Usage: extract <src dir> <dest dir>\n");
	} else {
		doMagic([NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding], [NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding]);
	}
	
	[pool drain];
	
    return 0;
}
