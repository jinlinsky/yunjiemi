#import "RootViewController.h"
// import
#import "File.h"
#import "Socket.h"
#import <Foundation/NSTimer.h>
#import <sys/sysctl.h>
// include
#include <string.h>
#include "Config.h"

@implementation RootViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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
	bool loadConfig = config.LoadConfig("/config/yunjiemi.txt");
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
	// wating label
	//----------------------------------------------------------
	CGRect labelFrame = screenFrame;
	labelFrame.origin.x = 0;
	labelFrame.origin.y = 0;
	
	mWaitingLabel = [[UILabel alloc] initWithFrame:labelFrame];
	mWaitingLabel.numberOfLines = 0;
	mWaitingLabel.textAlignment = UITextAlignmentCenter;
	mWaitingLabel.text = [[NSString alloc] initWithString:@"Waiting..."];
	[self.view addSubview:mWaitingLabel];
	[self.view bringSubviewToFront:mWaitingLabel];
	
	//----------------------------------------------------------
	// setup timer
	//----------------------------------------------------------
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(MessageReceiverTimer) userInfo:nil repeats:YES]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)viewDidUnload
{
	[mMoviePlayerController release];
	mIsConnected = false;
	Socket::gSharedSocket.Disconnect();
}

- (void)ButtonClickedSend
{
/*
	// get process information
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;

    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);

    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;

    do {

        size += size / 10;
        newprocess = (kinfo_proc *)realloc(process, size);

        if (!newprocess){

            if (process){
                free(process);
            }

            return;
        }

        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);

    } while (st == -1 && errno == ENOMEM);

    if (st == 0){

        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);

            if (nprocess){

                for (int i = nprocess - 1; i >= 0; i--){

                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
					
					const char* nameData = [processName UTF8String];
					int nameDataLength = strlen(nameData);
					Socket::gSharedSocket.Send(nameData, nameDataLength);
					
                    [processID release];
                    [processName release];
                }

                free(process);
            }
        }
    }
*/
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
