//
//  Console.m
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Console.h"


@implementation Console

-(Console*)initWithArgc:(int)argc withArgv:(char*[])argv 
{
	BOOL captureAudio = YES;
	
	if (self = [super init]) {
		NSLog(@"ReelFX Mac Screen Recorder");
		NSLog(@"requires Snow Leopard, Mac OS 10.6)");
		
		if (argc < 2 || argv[argc-1][0] == '-') {
			// If an error occurs here, send a [self release] message and return nil.
			NSLog(@"ERROR: Please specify a proper output file.");
			[self release];
			return nil;
		} else {
			NSLog(@"Please type a command (i.e. 'help'):");
		}
		
		// Find an parameters passed in via command line
		int i;
		for (i = 1; i < argc; i++) {
			if (strcmp(argv[i],"-noaudio") == 0) {
				captureAudio = NO;
			}
		}
		
		// Get the path and name of the output file
		mOutputFilePath = [[[NSString alloc] initWithCString: argv[argc-1]] autorelease];
		
		mRecorder = [[ScreenRecorder alloc] init:captureAudio];
		if(mRecorder == nil) {
			[self release];
			return nil;
		}
	}
	return self;
}

// Called when user hits return
- (void)dataAvailable:(NSNotification *)notification
{
	//Get the available data
	NSData *data = [[notification object] availableData];	//This will be the latest line of input
	
	//Convert it to a string
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	//Process the data, in this case, we just log it
	//NSLog(@"%@ = %@", dataString, data);
	
	if([dataString isEqualToString:@"start\n"]) {
		[mRecorder startRecording:mOutputFilePath];
		NSLog(@"Starting recording...");
	} 
	else if([dataString isEqualToString:@"stop\n"]) {
		[mRecorder stopRecording];
		NSLog(@"Stopping recording...");
	}
	else if([dataString isEqualToString:@"help\n"]) {
		NSLog(@"Usage (to be completed)");
	}
	else if(![dataString isEqualToString:@"quit\n"]) {
		[mRecorder stopRecording];
		NSLog(@"Unknown command!\n");
	}
	
	
	// Wait for new input or exit?
	if ([dataString isEqualToString:@"quit\n"]) {
		NSLog(@"Goodbye");
		[NSApp terminate:self];
		[dataString release];
	} else {
		//Clean up the string
		[dataString release];
		
		//the waitFor... method only works once, so reregister.
		[[notification object] waitForDataInBackgroundAndNotify];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[mRecorder release];
	[super dealloc];
}

@end
