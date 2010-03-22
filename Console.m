//
//  Console.m
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Console.h"


@implementation Console

@synthesize running;

-(id)init {
	if (self = [super init]) {
		mRecorder = [[ScreenRecorder alloc] init];
		running = YES;
	}
	return self;
}

- (void)dataAvailable:(NSNotification *)notification
{
	//This method will be triggered when the user presses the return key.
	//Get the available data
	NSData *data = [[notification object] availableData];	//This will be the latest line of input
	
	//Convert it to a string
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	//Process the data, in this case, we just log it
	NSLog(@"%@ = %@", dataString, data);
	
	if([dataString isEqualToString:@"start\n"]) {
		[mRecorder startRecording:@"test"];
		fprintf(stderr,"Starting...\n");
	} 
	else if([dataString isEqualToString:@"stop\n"]) {
		[mRecorder stopRecording];
		fprintf(stderr,"Stopping...\n");
	}
	
	if ([dataString isEqualToString:@"quit\n"]) {
		[NSApp terminate:self];
		[dataString release];
	} else {
		//Clean up the string
		[dataString release];
		
		//the waitFor... method only works once, so reregister.
		[[notification object] waitForDataInBackgroundAndNotify];
	}
	
	/*
	
	while (true && mRecorder != nil) {
		fprintf(stderr,"\nPlease type a command ('q' to quit): \n");
		fscanf(stdin,"%s",command);
		if(strcmp(command,"start") == 0) {
			[NSThread detachNewThreadSelector:@selector(startRecording:) toTarget:mRecorder withObject:file];
			fprintf(stderr,"Starting...\n");
		} 
		else if(strcmp(command,"stop") == 0) {
			[mRecorder stopRecording];
			fprintf(stderr,"Stopping...\n");
		}
		else if(strcmp(command,"check") == 0) {
			[mRecorder checkRecording];
		}		
		else if(strcmp(command,"help") == 0) {
			fprintf(stderr,"Usage: (To be completed)\n");
		}
		else if(strcmp(command, "quit") == 0 || strcmp(command,"q") == 0) {
			[mRecorder quit];
			fprintf(stderr,"Goodbye\n");
			break;
		} else {
			fprintf(stderr,"Unknown command! \n");
		}
	}
	*/
	
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//[fileHandle closeFile];
	//[fileHandle release];	//Proper memory management
	[mRecorder release];
	[super dealloc];
}

@end
