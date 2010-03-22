//
//  ScreenRecorder.m
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/19/10.
//  Copyright 2010 ReelFX, Inc. All rights reserved.
//

#import "ScreenRecorder.h"


@implementation ScreenRecorder : NSThread


-(id)init
{
	return [self init:YES];
}

-(id)init:(BOOL)captureAudio
{
    if (self = [super init]) {
		
		// If an error occurs here, send a [self release] message and return nil.
		BOOL success = YES;
		NSError *error = nil;

		// create a capture session
		mCaptureSession = [[QTCaptureSession alloc] init];
		
		// attach the screen input to the capture session 
		mCaptureScreenInput = [[NSClassFromString(@"QTCaptureScreenInput") alloc] init];
		success = [mCaptureSession addInput:mCaptureScreenInput error:&error];
		if (!success) {
			NSLog(@"Could not attach the screen input to the capture session!");
			[self release];
			return nil;
		}
		if(error != nil) {
			NSLog(@"%@", [error localizedDescription]);
		}
		
		if (captureAudio) {
			// grab the default audio device
			QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
			success = [audioDevice open:&error];
			if(!success) {
				NSLog(@"Could not start the audio device!");
				[self release];
				return nil;
			}
			
			// attach the audio input to the capture session
			mCaptureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
			success = [mCaptureSession addInput:mCaptureAudioDeviceInput error:&error];
			if (!success) {
				NSLog(@"Could not attach the audio device to the capture session!");
				[self release];
				return nil;
			}
		}
		if(error != nil) {
			NSLog(@"%@", [error localizedDescription]);
		}
		
		// specify the output file
		mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
		success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
		if(!success) {
			NSLog(@"Could not obtain a file output the capture session!");
			[self release];
			return nil;
		}
		if(error != nil) {
			NSLog(@"%@", [error localizedDescription]);
		}
		
		// set this class as a delegate for the output file
		[mCaptureMovieFileOutput setDelegate:self];
		
		// specify compression by grabbing all the "connections" to the output file, looking at their type, and setting options
		NSEnumerator *connectionEnumator = [[mCaptureMovieFileOutput connections] objectEnumerator];
		QTCaptureConnection *connection;
		
		while ((connection = [connectionEnumator nextObject])) {
			NSString *mediaType = [connection mediaType];
			QTCompressionOptions *compressionOptions = nil;
			
			if([mediaType isEqualToString:QTMediaTypeVideo]) {
				NSLog(@"Setting video compression.");
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeH264Video"];
			} else if ([mediaType isEqualToString:QTMediaTypeSound]) {
				NSLog(@"Setting audio compression.");
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
			} else {
				NSLog(@"Found an odd media connection type.");
			}

			
			[mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
		}
		
		// start capturing!
		[mCaptureSession startRunning];
		return self;
    } else {
		[self release];
		return nil;
	}
}

-(void)startRecording:(NSString*)file
{
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:@"/test_DANIEL.mov"]];
}

-(void)checkRecording 
{
	if ([mCaptureSession isRunning]) {
		printf("The capture is running.\n");
		printf("The capture has %i inputs.\n",[[mCaptureSession inputs] count]);
		if([mCaptureMovieFileOutput isRecordingPaused]) {
			printf("The file output recording is paused!\n");
		} else {
			printf("The file output recording is NOT paused.\n");
		}

	} else {
		printf("The capture is NOT running.\n");
	}
}

-(void)stopRecording
{
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
}

-(void)quit {
	[self stopRecording];
	[mCaptureSession stopRunning];
	if([[mCaptureAudioDeviceInput device] isOpen])
		[[mCaptureAudioDeviceInput device] close];
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willStartRecordingToOutputFileURL:(NSURL *)fileURL forConnections:(NSArray *)connections
{
	NSLog(@"About to start recording!");
}

-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didStartRecordingToOutputFileURL:(NSURL *)fileURL forConnections:(NSArray *)connections dueToError:(NSError*)error
{
	NSLog(@"Started recording!");
}

-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	//[@"This is a test file" writeToFile:@"test.txt" atomically:YES];
	
	NSError* err = nil;
	NSLog(@"Finished recording!");
	NSLog(@"%@", outputFileURL);
	// apparently can't use NSWorkSpace if not making a GUI: http://stackoverflow.com/questions/1743934/transparent-process-creation-for-cocoa-components
	//[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	[fileManager copyItemAtURL:outputFileURL toURL:[NSURL fileURLWithPath:@"/Users/daniel/Desktop/test_commandline.mov"] error:&err];
	if(err != nil) {
		NSLog(@"ERROR: %@", [err localizedDescription]);
	}
}

-(void)dealloc
{
	[mCaptureSession release];
	[mCaptureAudioDeviceInput release];
	[mCaptureMovieFileOutput release];
	[mCaptureScreenInput release];
	[super dealloc];
}

@end
