
#import <Foundation/Foundation.h>
#include "Console.h"
#import <AppKit/AppKit.h>
#import "ScreenRecorder.h"
//#import <ncurses.h>
//#import <string.h>
//#import <termios.h>

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSApplication sharedApplication];
	
	Console *test = [[Console alloc] init];
	NSFileHandle *fileHandle = [[NSFileHandle fileHandleWithStandardInput] retain];
	
	//Register myself for notifications
	[[NSNotificationCenter defaultCenter] addObserver:test
											 selector:@selector(dataAvailable:)
												 name:NSFileHandleDataAvailableNotification
											   object:fileHandle];
	
	//Get wait data on the background thread
	[fileHandle waitForDataInBackgroundAndNotify];
	
	[NSApp run];
	
	[fileHandle closeFile];
	[fileHandle release];	//Proper memory management
	[pool drain];
    return 0;
}

/* ATTEMPT FROM HERE: http://cc.byexamples.com/2007/04/08/non-blocking-user-input-in-loop-without-ncurses/ 
int kbhit()
{
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
    select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
    return FD_ISSET(STDIN_FILENO, &fds);
}

void nonblock(int state)
{
    struct termios ttystate;
	
    //get the terminal state
    tcgetattr(STDIN_FILENO, &ttystate);
	
    if (state==3)
    {
        //turn off canonical mode
        ttystate.c_lflag &= ~ICANON;
        //minimum of number input read.
        ttystate.c_cc[VMIN] = 1;
    }
    else if (state==5)
    {
        //turn on canonical mode
        ttystate.c_lflag |= ICANON;
    }
    //set the terminal attributes.
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);
	
}

int main()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	char c;
    int i=0;
	
	ScreenRecorder *mRecorder = [[ScreenRecorder alloc] init:YES];
	[mRecorder startRecording:@"test"];
    nonblock(3);
    while(!i)
    {
        usleep(10);
        i=kbhit();
        if (i!=0)
        {
            c=fgetc(stdin);
            if (c=='q')
                i=1;
            else
                i=0;
        }
		
        //fprintf(stderr,"%d ",i);
    }
    printf("\n you hit %c. \n",c);
    nonblock(5);
	[mRecorder stopRecording];
    [mRecorder release];
	[pool drain];
	endwin();
    return 0;
}
*/

/*  ATTEMPT WITH NCURSES -----------------------------
int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL captureAudio = YES;
	
	initscr();
	keypad(stdscr, TRUE);
	timeout(0);
	
    printw("ReelFX Mac Screen Recorder\n");
	printw("(requires Snow Leopard, Mac OS 10.6)\n");
	refresh();
	if (argc < 2 || argv[argc-1][0] == '-') {
		printw("\nERROR: Please specify a proper output file.\n");
		refresh();
		endwin();
		[pool drain];
		return 1;
	}
	
	int i;
	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i],"-noaudio") == 0) {
			captureAudio = NO;
		}
	}
	NSString *file = [[[NSString alloc] initWithCString: argv[argc-1]] autorelease];
	
	char command[255];
	ScreenRecorder *mRecorder = [[ScreenRecorder alloc] init:captureAudio];
	
	while (true && mRecorder != nil) {
		printw("Please type a command ('q' to quit): \n");
		scanw("%s",command);
		if(strcmp(command,"start") == 0) {
			//[NSThread detachNewThreadSelector:@selector(startRecording:) toTarget:mRecorder withObject:file];
			[mRecorder startRecording:file];
			printw("Starting...\n");
		} 
		else if(strcmp(command,"stop") == 0) {
			[mRecorder stopRecording];
			printw("Stopping...\n");
		}
		else if(strcmp(command,"check") == 0) {
			[mRecorder checkRecording];
		}		
		else if(strcmp(command,"help") == 0) {
			printw("Usage: (To be completed)\n");
		}
		else if(strcmp(command, "quit") == 0 || strcmp(command,"q") == 0) {
			[mRecorder quit];
			printw("Goodbye\n");
			break;
		} else {
			printw("Unknown command! \n");
		}
		refresh();
	}
	
	[mRecorder release];
	[pool drain];
	endwin();
    return 0;
}
*/

/* ATTEMPT WITH NSNOTIFICATION -----------------------------
int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL captureAudio = YES;
	
    fprintf(stderr,"ReelFX Mac Screen Recorder\n");
	fprintf(stderr,"(requires Snow Leopard, Mac OS 10.6)\n");
	
	/*
	if (argc < 2 || argv[argc-1][0] == '-') {
		fprintf(stderr, "\nERROR: Please specify a proper output file.\n");
		[pool drain];
		return 0;
	}
	
	int i;
	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i],"-noaudio") == 0) {
			captureAudio = NO;
		}
	}
	NSString *file = [[[NSString alloc] initWithCString: argv[argc-1]] autorelease];
	
	char command[255];
	*/
/*	
	Console *test = [[Console alloc] init];
	//Create a file handle to read the standard input
	//NSThread* thread = [NSThread detachNewThreadSelector:@selector(startRecording:) toTarget:mRecorder withObject:file];
	NSFileHandle *fileHandle = [[NSFileHandle fileHandleWithStandardInput] retain];
	
	//Register myself for notifications
	[[NSNotificationCenter defaultCenter] addObserver:test
											 selector:@selector(dataAvailable:)
												 name:NSFileHandleDataAvailableNotification
											   object:fileHandle];
	
	//Get wait data on the background thread
	[fileHandle waitForDataInBackgroundAndNotify];
	/*NSLog(@"sent file handle to wait");
	while ([test running] == YES) {
		[NSThread sleepForTimeInterval:200];
	}
	NSLog(@"main process is ending");*/
/*	[test release];
	[fileHandle closeFile];
	[fileHandle release];	//Proper memory management
	[pool drain];
    return 0;
}
*/

/* ORIGINAL ATTEMPT -----------------------------
int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL captureAudio = YES;
	
    fprintf(stderr,"ReelFX Mac Screen Recorder\n");
	fprintf(stderr,"(requires Snow Leopard, Mac OS 10.6)\n");
	
	if (argc < 2 || argv[argc-1][0] == '-') {
		fprintf(stderr, "\nERROR: Please specify a proper output file.\n");
		[pool drain];
		return 0;
	}
	
	int i;
	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i],"-noaudio") == 0) {
			captureAudio = NO;
		}
	}
	NSString *file = [[[NSString alloc] initWithCString: argv[argc-1]] autorelease];
	
	char command[255];
	ScreenRecorder *mRecorder = [[ScreenRecorder alloc] init:captureAudio];
	
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
	
	[mRecorder release];
	[pool drain];
    return 0;
}
*/
