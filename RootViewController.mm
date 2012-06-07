#import "RootViewController.h"
#import "File.h"
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
	
	File file;
	if (!file.Open("/var/stash/Applications.9UfCP1/YunJieMi.app/test.txt", File::OM_READ))
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

	if (result == -1) // result always -1?
	{
	
		//self.view.backgroundColor = [UIColor blueColor];



		mIsConnected = true;

	}else
	{
		//self.view.backgroundColor = [UIColor whiteColor];
	}
}

- (void)ButtonClickedSend
{
	const char* data = "START";

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
