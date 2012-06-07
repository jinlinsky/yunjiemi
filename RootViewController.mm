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
	if (!file.Open("/config/test.txt", File::OM_READ))
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
	if (mIsConnected == -1) return;
	
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
		system("open com.ted.TED");

		// play movie

	}else if(strcmp(data, "STOP") == 0)
	{
		system("open com.skype.SkypeForiPad");

		// stop movie
	}
}


@end
