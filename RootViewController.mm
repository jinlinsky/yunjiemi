#import "RootViewController.h"
// import
#import <Foundation/NSTimer.h>
#import <sys/sysctl.h>
// include
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
	// read config file
	//----------------------------------------------------------
	Config config;
	bool loadConfig = config.LoadConfig("/config/config.txt");
	if (!loadConfig)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error message"
		message:@"read config.txt failed!"
		delegate:nil
		cancelButtonTitle:@"OK"
		otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}

	mIp   = [[NSString alloc] initWithFormat: @"%s", config.GetText("ip").c_str()];
	mPort = [[NSString alloc] initWithFormat: @"%s", config.GetText("port").c_str()];
	
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
	
	if (Socket::gSharedSocket.GetConnectState() != Socket::CS_NOT_CONNECTED)
	{
		Socket::gSharedSocket.Disconnect();
	}
}

- (void)MessageReceiverTimer
{
	char data_receive[512] = "";
	
	// try to receive the data from the server
	// it can also reset the socket state if the connection is broken
	Socket::gSharedSocket.Recv(data_receive, 512);
	
	if (Socket::gSharedSocket.GetConnectState() == Socket::CS_NOT_CONNECTED)
	{
		Socket::gSharedSocket.Connect([mIp UTF8String], atoi([mPort UTF8String]), true);
	
		return;
	}else if (Socket::gSharedSocket.GetConnectState() == Socket::CS_CONNECTING)
	{
		//self.view.backgroundColor = [UIColor redColor];
		
		// do something here to show the current state is conneccting
		
		return;
	}
	
	if (strcmp(data_receive, "PLAY") == 0)
	{
		// play movie
		[self playMovie];

	}else if(strcmp(data_receive, "STOP") == 0)
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
