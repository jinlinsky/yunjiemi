#import "RootViewController.h"
#import "File.h"
#import "Socket.h"

#import <Foundation/NSTimer.h>
#import <sys/sysctl.h>

#include <string.h>

@implementation RootViewController


- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	mIsConnected = false;
	 
	UIButton* buttonConnect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonConnect.frame = CGRectMake(20, 20, 100, 100);
	[buttonConnect setTitle: @"connect" forState:UIControlStateNormal];
	[buttonConnect setTitle: @"connect" forState:UIControlStateHighlighted];
	[buttonConnect addTarget:self action:@selector(ButtonClickedConnect) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonConnect];
	[self.view bringSubviewToFront:buttonConnect];

	UIButton* buttonSend = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonSend.frame = CGRectMake(180, 20, 100, 100);
	[buttonSend setTitle: @"Send" forState:UIControlStateNormal];
	[buttonSend setTitle: @"Send" forState:UIControlStateHighlighted];
	[buttonSend addTarget:self action:@selector(ButtonClickedSend) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonSend];
	[self.view bringSubviewToFront:buttonSend];
	
	
	// initialize movie controller
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
}

- (void)viewDidUnload
{
	[MPMoviePlayerController release];
}

void playVideo();

- (void)ButtonClickedConnect
{
	if (mIsConnected) return;
	
	File file;
	if (!file.Open("/config/yunjiemi.txt", File::OM_READ))
		return;

	std::string ip;
	std::string port;
	file.ReadLine(ip);
	file.ReadLine(port);
	file.Close();

	int result = Socket::gSharedSocket.Connect(ip.c_str(), atoi(port.c_str()));
	//int result = Socket::gSharedSocket.Connect("192.168.2.104", 12345);
	
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

	if (result != -1)
	{
		mIsConnected = true;
		self.view.backgroundColor = [UIColor blueColor];
	}else
	{
		self.view.backgroundColor = [UIColor whiteColor];
	}
}

- (void)ButtonClickedSend
{
	if (!mIsConnected) return;
	
	const char* data = "START";

	int dataLength = strlen(data);

	Socket::gSharedSocket.Send(data, dataLength);
	
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

- (void)handleTimer
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
    [mMoviePlayerController play];
}

- (void)stopMovie
{
    [mMoviePlayerController stop];
}


@end
