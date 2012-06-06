#import "RootViewController.h"

#import "Socket.h"
#import <Foundation/NSTimer.h>

#include <string.h>

@implementation RootViewController

- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	//mIsConnected = false;
	 
	UIButton* buttonTED = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonTED.frame = CGRectMake(20, 20, 100, 100);
	[buttonTED setTitle: @"connect" forState:UIControlStateNormal];
	[buttonTED setTitle: @"connect" forState:UIControlStateHighlighted];
	[buttonTED addTarget:self action:@selector(ButtonClickedConnect) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonTED];
	[self.view bringSubviewToFront:buttonTED];

	UIButton* buttonCamera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonCamera.frame = CGRectMake(180, 20, 100, 100);
	[buttonCamera setTitle: @"Send" forState:UIControlStateNormal];
	[buttonCamera setTitle: @"Send" forState:UIControlStateHighlighted];
	[buttonCamera addTarget:self action:@selector(ButtonClickedSend) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonCamera];
	[self.view bringSubviewToFront:buttonCamera];

}

- (void)ButtonClickedConnect
{
	if (mIsConnected) return;

	if (Socket::gSharedSocket.Connect("192.168.0.100", 12345))
	{
		self.view.backgroundColor = [UIColor blueColor];

		NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES]; 
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

		mIsConnected = true;
	}else
	{
		self.view.backgroundColor = [UIColor whiteColor];
	}
}

- (void)ButtonClickedSend
{
	//if (!mIsConnected) return;

	const char* data = "start moive";

	int dataLength = strlen(data);

	Socket::gSharedSocket.Send(data, dataLength);
}

- (void)handleTimer
{
	char data[512] = "";
	
	Socket::gSharedSocket.Recv(data, 512);

	if (strcmp(data, "PLAY") == 0)
	{
		system("open com.ted.TED");

		// play movie

	}else if(strcmp(data, "STOP") == 0)
	{
		system("open com.skype.SkypeForiPad");

		// stop movie
	}
}


@end
