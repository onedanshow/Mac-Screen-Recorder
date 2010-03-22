//
//  Console.h
//  mac-screen-recorder
//
//  Created by Daniel Dixon on 3/20/10.
//  Copyright 2010 ReelFX, Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "ScreenRecorder.h"

@interface Console : NSObject {
	ScreenRecorder *mRecorder;
	BOOL running;
}

@property BOOL running;
-(id)init;
-(void)dataAvailable:(NSNotification*)notification;

@end
