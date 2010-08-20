//
//  Console.h
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/20/10.

#import <Foundation/Foundation.h>
#import "ScreenRecorder.h"

@interface Console : NSObject {
	ScreenRecorder *mRecorder;
	NSString *mOutputFilePath;
}

-(Console*)initWithArgc:(int)argc withArgv:(char*[])argv;
-(void)dataAvailable:(NSNotification*)notification;

@end
