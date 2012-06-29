#import "RootViewController.h"
// import
#import <Foundation/NSTimer.h>
#import <sys/sysctl.h>
// include
#include <string.h>
#include "Config.h"
#include "File.h"
#include "Socket.h"

@implementation RootViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//----------------------------------------------------------
	// initialize movie controller
	//----------------------------------------------------------
	NSString* moviePath = [[NSString alloc] initWithUTF8String:"/config/vedio.mov"];
	NSURL* movieURL = [NSURL fileURLWithPath: moviePath isDirectory:YES];
	
	mMoviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL: movieURL];
 
    mMoviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
    mMoviePlayerController.movieControlMode = MPMovieControlModeHidden;
 
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
                    addObserver: nil
                       selector: @selector(myMovieFinishedCallback:)
                           name: MPMoviePlayerPlaybackDidFinishNotification
                         object: mMoviePlayerController];
	
	[moviePath release];
	
	CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
	
	//----------------------------------------------------------
	// initialize socket connection
	//----------------------------------------------------------
	Config config;
	bool loadConfig = config.LoadConfig("/config/config.txt");
	if (!loadConfig)
	{
		self.view.backgroundColor = [UIColor blueColor];
		return;
	}

	std::string ip   = config.GetText("ip");
	std::string port = config.GetText("port");

	int result = Socket::gSharedSocket.Connect(ip.c_str(), atoi(port.c_str()), false);
	if (result == -1)
	{
		self.view.backgroundColor = [UIColor redColor];
		return;
	}
	
	mIsConnected = true;
	
	//----------------------------------------------------------
	// background
	//----------------------------------------------------------
	UIImageView* bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_background.jpg"]];
	
	[self.view addSubview:bgImage];
	[self.view bringSubviewToFront:bgImage];
	[bgImage release];
	
	//----------------------------------------------------------
	// logo
	//----------------------------------------------------------
	UIImageView* logImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_icon.png"]];
	
	[self.view addSubview:logImage];
	[self.view bringSubviewToFront:logImage];
	[logImage release];
	
	//----------------------------------------------------------
	// setup timer
	//----------------------------------------------------------
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(MessageReceiverTimer) userInfo:nil repeats:YES]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)viewDidUnload
{
	[mMoviePlayerController release];
	
	if (mIsConnected)
	{
		Socket::gSharedSocket.Disconnect();
		mIsConnected = false;
	}
}

- (void)MessageReceiverTimer
{
	char data[512] = "";
	
	Socket::gSharedSocket.Recv(data, 512);

	if (strcmp(data, "PLAY") == 0)
	{
		// play movie
		[self playMovie];

	}else if(strcmp(data, "STOP") == 0)
	{
		// stop movie
		[self stopMovie];
	}
}

- (void)playMovie
{
    // Movie playback is asynchronous, so this method returns immediately.
	if (mMoviePlayerController != nil)
    {
		[mMoviePlayerController play];
	}
}

- (void)stopMovie
{
	if (mMoviePlayerController != nil)
	{
		[mMoviePlayerController stop];
	}
}


@end
