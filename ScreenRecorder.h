//
//  ScreenRecorder.h
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/19/10.
//  Copyright 2010 ReelFX, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@interface ScreenRecorder : NSObject {
	// instance variables	
	QTCaptureSession *mCaptureSession;
	QTCaptureMovieFileOutput *mCaptureMovieFileOutput;
	QTCaptureInput *mCaptureScreenInput;
	QTCaptureDeviceInput *mCaptureAudioDeviceInput;
}

// method declartions
-(id)init;
-(id)init:(BOOL)captureAudio;
-(void)startRecording:(NSString*)file;
-(void)stopRecording;
-(void)quit;
@end
