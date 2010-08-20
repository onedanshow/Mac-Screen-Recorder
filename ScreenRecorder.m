//
//  ScreenRecorder.m
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/19/10.
//

#import "ScreenRecorder.h"


@implementation ScreenRecorder


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
				//NSLog(@"Setting video compression.");
				// QTCompressionOptionsLosslessAnimationVideo produces HUGE files
				// according to this page, custom options are not available: http://developer.apple.com/mac/library/qa/qa2008/qa1586.html (see bottom)
				// supposedly a way around it: http://osdir.com/ml/quicktime-api/2009-06/msg00122.html (older than the prior page)
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeH264Video"]; //QTCompressionOptionsLosslessAnimationVideo"];
			} else if ([mediaType isEqualToString:QTMediaTypeSound]) {
				//NSLog(@"Setting audio compression.");
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsVoiceQualityAACAudio"]; //QTCompressionOptionsHighQualityAACAudio"];
			} else {
				NSLog(@"Found an odd media connection type.");
			}
			
			[mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
		}
		// unfortunately this increasing the file size dramatically for no reason:
		//[mCaptureMovieFileOutput setMinimumVideoFrameInterval:(1.0/15.0)]; // consider denominator the framerate

		return self;
    } else {
		[self release];
		return nil;
	}
}

-(void)startRecording:(NSString*)file
{
	// tell capture session to start reading inputs and sending to outputs
	[mCaptureSession startRunning];	
	// tell file output where to save to
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:file]];
}

-(void)stopRecording
{
	// tell file output to stop recording
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
	// tell capture session to stop reading input and sending to outputs
	[mCaptureSession stopRunning];
}

-(void)quit {
	[self stopRecording];
	if([[mCaptureAudioDeviceInput device] isOpen])
		[[mCaptureAudioDeviceInput device] close];
}

-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{	
	NSLog(@"QTCaptureFileOutput has stopped recording!");
	//NSLog(@"%@", outputFileURL);
	// [[NSWorkspace sharedWorkspace] openURL:outputFileURL]; // opens file in Quicktime Player
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
